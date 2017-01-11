#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
 
# Priority: 160
# Description: [4.xx] Patch vsh.self to disable epilepsy message screen
 
# Option --patch-disable-epilepsy-message: [4.xx] Select Base Firmware

# Type --patch-disable-epilepsy-message: combobox { {CEX} {DEX} {REBUG} }

namespace eval ::18_patch_epilepsy {
 
    array set ::18_patch_epilepsy::options {
        --patch-disable-epilepsy-message "REBUG"
    }
 
    proc main {} {
		if {$::18_patch_epilepsy::options(--patch-disable-epilepsy-message) != ""} {
			if {$::18_patch_epilepsy::options(--patch-disable-epilepsy-message) == "CEX"} {
				::modify_devflash_file [file join dev_flash vsh module vsh.self] ::18_patch_epilepsy::patch_cex_self
			} elseif {$::18_patch_epilepsy::options(--patch-disable-epilepsy-message) == "DEX"} {
				::modify_devflash_file [file join dev_flash vsh module vsh.self] ::18_patch_epilepsy::patch_self
			} elseif {$::18_patch_epilepsy::options(--patch-disable-epilepsy-message) == "REBUG"} {
				set selfs {vsh.self vsh.self.swp}
				::modify_devflash_files [file join dev_flash vsh module] $selfs ::18_patch_epilepsy::patch_self
				::modify_devflash_file [file join dev_flash vsh module vsh.self.cexsp] ::18_patch_epilepsy::patch_cex_self
			} elseif {$::18_patch_epilepsy::options(--patch-disable-epilepsy-message) == "mine"} {
				set selfs {vsh.self vsh.self.nrm}
				::modify_devflash_files [file join dev_flash vsh module] $selfs ::18_patch_epilepsy::patch_self
				::modify_devflash_file [file join dev_flash vsh module vsh.self.cexsp] ::18_patch_epilepsy::patch_cex_self
			}
		}
	}
 
    proc patch_cex_self { self } {
			::modify_self_file $self ::18_patch_epilepsy::patch_cex_elf
    }
    proc patch_cex_elf { elf } {
		if {${::NEWMFW_VER} >= "4.21"} {
            log "Patching [file tail $elf] to disable epilepsy message on CEX CFW (credits to mysis and Ezio)"

			set search  "\x00\x00\x00\x02\x00\x00\x00\x01\x02\x01\x01\x01\xff\xff\xff\xff"
			set replace "\x00\x00\x00\x02\x00\x00\x00\x01\x02\x00\x01\x01\xff\xff\xff\xff"
			set offset 0
			set mask 0			
				# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
		}
    }
    proc patch_self { self } {
			::modify_self_file $self ::18_patch_epilepsy::patch_elf
    }
 
    proc patch_elf { elf } {
		if {${::NEWMFW_VER} >= "4.21"} {
		    log "Patching [file tail $elf] to disable epilepsy message on REBUG/DEX CFW (credits to mysis and Ezio)"

			set search  "\x00\x00\x00\x00\x00\x00\x00\x00\x01\x01\x01\x00\xff\xff\xff\xff"
			set replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x01\x00\xff\xff\xff\xff"
			set offset 0
			set mask 0			
				# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
		}
    }
}