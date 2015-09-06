#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 100
# Description: Patch VSH - Miscellaneous

# Option --patch-rogero-vsh-patches: [3.xx/4.xx]  -->  Patch VSH with ROGERO patches
# Option --allow-unsigned-app: [3.xx/4.xx]  -->  Patch to allow running of unsigned applications (3.xx/4.xx)
# Option --patch-vsh-react-psn-v2-4x: [3.xx/4.xx]  -->  Jailbait - Patch to implement ReactPSN v2.0 into VSH (3.xx/4.xx)
# Option --patch-vsh-no-delete-actdat: [3.xx/4.xx]  -->  Jailbait - Patch to implement NO deleting of unsigned act/dat (3.xx/4.xx)
# Option --disable-cinavia-protection-4x: [3.xx/4.xx]  -->  Disable Cinavia Protection (4.xx)
# Option --allow-retail-pkg-dex: [3.xx/4.xx]  -->  Patch to allow installation of retail packages on DEX (3.xx/4.xx)
# Option --allow-pseudoretail-pkg: [3.xx/4.xx]  -->  Patch to allow installation of pseudo-retail packages on REX/DEX (3.xx/4.xx)
# Option --allow-debug-pkg: [3.xx/4.xx]  -->  Patch to allow installation of debug packages (3.xx/4.xx)
# Option --customize-fw-ssl-cer: [3.xx/4.xx]  -->  Change SSL - New SSL CA certificate (source)
# Option --customize-fw-change-cer: [3.xx/4.xx]  -->  Change SSL - SSL CA public certificate (destination)

# Type --patch: boolean
# Type --customize-fw-ssl-cer: file open {"SSL Certificate" {cer}}
# Type --customize-fw-change-cer: combobox {{DNAS} {Proxy} {ALL} {CA01.cer} {CA02.cer} {CA03.cer} {CA04.cer} {CA05.cer} {CA23.cer} {CA06.cer} {CA07.cer} {CA08.cer} {CA09.cer} {CA10.cer} {CA11.cer} {CA12.cer} {CA13.cer} {CA14.cer} {CA15.cer} {CA16.cer} {CA17.cer} {CA18.cer} {CA19.cer} {CA20.cer} {CA21.cer} {CA22.cer} {CA24.cer} {CA25.cer} {CA26.cer} {CA27.cer} {CA28.cer} {CA29.cer} {CA30.cer} {CA31.cer} {CA32.cer} {CA33.cer} {CA34.cer} {CA35.cer} {CA36.cer}}

namespace eval ::patch_vsh {

    array set ::patch_vsh::options {
		--patch-rogero-vsh-patches false
		--allow-unsigned-app false
		--patch-vsh-react-psn-v2-4x true
		--patch-vsh-no-delete-actdat false	
		--disable-cinavia-protection-4x false		
        --allow-retail-pkg-dex true
        --allow-pseudoretail-pkg true		
        --allow-debug-pkg true		
        --customize-fw-ssl-cer ""
        --customize-fw-change-cer ""		   
    }

    proc main { } {
        variable options
        set src $::patch_vsh::options(--customize-fw-ssl-cer)
        set dst $::patch_vsh::options(--customize-fw-change-cer)
        set path [file join dev_flash data cert]
				
		
     
		# if "retail/debug pkg" options, then patch "nas_plugin.sprx"
        if {$::patch_vsh::options(--allow-pseudoretail-pkg) || $::patch_vsh::options(--allow-debug-pkg) || $::patch_vsh::options(--allow-retail-pkg-dex)} {
            set self [file join dev_flash vsh module nas_plugin.sprx]
            ::modify_devflash_file $self ::patch_vsh::patch_self
        }
        # if "unsigned/psn" patches enabled, patch "vsh.self"
        if {$::patch_vsh::options(--allow-unsigned-app) || $::patch_vsh::options(--patch-vsh-react-psn-v2-4x) || $::patch_vsh::options(--patch-rogero-vsh-patches) ||
			$::patch_vsh::options(--patch-vsh-no-delete-actdat)} {
            set self [file join dev_flash vsh module vsh.self]
            ::modify_devflash_file $self ::patch_vsh::patch_self
        }		
		
        # if "--customize-fw-ssl-cer" is defined, patch it
        if {$::patch_vsh::options(--customize-fw-ssl-cer) != ""} {
            if {[file exists $src] == 0 } {
                die "Source SSL CA public certificate file $src does not exist"
            } elseif {[string equal $dst "DNAS"] == 1} {
                log "Changing DNAS SSL CA public certificates to [file tail $dst]" 1
                set dst "CA01.cer CA02.cer CA03.cer CA04.cer CA05.cer"
                ::modify_devflash_files $path $dst ::patch_vsh::copy_customized_file $src
            } elseif {[string equal $dst "Proxy"] == 1} {
                log "Changing SSL CA public certificates to [file tail $src]" 1
                set dst "CA06.cer CA07.cer CA08.cer CA09.cer CA10.cer CA11.cer CA12.cer CA13.cer CA14.cer CA15.cer CA16.cer CA17.cer CA18.cer CA19.cer CA20.cer CA21.cer CA22.cer CA23.cer CA24.cer CA25.cer CA26.cer CA27.cer CA28.cer CA29.cer CA30.cer CA31.cer CA32.cer CA33.cer CA34.cer CA35.cer CA36.cer"
                ::modify_devflash_files $path $dst ::patch_vsh::copy_customized_file $src
            } elseif {[string equal $dst "ALL"] == 1} {
                log "Changing ALL SSL CA public certificates to [file tail $dst]" 1
                set dst "CA01.cer CA02.cer CA03.cer CA04.cer CA05.cer CA06.cer CA07.cer CA08.cer CA09.cer CA10.cer CA11.cer CA12.cer CA13.cer CA14.cer CA15.cer CA16.cer CA17.cer CA18.cer CA19.cer CA20.cer CA21.cer CA22.cer CA23.cer CA24.cer CA25.cer CA26.cer CA27.cer CA28.cer CA29.cer CA30.cer CA31.cer CA32.cer CA33.cer CA34.cer CA35.cer CA36.cer"
                ::modify_devflash_files $path $dst ::patch_vsh::copy_customized_file $src
            } else {
                log "Changing SSL CA public certificate $dst to [file tail $src]" 1
                set dst [file join $path [lindex $dst 0]]
                ::modify_devflash_file $dst ::patch_vsh::copy_customized_file $src
            }
        }
		# if "--disable-cinavia-protection-4x" enabled, patch it
		if {$::patch_vsh::options(--disable-cinavia-protection-4x)} {
		    log "Swapping videoplayer_plugin.sprx from Debug FW to Retail one..."
			log "...to disable cinavia protection"
			::patch_vsh::swappCinavia
		}
    }		
	
	# proc for dispatching to the appropriate func to path the
	# desired "self" file
    proc patch_self {self} { 		
		::modify_self_file $self ::patch_vsh::patch_elf		
    }

	# proc for patching "nas_plugin.sprx" file
    proc patch_elf {elf} {
	
		###########			PATCHES FOR "NAS_PLUGIN.SPRX"   #############################
		##
		if { [string first "nas_plugin.sprx" $elf 0] != -1 } {		
			
			# if "--allow-pseudoretail-pkg" enabled, patch it
			if {$::patch_vsh::options(--allow-pseudoretail-pkg) } {
				# <><> --- OPTIMIZED FOR 'PATCHTOOL' --- <><> #			
				# (patch seems fine, NO mask req'd)
				#
				# verified OFW ver. 3.55 - 4.55+
				# OFW 3.55 == 0x325C (0x316C)			
				# OFW 3.70 == 0x3264 (0x3174) 
				# OFW 4.00 == 0x3264 (0x3174)
				# OFW 4.46 == 0x3264 (0x3174)
				# OFW 4.55 == 0x3264 (0x3174)
				log "Patching [file tail $elf] to allow pseudo-retail pkg installs"         
				set search  "\x7C\x60\x1B\x78\xF8\x1F\x01\x80\xE8\x7F\x01\x80"
				set replace "\x38\x00\x00\x00"
				set offset 0
				set mask 0				 
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"   
			}			
			# if "--allow-retail-pkg-dex" enabled, patch it
			if {$::patch_vsh::options(--allow-retail-pkg-dex) } {
				# <><> --- OPTIMIZED FOR 'PATCHTOOL' --- <><> #	
				#
				# verified OFW ver. 3.55 - 4.55+
				# OFW 3.55 == 0x371EC (0x370FC)					
				# OFW 4.46 == 0x2E990 (0x2E8A0)
				# OFW 4.50 == 0x2EAC4 (0x2E9D4)				
				log "Patching [file tail $elf] to allow retail pkg installs on dex"         
				set search  "\x55\x60\x06\x3E\x2F\x80\x00\x00\x41\x9E\x01\xB0\x3B\xA1\x00\x80\x3D\x00\x2E\x7B"
				set mask	"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF" ;# <-- mask off the bits/bytes to ignore	
				set replace "\x60\x00\x00\x00"				;# ^^ patch starts here
				set offset 8							 
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"        
			}			
			# if "--allow-debug-pkg" enabled, patch it
			if {$::patch_vsh::options(--allow-debug-pkg) } {
				# <><> --- OPTIMIZED FOR 'PATCHTOOL' --- <><> #						
				#
				# verified OFW ver. 3.55 - 4.55+
				# OFW 3.55 == 0x37350 (0x37250)							
				# OFW 4.30 == 0x2E930 (0x2E840)
				# OFW 4.46 == 0x2EAF4 (0x2EAF4)
				# OFW 4.50 == 0x2EC28 (0x2EB38)
				log "Patching [file tail $elf] to allow debug pkg installs"         				
				set search  "\x2F\x89\x00\x00\x41\x9E\x00\x4C\x38\x00\x00\x00\x81\x22\xAA\xAA\x81\x62\xAA\xAA"
				set mask	"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\xFF\xFF\x00\x00\xFF\xFF\x00\x00" ;# <-- mask off the bits/bytes to ignore	
				set replace "\x60\x00\x00\x00"
				set offset 4									 
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"        
			}			
		} 
		##
		####           END OF PATCHES FOR "NAS_PLUGIN.SPRX"  ########################
		
		
		##########		PATCHES FOR "VSH.SELF"   		#############################
		##
		if { [string first "vsh.self" $elf 0] != -1 } {

			# patch VSH.self for ROGERO patches
			# there are TWO of these patches, easier to
			# just use the "MULTI" patch to hit them both in one shot
			if {$::patch_vsh::options(--patch-rogero-vsh-patches)} {	
				# <><> --- OPTIMIZED FOR 'PATCHTOOL' --- <><> #			
				# (patch seems fine, NO mask req'd)
				#
				# verified OFW ver. 3.60 - 4.55+
				# OFW 3.60 == 0x258DA0,0x25AC18 (0x268DA0,0x26AC18)
				# OFW 4.00 == 0x17E2F0,0x17FF1C (0x18E2F0,0x18FF1C)  
				# OFW 4.46 == 0x184070,0x185CA8 (0x194070,0x195CA8)				
				# OFW 4.55 == 0x1842A8,0x185EE0 (0x1942A8,0x195EE0)
				log "Patching VSH.self with Rogero patch 1&2/4"
				set ::FLAG_PATCH_FILE_MULTI 1				
				
				set search  "\x39\x29\x00\x04\x7C\x00\x48\x28"
				set replace "\x38\x00\x00\x01"
				set offset 4 
				set mask 0					
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"      
				
				log "Patching VSH.self with (downgrader patch) Rogero patch 3/4"	
				# <><> --- OPTIMIZED FOR 'PATCHTOOL' --- <><> #						
				#
				# verified OFW ver. 3.60 - 4.55+
				# OFW 3.60 == 0x30E3D0 (0x31E3D0)
				# OFW 4.00 == 0x2320BC (0x2420BC)  
				# OFW 4.46 == 0x23CFD4 (0x24CFD4)						
				# OFW 4.55 == 0x23E7F8 (0x24E7F48
				if {${::NEWMFW_VER} < "4.00"} {	
					set search	"\x38\x61\x02\x90\x48\x00\x52\x55\x60\x00\x00\x00\x6F\xA0\x80\x01\x2F\x80\x05\x14\x41\x9E\x03\x78\x38\x00\x00\x00\xF8\x1F\x00\x00"
					set mask	"\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
				} else {
					set search	"\x38\x61\x02\x90\x48\x00\x50\x65\x6F\xA0\x80\x01\x2F\x80\x05\x14\x41\x9E\x03\x54\x38\x00\x00\x00\xF8\x1F\x00\x00"
					set mask	"\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
				}
				set replace "\x60\x00\x00\x00";#patch starts here
				set offset 4				
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"														
				
				log "Patching VSH.self with Rogero patch 4/4"	
				# <><> --- OPTIMIZED FOR 'PATCHTOOL' --- <><> #			
				# (patch seems fine, NO mask req'd)
				#
				# verified OFW ver. 3.60 - 4.55+
				# OFW 3.55 == 0x305F50 (0x315F50)
				# OFW 3.60 == 0x6BC38D (0x6CC38D)  
				# OFW 4.00 == 0x697A8D (0x6B7A8D)  
				# OFW 4.46 == 0x6AA38D (0x6BA38D)					
				# OFW 4.55 == 0x6AAF8D (0x6BAF8D)
				set search     "\x61\x64\x5F\x72\x65\x63\x65\x69\x76\x65\x5F\x65\x76\x65\x6E\x74"
				append search  "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
				append search  "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
				append search  "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
				append search  "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
				append search  "\x00\x00\x00\x24\x13\xBC\xC5\xF6\x00\x33\x00\x00\x00"
				set replace    "\x34"
				set offset 93
				set mask 0					
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"											
			}			
			# if "--allow-unsigned-app" enabled, patch it
			if {$::patch_vsh::options(--allow-unsigned-app)} {
				# <><> --- OPTIMIZED FOR 'PATCHTOOL' --- <><> #			
				# (patch seems fine, NO mask req'd)
				#
				# verified OFW ver. 3.55 - 4.55+
				# OFW 3.55 == 0x5FFEE8 (0x60FEE8)			
				# OFW 3.60 == 0x60B29C (0x61B29C)
				# OFW 4.00 == 0x5DB8B8 (0x5FB8B8)  				
				# OFW 4.46 == 0x5EA584 (0x5FA584)				
				# OFW 4.55 == 0x5EAAC0 (0x5FAAC0)
				log "Patching [file tail $elf] to allow running of unsigned applications 1/2"         
				set search  "\xF8\x21\xFF\x81\x7C\x08\x02\xA6\x38\x61\x00\x70\xF8\x01\x00\x90\x4B\xFF\xFF\xE1\x38\x00\x00\x00"
				set replace "\x38\x60\x00\x01\x4E\x80\x00\x20"
				set offset 0
				set mask 0				 
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"        
			 
				# <><> --- OPTIMIZED FOR 'PATCHTOOL' --- <><> #			
				# (patch seems fine, NO mask req'd)
				#
				# verified OFW ver. 3.55 - 4.55+
				# OFW 3.55 == 0x30A7D4 (0x31A7D4)			
				# OFW 3.60 == 0x312ED4 (0x322ED4) 
				# OFW 4.00 == 0x236CC4 (0x246CC4) 
				# OFW 4.46 == 0x241C40 (0x251C40)				
				# OFW 4.55 == 0x243464 (0x253464)
				log "Patching [file tail $elf] to allow running of unsigned applications 2/2"
				set search  "\xA0\x7F\x00\x04\x39\x60\x00\x01\x38\x03\xFF\x7F\x2B\xA0\x00\x01\x40\x9D\x00\x08\x39\x60\x00\x00"
				set replace "\x60\x00\x00\x00"
				set offset 20
				set mask 0				 
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"        
			}
			# if "--patch-vsh-react-psn-v2-4x" enabled, patch it
			if {$::patch_vsh::options(--patch-vsh-react-psn-v2-4x)} {
				# <><> --- OPTIMIZED FOR 'PATCHTOOL' --- <><> #							
				#
				# verified OFW ver. 3.55 - 4.55+
				# OFW 3.55 == 0x30B230 (0x31B230)			
				# OFW 3.60 == 0x313930 (0x323930)				
				# OFW 4.00 == 0x2376CC (0x2476CC)	
				# OFW 4.30 == 0x240974 (0x250974)
				# OFW 4.46 == 0x242648 (0x252648)				
				# OFW 4.55 == 0x243E6C (0x253E6C)
				log "Patching [file tail $elf] to allow unsigned act.dat & .rif files"   
				## much easier to just find the entire block, as it exists the same in ALL OFW versions, rather then
				## trying to find smaller snippets, as pieces of this code is all throughout 'vsh'...									
				set search    "\xF8\x21\xFF\x91\x7C\x08\x02\xA6\xF8\x01\x00\x80\x48\x39\xB3\xA9\x60\x00\x00\x00\xE8\x01\x00\x80\x7C\x63\x07\xB4\x7C\x08\x03\xA6"
				set mask	  "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
				
				append search "\x38\x21\x00\x70\x4E\x80\x00\x20\xF8\x21\xFF\x91\x7C\x08\x02\xA6\xF8\x01\x00\x80\x4B\xDB\xE7\x2D\x60\x00\x00\x00\xE8\x01\x00\x80"
				append mask   "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
																											  ;# ^^ patch starts here
				append search "\x7C\x63\x07\xB4\x7C\x08\x03\xA6\x38\x21\x00\x70\x4E\x80\x00\x20"
				append mask	  "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"				
				set replace   "\x38\x60\x00\x00"
				set offset 52						 
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"        
			}
			# if "--patch-vsh-no-delete-actdat" enabled, patch it
			if {$::patch_vsh::options(--patch-vsh-no-delete-actdat)} {
				# <><> --- OPTIMIZED FOR 'PATCHTOOL' --- <><> #							
				#
				# verified OFW ver. 3.55 - 4.55+
				# OFW 3.55 == 0x30AC90 (0x31AC90)			
				# OFW 3.70 == 0x31BA2C (0x32BA2C)  				
				# OFW 4.00 == 0x23712C (0x23812C)  	
				# OFW 4.46 == 0x2420A8 (0x2520A8)				
				# OFW 4.55 == 0x2438CC (0x2538CC)
				log "Patching [file tail $elf] to disable deleting of unsigned act.dat & .rif files"
			   if {${::NEWMFW_VER} < "4.00"} {				   
					set search    "\xEB\x61\x00\xA8\xEB\x81\x00\xB0\xEB\xA1\x00\xB8\xEB\xC1\x00\xC0\xEB\xE1\x00\xC8\x38\x21\x00\xD0\x4E\x80\x00\x20\xF8\x21\xFF\x91"
					set mask	  "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
					
					append search "\x7C\x08\x02\xA6\xF8\x01\x00\x80\x48\x31\xB4\x65\x60\x00\x00\x00\x38\x03\xFF\xFF\x7C\x60\x03\x78\x7C\x00\xFE\x70\x7C\x63\x00\x38"
					append mask	  "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
					
					append search "\xE8\x01\x00\x80\x38\x21\x00\x70\x7C\x63\x07\xB4\x7C\x08\x03\xA6\x4E\x80\x00\x20"
					append mask	  "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"					
			   } else {	
					set search    "\xEB\x61\x00\xA8\xEB\x81\x00\xB0\xEB\xA1\x00\xB8\xEB\xC1\x00\xC0\xEB\xE1\x00\xC8\x38\x21\x00\xD0\x4E\x80\x00\x20\xF8\x21\xFF\x91"
					set mask	  "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
					
					append search "\x7C\x08\x02\xA6\xF8\x01\x00\x80\x48\x3D\x68\xD9\x38\x03\xFF\xFF\x7C\x60\x03\x78\x7C\x00\xFE\x70\x7C\x63\x00\x38\xE8\x01\x00\x80"
					append mask	  "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"				
					
					append search "\x38\x21\x00\x70\x7C\x63\x07\xB4\x7C\x08\x03\xA6\x4E\x80\x00\x20"
					append mask	  "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"							
				}	
				set replace   "\x38\x60\x00\x00"
				set offset 40							
				# PATCH THE ELF BINARY
				catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]" 				
			}									
		}
		#
		###########   END OF PATCHES TO "NAS_PLUGIN.SPRX" ###################################################
    }

    proc get_fw_release {filename} {
        set results [grep "^release:" $filename]
        set release [string trim [regsub "^release:" $results {}] ":"]
        return [string trim $release]
    }

    proc get_fw_build {filename} {
        set results [grep "^build:" $filename]
        set build [string trim [regsub "^build:" $results {}] ":"]
        return [string trim $build]
    }

    proc get_fw_target {filename} {
        set results [grep "^target:" $filename]
        set target [regsub "^target:" $results {}]
        return [string trim $target]
    }

    proc get_fw_security {filename} {
        set results [grep "^security:" $filename]
        set security [string trim [regsub "^security:" $results {}] ":"]
        return [string trim $security]
    }

    proc get_fw_system {filename} {
        set results [grep "^system:" $filename]
        set system [string trim [regsub "^system:" $results {}] ":"]
        return [string trim $system]
    }

    proc get_fw_x3 {filename} {
        set results [grep "^x3:" $filename]
        set x3 [string trim [regsub "^x3:" $results {}] ":"]
        return [string trim $x3]
    }

    proc get_fw_paf {filename} {
        set results [grep "^paf:" $filename]
        set paf [string trim [regsub "^paf:" $results {}] ":"]
        return [string trim $paf]
    }

    proc get_fw_vsh {filename} {
        set results [grep "^vsh:" $filename]
        set vsh [string trim [regsub "^vsh:" $results {}] ":"]
        return [string trim $vsh]
    }

    proc get_fw_sys_jp {filename} {
        set results [grep "^sys_jp:" $filename]
        set sys_jp [string trim [regsub "^sys_jp:" $results {}] ":"]
        return [string trim $sys_jp]
    }

    proc get_fw_ps1emu {filename} {
        set results [grep "^ps1emu:" $filename]
        set ps1emu [string trim [regsub "^ps1emu:" $results {}] ":"]
        return [string trim $ps1emu]
    }

    proc get_fw_ps1netemu {filename} {
        set results [grep "^ps1netemu:" $filename]
        set ps1netemu [string trim [regsub "^ps1netemu:" $results {}] ":"]
        return [string trim $ps1netemu]
    }

    proc get_fw_ps1newemu {filename} {
        set results [grep "^ps1newemu:" $filename]
        set ps1newemu [string trim [regsub "^ps1newemu:" $results {}] ":"]
        return [string trim $ps1newemu]
    }

    proc get_fw_ps2emu {filename} {
        set results [grep "^ps2emu:" $filename]
        set ps2emu [string trim [regsub "^ps2emu:" $results {}] ":"]
        return [string trim $ps2emu]
    }

    proc get_fw_ps2gxemu {filename} {
        set results [grep "^ps2gxemu:" $filename]
        set ps2gxemu [string trim [regsub "^ps2gxemu:" $results {}] ":"]
        return [string trim $ps2gxemu]
    }

    proc get_fw_ps2softemu {filename} {
        set results [grep "^ps2softemu:" $filename]
        set ps2softemu [string trim [regsub "^ps2softemu:" $results {}] ":"]
        return [string trim $ps2softemu]
    }

    proc get_fw_pspemu {filename} {
        set results [grep "^pspemu:" $filename]
        set pspemu [string trim [regsub "^pspemu:" $results {}] ":"]
        return [string trim $pspemu]
    }

    proc get_fw_emerald {filename} {
        set results [grep "^emerald:" $filename]
        set emerald [string trim [regsub "^emerald:" $results {}] ":"]
        return [string trim $emerald]
    }

    proc get_fw_bdp {filename} {
        set results [grep "^bdp:" $filename]
        set bdp [string trim [regsub "^bdp:" $results {}] ":"]
        return [string trim $bdp]
    }

    proc get_fw_auth {filename} {
        set results [grep "^auth:" $filename]
        set auth [string trim [regsub "^auth:" $results {}] ":"]
        return [string trim $auth]
    }	
	
    # func to copy specific file over
    proc copy_customized_file { dst src } {
        if {[file exists $src] == 0} {
            die "$src does not exist"
        } else {
            if {[file exists $dst] == 0} {
                die "$dst does not exist"
            } else {
                log "Replacing default firmware file [file tail $dst] with [file tail $src]"
                copy_file -force $src $dst
            }
        }
    }
	# proc for "swapping" debug versus retail
	# 'Cinavia' files
	proc swappCinavia {} {
        set copyCinavia [file copy -force ${::DCINAVIA} ${::RCINAVIA}]
	    set catch [catch $copyCinavia]
	    set batch [::modify_devflash_file ${::RCINAVIA} $catch]
        if {$batch == 0} {
	        log "Successfull swapped sprx and disabled cinavia protection"
	    } else {
	        log "Error!! Something went very wrong"
	    }
    }
}
#
# ############  END OF patch_vsh.TCL ######################################