Auto 1

# Run-time Variables

Var x: Num = 17
Var y: Num = 13
Var a: Num = 108
Var ax: Num = 1
Var ay: Num = 1
Var bx: Num = 1
Var by: Num = 1
Var di: Num = 3
Var f1: Num = 1
Var f2: Num = 0
Var l1: Num = 0
Var l2: Num = 1
Var r1: Num = 0
Var r2: Num = -1
Var af: Num = 0
Var al: Num = 0
Var ar: Num = 0
Var f: NumFOR = 0, 1, -1, 330, 2
Var g: NumFOR = 8, 7, 1, 8860, 4
Var h: NumFOR = 6, 5, 1, 8200, 2
Var j: NumFOR = 6, 5, 1, 8090, 2
Var k: NumFOR = 5, 4, 1, 8070, 3
Var x$: Str = "Northwest Southeast."
Var a$: Str = "\#226"
Var z$: StrArray(25, 25) = "1101111011110110001111011110111010010101010110000000011001010010010001100011101110001101110000011100110111101111011110111100111011110111101111111110110000010001000001111110001100011010010001110000010001011001010101111011100010001111011000111101111011110111101111011110011101110101110111101111100110110010011000000001100000000111011101111011110111111111011110111101111011111111101111011110111101111011110111101100000110111000111000000001000100000001011101111011010111101110100110111101100011110111101111111110111101111111110011111111011101011111111100110000001100100000000000011011110111011111011110111101111011110111101111011"
Var y$: StrArray(5, 5) = "1101111011000001101111011"

# End Run-time Variables

   1 REM 3-D MAZE
   2 REM  \* S.Robert Speel
   3 REM fast
  10 GO SUB 7000
  20 INK 1:\
     PAPER 5:\
     BORDER 3:\
     CLS
  50 CLS :\
     RESTORE 9000+10*di:\
     READ f1,f2,l1,l2,r1,r2
  60 IF x=1 OR x=25 OR y=1 OR y=25 THEN GO TO 90
  70 LET af=VAL z$(x+f1,y+f2):\
     LET al=VAL z$(x+l1,y+l2):\
     LET ar=VAL z$(x+r1,y+r2)
  80 IF z$(x-f1,y-f2)="1" AND al+ar=1 THEN GO TO 700
  90 CLS :\
     PLOT 80,0:\
     DRAW 0,150:\
     DRAW 50,-50:\
     DRAW 50,50:\
     DRAW 0,-150:\
     DRAW -50,100:\
     DRAW -50,-100
 100 IF x=1 OR x=25 OR y=1 OR y=25 THEN GO TO 600
 110 IF z$(x-f1,y-f2)="1" AND NOT al AND NOT ar THEN GO TO 550
 120 FOR f=100 TO 1 STEP -2:\
     PLOT 130-f/2,100-f:\
     DRAW f,0:\
     NEXT f:\
     IF x=1 OR x=25 OR y=1 OR y=25 THEN GO TO 600
 130 FOR f=100 TO 1 STEP -1.6:\
     PLOT 130-f/2,f/2+100:\
     DRAW f,0:\
     NEXT f
 150 IF NOT al THEN GO TO 200
 160 IF NOT ar THEN GO TO 300
 170 IF af THEN GO TO 500
 180 GO TO 1000
 200 PLOT 90,20:\
     DRAW 0,120:\
     PLOT 90,60:\
     DRAW 20,0:\
     DRAW 0,60:\
     DRAW -20,0
 210 PLOT 90,21:\
     DRAW INVERSE 1;20,40
 220 FOR f=30 TO -10 STEP -2:\
     PLOT 90,50-f:\
     DRAW 30-f,0:\
     NEXT f
 230 FOR f=20 TO 1 STEP -1:\
     PLOT 90,140-f:\
     DRAW f,0:\
     NEXT f
 240 IF NOT ar THEN GO TO 300
 250 IF af THEN GO TO 400
 260 GO TO 350
 300 PLOT 170,20:\
     DRAW 0,120:\
     PLOT 170,60:\
     DRAW -20,0:\
     DRAW 0,60:\
     DRAW 20,0
 310 PLOT 170,19:\
     DRAW INVERSE 1;-20,40
 320 FOR f=30 TO -10 STEP -2:\
     PLOT 170,F-50:\
     DRAW f-30,0:\
     NEXT f
 330 FOR f=20 TO 1 STEP -1:\
     PLOT 170,140-f:\
     DRAW -f,0:\
     NEXT f
 340 IF af THEN GO TO 450
 350 GO TO 1000
 400 FOR f=61 TO 119:\
     PLOT INVERSE 1;110,f:\
     DRAW INVERSE 1;60,0:\
     NEXT f
 410 PLOT 150,60:\
     DRAW 0,60
 420 GO TO 1000
 450 FOR f=61 TO 119:\
     PLOT INVERSE 1;110,f:\
     DRAW INVERSE 1;59,0:\
     NEXT f
 460 IF al THEN PLOT 110,60:\
     DRAW 0,60
 470 GO TO 1000
 500 FOR f=60 TO 120:\
     PLOT INVERSE 1;110,f:\
     DRAW INVERSE 1;59,0:\
     NEXT f
 510 FOR f=110 TO 150 STEP 2:\
     PLOT f,60:\
     DRAW 0,60:\
     NEXT f
 520 PRINT AT 9,14;"DEAD";AT 10,14;"END"
 530 GO TO 1000
 550 FOR f=7 TO 14:\
     PRINT AT f,8;"    ";AT f,21;"   ":\
     NEXT f:\
     FOR f=14 TO 21:\
     PRINT AT f,0; PAPER 6-(f>18)*3;"                                ":\
     NEXT f
 560 FOR f=24 TO 63 STEP 2:\
     PLOT 0,f:\
     DRAW OVER 1;255,0:\
     NEXT f
 570 PRINT AT 0,0;:\
     FOR f=0 TO 6:\
     PRINT "\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::":\
     NEXT f
 580 FOR f=0 TO 1:\
     PLOT 110+f*40,63:\
     DRAW 0,57:\
     NEXT f:\
     FOR f=60 TO 100 STEP 2:\
     PLOT 80+f/2,f:\
     DRAW 100-f,0:\
     NEXT f
 590 FOR f=100 TO 120:\
     PLOT 230-f,f:\
     DRAW f*2-200,0:\
     NEXT f:\
     GO TO 1000
 600 BORDER 4:\
     FOR f=10 TO 0 STEP -10:\
     PLOT 100-f,20:\
     DRAW 0,80+f:\
     DRAW 30+f,40+f:\
     DRAW 30+f,-40-f:\
     DRAW 0,-80-f:\
     NEXT f
 610 FOR f=20 TO 100:\
     PLOT 100,f:\
     DRAW 60,0:\
     NEXT f
 620 FOR f=100 TO 140:\
     PLOT 25+f*3/4,f:\
     DRAW 212-f*19/12.5,0:\
     NEXT f
 630 FOR f=1 TO 30:\
     PLOT OVER 1; PAPER 6;100+RND*60,20+RND*80:\
     NEXT f
 640 PRINT AT 0,0;"YOU HAVE REACHED THE EXIT."'"YOU TOOK"'FN c();"SECONDS. "
 650 FOR F=10 TO 67:\
     BEEP .1,f-50:\
     NEXT f:\
     BEEP 2,18
 655 PRINT
 660 PRINT INK 3+INT (RND*5);"Another game?"
 670 IF INKEY$="y" THEN BEEP .5,10:\
     CLS :\
     RUN
 680 IF INKEY$="n" THEN BEEP .5,10:\
     STOP
 690 GO TO 670
 700 FOR f=19 TO 21:\
     PRINT AT f,0; PAPER 3;"                                ":\
     NEXT f
 710 FOR f=24 TO 63 STEP 2:\
     PLOT al*(f/2+80),f:\
     DRAW 180-f/2-al*5,0:\
     NEXT f
 720 FOR f=60 TO 100 STEP 2:\
     PLOT 80+f/2,f:\
     DRAW 100-f,0:\
     NEXT f
 730 FOR f=100 TO 120:\
     PLOT 230-f,f:\
     DRAW f*2-200,0:\
     NEXT f
 740 FOR f=120 TO 140:\
     PLOT al*(230-f),f:\
     DRAW 30+f-al*5,0:\
     NEXT f
 750 PLOT 110+al*40,63:\
     DRAW 0,56:\
     PLOT 170-al*80,24:\
     DRAW 0,116
 760 GO TO 1000
1000 INPUT "WHAT NEXT? ";a$:\
     BEEP 1,20
1010 IF a$="o" THEN GO TO 1200
1020 IF a$="l" THEN GO TO 1300
1030 IF a$="r" THEN GO TO 1400
1040 IF a$="re" THEN GO TO 1500
1050 IF a$="c" THEN GO TO 1550
1060 IF a$="t" THEN GO TO 1600
1070 IF a$="h" THEN GO TO 1700
1080 GO TO 1000
1200 IF af THEN GO TO 1000
1210 LET x=x+f1:\
     LET y=y+f2
1220 GO TO 50
1300 IF al THEN GO TO 1000
1310 LET x=x+l1:\
     LET y=y+l2
1320 LET di=di+1:\
     IF di>3 THEN LET di=0
1330 GO TO 50
1400 IF ar THEN GO TO 1000
1410 LET x=x+r1:\
     LET y=y+r2
1420 LET di=di-1:\
     IF di<0 THEN LET di=3
1430 GO TO 50
1500 LET di=di+2:\
     IF di>3 THEN LET di=di-4
1510 GO TO 50
1550 PRINT AT 1,1;x$(di*5+1 TO di*5+5):\
     GO TO 1000
1600 PRINT AT 0,15;"TIME SO FAR";TAB 15;" = ";FN c();"SECS.":\
     GO TO 1000
1700 LET fp=25-(y<13)*7
1710 CLS :\
     FOR f=fp TO fp-17 STEP -1:\
     FOR g=1 TO 25:\
     LET g$=CHR$ 144:\
     IF z$(g,f)="1" THEN LET g$="\::"
1720 IF x=g AND y=f THEN PRINT INK 0; FLASH 1;CHR$ 145;:\
     GO TO 1740
1730 PRINT g$;
1740 NEXT g:\
     PRINT :\
     NEXT f
1750 PRINT "You are at the figure, facing  "'x$(di*5+1 TO di*5+5);"."
1760 GO TO 1000
7000 PRINT "  Corridors"''"  Commands are:"''"  on (o)"'"  reverse (re)"'"  left (l)"'"  right (r)"'"  compass (c)"'"  time (t)"'"  and help (h)."
7005 PRINT
7010 PRINT "Your aim is to exit the caves in the shortest possible time."
8000 PRINT AT 5,18; FLASH 1;"PLEASE WAIT":\
     RANDOMIZE :\
     DIM z$(25,25):\
     DIM y$(5,5)
8010 FOR f=1 TO 25 STEP 5:\
     FOR g=1 TO 25 STEP 5:\
     POKE 23000+RND*295,RND*255
8020 LET ax=1:\
     IF RND<.5 THEN LET ax=5
8030 LET ay=1:\
     IF ax=5 THEN LET ay=-1
8040 LET bx=1:\
     IF RND<.5 THEN LET bx=5
8050 LET by=1:\
     IF bx=5 THEN LET by=-1
8060 GO SUB 8200+INT (RND*10)*50
8070 FOR j=0 TO 4:\
     FOR k=0 TO 4:\
     LET z$(f+j,g+k)=y$(j*ay+ax,k*by+bx):\
     NEXT k:\
     NEXT j
8080 NEXT g:\
     NEXT f:\
     GO SUB 8200
8090 FOR j=1 TO 5:\
     LET z$(10+j,11 TO 15)=y$(j):\
     NEXT j:\
     GO TO 8800
8200 FOR h=1 TO 5:\
     LET y$(h)="11011":\
     NEXT h
8210 LET y$(3)="00000":\
     RETURN
8250 FOR h=1 TO 5:\
     LET y$(h)="11011":\
     NEXT h
8260 LET y$(3)="11000":\
     RETURN
8300 LET y$(1)="11111":\
     LET y$(2)=y$(1)
8310 LET y$(4)="11011":\
     LET y$(5)=y$(4)
8320 LET y$(3)="00000":\
     RETURN
8350 LET y$(\{f0}1)="11111":\
     LET y$(2)=y$(1)
8360 LET y$(4)="11011":\
     LET y$(5)=y$(4)
8370 LET y$(\{i0}3)="00011":\
     RETURN
8400 LET y$(1)="11011":\
     LET y$(5)=y$(1)\{p5}
8410 LET y$(2)="10001":\
     LET y$(4)=y$(2)
8420 LET y$(3)="00100":\
     RETURN
8450 LET y$(1)="11011":\
     LET y$(5)=y$(1)
8460 LET y$(2)="10101":\
     LET y$(3)="00100"
8470 LET y$(4)="10111":\
     RETURN
8500 LET y$(1)="11011":\
     LET y$(2)="00101"
8510 LET y$(3)="10100":\
     LET y$(4)="10001"
8520 LET y$(5)="11011":\
     RETURN
8550 LET y$(1)="11000":\
     LET y$(2)="11010"
8560 LET y$(3)="10001":\
     LET y$(4)="00000"
8570 LET y$(5)="11011":\
     RETURN
8600 LET y$(1)="11011":\
     LET y$(5)=y$(1)
8610 LET y$(2)="10011":\
     LET y$(3)="10100"
8620 LET y$(4)="10001":\
     RETURN
8650 LET y$(1)="11001":\
     LET y$(2)="11100"
8660 LET y$(5)="11011":\
     RETURN
8800 LET x=13:\
     LET y=13
8810 LET di=0
8820 LET x$="Northwest Southeast."
8830 DEF FN a()=INT ((PEEK 23672+256*PEEK 23673+65536*PEEK 23674)/50)
8840 DEF FN b(x,y)=(x+y+ABS (x-y))/2
8850 DEF FN c()=FN b(FN a(),FN a())
8860 RESTORE 9100:\
     FOR f=0 TO 1:\
     FOR g=0 TO 7:\
     READ a:\
     POKE USR CHR$ (144+f)+g,a:\
     NEXT g:\
     NEXT f
8870 FOR f=23674 TO 23672 STEP -1:\
     POKE f,0:\
     NEXT f
8880 RETURN
9000 DATA 0,1,-1,0,1,0
9010 DATA -1,0,0,-1,0,1
9020 DATA 0,-1,1,0,-1,0
9030 DATA 1,0,0,1,0,-1
9100 DATA 195,129,0,0,0,0,129,195
9110 DATA 56,56,16,124,186,186,40,108
