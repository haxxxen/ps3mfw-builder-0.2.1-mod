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

Credits go to all the original authors of MFW-BUILDER and its tools


NOTE:
Currently the spoof update task does not work for 4.6+ cfw due to changings in version.txt.
