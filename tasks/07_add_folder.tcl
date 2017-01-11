#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 60
# Description: Add folder To Firmware


# Option --folder-enable-00: Add (empty!) folder to main folder structure
# Option --file-loc: Custom Path1 /dev_flash/

# Type --folder-enable-00: boolean
# Type --file-loc: string

namespace eval 07_add_folder {

    array set ::07_add_folder::options {
	
		--folder-enable-00 true
		--file-loc "rebug/packages/PS3_GAME/USRDIR/img"
    }

    proc main {} {
        variable options
		if {$::07_add_folder::options(--folder-enable-00)} {
			set pkg [glob -nocomplain [file join ${::CUSTOM_UPDATE_DIR} dev_flash_000.*]]
			set unpkgdir [file join ${::CUSTOM_UPDATE_DIR} ${pkg}.unpkg]
			::unpkg_archive $pkg $unpkgdir
			set tar [file join $unpkgdir content]
			set unpkgdir2 [file join ${::CUSTOM_PUP_DIR}]
			extract_tar $tar $unpkgdir2
			file mkdir [file join ${::CUSTOM_PUP_DIR} dev_flash $::07_add_folder::options(--file-loc)]
			file delete -force $tar
			# ::create_tar_content $tar ${::CUSTOM_PUP_DIR} dev_flash
			if {${::NEWMFW_VER} >= ${::OFW_2NDGEN_BASE}} {    
				if {$::options(--4XX-CEX)} {
					::create_cex_tar4_000 $tar ${::CUSTOM_PUP_DIR} dev_flash
				} elseif {$::options(--4XX-DEX)} {
					::create_dex_tar4_000 $tar ${::CUSTOM_PUP_DIR} dev_flash
				}
			} else {
				if {$::options(--341-CEX)} {
					::create_cex_tar341_000 $tar ${::CUSTOM_PUP_DIR} dev_flash
				} elseif {$::options(--355-CEX)} {
					::create_cex_tar355_000 $tar ${::CUSTOM_PUP_DIR} dev_flash
				} elseif {$::options(--3XX-DEX)} {
					::create_dex_tar3_000 $tar ${::CUSTOM_PUP_DIR} dev_flash
				}
			}
			set pkg2 [file join ${::CUSTOM_UPDATE_DIR} ${pkg}.pkg]
			pkg_archive $unpkgdir $pkg2
			file delete -force $pkg
			file rename -force $pkg2 $pkg
			file delete -force $unpkgdir
			set pkg2 [glob -nocomplain [file join ${::CUSTOM_UPDATE_DIR} dev_flash_000.*]]
			set unpkgdir3 [glob -nocomplain [file join ${::CUSTOM_UPDATE_DIR} dev_flash dev_flash_000.*]]
			::unpkg_archive $pkg $unpkgdir3
			set tar2 [file join ${unpkgdir3} content]
			set unpkgdir4 [file join ${::CUSTOM_UPDATE_DIR} dev_flash dev_flash]
			extract_tar $tar2 $unpkgdir4
			file delete -force [file join ${::CUSTOM_PUP_DIR} dev_flash]
			if {${::NEWMFW_VER} >= ${::OFW_2NDGEN_BASE}} {    
				::pkg_spkg_archive $unpkgdir3 $pkg
				::copy_spkg
			} else {
				::pkg_archive $unpkgdir3 $pkg
			}
		}
	}
}
