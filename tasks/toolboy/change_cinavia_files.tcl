#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Notes: videoplayer_util.sprx, videoplayer_plugin.sprx and videoeditor_plugin.sprx
#        have Cinavia DRM checks. These checks are disabled in DEX firmware so these 
#        files can be replaced by those from the equivalent DEX firmware or if they
#        have been manually patched. 
#        TODO: bdp_plugin.sprx also contains checks but BD playback is disabled on 
#        DEX firmware so this file is not included in DEX firmware. This means that 
#        DNLA copy/playback won't have any Cinavia checks done on it but a copied BD 
#        playback will still check for Cinavia and mute the audio (Message Code 3) 
#        until DEX firmware with a bdp_plugin.sprx is released or someone patches 
#        this file manually.

# Priority: 204
# Description: CHANGE: Change Cinavia DRM affected files

# Option --cinavia-videoplayerutil: Patched videoplayer_util.sprx filename
# Option --cinavia-videoplayerplugin: Patched videoplayer_plugin.sprx filename
# Option --cinavia-videoeditorplugin: Patched videoeditor_plugin.sprx filename
# Option --cinavia-bdpplugin: Patched bdp_plugin.sprx filename

# Type --cinavia-videoplayerutil: file open {"SPRX library" {sprx}}
# Type --cinavia-videoplayerplugin: file open {"SPRX library" {sprx}}
# Type --cinavia-videoeditorplugin: file open {"SPRX library" {sprx}}
# Type --cinavia-bdpplugin: file open {"SPRX library" {sprx}}

namespace eval change_cinavia_files {

    array set ::change_cinavia_files::options {
        --cinavia-videoplayerutil "/path/to/videoplayer_util.sprx"
        --cinavia-videoplayerplugin "/path/to/videoplayer_plugin.sprx"
        --cinavia-videoeditorplugin "/path/to/videoeditor_plugin.sprx"
        --cinavia-bdpplugin "/path/to/bdp_plugin.sprx"
    }

    proc main {} {
        variable options

        set cinavia_videoplayerutil [file join dev_flash vsh module videoplayer_util.sprx]
        set cinavia_videoplayerplugin [file join dev_flash vsh module videoplayer_plugin.sprx]
        set cinavia_videoeditorplugin [file join dev_flash vsh module videoeditor_plugin.sprx]
        set cinavia_bdpplugin [file join dev_flash vsh module bdp_plugin.sprx]

        if {[file exists $options(--cinavia-videoplayerutil)] == 0 } {
            log "Skipping videoplayer_util.sprx, $options(--cinavia-videoplayerutil) does not exist"
        } else {
            ::modify_devflash_file ${cinavia_videoplayerutil} ::change_cinavia_files::copy_cinavia_file $::change_cinavia_files::options(--cinavia-videoplayerutil)
        }

        if {[file exists $options(--cinavia-videoplayerplugin)] == 0 } {
            log "Skipping cinavia_videoplayerplugin, $options(--cinavia-videoplayerplugin) does not exist"
        } else {
            ::modify_devflash_file ${cinavia_videoplayerplugin} ::change_cinavia_files::copy_cinavia_file $::change_cinavia_files::options(--cinavia-videoplayerplugin)
        }

        if {[file exists $options(--cinavia-videoeditorplugin)] == 0 } {
            log "Skipping cinavia_videoeditorplugin, $options(--cinavia-videoeditorplugin) does not exist"
        } else {
            ::modify_devflash_file ${cinavia_videoeditorplugin} ::change_cinavia_files::copy_cinavia_file $::change_cinavia_files::options(--cinavia-videoeditorplugin)
        }
        
        # TODO: no known bdp_plugin.sprx patch yet
        if {[file exists $options(--cinavia-bdpplugin)] == 0 } {
            log "Skipping cinavia_bdpplugin, $options(--cinavia-bdpplugin) does not exist"
        } else {
            ::modify_devflash_file ${cinavia_bdpplugin} ::change_cinavia_files::copy_cinavia_file $::change_cinavia_files::options(--cinavia-bdpplugin)
        }
    }

    proc copy_cinavia_file { dst src } {
        if {[file exists $src] == 0} {
            die "$src does not exist"
        } else {
            if {[file exists $dst] == 0} {
                die "$dst does not exist"
            } else {
                log "Replacing default file [file tail $dst] with patched [file tail $src]"
                copy_file -force $src $dst
            }
        }
    }
}
