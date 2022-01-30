cd basic
..\rasm\rasm -pasmo basic.asm -ob ..\bin\23.bin -sz -os ../bin/symbols.txt
cd ..\boot
..\rasm\rasm -pasmo boot.asm -ob ..\bin\boot.rom
erase basic.bin
cd ..\bin
copy /b boot.rom+basic.rom "..\ChloeVM.app\Contents\Resources\se.rom"
cd ..\rasm
rasm firmware.asm -ob ..\bin\FIRMWA~1.BIN
cd ..\ChloeVM.app
ChloeVM.cmd
