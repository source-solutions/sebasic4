cd basic
wine ../zeus/zcl basic.asm
cd ../boot
wine ../zeus/zcl boot.asm
rm basic.bin
cd ../emu
cp ../bin/boot.rom se.rom
cat ../bin/basic.rom >> se.rom
./zesarux --enable-remoteprotocol --mmc-file esxmmc085.img --enable-mmc --enable-divmmc --machine Chloe280 --disablefooter --nowelcomemessage --quickexit --nosplash
