cd basic
../rasm/rasm-deb-i386 -pasmo basic.asm -ob ../bin/23.bin -sz -os ../bin/symbols.txt
cd ../boot
../rasm/rasm-deb-i386 -pasmo boot.asm -ob ../bin/boot.rom
rm basic.bin
cp ../bin/boot.rom ../ChloeVM.app/Contents/Resources/se.rom
cat ../bin/basic.rom >> ../ChloeVM.app/Contents/Resources/se.rom
cd ../rasm
./rasm-deb-i386 firmware.asm -ob ../bin/FIRMWA~1.BIN
cd ..
./scripts/run-deb.sh
