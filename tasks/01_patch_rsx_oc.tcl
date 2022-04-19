#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 5
# Description: Patch LV1 for RSX Overclock

# Option --patch-lv1-rsx-oc: [3.xx/4.xx]  LV1: --> Patch LV1 to overclock RSX Core/Memory (600MHz / 750MHz)

# Type --patch: boolean

namespace eval ::01_patch_rsx_oc {

    array set ::01_patch_rsx_oc::options {
		--patch-lv1-rsx-oc false
    }

    proc main {} {
		variable options
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc)} {
			set self "lv1.self"
			::modify_coreos_file $self ::01_patch_rsx_oc::Do_LV1_Patch
		}
    }

	proc Do_LV1_Patch {self} {		
        ::modify_self_file $self ::01_patch_rsx_oc::LV1_elf_Patch
	}

	proc LV1_elf_Patch {elf} {
		log "Applying LV1 patch...."		
		# RSX OC 600/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc)} {
            log "Patching LV1 hypervisor to overclock RSX"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
	}
}

