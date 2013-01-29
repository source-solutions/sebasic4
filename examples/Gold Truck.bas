Auto 1

# Run-time Variables

Var b: Num = -1
Var c: Num = 7
Var i: Num = 5
Var l: Num = 17
Var add: Num = 32548
Var hi: Num = 0
Var sc: Num = 300
Var mp: Num = 19
Var fl: Num = 1
Var ng: Num = 15
Var le: Num = 0.1
Var osc: Num = 0
Var gold: Num = 8
Var zz: Num = 0
Var gl: Num = 16
Var gc: Num = 19
Var a: NumFOR = 5, 4, 1, 210, 2
Var h$: Str = "!!!!!"
Var a$: Str = "                     \l\m\n        "
Var b$: Str = "                     \o\p\q        "
Var c$: Str = ""

# End Run-time Variables

   2 PRINT AT 0,11-LEN STR$ sc; INK 6;sc:\
     RETURN
  10 GO SUB 8300
  20 GO SUB 8000:\
     GO SUB 5010
 100 LET zz=USR 32500:\
     PRINT #0;AT 0,0; INK 5;a$;AT 1,0;b$:\
     LET a$=a$(32)+a$( TO 31):\
     LET b$=b$(32)+b$( TO 31)
 105 IF RND<le THEN PRINT AT INT (RND*15)+5,31; INK 4;"\i"
 110 LET c$="":\
     IF INKEY$<>"" THEN LET c$=INKEY$:\
     PRINT AT 1,mp;" "
 115 IF c$="a" THEN BEEP .01,30:\
     PRINT AT 2,mp; INK 3;"\j"
 120 IF c$="m" THEN LET mp=mp+(mp<31)
 130 IF c$="n" THEN LET mp=mp-(mp>0)
 135 IF c$="z" THEN IF NOT fl THEN LET fl=1:\
     LET gl=4:\
     LET gc=mp:\
     LET gold=gold-1:\
     PRINT AT gl,gc; INK 6;"\g";AT 0,18; INK 7;gold;" "
 140 PRINT AT 1,mp; INK 6;"\h":\
     IF fl THEN GO TO 300
 200 IF le>.3 THEN IF RND>.95 THEN LET a=INT (RND*30)+1:\
     IF ATTR (2,a)=3 THEN BEEP .06,10:\
     PRINT AT 2,a; INK 2; OVER 1;"\k":\
     IF ATTR (2,a-1)=2 AND ATTR (2,a+1)=2 THEN GO TO 2000
 210 FOR a=1 TO 4:\
     NEXT a:\
     GO TO 100
 300 PRINT AT gl,gc; INK 0;"\i":\
     LET gl=gl+1:\
     IF SCREEN$ (gl,gc)="" AND gl=22 THEN GO TO 400
 320 IF gl=22 OR ATTR (gl,gc)=4 THEN LET fl=0:\
     BEEP .1,-10:\
     GO TO 340
 330 PRINT AT gl,gc; INK 6;"\g":\
     GO TO 100
 340 IF gold=0 THEN GO TO 1000
 350 GO TO 100
 400 FOR a=0 TO 10:\
     BEEP .01,a:\
     NEXT a:\
     LET fl=0:\
     LET sc=sc+150:\
     GO SUB 2:\
     IF gold=0 THEN GO TO 1000
 410 GO TO 100
1000 LET le=le+(.1 AND le<1):\
     IF sc=osc THEN GO TO 2000
1005 LET ti=FN t():\
     LET ti1=FN t():\
     IF ABS (ti-ti1)>1 THEN GO TO 1005
1010 LET b=100-ti:\
     LET sc=sc+(b AND b>0)*8:\
     BEEP .1,20:\
     GO SUB 5010
1015 LET osc=sc:\
     LET ng=ng-2*(ng>3):\
     LET gold=ng
1020 PRINT AT 0,18; INK 7;gold;" ":\
     GO TO 100
2000 FOR b=1 TO 3:\
     FOR a=40 TO 38 STEP -.05:\
     BEEP .008,a:\
     BEEP .008,a+10:\
     NEXT a:\
     NEXT b
2010 FOR a=1 TO 33:\
     LET zz=USR 32500:\
     NEXT a
2020 INPUT "":\
     FOR a=4 TO 21:\
     PRINT AT a,0;"                                ":\
     NEXT a
2030 FOR a=-20 TO 40 STEP 2:\
     BEEP .01,a:\
     BEEP .02,a-10:\
     NEXT a
2040 LET a$="                                \a\b\c         ":\
     LET b$="                                \d\e\f GAME OVER"
2050 FOR a=1 TO 45:\
     PRINT AT 8,0; INK 6;a$( TO 32);AT 9,0;b$( TO 32):\
     LET a$=a$(2 TO )+a$(1):\
     LET b$=b$(2 TO )+b$(1)
2060 BEEP .05,10:\
     NEXT a:\
     PRINT AT 8,0; INK 6;a$( TO 32);AT 9,0;b$( TO \{vnvn}32)\{vn}
2070 LET c$="G A M E    O V E R":\
     LET i=6:\
     LET c=7:\
     LET l=7:\
     GO SUB 3000
2080 LET c$="FINAL  SCORE":\
     LET i=5:\
     LET c=10:\
     LET l=10:\
     GO SUB 3000
2090 LET c$="000000"( TO 6-LEN STR$ sc)+STR$ sc:\
     LET i=7:\
     LET c=13:\
     LET l=12:\
     GO SUB 3000
2100 IF sc<=hi THEN GO TO 2200
2110 LET c$="NEW HIGH SCORE":\
     LET c=9:\
     LET i=4:\
     LET l=14:\
     GO SUB 3000
2120 INPUT "ENTER YOUR INITIALS (MAX-4):       "; LINE h$:\
     IF LEN h$<>4 THEN GO TO 2120
2130 LET hi=sc
2200 LET c$="CURRENT HIGH SCORE":\
     LET i=6:\
     LET c=7:\
     LET l=14:\
     GO SUB 3000
2210 LET c$="000000"( TO 6-LEN STR$ hi)+STR$ hi:\
     LET i=4:\
     LET c=13:\
     LET l=16:\
     GO SUB 3000
2240 FOR a=1 TO -10 STEP -1:\
     BEEP .07,a:\
     BEEP 01,-a+20:\
     NEXT a:\
     FOR a=1 TO 10:\
     NEXT a
2250 GO TO 4000
3000 FOR a=21 TO l STEP -1:\
     PRINT AT a,c; INK i;c$
3010 NEXT a
3020 FOR a=21 TO l+1 STEP -1:\
     PRINT AT a,c; OVER 1;c$:\
     NEXT a:\
     RETURN
3900 LET h$="!!!!!":\
     LET hi=0:\
     POKE 23609,100
4000 BORDER 1:\
     PAPER 1:\
     INK 7:\
     CLS
4010 LET c$="**************":\
     LET c=9:\
     LET i=6:\
     LET l=1:\
     GO SUB 3000
4020 LET c$="*            *":\
     LET l=2:\
     GO SUB 3000
4030 LET c$="* GOLD TRUCK *":\
     LET l=3:\
     GO SUB 3000
4040 LET c$="*            *":\
     LET l=4:\
     GO SUB 3000
4050 LET c$="**************":\
     LET l=5:\
     GO SUB 3000
4060 LET c$="WRITTEN BY NEIL PELLINACCI  1984":\
     LET i=7:\
     LET c=0:\
     LET l=9:\
     GO SUB 3000
4070 LET c$="THE KEYS ARE":\
     LET c=10:\
     LET i=5:\
     LET l=11:\
     GO SUB 3000
4080 RESTORE 4100:\
     LET l=13:\
     FOR a=1 TO 4:\
     READ a$,c:\
     PRINT AT l,c; INK 6;a$:\
     BEEP .5,l*2:\
     LET l=l+1:\
     NEXT a
4090 PRINT AT 20,5;"PRESS ANY KEY TO START":\
     BEEP .5,l*2
4100 DATA "'M'   MOVE RIGHT",8,"'N'   MOVE  LEFT",8,"'Z'   DROP  GOLD",8," 'A'   REPAIR  HOLE",7
4110 PAUSE 0:\
     GO TO 10
5000 DEF FN t()=INT ((65536*PEEK 23674+256*PEEK 23673+PEEK 23672)/50)
5010 POKE 23672,0:\
     POKE 23673,0:\
     POKE 23674,0:\
     RETURN
6000 PRINT AT 0,0;FN t():\
     GO TO 6000
8000 REM Screen
8010 BORDER 0:\
     PAPER 0:\
     INK 7:\
     CLS
8020 PRINT AT 0,0; INK 4;"SCORE:"; INK 6;"00000"; INK 5;"  GOLD:"; INK 7;"15"; INK 4;"  HIGH:"; INK 6;"00000"
8025 PRINT AT 0,32-LEN STR$ hi; INK 6;hi
8030 PRINT AT 2,0; INK 3;"\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j\j";AT 3,0;"\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k"
8040 LET a$="          \l\m\n                   ":\
     LET b$="          \o\p\q                   "
8050 FOR a=4 TO 21:\
     PRINT AT a,0; INK 0;"\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i\i":\
     NEXT a
8100 RETURN
8300 REM Variables
8310 LET sc=0:\
     LET mp=11:\
     LET fl=0
8320 LET ng=15:\
     LET le=.1:\
     LET osc=0:\
     LET gold=ng
8400 RETURN
8900 STOP
9000 REM UDGs
9010 RESTORE 9000:\
     FOR a=USR "a" TO USR "q"+7:\
     READ b:\
     POKE a,b:\
     NEXT a
9020 DATA 0,0,0,0,7,8,10,16,0,63,109,109,237,109,109,237,0,254,183,b,b,b,b,b,31,16,31,48,38,47,15,6
9030 DATA 127,63,245,234,85,127,0,0,255,254,127,195,153,189,60,24,0,0,0,60,126,255,b,0,0,0,24,60,90,255,219,231
9040 DATA 0,252,255,253,189,b,206,120,255,b,153,255,102,255,153,255,0,255,0,255,102,b,b,b,0,127,237,b,b,b,b,b
9050 DATA 0,252,182,b,183,182,b,183,0,0,0,0,224,16,80,8,255,127,254,195,153,189,60,24
9060 DATA 254,252,175,87,170,254,0,0,248,8,248,12,100,244,240,96
9100 CLEAR 32499:\
     RESTORE 9100:\
     LET add=32500
9110 READ b:\
     IF b=-1 THEN GO TO 3900
9120 POKE add,b:\
     LET add=add+1
9130 GO TO 9110
9150 DATA 33,160,88,6,15,14,31,35,126,254,4,32,15,54,0,43,126,254,24,32,4,54,45,24,2,54,4,35,13
9160 DATA 32,232,35,16,227,33,160,88,17,32,0,6,15,54,0,25,16,251,201
9170 DATA -1
9200 CLEAR :\
     SAVE "GOLD TRUCK" LINE 9000
