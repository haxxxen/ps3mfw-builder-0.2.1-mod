#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 2600
# Description: Spoof firmware build / version

# Option --spoof: Select firmware version to spoof
# Type --spoof: combobox { {3.15 38031 001:CEX-ww} {3.41 45039 001:CEX-ww} {3.55 47516 001:CEX-ww} {3.56 48246 001:CEX-ww} {3.60 48686 001:CEX-ww} }
    
namespace eval ::spoof_version {

    array set ::spoof_version::options {
      --spoof "3.60 48686 001:CEX-ww"
    }

    proc main {} {
      variable options

      set release [lindex $options(--spoof) 0]
      set build [lindex $options(--spoof) 1]
      set target [lindex $options(--spoof) 2]
      set auth [lindex $options(--spoof) 1]

      if {$release != "" || $build != "" || $target != "" || $auth != ""} {
        log "Changing firmware version.txt & index.dat file"
        ::modify_devflash_file [file join dev_flash vsh etc version.txt] ::spoof_version::version_txt
      }
      if {$build != "" || $auth != ""} {
        log "Patching vsh.self"
        ::modify_devflash_file [file join dev_flash vsh module vsh.self] ::spoof_version::patch_self
      }
    }

    proc patch_self {self} {
      ::modify_self_file $self ::spoof_version::patch_elf
    }

    proc patch_elf {elf} {
      variable options

      set release [lindex $options(--spoof) 0]
      set build [lindex $options(--spoof) 1]

      log "Patching [file tail $elf] to spoof version and build"

      debug "Patching version number"
      set search "99.99"
      debug "search: $search"
      set major [lindex [split $release "."] 0]
      set minor [lindex [split $release "."] 1]
      set replace "[format %0.2d ${major}].[format %0.2d ${minor}]"
	  set offset 0
	  set mask 0				 
      debug "replace: $replace"
	  # PATCH THE ELF BINARY
		  catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"   

      debug "Patching build number"
      set search "[format %0.5d [::get_pup_build]]"
      debug "search: $search"
      set replace "[format %0.5d $build]"
	  set offset 0
	  set mask 0				 
      debug "replace: $replace"
	  # PATCH THE ELF BINARY
		  catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"   

#      debug "Patching 0x31a7c0" 
#      set search "\x48\x00\x00\x38\xa0\x7f\x00\x04\x39\x60\x00\x01"
#      set replace "\x38\x60\x00\x82"
#      catch_die {::patch_elf $elf $search 4 $replace} "Unable to patch self [file tail $elf]"

#      debug "Patching ..."
#      set search "\x4b\xff\xfe\x80\xf8\x21\xff\x81\x7c\x08\x02\xa6\x38\x61\x00\x70"
#      set replace "\x38\x60\x00\x01\x4e\x80\x00\x20"
#      catch_die {::patch_elf $elf $search 4 $replace} "Unable to patch self [file tail $elf]"

      debug "Patching 0x48d030"
      set search    "\xeb\xe1\x00\x80\x38\x21\x00\x90\x7c\x08\x03\xa6\x4e\x80\x00\x20"
      append search "\xf8\x21\xff\x61\x7c\x08\x02\xa6\xfb\xe1\x00\x98\xf8\x01\x00\xb0"
      append search "\x7c\x7f\x1b\x78\x38\x00\x00\x00\x38\x61\x00\x74\xfb\x81\x00\x80"
      set replace "\x38\x60\x00\x00\x4e\x80\x00\x20"
	  set offset 16
	  set mask 0				 
	  # PATCH THE ELF BINARY
		  catch_die {::patch_elf $elf $search $offset $replace $mask} "Unable to patch self [file tail $elf]"   
    }

    proc get_fw_release {filename} {
      debug "Getting firmware release from [file tail $filename]"
      set results [grep "^release:" $filename]
      set release [string trim [regsub "^release:" $results {}] ":"]
      return [string trim $release]
    }

    proc get_fw_build {filename} {
      debug "Getting firmware build from [file tail $filename]"
      set results [grep "^build:" $filename]
      set build [string trim [regsub "^build:" $results {}] ":"]
      return [string trim $build]
    }

    proc get_fw_target {filename} {
      debug "Getting firmware target from [file tail $filename]"
      set results [grep "^target:" $filename]
      set target [regsub "^target:" $results {}]
      return [string trim $target]
    }

    proc get_fw_auth {filename} {
      debug "Getting firmware auth from [file tail $filename]"
      set results [grep "^auth:" $filename]
      set auth [string trim [regsub "^auth:" $results {}] ":"]
      return [string trim $auth]
    }

    proc version_txt {filename} {
      variable options

      set release [lindex $options(--spoof) 0]
      set build [lindex $options(--spoof) 1]
      set target [lindex $options(--spoof) 2]
      set auth [lindex $options(--spoof) 1]

      set fd [open $filename r]
      set data [read $fd]
      close $fd

      if {$release != [get_fw_release $filename]} {
        debug "Setting firmware release to $release"
        set major [lindex [split $release "."] 0]
        set minor [lindex [split $release "."] 1]
        set nano "0"
        set data [regsub {release:[0-9]+\.[0-9]+:} $data "release:[format %0.2d ${major}].[format %0.2d ${minor}][format %0.2d ${nano}]:"]
      }

      if {$build != [get_fw_build $filename]} {
        debug "Setting firmware build in to $build"
        set build_num $build
        set build_date [lindex [split [lindex [split [::spoof_version::get_fw_build $filename] ":"] 1] ","] 1]
        set data [regsub {build:[0-9]+,[0-9]+:} $data "build:${build_num},${build_date}:"]
      }

      if {$target != [get_fw_target $filename]} {
        debug "Setting firmware target to $target"
        set target_num [lindex [split $target ":"] 0]
        set target_string [lindex [split $target ":"] 1]
        set data [regsub {target:[0-9]+:[A-Z]+-ww} $data "target:${target_num}:${target_string}"]
      }

      if {$auth != [get_fw_auth $filename]} {
        debug "Setting firmware auth to $auth"
        set data [regsub {auth:[0-9]+:} $data "auth:$auth:"]
      }

      set fd [open $filename w]
      puts -nonewline $fd $data
      close $fd

      set index_dat [file join [file dirname $filename] index.dat]
      shell "dat" [file nativename $filename] [file nativename $index_dat]
    }
}

