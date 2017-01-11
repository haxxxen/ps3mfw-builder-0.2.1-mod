#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 90
# Description: Bypass RSOD screen


# Option --patch-rsod-version: [3.xx/4.xx] Select Firmware you want to bypass RSOD

# Type --patch-rsod-version: combobox { {3.15} {3.15 DEX} {3.40-3.55} {4.xx} }

namespace eval ::10_patch_rsod {

    array set ::10_patch_rsod::options {
        --patch-rsod-version ""
    }
    proc main {} {
		if {$::10_patch_rsod::options(--patch-rsod-version) != ""} {
			set self [file join dev_flash vsh module basic_plugins.sprx]
			::modify_devflash_file $self ::10_patch_rsod::patch_self
		}
    }

    proc patch_self {self} {
        log "Patching [file tail $self]"
		::modify_self_file $self ::10_patch_rsod::patch_elf
    }
	
    proc patch_elf {elf} {
        if {$::10_patch_rsod::options(--patch-rsod-version) == "3.15"} {
			debug "Patching [file tail $elf] to disable RSOD Screen on ${::10_patch_rsod::options(--patch-rsod-version)}"
				set search  "\x41\x9E\x00\xDC\x4B\xFF\xED\x69\x60\x00\x00\x00\x81\x22\x86\x60"
				set replace "\x60\x00\x00\x00\x4B\xFF\xED\x69\x60\x00\x00\x00\x81\x22\x86\x60"
				set offset 0
				set mask 0				
				catch_die {::patch_elf $elf $search $offset $replace $mask} \
					"Unable to patch self [file tail $elf]"
        }
        if {$::10_patch_rsod::options(--patch-rsod-version) == "3.15 DEX"} {
			debug "Patching [file tail $elf] to disable RSOD Screen on ${::10_patch_rsod::options(--patch-rsod-version)}"
				set search  "\x41\x9E\x00\xDC\x4B\xFF\xED\x69\x60\x00\x00\x00\x81\x22\x86\xA8"
				set replace "\x60\x00\x00\x00\x4B\xFF\xED\x69\x60\x00\x00\x00\x81\x22\x86\xA8"
				set offset 0
				set mask 0				
				catch_die {::patch_elf $elf $search $offset $replace $mask} \
					"Unable to patch self [file tail $elf]"
        }
        if {$::10_patch_rsod::options(--patch-rsod-version) == "3.40-3.55"} {
			debug "Patching [file tail $elf] to disable RSOD Screen on ${::10_patch_rsod::options(--patch-rsod-version)}"
				set search  "\x41\x9E\x00\xDC\x48\x00\x12\x8D\x60\x00\x00\x00\x81\x22"
				set replace "\x60\x00\x00\x00\x48\x00\x12\x8D\x60\x00\x00\x00\x81\x22"
				set offset 0
				set mask 0				
				catch_die {::patch_elf $elf $search $offset $replace $mask} \
					"Unable to patch self [file tail $elf]"
        }
        if {$::10_patch_rsod::options(--patch-rsod-version) == "4.xx"} {
			debug "Patching [file tail $elf] to disable RSOD Screen on ${::10_patch_rsod::options(--patch-rsod-version)}"
				set search  "\x40\x9E\x00\x20\x48\x00\x00\x10"
				set replace "\x48\x00\x00\x20\x48\x00\x00\x10"
				set offset 0
				set mask 0				
				catch_die {::patch_elf $elf $search $offset $replace $mask} \
					"Unable to patch self [file tail $elf]"
        }
    }
}