Auto 1

# Run-time Variables

Var a: Num = 0
Var hiscore: Num = 0
Var n: NumFOR = 7, 6, 1, 6065, 2
Var g: NumFOR = 8, 7, 1, 6070, 2
Var f: NumFOR = 51, 50, 1, 8406, 3
Var a$: Str = ""
Var k$: StrArray(4) = "poqs"

# End Run-time Variables

   1 REM Dash it!
   2 REM by Arjun Nair 2004
   3 REM Version 2: Modified Sep 2005
   4 REM ****************************
   5 CLEAR : RANDOMIZE
  10 CLS : LET hiscore=0
  11 DIM k$(4): LET k$(1)="p": LET k$(2)="o": LET k$(3)="q": LET k$(4)="s"
  15 GO SUB 6060: REM init graphics
  20 GO SUB 8000: REM main menu
  30 GO SUB 1000: REM game loop
  50 GO TO 20
 100 REM Initialise game
 110 LET lives=3: LET dir=0: LET score=0: LET seedtime=50: LET level=1
 115 LET quanta=5*level: LET time=seedtime+(level*30): CLS
 120 PRINT AT 1,0; INK 3;"\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b";AT 20,0; INK 3;"\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
 130 FOR f=1 TO 19
 140 PRINT AT f,0; INK 3;"\b";AT f,31; INK 3;"\b"
 150 NEXT f
 160 LET x=10: LET y=10
 250 FOR f=1 TO 5*level
 260 LET p=INT (RND*17)+2
 270 LET q=INT (RND*28)+2
 280 IF ((p=y AND q=x) OR (ATTR (p,q)=5)) THEN GO TO 260: REM don't overwrite player or another quanta!
 290 PRINT AT p,q; INK 5;"\g"
 300 NEXT f
 999 RETURN
1000 REM main game loop
1005 GO SUB 100: REM initialise
1010 PRINT AT 21,0;"Lives: ";lives;TAB 20;"Score: ";score
1020 PRINT AT 0,0;"Time: ";time;"      "
1030 PRINT AT 0,20;"Level: ";level
2000 LET a$=INKEY$
2010 IF a$=k$(1) THEN LET dir=1: REM right
2020 IF a$=k$(2) THEN LET dir=2: REM left
2030 IF a$=k$(3) THEN LET dir=3: REM up
2040 IF a$=k$(4) THEN LET dir=4: REM down
2045 IF dir<>0 THEN PRINT AT y,x; INK 1;CHR$ (143)
2050 IF dir=1 THEN LET x=x+1
2060 IF dir=2 THEN LET x=x-1
2070 IF dir=3 THEN LET y=y-1
2080 IF dir=4 THEN LET y=y+1
2090 IF (ATTR (y,x)=3 OR ATTR (y,x)=1) THEN FOR f=0 TO 4: PRINT AT y,x; PAPER 2; INK 6; FLASH 1;CHR$ (145+f); FLASH 0: BEEP 0.4,RND*f: NEXT f: PAUSE 10: GO TO 6000
2095 IF ATTR (y,x)=5 THEN LET score=score+(level*10): LET quanta=quanta-1: BEEP 0.01,0.1: IF quanta=0 THEN PRINT AT 10,3; PAPER 1; INK 5; FLASH 1;"Space-Time Jump! Get Ready!"; FLASH 0: FOR f=1 TO 10: BEEP 0.03,RND*f: NEXT f: PAUSE 50: LET level=level+1: GO TO 6020
3000 PRINT AT y,x; INK 4;"\a"
3005 LET time=time-1
3010 IF time=0 THEN PRINT AT 10,5; PAPER 2; INK 6; FLASH 1;"S-T Field Collapsing!"; FLASH 0: FOR f=10 TO 1 STEP -1: BEEP 0.1,f/2: NEXT f: PAUSE 50: FOR f=2 TO 19: PRINT AT f,1; PAPER 1; INK 2;"\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::": BEEP 0.05,RND*f/2: NEXT f: GO TO 6000
4000 GO TO 1010
6000 LET lives=lives-1
6010 IF lives=0 THEN PRINT AT 10,10; PAPER 4; INK 1;"  GAME OVER!  ": PAUSE 100
6012 IF lives=0 THEN IF score>hiscore THEN LET hiscore=score: PRINT AT 12,10; PAPER 5; INK 1; FLASH 1;"New High Score!"; FLASH 0: PAUSE 100
6015 IF lives=0 THEN RETURN
6020 LET dir=0: LET x=10: LET y=10: LET a$="": PAUSE 100: GO SUB 115: GO TO 1010
6050 PAUSE 0: RETURN
6060 REM ********UDG data***
6065 FOR n=0 TO 6
6070 FOR g=0 TO 7: READ a
6080 POKE USR CHR$ (144+n)+g,a
6090 NEXT g: NEXT n
7000 DATA 66,60,126,219,255,102,60,66,161,60,111,94,122,254,60,133,128,60,122,120,100,120,54,1,8,52,28,128,228,44,144,1
7001 DATA 0,0,20,50,32,18,0,0,255,255,255,255,255,255,255,255
7002 DATA 0,0,0,24,24,0,0,0
7003 RETURN
8000 REM *** Main Menu ***
8010 BORDER 0: PAPER 0: INK 6: CLS : LET a$="":
8020 PRINT "\f\f\f\f\f\f\f\f\f\f\f\f\{i2p2i6}Dash it!\f\f\f\f\f\f\f\f\f\f\f\f\{p2i2p7i0p0i7}"
8030 PRINT AT 5,7; INK 3;"1) Play game"
8040 PRINT AT 7,7; INK 4;"2) Redefine Keys"
8050 PRINT AT 9,7; INK 5;"3) Instructions"
8060 PRINT AT 11,7; INK 6;"4) Credits"
8070 PRINT AT 15,7; INK 7;" High Score: ";hiscore
8080 PRINT #0; INK 2;TAB 5;"(c) 2004 Arjun Nair"
8090 LET a$=INKEY$:
8095 IF a$="" OR a$>"4" THEN GO TO 8090
8096 BEEP 0.3,10
8100 IF a$="0" THEN PRINT #0;"For my parents and Lina, Shreya & Hazel": PAUSE 200: CLS
8110 IF a$="1" THEN RETURN
8120 IF a$="2" THEN GO SUB 8400
8130 IF a$="3" THEN GO SUB 9000
8140 IF a$="4" THEN GO SUB 8300
8150 GO TO 8010
8300 REM *** Credits ***
8310 CLS
8320 PRINT "Dash it! was originally written": PRINT "especially for the CSS Crap     ": PRINT "Games Competition 2004.": PRINT '"This version is an updated one ": PRINT "with some bug fixes and sound!": PRINT "It's still crap though! :) "
8330 PRINT : PRINT "Developed on the BASin IDE      written by Paul Dunn."
8350 PRINT : PRINT "Hello to all WoS regulars (and  irregulars) and to folks at CSS.Speccy forever! Amen."
8360 PRINT \{vnvn}#0; INK 5;"       www.yantragames.com "
8370 PAUSE 0
8380 RETURN
8400 REM *** Redefine keys ***
8405 LET k$(1)="": LET k$(2)="": LET k$(3)="": LET k$(4)=""
8406 PAUSE 10: FOR f=1 TO 50: NEXT f
8410 PRINT AT 15,7; INK 7;"Press key for left": PAUSE 0
8420 LET k$(2)=INKEY$
8430 IF k$(2)="" THEN GO TO 8420
8435 BEEP 0.1,20
8440 PRINT AT 15,7; INK 7;"Press key for right": PAUSE 0
8450 LET k$(1)=INKEY$
8460 IF k$(1)="" THEN GO TO 8450
8465 BEEP 0.1,20
8470 PRINT AT 15,7; INK 7;"Press key for up    ": PAUSE 0
8480 LET k$(3)=INKEY$
8490 IF k$(3)="" THEN GO TO 8480
8495 BEEP 0.1,20
8500 PRINT AT 15,7; INK 7;"Press key for down    ": PAUSE 0
8510 LET k$(4)=INKEY$
8520 IF k$(4)="" THEN GO TO 8480
8525 BEEP 0.1,20
8530 PRINT AT 15,5; INK 7;"  Keys Redefined!          ": PAUSE 100
8540 RETURN
9000 REM *****Main Menu*******
9005 BORDER 0: PAPER 0: INK 6: CLS
9010 PRINT "\f\f\f\f\f\f\f\f\f\f\f\f\{i2p2i6}Dash it!\f\f\f\f\f\f\f\f\f\f\f\f\{p2i2p7i0p0i7}"
9015 PRINT
9020 PRINT "Krapz the mysterious alien findshimself trapped in a Space-Time continuum warp. The only way to survive is to keep on the move, and collect the quanta particlesin the vicinity that will give  him the necessary boost to jump out the warp."
9025 PRINT
9030 PRINT "Be forewarned though that there are other warps in the vicinity too and you may well jump into  another more tricky one."
9035 PRINT
9040 PRINT "You must also stay clear of the ST fluctuations you leave behindin your wake. Touching them willmean instant death. Avoid the   walls of the warp too for the   same reasons."
9050 PRINT #0;"Keys: Left=";k$(2);" Right=";k$(1);" Up=";k$(3);" Down=";k$(4)
9060 PAUSE 0
9070 RETURN
