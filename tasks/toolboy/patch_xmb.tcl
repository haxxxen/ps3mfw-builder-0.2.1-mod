#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 0004
# Description: PATCH: XMB - Miscellaneous

# Option --patch-package-files: [3.xx/4.xx]  -->  Add "Install Package Files" icon to the XMB Game Category    
# Option --patch-app-home: [3.xx/4.xx]  -->  Add "/app_home" icon to the XMB Game Category
# Option --patch-ren-apphome: [3.xx/4.xx]  -->  Rename /app_home/PS3_GAME/ to Discless
# Option --add-install-pkg: [3.xx/4.xx]  -->  Add the standard Install Package Files Segment to the HomeBrew Category in XMB
# Option --add-pkg-mgr: [3.xx/4.xx]  -->  Add MFW PKG Manager Segment to the HomeBrew Category in XMB
# Option --add-hb-seg: [3.xx/4.xx]  -->  Add MFW HomeBrew Segment to the HomeBrew Category in XMB
# Option --add-emu-seg: [3.xx/4.xx]  -->  Add MFW Emulator Segment to the HomeBrew Category in XMB
# Option --homebrew-cat: [3.xx/4.xx]  -->  Specify new HomeBrew category manually (Do not use with options above!!)
# Option --patch-alpha-sort: [3.xx/4.xx]  -->  Alphabetical sort Order for Games in the XMB
# Option --patch-rape-sfo: [3.xx/4.xx]  -->  Rape the SFO Param's X0 (NeoGeo) and X4 (PCEngine) to use with the Homebrew category and custome segments
# Option --fix-typo-sysconf-Italian: [3.xx/4.xx]  -->  Fix a typo in the Italian localization of the sysconf plugin
# Option --tv-cat: [3.xx]  -->  Show TV category in xmb no matter if your country supports it. (3.55 ONLY)

# Type --patch-package-files: boolean
# Type --patch-app-home: boolean
# Type --patch-ren-apphome: boolean
# Type --add-install-pkg: boolean
# Type --add-pkg-mgr: boolean
# Type --add-hb-seg: boolean
# Type --add-emu-seg: boolean
# Type --homebrew-cat: combobox {{ } {Users} {Photo} {Music} {Video} {TV} {Game} {Network} {PlayStation® Network} {Friends}}
# Type --patch-alpha-sort: boolean
# Type --patch-rape-sfo: boolean
# Type --fix-typo-sysconf-Italian: boolean
# Type --tv-cat: boolean

namespace eval patch_xmb {
    
	set ::patch_xmb::pointer_xmb 0 
	set ::patch_xmb::CATEGORY_TV_XML ""
	set ::patch_xmb::XMB_PLUGIN ""
	set ::patch_xmb::SYSCONF_PLUGIN_RCO ""
	set ::patch_xmb::EXPLORE_PLUGIN_FULL_RCO ""
	set ::patch_xmb::XMB_INGAME_RCO ""
	set ::patch_xmb::REGISTORY_XML ""
	set ::patch_xmb::NET_CAT_XML ""
	set ::patch_xmb::CATEGORY_GAME_TOOL2_XML ""
	set ::patch_xmb::CATEGORY_GAME_XML ""
	set ::patch_xmb::PSN_CAT_XML ""
	set ::patch_xmb::TEMPLAT_MFW_XML ""
	set ::patch_xmb::ACTIVATE_IPF ""
	set ::patch_xmb::rapeo ""
	set ::patch_xmb::rapen ""
	set ::patch_xmb::embed ""
	set ::patch_xmb::hermes_enabled false
	set ::patch_xmb::flag_icons_copied false
		
    array set ::patch_xmb::options {		
		--patch-package-files true
		--patch-app-home true
        --patch-ren-apphome false
        --add-install-pkg false		
        --add-pkg-mgr false
        --add-hb-seg false
        --add-emu-seg false
        --homebrew-cat ""                
        --patch-alpha-sort false
        --patch-rape-sfo false
        --fix-typo-sysconf-Italian false
        --tv-cat false
    }
    
    proc main {} {        
		## ---------------------- SET 'EXTERNALS' HERE ------------------
		## first see if "customize_firmware" task is even selected, if so,
		## set the "embed" param to the embedded app
		set ::patch_xmb::embed ""
		set ::patch_xmb::hermes_enabled false
		if {[info exists ::customize_firmware::options(--customize-embedded-app)]} {
			set ::patch_xmb::embed ${::customize_firmware::options(--customize-embedded-app)} }		
		if {[info exists ::patch_cos::options(--patch-lv2-payload-hermes-4x)]} {
			set ::patch_xmb::hermes_enabled $::patch_cos::options(--patch-lv2-payload-hermes-4x) }		
		##  ----------------     END EXTERNALS -------------------------
		
		variable options		                		
		set ::patch_xmb::CATEGORY_TV_XML [file join dev_flash vsh resource explore xmb category_tv.xml]
        set ::patch_xmb::XMB_PLUGIN [file join dev_flash vsh module xmb_plugin.sprx]
        set ::patch_xmb::SYSCONF_PLUGIN_RCO [file join dev_flash vsh resource sysconf_plugin.rco]
        set ::patch_xmb::EXPLORE_PLUGIN_FULL_RCO [file join  dev_flash vsh resource explore_plugin_full.rco]
		set ::patch_xmb::XMB_INGAME_RCO [file join dev_flash vsh resource xmb_ingame.rco]
	    set ::patch_xmb::REGISTORY_XML [file join dev_flash vsh resource explore xmb registory.xml]
		set ::patch_xmb::NET_CAT_XML [file join dev_flash vsh resource explore xmb category_network.xml]
		set ::patch_xmb::CATEGORY_GAME_TOOL2_XML [file join dev_flash vsh resource explore xmb category_game_tool2.xml]
		set ::patch_xmb::CATEGORY_GAME_XML [file join dev_flash vsh resource explore xmb category_game.xml]
		set ::patch_xmb::PSN_CAT_XML [file join dev_flash vsh resource explore xmb category_psn.xml]
		set ::patch_xmb::TEMPLAT_MFW_XML [file join ${::CUSTOM_TEMPLAT_DIR} mfw_templat.xml]		
		set ::patch_xmb::ACTIVATE_IPF {nas_plugin.sprx explore_category_game.sprx explore_plugin.sprx}
		set ::patch_xmb::rapeo "cond=An+Game:Game.category"
		set ::patch_xmb::rapen "cond=An+Game:Game.category X4+An+Game:Game.category X0+An+Game:Game.category"
		
		
		# modify the "category_game.xml"
		if {($::patch_xmb::options(--patch-package-files)) || ($::patch_xmb::options(--patch-app-home))} {
		
			log "Adding '*Install Package Files/APP_HOME' icons back into XMB....." 
			::modify_devflash_file $::patch_xmb::CATEGORY_GAME_XML ::patch_xmb::category_game_addpkgfiles
			
			# if patch-package enabled, need to check if modules also need to be
			# patched (depending on FW rev)
			if {$::patch_xmb::options(--patch-package-files)} {												
				if {${::NEWMFW_VER} >= "4.00"} {
					log ".......MFW is 4.xx, modifying explore_xxx.sprx files first......" 
					modify_devflash_files [file join dev_flash vsh module] $::patch_xmb::ACTIVATE_IPF ::patch_xmb::patch_self
				} else {
					log ".......MFW is 3.xx, no need to modify explore_xxx.sprx files......."
				}
				log ".......Modifying xml for *Install Package files back to XMB...."
			}				
		}
		
		# if homebrew options enabled, setup the homebrew segments
		if {$::patch_xmb::options(--add-install-pkg) || $::patch_xmb::options(--add-pkg-mgr) || $::patch_xmb::options(--add-hb-seg) || $::patch_xmb::options(--add-emu-seg)} {
		    ::modify_rco_file $::patch_xmb::EXPLORE_PLUGIN_FULL_RCO ::patch_xmb::callback_homebrew
		    ::modify_rco_file $::patch_xmb::XMB_INGAME_RCO ::patch_xmb::callback_homebrew
		    set ::patch_xmb::pointer_xmb 1
		    ::modify_devflash_file $::patch_xmb::NET_CAT_XML ::patch_xmb::patch_xml
		} else {
			if {$::patch_xmb::options(--patch-ren-apphome)} {
		        ::modify_rco_file $::patch_xmb::EXPLORE_PLUGIN_FULL_RCO ::patch_xmb::callback_discless
		        ::modify_rco_file $::patch_xmb::XMB_INGAME_RCO ::patch_xmb::callback_discless
		    }
		}	       
		
		if {$::patch_xmb::options(--patch-alpha-sort) || $::patch_xmb::options(--patch-rape-sfo) ||
		[expr {$::patch_xmb::options(--homebrew-cat) ne ""}]} {		
		    ::modify_devflash_file $::patch_xmb::CATEGORY_GAME_XML ::patch_xmb::patch_xml	    
		}
        # modify the "xmb_plugin.sprx"
        if { [expr {$::patch_xmb::options(--homebrew-cat) ne "TV"}] && $::patch_xmb::options(--tv-cat)} {
            ::modify_devflash_file $::patch_xmb::XMB_PLUGIN ::patch_xmb::patch_self
        }
        # modify the "sysconf_plugin.rco"
        if {$::patch_xmb::options(--fix-typo-sysconf-Italian) && $::customize_firmware::options(--customize-fw-version) == ""} {
            ::modify_rco_file $::patch_xmb::SYSCONF_PLUGIN_RCO ::patch_xmb::callback_fix_typo_sysconf_Italian
        }
    }
	##
	## ----------------------------------  END MAIN PROC ----------------------------------------------------------------------
	
   
	# proc for modify the dev_flash xml scripts
    proc patch_xml {args} {
        if {$::patch_xmb::pointer_xmb == 1} {			
            ::patch_xmb::find_nodes "" ${::patch_xmb::::TEMPLAT_MFW_XML} 
            ::patch_xmb::find_nodes1 ${::CUSTOM_DEVFLASH_DIR} $::patch_xmb::CATEGORY_GAME_TOOL2_XML 
            ::patch_xmb::read_cat ${::CUSTOM_DEVFLASH_DIR} $::patch_xmb::NET_CAT_XML 
            ::patch_xmb::inject_nodes ${::CUSTOM_DEVFLASH_DIR} $::patch_xmb::NET_CAT_XML 
            ::patch_xmb::inject_cat ${::CUSTOM_DEVFLASH_DIR} $::patch_xmb::PSN_CAT_XML 
        }     
        	  
		if {$::patch_xmb::options(--patch-alpha-sort)} {
			::patch_xmb::alpha_sort ${::CUSTOM_DEVFLASH_DIR} $::patch_xmb::REGISTORY_XML 
        }
        
        if {$::patch_xmb::options(--patch-rape-sfo) && !$::patch_xmb::options(--patch-alpha-sort)} {
			::patch_xmb::rape_sfo ${::CUSTOM_DEVFLASH_DIR} $::patch_xmb::REGISTORY_XML 
        }
        
        if {[expr {$::patch_xmb::options(--homebrew-cat) ne ""}]} {
            if {$::patch_xmb::options(--homebrew-cat) == "Users"} {
		       set CATEGORY_XML [file join dev_flash vsh resource explore xmb category_user.xml]
		    }
		   
		    if {$::patch_xmb::options(--homebrew-cat) == "Photo"} {
		       set CATEGORY_XML [file join dev_flash vsh resource explore xmb category_photo.xml]
		    }
         
		    if {$::patch_xmb::options(--homebrew-cat) == "Music"} {
		       set CATEGORY_XML [file join dev_flash vsh resource explore xmb category_music.xml]
		    }
		  
		    if {$::patch_xmb::options(--homebrew-cat) == "Video"} {
		       set CATEGORY_XML [file join dev_flash vsh resource explore xmb category_video.xml]
		    }
		 
		    if {$::patch_xmb::options(--homebrew-cat) == "TV"} {
		       modify_devflash_file $::patch_xmb::XMB_PLUGIN ::patch_xmb::patch_self
		       ::patch_xmb::find_nodes2 ${::CUSTOM_DEVFLASH_DIR} $::patch_xmb::CATEGORY_TV_XML 
		       set CATEGORY_XML [file join dev_flash vsh resource explore xmb category_tv.xml]
		    }
		  
		    if {$::patch_xmb::options(--homebrew-cat) == "Game"} {
		       set CATEGORY_XML [file join dev_flash vsh resource explore xmb category_game.xml]
		    }
		 
		    if {$::patch_xmb::options(--homebrew-cat) == "Network"} {
		       set CATEGORY_XML [file join dev_flash vsh resource explore xmb category_network.xml]
		    }
		 
		    if {$::patch_xmb::options(--homebrew-cat) == "PlayStation® Network"} {
		       set CATEGORY_XML [file join dev_flash vsh resource explore xmb category_psn.xml]
		    }
		 
		    if {$::patch_xmb::options(--homebrew-cat) == "Friends"} {
		       set CATEGORY_XML [file join dev_flash vsh resource explore xmb category_friend.xml]
		    }	
			
			# patch in the 'homebrew' category
            ::patch_xmb::find_nodes2 ${::CUSTOM_DEVFLASH_DIR} $::patch_xmb::CATEGORY_GAME_TOOL2_XML 
            ::patch_xmb::inject_nodes2 ${::CUSTOM_DEVFLASH_DIR} $::patch_xmb::CATEGORY_GAME_XML 
		    modify_rco_file $::patch_xmb::EXPLORE_PLUGIN_FULL_RCO ::patch_xmb::callback_manual
		    modify_rco_file $::patch_xmb::XMB_INGAME_RCO ::patch_xmb::callback_manual
        }
        # unset these globals
        if { [info exist ::query_package_files] } {
			unset ::query_package_files }
		if { [info exist ::view_package_files] } {
			unset ::view_package_files }
		if { [info exist ::view_packages] } {
			unset ::view_packages }
		if { [info exist ::query_gamedebug] } {
			unset ::query_gamedebug }
		if { [info exist ::view_gamedebug] } {
			unset ::view_gamedebug }
    }
	# end proc "patch_xml"
	######################################################################3
    
    proc patch_self {self} {		
		set args ""		
        log "Patching [file tail $self]"
        ::modify_self_file $self ::patch_xmb::patch_elf
    }

	# callback proc for doing the main ELF patches for all of the xmb-related
	# patches
    proc patch_elf {elf} {			
		# if "tv-cat" enabled, find the patch
		# currently, only good for < 3.60
		# patch for file: "xmb_plugin.sprx"
		if {$::patch_xmb::options(--tv-cat)} {	
			if { [string first "xmb_plugin.sprx" $elf 0] != -1 } {
				if {${::NEWMFW_VER} < "3.60"} {
					# verified OFW ver. 3.60 - 3.60
					# OFW 3.55: 0x1E251 (0x1E161)
					# OFW 3.60: *** NO LONGER AVAILABLE ??  ***
					log "Patching [file tail $elf] to add tv category"  
					# ***  this patch is for "xmb_plugin.sprx"  ***
					# dev_hdd0/game/BCES00275........
					set search  "\x64\x65\x76\x5f\x68\x64\x64\x30\x2f\x67\x61\x6d\x65\x2f\x42\x43\x45\x53\x30\x30\x32\x37\x35"
					set replace "\x64\x65\x76\x5f\x66\x6c\x61\x73\x68\x2f\x64\x61\x74\x61\x2f\x63\x65\x72\x74\x00\x00\x00\x00"
					set offset 0
					set mask 0	
					# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"
					
				} else {
					log "ERROR:  This patch is only available on OFW < 3.60!!"
					die "ERROR:  This patch is only available on OFW < 3.60!!"
				}
			}
		}
		####   *INSTALL PKG FILES*  adding into XMB  ##############################################
		####
		####   NOTE:  Unsure of what firmware EXACTLY this patch set became possible????
		#####         *some* of the patches are found in OFW early as 3.60, but others later???
		#
		# if "add install pkg files" back to XMB enabled, patch it
		if {$::patch_xmb::options(--patch-package-files)} {
		
			# verified against "Rogero 4.46 - 09/20/2013"
			# patches are valid for OFW 4.00 - 4.55+
			if { [string first "nas_plugin.sprx" $elf 0] != -1 } {				
				if {${::NEWMFW_VER} >= "4.00"} {
					# verified OFW ver. 3.55 - 4.46+
					# OFW 3.55: *** DOES NOT EXIST IN 3.xx OFW! ***
					# OFW 3.70: *** DOES NOT EXIST IN 3.xx OFW! ***
					# OFW 4.00: 0x22CC0 (0x22BD0)
					# OFW 4.30: 0x242D8 (0x241E8)
					# OFW 4.46: 0x23B28 (0x23A38)					
					log "Patching [file tail $elf] to add Install Package Files back to the XMB Pt 1/2"     				
					set search  "\x40\x9E\x00\x3C\x3D\x20\x00\x06\x38\x00\x00\x29\x3B\xA0\x00\x00"					
					set replace "\x48\x00"
					set offset  0
					set mask 0
					# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"   		
				
					# verified OFW ver. 3.55 - 4.55+
					# OFW 3.55: 0x3734C (0x3725C)
					# OFW 3.70: 0x3BF1C (0x3BE2C)
					# OFW 4.00: 0x2DFD0 (0x3BE2C)
					# OFW 4.30: 0x2E930 (0x2E840)
					# OFW 4.46: 0x2EAF0 (0x2EA00)
					log "Patching [file tail $elf] to add Install Package Files back to the XMB Pt 2/2"     				
					set search  "\x2F\x89\x00\x00\x41\x9E\x00\x4C\x38\x00\x00\x00\x81\x22"
					set replace "\x40"
					set offset 4
					set mask 0	
					# PATCH THE ELF BINARY
					catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"    
					
				} else {
					log "ERROR: Adding *Install Pkg Files to XMB via elf patching only works in 4.xx FIRMWARE!!"
					die "ERROR: Adding *Install Pkg Files to XMB via elf patching only works in 4.xx FIRMWARE!!"
				}
			} else {
				if {${::NEWMFW_VER} >= "4.00"} {
					# "*INSTALL PKG FILE PATCHES" FOR:  "explore_category_game.sprx" AND  "explore_plugin.sprx"
					if { ([string first "explore_category_game.sprx" $elf 0] != -1) || ([string first "explore_plugin.sprx" $elf 0] != -1) } {					
						# verified OFW ver. 3.55 - 4.46+
						#"explore_category_game.sprx"       "explore_plugin.sprx"
						# OFW 3.55: ** NOT FOUND **			# OFW 3.55: ** NOT FOUND **		
						# OFW 3.60: 0xBAF50 (0xBAE60)		# OFW 3.60: 0x1F3ACC (0x1F39DC)
						# OFW 3.70: 0xBE87C (0xBE78C)		# OFW 3.70: 0x200870 (0x200780)
						# OFW 4.00: 0xBA564 (0xBA474)		# OFW 4.00: 0x1F6708 (0x1F6618)
						# OFW 4.30: 0xB64EC (0xB63FC		# OFW 4.30: 0x1FE508 (0x1FE418)
						# OFW 4.46: 0xB6658 (0xB6568)		# OFW 4.46: 0x1FF014 (0x1FEF24)
						log "Patching [file tail $elf] to add Install Package Files back to the XMB"         
						set search  "\xF8\x21\xFE\xD1\x7C\x08\x02\xA6\xFB\x81\x01\x10\x3B\x81\x00\x70"
						set replace "\x38\x60\x00\x01\x4E\x80\x00\x20"
						set offset  0
						set mask 0	
						# PATCH THE ELF BINARY
						catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 
						
					} else {
						log "ERROR: *Install Pkg Files patch encountered for unhandled file: [file tail $elf]"
						die "ERROR: *Install Pkg Files patch encountered for unhandled file: [file tail $elf]"
					}
				} else {
					log "ERROR: Adding *Install Pkg Files to XMB via elf patching only works in 4.xx FIRMWARE!!"
					die "ERROR: Adding *Install Pkg Files to XMB via elf patching only works in 4.xx FIRMWARE!!"
				}
			}					
		}
		#
		#### END "if {$::patch_xmb::options(patch-package-files)} ENABLED ######
    }
	#
	#### END "patch_elf{} ######
    
	### proc for "alphabetical sort"
    proc alpha_sort {path file} {
        log "Patching Alphabetical Sort for Games in file [file tail $path]"
        sed_in_place [file join $path $file] -Game:Common.stat.rating-Game:Common.timeCreated+Game:Common.titleForSort-Game:Game.category -Game:Common.stat.rating-Game:Common.title+Game:Common.titleForSort-Game:Game.category
        sed_in_place [file join $path $file] -Game:Common.stat.rating+Game:Common.timeCreated+Game:Common.titleForSort-Game:Game.category -Game:Common.stat.rating+Game:Common.title+Game:Common.titleForSort-Game:Game.category
        sed_in_place [file join $path $file] -Game:Common.stat.rating-Game:Common.stat.timeLastUsed+Game:Common.titleForSort-Game:Common.timeCreated-Game:Game.category -Game:Common.stat.rating-Game:Common.stat.timeLastUsed+Game:Common.titleForSort-Game:Common.title-Game:Game.category
        sed_in_place [file join $path $file] -Game:Common.stat.rating+Game:Common.titleForSort-Game:Common.timeCreated-Game:Game.category -Game:Common.stat.rating+Game:Common.titleForSort-Game:Common.title-Game:Game.category
        sed_in_place [file join $path $file] -Game:Common.stat.rating+Game:Game.gameCategory-Game:Common.timeCreated+Game:Common.titleForSort -Game:Common.stat.rating+Game:Game.gameCategory-Game:Common.title+Game:Common.titleForSort
        
        if {$::patch_xmb::options(--patch-rape-sfo)} {
            ::patch_xmb::rape_sfo $path $file
        }
    }
    
    proc rape_sfo {path file} {
        log "Patching Rape SFO in file [file tail $path]"
        sed_in_place [file join $path $file] $::patch_xmb::rapeo $::patch_xmb::rapen       
    }

    proc callback_fix_typo_sysconf_Italian {path} {
        log "Patching Italian.xml into [file tail $path]"
        sed_in_place [file join $path Italian.xml] backuip backup
    }
    
    proc callback_homebrew {path} {		
        log "Patching English.xml into [file tail $path]"
        sed_in_place [file join $path English.xml] Network Homebrew
        
        log "Patching German.xml into [file tail $path]"
        sed_in_place [file join $path German.xml] Network Homebrew
        
        log "Patching Korean.xml into [file tail $path]"
        sed_in_place [file join $path Korean.xml] Network Homebrew
        
        log "Patching Russian.xml into [file tail $path]"
        sed_in_place [file join $path Russian.xml] Network Homebrew
        
        log "Patching Swedish.xml into [file tail $path]"
        sed_in_place [file join $path Swedish.xml] Network Homebrew
        
        log "Patching Spanish.xml into [file tail $path]"
        sed_in_place [file join $path Spanish.xml] Network Homebrew
        
        log "Patching Portugese.xml into [file tail $path]"
        sed_in_place [file join $path Portugese.xml] Network Homebrew
        
        log "Patching Norwegian.xml into [file tail $path]"
        sed_in_place [file join $path Norwegian.xml] Network Homebrew
        
        log "Patching Japanese.xml into [file tail $path]"
        sed_in_place [file join $path Japanese.xml] Network Homebrew
        
        log "Patching Italian.xml into [file tail $path]"
        sed_in_place [file join $path Italian.xml] Network Homebrew
        
        log "Patching French.xml into [file tail $path]"
        sed_in_place [file join $path French.xml] Network Homebrew
        
        log "Patching Finnish.xml into [file tail $path]"
        sed_in_place [file join $path Finnish.xml] Network Homebrew
        
        log "Patching Dutch.xml into [file tail $path]"
        sed_in_place [file join $path Dutch.xml] Network Homebrew
        
        log "Patching Danish.xml into [file tail $path]"
        sed_in_place [file join $path Danish.xml] Network Homebrew
        
        log "Patching ChineseTrad.xml into [file tail $path]"
        sed_in_place [file join $path ChineseTrad.xml] Network Homebrew
        
        log "Patching ChineseSimpl.xml into [file tail $path]"
        sed_in_place [file join $path ChineseSimpl.xml] Network Homebrew
        
        if {$::patch_xmb::options(--patch-ren-apphome)} { 
            ::patch_xmb::callback_discless $path
        }
    }
    
    proc callback_discless {path} {
        log "Patching English.xml into [file tail $path]"
        sed_in_place [file join $path English.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching German.xml into [file tail $path]"
        sed_in_place [file join $path German.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching Korean.xml into [file tail $path]"
        sed_in_place [file join $path Korean.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching Russian.xml into [file tail $path]"
        sed_in_place [file join $path Russian.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching Swedish.xml into [file tail $path]"
        sed_in_place [file join $path Swedish.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching Spanish.xml into [file tail $path]"
        sed_in_place [file join $path Spanish.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching Portugese.xml into [file tail $path]"
        sed_in_place [file join $path Portugese.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching Norwegian.xml into [file tail $path]"
        sed_in_place [file join $path Norwegian.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching Japanese.xml into [file tail $path]"
        sed_in_place [file join $path Japanese.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching Italian.xml into [file tail $path]"
         sed_in_place [file join $path Italian.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching French.xml into [file tail $path]"
        sed_in_place [file join $path French.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching Finnish.xml into [file tail $path]"
        sed_in_place [file join $path Finnish.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching Dutch.xml into [file tail $path]"
        sed_in_place [file join $path Dutch.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching Danish.xml into [file tail $path]"
        sed_in_place [file join $path Danish.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching ChineseTrad.xml into [file tail $path]"
        sed_in_place [file join $path ChineseTrad.xml] /app_home/PS3_GAME/ Discless
        
        log "Patching ChineseSimpl.xml into [file tail $path]"
        sed_in_place [file join $path ChineseSimpl.xml] /app_home/PS3_GAME/ Discless
    }
    
    proc callback_manual { path } {
        log "Patching English.xml into [file tail $path]"
        sed_in_place [file join $path English.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching German.xml into [file tail $path]"
        sed_in_place [file join $path German.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching Korean.xml into [file tail $path]"
        sed_in_place [file join $path Korean.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching Russian.xml into [file tail $path]"
        sed_in_place [file join $path Russian.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching Swedish.xml into [file tail $path]"
        sed_in_place [file join $path Swedish.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching Spanish.xml into [file tail $path]"
        sed_in_place [file join $path Spanish.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching Portugese.xml into [file tail $path]"
        sed_in_place [file join $path Portugese.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching Norwegian.xml into [file tail $path]"
        sed_in_place [file join $path Norwegian.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching Japanese.xml into [file tail $path]"
        sed_in_place [file join $path Japanese.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching Italian.xml into [file tail $path]"
        sed_in_place [file join $path Italian.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching French.xml into [file tail $path]"
        sed_in_place [file join $path French.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching Finnish.xml into [file tail $path]"
        sed_in_place [file join $path Finnish.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching Dutch.xml into [file tail $path]"
        sed_in_place [file join $path Dutch.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching Danish.xml into [file tail $path]"
        sed_in_place [file join $path Danish.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching ChineseTrad.xml into [file tail $path]"
        sed_in_place [file join $path ChineseTrad.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
        
        log "Patching ChineseSimpl.xml into [file tail $path]"
        sed_in_place [file join $path ChineseSimpl.xml] $::patch_xmb::options(--homebrew-cat) Homebrew
    }
    
	# proc for changing the "Welcome String"
    proc change_welcome_string { path } {
	
        log "Changing Welcome string to Hombrew segment"       
        #sed_in_place [file join $path category_network.xml] key="seg_browser"> key="seg_hbrew">
		sed_in_place $path key="seg_browser"> key="seg_hbrew">
    }
    # proc for cleaning homebrew cat
    proc clean_net { path file } {
	
        log "Modifying XML(clean_net): file [file tail $file]"
        log "Cleaning Homebrew category"
		set filepath [file join $path $file]
		set xml [::xml::LoadFile $filepath]      
     
        set xml [::remove_node_from_xmb_xml $xml "seg_browser" "Internet Browser"]
        set xml [::remove_node_from_xmb_xml $xml "seg_folding_at_home" "Life with PlayStation "]
        set xml [::remove_node_from_xmb_xml $xml "seg_kensaku" "Internet Search"]
        set xml [::remove_node_from_xmb_xml $xml "seg_manual" "Online Instruction Manuals"]
        set xml [::remove_node_from_xmb_xml $xml "seg_premo" "Remote Play"]
        set xml [::remove_node_from_xmb_xml $xml "seg_dlctrl" "Download Controle"]
		# save the cleaned file
		::xml::SaveToFile $xml $filepath
    }
    
	# proc for reading out of the file
    proc read_cat { path file } {
	
        log "Parsing XML(read cat): [file tail $file]"		
		set filepath [file join $path $file]
		# if we are fixing the "category_network" file, fix that stupid
		# open brace problem!
		if { [string first "category_network.xml" $file] != -1 } {
			remove_line_from_network_cat $filepath
		}
        set xml [::xml::LoadFile $filepath]       				
        set ::query_manual [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key "seg_manual"]
        set ::view_seg_manual [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_manual"]        
        if {$::query_manual == "" || $::view_seg_manual == ""} {
            die "Could not parse $file"
        }		
        
        set ::query_premo [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key "seg_premo"]
        set ::view_premo [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_premo"]        
        if {$::query_premo == "" || $::view_premo == ""} {
            die "Could not parse $file"
        }
        
        set ::query_browser [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key "seg_browser"]
        set ::view_browser [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_browser"]        
        if {$::query_browser == "" || $::view_browser == ""} {
            die "Could not parse $file"
        }
        
        set ::query_kensaku [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key "seg_kensaku"]
        set ::view_kensaku [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_kensaku"]        
        if {$::query_kensaku == "" || $::view_kensaku == ""} {
            die "Could not parse $file"
        }
        
        set ::query_dlctrl [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key "seg_dlctrl"]        
        if {$::query_dlctrl == "" } {
            die "Could not parse $file"
        }		
        # go inject the selected nodes
        #::patch_xmb::inject_nodes $path $file
        
    }
    
	# proc for injecting the new cats
    proc inject_cat { path file } {
	
        log "Modifying XML(inject cat): [file tail $file]"
		set filepath [file join $path $file]	
        set xml [::xml::LoadFile $filepath]
        
        set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key ""] $::query_dlctrl]  
		
        unset ::query_dlctrl
        
        set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "" ] $::query_kensaku]
        set xml [::xml::InsertNode $xml {2 end 0} $::view_kensaku]
     
        unset ::query_kensaku
        unset ::view_kensaku
        
        set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "" ] $::query_browser]
        set xml [::xml::InsertNode $xml {2 end 0} $::view_browser]
     
        unset ::query_browser
        unset ::view_browser
        
        set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "" ] $::query_premo]
        set xml [::xml::InsertNode $xml {2 end 0} $::view_premo]
     
        unset ::query_premo
        unset ::view_premo
        
        set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "" ] $::query_manual]
        set xml [::xml::InsertNode $xml {2 end 0} $::view_seg_manual]
     
        unset ::query_manual
        unset ::view_seg_manual
        
        ::xml::SaveToFile $xml $filepath
    }
    
    proc find_nodes { path file } {
        log "Parsing XML(find_nodes): [file tail $file]"
		set filepath [file join $path $file]		
        set xml [::xml::LoadFile $filepath]
        
        
        if {$::patch_xmb::options(--add-emu-seg)} {
            set ::query_emulator [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key "seg_emulator"]
            set ::view_emulator [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_emulator"]
            set ::view_emu [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_emu"]         
            if {$::query_emulator == "" || $::view_emulator == "" || $::view_emu == "" } {
                die "Could not parse $file"
            }
        }
        
        if {$::patch_xmb::options(--add-hb-seg)} {
            set ::query_hbrew [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key "seg_hbrew"]
            set ::view_hbrew [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_hbrew"]
            set ::view_brew [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_brew"]         
            if {$::query_hbrew == "" || $::view_hbrew == "" || $::view_brew == "" } {
                die "Could not parse $file"
            }
        }
        
        if {$::patch_xmb::options(--add-pkg-mgr)} {
            set ::query_package_manager [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key "seg_package_manager"]
            set ::view_package_manager [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_package_manager"]
            set ::view_pkg_files [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_pkg_files"]
            set ::view_pkg_fixed [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_pkg_fixed"]
            set ::view_install_pkg_fixed [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_install_pkg_fixed"]
            set ::view_delete_pkg_fixed [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_delete_pkg_fixed"]
            set ::view_pkg_install_fixed [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_pkg_install_fixed"]
            set ::view_pkg_install_flash [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_pkg_install_flash"]
            set ::view_pkg_install_hdd0 [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_pkg_install_hdd0"]
            set ::view_pkg_install_usb [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_pkg_install_usb"]
            set ::view_pkg_install_orig [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_pkg_install_orig"]
            set ::view_pkg_delete_fixed [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_pkg_delete_fixed"]
            set ::view_pkg_delete_hdd0 [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_pkg_delete_hdd0"]
            set ::view_pkg_delete_usb [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_pkg_delete_usb"]
            set ::view_pkg_delete_orig [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_pkg_delete_orig"]
            
            if {$::query_package_manager == "" || $::view_package_manager == "" || $::view_pkg_files == "" || $::view_pkg_fixed == "" || $::view_install_pkg_fixed == "" || $::view_delete_pkg_fixed == "" || $::view_pkg_install_fixed == "" || $::view_pkg_install_flash == "" || $::view_pkg_install_hdd0 == "" || $::view_pkg_install_usb == "" || $::view_pkg_install_orig == "" || $::view_pkg_delete_fixed == "" || $::view_pkg_delete_hdd0 == "" || $::view_pkg_delete_usb == "" || $::view_pkg_delete_orig == "" } {
                die "Could not parse $file"
            }
        }
    }
    
    proc find_nodes1 { path file } {
        log "Parsing XML(find_nodes1): [file tail $file]"		
		set filepath [file join $path $file]		
        set xml [::xml::LoadFile $filepath]
        
        if {$::patch_xmb::options(--add-install-pkg)} {
            set ::query_package_files [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key "seg_package_files"]
            set ::view_package_files [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_package_files"]
            set ::view_packages [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_packages"]         
            if {$::query_package_files == "" || $::view_package_files == "" || $::view_packages == "" } {
                die "Could not parse $file"
            }
        }               
    }
    
    proc find_nodes2 { path file } {
        log "Parsing XML(find_nodes2): [file tail $file]"
		set filepath [file join $path $file]		
        set xml [::xml::LoadFile $filepath]        
     
        set ::XMBML [::xml::GetNodeByAttribute $xml "XMBML" version "1.0"]     
        if {$::XMBML == ""} {
            die "Could not parse $file"
        }
    }
    
    proc inject_nodes { path file } {
	
        log "Modifying XML(inject_nodes): [file tail $file]"
		set filepath [file join $path $file]		
        set xml [::xml::LoadFile $filepath]        
        
        if {$::patch_xmb::options(--add-emu-seg)} {
            set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "seg_gameexit"] $::query_emulator]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_emulator]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_emu]
         
            unset ::query_emulator
            unset ::view_emulator
            unset ::view_emu
        }
        
        if {$::patch_xmb::options(--add-hb-seg)} {
            set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "seg_gameexit"] $::query_hbrew]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_hbrew]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_brew]
          
            unset ::query_hbrew
            unset ::view_hbrew
            unset ::view_brew
        }
        
        if {$::patch_xmb::options(--add-pkg-mgr)} {
            set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "seg_gameexit"] $::query_package_manager]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_package_manager]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_pkg_files]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_pkg_fixed]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_install_pkg_fixed]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_delete_pkg_fixed]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_pkg_install_fixed]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_pkg_install_flash]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_pkg_install_hdd0]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_pkg_install_usb]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_pkg_install_orig]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_pkg_delete_fixed]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_pkg_delete_hdd0]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_pkg_delete_usb]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_pkg_delete_orig]
            
            unset ::query_package_manager
            unset ::view_package_manager
            unset ::view_pkg_files
            unset ::view_pkg_fixed
            unset ::view_install_pkg_fixed
            unset ::view_delete_pkg_fixed
            unset ::view_pkg_install_fixed
            unset ::view_pkg_install_flash
            unset ::view_pkg_install_hdd0
            unset ::view_pkg_install_usb
            unset ::view_pkg_install_orig
            unset ::view_pkg_delete_fixed
            unset ::view_pkg_delete_hdd0
            unset ::view_pkg_delete_usb
            unset ::view_pkg_delete_orig
        }
     
        if {$::patch_xmb::options(--add-install-pkg)} {
            set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "seg_gameexit"] $::query_package_files]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_package_files]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_packages]
        }
        # go clean the file
        ::patch_xmb::clean_net $path $file
        
        log "Saving XML"
        ::xml::SaveToFile $xml $filepath
        
		# go change the welcome screen
        ::patch_xmb::change_welcome_string $filepath
        
		# if we didn't already copy the image icons, 
		# copy them over
		if { !$::patch_xmb::flag_icons_copied } {
			log "Copy custom icon's into dev_flash"
			::copy_mfw_imgs
			set ::patch_xmb::flag_icons_copied true
		}
        
		# if we chose an embedded app
        if { [expr {"$::patch_xmb::embed" ne ""}] } {
			if { !$::patch_xmb::hermes_enabled } {
				log "WARNING! You want to change the embedded App but you forgot to set the patch for lv2 payload hermes 4.xx"
				log "WARNING! Without this patch the App can not be mounted"
				log "Skipping customization of the embedded App"  
				tk_messageBox -default ok -message "WARNING: HERMES payload not selected!" -icon warning
			} else {
				 log "Copy custom embedded app into dev_flash"
				::patch_ps3_game $::patch_xmb::embed
			}			
        } else {
			if { $::patch_xmb::hermes_enabled } {
				#log "Installing standalone '*Install Package Files' app"
				#::patch_ps3_game ${::CUSTOM_PS3_GAME}
				tk_messageBox -default ok -message "WARNING: Install PKG was not selected!" -icon warning
			}
        }		
    }
    ######################################################################################################################
	#
    proc category_game_addpkgfiles { file } {	        
		
		log "Modifying XML(for *InstallPkg):[file tail $file]"		
		set filepath [file join ${::CUSTOM_DEVFLASH_DIR} $file]		
		
		set fd [open $file r]
		fconfigure $fd -translation binary 
        set xml [read $fd]
        close $fd         

		set totalquery ""		
		# pkgquery for '*Install PKG Files'
		log "Adding '*Install PKG Files' back into XML....."
		set pkgquery 	"\n\t\t\t<Query\n"
		append pkgquery "\t\t\t\tclass=\"type:x-xmb/folder-pixmap\"\n"
		append pkgquery "\t\t\t\tkey=\"seg_package_files\"\n"
		append pkgquery "\t\t\t\tsrc=\"xmb://localhost/%flash/xmb/category_game_tool2.xml#seg_package_files\"\n"
		append pkgquery "\t\t\t\t/>"
		# if '--patch-package-files' enabled, append the query to the 'install-pkg-files' query
		if {$::patch_xmb::options(--patch-package-files)} {
			append totalquery $pkgquery
		}
		
		# pkgquery for 'app_home' icon	
		log "Adding 'APP_HOME' icon back into XML....."		
		set apphomequery 	"\n\t\t\t<Query\n"
		append apphomequery "\t\t\t\tclass=\"type:x-xmb/folder-pixmap\"\n"
		append apphomequery "\t\t\t\tkey=\"seq_gamedebug\"\n"
		append apphomequery "\t\t\t\tsrc=\"xmb://localhost/%flash/xmb/category_game_tool2.xml#seg_gamedebug\"\n"
		append apphomequery "\t\t\t\t/>"		
		# if 'app-home' enabled, append the query to the 'install-pkg-files' query
		if {$::patch_xmb::options(--patch-app-home)} {
			append totalquery $apphomequery
		}			
		
		set inserted 0
		set finaldata ""	
		set lines [split $xml "\x0D"]
		foreach line $lines {			
			if {$inserted == 0} {
				if {([string first "<Items>" $line 0] != -1)} {
					set inserted 1
					append finaldata $line
					append finaldata $totalquery
				} else {
					append finaldata $line
				}
			} else {
				append finaldata $line
			}
		}
        # write out final data
		log "Saving XML file:[file tail $filepath]"
        set fd [open $filepath w]
		fconfigure $fd -translation binary
        puts -nonewline $fd $finaldata
        close $fd         	
       
    }
	#
	#######################################     end of "category_game_addpkgfiles"  #########################################################
	
	
    ######################################################################################################################
	#
    proc inject_nodes2 { path file } {
        log "Modifying XML(inject_nodes2): [file tail $file]"	
		set filepath [file join $path $file]		
        set xml [::xml::LoadFile $filepath]		        
            
        if {$::patch_xmb::options(--patch-package-files)} {
            set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "seg_gameexit"] $::query_package_files]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_package_files]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_packages]
        }
        
        if {$::patch_xmb::options(--patch-app-home)} {
            set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "seg_gameexit"] $::query_gamedebug]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_gamedebug]
        }       
        log "Saving XML"
        ::xml::SaveToFile $xml $filepath		
        
		##  check for installing the embedded app
        if {!$::patch_xmb::options(--add-install-pkg) && !$::patch_xmb::options(--add-pkg-mgr) && !$::patch_xmb::options(--add-hb-seg) && !$::patch_xmb::options(--add-emu-seg) } {	
			if { [expr {"$::patch_xmb::embed" ne ""}] } {
				if {!$::patch_xmb::hermes_enabled} {
					log "WARNING! You want to change the embedded App but you forgot to set the patch for lv2 payload hermes 4.xx"
					log "WARNING! Without this patch the App can not be mounted"
					log "Skipping customization of the embedded App"  
					tk_messageBox -default ok -message "WARNING: HERMES payload not selected!" -icon warning
				} else {
					if { [expr {"$::patch_xmb::embed" ne ""}] } {
						log "Copy custom embedded app into dev_flash"
						::patch_ps3_game $::patch_xmb::embed
					} else {
						## not sure if we need to do this, as it's also checked elsewhere
						#log "Copy standalone '*Install Package Files' app into dev_flash"
						#::copy_ps3_game ${::CUSTOM_PS3_GAME}
						tk_messageBox -default ok -message "WARNING: Install PKG was not selected!" -icon warning
					}
				} 
			}
        }
    }
	#
	#######################################     end of "inject_nodes2"  #########################################################
	
	# fix for network cat, sony left a unclosed brace which will "modify_xml" command cause a error
	proc remove_line_from_network_cat {file} {
		log "Fixing \"category_network.xml\" unclosed brace bug!"
	    set src $file
	    set tmp ${src}.work
     
        set source [open $file]
        set desti [open $tmp w]
        set buff [read $source]
        close $source
        set lines [split $buff \n]
        set lines_after_deletion [lreplace $lines 47 47]
        puts -nonewline $desti [join $lines_after_deletion \n]
        close $desti
        file rename -force $tmp $file
	}
	# test callback func for just debug-break
	proc debug_test {args} {
		die "DEBUG BREAK"
	}
}