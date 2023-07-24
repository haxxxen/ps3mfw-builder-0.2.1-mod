#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 220
# Description: Patch to enable 3rd party Controller in RECOVERY

# Option --patch-pad: [3.xx/4.xx]  EMER_INIT: --> Patch emer_init.self to enable 3rd-Party Controller in RECOVERY Menu

# Type --patch: boolean

namespace eval ::24_patch_pad {

    array set ::24_patch_pad::options {
		--patch-pad false
    }

    proc main {} {
		variable options
		if {$::24_patch_pad::options(--patch-pad)} {
			set self "emer_init.self"
			::modify_coreos_file $self ::24_patch_pad::Do_EMER_Patch
		}
    }

	proc Do_EMER_Patch {self} {		
        ::modify_self_file $self ::24_patch_pad::EMER_elf_Patch
	}

	proc EMER_elf_Patch {elf} {
		log "Applying EMER_INIT patch...."		
		if {$::24_patch_pad::options(--patch-pad)} {
            log "Patching EMER_INIT to enable (wired only?) 3rd-Party Controller"
			00
			set search  "\x41\x9E\x00\x40\x2B\xBC\x00\x7E"
			set replace "\x38\x00\x00\x01\x2B\xBC\x00\x7E"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
	}
}

