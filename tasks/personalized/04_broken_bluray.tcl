#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 30
# Description: Patch Firmware for consoles with broken blu-ray drive
    
# Option --remove-bd-revoke: remove BdpRevoke (ENABLING THIS WILL REMOVE BLU-RAY DRIVE FIRMWARE)
# Option --remove-bd-firmware: remove BD firmware (ENABLING THIS WILL REMOVE BLU-RAY DRIVE FIRMWARE)
# Option --patch-lv1-nobd: Select MLT's (3.55+) or zecoxao's (4.xx) noBD patch, to fake a working BLU-RAY Drive

# Type --remove-bd: boolean
# Type --patch-lv1-nobd: combobox { {MLT (3.55+)} {zecoxao (4.xx)} }

namespace eval ::04_broken_bluray {

    array set ::04_broken_bluray::options {
        --remove-bd-revoke true
        --remove-bd-firmware true
        --patch-lv1-nobd ""
    }
    
    proc main {} {
		if {$::04_broken_bluray::options(--remove-bd-revoke) || $::04_broken_bluray::options(--remove-bd-firmware)} {
			::modify_upl_file ::04_broken_bluray::callback
		}

		if {$::04_broken_bluray::options(--remove-bd-revoke) && $::04_broken_bluray::options(--remove-bd-firmware) && $::04_broken_bluray::options(--patch-lv1-nobd) == "MLT (3.55+)"} {
			set self "lv1.self"
				::modify_coreos_file $self ::04_broken_bluray::patch_file
		}

		if {${::NEWMFW_VER} > "4.20"} {
			if {$::04_broken_bluray::options(--patch-lv1-nobd) == "zecoxao (4.xx)"} {
				if {$::04_broken_bluray::options(--remove-bd-revoke) && $::04_broken_bluray::options(--remove-bd-firmware)} {
					set self "lv1.self"
						::modify_coreos_file $self ::04_broken_bluray::patch_file
				} else {
					return -code error "  TO HAVE FULL NOBD MFW, YOU HAVE TO REMOVE BLU-RAY UPDATE PKGS AS WELL !!!"
				}
			}
		}
    }

    proc callback { file } {
	
        log "Modifying XML file [file tail ${file}]"       
        set xml [::xml::LoadFile $file]
        if {$::04_broken_bluray::options(--remove-bd-revoke)} {
		  log "Removing BdpRevoke package...."
          set xml [::remove_pkg_from_upl_xml $xml "BdpRevoke" "blu-ray drive revoke"]
        }

        if {$::04_broken_bluray::options(--remove-bd-firmware)} {
		  log "Removing Blu-ray firmware packages...."
          set xml [::remove_pkgs_from_upl_xml $xml "BD" "blu-ray drive firmware"]
        }
		# save the file as is, then re-read it
		# in, and fixup the CR/LFs, etc
        ::xml::SaveToFile $xml $file
		
		set finaldata ""		
		set xml ""
		set fd [open $file r]
		fconfigure $fd -translation binary 
        set xml [read $fd]
        close $fd     		
		
		# iterate through the 'xml' data
		# since the "xml.tcl" removes the original xml header, we
		# need to add it back!!
		append finaldata "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\x0A"		
		set lines [split $xml "\x0D"]
		foreach line $lines {			
			append finaldata $line
		}
        # write out final data
        set fd [open $file w]
		fconfigure $fd -translation binary
        puts -nonewline $fd $finaldata
        close $fd        		
    }

	proc patch_file {self} {
        log "Patching [file tail $self]"
		if {$::04_broken_bluray::options(--patch-lv1-nobd) == "MLT (3.55+)"} {
			::modify_self_file $self ::04_broken_bluray::mlt_elf
		} elseif {${::NEWMFW_VER} >= "4.21" && $::04_broken_bluray::options(--patch-lv1-nobd) == "zecoxao (4.xx)"} {
			::modify_self_file $self ::04_broken_bluray::zeco_elf
		}
    }

	proc mlt_elf {elf} {
		#Patch lv1 for PS3 and Broken BD Drives!
		log "Patching MLT's lv1 noBD Fix for 3.55+ MFW"
		log "Credits to MLT!"
		log "Part 1" 1
			set  search "\xF9\x21\x00\x78\x40\x9D\x00\x14"
			set replace "\xF9\x21\x00\x78\x60\x00\x00\x00"
			set offset 0
			set mask 0				
				catch_die {::patch_elf $elf $search $offset $replace $mask} \
					"Unable to patch self [file tail $elf]"
			log "Part 2" 1
				set  search "\x41\x9E\x00\x14\x2F\xBF\x00\xA7"
				set replace "\x48\x00\x00\x14\x2F\xBF\x00\xA7"
				set offset 0
				set mask 0				
					catch_die {::patch_elf $elf $search $offset $replace $mask} \
						"Unable to patch self [file tail $elf]"
			log "Part 3" 1
				set  search "\x2F\x9D\x00\x00\x41\xDE\x00\x28\x38\x1F\xFF\xFF"
				set mask    "\xFF\x00\xFF\xFF\xFF\x00\x00\x00\xFF\xFF\xFF\xFF"				
				set replace "\x2F\x9D\x00\x00\x60\x00\x00\x00\x38\x1F\xFF\xFF"
				set offset 0
					catch_die {::patch_elf $elf $search $offset $replace $mask} \
						"Unable to patch self [file tail $elf]"
    }

	proc zeco_elf {elf} {
		if {${::NEWMFW_VER} > "4.20"} {
			#Patch lv1 for PS3 and Broken BD Drives!
			log "Patching zecoxao's lv1 noBD Fix for 4.xx MFW"
			log "Credits to zecoxao!"
			log "Part 1" 1
				set  search "\xF9\x21\x00\x78\x40\x9D\x00\x14"
				set replace "\xF9\x21\x00\x78\x60\x00\x00\x00"
				set offset 0
				set mask 0				
					catch_die {::patch_elf $elf $search $offset $replace $mask} \
						"Unable to patch self [file tail $elf]"
			log "Part 2" 1
				set  search "\x2F\xBF\x00\xA7\x41\x9E\x00\x0C\x2F\xBF\x00\xA5\x40\x9E\x00\x54"
				set replace "\x2F\xBF\x00\xA7\x41\x9E\x00\x0C\x2F\xBF\x00\xA5\x60\x00\x00\x00"
				set offset 0
				set mask 0				
					catch_die {::patch_elf $elf $search $offset $replace $mask} \
						"Unable to patch self [file tail $elf]"
			log "Part 3" 1
				set  search "\x78\x84\x00\x20\xF8\x01\x00\x70\xF9\x21\x00\x78\x40\x9E\x00\x0C"
				set replace "\x78\x84\x00\x20\xF8\x01\x00\x70\xF9\x21\x00\x78\x60\x00\x00\x00"
				set offset 0
				set mask 0				
					catch_die {::patch_elf $elf $search $offset $replace $mask} \
						"Unable to patch self [file tail $elf]"
		} else {
			return -code error "  ZECOXAO'S PATCHES ONLY WORK ON 4.XX FIRMWARES !!!"
		}
    }
}
