#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

proc ego {} {
    puts "PS3MFW Creator v${::PS3MFW_VERSION}"
    puts "    Copyright (C) 2011 Project PS3MFW"
    puts "    This program comes with ABSOLUTELY NO WARRANTY;"
    puts "    This is free software, and you are welcome to redistribute it"
    puts "    under certain conditions; see COPYING for details."
    puts ""
    puts "    Developed By :"
    puts "    Anonymous Developers"
    puts ""
}

proc ego_gui {} {
    log "PS3MFW Creator v${::PS3MFW_VERSION}"
    log "    Copyright (C) 2011 Project PS3MFW"
    log "    This program comes with ABSOLUTELY NO WARRANTY;"
    log "    This is free software, and you are welcome to redistribute it"
    log "    under certain conditions; see COPYING for details."
    log ""
    log "    Developed By :"
    log "    Anonymous Developers"
    log ""
}

proc clean_up {} {
    log "Deleting output files"
    catch_die {file delete -force -- ${::CUSTOM_PUP_DIR} ${::ORIGINAL_PUP_DIR} ${::HASH_DIR} ${::OUT_FILE}} \
        "Could not cleanup output files"
}

proc unpack_source_pup {pup dest} {
    log "Unpacking source PUP [file tail ${pup}]"
    catch_die {pup_extract ${pup} ${dest}} "Error extracting PUP file [file tail ${pup}]"

    # Check for license.txt for people using older version of ps3tools
    set license_txt [file join ${::CUSTOM_UPDATE_DIR} license.txt]
    if {![file exists ${::CUSTOM_LICENSE_XML}] && [file exists ${license_txt}]} {
        set ::CUSTOM_LICENSE_XML ${license_txt}
    }
}

proc pack_custom_pup {dir pup} {
    set build ${::PUP_BUILD}
    set obuild [get_pup_build]
	log "PUP original build:$obuild"
    if {${build} == "" || ![string is integer ${build}] || ${build} == ${obuild}} {
        set build ${obuild}        
    }
    # create pup
    log "Packing Modified PUP:\"[file tail ${pup}]\", BUILD:$build" 1
    catch_die {pup_create ${dir} ${pup} $build} "Error packing PUP file [file tail ${pup}]"
}


proc build_mfw {input output tasks} {
    global options
	 # array for saving off SELF-SCE Hdr fields
	 # for "LV0" for use by unself/makeself routines
	array set LV0_SCE_HDRS {
		--KEYREV ""
		--AUTHID ""
		--VENDORID ""
		--SELFTYPE ""
		--APPVERSION ""
		--FWVERSION ""
		--CTRLFLAGS ""
		--CAPABFLAGS ""
		--COMPRESS ""
	}

	set ::AUTOCOS "0"
	if {$::options(--auto-cos)} {
		set ::AUTOCOS "1"
    }

    set ::selected_tasks [sort_tasks ${tasks}]

    # print out ego info
    ego_gui

    if {${input} == "" || ${output} == ""} {
        die "Must specify an input and output file"
    }
    if {![file exists ${input}]} {
        die "Input file does not exist"
    }

	# if {!$::options(--341-CEX) || !$::options(--355-CEX) || !$::options(--3XX-DEX) || !$::options(--4XX-CEX) || !$::options(--4XX-DEX)} {
        # die "Please select Base Firmware in global options"
	# }

    log "Selected tasks : ${::selected_tasks}"

    if {[info exists ::env(HOME)]} {
        debug "HOME=$::env(HOME)"
    }
    if {[info exists ::env(USERPROFILE)]} {
        debug "USERPROFILE=$::env(USERPROFILE)"
    }
    if {[info exists ::env(PATH)]} {
        debug "PATH=$::env(PATH)"
    }

    clean_up

	# if {$::options(--341-CEX) == "0" || $::options(--355-CEX) == "0" || $::options(--3XX-DEX) == "0" || $::options(--4XX-CEX) == "0" || $::options(--4XX-DEX) == "0" || $::options(--4XX-DEH) == "0"} {
		# die "Please select Base Firmware in global options"
	# }

    # PREPARE PS3UPDAT.PUP for modification
    unpack_source_pup ${input} ${::ORIGINAL_PUP_DIR}
	
    # Check for update_flags.txt if CEX, DEX, DECR, SEX
	log "Checking Target Firmware"
    if {![file exists ${::ORIGINAL_UPDATE_FLAGS_TXT}]} {
		debug "Getting Target Firmware from: [file tail ${::ORIGINAL_UPDATE_FLAGS_TXT}]"
		set tid_str "DECR"
    } else {
		set fdf [open [file join ${::ORIGINAL_UPDATE_FLAGS_TXT}] r]
		set flag [string trim [read $fdf]]
		close $fdf
		if {${flag} == "0100"} {
			set tid_str "DEX"
		} elseif {${flag} == "0300"} {
			set tid_str "SEX"
		} elseif {${flag} == "0000"} {
			set tid_str "CEX"
		}
	}
	log "Target Firmware = '$tid_str'"

	# set the pup version into a variable so commands later can check it and do fw specific thingy's
	# save off the "OFW MAJOR.MINOR" into a global for usage throughout
	debug "checking pup version"
    set ::SUF [::get_pup_version ${::ORIGINAL_VERSION_TXT}]	
	if { [regexp "(^\[0-9]{1,2})\.(\[0-9]{1,2})(.*)" $::SUF all ::OFW_MAJOR_VER ::OFW_MINOR_VER SubVerInfo] } {		
		set ::NEWMFW_VER [format "%.1d.%.2d" $::OFW_MAJOR_VER $::OFW_MINOR_VER]	
		if { $SubVerInfo != "" } {
			log "Getting pup version OK! var = ${::NEWMFW_VER} (subversion:$SubVerInfo)" 
		} else { 
			log "Getting pup version OK! var = ${::NEWMFW_VER}" 
		}		
	} else {
		die "Getting pup version FAILED! Exiting!" 1
	}
	
	# extract "custom_update.tar
    extract_tar ${::ORIGINAL_UPDATE_TAR} ${::ORIGINAL_UPDATE_DIR}

	log "Searching for new SPKG tar....." 1
    if {[file exists ${::ORIGINAL_SPKG_TAR}]} {
		log "\"spkg_hdr.tar\" found in working dir. Using \"NEW PKG\" routine" 1
        extract_tar ${::ORIGINAL_SPKG_TAR} ${::ORIGINAL_SPKG_DIR}
    } else {
		log "No SPKG tar found in working dir. Using \"OLD PKG\" routine" 1
	}

	# unpack devflash files	
	# (do this before the copy, so we have the unpacked
	#  flash files in the PS3OFW directory)
    log "Unpacking all dev_flash files....." 
    unpkg_devflash_all ${::ORIGINAL_UPDATE_DIR} ${::ORIGINAL_DEVFLASH_DIR}	
	if {$::options(--dev3)} {
		log "EXPERIMENTAL: Unpacking all dev_flash3 files....." 
		unpkg_devflash3_all ${::ORIGINAL_UPDATE_DIR} ${::ORIGINAL_DEVFLASH3_DIR}
	}

	# unpack the CORE_OS files here, pass the 
	# SELF-SCE Headers array
	if {$::options(--auto-cos)} {
		log "LV0 Option selected. Unpacking LV0....." 
		::unpack_coreos_files ${::ORIGINAL_PUP_DIR} LV0_SCE_HDRS			
	}

	### DO THE COPY HERE, SO WE HAVE A MIRROR OF ALL REQ'D
	### files in the 'PS3MFW-OFW' directory.
	# copy original UNPACKED PUP/assoc. files to working dir
	log "Please WAIT.....copying unpacked OFW to MFW dirs....."	
    # copy_dir ${::ORIGINAL_PUP_DIR} ${::CUSTOM_PUP_DIR}

    # copy original PUP to working dir
    copy_file ${::ORIGINAL_PUP_DIR} ${::CUSTOM_PUP_DIR}

    # Execute tasks
    foreach task ${::selected_tasks} {
        log "******** Running task $task **********"
        eval [string map {- _} ${task}::main]
    }

	#repack the CORE_OS files here, pass the 
	# SELF-SCE Headers array	
    set lv0 [file join ${::CUSTOM_COSUNPKG_DIR} ${::LV0NEW}]	
    if {[file exists $lv0]} {
		if {$::options(--auto-cos)} {
			::repack_coreos_files LV0_SCE_HDRS
		}
	}

	log "******** Completed tasks **********"

    # RECREATE PS3UPDAT.PUP
    file delete -force ${::CUSTOM_DEVFLASH_DIR}
	debug "custom dev_flash deleted"	
	if {$::options(--dev3)} {
		file delete -force ${::CUSTOM_DEVFLASH3_DIR}
		debug "custom dev_flash3 deleted"	
	}
    file delete -force ${::CUSTOM_COSUNPKG_DIR}
    file delete -force ${::CUSTOM_UNPKG_DIR}
	debug "custom CORE_OS deleted"	

    set meta [file join ${::PS3MFW_DIR}	metadata_decrypted]
    if {[file exists $meta]} {
		file delete -force $meta
		debug "custom metadata deleted"	
	}

    if {[file exists ${::HASH_DIR}]} {
		file delete -force ${::HASH_DIR}
		debug "custom hash folder deleted"	
	}

    if {[file exists ${::CUSTOM_SPKG_DIR}]} {
		set filesSPKG [lsort [glob -nocomplain -tails -directory ${::CUSTOM_SPKG_DIR} *.1]]
		debug "spkg's added to list"
	}
    set files [lsort [glob -nocomplain -tails -directory ${::CUSTOM_UPDATE_DIR} *.pkg]]
	debug "pkg's added to list"
    eval lappend files [lsort [glob -nocomplain -tails -directory ${::CUSTOM_UPDATE_DIR} *.img]]
	debug "img's added to list"
    eval lappend files [lsort [glob -nocomplain -tails -directory ${::CUSTOM_UPDATE_DIR} dev_flash3_*]]
	debug "dev_flash3 added to list"
    eval lappend files [lsort [glob -nocomplain -tails -directory ${::CUSTOM_UPDATE_DIR} dev_flash_*]]
	debug "dev_flash added to list"

	log "Please WAIT....Building new PUP TAR file(s)....."	

	if {[file exists ${::ORIGINAL_UPDATE_TAR}]} {
		if {$::options(--341-CEX)} {
			create_cex_tar341_update ${::CUSTOM_UPDATE_TAR}  ${::CUSTOM_UPDATE_DIR} ${files}
		} elseif {$::options(--355-CEX)} {
			create_cex_tar355_update ${::CUSTOM_UPDATE_TAR}  ${::CUSTOM_UPDATE_DIR} ${files}
		} elseif {$::options(--3XX-DEX)} {
			create_dex_tar3_update ${::CUSTOM_UPDATE_TAR}  ${::CUSTOM_UPDATE_DIR} ${files}
		} elseif {$::options(--4XX-CEX)} {
			create_cex_tar4_update ${::CUSTOM_UPDATE_TAR}  ${::CUSTOM_UPDATE_DIR} ${files}
		} elseif {$::options(--4XX-DEX)} {
			create_dex_tar4_update ${::CUSTOM_UPDATE_TAR}  ${::CUSTOM_UPDATE_DIR} ${files}
		} elseif {$::options(--3XX-DEH)} {
			create_deh_tar3_update ${::CUSTOM_UPDATE_TAR}  ${::CUSTOM_UPDATE_DIR} ${files}
		} elseif {$::options(--4XX-DEH)} {
			create_deh_tar4_update ${::CUSTOM_UPDATE_TAR}  ${::CUSTOM_UPDATE_DIR} ${files}
		} else {
			die "Please select Base Firmware in global options"
		}
		log "\"update_files.tar\" created" 1
	}

	if {[file exists ${::ORIGINAL_SPKG_TAR}] && [file exists ${::CUSTOM_SPKG_DIR}]} {
		if {$::options(--3XX-DEX)} {
			create_dex_tar3_spkg ${::CUSTOM_SPKG_TAR}  ${::CUSTOM_SPKG_DIR} ${filesSPKG}
		} elseif {$::options(--4XX-CEX)} {
			create_cex_tar4_spkg ${::CUSTOM_SPKG_TAR}  ${::CUSTOM_SPKG_DIR} ${filesSPKG}
		} elseif {$::options(--4XX-DEX)} {
			create_dex_tar4_spkg ${::CUSTOM_SPKG_TAR}  ${::CUSTOM_SPKG_DIR} ${filesSPKG}
		} elseif {$::options(--3XX-DEH)} {
			create_deh_tar3_spkg ${::CUSTOM_SPKG_TAR}  ${::CUSTOM_SPKG_DIR} ${filesSPKG}
		} elseif {$::options(--4XX-DEH)} {
			create_deh_tar4_spkg ${::CUSTOM_SPKG_TAR}  ${::CUSTOM_SPKG_DIR} ${filesSPKG}
		} else {
			die "Please select Base Firmware in global options"
		}
		log "\"spkg_hdr.tar\" created" 1
	}

	# cleanup any previous output builds
	set final_output "${::OUT_FILE}_$::OFW_MAJOR_VER.$::OFW_MINOR_VER.$tid_str-PS3UPDAT.PUP"
	catch_die {file delete -force -- ${::OUT_FILE}} "Could not cleanup output files"
	
	# finalize the completed PUP
    pack_custom_pup ${::CUSTOM_PUP_DIR} ${final_output}
	log "CUSTOM FIMWARE VER:$::OFW_MAJOR_VER.$::OFW_MINOR_VER BUILD-$tid_str COMPLETE!!!"
}
