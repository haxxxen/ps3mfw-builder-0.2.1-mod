#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 200
# Description: Patch APPLDR to to allow unsigned apps (REPLACES KAKAROTO'S VSH PATCHES)

# Option --patch-appldr-unsigned-apps: Patch appldr with JFW DH patterns (4.21 only)

# Type --patch-appldr-unsigned-apps: boolean

namespace eval ::22_patch_appldr_unsigned_apps {

    array set ::22_patch_appldr_unsigned_apps::options {
		--patch-appldr-unsigned-apps true
    }

    proc main { } {
		variable options
		if {!$::options(--auto-cos)} {
			return -code error "  YOU HAVE TO SELECT LV0 EXTRACT OPTION FOR 4.XX MFW !!!"
		}

		if {!$::options(--sign-iso)} {
			return -code error "  YOU HAVE TO SELECT ISO_REBUILDER OPTION FOR 4.21 !!!"
		}

		if {${::NEWMFW_VER} != "4.21"} {
			return -code error "  SORRY, ONLY FIRMWARE 4.21 FOR NOW !!!"
		} else {
			set self "appldr.self"
			set path $::CUSTOM_COSUNPKG_DIR
			set file [file join $path $self]
				::modify_coreos_file $file ::22_patch_appldr_unsigned_apps::Do_APPLDR_Patches
		}
    }

    proc Do_APPLDR_Patches {self} {
        log "Patching [file tail $self]"
			::modify_iso_file $self ::22_patch_appldr_unsigned_apps::APPLDR_elf_Patches
    }
	proc APPLDR_elf_Patches {elf} {
		log "Applying APPLDR unsigned apps Patches based on JFW DH 3.56 MA...."

		if {$::22_patch_appldr_unsigned_apps::options(--patch-appldr-unsigned-apps)} {
			log "Patch 1"
			set search  "\x21\x00\x0E\x03\x04\x00\x28\x03\x33\x12\x84\x80\x12\x00\x0D\x8A\x21\x00\x0C\x03"
			set replace "\x00\x20\x00\x00\x04\x00\x28\x03\x33\x12\x84\x80\x12\x00\x0D\x8A\x00\x20\x00\x00"
			set offset 0
			set mask 0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

			log "Patch 2"
			set search  "\x20\x00\x08\x82\x33\x7E\x21\x80"
			set replace "\x32\x00\x08\x82\x33\x7E\x21\x80"
			set offset 0
			set mask 0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

			log "Patch 3"
			set search  "\x00\x04\x12\x32\xF2\x8F\x40\x80\x10\x05\x24\x00\x40\x80"
			set replace "\x00\x03\x35\x00\x00\x00\x00\x20\x00\x00\x00\x20\x00\x00"
			set offset 0
			set mask 0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

			log "Patch 4"
			set search  "\x20\x00\x24\x0D\x32\x00\x21\x00"
			set replace "\x00\x20\x00\x00\x32\x00\x21\x00"
			set offset 0
			set mask 0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

			log "Patch 5"
			set search  "\x21\x00\x12\x83\x04\x00\x29\x83"
			set replace "\x00\x20\x00\x00\x04\x00\x29\x83"
			set offset 0
			set mask 0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

			log "Patch 6"
			set search  "\x20\x7F\xDE\x03\x32\x7F\xFC\x00"
			set replace "\x32\x7F\xDE\x03\x32\x7F\xFC\x00"
			set offset 0
			set mask 0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

			log "Patch 7"
			set search		"\x21\x00\x0A\x82\x34\x02\x68\x04\x3F\x82\x02\x04\x33\x7C\x69\x80"
			append search	"\x33\xB0\x33\x04\x04\x00\x01\x82\x04\x00\x28\x03\x21\x00\x07\x02"
			append search	"\x34\x02\x68\x07\x3F\x82\x03\x85\x33\x7C\x23\x00\x12\x7B\xBB\x89"
			append search	"\x04\x00\x01\x82\x3F\xE0\x28\x03\x21\x00\x03\x82"
			set replace		"\x00\x20\x00\x00\x34\x02\x68\x04\x3F\x82\x02\x04\x33\x7C\x69\x80"
			append replace	"\x33\xB0\x33\x04\x04\x00\x01\x82\x04\x00\x28\x03\x00\x20\x00\x00"
			append replace	"\x34\x02\x68\x07\x3F\x82\x03\x85\x33\x7C\x23\x00\x12\x7B\xBB\x89"
			append replace	"\x04\x00\x01\x82\x3F\xE0\x28\x03\x00\x20\x00\x00"
			set offset 0
			set mask 0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

			log "Patch 8"
			set search  "\x21\x00\x1E\x83\x34\x03\xA8\xA0"
			set replace "\x00\x20\x00\x00\x34\x03\xA8\xA0"
			set offset 0
			set mask 0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

			log "Patch 9 (=OFW pattern for CFWs like REBUG)"
			set search  "\x04\x00\x01\xD0\x21\x00\x0F\x03\x04\x00\x28\x83"
			set replace "\x33\x7C\x55\x80\x04\x00\x01\xD0"
			set offset 12
			set mask 0
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
		}
	}
}
