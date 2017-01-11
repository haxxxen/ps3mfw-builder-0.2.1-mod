#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.


# Priority: 150
# Description: REBUG COBRA update task

# Option --netemu: ps2_netemu.self file
# Option --vsh-self: vsh.self file
# Option --replace-stage1: stage2.cex.bak file
# Option --replace-stage2: stage2.dex.bak file
# Option --replace-stage3: stage2.cexr file
# Option --replace-stage4: stage2.dexr file
# Option --index-dat: index.dat.swp file
# Option --version-txt: version.txt.swp file
# Option --vsh-swp: vsh.self.swp file
# Option --vsh-cexsp: vsh.self.cexsp file

# Type --netemu: file open {"Self File" {.self}}
# Type --vsh-self: file open {"Self File" {.self}}
# Type --replace-stage1: file open {"Self File" {*.*}}
# Type --replace-stage2: file open {"Self File" {*.*}}
# Type --replace-stage3: file open {"Self File" {*.*}}
# Type --replace-stage4: file open {"Self File" {*.*}}
# Type --index-dat: file open {"dat File" {.dat.swp}}
# Type --version-txt: file open {"txt File" {.txt.swp}}
# Type --vsh-swp: file open {"Self File" {.self.swp}}
# Type --vsh-cexsp: file open {"Self File" {*.self.cexsp}}

namespace eval ::16_cobra_selfs {

    array set ::16_cobra_selfs::options {
        --netemu ""
        --vsh-self ""
        --replace-stage1 "D:/_Files/PSSaves/PS3/Toolz/CFW/fw/cobra/kernels/debug/stage2.cex.bak"
        --replace-stage2 "D:/_Files/PSSaves/PS3/Toolz/CFW/fw/cobra/kernels/debug/stage2.dex.bak"
        --replace-stage3 "D:/_Files/PSSaves/PS3/Toolz/CFW/fw/cobra/kernels/debug/stage2.cexr"
        --replace-stage4 "D:/_Files/PSSaves/PS3/Toolz/CFW/fw/cobra/kernels/debug/stage2.dexr"
        --index-dat ""
        --version-txt ""
        --vsh-swp ""
        --vsh-cexsp ""
    }
    proc main {} {
        variable options
        set net [file join dev_flash ps2emu ps2_netemu.self]
        # set self [file join dev_flash vsh module vsh.self]
        set self [file join dev_flash vsh module vsh.self.nrm]
		set st1 [file join dev_flash rebug cobra stage2.cex.bak]
        set st2 [file join dev_flash rebug cobra stage2.dex.bak]
		set st3 [file join dev_flash rebug cobra stage2.cexr]
        set st4 [file join dev_flash rebug cobra stage2.dexr]
        # set dat [file join dev_flash vsh etc index.dat.swp]
        # set txt [file join dev_flash vsh etc version.txt.swp]
        set dat [file join dev_flash vsh etc index.dat]
        set txt [file join dev_flash vsh etc version.txt]
        set cexsp [file join dev_flash vsh module vsh.self.cexsp]
        # set swp [file join dev_flash vsh module vsh.self.swp]
        set swp [file join dev_flash vsh module vsh.self]
        if {[file exists $options(--netemu)] == 0 } {
            log "Skipping file, $options(--netemu) does not exist"
        } else {
            ::modify_devflash_file ${net} ::16_cobra_selfs::copy_devflash_file $::16_cobra_selfs::options(--netemu)
        }
        if {[file exists $options(--vsh-self)] == 0 } {
            log "Skipping file, $options(--vsh-self) does not exist"
        } else {
            ::modify_devflash_file ${self} ::16_cobra_selfs::copy_devflash_file $::16_cobra_selfs::options(--vsh-self)
        }
        if {[file exists $options(--replace-stage1)] == 0 } {
            log "Skipping file, $options(--replace-stage1) does not exist"
        } else {
            ::modify_devflash_file ${st1} ::16_cobra_selfs::copy_devflash_file $::16_cobra_selfs::options(--replace-stage1)
        }
        if {[file exists $options(--replace-stage2)] == 0 } {
            log "Skipping file, $options(--replace-stage2) does not exist"
        } else {
            ::modify_devflash_file ${st2} ::16_cobra_selfs::copy_devflash_file $::16_cobra_selfs::options(--replace-stage2)
        }
        if {[file exists $options(--replace-stage3)] == 0 } {
            log "Skipping file, $options(--replace-stage3) does not exist"
        } else {
            ::modify_devflash_file ${st3} ::16_cobra_selfs::copy_devflash_file $::16_cobra_selfs::options(--replace-stage3)
        }
        if {[file exists $options(--replace-stage4)] == 0 } {
            log "Skipping file, $options(--replace-stage4) does not exist"
        } else {
            ::modify_devflash_file ${st4} ::16_cobra_selfs::copy_devflash_file $::16_cobra_selfs::options(--replace-stage4)
        }
        if {[file exists $options(--index-dat)] == 0 } {
            log "Skipping dat, $options(--index-dat) does not exist"
        } else {
            ::modify_devflash_file ${dat} ::16_cobra_selfs::copy_devflash_file $::16_cobra_selfs::options(--index-dat)
        }
        if {[file exists $options(--version-txt)] == 0 } {
            log "Skipping txt, $options(--version-txt) does not exist"
        } else {
            ::modify_devflash_file ${txt} ::16_cobra_selfs::copy_devflash_file $::16_cobra_selfs::options(--version-txt)
        }
        if {[file exists $options(--vsh-swp)] == 0 } {
            log "Skipping file, $options(--vsh-swp) does not exist"
        } else {
            ::modify_devflash_file ${swp} ::16_cobra_selfs::copy_devflash_file $::16_cobra_selfs::options(--vsh-swp)
        }
        if {[file exists $options(--vsh-cexsp)] == 0 } {
            log "Skipping file, $options(--vsh-cexsp) does not exist"
        } else {
            ::modify_devflash_file ${cexsp} ::16_cobra_selfs::copy_devflash_file $::16_cobra_selfs::options(--vsh-cexsp)
        }
    }
    
	proc copy_devflash_file { dst src } {
        if {[file exists $src] == 0} {
            die "$src does not exist"
        } else {
            if {[file exists $dst] == 0} {
                die "$dst does not exist"
            } else {
                log "Replacing default devflash file [file tail $dst] with [file tail $src]"
                copy_file -force $src $dst
            }
        }
    }
}

