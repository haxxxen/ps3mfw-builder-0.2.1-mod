#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 1
# Description: Change specific file(s) in COREOS manually

# Option --change-coreos-files: Replace ANY COREOS file(s)

# Type --change-coreos-files: boolean

namespace eval 01_change_cos_files {
    array set ::01_change_cos_files::options {
        --change-coreos-files true
    }
    proc main {} {
		log "WARNING: Playing with COREOS Files only on your own Risk and NOT WITHOUT Flasher !!!" 1
        variable options
        if {$::01_change_cos_files::options(--change-coreos-files)} {
			set coreos "creserved_0"
				::modify_coreos_file $coreos ::01_change_cos_files::change_file
		}
	}
	proc change_file { file } {
        log "The file to change is in ${::CUSTOM_UPDATE_DIR} CORE_OS_PACKAGE"
        if {[package provide Tk] != "" } {
           tk_messageBox -default ok -message "Change the file '${file}' then press ok to continue" -icon warning
        } else {
           puts "Press \[RETURN\] or \[ENTER\] to continue"
           gets stdin
        }
    }
}
