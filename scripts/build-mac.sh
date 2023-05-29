cd basic
rasm -pasmo basic.asm -ob ../bin/23.bin -sz -os ../bin/symbols.txt
cd ../boot
rasm -pasmo boot.asm -ob ../bin/boot.rom
rm basic.bin
cp ../bin/boot.rom ../bin/se.rom
cat ../bin/basic.rom >> ../bin/se.rom
cd ../scripts
rasm firmware.asm -ob ../bin/FIRMWA~1.BIN
./run-mac.sh