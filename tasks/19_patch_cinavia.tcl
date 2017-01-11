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
# Description: Remove CINAVIA Copy Protection on HDD Content
 
# Option --patch-disable-cinavia: Select Base Firmware
 
# Type --patch-disable-cinavia: combobox { {CEX} {REBUG} }
 
namespace eval ::19_patch_cinavia {
 
    array set ::19_patch_cinavia::options {
        --patch-disable-cinavia ""
    }
 
    proc main {} {
		if {$::19_patch_cinavia::options(--patch-disable-cinavia) != ""} {
			if {$::19_patch_cinavia::options(--patch-disable-cinavia) == "CEX"} {
				set selfs {bdp_BDMV.self bdp_BDVD.self}
				::modify_devflash_file [file join dev_flash vsh module videoplayer_plugin.sprx] ::19_patch_cinavia::patch_sprx
				::modify_devflash_files [file join dev_flash bdplayer] $selfs ::19_patch_cinavia::patch_self
			# } elseif {$::19_patch_cinavia::options(--patch-disable-cinavia) == "DEX"} {
				# ::modify_devflash_file [file join dev_flash vsh module vsh.self] ::19_patch_cinavia::patch_self
			} elseif {$::19_patch_cinavia::options(--patch-disable-cinavia) == "REBUG"} {
				set selfs {bdp_BDMV.self bdp_BDVD.self}
				::modify_devflash_files [file join dev_flash bdplayer] $selfs ::19_patch_cinavia::patch_self
			}
		}
	}
 
    proc patch_sprx { self } {
			::modify_self_file $self ::19_patch_cinavia::patch_prx
    }
    proc patch_self { self } {
			::modify_self_file $self ::19_patch_cinavia::patch_elf
    }
 
    proc patch_prx { elf } {
            log "Patching [file tail $elf] to disable CINAVIA protection message (credits to mysis and habib)"

            set search  "\xF8\x21\xFF\x51\x7C\x08\x02\xA6\xFB\x41\x00\x80\x7C\x7A\x1B\x78\x3C\x80"
			set replace "\x4E\x80\x00\x20"
			set offset 0
			set mask 0			
				# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

			set search  "\xF8\x21\xFF\x51\x7C\x08\x02\xA6\xFB\xA1\x00\x98\xF8\x01\x00\xC0\x83\xA3\x00\x00"
			set replace "\x4E\x80\x00\x20"
			set offset 0
			set mask 0			
				# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
    }
    proc patch_elf { elf } {
		    log "Patching [file tail $elf] to disable CINAVIA protection message (credits to mysis and habib)"

			set search  "\x4B\xFF\xFF\x81\x38\x00\x00\x01\x80\x7E\x80\x14\x98\x1F\x00\x00"
			set replace "\x4E\x80\x00\x20"
			set offset 56
			set mask 0			
				# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

			# set search  "\x4B\xFF\xFF\x81\x38\x00\x00\x01\x80\x7E\x80\x14\x98\x1F\x00\x00"
			# set replace "\x4E\x80\x00\x20"
			set offset 100
			set mask 0			
				# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
    }
}