cd basic
../rasm/rasm-mac -pasmo basic.asm -ob ../bin/23.bin
cd ../bin
head -c 16384 23.bin > basic.rom
tail -c 7168 23.bin > ../boot/basic.bin
cd ../boot
../rasm/rasm-mac -pasmo boot.asm -ob ../bin/boot.rom
rm basic.bin
cp ../bin/boot.rom ../ChloeVM.app/Contents/Resources/se.rom
cat ../bin/basic.rom >> ../ChloeVM.app/Contents/Resources/se.rom
cd ../rasm
rasm firmware.asm -ob ../bin/FIRMWA~1.BIN
cd ..
open ChloeVM.app
