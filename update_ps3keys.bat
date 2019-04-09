@echo off
copy templat\keydat .\keydat

echo Updating ps3keys...
set /p ver=Type in new PS3 Firmware Version (e.g. for 4.84 type 484): 
copy ps3keys\*-481 ps3keys\*-%ver%

echo Updating scetool keys...
set /p new=Type in new PS3 Firmware Version in special format (e.g. for 4.84 type 40084): 
tools\sfk.exe rep -pat /90099/%new%/ -dir . -file keydat -yes
tools\sfk.exe partcopy keydat -allfrom 0x0 data\keys -append -yes
tools\sfk.exe partcopy keydat -allfrom 0x0 ps3keys\keys -append -yes

del /F /Q keydat
echo Done!
pause
