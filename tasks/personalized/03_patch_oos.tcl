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

# Priority: 20
# Description: Patch LV1 for OtherOS++

# Option --fwtype: SELECT YOUR MFW BASE VERSION
# Option --patch-gameos-hdd-region-size: Create OtherOS HDD region of
# Option --patch-pup-search-in-game-disc: Disable updates from GAME Disc in Recovery Menu
# Option --patch-lv1-peek-poke: peek/poke support (unused lv1 calls 182 and 183)
# Option --patch-lv1-htab-write: Allow mapping of HTAB with write protection
# Option --patch-lv1-mfc-sr1-mask: Allow to set all bits of SPE register MFC_SR1 with lv1_set_spe_privilege_state_area_1_register
# Option --patch-lv1-dabr-priv-mask: Allow setting data access breakpoints in hypervisor state with lv1_set_dabr
# Option --patch-lv1-encdec-ioctl-0x85: Allow ENCDEC IOCTL command 0x85
# Option --patch-lv1-gpu-4kb-iopage: Allow 4kb IO page size for GPU GART memory
# Option --patch-lv1-um-extract-pkg: Allow extracting for all package types
# Option --patch-lv1-um-write-eprom-product-mode: Allow enabling product mode by using Update Manager Write EPROM
# Option --patch-lv1-sm-del-encdec-key: Allow deleting of all ENCDEC keys
# Option --patch-lv1-repo-node-lpar: Allow creating/modifying/deleting of repository nodes in any LPAR
# Option --patch-lv1-gameos-gos-mode-one: Enable GuestOS mode 1 for GameOS
# Option --patch-lv1-enable-dbgcard-calls: Enable debug card LV1 calls
# Option --patch-lv1-otheros-plus-plus-cold-boot-fix: OtherOS++ coldboot fix
# Option --patch-lv1-mmap: Allow mapping of any memory area (Needed for LV2 Poke)
# Option --patch-lv1-iimgr-access: Allow access to all services of Indi Info Manager
# Option --patch-lv1-gameos-sysmgr-ability: Allow access to all System Manager services of GameOS
# Option --patch-lv1-dispmgr-access: Allow access to all SS services (Needed for ps3dm-/ps3vuart-utils)
# Option --patch-lv1-sysmgr-disable-integrity-check: Disable integrity check in System Manager (Needed for ps3dm-/ps3vuart-utils)
# Option --patch-lv1-storage-skip-acl-check: Skip ACL checks for all storage devices
# Option --patch-lv1-otheros-plus-plus: OtherOS++ support (3.55 ONLY)
# Option --patch-lv1-um-qa: Enable QA in Update Manager
# Option --patch-lv1-ata-region0-access: Allow access to all regions of all storage devices

# Type --fwtype: combobox { {3.xx} {4.xx} }
# Type --patch-gameos-hdd-region-size: combobox { {22GB} {10GB} }
# Type --patch-pup-search-in-game-disc: boolean
# Type --patch-lv1: boolean

namespace eval ::03_patch_oos {

    array set ::03_patch_oos::options {
		--fwtype ""
        --patch-gameos-hdd-region-size ""
        --patch-pup-search-in-game-disc false
        --patch-lv1-peek-poke false
        --patch-lv1-htab-write false
        --patch-lv1-mfc-sr1-mask false
	--patch-lv1-dabr-priv-mask false
	--patch-lv1-encdec-ioctl-0x85 false
	--patch-lv1-gpu-4kb-iopage false
        --patch-lv1-um-extract-pkg false
	--patch-lv1-um-write-eprom-product-mode false
        --patch-lv1-sm-del-encdec-key false
        --patch-lv1-repo-node-lpar false
        --patch-lv1-gameos-gos-mode-one false
	--patch-lv1-enable-dbgcard-calls false
	--patch-lv1-otheros-plus-plus-cold-boot-fix false
        --patch-lv1-mmap false
	--patch-lv1-iimgr-access false
        --patch-lv1-gameos-sysmgr-ability false
        --patch-lv1-dispmgr-access false
	--patch-lv1-sysmgr-disable-integrity-check false
	--patch-lv1-storage-skip-acl-check false
	--patch-lv1-otheros-plus-plus false
        --patch-lv1-um-qa false
        --patch-lv1-ata-region0-access false
    }
        # --patch-lv1-lv2mem false

    proc main { } {
		if {$::03_patch_oos::options(--fwtype) == ""} {
			return -code error "  YOU HAVE TO SELECT BASE MFW VERSION !!!"
		}

		if {$::03_patch_oos::options(--fwtype) != "" && ($::03_patch_oos::options(--patch-gameos-hdd-region-size) != "" || $::03_patch_oos::options(--patch-pup-search-in-game-disc))} {
			set self "emer_init.self"
				::modify_coreos_file $self ::03_patch_oos::patch_emer
		}

		set self "lv1.self"
			::modify_coreos_file $self ::03_patch_oos::patch_self
    }

    proc patch_self {self} {
        ::modify_self_file $self ::03_patch_oos::patch_elf
    }
    proc patch_elf {elf} {
        if {$::03_patch_oos::options(--patch-lv1-peek-poke)} {
            log "Patching LV1 hypervisor to add peek/poke support"

            set search  "\x38\x00\x00\x00\x64\x00\xff\xff\x60\x00\xff\xec\xf8\x03\x00\xc0"
	    append search "\x4e\x80\x00\x20\x38\x00\x00\x00"
            set replace "\xe8\x83\x00\x18\xe8\x84\x00\x00\xf8\x83\x00\xc8"
			set offset 4
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

            set search  "\x4e\x80\x00\x20\x38\x00\x00\x00\x64\x00\xff\xff\x60\x00\xff\xec"
	    append search "\xf8\x03\x00\xc0\x4e\x80\x00\x20"
            set replace "\xe8\xa3\x00\x20\xe8\x83\x00\x18\xf8\xa4\x00\x00"
			set offset 8
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

		if {$::03_patch_oos::options(--patch-lv1-htab-write)} {
            log "Patching LV1 hypervisor to allow mapping of HTAB with write protection"

            set search  "\x2f\x1d\x00\x00\x61\x4a\x97\xd2\x7f\x80\xf0\x00\x79\x4a\x07\xc6"
	    append search "\x65\x4a\xb5\x8e\x41\xdc\x00\x54\x3d\x40\x99\x79\x41\xda\x00\x54"
            set replace "\x60\x00\x00\x00"
			set offset 28
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
	}

        if {$::03_patch_oos::options(--patch-lv1-mfc-sr1-mask)} {
            log "Patching LV1 hypervisor to allow setting all bits of SPE register MFC_SR1 with lv1_set_spe_privilege_state_area_1_register"

            set search  "\xe8\x03\x00\x10\x39\x20\x00\x09\xe9\x43\x00\x00\x39\x00\x00\x00"
	    append search "\x78\x00\xef\xa6\x7c\xab\x48\x38\x78\x00\x1f\xa4\x7d\x6b\x03\x78"
            set replace "\x39\x20\xff\xff"
			set offset 4
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
	}

        if {$::03_patch_oos::options(--patch-lv1-dabr-priv-mask)} {
            log "Patching LV1 hypervisor to allow setting data access breakpoints in hypervisor state with lv1_set_dabr"

            set search  "\x60\x00\x00\x00\x38\x00\x00\x0b\x7f\xe9\x00\x38\x7f\xa9\xf8\x00"
            set replace "\x38\x00\x00\x0f"
			set offset 4
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
	}

        if {$::03_patch_oos::options(--patch-lv1-encdec-ioctl-0x85)} {
            log "Patching LV1 hypervisor to allow ENCDEC IOCTL command 0x85"

			set search  "\x00\x1C\x38\x00\x00\x01\x39\x20"
			if {$::03_patch_oos::options(--fwtype) == "3.xx"} {
				set replace "\x00\x5f"
			}
			if {$::03_patch_oos::options(--fwtype) == "4.xx"} {
				set replace "\x00\xdf"
			}
			set offset 8
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
	}

        if {$::03_patch_oos::options(--patch-lv1-gpu-4kb-iopage)} {
            log "Patching LV1 hypervisor to allow 4kb IO page size for GPU GART memory"

            set search  "\x6d\x00\x55\x55\x2f\xa9\x00\x00\x68\x00\x55\x55\x39\x20\x00\x00"
            set replace "\x38\x00\x10\x00"
			set offset 84
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
	}

        if {$::03_patch_oos::options(--patch-lv1-um-extract-pkg)} {
            log "Patching Update Manager to enable extracting for all package types"

            set search  "\x38\x1f\xff\xf9\x2f\x1d\x00\x01\x2b\x80\x00\x01\x38\x00\x00\x00"
	    append search "\xf8\x1b\x00\x00\x41\x9d\x00\xa8\x7b\xfd\x00\x20\x7f\x44\xd3\x78"
            set replace "\x60\x00\x00\x00"
			set offset 20
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-um-write-eprom-product-mode)} {
            log "Patching Update Manager to enable setting product mode by using Update Manager Write EPROM"

            set search  "\xe8\x18\x00\x08\x2f\xa0\x00\x00\x40\x9e\x00\x10\x7f\xc3\xf3\x78"
            set replace "\x38\x00\x00\x00"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-sm-del-encdec-key)} {
            log "Patching Storage Manager to allow deleting of all ENCDEC keys"

            set search  "\x7d\x24\x4b\x78\x39\x29\xff\xf4\x7f\xa3\xeb\x78\x2b\xa9\x00\x03"
            append search "\x38\x00\x00\x09\x41\x9d\x00\x4c"
            set replace "\x60\x00\x00\x00"
			set offset 20
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-repo-node-lpar)} {
            log "Patching LV1 hypervisor to allow creating/modifying/deleting of repository nodes in any LPAR"

            set search  "\x39\x20\x00\x00\xe9\x69\x00\x00\x4b\xff\xff\x68\x3d\x2d\x00\x00\x7c\x08\x02\xa6"
	    append search "\xf8\x21\xff\x11\x39\x29\x98\x18\xfb\xa1\x00\xd8"
            set replace  "\xe8\x1e\x00\x20\xe9\x3e\x00\x28\xe9\x5e\x00\x30\xe9\x1e\x00\x38\xe8\xfe\x00\x40"
	    append replace "\xe8\xde\x00\x48\xeb\xfe\x00\x18"
			set offset 64
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

            set search  "\x39\x20\x00\x00\xe9\x29\x00\x00\x4b\xff\xff\x9c\x3d\x2d\x00\x00\x7c\x08\x02\xa6"
	    append search "\xf8\x21\xff\x11\x39\x29\x98\x18\xfb\xa1\x00\xd8"
            set replace  "\xe8\x1e\x00\x20\xe9\x3e\x00\x28\xe9\x5e\x00\x30\xe9\x1e\x00\x38\xe8\xfe\x00\x40"
	    append replace "\xe8\xde\x00\x48\xeb\xfe\x00\x18"
			set offset 64
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

            set search  "\x39\x20\x00\x00\xe9\x29\x00\x00\x4b\xff\xfe\x70\x3d\x2d\x00\x00\x7c\x08\x02\xa6"
	    append search "\xf8\x21\xff\x31\x39\x29\x98\x18\xfb\xa1\x00\xb8"
            set replace  "\xe8\x1e\x00\x20\xe9\x5e\x00\x28\xe9\x1e\x00\x30\xe8\xfe\x00\x38\xeb\xfe\x00\x18"
			set offset 60
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-gameos-gos-mode-one)} {
            log "Patching LV1 to enable GuestOS mode 1 for GameOS"

            set search  "\x41\x9E\x00\x0C\x38\x60\x00\xFF"
            set replace "\x38\x60\x00\x01"
			if {$::03_patch_oos::options(--fwtype) == "3.xx"} {
				set offset 28
			}
			if {$::03_patch_oos::options(--fwtype) == "4.xx"} {
				set offset 12
			}
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-enable-dbgcard-calls)} {
            log "Patching LV1 to enable debug card LV1 calls"

            # lv1_undocumented_function_105

            set search  "\x41\x9E\x00\x64\x38\x00\x00\x01\x98\x1F"
            set replace "\x60\x00\x00\x00"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

            # lv1_undocumented_function_106

            set search  "\x41\x9E\x00\x34\x38\x00\x00\x01\x98\x1F"
            set replace "\x60\x00\x00\x00"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

            # lv1_undocumented_function_107

            set search  "\x41\x9E\x00\x4C\x38\x00\x00\x01\x98\x1E"
            set replace "\x60\x00\x00\x00"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

            # lv1_undocumented_function_108

            set search  "\x41\x9E\x00\x44\x38\x00\x00\x01\x98\x1E"
            set replace "\x60\x00\x00\x00"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

            # lv1_undocumented_function_109

            set search  "\x41\x9E\x00\x38\x38\x00\x00\x01\x98\x1F\x00\x00\x7F\xC3\xF3\x78\x38\x80\x00\x01"
            set replace "\x60\x00\x00\x00"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-otheros-plus-plus-cold-boot-fix)} {
            log "Patching Initial GOS Loader to enable OtherOS++ coldboot support"

			set search  "\xe9\x29\x00\x00\x2f\xa9\x00\x01\x40\x9e\x00\x18"
			set mask    "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xF0\xFF\xFF\xF0"				
            set replace "\x39\x20\x00\x03"
			set offset 0
			# set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-mmap)} {
            log "Patching LV1 hypervisor to allow mapping of any memory area (1006151)"				  

			if {$::03_patch_oos::options(--fwtype) == "3.xx"} {
				set search  "\x39\x08\x05\x48\x39\x20\x00\x00\x38\x60\x00\x00\x4b\xff\xfc\x45"
				set replace "\x01"
				set offset 7
			}
			if {$::03_patch_oos::options(--fwtype) == "4.xx"} {
				#set search    "\x41\x9E\xFF\xF0\x4B\xFF\xFD\x00\x38\x60\x00\x00\x4B\xFF\xFC\x58"  --- OLD MATCH PATTERN ---
				set search    "\x39\x2B\x00\x6C\x7D\x6B\x03\x78\x7D\x29\x03\x78\x91\x49\x00\x00\x48\x00\x00\x08\x43\x40\x00\x18"
				append search "\x80\x0B\x00\x00\x54\x00\x06\x30\x2F\x80\x00\x00\x41\x9E\xFF\xF0\x4B\xFF\xFD\x00"
				set replace   "\x4B\xFF\xFD\x01"
				set offset 40
			}
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }                        

        if {$::03_patch_oos::options(--patch-lv1-iimgr-access)} {
            log "Patching Indi Info Manager to allow access to all its services"

            set search  "\x38\x60\x00\x0d\x38\x00\x00\x0d\x7c\x63\x00\x38\x4e\x80\x00\x20"
            set replace "\x38\x60\x00\x00"
			set offset 8
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-gameos-sysmgr-ability)} {
            log "Patching System Manager ability mask of GameOS to allow access to all System Manager services"

            set search  "\x39\x20\x00\x03\xF9"
            set replace "\xff\xff"
			set offset 10
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

			set replace "\xff\xfe"
			set offset 18
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-dispmgr-access)} {
            log "Patching Dispatcher Manager to allow access to all SS services"

            set search  "\xe8\x17\x00\x08\x7f\xc4\xf3\x78\x7f\x83\xe3\x78\xf8\x01\x00\x98"
            set replace "\x60\x00\x00\x00"
			set offset 12
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

            set search  "\x7f\xa4\xeb\x78\x7f\x85\xe3\x78\x4b\xff\xf0\xe5\x54\x63\x06\x3e"
            set replace "\x38\x60\x00\x01"
			set offset 8
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

            set search  "\x7f\x84\xe3\x78\x38\xa1\x00\x70\x9b\xe1\x00\x70\x48\x00"
            set replace "\x3b\xe0\x00\x01\x9b\xe1\x00\x70\x38\x60\x00\x00"
			set offset 4
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-sysmgr-disable-integrity-check)} {
            log "Patching System Manager to disable integrity check"

            set search  "\x38\x60\x00\x01\xf8\x01\x00\x90\x88\x1f\x00\x00\x2f\x80\x00\x00"
            set replace "\x38\x60\x00\x00"
			set offset 20
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-storage-skip-acl-check)} {
            log "Patching LV1 to enable skipping of ACL checks for all storage devices"

            set search  "\x54\x63\x06\x3e\x2f\x83\x00\x00\x41\x9e\x00\x14\xe8\x01\x00\x70\x54\x00\x07\xfe"
	    append search "\x2f\x80\x00\x00\x40\x9e\x00\x18"
            set replace "\x38\x60\x00\x01\x2f\x83\x00\x00\x41\x9e\x00\x14\x38\x00\x00\x01"
			set offset 0
			set mask 0				
			# PATCH THE ELF BINARY
			catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
        }

        if {$::03_patch_oos::options(--patch-lv1-otheros-plus-plus)} {
			if {$::03_patch_oos::options(--fwtype) == "3.xx"} {
				log "Patching Secure LPAR Loader to add OtherOS++ support"
				set search "\x53\x43\x45\x00\x00\x00\x00\x02\x80\x00\x00\x01\x00\x00\x01\xe0\x00\x00\x00\x00"
				append search "\x00\x00\x04\x80\x00\x00\x00\x00\x00\x03\x8a\x50\x00\x00\x00\x00\x00\x00\x00\x03"
				append search "\x00\x00\x00\x00\x00\x00\x00\x70\x00\x00\x00\x00\x00\x00\x00\x90\x00\x00\x00\x00"
				append search "\x00\x00\x00\xd0\x00\x00\x00\x00\x00\x03\x8b\xd0\x00\x00\x00\x00\x00\x00\x01\x40"
				append search "\x00\x00\x00\x00\x00\x00\x01\x80\x00\x00\x00\x00\x00\x00\x01\x90\x00\x00\x00\x00"
				append search "\x00\x00\x00\x70\x00\x00\x00\x00\x00\x00\x00\x00\x10\x70\x00\x00\x34\x00\x00\x01"
				append search "\x07\x00\x00\x01\x00\x00\x00\x04"
				set replace "\x00\x00\x00\x00\x00\x01\xd0\x00\x00\x00\x00\x00\x00\x01\xd0\x00\x00\x00\x00\x00"
				append replace "\x00\x01\x00\x00\x00\x00\x00\x01\x00\x00\x00\x06\x00\x00\x00\x00\x00\x03\x00\x00"
				append replace "\x00\x00\x00\x00\xc0\x00\x00\x00\x00\x00\x00\x00\xc0\x00\x00\x00\x00\x00\x00\x00"
				append replace "\x00\x00\x77\x20\x00\x00\x00\x00\x00\x00\x81\x30\x00\x00\x00\x00\x00\x01\x00\x00"
				append replace "\x00\x00\x00\x00\x00\x01\x04\x80\x00\x00\x00\x00\x00\x01\xd0\x00"
				set offset 240
				set mask 0				
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

				set search  "\x63\x2f\xeb\x68\x7f\x45\x4c\x46\x02\x02\x01\x66\x00\x00\x00\x00\x00\x00\x00\x00"
				append search "\x00\x02\x00\x15\x00\x00\x00\x01\x00\x00\x00\x00\xc0\x00\x29\x78\x00\x00\x00\x00"
				append search "\x00\x00\x00\x40\x00\x00\x00\x00\x00\x03\x87\x50\x00\x00\x00\x00\x00\x40\x00\x38"
				append search "\x00\x02\x00\x40\x00\x0c\x00\x0b\x00\x00\x00\x01\x00\x00\x00\x07\x00\x00\x00\x00"
				append search "\x00\x01\x00\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00\x00\x00\x80\x00\x00\x00"
				append search "\x00\x00\x00\x00\x00\x01\xc0\x80\x00\x00\x00\x00\x00\x01\xc0\x80"
				set replace  "\x00\x00\x00\x00\x00\x01\xd0\x00\x00\x00\x00\x00\x00\x01\xd0\x00"
				set offset 100
				set mask 0				
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

				set search  "\x00\x00\x00\x27\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00"
				append search "\x80\x01\xb3\x90\x00\x00\x00\x00\x00\x02\xb3\x90\x00\x00\x00\x00\x00\x00\x0c\xf0"
				set replace  "\x00\x00\x00\x00\x00\x00\x1c\x70"
				set offset 32
				set mask 0				
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

				set search  "\x00\x00\x00\x00\xc0\x00\x5c\xd8\x00\x00\x00\x00\xc0\x00\x5c\xc0\x00\x00\x00\x00"
				append search "\xc0\x00\x5c\xa8\x00\x00\x00\x00\xc0\x00\x5c\x90\x00\x00\x00\x00\xc0\x00\x5b\x88"
				append search "\x00\x00\x00\x00\xc0\x00\x5b\x70\x00\x00\x00\x00\xc0\x00\x5c\xf0\x00\x00\x00\x00"
				append search "\xc0\x00\x4d\x48\x00\x00\x00\x00\xc0\x00\x4d\x60\x00\x00\x00\x00\xc0\x00\x5a\xc8"
				append search "\x00\x00\x00\x00\xc0\x00\x4d\x78\x00\x00\x00\x00\xc0\x00\x4e\x38"

				set replace  "\xf8\x21\xff\x01\x7c\x08\x02\xa6\xf8\x01\x01\x10\xfb\x21\x00\xf8\xfb\x41\x00\xf0"
				append replace "\xfb\x61\x00\xe8\xfb\x81\x00\xe0\xfb\xa1\x00\xd8\xfb\xc1\x00\xd0\xfb\xe1\x00\xc8"
				append replace "\xf8\x61\x00\xc0\xf8\x81\x00\xb8\xf8\xa1\x00\xb0\x48\x00\x00\x05\x7f\xe8\x02\xa6"
				append replace "\x3b\xff\xff\xc8\xe8\x1f\x04\xb0\xf8\x01\x00\x88\xe8\x1f\x04\xb8\xf8\x01\x00\x90"
				append replace "\xe8\x1f\x04\xc0\xf8\x01\x00\x98\xe8\x1f\x04\xc8\xf8\x01\x00\xa0\x38\x00\x00\x00"
				append replace "\xf8\x01\x00\x78\xf8\x01\x00\x80\x38\x60\x00\x01\x38\x81\x00\x88\x38\xa1\x00\x78"
				append replace "\x3b\xc0\x00\x00\x67\xde\x80\x01\x63\xde\x2f\xd0\x7f\xc9\x03\xa6\x4e\x80\x04\x21"
				append replace "\x2f\xa3\x00\x00\x40\x9e\x00\x18\xe8\x01\x00\x78\x78\x00\x06\x20\x2f\x80\x00\xff"
				append replace "\x3b\x60\x00\x0f\x40\x9e\x03\x6c\xe8\x1f\x04\xb0\xf8\x01\x00\x88\xe8\x1f\x04\xb8"
				append replace "\xf8\x01\x00\x90\xe8\x1f\x04\xd0\xf8\x01\x00\x98\xe8\x1f\x04\xd8\xf8\x01\x00\xa0"
				append replace "\x38\x00\x00\x00\xf8\x01\x00\x78\xf8\x01\x00\x80\x38\x60\x00\x01\x38\x81\x00\x88"
				append replace "\x38\xa1\x00\x78\x3b\xc0\x00\x00\x67\xde\x80\x01\x63\xde\x2f\xd0\x7f\xc9\x03\xa6"
				append replace "\x4e\x80\x04\x21\x2f\xa3\x00\x00\x40\x9e\x00\x18\xe8\x01\x00\x78\x78\x00\x06\x20"
				append replace "\x2f\x80\x00\xff\x3b\x60\x00\x0f\x40\x9e\x03\x04\xe8\x1f\x04\xb0\xf8\x01\x00\x88"
				append replace "\xe8\x1f\x04\xb8\xf8\x01\x00\x90\xe8\x1f\x04\xe0\xf8\x01\x00\x98\xe8\x1f\x04\xd8"
				append replace "\xf8\x01\x00\xa0\x38\x00\x00\x00\xf8\x01\x00\x78\xf8\x01\x00\x80\x38\x60\x00\x01"
				append replace "\x38\x81\x00\x88\x38\xa1\x00\x78\x3b\xc0\x00\x00\x67\xde\x80\x01\x63\xde\x2f\xd0"
				append replace "\x7f\xc9\x03\xa6\x4e\x80\x04\x21\x2f\xa3\x00\x00\x40\x9e\x00\x18\xe8\x01\x00\x78"
				append replace "\x78\x00\x06\x20\x2f\x80\x00\xff\x3b\x60\x00\x0f\x40\x9e\x02\x9c\xe8\x1f\x04\xb0"
				append replace "\xf8\x01\x00\x88\xe8\x1f\x04\xb8\xf8\x01\x00\x90\xe8\x1f\x04\xe8\xf8\x01\x00\x98"
				append replace "\xe8\x1f\x04\xd8\xf8\x01\x00\xa0\x38\x00\x00\x00\xf8\x01\x00\x78\xf8\x01\x00\x80"
				append replace "\x38\x60\x00\x01\x38\x81\x00\x88\x38\xa1\x00\x78\x3b\xc0\x00\x00\x67\xde\x80\x01"
				append replace "\x63\xde\x2f\xd0\x7f\xc9\x03\xa6\x4e\x80\x04\x21\x2f\xa3\x00\x00\x40\x9e\x00\x18"
				append replace "\xe8\x01\x00\x78\x78\x00\x06\x20\x2f\x80\x00\xff\x3b\x60\x00\x0f\x40\x9e\x02\x34"
				append replace "\xe8\x61\x00\xb0\x38\x80\x00\x00\xeb\x5f\x04\x70\xeb\x9f\x04\x90\x7c\xba\xe2\x14"
				append replace "\x38\xc1\x00\xa8\x3b\xc0\x00\x00\x67\xde\x80\x00\x63\xde\x26\xb4\x7f\xc9\x03\xa6"
				append replace "\x4e\x80\x04\x21\x2f\x83\x00\x00\x7c\x7b\x1b\x78\x40\x9e\x01\xfc\xe8\x61\x00\xa8"
				append replace "\x38\x80\x00\x00\x7f\x85\xe3\x78\x3b\xc0\x00\x00\x67\xde\x80\x00\x63\xde\x02\x78"
				append replace "\x7f\xc9\x03\xa6\x4e\x80\x04\x21\x38\x7f\x04\x98\x38\x80\x00\x00\x3b\x60\x00\x10"
				append replace "\x3b\xc0\x00\x00\x67\xde\x80\x01\x63\xde\x3d\x40\x7f\xc9\x03\xa6\x4e\x80\x04\x21"
				append replace "\x2f\x83\x00\x00\x7c\x7d\x1b\x78\x41\x9c\x01\x94\x7f\xa3\x07\xb4\xe8\x81\x00\xa8"
				append replace "\x3b\x20\x08\x00\x7f\x25\xcb\x78\x3b\x60\x00\x10\x3b\xc0\x00\x00\x67\xde\x80\x01"
				append replace "\x63\xde\x3d\xb8\x7f\xc9\x03\xa6\x4e\x80\x04\x21\x7f\xa3\xc8\x00\x40\x9e\x01\x4c"
				append replace "\x3b\x60\x00\x14\x38\x7f\x04\x78\xe8\x81\x00\xa8\x38\xa0\x00\x10\x3b\xc0\x00\x00"
				append replace "\x67\xde\x80\x01\x63\xde\x39\xe0\x7f\xc9\x03\xa6\x4e\x80\x04\x21\x2f\xa3\x00\x00"
				append replace "\x40\x9e\x01\x20\xe8\xa1\x00\xa8\x83\x25\x00\x10\x2f\x99\x00\x01\x40\x9e\x01\x10"
				append replace "\xe8\xa1\x00\xa8\x83\x25\x00\x20\x2f\x99\x00\x00\x40\x9e\x01\x00\xe8\xa1\x00\xa8"
				append replace "\x83\x25\x02\x00\x2f\x99\x00\x00\x41\x9e\x00\xf0\xe8\xa1\x00\xa8\x83\x25\x00\x24"
				append replace "\x7f\xb9\xe0\x00\x41\x9d\x00\xe0\x7f\xa3\x07\xb4\xe8\x81\x00\xa8\x7f\x25\xcb\x78"
				append replace "\x3b\x60\x00\x10\x3b\xc0\x00\x00\x67\xde\x80\x01\x63\xde\x3d\xb8\x7f\xc9\x03\xa6"
				append replace "\x4e\x80\x04\x21\x7f\xa3\xc8\x00\x40\x9e\x00\xb4\xe8\x1f\x04\xf0\xf8\x01\x00\x88"
				append replace "\xe8\x1f\x04\xf8\xf8\x01\x00\x90\xe8\x1f\x05\x00\xf8\x01\x00\x98\xe8\x1f\x05\x08"
				append replace "\xf8\x01\x00\xa0\x38\x00\x00\x00\xf8\x01\x00\x78\xf8\x01\x00\x80\x38\x60\x00\x01"
				append replace "\x38\x81\x00\x88\x38\xa1\x00\x78\x3b\xc0\x00\x00\x67\xde\x80\x01\x63\xde\x2f\x88"
				append replace "\x7f\xc9\x03\xa6\x4e\x80\x04\x21\x38\x60\x00\x29\x3b\xc0\x00\x00\x67\xde\x80\x00"
				append replace "\x63\xde\x2c\xf0\x7f\xc9\x03\xa6\x4e\x80\x04\x21\x39\x20\x00\x00\x48\x00\x00\x14"
				append replace "\xe8\x01\x00\xa8\x7c\x09\x02\x14\x7c\x00\x00\x6c\x39\x29\x00\x80\x7f\xa9\xe0\x00"
				append replace "\x41\x9c\xff\xec\x7c\x00\x04\xac\x39\x20\x00\x00\x48\x00\x00\x14\xe8\x01\x00\xa8"
				append replace "\x7c\x09\x02\x14\x7c\x00\x07\xac\x39\x29\x00\x80\x7f\xa9\xe0\x00\x41\x9c\xff\xec"
				append replace "\x4c\x00\x01\x2c\x3b\x60\x00\x00\x7f\xa3\x07\xb4\x3b\xc0\x00\x00\x67\xde\x80\x01"
				append replace "\x63\xde\x3d\x7c\x7f\xc9\x03\xa6\x4e\x80\x04\x21\xe8\x61\x00\xa8\x7c\x9a\xe2\x14"
				append replace "\x3b\xc0\x00\x00\x67\xde\x80\x01\x63\xde\x3e\xb8\x7f\xc9\x03\xa6\x4e\x80\x04\x21"
				append replace "\x7b\x63\x00\x20\xe8\x01\x01\x10\xeb\x21\x00\xf8\xeb\x41\x00\xf0\xeb\x61\x00\xe8"
				append replace "\xeb\x81\x00\xe0\xeb\xa1\x00\xd8\xeb\xc1\x00\xd0\xeb\xe1\x00\xc8\x2f\x83\x00\x00"
				append replace "\x41\x9e\x00\x2c\xe8\x61\x00\xc0\xe8\x81\x00\xb8\xe8\xa1\x00\xb0\x38\x21\x01\x00"
				append replace "\x7c\x08\x03\xa6\x38\xc0\x00\x00\x64\xc6\x80\x00\x60\xc6\x0e\x44\x7c\xc9\x03\xa6"
				append replace "\x4e\x80\x04\x20\x38\x21\x01\x00\x7c\x08\x03\xa6\x4e\x80\x00\x20\x00\x00\x00\x00"
				append replace "\x00\x00\x00\x00\x63\x65\x6c\x6c\x5f\x65\x78\x74\x5f\x6f\x73\x5f\x61\x72\x65\x61"
				append replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x80\x00\x00\x2f\x64\x65\x76"
				append replace "\x2f\x72\x66\x6c\x61\x73\x68\x5f\x6c\x78\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
				append replace "\x00\x00\x00\x00\x73\x73\x00\x00\x70\x61\x72\x61\x6d\x00\x00\x00\x75\x70\x64\x61"
				append replace "\x74\x65\x00\x00\x73\x74\x61\x74\x75\x73\x00\x00\x70\x72\x6f\x64\x75\x63\x74\x00"
				append replace "\x6d\x6f\x64\x65\x00\x00\x00\x00\x72\x65\x63\x6f\x76\x65\x72\x00\x68\x64\x64\x63"
				append replace "\x6f\x70\x79\x00\x00\x00\x00\x00\x69\x6f\x73\x00\x61\x74\x61\x00\x00\x00\x00\x00"
				append replace "\x72\x65\x67\x69\x6f\x6e\x30\x00\x61\x63\x63\x65\x73\x73\x00\x00"
				set offset 96
				set mask 0				
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 

				set search  "\x88\x04\x00\x00\x2f\x80\x00\x00\x41\x9e\x01\x20\x2b\xa6\x00\x01\x40\x9d\x01\x18"
				append search "\x7c\xa4\x2b\x78\x7c\xc5\x33\x78\x48\x00\x03\xe1"
				set replace  "\x48\x01\xb6\x1d"
				set offset 28
				set mask 0				
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
			} else {
				log "SORRY, NO GENERIC OtherOS++ SUPPORT TASK FOR 4.XX YET"
			}
		}

		if {$::03_patch_oos::options(--patch-lv1-um-qa)} {
            log "Patching Update Manager to enable QA"

            set search  "\x88\x01\x01\x73\x7f\xc3\xf3\x78\x38\x80\x00\x01"
            set replace "\x38\x00\x00\xff"
			set offset 0
			set mask 0			
			# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"

            set search  "\x88\x01\x01\x67\x7f\xc3\xf3\x78\x38\x80\x00\x01"
            set replace "\x38\x00\x00\xff"
			set offset 0
			set mask 0			
			# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
        }

        if {$::03_patch_oos::options(--patch-lv1-ata-region0-access)} {
            log "Patching System Manager to allow access to all regions of all storage devices"

            set search  "\x98\x1f\x00\x00\x38\x00\x00\x01\xf9\x21\x00\x80"
			set replace "\x60\x00\x00\x00"
			set offset 28
			set mask 0			
			# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
        }

        # if {$::03_patch_oos::options(--patch-lv1-lv2mem)} {
            # log "Patching Hypervisor to remove LV2 memory protection"

            # set search  "\x2F\x83\x00\x3C\x40\x9E\x00\xCC"
			# set replace "\x60\x00\x00\x00"
			# set offset 12
			# set mask 0			
			# # PATCH THE ELF BINARY
				# catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
        # }
    }

    proc patch_emer {self} {
        ::modify_self_file $self ::03_patch_oos::emer_elf
    }
    proc emer_elf {elf} {
        set size $::03_patch_oos::options(--patch-gameos-hdd-region-size)
        set pup $::03_patch_oos::options(--patch-pup-search-in-game-disc)

		if {$::03_patch_oos::options(--fwtype) != "" && ($::03_patch_oos::options(--patch-gameos-hdd-region-size) != "" || $::03_patch_oos::options(--patch-pup-search-in-game-disc))} {

			if {$size != ""} {
				log "Patching [file tail $elf] to create GameOS HDD region of size $size smaller than default"
				if {${::NEWMFW_VER} < "4.20"} {
					set search    "\xE9\x21\x00\xA0\x79\x4A\x00\x20\xE9\x1B\x00\x00\x38\x00\x00\x00"
					append search "\x7D\x26\x48\x50\x7D\x49\x03\xA6\x39\x40\x00\x00\x38\xE9\xFF\xF8"
					set replace   "\x3C\xE9"
					set offset 28
				} else {
					set search    "\x7D\x26\x38\x50\xEB\x78\x00\x00\x3B\xA0\x00\x00\x3B\x49\xFF\xF8"
					append search "\x38\x00\x00\x00"
					set replace   "\x3F\x49"
					set offset 12
				}				
				if {[string equal ${size} "22GB"] == 1} {
					append replace "\xFD\x40"
				} elseif {[string equal ${size} "10GB"] == 1} {
					append replace "\xFE\xC0"
				}
				set mask 0				
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
			}

			if {$pup} {
				log "Patching [file tail $elf] to disable searching for update packages in GAME disc"
					set search  "\x80\x01\x00\x74\x2f\x80\x00\x00\x40\x9e\x00\x14"
					set replace "\x38\x00\x00\x01"
					set offset 0
					set mask 0				
						catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
			}
		}
    }
}
