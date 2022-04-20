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

# Option --patch-lv1-rsx-oc: [3.xx/4.xx]  LV1: --> Patch LV1 to overclock RSX Core / Memory

# Type --patch-lv1-rsx-oc: combobox { {550MHz / 675MHz} {550MHz / 700MHz} {550MHz / 725MHz} {550MHz / 750MHz} {} {600MHz / 675MHz} {600MHz / 700MHz} {600MHz / 725MHz} {600MHz / 750MHz} }

namespace eval ::01_patch_rsx_oc {

    array set ::01_patch_rsx_oc::options {
		--patch-lv1-rsx-oc "Select Speed"
    }

    proc main {} {
		variable options
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) != "Select Speed" || $::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) != ""} {
			set self "lv1.self"
			::modify_coreos_file $self ::01_patch_rsx_oc::Do_LV1_Patch
		}
    }

	proc Do_LV1_Patch {self} {		
        ::modify_self_file $self ::01_patch_rsx_oc::LV1_elf_Patch
	}

	proc LV1_elf_Patch {elf} {
		log "Applying LV1 patch...."		
		# RSX OC 550/675
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 675MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 675MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1b\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 550/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 550/725
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 725MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 725MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1d\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 550/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/675
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 675MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 675MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1b\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/725
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 725MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 725MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1d\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
	}
}

