#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 9999
# Description: Repair REBUG COBRA stage2 HASHES

# Option --repair-hashes: Patch REBUG's stage2 files with new hashes

# Type --repair-hashes: boolean

namespace eval ::15_repair_hashes {

    array set ::15_repair_hashes::options {
      --repair-hashes true
    }

    proc main {} {
		variable options
		file mkdir ${::HASH_DIR}
		set ORI_DIR [file join ${::CUSTOM_TEMPLAT_DIR} ${::NEWMFW_VER}]

		set module1 "basic_plugins.sprx"
		set hashorig1 [file join $ORI_DIR $module1.orig]
		copy_file -force $hashorig1 ${::HASH_DIR}
			::modify_devflash_files [file join dev_flash vsh module] $module1 ::15_repair_hashes::copy_hash
		set st2 ${::ST2RBG}
			::modify_devflash_files [file join dev_flash] $st2 ::15_repair_hashes::patch_st2
		file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.orig]]
		file delete -force [file join $ORI_DIR $module1.orig]
		file copy -force [file join ${::HASH_DIR} $module1.log] [file join $ORI_DIR $module1.orig]
		file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.log]]

		if {${::NEWMFW_VER} > "4.21"} {
			set module2 "game_ext_plugin.sprx"
			set hashorig2 [file join $ORI_DIR $module2.orig]
			copy_file -force $hashorig2 ${::HASH_DIR}
				::modify_devflash_files [file join dev_flash vsh module] $module2 ::15_repair_hashes::copy_hash
			set st2 ${::ST2RBG}
				::modify_devflash_files [file join dev_flash] $st2 ::15_repair_hashes::patch_st2
			file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.orig]]
			file delete -force [file join $ORI_DIR $module2.orig]
			file copy -force [file join ${::HASH_DIR} $module2.log] [file join $ORI_DIR $module2.orig]
			file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.log]]
		}

		set module3 "vsh.self"
		set hashorig3 [file join $ORI_DIR $module3.orig]
		copy_file -force $hashorig3 ${::HASH_DIR}
			::modify_devflash_files [file join dev_flash vsh module] $module3 ::15_repair_hashes::copy_hash
		set st2 ${::ST2RBG}
			::modify_devflash_files [file join dev_flash] $st2 ::15_repair_hashes::patch_st2
		file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.orig]]
		file delete -force [file join $ORI_DIR $module3.orig]
		file copy -force [file join ${::HASH_DIR} $module3.log] [file join $ORI_DIR $module3.orig]
		file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.log]]

		# set module3 "vsh.self.nrm"
		# set hashorig3 [file join $ORI_DIR $module3.orig]
		# copy_file -force $hashorig3 ${::HASH_DIR}
			# ::modify_devflash_files [file join dev_flash vsh module] $module3 ::15_repair_hashes::copy_hash
		# set st2 ${::ST2RBG}
			# ::modify_devflash_files [file join dev_flash] $st2 ::15_repair_hashes::patch_st2
		# file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.orig]]
		# file delete -force [file join $ORI_DIR $module3.orig]
		# file copy -force [file join ${::HASH_DIR} $module3.log] [file join $ORI_DIR $module3.orig]
		# file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.log]]

		set module4 "vsh.self.cexsp"
		set hashorig4 [file join $ORI_DIR $module4.orig]
		copy_file -force $hashorig4 ${::HASH_DIR}
			::modify_devflash_files [file join dev_flash vsh module] $module4 ::15_repair_hashes::copy_hash
		set st2 ${::ST2RBG}
			::modify_devflash_files [file join dev_flash] $st2 ::15_repair_hashes::patch_st2
		file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.orig]]
		file delete -force [file join $ORI_DIR $module4.orig]
		file copy -force [file join ${::HASH_DIR} $module4.log] [file join $ORI_DIR $module4.orig]
		file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.log]]

		set module5 "vsh.self.swp"
		if {${::NEWMFW_VER} > "4.21"} {
			file delete -force [file join $ORI_DIR $module5.orig]
			file copy -force [file join $ORI_DIR $module3.orig] [file join $ORI_DIR $module5.orig]
		}
		set hashorig5 [file join $ORI_DIR $module5.orig]
		copy_file -force $hashorig5 ${::HASH_DIR}
			::modify_devflash_files [file join dev_flash vsh module] $module5 ::15_repair_hashes::copy_hash
		set st2 ${::ST2RBG}
			::modify_devflash_files [file join dev_flash] $st2 ::15_repair_hashes::patch_st2
		file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.orig]]
		file delete -force [file join $ORI_DIR $module5.orig]
		file copy -force [file join ${::HASH_DIR} $module5.log] [file join $ORI_DIR $module5.orig]
		file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.log]]

		# set module5 "vsh.self"
		# set hashorig5 [file join $ORI_DIR $module5.orig]
		# copy_file -force $hashorig5 ${::HASH_DIR}
			# ::modify_devflash_files [file join dev_flash vsh module] $module5 ::15_repair_hashes::copy_hash
		# set st2 ${::ST2RBG}
			# ::modify_devflash_files [file join dev_flash] $st2 ::15_repair_hashes::patch_st2
		# file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.orig]]
		# file delete -force [file join $ORI_DIR $module5.orig]
		# file copy -force [file join ${::HASH_DIR} $module5.log] [file join $ORI_DIR $module5.orig]
		# file delete -force [glob -nocomplain [file join ${::HASH_DIR} *.log]]
    }

	proc copy_hash {self} {
		log "Exporting $self NEW HASH" 1
			::export_hash $self
		set hash $self.log
		copy_file -force $hash ${::HASH_DIR}
		if {[file exists [file join $hash]]} {
			debug "removing $hash from working dir"
			delete_file -force $hash
		}
	}

	proc patch_st2 {elf} {
		log "Patching [file tail $elf] with NEW HASHES"
		set hashorig [glob -nocomplain [file join ${::HASH_DIR} *.orig]]
		set newlog [glob -nocomplain [file join ${::HASH_DIR} *.log]]

		set fp [open [file join $hashorig] r]
		set search_data [read $fp]
		puts $search_data
		log "Reading [file tail $hashorig] ORIGINAL HASH : $search_data" 1
		set search $search_data
		close $fp

		set fp [open [file join $newlog] r]
		set replace_data [read $fp]
		puts $replace_data
		log "Patching [file tail $newlog] NEW HASH : $replace_data" 1
		close $fp
		set replace $replace_data

			shell ${::PATCHTOOL} -action patch -filename $elf -search $search -replace $replace -offset 0 -multi yes -debug yes
	}
}

