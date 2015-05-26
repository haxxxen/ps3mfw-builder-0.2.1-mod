#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 120
# Description: Update or set Spoofer for MFW or REBUG Firmwares

# Option --version: Select REBUG Firmware or leave empty for MFW
# Option --spoof: Select Spoofer Version
# Option --screen: Patch Screenshot Feature to vsh.self

# Type --version: combobox { { REBUG } }
# Type --spoof: combobox { { 4.70 64978 20150205 0001:CEX-ww 5271@svn+ssh://svn/ps3/svn/security/sdk_branches/release_470/trunk 50509@svn+ssh://svn/ps3/svn/sys/sdk_branches/release_470/trunk 16380@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/x3/trunk 6254@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/paf/trunk 94518@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/vsh/trunk 95@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/sys_jp/trunk 11554@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emu/branches/target101/ps1 11556@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emu/branches/target465/ps1_net 9246@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emu/branches/target202/ps1_new 9736@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emu/branches/target400/ps2 17227@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/lopnor/branches/target400/gx 17168@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/lopnor/branches/soft190/soft 10788@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emu/branches/target460/psp 4044@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emerald/current 20103@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/bdp/prof5/release } { 9.99 99999 99990909 0001:CEX-ww 5271@svn+ssh://svn/ps3/svn/security/sdk_branches/release_470/trunk 50509@svn+ssh://svn/ps3/svn/sys/sdk_branches/release_470/trunk 16380@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/x3/trunk 6254@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/paf/trunk 94518@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/vsh/trunk 95@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/sys_jp/trunk 11554@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emu/branches/target101/ps1 11556@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emu/branches/target465/ps1_net 9246@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emu/branches/target202/ps1_new 9736@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emu/branches/target400/ps2 17227@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/lopnor/branches/target400/gx 17168@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/lopnor/branches/soft190/soft 10788@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emu/branches/target460/psp 4044@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/emerald/current 20103@svn+ssh://svn.rd.scei.sony.co.jp/ps3/svn/bdp/prof5/release } }
# Type --screen: boolean

namespace eval ::13_spoofer_update {

    array set ::13_spoofer_update::options {
      --version ""
      --spoof ""
      --screen false
    }

    proc main {} {
		variable options
		if {$::13_spoofer_update::options(--spoof) == ""} {
			return -code error "  YOU HAVE NOT SELECTED SPOOFER VERSION !!!"
		} else {
			if {$::13_spoofer_update::options(--version) == "REBUG"} {
				log "Patching REBUG's vsh.self.cexsp & vsh.self.swp to spoof Build and Version Number"
					::modify_devflash_file [file join dev_flash vsh module vsh.self.cexsp] ::13_spoofer_update::patch_vsh_self
					::modify_devflash_file [file join dev_flash vsh module vsh.self.swp] ::13_spoofer_update::patch_vsh_self
				log "Patching version.txt.swp & index.dat.swp file to spoof all entries"
					::modify_devflash_file [file join dev_flash vsh etc version.txt.swp] ::13_spoofer_update::version_txt
			} else {
				log "Patching vsh.self to spoof Build and Version Number"
					::modify_devflash_file [file join dev_flash vsh module vsh.self] ::13_spoofer_update::patch_vsh_self
				log "Patching version.txt & index.dat file to spoof all entries"
					::modify_devflash_file [file join dev_flash vsh etc version.txt] ::13_spoofer_update::version_txt
			}
		}
		if {$::13_spoofer_update::options(--screen)} {
			set xml [file join dev_flash vsh resource explore xmb category_photo.xml]
			if {$::13_spoofer_update::options(--version) == "REBUG"} {
				log "Patching explore_category_photo.xml and REBUG's vsh.self file(s) to enable screenshot feature"
					::modify_devflash_file $xml ::13_spoofer_update::callback_patch
					::modify_devflash_file [file join dev_flash vsh module vsh.self] ::13_spoofer_update::patch_screen
					::modify_devflash_file [file join dev_flash vsh module vsh.self.cexsp] ::13_spoofer_update::patch_screen
					::modify_devflash_file [file join dev_flash vsh module vsh.self.swp] ::13_spoofer_update::patch_screen
			} else {
				log "Patching explore_category_photo.xml and vsh.self file to enable screenshot feature"
					::modify_devflash_file $xml ::13_spoofer_update::callback_patch
					::modify_devflash_file [file join dev_flash vsh module vsh.self] ::13_spoofer_update::patch_screen
			}
		}
    }

    proc patch_vsh_self {self} {
		::modify_self_file $self ::13_spoofer_update::patch_vsh_elf
	}
    proc patch_vsh_elf {elf} {
		variable options
		set release [lindex $options(--spoof) 0]
		set build [lindex $options(--spoof) 1]
		set major [lindex [split $release "."] 0]
		set minor [lindex [split $release "."] 1]
		log "Patching [file tail $elf] to spoof new Build and Version Number"
		log "Patching Build Number"
		# set search "[format %0.5d $fake_build]"
		set search "\x15\x88\x09\xCF\x4F\x3C"
		debug "search: $search"
		set replace "[format %0.5d $build]"
		debug "replace: $replace"
		set offset 6
		set mask 0			
		# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
		log "Patching Version Number"
		# set search "[format %0.2d ${fake_major}].[format %0.2d ${fake_minor}]"
        if {${::NEWMFW_VER} > "3.56"} {
			set search "\x00\x00\x5F\x76\x6E\x74\x30\x30\x38\x00"
		} else {
			set search "\x39\x39\x2E\x39\x39\x00\x00\x00"
		}
		debug "search: $search"
		set replace "[format %0.2d ${major}].[format %0.2d ${minor}]"
		debug "replace: $replace"
        if {${::NEWMFW_VER} > "3.56"} {
			set offset 12
		} else {
			set offset 8
		}
		set mask 0			
		# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
    }

    proc get_fw_release {filename} {
      set results [grep "^release:" $filename]
      set release [string trim [regsub "^release:" $results {}] ":"]
      return [string trim $release]
    }
    proc get_fw_build {filename} {
      set results [grep "^build:" $filename]
      set build [string trim [regsub "^build:" $results {}] ":"]
      return [string trim $build]
    }
    proc get_fw_target {filename} {
      set results [grep "^target:" $filename]
      set target [regsub "^target:" $results {}]
      return [string trim $target]
    }
    proc get_fw_security {filename} {
      set results [grep "^security:" $filename]
      set security [string trim [regsub "^security:" $results {}] ":"]
      return [string trim $security]
    }
    proc get_fw_system {filename} {
      set results [grep "^system:" $filename]
      set system [string trim [regsub "^system:" $results {}] ":"]
      return [string trim $system]
    }
    proc get_fw_x3 {filename} {
      set results [grep "^x3:" $filename]
      set x3 [string trim [regsub "^x3:" $results {}] ":"]
      return [string trim $x3]
    }
    proc get_fw_paf {filename} {
      set results [grep "^paf:" $filename]
      set paf [string trim [regsub "^paf:" $results {}] ":"]
      return [string trim $paf]
    }
    proc get_fw_vsh {filename} {
      set results [grep "^vsh:" $filename]
      set vsh [string trim [regsub "^vsh:" $results {}] ":"]
      return [string trim $vsh]
    }
    proc get_fw_sys_jp {filename} {
      set results [grep "^sys_jp:" $filename]
      set sys_jp [string trim [regsub "^sys_jp:" $results {}] ":"]
      return [string trim $sys_jp]
    }
    proc get_fw_ps1emu {filename} {
      set results [grep "^ps1emu:" $filename]
      set ps1emu [string trim [regsub "^ps1emu:" $results {}] ":"]
      return [string trim $ps1emu]
    }
    proc get_fw_ps1netemu {filename} {
      set results [grep "^ps1netemu:" $filename]
      set ps1netemu [string trim [regsub "^ps1netemu:" $results {}] ":"]
      return [string trim $ps1netemu]
    }
    proc get_fw_ps1newemu {filename} {
      set results [grep "^ps1newemu:" $filename]
      set ps1newemu [string trim [regsub "^ps1newemu:" $results {}] ":"]
      return [string trim $ps1newemu]
    }
    proc get_fw_ps2emu {filename} {
      set results [grep "^ps2emu:" $filename]
      set ps2emu [string trim [regsub "^ps2emu:" $results {}] ":"]
      return [string trim $ps2emu]
    }
    proc get_fw_ps2gxemu {filename} {
      set results [grep "^ps2gxemu:" $filename]
      set ps2gxemu [string trim [regsub "^ps2gxemu:" $results {}] ":"]
      return [string trim $ps2gxemu]
    }
    proc get_fw_ps2softemu {filename} {
      set results [grep "^ps2softemu:" $filename]
      set ps2softemu [string trim [regsub "^ps2softemu:" $results {}] ":"]
      return [string trim $ps2softemu]
    }
    proc get_fw_pspemu {filename} {
      set results [grep "^pspemu:" $filename]
      set pspemu [string trim [regsub "^pspemu:" $results {}] ":"]
      return [string trim $pspemu]
    }
    proc get_fw_emerald {filename} {
      set results [grep "^emerald:" $filename]
      set emerald [string trim [regsub "^emerald:" $results {}] ":"]
      return [string trim $emerald]
    }
    proc get_fw_bdp {filename} {
      set results [grep "^bdp:" $filename]
      set bdp [string trim [regsub "^bdp:" $results {}] ":"]
      return [string trim $bdp]
    }
    proc get_fw_auth {filename} {
      set results [grep "^auth:" $filename]
      set auth [string trim [regsub "^auth:" $results {}] ":"]
      return [string trim $auth]
    }
    # proc get_fw_patch {filename} {
      # set results [grep "^patch:" $filename]
      # set patch [string trim [regsub "^patch:" $results {}] ":"]
      # return [string trim $patch]
    # }

	proc version_txt {filename} {
      variable options
      set release [lindex $options(--spoof) 0]
      set build [lindex $options(--spoof) 1]
      set bdate [lindex $options(--spoof) 2]
      set target [lindex $options(--spoof) 3]
      set security [lindex $options(--spoof) 4]
      set system [lindex $options(--spoof) 5]
      set x3 [lindex $options(--spoof) 6]
      set paf [lindex $options(--spoof) 7]
      set vsh [lindex $options(--spoof) 8]
      set sys_jp [lindex $options(--spoof) 9]
      set ps1emu [lindex $options(--spoof) 10]
      set ps1netemu [lindex $options(--spoof) 11]
      set ps1newemu [lindex $options(--spoof) 12]
      set ps2emu [lindex $options(--spoof) 13]
      set ps2gxemu [lindex $options(--spoof) 14]
      set ps2softemu [lindex $options(--spoof) 15]
      set pspemu [lindex $options(--spoof) 16]
      set emerald [lindex $options(--spoof) 17]
      set bdp [lindex $options(--spoof) 18]
      set auth [lindex $options(--spoof) 1]
      # set patch [lindex $options(--spoof) 19]
      set fd [open $filename r]
      set data [read $fd]
      close $fd
	  log "Patching version.txt file to spoof all new entries"
      if {$release != [get_fw_release $filename]} {
        set major [lindex [split $release "."] 0]
        set minor [lindex [split $release "."] 1]
        set nano "0"
        debug "Setting release to release:[format %0.2d ${major}].[format %0.2d ${minor}][format %0.2d ${nano}]:"
        set data [regsub {release:[0-9]+\.[0-9]+:} $data "release:[format %0.2d ${major}].[format %0.2d ${minor}][format %0.2d ${nano}]:"]
      }
      if {$build != [get_fw_build $filename]} {
        set build_num $build
        set build_date $bdate
        debug "Setting build to build:${build_num},${build_date}:"
        set data [regsub {build:[0-9]+,[0-9]+:} $data "build:${build_num},${build_date}:"]
      }
      if {$target != [get_fw_target $filename]} {
        set target_num [lindex [split $target ":"] 0]
        set target_string [lindex [split $target ":"] 1]
        debug "Setting target to target:${target_num}:${target_string}"
        set data [regsub {target:[0-9]+:[A-Z]+-ww} $data "target:${target_num}:${target_string}"]
      }
      if {$security != [get_fw_security $filename]} {
        set security_string [lindex [split $security ":"] 0]
        debug "Setting security to security:${security_string}:"
        set data [regsub {security:(.*?):} $data "security:${security_string}:"]
      }
      if {$system != [get_fw_system $filename]} {
        set system_string [lindex [split $system ":"] 0]
        debug "Setting system to system:${system_string}:"
        set data [regsub {system:(.*?):} $data "system:${system_string}:"]
      }
      if {$x3 != [get_fw_x3 $filename]} {
        set x3_string [lindex [split $x3 ":"] 0]
        debug "Setting x3 to x3:${x3_string}:"
        set data [regsub {x3:(.*?):} $data "x3:${x3_string}:"]
      }
      if {$paf != [get_fw_paf $filename]} {
        set paf_string [lindex [split $paf ":"] 0]
        debug "Setting paf to paf:${paf_string}:"
        set data [regsub {paf:(.*?):} $data "paf:${paf_string}:"]
      }
      if {$vsh != [get_fw_vsh $filename]} {
        set vsh_string [lindex [split $vsh ":"] 0]
        debug "Setting vsh to vsh:${vsh_string}:"
        set data [regsub {vsh:(.*?):} $data "vsh:${vsh_string}:"]
      }
      if {$sys_jp != [get_fw_sys_jp $filename]} {
        set sys_jp_string [lindex [split $sys_jp ":"] 0]
        debug "Setting sys_jp to sys_jp:${sys_jp_string}:"
        set data [regsub {sys_jp:(.*?):} $data "sys_jp:${sys_jp_string}:"]
      }
      if {$ps1emu != [get_fw_ps1emu $filename]} {
        set ps1emu_string [lindex [split $ps1emu ":"] 0]
        debug "Setting ps1emu to ps1emu:${ps1emu_string}:"
        set data [regsub {ps1emu:(.*?):} $data "ps1emu:${ps1emu_string}:"]
      }
      if {$ps1netemu != [get_fw_ps1netemu $filename]} {
        set ps1netemu_string [lindex [split $ps1netemu ":"] 0]
        debug "Setting ps1netemu to ps1netemu:${ps1netemu_string}:"
        set data [regsub {ps1netemu:(.*?):} $data "ps1netemu:${ps1netemu_string}:"]
      }
      if {$ps1newemu != [get_fw_ps1newemu $filename]} {
        set ps1newemu_string [lindex [split $ps1newemu ":"] 0]
        debug "Setting ps1newemu to ps1newemu:${ps1newemu_string}:"
        set data [regsub {ps1newemu:(.*?):} $data "ps1newemu:${ps1newemu_string}:"]
      }
      if {$ps2emu != [get_fw_ps2emu $filename]} {
        set ps2emu_string [lindex [split $ps2emu ":"] 0]
        debug "Setting ps2emu to ps2emu:${ps2emu_string}:"
        set data [regsub {ps2emu:(.*?):} $data "ps2emu:${ps2emu_string}:"]
      }
      if {$ps2gxemu != [get_fw_ps2gxemu $filename]} {
        set ps2gxemu_string [lindex [split $ps2gxemu ":"] 0]
        debug "Setting ps2gxemu to ps2gxemu:${ps2gxemu_string}:"
        set data [regsub {ps2gxemu:(.*?):} $data "ps2gxemu:${ps2gxemu_string}:"]
      }
      if {$ps2softemu != [get_fw_ps2softemu $filename]} {
        set ps2softemu_string [lindex [split $ps2softemu ":"] 0]
        debug "Setting ps2softemu to ps2softemu:${ps2softemu_string}:"
        set data [regsub {ps2softemu:(.*?):} $data "ps2softemu:${ps2softemu_string}:"]
      }
      if {$pspemu != [get_fw_pspemu $filename]} {
        set pspemu_string [lindex [split $pspemu ":"] 0]
        debug "Setting pspemu to pspemu:${pspemu_string}:"
        set data [regsub {pspemu:(.*?):} $data "pspemu:${pspemu_string}:"]
      }
      if {$emerald != [get_fw_emerald $filename]} {
        set emerald_string [lindex [split $emerald ":"] 0]
        debug "Setting emeral to emerald:${emerald_string}:"
        set data [regsub {emerald:(.*?):} $data "emerald:${emerald_string}:"]
      }
      if {$bdp != [get_fw_bdp $filename]} {
        set bdp_string [lindex [split $bdp ":"] 0]
        debug "Setting bdp to bdp:${bdp_string}:"
        set data [regsub {bdp:(.*?):} $data "bdp:${bdp_string}:"]
      }
      if {$auth != [get_fw_auth $filename]} {
        debug "Setting auth to auth:$auth:"
        set data [regsub {auth:[0-9]+:} $data "auth:$auth:"]
      }
      # if {$patch != [get_fw_patch $filename]} {
        # debug "Setting patch to patch:$patch:"
        # set data [regsub {patch:[0-9]+:} $data "patch:$patch:"]
      # }
      set fd [open $filename w]
      puts -nonewline $fd $data
      close $fd
	  if {$::13_spoofer_update::options(--version) == "REBUG"} {
		  set index_dat_swp [file join [file dirname $filename] index.dat.swp]
		  shell "dat" [file nativename $filename] [file nativename $index_dat_swp]
	  } else {
		  set index_dat [file join [file dirname $filename] index.dat]
		  shell "dat" [file nativename $filename] [file nativename $index_dat]
	  }
    }

	proc callback_patch {path args} {		
        log "Patching Photo Category"
		if {$::13_spoofer_update::options(--patch-screen)} {
			sed_in_place [file join $path] "sel://localhost/screenshot?category_photo.xml#seg_screenshot" "#seg_screenshot"
		}
	}

    proc patch_screen {self} {
		::modify_self_file $self ::13_spoofer_update::screen_elf
	}
    proc screen_elf {elf} {
		log "Patch 1" 1
            set search "\x39\x29\x00\x04\x7C\x00\x48\x28\x7C\x09\xFE\x70"
            set replace "\x39\x29\x00\x04\x38\x00\x00\x01\x7C\x09\xFE\x70"
			set offset 0
			set mask 0			
			# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

		log "Patch 2" 1
            set search "\x39\x29\x00\x04\x7C\x00\x48\x28\x2F\x80\x00\x00"
            set replace "\x39\x29\x00\x04\x38\x00\x00\x01\x2F\x80\x00\x00"
			set offset 0
			set mask 0			
			# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
    }
}

