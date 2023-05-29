echo Generating 0437-IBM.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe CP437 -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/0437-IBM.CP
rm TEMP.FTX

echo Generating 1250-EUC.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe CP1250 -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/1250-EUC.CP
rm TEMP.FTX

echo Generating 1251-CYR.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe CP1251 -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/1251-CYR.CP
rm TEMP.FTX

echo Generating 1252-EUW.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe CP1252 -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/1252-EUW.CP
rm TEMP.FTX

echo Generating 1253-GRE.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe CP1253 -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/1253-GRE.CP
rm TEMP.FTX

echo Generating 1254-TUR.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe CP1254 -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/1254-TUR.CP
rm TEMP.FTX

echo Generating 1255-HEB.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe CP1255 -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/1255-HEB.CP
rm TEMP.FTX

echo Generating 1256-ARA.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe CP1256 -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/1256-ARA.CP
rm TEMP.FTX

echo Generating 1257-BAL.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe CP1257 -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/1257-BAL.CP
rm TEMP.FTX

echo Generating 1258-VIE.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe CP1258 -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/1258-VIE.CP
rm TEMP.FTX

echo Generating APPLE-II.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe "U8/M Apple II" -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/APPLE-II.CP
rm TEMP.FTX

echo Generating ATARI-ST.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe "U8/M Atari ST" -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/ATARI-ST.CP
rm TEMP.FTX

echo Generating ATASCII.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe "U8/M ATASCII" -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/ATASCII.CP
rm TEMP.FTX

echo Generating IR-109.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe "ISO 8859-3" -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/IR-109.CP
rm TEMP.FTX

echo Generating IR-226.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe "ISO 8859-16" -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/IR-226.CP
rm TEMP.FTX

echo Generating KOI8-R.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe "FZX KOI-8" -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/KOI8-R.CP
rm TEMP.FTX

echo Generating MACROMAN.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe MacRoman -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/MACROMAN.CP
rm TEMP.FTX

echo Generating PETSCII.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe "U8/M PETSCII" -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/PETSCII.CP
rm TEMP.FTX

echo Generating RISC-OS.CP
java -jar scripts/bitsnpicas.jar convertbitmap -f dosv -oe "U8/M RISC OS" -o TEMP.FTX "bin/Chloe Sans Bitmap-6.kbits"
tail -c 2048 TEMP.FTX > chloehd/SYSTEM/FONTS/RISC-OS.CP
rm TEMP.FTX
