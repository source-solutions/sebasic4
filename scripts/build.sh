cd basic
wine ../zeus/zcl basic.asm
cd ../boot
wine ../zeus/zcl boot.asm
rm basic.bin
cp ../bin/boot.rom ../ChloeVM.app/Contents/Resources/se.rom
cat ../bin/basic.rom >> ../ChloeVM.app/Contents/Resources/se.rom
cd ../zeus
wine zcl firmware.asm
cd ..
open ChloeVM.app
