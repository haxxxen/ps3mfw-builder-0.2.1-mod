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

# Type --patch-lv1-rsx-oc: combobox { {400MHz / 550MHz} {450MHz / 550MHz} {500MHz / 550MHz} {550MHz / 550MHz} {600MHz / 550MHz} {} {400MHz / 575MHz} {450MHz / 575MHz} {500MHz / 575MHz} {550MHz / 575MHz} {600MHz / 575MHz} {} {400MHz / 600MHz} {450MHz / 600MHz} {500MHz / 600MHz} {550MHz / 600MHz} {600MHz / 600MHz} {} {400MHz / 625MHz} {450MHz / 625MHz} {500MHz / 625MHz} {550MHz / 625MHz} {600MHz / 625MHz} {} {400MHz / 650MHz} {450MHz / 650MHz} {Default - 500MHz / 650MHz} {550MHz / 650MHz} {600MHz / 650MHz} {650MHz / 650MHz} {700MHz / 650MHz} {750MHz / 650MHz} {800MHz / 650MHz} {850MHz / 650MHz} {900MHz / 650MHz} {950MHz / 650MHz} {1000MHz / 650MHz} {} {400MHz / 675MHz} {450MHz / 675MHz} {500MHz / 675MHz} {550MHz / 675MHz} {600MHz / 675MHz} {} {400MHz / 700MHz} {450MHz / 700MHz} {500MHz / 700MHz} {550MHz / 700MHz} {600MHz / 700MHz} {650MHz / 700MHz} {700MHz / 700MHz} {750MHz / 700MHz} {800MHz / 700MHz} {850MHz / 700MHz} {900MHz / 700MHz} {950MHz / 700MHz} {1000MHz / 700MHz} {} {400MHz / 725MHz} {450MHz / 725MHz} {500MHz / 725MHz} {550MHz / 725MHz} {600MHz / 725MHz} {} {400MHz / 750MHz} {450MHz / 750MHz} {500MHz / 750MHz} {550MHz / 750MHz} {600MHz / 750MHz} {650MHz / 750MHz} {700MHz / 750MHz} {750MHz / 750MHz} {800MHz / 750MHz} {850MHz / 750MHz} {900MHz / 750MHz} {950MHz / 750MHz} {1000MHz / 750MHz} {} {550MHz / 800MHz} {600MHz / 800MHz} {650MHz / 800MHz} {700MHz / 800MHz} {750MHz / 800MHz} {800MHz / 800MHz} {850MHz / 800MHz} {900MHz / 800MHz} {950MHz / 800MHz} {1000MHz / 800MHz} {} {550MHz / 850MHz} {600MHz / 850MHz} {650MHz / 850MHz} {700MHz / 850MHz} {750MHz / 850MHz} {800MHz / 850MHz} {850MHz / 850MHz} {900MHz / 850MHz} {950MHz / 850MHz} {1000MHz / 850MHz} {} {550MHz / 900MHz} {600MHz / 900MHz} {650MHz / 900MHz} {700MHz / 900MHz} {750MHz / 900MHz} {800MHz / 900MHz} {850MHz / 900MHz} {900MHz / 900MHz} {950MHz / 900MHz} {1000MHz / 900MHz} {} {550MHz / 950MHz} {600MHz / 950MHz} {650MHz / 950MHz} {700MHz / 950MHz} {750MHz / 950MHz} {800MHz / 950MHz} {850MHz / 950MHz} {900MHz / 950MHz} {950MHz / 950MHz} {1000MHz / 950MHz} {} {550MHz / 1000MHz} {600MHz / 1000MHz} {650MHz / 1000MHz} {700MHz / 1000MHz} {750MHz / 1000MHz} {800MHz / 1000MHz} {850MHz / 1000MHz} {900MHz / 1000MHz} {950MHz / 1000MHz} {1000MHz / 1000MHz} }

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
		# RSX OC 400/550
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "400MHz / 550MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 400MHz / 550MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x08\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x16\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 450/550
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "450MHz / 550MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 450MHz / 550MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x09\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x16\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 500/550
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "500MHz / 550MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 500MHz / 550MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x16\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 550/550
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 550MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 550MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x16\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/550
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 550MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 550MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x16\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
		}

		# RSX OC 400/575
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "400MHz / 575MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 400MHz / 575MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x08\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x17\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 450/575
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "450MHz / 575MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 450MHz / 575MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x09\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x17\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 500/575
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "500MHz / 575MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 500MHz / 575MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x17\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 550/575
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 575MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 575MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x17\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/575
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 575MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 575MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x17\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

		# RSX OC 400/600
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "400MHz / 600MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 400MHz / 600MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x08\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x18\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 450/600
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "450MHz / 600MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 450MHz / 600MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x09\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x18\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 500/600
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "500MHz / 600MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 500MHz / 600MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x18\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 550/600
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 600MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 600MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x18\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/600
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 600MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 600MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x18\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

		# RSX OC 400/625
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "400MHz / 625MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 400MHz / 625MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x08\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x19\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 450/625
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "450MHz / 625MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 450MHz / 625MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x09\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x19\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 500/625
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "500MHz / 625MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 500MHz / 625MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x19\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 550/625
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 625MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 625MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x19\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/625
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 625MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 625MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x19\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		
		# RSX OC 400/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "400MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 400MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x08\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 450/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "450MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 450MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x09\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 500/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "Default - 500MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to Default 500MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 550/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 650/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 700/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "700MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 700MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0e\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 750/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "750MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 750MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0f\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 800/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "800MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 800MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x10\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 850/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "850MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 850MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x11\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 900/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "900MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 900MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x12\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 950/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "950MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 950MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x13\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 1000/650
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "1000MHz / 650MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 1000MHz / 650MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x14\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

		# RSX OC 400/675
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "400MHz / 675MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 400MHz / 675MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x08\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1b\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 450/675
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "450MHz / 675MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 450MHz / 675MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x09\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1b\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 500/675
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "500MHz / 675MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 500MHz / 675MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1b\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
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
		
		# RSX OC 400/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "400MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 400MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x08\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 450/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "450MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 450MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x09\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 500/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "500MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 500MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
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
		# RSX OC 650/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 700/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "700MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 700MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0e\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 750/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "750MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 750MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0f\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 800/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "800MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 800MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x10\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 850/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "850MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 850MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x11\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 900/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "900MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 900MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x12\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 950/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "950MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 950MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x13\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 1000/700
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "1000MHz / 700MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 1000MHz / 700MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x14\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1c\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

		# RSX OC 400/725
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "400MHz / 725MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 400MHz / 725MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x08\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1d\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 450/725
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "450MHz / 725MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 450MHz / 725MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x09\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1d\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 500/725
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "500MHz / 725MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 500MHz / 725MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1d\x04"
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
		
		# RSX OC 400/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "400MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 400MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x08\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 450/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "450MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 450MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x09\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 500/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "500MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 500MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
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
		# RSX OC 650/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 700/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "700MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 700MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0e\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 750/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "750MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 750MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0f\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 800/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "800MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 800MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x10\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 850/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "850MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 850MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x11\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 900/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "900MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 900MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x12\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 950/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "950MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 950MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x13\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 1000/750
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "1000MHz / 750MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 1000MHz / 750MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x14\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1e\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

		# RSX OC 550/800
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 800MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 800MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x20\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/800
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 800MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 800MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x20\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 650/800
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 800MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 800MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x20\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 700/800
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "700MHz / 800MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 700MHz / 800MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0e\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x20\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 750/800
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "750MHz / 800MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 750MHz / 800MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0f\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x20\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 800/800
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "800MHz / 800MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 800MHz / 800MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x10\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x20\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 850/800
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "850MHz / 800MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 850MHz / 800MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x11\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x20\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 900/800
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "900MHz / 800MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 900MHz / 800MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x12\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x20\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 950/800
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "950MHz / 800MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 950MHz / 800MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x13\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x20\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 1000/800
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "1000MHz / 800MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 1000MHz / 800MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x14\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x20\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

		# RSX OC 550/850
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 850MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 850MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x22\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/850
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 850MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 850MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x22\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 650/850
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 850MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 850MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x22\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 700/850
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "700MHz / 850MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 700MHz / 850MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0e\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x22\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 750/850
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "750MHz / 850MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 750MHz / 850MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0f\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x22\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 800/850
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "800MHz / 850MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 800MHz / 850MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x10\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x22\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 850/850
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "850MHz / 850MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 850MHz / 850MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x11\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x22\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 900/850
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "900MHz / 850MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 900MHz / 850MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x12\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x22\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 950/850
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "950MHz / 850MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 950MHz / 850MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x13\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x22\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 1000/850
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "1000MHz / 850MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 1000MHz / 850MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x14\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x22\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

		# RSX OC 550/900
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 900MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 900MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x24\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/900
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 900MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 900MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x24\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 650/900
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 900MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 900MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x24\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 700/900
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "700MHz / 900MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 700MHz / 900MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0e\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x24\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 750/900
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "750MHz / 900MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 750MHz / 900MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0f\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x24\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 800/900
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "800MHz / 900MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 800MHz / 900MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x10\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x24\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 850/900
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "850MHz / 900MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 850MHz / 900MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x11\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x24\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 900/900
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "900MHz / 900MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 900MHz / 900MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x12\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x24\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 950/900
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "950MHz / 900MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 950MHz / 900MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x13\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x24\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 1000/900
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "1000MHz / 900MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 1000MHz / 900MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x14\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x24\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

		# RSX OC 550/950
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 950MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 950MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x26\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/950
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 950MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 950MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x26\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 650/950
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 950MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 950MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x26\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 700/950
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "700MHz / 950MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 700MHz / 950MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0e\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x26\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 750/950
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "750MHz / 950MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 750MHz / 950MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0f\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x26\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 800/950
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "800MHz / 950MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 800MHz / 950MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x10\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x26\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 850/950
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "850MHz / 950MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 850MHz / 950MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x11\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x26\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 900/950
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "900MHz / 950MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 900MHz / 950MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x12\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x26\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 950/950
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "950MHz / 950MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 950MHz / 950MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x13\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x26\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 1000/950
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "1000MHz / 950MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 1000MHz / 950MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x14\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x26\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

		# RSX OC 550/1000
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "550MHz / 1000MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 550MHz / 1000MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0b\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x28\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 600/1000
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "600MHz / 1000MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 600MHz / 1000MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0c\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x28\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 650/1000
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 1000MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 1000MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x28\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 700/1000
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "700MHz / 1000MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 700MHz / 1000MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0e\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x28\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 750/1000
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "750MHz / 1000MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 750MHz / 1000MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0f\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x28\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 800/1000
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "800MHz / 1000MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 800MHz / 1000MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x10\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x28\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 850/1000
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "850MHz / 1000MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 850MHz / 1000MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x11\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x28\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 900/1000
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "900MHz / 1000MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 900MHz / 1000MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x12\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x28\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 950/1000
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "950MHz / 1000MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 950MHz / 1000MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x13\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x28\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
		# RSX OC 1000/1000
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "1000MHz / 1000MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 1000MHz / 1000MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x14\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x28\x04"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }
	}
}

