# tar.tcl --
#
#       Creating, extracting, and listing posix tar archives
#
# Copyright (c) 2004    Aaron Faupell <afaupell@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: tar.tcl,v 1.11 2007/02/09 06:03:56 afaupell Exp $

package provide tar 0.4

namespace eval ::tar {}

proc ::tar::parseOpts {acc opts} {
    array set flags $acc
    foreach {x y} $acc {upvar $x $x}
    
    set len [llength $opts]
    set i 0
    while {$i < $len} {
        set name [string trimleft [lindex $opts $i] -]
        if {![info exists flags($name)]} {return -code error "unknown option \"$name\""}
        if {$flags($name) == 1} {
            set $name [lindex $opts [expr {$i + 1}]]
            incr i $flags($name)
        } elseif {$flags($name) > 1} {
            set $name [lrange $opts [expr {$i + 1}] [expr {$i + $flags($name)}]]
            incr i $flags($name)
        } else {
            set $name 1
        }
        incr i
    }
}

proc ::tar::pad {size} {
    set pad [expr {512 - ($size % 512)}]
    if {$pad == 512} {return 0}
    return $pad
}

proc ::tar::readHeader {data} {
    binary scan $data a100a8a8a8a12a12a8a1a100a6a2a32a32a8a8a155 \
                      name mode uid gid size mtime cksum type \
                      linkname magic version uname gname devmajor devminor prefix
                               
    foreach x {name mode type linkname magic uname gname prefix mode uid gid size mtime cksum version devmajor devminor} {
        set $x [string trim [set $x] "\x00"]
    }
    set mode [string trim $mode " \x00"]
    foreach x {uid gid size mtime cksum version devmajor devminor} {
        set $x [format %d 0[string trim [set $x] " \x00"]]
    }

    return [list name $name mode $mode uid $uid gid $gid size $size mtime $mtime \
                 cksum $cksum type $type linkname $linkname magic $magic \
                 version $version uname $uname gname $gname devmajor $devmajor \
                 devminor $devminor prefix $prefix]
}

proc ::tar::contents {file} {
    set fh [::open $file]
    while {![eof $fh]} {
        array set header [readHeader [read $fh 512]]
        if {$header(name) == ""} break
        lappend ret $header(prefix)$header(name)
        seek $fh [expr {$header(size) + [pad $header(size)]}] current
    }
    close $fh
    return $ret
}

proc ::tar::stat {tar {file {}}} {
    set fh [::open $tar]
    while {![eof $fh]} {
        array set header [readHeader [read $fh 512]]
        if {$header(name) == ""} break
        seek $fh [expr {$header(size) + [pad $header(size)]}] current
        if {$file != "" && "$header(prefix)$header(name)" != $file} {continue}
        set header(type) [string map {0 file 5 directory 3 characterSpecial 4 blockSpecial 6 fifo 2 link} $header(type)]
        set header(mode) [string range $header(mode) 2 end]
        lappend ret $header(prefix)$header(name) [list mode $header(mode) uid $header(uid) gid $header(gid) \
                    size $header(size) mtime $header(mtime) type $header(type) linkname $header(linkname) \
                    uname $header(uname) gname $header(gname) devmajor $header(devmajor) devminor $header(devminor)]
    }
    close $fh
    return $ret
}

proc ::tar::get {tar file} {
    set fh [::open $tar]
    fconfigure $fh -encoding binary -translation lf -eofchar {}
    while {![eof $fh]} {
        array set header [readHeader [read $fh 512]]
        if {$header(name) == ""} break
        set name [string trimleft $header(prefix)$header(name) /]
        if {$name == $file} {
            set file [read $fh $header(size)]
            close $fh
            return $file
        }
        seek $fh [expr {$header(size) + [pad $header(size)]}] current
    }
    close $fh
    return {}
}

proc ::tar::untar {tar args} {
    set nooverwrite 0
    set data 0
    set nomtime 0
    set noperms 0
    parseOpts {dir 1 file 1 glob 1 nooverwrite 0 nomtime 0 noperms 0} $args
    if {![info exists dir]} {set dir [pwd]}
    set pattern *
    if {[info exists file]} {
        set pattern [string map {* \\* ? \\? \\ \\\\ \[ \\\[ \] \\\]} $file]
    } elseif {[info exists glob]} {
        set pattern $glob
    }

    set ret {}
    set fh [::open $tar]
    fconfigure $fh -encoding binary -translation lf -eofchar {}
    while {![eof $fh]} {
        array set header [readHeader [read $fh 512]]
        if {$header(name) == ""} break
        set name [string trimleft $header(prefix)$header(name) /]
        if {![string match $pattern $name] || ($nooverwrite && [file exists $name])} {
            seek $fh [expr {$header(size) + [pad $header(size)]}] current
            continue
        }

        set name [file join $dir $name]
        if {![file isdirectory [file dirname $name]]} {
            file mkdir [file dirname $name]
            lappend ret [file dirname $name] {}
        }
        if {[string match {[0346]} $header(type)]} {
            set new [::open $name w+]
            fconfigure $new -encoding binary -translation lf -eofchar {}
            fcopy $fh $new -size $header(size)
            close $new
            lappend ret $name $header(size)
        } elseif {$header(type) == 5} {
            file mkdir $name
            lappend ret $name {}
        } elseif {[string match {[12]} $header(type)] && $::tcl_platform(platform) == "unix"} {
            catch {file delete $name}
            if {![catch {file link [string map {1 -hard 2 -symbolic} $header(type)] $name $header(linkname)}]} {
                lappend ret $name {}
            }
        }
        seek $fh [pad $header(size)] current
        if {![file exists $name]} continue

        if {$::tcl_platform(platform) == "unix"} {
	    set mode 0000644
	    if {$header(type) == 5} {set mode 0000755}
            if {!$noperms} {
		 catch {file attributes $name -permissions $mode}
            }
            catch {file attributes $name -owner $header(uid) -group $header(gid)}
            catch {file attributes $name -owner $header(uname) -group $header(gname)}
        }
        if {!$nomtime} {
            file mtime $name $header(mtime)
        }
    }
    close $fh
    return $ret
}

#new fixed tarball header creation routine
proc ::tar::createHeader_cex341_000 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001760"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0100644
			if {$stat(type) == "directory"} {set mode 0000775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_cex341_content {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001760"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000644
			if {$stat(type) == "directory"} {set mode 0000755}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_cex341_update {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001760"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000644
			if {$stat(type) == "directory"} {set mode 0040775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_cex341_dev3 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		# if {[file exists $name]} continue
		set uid "0001760"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000755
			if {$stat(type) == "directory"} {set mode 0040755}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_cex355_000 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001752"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0100644
			if {$stat(type) == "directory"} {set mode 0000775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_cex355_content {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001752"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000644
			if {$stat(type) == "directory"} {set mode 0000755}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_cex355_update {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001752"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000644
			if {$stat(type) == "directory"} {set mode 0040775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_cex355_dev3 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		# if {[file exists $name]} continue
		set uid "0001752"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000755
			if {$stat(type) == "directory"} {set mode 0040755}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}

proc ::tar::createHeader_dex3_000 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0000764"
		set gid "0000764"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "tetsu"
		set gname "tetsu"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0100644
			if {$stat(type) == "directory"} {set mode 0040775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_dex3_content {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0000764"
		set gid "0000764"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "tetsu"
		set gname "tetsu"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0100644
			if {$stat(type) == "directory"} {set mode 0040775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_dex3_update {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0000000"
		set gid "0000000"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "root"
		set gname "root"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0100644
			if {$stat(type) == "directory"} {set mode 0040775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_dex3_spkg {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001764"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "make_pup2_downversion"
		set gname "root"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000755
			if {$stat(type) == "directory"} {set mode 0040775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_dex3_dev3 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		# if {[file exists $name]} continue
		set uid "0000764"
		set gid "0000764"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "tetsu"
		set gname "tetsu"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0100775
			if {$stat(type) == "directory"} {set mode 0040775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}

proc ::tar::createHeader_cex4_000 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001752"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			if {$stat(type) == "directory" && $stat(name) == "dev_flash"}
				set mode 0000775
			else set mode 0000755
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_cex4_content {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001752"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000644
			if {$stat(type) == "directory"} {set mode 0000755}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_cex4_update {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001752"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000644
			if {$stat(type) == "directory"} {set mode 0000644}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_cex4_spkg {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001752"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000755
			# if {$stat(type) == "directory"} {set mode 0000775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_cex4_dev3 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		# if {[file exists $name]} continue
		set uid "0001752"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "pup_tool"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000755
			# if {$stat(type) == "directory"} {set mode 0040755}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}

proc ::tar::createHeader_dex4_000 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0000764"
		set gid "0000764"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "tetsu"
		set gname "tetsu"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0040775
			if {$stat(type) == "directory"} {set mode 0040775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_dex4_content {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0000764"
		set gid "0000764"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "tetsu"
		set gname "tetsu"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0100644
			if {$stat(type) == "directory"} {set mode 0040775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_dex4_update {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		# if {[file exists $name]} continue
		set uid "0001762"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "make_pup2"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000644
			# if {$stat(type) == "directory"} {set mode 0000775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_dex4_spkg {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		# if {[file exists $name]} continue
		set uid "0001762"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "make_pup2"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000755
			# if {$stat(type) == "directory"} {set mode 0000775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_dex4_dev3 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		# if {[file exists $name]} continue
		set uid "0000764"
		set gid "0000764"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "tetsu"
		set gname "tetsu"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0040775
			if {$stat(type) == "directory"} {set mode 0040775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}

proc ::tar::createHeader_deh4_000 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001041"
		set gid "0000764"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "kanee"
		set gname "kanee"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0040700
			if {$stat(type) == "directory"} {set mode 0040700}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_deh4_content {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		set uid "0001041"
		set gid "0000764"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "kanee"
		set gname "kanee"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0100600
			if {$stat(type) == "directory"} {set mode 0040700}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_deh4_update {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		# if {[file exists $name]} continue
		set uid "0001762"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "make_pup2"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000600
			# if {$stat(type) == "directory"} {set mode 0000600}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_deh4_spkg {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		# if {[file exists $name]} continue
		set uid "0001762"
		set gid "0001274"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "make_pup2"
		set gname "psnes"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0000755
			if {$stat(type) == "directory"} {set mode 0000755}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}
proc ::tar::createHeader_deh4_dev3 {name followlinks} {
		foreach x {linkname prefix devmajor devminor} {set $x ""}
		
		if {$followlinks} {
			file stat $name stat
		} else {
			file lstat $name stat
		}
		
		set type [string map {file 0 directory 5 characterSpecial 3 blockSpecial 4 fifo 6 link 2 socket A} $stat(type)]
		# if {[file exists $name]} continue
		set uid "0000764"
		set gid "0000764"
		set mtime [format %.11o $stat(mtime)]
		
		set uname "kanee"
		set gname "kanee"
		if {$::tcl_platform(platform) == "unix"} {
			set mode 00[file attributes $name -permissions]
			if {$stat(type) == "link"} {set linkname [file link $name]}
		} else {
			set mode 0040775
			if {$stat(type) == "directory"} {set mode 0040775}
		}
		
		set size 00000000000
		if {$stat(type) == "file"} {
			set size [format %.11o $stat(size)]
		}
		
		set name [string trimleft $name /]
		if {[string length $name] > 255} {
			return -code error "path name over 255 chars"
		} elseif {[string length $name] > 100} {
			set prefix [string range $name 0 end-100]
			set name [string range $name end-99 end]
		}

		set header [binary format a100a8A8A8A12A12A8a1a100A6a2a32a32a8a8a155a12 \
								  $name $mode $uid\x00 $gid\x00 $size\x00 $mtime\x00 {} $type \
								  $linkname ustar " " $uname $gname $devmajor $devminor $prefix {}]

		binary scan $header c* tmp
		set cksum 0
		foreach x $tmp {incr cksum $x}

		return [string replace $header 148 155 [binary format A8 0[format %o $cksum]\x00]]
	}

proc ::tar::recurseDirs {files followlinks} {
    foreach x $files {
        if {[file isdirectory $x] && ([file type $x] != "link" || $followlinks)} {
            if {[set more [glob -dir $x -nocomplain *]] != ""} {
                eval lappend files [recurseDirs $more $followlinks]
            } else {
                lappend files $x
            }
        }
    }
    return $files
}

#new fixed tarball archive creation routine
proc ::tar::writefile_cex341_000 {in out followlinks} {
		 puts -nonewline $out [createHeader_cex341_000 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_cex341_content {in out followlinks} {
		 puts -nonewline $out [createHeader_cex341_content $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_cex341_update {in out followlinks} {
		 puts -nonewline $out [createHeader_cex341_update $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_cex341_dev3 {in out followlinks} {
		 puts -nonewline $out [createHeader_cex341_dev3 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}

proc ::tar::create_cex341_000 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex341_000 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_cex341_content {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex341_content $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_cex341_update {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex341_update $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_cex341_dev3 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex341_dev3 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}

proc ::tar::writefile_cex355_000 {in out followlinks} {
		 puts -nonewline $out [createHeader_cex355_000 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_cex355_content {in out followlinks} {
		 puts -nonewline $out [createHeader_cex355_content $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_cex355_update {in out followlinks} {
		 puts -nonewline $out [createHeader_cex355_update $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_cex355_dev3 {in out followlinks} {
		 puts -nonewline $out [createHeader_cex355_dev3 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}

proc ::tar::create_cex355_000 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex355_000 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_cex355_content {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex355_content $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_cex355_update {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex355_update $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_cex355_dev3 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex355_dev3 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}

proc ::tar::writefile_dex3_000 {in out followlinks} {
		 puts -nonewline $out [createHeader_dex3_000 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_dex3_content {in out followlinks} {
		 puts -nonewline $out [createHeader_dex3_content $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_dex3_update {in out followlinks} {
		 puts -nonewline $out [createHeader_dex3_update $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_dex3_spkg {in out followlinks} {
		 puts -nonewline $out [createHeader_dex3_spkg $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_dex3_dev3 {in out followlinks} {
		 puts -nonewline $out [createHeader_dex3_dev3 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}

proc ::tar::create_dex3_000 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_dex3_000 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_dex3_content {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_dex3_content $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_dex3_update {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_dex3_update $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_dex3_spkg {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_dex3_spkg $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_dex3_dev3 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_dex3_dev3 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}

proc ::tar::writefile_cex4_000 {in out followlinks} {
		 puts -nonewline $out [createHeader_cex4_000 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_cex4_content {in out followlinks} {
		 puts -nonewline $out [createHeader_cex4_content $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_cex4_update {in out followlinks} {
		 puts -nonewline $out [createHeader_cex4_update $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_cex4_spkg {in out followlinks} {
		 puts -nonewline $out [createHeader_cex4_spkg $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_cex4_dev3 {in out followlinks} {
		 puts -nonewline $out [createHeader_cex4_dev3 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}

proc ::tar::create_cex4_000 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex4_000 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_cex4_content {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex4_content $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_cex4_update {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex4_update $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_cex4_spkg {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex4_spkg $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_cex4_dev3 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_cex4_dev3 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}

proc ::tar::writefile_dex4_000 {in out followlinks} {
		 puts -nonewline $out [createHeader_dex4_000 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_dex4_content {in out followlinks} {
		 puts -nonewline $out [createHeader_dex4_content $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_dex4_update {in out followlinks} {
		 puts -nonewline $out [createHeader_dex4_update $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_dex4_spkg {in out followlinks} {
		 puts -nonewline $out [createHeader_dex4_spkg $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_dex4_dev3 {in out followlinks} {
		 puts -nonewline $out [createHeader_dex4_dev3 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}

proc ::tar::create_dex4_000 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_dex4_000 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_dex4_content {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_dex4_content $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_dex4_update {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_dex4_update $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_dex4_spkg {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_dex4_spkg $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_dex4_dev3 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_dex4_dev3 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}

proc ::tar::writefile_deh4_000 {in out followlinks} {
		 puts -nonewline $out [createHeader_deh4_000 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_deh4_content {in out followlinks} {
		 puts -nonewline $out [createHeader_deh4_content $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_deh4_update {in out followlinks} {
		 puts -nonewline $out [createHeader_deh4_update $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_deh4_spkg {in out followlinks} {
		 puts -nonewline $out [createHeader_deh4_spkg $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}
proc ::tar::writefile_deh4_dev3 {in out followlinks} {
		 puts -nonewline $out [createHeader_deh4_dev3 $in $followlinks]
		 set size 0
		 if {[file type $in] == "file" || ($followlinks && [file type $in] == "link")} {
			 set in [::open $in]
			 fconfigure $in -encoding binary -translation lf -eofchar {}
			 set size [fcopy $in $out]
			 close $in
		 }
		 puts -nonewline $out [string repeat \x00 [pad $size]]
	}

proc ::tar::create_deh4_000 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_deh4_000 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_deh4_content {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_deh4_content $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_deh4_update {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_deh4_update $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_deh4_spkg {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_deh4_spkg $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}
proc ::tar::create_deh4_dev3 {tar files args} {
		set dereference 0
		parseOpts {dereference 0} $args
		
		set fh [::open $tar w+]
		fconfigure $fh -encoding binary -translation lf -eofchar {}
		foreach x [recurseDirs $files $dereference] {
			writefile_deh4_dev3 $x $fh $dereference
		}
		puts -nonewline $fh [string repeat \x00 6656]; # For some reason, normal tar puts 13 EOBs instead of 2

		close $fh
		return $tar
	}

proc ::tar::add {tar files args} {
    set dereference 0
    parseOpts {dereference 0} $args
    
    set fh [::open $tar r+]
    fconfigure $fh -encoding binary -translation lf -eofchar {}
    seek $fh -1024 end

    foreach x [recurseDirs $files $dereference] {
        writefile $x $fh $dereference
    }
    puts -nonewline $fh [string repeat \x00 1024]

    close $fh
    return $tar
}

proc ::tar::remove {tar files} {
    set n 0
    while {[file exists $tar$n.tmp]} {incr n}
    set tfh [::open $tar$n.tmp w]
    set fh [::open $tar r]

    fconfigure $fh  -encoding binary -translation lf -eofchar {}
    fconfigure $tfh -encoding binary -translation lf -eofchar {}

    while {![eof $fh]} {
        array set header [readHeader [read $fh 512]]
        if {$header(name) == ""} {
            puts -nonewline $tfh [string repeat \x00 1024]
            break
        }
        set name $header(prefix)$header(name)
        set len [expr {$header(size) + [pad $header(size)]}]
        if {[lsearch $files $name] > -1} {
            seek $fh $len current
        } else {
            seek $fh -512 current
            fcopy $fh $tfh -size [expr {$len + 512}]
        }
    }

    close $fh
    close $tfh

    file rename -force $tar$n.tmp $tar
}
