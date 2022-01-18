arch=$(arch)

cd basic

if [[ "$arch" == "aarch64" ]];
then ../rasm/rasm-deb-arm64 -pasmo basic.asm -ob ../bin/23.bin -sz -os ../bin/symbols.txt
else ../rasm/rasm-deb-i386 -pasmo basic.asm -ob ../bin/23.bin -sz -os ../bin/symbols.txt
fi

cd ../boot

if [[ "$arch" == "aarch64" ]];
then ../rasm/rasm-deb-arm64 -pasmo boot.asm -ob ../bin/boot.rom
else ../rasm/rasm-deb-i386 -pasmo boot.asm -ob ../bin/boot.rom
fi

rm basic.bin
cp ../bin/boot.rom ../ChloeVM.app/Contents/Resources/se.rom
cat ../bin/basic.rom >> ../ChloeVM.app/Contents/Resources/se.rom
cd ../rasm

if [[ "$arch" == "aarch64" ]];
then ../rasm-deb-arm64 firmware.asm -ob ../bin/FIRMWA~1.BIN
else ../rasm-deb-i386 firmware.asm -ob ../bin/FIRMWA~1.BIN
fi

cd ..
./scripts/run-deb.sh
