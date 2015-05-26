#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
# Copyright (C) glevand (geoffrey.levand@mail.ru)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 300
# Description: Patch emergency init

# Option --patch-emer-init-gameos-hdd-region-size-half: Create GameOS HDD region of size half of installed HDD
# Option --patch-emer-init-gameos-hdd-region-size-quarter: Create GameOS HDD region of size quarter of installed HDD
# Option --patch-emer-init-gameos-hdd-region-size-eighth: Create GameOS HDD region of size eighth of installed HDD
# Option --patch-emer-init-gameos-hdd-region-size-22gb-smaller: Create GameOS HDD region of size 22GB smaller than default
# Option --patch-emer-init-disable-pup-search-in-game-disc: Disable searching for update packages in GAME disc.

# Type --patch-emer-init-gameos-hdd-region-size-half: boolean
# Type --patch-emer-init-gameos-hdd-region-size-quarter: boolean
# Type --patch-emer-init-gameos-hdd-region-size-eighth: boolean
# Type --patch-emer-init-gameos-hdd-region-size-22gb-smaller: boolean
# Type --patch-emer-init-disable-pup-search-in-game-disc: boolean

namespace eval ::patch_emer_init {

    array set ::patch_emer_init::options {
        --patch-emer-init-gameos-hdd-region-size-half false
        --patch-emer-init-gameos-hdd-region-size-quarter true
        --patch-emer-init-gameos-hdd-region-size-eighth false
        --patch-emer-init-gameos-hdd-region-size-22gb-smaller false
        --patch-emer-init-disable-pup-search-in-game-disc false
    }

    proc main { } {
        set self "emer_init.self"

        ::modify_coreos_file $self ::patch_emer_init::patch_self
    }

    proc patch_self {self} {
        ::modify_self_file $self ::patch_emer_init::patch_elf
    }

    proc patch_elf {elf} {
        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-half)} {
            log "Patching emergency init to create GameOS HDD region of size half of installed HDD"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x79\x27\xf8\x42"
			set offset 28
			set mask 0				 
			# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"   
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-quarter)} {
            log "Patching emergency init to create GameOS HDD region of size quarter of installed HDD"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x79\x27\xf0\x82"
			set offset 28
			set mask 0				 
			# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"   
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-eighth)} {
            log "Patching emergency init to create GameOS HDD region of size eighth of installed HDD"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x79\x27\xe8\xc2"
			set offset 28
			set mask 0				 
			# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"   
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-22gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 22GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xfd\x40"
			set offset 28
			set mask 0				 
			# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"   
        }

        if {$::patch_emer_init::options(--patch-emer-init-disable-pup-search-in-game-disc)} {
            log "Patching emergency init to disable searching for update packages in GAME disc"

            set search  "\x80\x01\x00\x74\x2f\x80\x00\x00\x40\x9e\x00\x14\x7f\xa3\xeb\x78"
            set replace "\x38\x00\x00\x01"
			set offset 0
			set mask 0				 
			# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"   
        }
    }
}
