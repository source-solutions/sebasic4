Auto 0

# Run-time Variables

Var n: Num = -24
Var x: Num = 7
Var y: Num = 1
Var g: Num = 8
Var lz: Num = 1
Var fx: Num = 5
Var fy: Num = 11
Var ti: Num = 41
Var ws: Num = 1
Var np: Num = 1
Var ps: Num = 1
Var mx: Num = 15
Var my: Num = 11
Var md: Num = 1
Var ox: Num = 15
Var oy: Num = 11
Var ofx: Num = 5
Var ofy: Num = 12
Var pl: Num = 9
Var pn: Num = 1
Var x: NumArray(50) = 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var y: NumArray(50) = 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var d: NumArray(50) = 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var a: NumFOR = 0, 19, 1, 8800, 5
Var m$: Str = "\a\b\e\f\a\b\i\j\c\d\g\h\c\d\k\l"
Var p$: Str = "\m\n\::\::\::\n\::\p\::\::\o\p\m\::\o\::\o\p\  \  \  \m\  \o\  \  \m\n\n\  \p\  "
Var a$: Str = ".  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  Featuring the AMAZING TECHNICOLOUR MUTANT PIZZA CRUSTS  .  .  .  .  .  .  .  .  .  .  .  ."

# End Run-time Variables

   5 GO SUB 9400
  10 GO TO 8000
1000 LET x=INT (RND *31):\
     LET y=INT (RND *20):\
     IF NOT (ATTR (y,x) OR ATTR (y+1,x) OR ATTR (y,x+1) OR ATTR (y+1,x+1) OR INT (RND *2) OR np=50 OR ps) THEN LET np=np+1:\
     LET x(np)=x:\
     LET y(np)=y:\
     LET d(np)=INT (RND *5)+2:\
     LET ps=1:\
     LET pl=0
1005 PRINT AT 0,0; INK 1; PAPER 7;ti-1;"\  ":\
     LET ti=ti-1
1006 IF NOT ti THEN LET lz=lz+1:\
     GO TO 7500
1010 IF np=0 THEN GO TO 2000
1020 IF NOT ps THEN LET pn=INT (RND *np)+1:\
     LET pl=0:\
     LET ps=INT (RND *4)+2
1030 LET pl=pl-1+(ps<6)*2
1100 IF ps>5 THEN GO TO 1800
1150 IF ps=1 THEN LET ps=(pl<10):\
     PRINT AT y(np),x(np); INK d(np)-ps*(d(np)-1);"\m\n";AT y(np)+1,x(np);"\o\p";:\
     GO TO 2000
1200 IF ps=2 AND NOT (ATTR (y(pn)-pl,x(pn)) OR ATTR (y(pn)-pl,x(pn)+1)) THEN LET y=y(pn)-pl:\
     LET x=x(pn):\
     GO TO 1900
1210 IF ps=3 AND NOT (ATTR (y(pn),x(pn)+pl+1) OR ATTR (y(pn)+1,x(pn)+pl+1)) THEN LET y=y(pn):\
     LET x=x(pn)+pl:\
     GO TO 1900
1220 IF ps=4 AND NOT (ATTR (y(pn)+pl+1,x(pn)) OR ATTR (y(pn)+pl+1,x(pn)+1)) THEN LET y=y(pn)+pl:\
     LET x=x(pn):\
     GO TO 1900
1230 IF ps=5 AND NOT (ATTR (y(pn),x(pn)-pl) OR ATTR (y(pn)+1,x(pn)-pl)) THEN LET y=y(pn):\
     LET x=x(pn)-pl:\
     GO TO 1900
1300 LET ps=ps+4
1800 IF pl=1 THEN LET ps=0:\
     GO TO 2000
1805 LET x=x(pn):\
     LET y=y(pn)
1810 LET y(pn)=y(pn)+(ps=8)-(ps=6)
1820 LET x(pn)=x(pn)+(ps=7)-(ps=9)
1900 LET a=ps*4-8
1910 PRINT AT y,x; INK d(pn)*(ps<>7 AND ps<>8);p$(a+1); INK d(pn)*(ps<8);p$(a+2);AT y+1,x; INK d(pn)*(ps<>6 AND ps<>7);p$(a+3); INK d(pn)*(ps<>6 AND ps<>9);p$(a+4);
2000 LET ox=mx:\
     LET oy=my
2100 IF INKEY$ ="o" THEN LET mx=mx-1:\
     LET md=0
2110 IF INKEY$ ="p" THEN LET mx=mx+1:\
     LET md=1
2120 IF INKEY$ ="q" THEN LET my=my-1
2130 IF INKEY$ ="a" THEN LET my=my+1
3000 LET ofx=fx:\
     LET ofy=fy
3010 LET fx=fx+(ws OR np>10)*((fx<=ox)-(fx>ox))
3020 LET fy=fy+(NOT ws)*((fy<=oy)-(fy>oy))
3040 LET a=ATTR (fy,fx):\
     IF a<>0 AND a<>7 THEN LET fx=ofx:\
     LET fy=ofy:\
     GO TO 4000
3050 PRINT AT ofy,ofx; INK 0;"\  ";AT fy,fx; INK ws+2;"\s";
5000 IF ATTR (oy,ox)<>7 OR ATTR (oy,ox+1)<>7 OR ATTR (oy+1,ox)<>7 OR ATTR (oy+1,ox+1)<>7 THEN GO TO 7000
5010 PRINT AT oy,ox; INK 0;"\  \  ";AT oy+1,ox;"\  \  ";
5020 IF ATTR (my,mx)>1 OR ATTR (my,mx+1)>1 OR ATTR (my+1,mx)>1 OR ATTR (my+1,mx+1)>1 THEN GO TO 7000
5030 LET g=md*8+ws*4
5050 PRINT AT my,mx; INK 7;m$(g+1 TO g+2);AT my+1,mx;m$(g+3 TO g+4);
6000 LET ws=NOT ws:\
     GO TO 1000
7000 PRINT AT 6,1; PAPER 2; INK 7; BRIGHT 1; FLASH 1;"Game over.You reached level ";lz;:\
     FOR a=12 TO 0 STEP -1:\
     BEEP .2,a:\
     NEXT a:\
     LET lz=1:\
     GO TO 8100
7500 PRINT AT 6,12; PAPER 2; INK 7; BRIGHT 1; FLASH 1;"Next level";:\
     FOR a=12 TO 0 STEP -1:\
     BEEP .2,a:\
     NEXT a:\
     GO TO 8100
8000 LET lz=1
8005 PAPER 1:\
     INK 7:\
     CLS :\
     PRINT PAPER 3; INK 7; FLASH 1;AT 12,10;"INITIALISING"; FLASH 0
8010 DIM x(50):\
     DIM y(50):\
     DIM d(50)
8020 FOR a=0 TO 151:\
     READ n:\
     POKE USR "a"+a,n:\
     NEXT a
8100 LET fx=1:\
     LET fy=12
8106 LET ti=50*lz+1
8110 LET ws=0:\
     LET m$="\a\b\e\f\a\b\i\j\c\d\g\h\c\d\k\l"
8200 LET np=0:\
     LET ps=0
8210 LET p$="\m\n\::\::\::\n\::\p\::\::\o\p\m\::\o\::\o\p\  \  \  \m\  \o\  \  \m\n\n\  \p\  "
8300 LET mx=15:\
     LET my=11:\
     LET md=1
8500 BORDER 2:\
     PAPER 0:\
     INK 4:\
     CLS :\
     PRINT :\
     PRINT
8600 PRINT TAB 19;"\''\  \.."
8610 PRINT TAB 6;"\.'\''\. \:.\  \: \:'\''\. \:'\''\. \:'\''\' \':\  \.'\''"
8620 PRINT TAB 6;"\:'\''\: \: \'.\: \: \  \: \:'\:'\  \:'\''\  \' \  \ '\''\. "
8630 PRINT TAB 6;"\' \  \' \' \  \' \''\''\  \' \ '\' \''\''\' \  \  \ '\''"
8640 PRINT
8650 PRINT TAB 3;"\:.\  \: \':\' \.'\''\' \: \  \: \''\:'\' \  \  \  \.'\''\. \:'\''\' \:'\''\' "
8660 PRINT TAB 3;"\: \'.\: \ :\  \: \ '\: \:'\''\: \  \: \  \  \  \  \: \  \: \:'\''\  \:'\''"
8670 PRINT TAB 3;"\' \  \' \''\' \ '\''\  \' \  \' \  \' \  \  \  \  \ '\''\  \' \  \  \' "
8680 PRINT
8700 LET a$=".  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  Featuring the AMAZING TECHNICOLOUR MUTANT PIZZA CRUSTS  .  .  .  .  .  .  .  .  .  .  .  ."
8710 RESTORE 9300:\
     FOR a=0 TO LEN a$-32:\
     PRINT PAPER 0; INK a-INT (a/4)*4+4;AT 18,0;a$(a+1 TO a+32);:\
     IF a/3=INT (a/3) THEN READ n
8720 BEEP 0.01,n:\
     LET n=n-12:\
     IF INKEY$ ="" THEN NEXT a
8800 PAPER 6:\
     INK 1:\
     PRINT AT 0,0;"\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q";:\
     FOR a=0 TO 19:\
     PRINT "\q"; PAPER 0; INK 0;"\  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  \  "; INK 1; PAPER 6;"\q";:\
     NEXT a:\
     PRINT "\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q\q";
8810 PAPER 0:\
     PRINT AT my,mx; INK 7;"\  \  ";AT my+1,mx;"\  \  ";
8900 PRINT AT 0,29; INK 1; PAPER 7;lz;" "
8999 GO TO 1000
9199 REM Character data
9200 DATA 1,3,31,2,7,3,1,3
9201 DATA 128,192,248,192,192,192,128,192
9202 DATA 1,3,31,3,3,3,1,3
9203 DATA 128,192,248,64,224,192,128,192
9204 DATA 7,15,31,63,51,1,1,3
9205 DATA 240,248,252,236,192,128,128,128
9206 DATA 15,31,63,55,3,1,1,1
9207 DATA 224,240,248,252,204,128,128,192
9208 DATA 7,7,7,6,3,22,28,8
9209 DATA 96,96,96,224,192,120,24,16
9210 DATA 6,6,6,7,3,30,24,8
9211 DATA 224,224,224,96,192,104,56,16
9212 DATA 3,15,63,63,127,127,255,255
9213 DATA 192,240,252,252,254,254,255,255
9214 DATA 255,255,127,127,63,63,15,3
9215 DATA 255,255,254,254,252,252,240,192
9216 DATA 255,85,255,119,255,85,255,221
9217 DATA 95,175,95,175,250,245,250,245
9218 DATA 165,66,90,126,189,24,36,66
9300 DATA 4,4,4,4,2,0,0,-1,-3,-3,0,4,9,9,9,9,7,5,5,4,2,2,4,5,4,5,4,8,5,4,4,2,0,0,-1,-3,-1,-1,-1,-1,0,-1,-3,0,4,9,99
9310 PAPER 7:\
     INK 0:\
     FOR a=0 TO 151:\
     POKE USR "a"+a,PEEK (15880+a):\
     NEXT a
9400 REM Instructions
9410 PAPER 1:\
     INK 7:\
     BORDER 5:\
     CLS
9420 PRINT "       Andre's Night Off"
9425 PRINT "       -----------------"
9430 PRINT "Andre, the chef from the"
9440 PRINT "mansion, has been given the"
9450 PRINT "night off."
9470 PRINT "But a deadly lobster and the"
9480 PRINT "amazing tehnicolour mutant"
9490 PRINT "pizza crusts have taken over"
9495 PRINT "his kitchen."
9500 PRINT "You must steer Andre out of"
9510 PRINT "harm's way, avoiding the"
9520 PRINT "pizza crusts and lobster"
9525 PRINT "for as long as possible."
9530 PRINT "Your target time ticks away"
9540 PRINT "on the top left of the screen."
9550 PRINT "But if you surive, the time"
9560 PRINT "will increase on the next"
9570 PRINT "level!!"
9580 PRINT "        A-down  Q-up"
9590 PRINT "        O-left  P-right"
9600 PRINT
9880 PRINT "     Press any key to start":\
     PAUSE 0
9900 RETURN
