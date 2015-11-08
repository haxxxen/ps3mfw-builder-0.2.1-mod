#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 80
# Description: Patch advanced Remote Play

# Option --patch-premo: Patch premo modules to enable Remote Play
# Option --patch-game: Patch game_ext_plugin module to enable Remote Play

# Type --patch: boolean

namespace eval ::09_patch_premo {

    array set ::09_patch_premo::options {
      --patch-premo true
      --patch-game true
    }

    proc main {} {
		variable options
		if {${::NEWMFW_VER} < "4.20"} {
			return -code error "  REMOTE PLAY IS ONLY AVAILABLE ON 4.XX FIRMWARES !!!"
		} else {
			if {$::09_patch_premo::options(--patch-premo)} {
				log "Patching Remote Play compatibility"
					set self [file join dev_flash vsh module premo_game_plugin.sprx]
						::modify_devflash_file $self ::09_patch_premo::patch_premo
					set self [file join dev_flash vsh module premo_plugin.sprx]
						::modify_devflash_file $self ::09_patch_premo::patch_premo
			}

			if {$::09_patch_premo::options(--patch-game)} {
				log "Patching Remote Play SFO hack (by mysis)"
					set self [file join dev_flash vsh module game_ext_plugin.sprx]
						::modify_devflash_file $self ::09_patch_premo::patch_game
			}
		}
    }

    proc patch_premo {self} {
		::modify_self_file $self ::09_patch_premo::premo_elf
	}
    proc premo_elf {elf} {
        if {$::09_patch_premo::options(--patch-premo) } {
			log "Patching [file tail $elf] with Pattern"
			set search      "\x38\x60\x00\x00\xE8\x01\x00\x90\x7C\x63\x07\xB4\xEB\xC1"
			set replace     "\x38\x60\x00\x01\xE8\x01\x00\x90\x7C\x63\x07\xB4\xEB\xC1"
			set offset 0
			set mask 0				
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
		}
	}

    proc patch_game {self} {
		::modify_self_file $self ::09_patch_premo::game_elf
	}
    proc game_elf {elf} {
        if {$::09_patch_premo::options(--patch-game) } {
			log "Patching [file tail $elf] with Pattern"
			set search      "\x41\x9e\x00\x1c\x2f\x83\x00\x03"
			set replace     "\x41\x9e\x00\x28\x2f\x83\x00\x03"
			set offset 0
			set mask 0				
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
		}
	}
}

