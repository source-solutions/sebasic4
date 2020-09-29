cd basic
../rasm/rasm-deb -pasmo basic.asm -ob ../bin/23.bin
cd ../boot
../rasm/rasm-deb -pasmo boot.asm -ob ../bin/boot.rom
rm basic.bin
cp ../bin/boot.rom ../ChloeVM.app/Contents/Resources/se.rom
cat ../bin/basic.rom >> ../ChloeVM.app/Contents/Resources/se.rom
cd ../rasm
./rasm-deb firmware.asm -ob ../bin/FIRMWA~1.BIN
cd ..
./scripts/run-deb.sh
