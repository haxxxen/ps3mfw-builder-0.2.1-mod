#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 160
# Description: Re-enable GAMEBOOT sound and animation on 3.00+ MFW

# Option --patch-game: Patch game_ext_plugin.sprx to re-enable gameboot

# Type --patch: boolean

namespace eval ::18_patch_gameboot {

    array set ::18_patch_gameboot::options {
      --patch-game true
    }

    proc main {} {
		variable options
		if {${::NEWMFW_VER} < "3.00"} {
			return -code error "  GAMEBOOT NEED TO BE RE-ENABLED ONLY ON 3.00+ FIRMWARES !!!"
		} else {
			if {$::18_patch_gameboot::options(--patch-game)} {
				log "Patching gameboot sound and animation (by mysis??)"
					set self [file join dev_flash vsh module game_ext_plugin.sprx]
						::modify_devflash_file $self ::18_patch_gameboot::patch_game
					set coldboot_stereo [file join dev_flash vsh resource coldboot_stereo.ac3]
						::modify_devflash_file $coldboot_stereo ::18_patch_gameboot::add_stereo
					set coldboot_multi [file join dev_flash vsh resource coldboot_multi.ac3]
						::modify_devflash_file $coldboot_multi ::18_patch_gameboot::add_multi
					set theme [file join dev_flash vsh resource theme 01.p3t]
						::modify_devflash_file $theme ::18_patch_gameboot::remove_theme
			}
		}
    }

    proc patch_game {self} {
		::modify_self_file $self ::18_patch_gameboot::game_elf
	}
    proc game_elf {elf} {
        if {$::18_patch_gameboot::options(--patch-game) } {
			if {${::NEWMFW_VER} < "4.53"} {
				log "Patching 3.00-4.50 [file tail $elf] with Pattern"
				set search      "\x38\x80\x00\x00\x7B\xE3\x00\x20"
				set replace     "\x38\x80\x00\x00\x38\x60\x00\x02"
				set offset 0
				set mask 0				
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
			} elseif {${::NEWMFW_VER} >= "4.53"} {
				log "Patching 4.53+ [file tail $elf] with Pattern"
				set search      "\x2F\x89\x00\x00\x7B\xC3\x00\x20"
				set replace     "\x2F\x89\x00\x00\x38\x60\x00\x02"
				set offset 0
				set mask 0				
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
			}
		}
	}

    proc add_stereo {file} {
		variable options
		set stereo [file join ${::CUSTOM_GAMEBOOT_DIR} gameboot_stereo.ac3]
		file copy -force [file join $stereo] [file join ${::CUSTOM_DEV_RES} gameboot_stereo.ac3]
	}
    proc add_multi {file} {
		variable options
		set multi [file join ${::CUSTOM_GAMEBOOT_DIR} gameboot_multi.ac3]
		file copy -force [file join $multi] [file join ${::CUSTOM_DEV_RES} gameboot_multi.ac3]
	}
    proc remove_theme {file} {
		file delete -force [file join ${::CUSTOM_DEV_RES} theme $file]
	}
}

