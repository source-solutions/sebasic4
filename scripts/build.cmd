copy zeus/zcl.exe basic/zcl.exe
cd basic
zcl basic.asm
erase zcl.exe
cd ..
copy zeus/zcl.exe boot/zcl.exe
cd boot
zcl boot.asm
erase basic.bin
erase zcl.exe
cd ..
cd bin
copy /b boot.rom+basic.rom "../emu/se.rom"
cd ../emu
zesarux.exe --enable-remoteprotocol --mmc-file esxmmc085.img --enable-mmc --enable-divmmc --machine Chloe280 --disablefooter --nowelcomemessage --quickexit --nosplash
