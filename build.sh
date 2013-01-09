rm ./bin/*.rom
make rom=0
cp se-0.rom ./bin/
make clean
make rom=1
cp se-1.rom ./bin/
make clean
