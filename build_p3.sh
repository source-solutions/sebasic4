rm ./bin/*.rom
rm ./bin/se-1.tap
make rom=0
cp se-0.rom ./bin/
make clean
make rom=1
cp se-1.rom ./bin/
make clean
cd bin
bin2tap se-1.rom rom.tap 32768
cat loader.tap rom.tap > se-1.tap
rm rom.tap
cd ..