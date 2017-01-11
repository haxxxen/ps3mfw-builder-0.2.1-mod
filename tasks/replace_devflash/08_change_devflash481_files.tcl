#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
 
# Priority: 50
# Description: Change files in devflash manually

# Option --change-filenames: Filenames to change (must start with 'dev_flash/')

# Type --change-filenames: textarea


namespace eval 08_change_devflash481_files {

    array set ::08_change_devflash481_files::options {
        --change-filenames "dev_flash/data/font/SCE-PS3-NR-L-JPN.TTF
dev_flash/data/font/SCE-PS3-DH-R-CGB.TTF
dev_flash/data/font/SCE-PS3-CP-R-KANA.TTF
dev_flash/data/font/SCE-PS3-MT-R-LATIN.TTF
dev_flash/vsh/etc/index.dat
dev_flash/data/cert/CA01.cer
dev_flash/ps2emu/ps2_gxemu.self
dev_flash/vsh/module/autodownload_plugin.sprx
dev_flash/vsh/module/audioplayer_plugin_mini.sprx
dev_flash/vsh/module/bdp_plugin.sprx
dev_flash/vsh/module/avc2_game_plugin.sprx
dev_flash/vsh/module/audioplayer_plugin.sprx
dev_flash/vsh/module/comboplay_plugin.sprx
dev_flash/vsh/module/avc_util.sprx
dev_flash/vsh/resource/audioplayer_plugin_mini.rco
dev_flash/vsh/resource/audioplayer_plugin_util.rco
dev_flash/vsh/resource/audioplayer_plugin.rco
dev_flash/sys/internal/eurus_fw.bin
dev_flash/sys/external/flashATRAC.pic
dev_flash/ps1emu/ps1_emu.self
dev_flash/bdplayer/CprmModule.spu.isoself
dev_flash/bdplayer/AacsModule.spu.isoself
dev_flash/bdplayer/bdp_BDMV.self
dev_flash/vsh/module/vsh.self.swp"
    }

    proc main {} {
        variable options
        foreach file [split $options(--change-filenames) "\n"] {
            if {[string equal -length 14 "dev_flash/path" ${file}] != 1} {
                if {[string equal -length 10 "dev_flash/" ${file}] == 1} {
                    ::modify_devflash_file ${file} ::08_change_devflash481_files::change_file
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
