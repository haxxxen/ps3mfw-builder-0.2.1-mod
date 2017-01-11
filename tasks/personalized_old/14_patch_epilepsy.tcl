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
# Description: [4.xx] Patch vsh.self to disable or enable epilepsy message screen
 
# Option --patch-epilepsy-message: [4.xx] Select Base Firmware
# Option --patch-select: Select to disable or enable epilepsy message screen


# Type --patch-epilepsy-message: combobox { {CEX} {DEX} {REBUG} }
# Type --patch-select: combobox { {disable} {enable} }

namespace eval ::14_patch_epilepsy {
 
    array set ::14_patch_epilepsy::options {
        --patch-epilepsy-message ""
        --patch-select ""
    }
 
    proc main {} {
		if {$::14_patch_epilepsy::options(--patch-epilepsy-message) != ""} {
			if {$::14_patch_epilepsy::options(--patch-epilepsy-message) == "CEX"} {
				::modify_devflash_file [file join dev_flash vsh module vsh.self] ::14_patch_epilepsy::patch_cex_self
			} elseif {$::14_patch_epilepsy::options(--patch-epilepsy-message) == "DEX"} {
				::modify_devflash_file [file join dev_flash vsh module vsh.self] ::14_patch_epilepsy::patch_self
			} elseif {$::14_patch_epilepsy::options(--patch-epilepsy-message) == "REBUG"} {
				set selfs {vsh.self vsh.self.swp}
				::modify_devflash_files [file join dev_flash vsh module] $selfs ::14_patch_epilepsy::patch_self
				::modify_devflash_file [file join dev_flash vsh module vsh.self.cexsp] ::14_patch_epilepsy::patch_cex_self
			}
		}
	}
 
    proc patch_cex_self { self } {
			::modify_self_file $self ::14_patch_epilepsy::patch_cex_elf
    }
    proc patch_self { self } {
			::modify_self_file $self ::14_patch_epilepsy::patch_elf
    }
 
    proc patch_cex_elf { elf } {
		if {${::NEWMFW_VER} >= "4.21"} {
			if {$::14_patch_epilepsy::options(--patch-select) == "disable"} {
				log "Patching [file tail $elf] to disable epilepsy message on CEX CFW (credits to mysis and Ezio)"

				set search  "\x00\x00\x00\x02\x00\x00\x00\x01\x02\x01\x01\x01\xff\xff\xff\xff"
				set replace "\x00\x00\x00\x02\x00\x00\x00\x01\x02\x00\x01\x01\xff\xff\xff\xff"
				set offset 0
				set mask 0			
					# PATCH THE ELF BINARY
						catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
			}

			if {$::14_patch_epilepsy::options(--patch-select) == "enable"} {
				log "Patching [file tail $elf] to enable epilepsy message on CEX CFW (credits to mysis and Ezio)"

				set search	"\x00\x00\x00\x02\x00\x00\x00\x01\x02\x00\x01\x01\xff\xff\xff\xff"
				set replace	"\x00\x00\x00\x02\x00\x00\x00\x01\x02\x01\x01\x01\xff\xff\xff\xff"
				set offset 0
				set mask 0			
					# PATCH THE ELF BINARY
						catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
			}
		}
    }
    proc patch_elf { elf } {
		if {${::NEWMFW_VER} >= "4.21"} {
			if {$::14_patch_epilepsy::options(--patch-select) == "disable"} {
				log "Patching [file tail $elf] to disable epilepsy message on REBUG/DEX CFW (credits to mysis and Ezio)"

				set search  "\x00\x00\x00\x00\x00\x00\x00\x00\x01\x01\x01\x00\xff\xff\xff\xff"
				set replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x01\x00\xff\xff\xff\xff"
				set offset 0
				set mask 0			
					# PATCH THE ELF BINARY
						catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
			}

			if {$::14_patch_epilepsy::options(--patch-select) == "enable"} {
				log "Patching [file tail $elf] to enable epilepsy message on REBUG/DEX CFW (credits to mysis and Ezio)"

				set search	"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x01\x00\xff\xff\xff\xff"
				set replace	"\x00\x00\x00\x00\x00\x00\x00\x00\x01\x01\x01\x00\xff\xff\xff\xff"
				set offset 0
				set mask 0			
					# PATCH THE ELF BINARY
						catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
			}
		}
    }
}