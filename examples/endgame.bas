   5 REM draw blank board
   7 BORDER 5
  10 LET bb=1: LET bw=5: REM white and blue for board
  15 PAPER bw: INK bb: CLS
  20 PLOT 79,128: REM border
  30 DRAW 65,0: DRAW 0,-65
  40 DRAW -65,0: DRAW 0,65
  50 PAPER bb
  60 REM board
  70 FOR n=0 TO 3: FOR m=0 TO 3
  80 PRINT AT 6+2*n,11+2*m;" "
  90 PRINT AT 7+2*n,10+2*m;" "
 100 NEXT m: NEXT n
 110 PAPER 8
 120 LET pw=7: LET pb=2: REM colours white and black pieces
 200 DIM b$(8,8): REM positions of pieces
 210 LET b$(1)="rnbqkbnr"
 220 LET b$(2)="pppppppp"
 230 LET b$(7)="PPPPPPPP"
 240 LET b$(8)="RNBQKBNR"
 300 REM display board
 310 FOR n=1 TO 8: FOR m=1 TO 8
 320 LET bc=CODE b$(n,m): INK pw
 325 IF bc=CODE " " THEN GO TO 350: REM space
 330 IF bc>CODE "Z" THEN INK pb: LET bc=bc-32: REM lower case for black
 340 LET bc=bc+79: REM convert to graphics
 350 PRINT AT 5+n,9+m;CHR$ bc
 360 NEXT m: NEXT n
1000 REM Endgame
1010 BORDER 5
1020 DIM t$(96)
1025 PAPER 8
1030 GO SUB 7015
1050 INK 8
1060 FOR i=6 TO 13
1070 PRINT AT i,10;"        "
1080 NEXT i
1090 LET t$="White Pawn (Alice) to play, and win in eleven moves."
1100 GO SUB 7000
1110 PRINT AT 6,16; INK pb;"\n"
1120 PRINT AT 8,12; INK pw;"\k"
1130 PRINT AT 9,15; INK pw;"\n"
1140 PRINT AT 10,14; INK pb;"\k"
1150 PRINT AT 12,13; INK pw; BRIGHT 1;"\p"; INK pb;"\q"
1160 PRINT AT 13,12; INK pw;"\q  \r"
1170 LET t$="1. Alice meets Red Queen.": GO SUB 7000
1180 PRINT AT 12,13; INK pw;"\p "
1190 PRINT AT 11,15; INK pb;"\q"
1200 PAUSE 20
1210 PRINT AT 11,15; INK pb;" ";AT 10,16; INK pb;"\q"
1220 PAUSE 20
1230 PRINT AT 10,16; INK pb;" ";AT 9,17; INK pb; BRIGHT 1;"\q"
1240 LET t$="1. Red Queen to King's Rook 4th": GO SUB 7010
1250 PRINT AT 12,13;" ";AT 9,17;"\q";AT 11,13; INK pw; BRIGHT 1;"\p"
1260 LET t$="2. Alice through Queen's 3rd    (by railway).": GO SUB 7000
1270 PRINT AT 11,13;" ";AT 10,13; INK pw; BRIGHT 1;"\p"
1280 LET t$="2. Alice to Queen's 4th         (Tweedledum and Tweedledee).": GO SUB 7000
1285 PRINT AT 10,13;"\p"
1290 FOR y=13 TO 11 STEP -1: PRINT AT y,12;" ";AT y-1,12; BRIGHT 1; INK pw;"\q";: PAUSE 20: NEXT y
1300 PRINT ;"\p";
1310 LET t$="2. White Queen to Queen's Bishop4th (after shawl)": GO SUB 7010
1320 PRINT AT 10,13; OVER 1; BRIGHT 1;" ";
1330 LET t$="3. Alice meets White Queen      (with shawl)": GO SUB 7000
1340 PRINT AT 10,12;" \p";AT 9,12; INK pw; BRIGHT 1;"\q"
1350 LET t$="3. White Queen to Queen's Bishop5th (becomes sheep)": GO SUB 7010
1360 PRINT AT 10,13;" ";AT 9,12;"\q"; BRIGHT 1;"\p"
1370 LET t$="4. Alice to Queen's 5th         (shop, river, shop)": GO SUB 7000
1380 PRINT AT 9,12;" \p"
1390 FOR k=0 TO 3: PRINT AT 9-k,12+k; INK pw; BRIGHT 1;"\q";AT 10-k,11+k;" ": PAUSE 20: NEXT k
1400 LET t$="4. White Queen to King's Bishop 8th (leaves egg on shelf)": GO SUB 7010
1410 PRINT AT 6,15;"\q";AT 9,13;" ";AT 8,13; BRIGHT 1;"\p"
1420 LET t$="5. Alice to Queen's 6th         (Humpty Dumpty)": GO SUB 7000
1430 PRINT AT 8,13;"\p": REM e
1440 FOR x=14 TO 12 STEP -1: PRINT AT 6,x; BRIGHT 1; INK pw;"\q"; BRIGHT 0;" ": PAUSE 20: NEXT x
1450 LET t$="5. White Queen to Queen's Bishop8th (flying from Red Knight)": GO SUB 7010
1460 PRINT AT 6,12;"\q";AT 8,13;" ";AT 7,13; BRIGHT 1; INK pw;"\p"
1470 LET t$="6. Alice to Queen's 7th         (forest)": GO SUB 7000
1480 PRINT AT 7,13;"\p";AT 6,16;" ";AT 7,14; INK pb; FLASH 1; BRIGHT 1;"\n"
1490 LET t$="6. Red Knight to King's 2nd     (check)": GO SUB 7010
1500 PRINT AT 9,15; BRIGHT 1;"\n": PAUSE 20
1510 PRINT AT 9,15;" ";AT 7,14; BRIGHT 1; INK pw;"\n"
1520 PRINT AT 13,19; INK pb;"\n"
1530 LET t$="7. White Knight takes Red Knight": GO SUB 7000
1540 PRINT AT 9,15; BRIGHT 1;"\n"
1550 PRINT AT 7,14;" "
1560 LET t$="7. White Knight to Queen's      Bishop's 5th": GO SUB 7010
1570 PRINT AT 9,15;"\n";AT 7,13; BRIGHT 1;"\p": PAUSE 20: PRINT AT 7,13; BRIGHT 0;" ";AT 6,13; BRIGHT 1;"\p"
1580 LET t$="8. Alice to Queen's 8th         (coronation)": GO SUB 7000
1590 PRINT AT 6,13;"\p"
1600 FOR k=0 TO 2: PRINT AT 8-k,16-k; BRIGHT 1; INK pb;"\q";AT 9-k,17-k; BRIGHT 0;" ": PAUSE 20: NEXT k
1610 LET t$="8. Red Queen to king's square   (examination)": GO SUB 7010
1620 PRINT AT 6,13; BRIGHT 1;"\p"; BRIGHT 0;"\q"
1630 LET t$="9. Alice becomes Queen.": GO SUB 7000
1640 PRINT AT 6,12; BRIGHT 1;"\q"; BRIGHT 0;"\p"; BRIGHT 1;"\q"
1650 LET t$="9. Queens castle                (Enter the palace)": GO SUB 7010
1660 PRINT AT 6,12; BRIGHT 0;"\q\p\q";AT 6,13; BRIGHT 1;"\p"
1670 LET t$="10. Alice castles               (feast)": GO SUB 7000
1680 PRINT AT 6,12;" \p\q";AT 7,11; BRIGHT 1; INK pw;"\p";: PAUSE 20
1690 PRINT AT 8,10; BRIGHT 1;"\q";AT 7,11; BRIGHT 0;" ";
1700 LET t$="10. White Queen to Queen's Rook 6th (soup)": GO SUB 7010
1710 PRINT AT 8,10;"\q";AT 6,13; BRIGHT 1;"\p": PAUSE 20
1720 PRINT AT 6,13;\{f0}" \p";AT 6,14; BRIGHT 1; INK pw;"\p"
1730 PRINT AT 13,20; INK pb; BRIGHT 1;"\q": PAUSE 10
1740 PRINT AT 13,20; INK pb;"\q"
1750 LET t$="11. Alice takes Red Queen & wins(checkmate)": GO SUB 7000
1760 LET t$="Note. The alternation of Red andWhite is perhaps not so strictlyobserved as it might be.": GO SUB 7000
1770 LET t$="Note. As the book explains, it  takes all the running you can doto keep in the same place.": GO SUB 7000
1780 LET t$="Note. Also, through the Looking Glass, castling has nothing to  do with Rooks (or crows).": GO SUB 7000
1790 LET t$="Note. It is merely a way of     saying the Queens entered the   Palace.": GO SUB 7000
1890 PAPER 7: INK 0
1896 STOP
7010 PRINT AT 18,0; PAPER 7; INK 0;t$
7015 PRINT \{vn}#1;AT 0,9;"Press a key": PAUSE 0: RETURN
9002 RESTORE 9000
9005 LET b=BIN 01111100: LET c=BIN 00111000: LET d=BIN 00010000
9010 FOR n=1 TO 6: READ p$: REM 6 pieces
9020 FOR f=0 TO 7: REM read piece into 8 bytes
9030 READ a: POKE USR p$+f,a
9040 NEXT f
9050 NEXT n
9100 REM bishop
9110 DATA "b",0,d,BIN 00101000,BIN 01000100
9120 DATA BIN 01101100,c,b,0
9130 REM king
9140 DATA "k",0,d,c,d
9150 DATA c,BIN 01000100,c,0
9160 REM rook
9170 DATA "r",0,BIN 01010100,b,c
9180 DATA c,b,b,0
9190 REM queen
9200 DATA "q",0,BIN 01010100,BIN 00101000,d
9210 DATA BIN 01101100,b,b,0
9220 REM pawn
9230 DATA "p",0,0,d,c
9240 DATA c,d,b,0
9250 REM knight
9260 DATA "n",0,d,c,BIN 01111000
9270 DATA BIN 00011000,c,b,0
