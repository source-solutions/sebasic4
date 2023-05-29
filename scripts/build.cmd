cd basic
rasm -pasmo basic.asm -ob ..\bin\23.bin -sz -os ..\bin\symbols.txt
cd ..\boot
rasm -pasmo boot.asm -ob ..\bin\boot.rom
erase basic.bin
cd ..\bin
copy /b boot.rom+basic.rom ..\bin\se.rom
cd ..\scripts
rasm firmware.asm -ob ..\bin\FIRMWA~1.BIN
run.cmd
