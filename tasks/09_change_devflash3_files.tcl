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
# Description: Change files in devflash3 manually	[SELECT DEVFLASH3 EXTRACT OPTION]

# Option --change-filenames: Filenames to change (must start with 'dev_flash3/')

# Type --change-filenames: 


namespace eval 09_change_devflash3_files {

    array set ::09_change_devflash3_files::options {
        --change-filenames "dev_flash3/data-revoke/crl/CRL1"
    }

    proc main {} {
        variable options
        foreach file [split $options(--change-filenames) "\n"] {
            if {[string equal -length 15 "dev_flash3/path" ${file}] != 1} {
                if {[string equal -length 11 "dev_flash3/" ${file}] == 1} {
                    ::modify_devflash3_file ${file} ::09_change_devflash3_files::change_file
                }
            }
        }
    }

    proc change_file { file } {
        log "The file to change is in ${file}"
        if {[package provide Tk] != "" } {
           tk_messageBox -default ok -message "Change the file '${file}' then press ok to continue" -icon warning
        } else {
           puts "Press \[RETURN\] or \[ENTER\] to continue"
           gets stdin
        }
    }
}
