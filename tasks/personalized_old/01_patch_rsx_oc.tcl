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

# Type --patch-lv1-rsx-oc: combobox { {400MHz / 550MHz} {450MHz / 550MHz} {500MHz / 550MHz} {550MHz / 550MHz} {600MHz / 550MHz} {650MHz / 550MHz} {} {400MHz / 575MHz} {450MHz / 575MHz} {500MHz / 575MHz} {550MHz / 575MHz} {600MHz / 575MHz} {650MHz / 575MHz} {} {400MHz / 600MHz} {450MHz / 600MHz} {500MHz / 600MHz} {550MHz / 600MHz} {600MHz / 600MHz} {650MHz / 600MHz} {} {400MHz / 625MHz} {450MHz / 625MHz} {500MHz / 625MHz} {550MHz / 625MHz} {600MHz / 625MHz} {650MHz / 625MHz} {} {400MHz / 650MHz} {450MHz / 650MHz} {550MHz / 650MHz} {600MHz / 650MHz} {650MHz / 650MHz} {} {400MHz / 675MHz} {450MHz / 675MHz} {500MHz / 675MHz} {550MHz / 675MHz} {600MHz / 675MHz} {650MHz / 675MHz} {} {400MHz / 700MHz} {450MHz / 700MHz} {500MHz / 700MHz} {550MHz / 700MHz} {600MHz / 700MHz} {650MHz / 700MHz} {} {400MHz / 725MHz} {450MHz / 725MHz} {500MHz / 725MHz} {550MHz / 725MHz} {600MHz / 725MHz} {650MHz / 725MHz} {} {400MHz / 750MHz} {450MHz / 750MHz} {500MHz / 750MHz} {550MHz / 750MHz} {600MHz / 750MHz} {650MHz / 750MHz} }

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
		# RSX OC 650/550
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 550MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 550MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x16\x04"
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
		# RSX OC 650/575
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 575MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 575MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x17\x04"
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
		# RSX OC 650/600
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 600MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 600MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x18\x04"
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
		# RSX OC 650/625
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 625MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 625MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x19\x04"
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
		# RSX OC 650/675
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 675MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 675MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1b\x04"
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
		# RSX OC 650/725
		if {$::01_patch_rsx_oc::options(--patch-lv1-rsx-oc) == "650MHz / 725MHz"} {
            log "Patching LV1 hypervisor to overclock RSX to 650MHz / 725MHz"
			set search  "\x0a\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1a\x04"
			set replace "\x0d\x02\x00\x00\x00\xa1\x00\x00\x00\x00\x00\x00\x1d\x04"
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
	}
}
