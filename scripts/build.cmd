cd basic
..\rasm\rasm -pasmo basic.asm -ob ..\bin\23.bin
cd ..\zeus
zcl split.asm
cd ..\boot
..\rasm\rasm -pasmo boot.asm -ob ..\bin\boot.rom
erase basic.bin
cd ..\bin
copy /b boot.rom+basic.rom "..\ChloeVM.app\Contents\Resources\se.rom"
cd ..\zeus
zcl firmware.asm
cd ..\ChloeVM.app
ChloeVM.cmd
