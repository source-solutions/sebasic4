Auto 0

# Run-time Variables

Var a: Num = 14
Var x: Num = 14
Var y: Num = 6
Var score: Num = 40
Var ball: Num = 10
Var walk: Num = 27
Var sk: Num = 2
Var f: NumFOR = 30, 27, 3, 2400, 2
Var g: NumFOR = 8, 7, 1, 9030, 3
Var z: NumFOR = 10, 9, 1, 220, 2
Var s$: Str = "1"
Var a$: Str = "                          "
Var g$: Str = "\:'\''\''\''\''\''\''\''\''\':"
Var h$: Str = "\:         \ :"
Var y$: Str = "n"

# End Run-time Variables

  10 REM ***********************
  20 REM
  30 REM \{vi}  Penalty  Kick \{vn}
  40 REM
  50 REM        by
  60 REM
  70 REM \{vi}  Fred Hibbert  \{vn}
  80 REM
  90 REM      DEC 1984
 100 REM
 110 REM ***********************
 120 REM
 130 DEF FN M()=PEEK 23730+256*PEEK 23731-PEEK 23653-256*PEEK 23654:\{vi} REM  memory left\{vn}
 140 REM
 150 GO SUB 9000: REM udg's
 160 GO SUB 1000: REM initialise
 170 GO SUB 2000: REM screen
 180 GO SUB 2400: REM animation
 190 GO SUB 2300: REM input
 200 GO SUB 2600: REM start
 210 GO SUB 3000: REM main loop
 220 FOR z=1 TO 9
 230 GO SUB 1050: REM initialise don't reset score OR ball
 240 GO SUB 2000: REM screen
 250 GO SUB 2600: REM start
 260 GO SUB 3000: REM main loop
 270 NEXT z
 280 GO SUB 5000: REM another go
 290 GO SUB 500: REM end
 300 STOP
 310 REM
 320 REM
 330 REM \@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\{vivn}         \{vi}#######################\{vn}         \@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\{vivn}
 340 REM
 350 REM
 500 REM
 510 REM \{vi}the end of the game\{vn}
 520 REM
 530 PAPER 0: CLS : BORDER 0: INK 7
 540 PRINT AT 0,5; BRIGHT 1; INK 6;"\j\i\j "; INK 5;"PENALTY KICK"; INK 6;" \j\i\j"
 550 PRINT AT 4,0; INK 4;"\* FRED HIBBERT \* "
 560 PRINT AT 7,0; INK 3;"     DEC  84"
 570 PRINT AT 10,0; INK 2;"\i\j\i\j\i\j\i\j\i\j\i\j\i\j\i\j\i\j\i\j\i\j\i\j\i\j\i\j\i\j\i\j"
 580 PRINT AT 14,0; INK 6;" * * ";FN M();" BYTES LEFT * *"
 590 LET walk=27
 600 INK 5
 610 GO SUB 2400
 620 PRINT AT 21,0; INK 2;"T H E  E N D ": PAUSE 0
 630 RETURN
1000 REM
1010 \{vi} REM  sub to initialise\{vn}
1020 REM
1030 LET score=0
1040 LET ball=0
1050 LET x=15
1060 LET y=6
1070 LET a=19
1080 LET a$="                          "
1090 LET walk=12
1100 RETURN
2000 REM
2010 \{vi} REM   sub set up screen\{vn}
2020 REM
2030 PAPER 4: BRIGHT 0: CLS : BORDER 3: INK 1: FLASH 0
2040 PRINT AT 0,0; PAPER 1;a$
2050 PRINT AT 1,0; PAPER 1;a$
2060 PRINT AT 2,0; PAPER 1; BRIGHT 1;a$
2070 PRINT AT 3,0; PAPER 5;a$
2080 PRINT AT 4,0; PAPER 5;a$
2090 PRINT AT 5,0; PAPER 5;a$
2100 PRINT AT 0,7; BRIGHT 1; INK 2;"\j\i\j "; INK 1;"PENALTY KICK"; INK 2;" \j\i\j"
2110 PLOT 0,16: DRAW 30,108: DRAW 40,0: PLOT 254,16: DRAW -30,106: DRAW -40,0: PLOT 0,16: DRAW 255,0
2120 PLOT 44,16: DRAW 167,0,-2
2130 LET g$="\:'\''\''\''\''\''\''\''\''\':"
2140 LET h$="\:         \ :"
2150 PRINT AT 4,11; INK 0; PAPER 8;g$
2160 PRINT AT 5,11; INK 0; PAPER 8;h$
2170 PRINT AT 6,11; INK 0; PAPER 8;h$
2180 PRINT AT 2,0; PAPER 2; INK 6; BRIGHT 1;" SCORE ";score
2190 LET ball=ball+1
2200 PRINT AT 3,0; PAPER 6; INK 2; BRIGHT 1;" BALL  ";ball
2210 PRINT AT 19,15;"\j"
2220 PLOT 118,16: DRAW 12,0,-PI
2230 PRINT AT y,X; INK 0; PAPER 8;"\i"
2240 RETURN
2250 REM
2260 \{vi} REM input routine \{vn}
2300 REM
2310 INPUT "  S K I L L  level 1 TO 5  "; LINE S$
2320 IF LEN S$>1 OR CODE S$<49 OR CODE S$>53 THEN BEEP .5,-10: GO TO 2310
2330 LET SK=VAL S$
2340 LET SK=SK+1
2350 RETURN
2360 REM
2370 \{vi} REM animation routine \{vn}
2380 REM
2400 FOR f=0 TO walk STEP 3
2410 PRINT AT 20,f;"\a"
2420 PRINT AT 21,f;"\b"
2430 BEEP .2,f
2440 PRINT AT 20,f;" ";AT 21,f;" "
2450 PRINT AT 20,f+1;"\c"
2460 PRINT AT 21,f+1;"\d"
2470 BEEP .1,f+4
2480 PRINT AT 20,f+1;" ";AT 21,f+1;" "
2490 PRINT AT 20,f+2;"\e"
2500 PRINT AT 21,f+2;"\f"
2510 BEEP .2,f+8
2520 PRINT AT 20,f+2;" ";AT 21,f+2;" "
2530 PRINT AT 20,f+3;"\g"
2540 PRINT AT 21,f+3;"\h"
2550 BEEP .1,f+15
2560 PRINT AT 20,f+3;" ";AT 21,f+3;" "
2570 NEXT f
2580 IF walk=12 THEN PRINT AT 20,15;"\g";AT 21,15;"\h"
2590 RETURN
2600 REM
2610 \{vi} REM start routine \{vn}
2620 REM
2630 PRINT AT y,x; INK 0; PAPER 8;"\i"
2640 PRINT AT 20,15;"\g";AT 21,15;"\h"
2650 PRINT #1;"  \j\i\j Press a K E Y to kick \j\i\j "
2660 PAUSE 6
2670 BEEP .2,8: BEEP .2,6
2680 PAUSE 0
2690 INPUT ;
2700 PRINT AT 19,15;" "
2710 RETURN
3000 REM
3010 \{vi} REM main loop            \{vn}       \{vi}                         \{vn}
3020 REM
3030 FOR f=18 TO 6 STEP -1
3040 IF INKEY$ <>"" THEN GO SUB 3400
3050 PRINT AT f,a;"\j"
3060 \{vi} REM \{vn}
3070 IF y=f AND a=x THEN GO SUB 3800: RETURN :\{vi} REM check \{vn}
3080 \{vi} REM \{vn}
3090 BEEP 1/10,-10
3100 PRINT AT f,a;" "
3110 LET a=INT (RND *SK)+13
3120 NEXT f
3130 PRINT AT f,a; FLASH 1;"\j"
3140 GO SUB 3900
3150 RETURN
3160 REM
3400 \{vi} REM move goalkeeper\{vn}
3410 REM
3420 PRINT AT y,x; PAPER 8;" "
3430 LET x=x+(INKEY$ ="8")-(INKEY$ ="5")+(x<13)-(x>18)
3440 LET y=y+(INKEY$ ="6")-(INKEY$ ="7")+(Y<6)-(Y>8)
3450 PRINT AT y,x; INK 0; PAPER 8;"\i"
3460 RETURN
3470 REM
3480 \{vi} REM end of main loop      \{vn}           \{vi}                     \{vn}
3490 REM
3790 REM
3800 \{vi} REM saved goal\{vn}
3810 REM
3820 PRINT AT y-1,x; FLASH 1; INK 0; PAPER 8;"\i"
3830 PRINT AT 2,20; FLASH 1; BRIGHT 1; INK 6;" WELL HELD! "
3840 LET score=score+10
3850 PRINT AT 2,0; PAPER 2; INK 6; BRIGHT 1;" SCORE ";score
3860 FOR f=0 TO 21: BORDER f/3: BEEP 1/30,f: NEXT f
3870 PRINT AT 1,20; PAPER 8;a$
3880 BORDER 3
3890 RETURN
3900 REM
3910 \{vi} REM a goal\{vn}
3920 REM
3930 PRINT AT 2,23; BRIGHT 1; INK 6; PAPER 2; FLASH 1;" A GOAL! "
3940 FOR f=30 TO 0 STEP -4: BEEP 1/5,f: NEXT f
3950 RETURN
5000 REM
5010 \{vi} REM another game? \{vn}
5020 REM
5030 PRINT AT 2,0; PAPER 2; INK 6; BRIGHT 1;" SCORE ";score
5040 INPUT ;"  \j\i\j Another Game (Y/N)? \j\i\j "; LINE Y$
5050 IF Y$="Y" OR Y$="y" THEN RUN
5060 RETURN
9000 REM
9010 \{vi} REM user def. graphics\{vn}
9020 REM
9030 FOR f=0 TO 9: FOR g=0 TO 7: READ a: POKE USR CHR$ (144+f)+g,a: NEXT g: NEXT f
9040 DATA 0,56,56,16,16,24,52,50
9050 DATA 24,16,24,24,24,16,48,48
9060 DATA 0,56,56,16,16,56,52,50
9070 DATA 24,20,28,24,48,16,16,16
9080 DATA 0,56,56,16,16,56,54,80
9090 DATA 80,80,24,20,36,66,65,65
9100 DATA 0,56,56,16,16,56,56,56
9110 DATA 56,16,24,24,24,40,40,40
9120 DATA 28,28,136,126,29,29,20,54
9130 DATA 0,0,0,24,60,60,24,0
9900 RETURN
