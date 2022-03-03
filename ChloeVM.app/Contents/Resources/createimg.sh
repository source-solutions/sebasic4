rm chloehd.img
hdfmonkey create --fat16 chloehd.img 128MB CHLOEHD
hdfmonkey put chloehd.img ./chloehd/* /
./chloevm-deb-arm64 --noconfigfile --enable-mmc --enable-divmmc --mmc-file chloehd.img --def-f-function f1 NMI --def-f-function f4 Reset --enablekempstonmouse --machine Chloe280 --disablefooter --nowelcomemessage --quickexit --nosplash --gui-style QL --menucharwidth 6 --zoomx 4 --zoomy 3
