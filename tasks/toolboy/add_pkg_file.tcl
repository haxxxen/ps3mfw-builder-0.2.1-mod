#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Notes: Don't Try To Use This Without The Modified OFW Firmware..

# Created By RazorX

# Priority: 202
# Description: CHANGE: Add Package File(s) To Custom Firmware


# Option --pkg-label::
# Option --pkg-label1::
# Option --pkg-label2::
# Option --pkg-label3::
# Option --pkg-label4::
# Option --pkg-label5::
# Option --pkg-src: Select Package File
# Option --pkg-src2: Select Package File
# Option --pkg-src3: Select Package File
# Option --pkg-src4: Select Package File
# Option --pkg-src5: Select Package File
# Option --pkg-label6::

# Type --pkg-label: label {PKG Section}
# Type --pkg-label1: label {Space}
# Type --pkg-label2: label {Warning}
# Type --pkg-label3: label {Warning}
# Type --pkg-label4: label {Warning}
# Type --pkg-label5: label {Space}
# Type --pkg-src: file open {"Package File" {pkg}}
# Type --pkg-src2: file open {"Package File" {pkg}}
# Type --pkg-src3: file open {"Package File" {pkg}}
# Type --pkg-src4: file open {"Package File" {pkg}}
# Type --pkg-src5: file open {"Package File" {pkg}}
# Type --pkg-label6: label {PKG Section}

namespace eval add_pkg_file {

    array set ::add_pkg_file::options {
	
		--pkg-label "---------------------------------- Welcome To The PKG Section --------------------------------   : :"
		--pkg-label1 "                                                                                                                                                    : :"
		--pkg-label2 "    Please Dont Try This With Any Other Original Firmware But OFW-MOD.PUP        : :"
		--pkg-label3 "                        Created By RazorX Or It Wont Work And Preferably Only                        : :"
		--pkg-label4 "              Add Package File(s) Below Or 1MB Depending On Nand/Nor Size...            : :"
		--pkg-label5 "                                                                                                                                                   : :"
		--pkg-src "/path/to/file"
		--pkg-src2 "/path/to/file"
		--pkg-src3 "/path/to/file"
		--pkg-src4 "/path/to/file"
		--pkg-src5 "/path/to/file"
		--pkg-label6 "--------------------------------------------------------------------------------------------------------------   : :"
    }

    proc main {} {
        variable options
		
		set src $options(--pkg-src)
		set src2 $options(--pkg-src5)
		set dst [file join dev_flash PS3Ultimate Packages]

		if {[file exists $options(--pkg-src)] == 0} {
            log "Skipping $options(--pkg-src) does not exist"
        } else {
		        log "Adding $src to CFW (/dev_flash/PS3Ultimate/Packages)"
				log "Please install through Package Manager or Install Package Files"
		::modify_devflash_file $dst ::add_pkg_file::copy_devflash_file $src
		}
	
		if {[file exists $options(--pkg-src5)] == 0} {
            log "Skipping $options(--pkg-src2) does not exist"
        } else {
				log "Adding $src2 to CFW (/dev_flash/PS3Ultimate/Packages)"
				log "Please install through Package Manager or Install Package Files"
		::modify_devflash_file $dst ::add_pkg_file::copy_devflash_file $src2
		}
    }

    proc copy_devflash_file { dst src } {
        if {[file exists $src] == 0} {
            die "$src does not exist"
        } else {
            if {[file exists $dst] == 0} {
                die "$dst does not exist"
            } else {
                copy_file -force $src $dst
            }
        }
    }
}
