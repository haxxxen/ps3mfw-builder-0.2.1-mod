#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 170
# Description: Enable FSELFs on CEX CFW / MFW or REBUG CFWs

# Option --version: Select CEX 4.XX, REBUG 4.XX or 3.41 / 3.55 Base Firmware
# Option --patch-fself: Patch self(s) to enable FSELFs on CEX

# Type --version: combobox { {CEX 4.XX} {REBUG REX 4.XX} {REBUG D-REX 4.XX} {3.41 / 3.55 CEX / REBUG} }
# Type --patch-fself: boolean

namespace eval ::19_patch_fself {

    array set ::19_patch_fself::options {
		--version ""
        --patch-fself true
    }

    proc main { } {	
		variable options
		if {${::NEWMFW_VER} > "3.56"} {
			if {!$::options(--auto-cos)} {
				return -code error "  YOU HAVE TO SELECT LV0 EXTRACT OPTION FOR 4.XX MFW !!!"
			}
		}

		if {$::19_patch_fself::options(--version) == ""} {
			return -code error "  YOU HAVE TO SELECT FIRMWARE BASE VERSION !!!"
		}

		if {${::NEWMFW_VER} >= "4.20"} {
			set vsh [file join dev_flash vsh module vsh.self]
				::modify_devflash_file $vsh ::19_patch_fself::Do_VSH_Patches

			if {($::19_patch_fself::options(--version) != "CEX 4.XX")} {
				set vshs {vsh/module/vsh.self.cexsp vsh/module/vsh.self.swp}
					::modify_devflash_files [file join dev_flash] $vshs ::19_patch_fself::Do_VSH_Patches
				if {($::19_patch_fself::options(--version) == "REBUG REX 4.XX")} {
					set lv2dex "lv2Dkernel.self"
						::modify_coreos_file $lv2dex ::19_patch_fself::Do_LV2_Patches
				} else {
					set lv2 "lv2Ckernel.self"
						::modify_coreos_file $lv2 ::19_patch_fself::Do_LV2_Patches
				}
			}

			set lv2 "lv2_kernel.self"
				::modify_coreos_file $lv2 ::19_patch_fself::Do_LV2_Patches

			set self "appldr.self"
			set path $::CUSTOM_COSUNPKG_DIR
			set file [file join $path $self]
				::modify_coreos_file $file ::19_patch_fself::Do_APPLDR_Patches
		} else {
			if {($::19_patch_fself::options(--version) == "3.41 / 3.55 CEX / REBUG")} {
				set self "appldr"
					::modify_coreos_file $self ::19_patch_fself::Do_APPLDR_Patches
			}
		}
    }

    proc Do_VSH_Patches {self} {
        log "Patching [file tail $self]"
			::modify_self_file $self ::19_patch_fself::VSH_elf_Patches
    }
	proc VSH_elf_Patches {elf} {
		log "Applying VSH FSELF Patch...."

			set search  "\xF8\x21\xFF\x81\x7C\x08\x02\xA6\xFB\xE1\x00\x78\x7C\x7F\x1B\x78\xF8\x01\x00\x90\x3D\x60"
			set replace "\x38\x60\x00\x00\x4E\x80\x00\x20"
			set offset 0
			set mask 0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
	}

    proc Do_LV2_Patches {self} {
        log "Patching [file tail $self]"
			::modify_self_file $self ::19_patch_fself::LV2_elf_Patches
    }
	proc LV2_elf_Patches {elf} {
		log "Applying LV2_KERNEL FSELF Patch...."

			set search  "\x2F\x83\x00\x00\x41\x9E\xFF\x50\x7C\x7F\x1B\x78\x48\x00\x00\x18"
			set replace "\x38\x00\x00\x01\x98\x09\x00\x00"
			set offset 52
			set mask	0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
	}

    proc Do_APPLDR_Patches {self} {
        log "Patching [file tail $self]"
			::modify_iso_file $self ::19_patch_fself::APPLDR_elf_Patches
    }
	proc APPLDR_elf_Patches {elf} {
		if {${::NEWMFW_VER} >= "4.20"} {
			log "Applying 4.XX APPLDR FSELF Patches...."

				log "Patch 1"
				set search  "\x24\xFF\xC0\xD0\x7E\x00\x03\x03\x04\x00"
				set replace "\x04\x00\x29\x03\x40\x80\x00\x03"
				set offset 32
				set mask 0
					# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

				log "Patch 2"
				set search  "\x24\xFE\x00\xD7\x04\x00\x06\xD4\x24\xFD\xC0\xD8\x04\x00\x05\x56"
				set replace "\x24\xFE\x00\xD7\x40\x80\x00"
				set offset 0
				set mask 0
					# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
		}
		
		if {${::NEWMFW_VER} == "3.41"} {
			log "Applying 3.41 APPLDR FSELF Patch...."

				set search  "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x00\x04\x80\x32\x80\x80"
				set replace "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x10\xF8\x80\x32\x80\x80"
				set offset 7
				set mask 0
					# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
		}
		
		if {${::NEWMFW_VER} == "3.55"} {
			log "Applying 3.55 APPLDR FSELF Patch...."

				set search  "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x00\x04\x80\x32\x80\x80"
				set replace "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x11\x73\x00\x32\x80\x80"
				set offset 7
				set mask 0
					# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
		}
	}
}
