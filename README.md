# ps3mfw-builder-0.2.1-mod
modified version of toolboy's MFW-Builder (and original MFW-Builder 0.2.1)

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

small explanation of tasks:
- patch_cos: Has all basic COREOS patches you would need for a standard MFW and is based on toolboy. I only have added appldr lv2memory protection removal patch and appldr signature patch to be able to exit FSM on 4.XX (NOTE: For lv0 patches on 4.XX, you have to select lv0 extract option. Also current payloads are not working for DEX MFW thanks to Joonie for reporting)
- patch_oos: glevand's task ported to work with 4.XX MFW as well. You can now make a 4.XX OtherOS++ pup, so no more 3.55 times
- broken_bluray: It is an AIO task for a FULL noBD or noBluetooth MFW
- patch_info: This will patch old 3.55.4 / 4.21.2 REX CFW to a FULL working D-REX version (my favourite :D)
- change_devflash_files: Use this task whenever you want to replace any devflash file. This has to be done manually though, and keep in mind that you have to close windows explorer when you have replaced. Otherwise windoof will lock the folder and mfwbuilder cannot proceed with script and spits an error.
- change_devflash3_files: Experimental ! this works same like change_devflash_files, only with devflash3
- patch_rsod: Self-explanatory
- patch_premo: It has all remote-play patches as well as mysis' advanced sfo patch
- change_xml_files: This can replace automatically any XMB xml file. You only have to choose the path to your modified file. When empty, it skips the file and none will be replaced
- patch_vsh: This will apply misc vsh patches, but this task is not made by me. Seems i have to fix it, to make it work (thanks to kozarovv)
- customize_firmware: Same like vsh task, and it is way too AIO. This i won't fix and remove in future
- spoofer_update: This will let you update or set a spoofer on any MFW or CFW. It also has advanced SEN patches, but those do not work anymore (none of them)
- cobra_selfs: This is based on REBUG COBRA only and will let you replace automatically vsh(s), cobra stage2 files and index.dat / version.txt
- patch_epilepsy: This will let you patch out that extra health screen, with that epilepsy warning
- patch_cinavia: This will let you remove cinavia copy-protection on hdd content
- patch_gameboot: This will let you enable that old 2.78-OFW gameboot sound and animation. The sound files will be automatically copied to matching coldboot devflash package and also remove 01.p3t file, to give more freespace on devflash
- patch_fself: This will let you run FSELFs on a CEX CFW for both kernels, even loading DEX kernel on CEX (my favourite :D)
- patch_appldr_unsigned_apps: This will let you patch appldr for running unsigned apps, based on DEMONHADES. Now you can remove kakaroto's unsigned app vsh patch, which disables npdrm_fself on DEX. So no more shutdowns or blackscreens when kakaroto's patch is removed (also my favourite :D)

Credits go to all the original authors of MFW-BUILDER and its tools. Also credits to mysis, who has made most of the patches!
