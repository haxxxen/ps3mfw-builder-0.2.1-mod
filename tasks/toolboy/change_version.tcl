#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 0201
# Description: CHANGE: Change PUP version info

# Option --version-string: If set, overrides the entire PUP version string
# Option --version-prefix: Prefix to add to the PUP version string
# Option --version-suffix: Suffix to add to the PUP version string

# Type --version-string: string
# Type --version-prefix: string
# Type --version-suffix: string
    
namespace eval ::change_version {

    array set ::change_version::options {     
      --version-string ""
      --version-prefix ""
      --version-suffix "-CFW v1.00"
    }

    proc main {} {
      variable options

      log "Changing PUP version.txt file"
      if {$options(--version-string) != ""} {
        ::modify_pup_version_file $options(--version-string) "" 1
      } else {
        ::modify_pup_version_file $options(--version-prefix) $options(--version-suffix) 0
      }
    }
}

