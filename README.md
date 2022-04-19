# ps3mfw-builder-0.2.1-mod
modified version of toolboy's MFW-Builder (and original MFW-Builder 0.2.1)

ATTENTION: Just have noticed, currently lv0tool does not work with isorebuilder and has to be fixed, so please do no
lv0 (lv1ldr, lv2ldr, isoldr, appldr) modifications for now. Sorry for any inconvenience and damage it may has brought.
It may work with scetool, but have not tried so far

NOTES:
- This modified mfwbuilder's purpose is mainly to modify all the different CFW flavours
- PLEASE DO NOT TRY A MFW WITHOUT HARDWARE FLASHER
- Please check Base firmware option, so correct tarballs can be produced (each version/target has its own)
- to use scetool for resigning prx(s) or elf(s), just leave both options for self-/isorebuilder unticked. if you wanna use
self-/isorebuilder (they make files more genuine with same size) check both options (recommended)
- when you want to replace files manually in coreos/devflash/devflash3 and using windows explorer, I recommend you close explorer
after you have replaced files. otherwise, you could get an error about files not accessible
- AGAIN, PLEASE DO NOT FORGET TO HAVE A HARDWARE FLASHER AT HAND, especially when modifying any coreos file or using
NAND PS3

Changes:

- using old routines to repack tar archive, packages and CORE_OS
- using toolboy's new routines/tools to extract PUP, packages and flash files
- using toolboy's patchtool to patch files
- option to use either self_rebuilder/iso_rebuilder or scetool to resign selfs
- option to extract/modify/repack lv0 on 3.6+ MFW (no automated process)
- different way of detecting spkg support for 3.56+ MFW (3.55 dex downgrader/REBUG 3.55.4 work as well now)
- toolboy's OtherOS++ tasks fixed (glevand's tasks used as source)
- glevand's 3.55 (OtherOS) tasks fixed to work with patchtool
- personalized tasks
- pkgtool "hexified" to work on WindowsXP (SP3)
- modified version of COBRA's hashcalc app added, to make it work with MFW-Builder
- COBRA CFWs can be patched now and hashes can be directly replaced in stage2 file(s)
- fixed tar creation routine, so now you HAVE to select a base firmware version, or else it will fail
- added a batch script to update keys. you have to type in the firmware version first in format XXX (e.g. 484)
  and then in format X00XX (e.g. 40084). keys will then automatically generated based on 4.81 set of keys
- finally fixed lv0 ctype keys thanks to littlebalup and Joonie. I am sorry if I have caused any serious problems to anyone!
- added target prefix to output file, depending on target of input file (CEX, DEX, SEX, DECR)
- added DECR tarball option, so now 3.55 and 4.xx DECR firmwares can be modified
  
small explanation of tasks:
- patch_cos: Has all basic COREOS patches you would need for a standard MFW and is based on toolboy. I only have added appldr lv2memory protection removal patch and appldr signature patch to be able to exit FSM on 4.XX (NOTE: For lv0 patches on 4.XX, you have to select lv0 extract option. Also current payloads are not working for DEX MFW thanks to Joonie for reporting)
- patch_oos: glevand's task ported to work with 4.XX MFW as well. You can now make a 4.XX OtherOS++ pup, so no more 3.55 times
- broken_bluray: It is an AIO task for a FULL noBD or noBluetooth MFW. for a noBD MFW, select both BD options and also zecoxao's lv1 patch
- patch_info: This will patch old 3.55.4 / 4.21.2 REX CFW to a FULL working D-REX version
- change_devflash_files: Use this task whenever you want to replace any devflash file. This has to be done manually though, and keep in mind that you have to close windows explorer when you have replaced. Otherwise windoof will lock the folder and mfwbuilder cannot proceed with script and spits an error.
- change_devflash3_files: Experimental ! this works same like change_devflash_files, only with devflash3
- patch_rsod: Patch basic_plugins.sprx with RSOD bypass, to be able to boot to XMB -> it does not fix the error!
- patch_premo: It has all remote-play patches as well as mysis' advanced sfo patch
- change_xml_files: This can replace automatically any XMB xml file. You only have to choose the path to your modified file. When empty, it skips the file and none will be replaced
- spoofer_update: This will let you update or set a spoofer on any MFW or CFW. It also has advanced SEN patches, but those do only work on 4.3+ CFWs
- cobra_selfs: This is based on REBUG COBRA only and will let you replace automatically vsh(s), cobra stage2 files and index.dat / version.txt. Leave empty box for no replacement.
- patch_epilepsy: This will let you patch out that extra health screen, with epilepsy warning
- patch_cinavia: This will let you remove cinavia copy-protection on hdd content
- patch_gameboot: This will let you enable that old 2.78-OFW gameboot sound and animation. The sound files will be automatically copied to matching coldboot devflash package and also remove 01.p3t file, to give more freespace on devflash
- patch_fself: This will let you run FSELFs on a CEX CFW for both kernels, even loading DEX kernel on CEX
- patch_appldr_unsigned_apps: This will let you patch (4.21 ONLY) appldr for running unsigned apps, based on DEMONHADES. Now you can remove kakaroto's unsigned app vsh patch, which disables npdrm_fself on DEX. So no more shutdowns or blackscreens when kakaroto's patch is removed on a CEX CFW
- repair_hashes: This will let you repair modified COBRA hashes yourself without recompiling new stage2 file(s). It is reduced only to basic_plugins.sprx, game_ext_plugin.sprx, vsh.self, vsh.self.cexsp and vsh.self.swp, but those modules are the only ones that can be patched with MFW-Builder and besides, the others do not need to get patched. Just select any patch task for any of these modules and select the repair_hashes task. It will run always at the very last instance, so other patches can be applied beforehand. You can also patch manually and then just run the task, it will do everything itself. NOTE: For official REBUG COBRAs you have to first select the spoofer task and let it patch all vsh files, to get same hashes in the end! It only works for REBUG 4.21-4.80 COBRA, DARKNET 4.70 v5/4.81 COBRA and habib 4.75 v4 COBRA for now and only for original version.
- patch_db: This will let you patch a 4.xx OFW, to disable ECDSA checks, that it can be installed on CFW for dualboot setups.
- patch_rsx_oc: This will let you patch lv1.self, to overclock RSX Speeds (600MHz Core / 750MHz Memory)

NOTE FOR COBRA CFWs:
When patching a COBRA CFW, keep in mind to update COBRA hashes on protected modules.

Credits go to all the original authors of MFW-BUILDER and its tools and of course Graf Chokolo and glevand. Besides, credits to toolboy for his amazing (mfw)tools and mysis, who has made most of the patches possible! And finally credits to those (brave enough ;)) testing this modified version of mfwbuilder.

Last but not least, some reminder to all, on the already gone scener "bitsbubba", who initially inspired me with his "NFW", to go for firmware moddings. You won't be forgotten, R.I.P.
