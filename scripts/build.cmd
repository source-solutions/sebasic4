copy zeus\zcl.exe basic\zcl.exe
cd basic
zcl basic.asm
erase zcl.exe
cd ..
copy zeus\zcl.exe boot\zcl.exe
cd boot
zcl boot.asm
erase basic.bin
erase zcl.exe
cd ..
cd bin
copy /b boot.rom+basic.rom "..\ChloeVM.app\Contents\Resources\se.rom"
cd ..\zeus
zcl firmware.asm
cd ..\ChloeVM.app
ChloeVM.cmd