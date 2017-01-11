#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Notes: Don't Try To Replace XML Files Unless You Know What You Are Doing..

# Created By RazorX

# Priority: 110
# Description: Replace XML Files


# Option --xml-game: category_game.xml
# Option --xml-friend: category_friend.xml
# Option --xml-music: category_music.xml
# Option --xml-network: category_network.xml
# Option --xml-photo: category_photo.xml
# Option --xml-psn: category_psn.xml
# Option --xml-sysconf: category_sysconf.xml
# Option --xml-tv: category_tv.xml
# Option --xml-user: category_user.xml
# Option --xml-user-login: category_user_login.xml
# Option --xml-video: category_video.xml
# Option --xml-ps2: category_game_tool2.xml

# Type --xml-game: file open {"xml file" {xml}}
# Type --xml-friend: file open {"xml file" {xml}}
# Type --xml-music: file open {"xml file" {xml}}
# Type --xml-network: file open {"xml file" {xml}}
# Type --xml-photo: file open {"xml file" {xml}}
# Type --xml-psn: file open {"xml file" {xml}}
# Type --xml-sysconf: file open {"xml file" {xml}}
# Type --xml-tv: file open {"xml file" {xml}}
# Type --xml-user: file open {"xml file" {xml}}
# Type --xml-user-login: file open {"xml file" {xml}}
# Type --xml-video: file open {"xml file" {xml}}
# Type --xml-ps2: file open {"xml file" {xml}}

namespace eval 12_change_xml_files {

    array set ::12_change_xml_files::options {
	
        --xml-game "/path/to/file"
		--xml-friend "/path/to/file"
		--xml-music "/path/to/file"
		--xml-network "/path/to/file"
		--xml-photo "/path/to/file"
		--xml-psn "/path/to/file"
        --xml-sysconf "/path/to/file"
        --xml-tv "/path/to/file"
        --xml-user "/path/to/file"
        --xml-user-login "/path/to/file"
        --xml-video "/path/to/file"	
		--xml-ps2 "/path/to/file"
    }

    proc main {} {
        variable options

        set xml_game [file join dev_flash vsh resource explore xmb category_game.xml]
		set xml_friend [file join dev_flash vsh resource explore xmb category_friend.xml]
		set xml_music [file join dev_flash vsh resource explore xmb category_music.xml]
		set xml_network [file join dev_flash vsh resource explore xmb category_network.xml]
		set xml_photo [file join dev_flash vsh resource explore xmb category_photo.xml]
		set xml_psn [file join dev_flash vsh resource explore xmb category_psn.xml]
        set xml_sysconf [file join dev_flash vsh resource explore xmb category_sysconf.xml]
		set xml_tv [file join dev_flash vsh resource explore xmb category_tv.xml]
		set xml_user [file join dev_flash vsh resource explore xmb category_user.xml]
		set xml_user_login [file join dev_flash vsh resource explore xmb category_user_login.xml]
		set xml_video [file join dev_flash vsh resource explore xmb category_video.xml]
		set xml_ps2 [file join dev_flash vsh resource explore xmb category_game_tool2.xml]

        if {[file exists $options(--xml-game)] == 0 } {
            log "Skipping xml_game, $options(--xml-game) does not exist"
        } else {
            ::modify_devflash_file ${xml_game} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-game)
        }
		
		if {[file exists $options(--xml-friend)] == 0 } {
            log "Skipping xml_friend, $options(--xml-friend) does not exist"
        } else {
            ::modify_devflash_file ${xml_friend} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-friend)
        }
		
		if {[file exists $options(--xml-music)] == 0 } {
            log "Skipping xml_music, $options(--xml-music) does not exist"
        } else {
            ::modify_devflash_file ${xml_music} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-music)
        }
		
		if {[file exists $options(--xml-network)] == 0 } {
            log "Skipping xml_network, $options(--xml-network) does not exist"
        } else {
            ::modify_devflash_file ${xml_network} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-network)
        }
		
		if {[file exists $options(--xml-photo)] == 0 } {
            log "Skipping xml_photo, $options(--xml-photo) does not exist"
        } else {
            ::modify_devflash_file ${xml_photo} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-photo)
        }
		
		if {[file exists $options(--xml-psn)] == 0 } {
            log "Skipping xml_psn, $options(--xml-psn) does not exist"
        } else {
            ::modify_devflash_file ${xml_psn} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-psn)
        }

        if {[file exists $options(--xml-sysconf)] == 0 } {
            log "Skipping xml_sysconf, $options(--xml-sysconf) does not exist"
        } else {
            ::modify_devflash_file ${xml_sysconf} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-sysconf)
        }
		
		if {[file exists $options(--xml-tv)] == 0 } {
            log "Skipping xml_tv, $options(--xml-tv) does not exist"
        } else {
            ::modify_devflash_file ${xml_tv} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-tv)
        }
		
		if {[file exists $options(--xml-user)] == 0 } {
            log "Skipping xml_user, $options(--xml-user) does not exist"
        } else {
            ::modify_devflash_file ${xml_user} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-user)
        }

		if {[file exists $options(--xml-user-login)] == 0 } {
            log "Skipping xml_user_login, $options(--xml-user-login) does not exist"
        } else {
            ::modify_devflash_file ${xml_user_login} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-user-login)
        }

		if {[file exists $options(--xml-video)] == 0 } {
            log "Skipping xml_video, $options(--xml-video) does not exist"
        } else {
            ::modify_devflash_file ${xml_video} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-video)
        }
		
		if {[file exists $options(--xml-ps2)] == 0 } {
            log "Skipping xml_ps2, $options(--xml-ps2) does not exist"
        } else {
            ::modify_devflash_file ${xml_ps2} ::12_change_xml_files::copy_xml_file $::12_change_xml_files::options(--xml-ps2)
        }
    }

    proc copy_xml_file { dst src } {
        if {[file exists $src] == 0} {
            die "$src does not exist"
        } else {
            if {[file exists $dst] == 0} {
                die "$dst does not exist"
            } else {
                log "Replacing default xml file [file tail $dst] with [file tail $src]"
                copy_file -force $src $dst
            }
        }
    }
}
