Auto 300

# Run-time Variables

Var t: Num = 0
Var p: Num = 0
Var u: Num = 13
Var v: Num = 20
Var w: Num = 0
Var g: Num = 200
Var tt: Num = 0
Var m: NumFOR = 13, 4, 2, 30, 2
Var n: NumFOR = 20, 30, 2, 38, 2
Var a: NumFOR = 13, 20, 1, 240, 2
Var r: NumFOR = 3, 6, 1, 50, 2
Var a$: Str = ""

# End Run-time Variables

  10 LET tt=-1
  20 LET tt=tt+1:\
     LET t=0:\
     LET p=1:\
     BORDER 5:\
     INK 0:\
     PAPER 7:\
     CLS
  30 FOR m=1 TO 4 STEP 2
  32 FOR n=0 TO 30 STEP 2
  34 PRINT AT m+3,n; PAPER m;"\q\e";:\
     PRINT AT m+4,n; PAPER m+1;"\e\q"
  36 NEXT n:\
     NEXT m
  38 FOR n=0 TO 30 STEP 2
  40 PRINT AT m+3,n; PAPER m+1;"\q\e":\
     NEXT n
  46 LET u=0:\
     LET v=0
  48 LET a=14:\
     LET t=0:\
     LET w=0
  50 FOR r=1 TO 6
  52 LET m=10:\
     LET n=8+INT (RND *14)
  54 LET g=200:\
     LET p=0:\
     LET a=13
  56 PRINT AT 21,0;"             \:'\''\':                "
  65 GO SUB g:\
     PRINT AT u,v;" "
  70 PRINT AT m,n;"\b":\
     LET u=m:\
     LET v=n
  74 IF m=20 THEN PRINT AT m,n;"\c"
  80 PAUSE 5:\
     LET a$=INKEY$ :\
     IF a$="o" THEN GO SUB 220
  81 IF a$="O" THEN GO SUB 224
  85 IF a$="p" THEN GO SUB 230
  86 IF a$="P" THEN GO SUB 234
  90 GO TO 60
 100 IF m>20 THEN GO TO 240
 101 IF m<20 THEN GO TO 106
 102 IF t>=558 THEN GO TO 20
 103 LET p=0:\
     LET w=0:\
     IF n=a+1 OR n=a+2 THEN LET g=120:\
     GO TO 120
 104 IF n=a THEN LET g=180:\
     GO TO 190
 105 IF n=a-1 THEN LET g=140:\
     GO TO 140
 106 IF n>30 THEN LET g=160:\
     GO TO 160
 110 LET m=m+1:\
     LET n=n+1
 112 LET c=ATTR (m,n):\
     IF c<>56 THEN GO SUB 250:\
     IF p=0 OR w=1 THEN LET g=120
 114 RETURN
 120 IF n>30 THEN LET g=140:\
     GO TO 140
 125 IF m<1 THEN LET w=1:\
     LET g=100:\
     GO TO 100
 130 LET m=m-1:\
     LET n=n+1
 132 LET c=ATTR (m,n):\
     IF c<>56 THEN GO SUB 250:\
     LET p=1:\
     LET g=100+40*w
 134 RETURN
 140 IF m<1 THEN LET w=1:\
     LET g=160:\
     GO TO 160
 145 IF n<1 THEN LET g=120:\
     GO TO 120
 150 LET m=m-1:\
     LET n=n-1
 152 LET c=ATTR (m,n):\
     IF c<>56 THEN GO SUB 250:\
     LET p=1:\
     LET g=160-40*w
 154 RETURN
 160 IF m>20 THEN GO TO 240
 161 IF m<20 THEN GO TO 166
 162 IF t>=558 THEN GO TO 20
 163 LET p=0:\
     LET w=0:\
     IF n=a+3 THEN LET g=120:\
     GO TO 120
 164 IF n=a+2 THEN LET g=180:\
     GO TO 180
 165 IF n=a OR n=a+1 THEN LET g=140:\
     GO TO 140
 166 IF n<1 THEN LET g=100:\
     GO TO 100
 170 LET m=m+1:\
     LET n=n-1
 172 LET c=ATTR (m,n):\
     IF c<>56 THEN GO SUB 250:\
     IF p=0 OR w=1 THEN LET g=140
 174 RETURN
 180 IF m<1 THEN LET g=200:\
     GO TO 212
 190 LET m=m-1:\
     LET c=ATTR (m,n):\
     IF c<>56 THEN GO SUB 250:\
     LET g=200
 195 RETURN
 200 IF m>20 THEN GO TO 240
 202 IF m<20 THEN GO TO 212
 203 IF t>=558 THEN GO TO 20
 204 LET p=0:\
     LET w=0:\
     IF n=a+2 THEN LET g=120:\
     GO TO 120
 206 IF n=a+1 THEN LET g=20*(6+INT (RND *2)):\
     GO TO g
 210 IF n=a THEN LET g=140:\
     GO TO 140
 212 LET m=m+1:\
     RETURN
 220 IF a<1 THEN RETURN
 222 LET a=a-1:\
     PRINT AT 21,a;"\:'\''\':\  ":\
     RETURN
 224 IF a<2 THEN GO TO 220
 226 LET a=a-2:\
     PRINT AT 21,a;"\:'\''\':\   ":\
     RETURN
 230 IF a>28 THEN RETURN
 232 LET a=a+1:\
     PRINT AT 21,a-1;" \:'\''\':":\
     RETURN
 234 IF a>27 THEN GO TO 230
 236 LET a=a+2:\
     PRINT AT 21,a-2;"  \:'\''\':":\
     RETURN
 240 FOR a=1 TO 20:\
     BEEP .02,20-a:\
     NEXT a:\
     BEEP .1,-20
 242 NEXT r
 244 CLS :\
     LET yy=32:\
     LET xs=4:\
     LET ys=4:\
     LET p$="SCORE":\
     GO SUB 3000:\
     LET yy=72:\
     LET p$=STR$ (tt*600+t):\
     GO SUB 3000:\
     LET xs=1:\
     LET ys=2:\
     LET yy=128:\
     LET p$="Press y to play again":\
     GO SUB 3000:\
     LET yy=152:\
     LET p$="Press n to exit":\
     GO SUB 3000
 246 LET a$=INKEY$ :\
     IF a$="y" THEN RUN
 247 IF a$<>"n" THEN GO TO 246
 248 STOP
 250 LET t=t+10-c/8
 252 LET b=ABS (m-n)
 254 LET y=INT (b/2)*2
 256 IF b=y AND n<31 THEN PRINT AT m,n+1;" "
 258 IF b<>y AND n>0 THEN PRINT AT m,n-1;" "
 260 RETURN
 300 CLEAR 32255:\
     LOAD "WallGFX.bin"CODE USR "a":\
     LOAD "WallCODE.bin"CODE 32256
 310 PAPER 5:\
     CLS :\
     INK 0:\
     BORDER 5
 320 REM LET yy=80:\
    LET xs=2:\
    LET ys=2:\
    LET p$="STOP THE TAPE":\
    FLASH 1:\
    GO SUB 3000:\
    FLASH 0
 330 LET yy=20:\
     LET xs=2:\
     LET ys=3:\
     LET p$="THRO' THE WALL":\
     GO SUB 3000
 350 LET yy=120:\
     LET xs=2:\
     LET ys=2:\
     LET p$="PSION   \*1982":\
     GO SUB 3000
 360 LET yy=160:\
     LET xs=1:\
     LET ys=2:\
     LET p$="   Press any key to continue   ":\
     GO SUB 3000
 370 PAUSE 0
 400 PAPER 7:\
     CLS
 410 PRINT AT 2,0;"   This is a BASIC program        It illustrates how you can      program your own real time        games on the SPECTRUM            using simple BASIC"
 500 PRINT AT 10,2;"Get ready to move......."''"      p to move right"''"      o to move left"''"      CAPS SHIFT for extra zip"
 510 PLOT 16,86:\
     DRAW 134,0
 520 PRINT AT 20,3;"PRESS ANY KEY TO START"
 530 PAUSE 0:\
     RUN
3090 LET xx=(256-8*xs*LEN p$)/2
3100 LET i=23306:\
     POKE i,xx:\
     POKE i+1,yy:\
     POKE i+2,xs:\
     POKE i+3,ys:\
     POKE i+4,8:\
     LET i=i+4:\
     LET w=LEN p$:\
     FOR n=1 TO w:\
     POKE i+n,CODE p$(n):\
     NEXT n:\
     POKE i+w+1,255:\
     LET w=USR 32256:\
     RETURN
9990 SAVE "wall" LINE 300
9992 SAVE "wallg"CODE USR "a",168
9994 SAVE "c"CODE 32256,300
