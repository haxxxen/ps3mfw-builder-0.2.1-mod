#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 0000
# Description: REQ'D - **Set PUP build and/or version info**

# Option --enable-spoof-build: [3.xx/4.xx]  -->  Enable setting PUP build version (FW Spoofing)
# Option --spoof-build-number:	[3.xx/4.xx] ---->  PUP build version to set
# Option --version-string: If set, overrides the entire PUP version string
# Option --version-prefix: Prefix to add to the PUP version string
# Option --version-suffix: Suffix to add to the PUP version string

# Type --enable-spoof-build: boolean
# Type --spoof-build-custom: combobox { }
# Type --version-string: string
# Type --version-prefix: string
# Type --version-suffix: string
    
namespace eval ::patch_version {

    array set ::patch_version::options {  
	  --enable-spoof-build true
	  --spoof-build-number "99999"
      --version-string ""
      --version-prefix ""
      --version-suffix "-CFW v1.00"
    }

	proc main {} {
		variable options
		  
		 # setup vars based on the spoof string
		if {$::patch_version::options(--enable-spoof-build)} {
			set org_build ""
			set new_build ""
			log "Changing PUP build version, patching UPL.xml........"
						
			set org_build ${::PUP_BUILD}
			set new_build $::patch_version::options(--spoof-build-number)	
			
			# go patch the UPL.xml file
			::modify_upl_file ::change_build_upl_xml $new_build			
		}
		
		# make any changes to the 'version.txt' file
		log "Changing PUP version.txt file"
		if {$::patch_version::options(--version-string) != ""} {
			::modify_pup_version_file $::patch_version::options(--version-string) "" 1
		} else {
			::modify_pup_version_file $::patch_version::options(--version-prefix) $::patch_version::options(--version-suffix) 0
		}
	}
}

