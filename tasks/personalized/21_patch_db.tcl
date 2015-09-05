#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 190
# Description: Patch 4.XX OFW for dualboot installations

# Option --patch-db: Patch selfs to disable ECDSA signature

# Type --patch-db: boolean

namespace eval ::21_patch_db {

    array set ::21_patch_db::options {
        --patch-db true
    }

    proc main { } {	
		variable options
		if {!$::options(--auto-cos)} {
			return -code error "  YOU HAVE TO SELECT LV0 EXTRACT OPTION !!!"
		}

		if {!$::options(--sign-iso)} {
			return -code error "  PLEASE SELECT ISO_REBUILDER OPTION. THIS MAKES IT MORE ORIGINALLY !!!"
		}

		set self "isoldr.self"
		set path $::CUSTOM_COSUNPKG_DIR
		set file [file join $path $self]
			::modify_coreos_file $file ::21_patch_db::Do_ISOLDR_Patches

		set self "spu_pkg_rvk_verifier.self"
		set path $::CUSTOM_COSUNPKG_DIR
		set file [file join $path $self]
			::modify_coreos_file $file ::21_patch_db::Do_PKG_Patches
    }

    proc Do_ISOLDR_Patches {self} {
        log "Patching [file tail $self]"
			::modify_iso_file $self ::21_patch_db::ISOLDR_elf_Patches
    }
	proc ISOLDR_elf_Patches {elf} {
		log "Applying ISOLDR ECDSA Patches...."

		log "Patch 1"
			set search  "\x3F\xE1\x12\x85\x18\x01\x42\x06"
			set mask 	"\xFF\xFF\x00\xFF\xFF\xFF\xFF\xFF"
			set replace "\x40\x80\x00\x03"
			set offset 8
				# PATCH THE ELF BINARY
				catch_die {::patch_file_multi $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

		# log "Patch 2"
			# set search  "\x3F\xE1\x1F\x85\x18\x01\x42\x06"
			# set replace "\x40\x80\x00\x03"
			# set offset 8
			# set mask 0
				# PATCH THE ELF BINARY
				# catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
	}

    proc Do_PKG_Patches {self} {
        log "Patching [file tail $self]"
			::modify_iso_file $self ::21_patch_db::PKG_elf_Patches
    }
	proc PKG_elf_Patches {elf} {
		log "Applying SPU_PKG_RVK_VERIFIER ECDSA Patches...."

			set search  "\x21\x00\x03\x03\x04\x00\x2A\x03"
			set replace "\x40\x80\x00\x03"
			set offset 8
			set mask 0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
	}
}
