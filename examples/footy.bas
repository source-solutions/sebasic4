Auto 8

# Run-time Variables

Var l: Num = 0
Var m: Num = 100000
Var s: Num = 0
Var was: Num = 0
Var des: Num = 0
Var px: Num = 0
Var py: Num = 0
Var ho: Num = 0
Var aw: Num = 0
Var re: Num = 0
Var s5: Num = 0
Var s1: Num = 0
Var xp: Num = 0
Var f: NumArray(3, 2) = 0, 0, 0, 0, 0, 0
Var g: NumArray(3, 2) = 0, 0, 0, 0, 0, 0
Var d: NumArray(4) = 0, 0, 0, 0
Var k: NumArray(3) = 0, 0, 0
Var s: NumArray(2) = 0, 0
Var a: NumArray(5) = 0, 0, 0, 0, 0
Var u: NumArray(5) = 0, 0, 0, 0, 0
Var z: NumArray(17) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var b: NumArray(16) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var c: NumArray(16) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var p: NumArray(24) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var t: NumArray(16) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var x: NumArray(2) = 0, 0
Var y: NumArray(24) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var r: NumArray(24) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var v: NumArray(24) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var d$: StrArray(1) = " "
Var k$: StrArray(2) = "  "
Var f$: StrArray(8) = "        "
Var u$: StrArray(16) = "                "
Var l$: StrArray(7, 16) = "                                                                                                                "
Var r$: StrArray(3, 2) = "      "
Var p$: StrArray(24, 8) = "                                                                                                                                                                                                "
Var t$: StrArray(64, 12) = "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                "
Var a$: StrArray(7, 9) = "                                                               "
Var q$: StrArray(3, 5) = "               "

# End Run-time Variables

   8 CLS :\
     PRINT "FOOTBALL MANAGER"'"\* Copyright K. J. Toms 1982":\
     PAUSE 300
   9 BORDER 7:\
     INK 0:\
     PAPER 7:\
     FLASH 0:\
     BRIGHT 0:\
     OVER 0:\
     INVERSE 0:\
     CLS :\
     INPUT "Type your name "; LINE m$:\
     IF LEN m$>20 THEN CLS :\
     PRINT "Name is too long (max 20 chars.)":\
     PAUSE 200:\
     GO TO 9
  10 GO SUB 9000:\
     GO SUB 8900
  98 DEF FN p(p)=INT ((p-1)/8+1)
  99 DEF FN r(x)\{f0}=INT (RND *x+1)
 100 RANDOMIZE
 101 GO SUB 2000
 110 IF x$="keep" OR x$="KEEP" THEN GO TO 800
 120 GO SUB 4000
 130 GO SUB 8000
 140 GO SUB 8100
 150 GO SUB 8700
 199 GO TO 100
 260 RESTORE 261
 261 DATA 24,88,126,26,120,72,206,2,48,48,24,60,28,56,48,40,24,24,30,58,24,42,36,32,24,24,24,28,60,24,28,8,24,24,60,90,90,60,36,102,0,0,0,0,0,0,3,3,24,26,126,88,30,18,115,64,12,12,24,60,56,28,12,20,24,24,120,92,24,84,36,4,24,24,24,56,60,24,56,8,0,0,0,0,0,0,192,192,24,24,61,90,56,28,20,36,24,24,188,90,28,56,40,36,12,12,60,91,152,62,64,192,48,48,60,218,25,124,2,3
 265 FOR i=0 TO 15*8-1
 266 READ q:\
     POKE USR "a"+i,q
 267 NEXT i
 269 RETURN
 270 PRINT INK 6;AT k(2),k(1);k$(k(3)):\
     LET k(3)=INT (1.5/k(3))+1:\
     LET r3=(d(2)>k(2)+(d(4)<>0))-(d(2)<k(2)-(d(4)<>0)):\
     PRINT INK ho;AT k(2)+r3,23-(k(2)+r3);k$(k(3)):\
     LET k(2)=k(2)+r3:\
     LET k(1)=23-k(2)
 271 RETURN
 280 PRINT INK 6;AT k(2),k(1);k$(k(3)):\
     LET k(3)=INT (1.5/k(3))+1:\
     LET r3=(d(2)>k(2)+(d(4)<>0))-(d(2)<k(2)-(d(4)<>0)):\
     PRINT INK aw;AT k(2)+r3,(k(2)+8+r3);k$(k(3)):\
     LET k(2)=k(2)+r3:\
     LET k(1)=k(2)+8
 281 RETURN
 290 OVER 0
 292 PRINT INK 6; PAPER 2;AT 0,0;"****\::    \::\::  \::\::\::  \::\:: \::\::\::\:: \::*********\:: \::\::\..\:: \::\:: \:: \::\:: \:: \::\::\::\:: \::*********\:: \::\.. \:: \::\:: \:: \..\.. \:: \::\::\::\::\..\::*********\::    \::\::  \::\:: \::\:: \::    \:: \::*****"
 293 FOR r=1 TO 5+FN r(5):\
     BEEP .05,FN r(36):\
     NEXT r
 294 GO SUB 1090
 295 RETURN
 300 BORDER 7:\
     BRIGHT 1:\
     INK 6:\
     PAPER 4:\
     LET was=6:\
     LET f$="\a\b\c\d\e\n\l\h":\
     LET d$="\f":\
     LET k$="\l\h":\
     LET k(3)=1:\
     CLS
 301 PLOT 71,88:\
     DRAW -16,-8:\
     DRAW -8,-16:\
     DRAW 24,0:\
     PLOT 8,0:\
     DRAW 175,175:\
     PLOT 72,64:\
     DRAW 0,24:\
     DRAW 48,48:\
     DRAW 0,-24:\
     PLOT 64,56:\
     DRAW 24,0:\
     DRAW 64,64:\
     DRAW -24,0:\
     PLOT 32,24:\
     DRAW 96,0:\
     DRAW 115,115:\
     DRAW -96,0
 302 PLOT 119,135:\
     DRAW -16,-8:\
     DRAW -8,-16:\
     DRAW 24,0
 303 PLOT 102,126:\
     DRAW -48,-48:\
     PLOT 158,84:\
     DRAW 2,0:\
     PLOT 158,85:\
     DRAW 2,0:\
     PLOT 201,96:\
     DRAW -40,-40,-2*PI /5
 304 OVER 1
 310 LET f(1,2)=3+FN r(18):\
     LET f(1,1)=25+FN r(6):\
     LET d(1)=f(1,1)-1:\
     LET d(2)=f(1,2):\
     LET d(3)=-1:\
     LET d(4)=0:\
     LET k(1)=11+FN r(2)+2*(f(1,2)<11)-2*(f(1,2)>10):\
     LET k(2)=23-k(1)
 311 FOR i=2 TO 3
 312 LET f(i,1)=10+FN r(20):\
     LET f(i,2)=FN r(21)
 313 IF f(i,1)+f(i,2)<25 OR f(i,1)>f(1,1)-4 THEN GO TO 312
 314 FOR j=1 TO 3:\
     IF (f(i,2)=f(j,2)) AND (j<>i) THEN GO TO 312
 315 NEXT j:\
     NEXT i
 316 FOR i=1 TO 3
 317 LET g(i,1)=10+FN r(10):\
     LET g(i,2)=FN r(18)
 318 IF g(i,1)+g(i,2)<24 OR g(i,1)>f(1,1)-4 THEN GO TO 317
 319 FOR j=1 TO 3:\
     IF (g(i,2)=f(j,2)) OR ((g(i,2)=g(j,2)) AND (j<>i)) THEN GO TO 317
 320 NEXT j:\
     NEXT i
 322 PRINT INK aw;AT f(1,2),f(1,1);f$(1):\
     FOR i=2 TO 3:\
     PRINT INK aw;AT f(i,2),f(i,1);f$(1+2*(f(i,2)<10)):\
     NEXT i
 323 FOR i=1 TO 3:\
     PRINT INK ho;AT g(i,2),g(i,1);f$(2+2*(g(i,2)<10)):\
     NEXT i
 325 PRINT INK 1;AT d(2),d(1);d$
 326 PRINT INK ho;AT k(2),k(1);k$(1)
 340 LET oop=0:\
     LET dri=FN r(3)*2-1:\
     LET wm=1
 341 FOR e=1 TO dri:\
     LET wm1=wm:\
     LET wm=INT (1.5/wm)+1:\
     PRINT INK 6;AT d(2),d(1);d$; INK 1;AT d(2),d(1)-1;d$:\
     LET d(1)=d(1)-1:\
     GO SUB 360:\
     NEXT e
 342 FOR j=1 TO 3:\
     PRINT INK 6;AT g(j,2),g(j,1);f$(wm1+2*(g(j,2)<10)); INK ho;AT g(j,2),g(j,1);f$(5):\
     NEXT j:\
     FOR j=2 TO 3:\
     PRINT INK 6;AT f(j,2),f(j,1);f$(wm+2*(f(j,2)<10)); INK aw;AT f(j,2),f(j,1);f$(5):\
     NEXT j:\
     PRINT INK 6;AT f(1,2),f(1,1);f$(2)
 343 PRINT INK aw;AT f(1,2),f(1,1);f$(1):\
     BEEP .15,-40:\
     LET d(4)=(d(2)<8)-(d(2)>15)+(d(2)>12 AND d(2)<16)*(FN r(2)-2):\
     LET d(3)=-2:\
     GO SUB 350:\
     GO SUB 350:\
     GO SUB 350:\
     PRINT INK aw;AT f(1,2),f(1,1);f$(1);AT f(1,2),f(1,1);f$(5)
 344 IF oop<>1 THEN GO SUB 350:\
     GO TO 344
 345 IF (d(1)+d(2)<22) AND (d(2)<14) AND (d(2)>4) AND (d(1)<15) AND (d(1)>6) AND NOT (d(1)=7 AND d(2)=13 AND d(4)<0) THEN LET s(2)=s(2)+1:\
     GO SUB 290:\
     GO TO 347
 346 OVER 0:\
     PRINT INK 0; PAPER 7;AT 1,10;"NO GOAL!":\
     BEEP .25,-50
 347 PAUSE 200
 349 RETURN
 350 LET px=d(1)+d(3):\
     LET py=d(2)+d(4):\
     LET des=ATTR (py,px):\
     IF ((py+px=24) OR (py+px=25) OR (py+px=26) OR (py+px=27)) AND py>7 AND py<14 THEN GO SUB 270
 351 IF px+py<22 OR py<0 OR py>21 OR px>31 THEN LET oop=1:\
     PRINT INK was;AT d(2),d(1);d$:\
     LET d(2)=py:\
     LET d(1)=px:\
     GO TO 358
 352 IF des<>102 THEN LET d(3)=(des=96+ho)*2+(des=96+aw)*-2:\
     LET d(4)=(d(3)=-2)*(FN r(2)-2)+(d(3)=2)*(FN r(3)-2):\
     PRINT INK was;AT d(2),d(1);d$; INK (des-96);AT py,px;d$;AT py,px;f$(5*(py+px<>23)+(py+px=23)*(6+k(3)));AT py,px;f$(6):\
     BEEP .15,-30:\
     BEEP .08,-40:\
     PRINT INK (des-96);AT py,px;f$(6);AT py,px;f$(5*(py+px<>23)+(py+px=23)*(6+k(3))):\
     LET d(2)=py:\
     LET d(1)=px:\
     GO TO 359
 353 PRINT INK was;AT d(2),d(1);d$; INK 1;AT py,px;d$:\
     LET d(2)=py:\
     LET d(1)=px:\
     GO TO 359
 358 IF (px+py<22) AND (py>=0) AND (py<=21) AND (px>=0) AND (px<=31) THEN PRINT INK 1;AT py,px;d$:\
     GO TO 359
 359 LET was=des-96:\
     RETURN
 360 PRINT INK 6;AT f(1,2),f(1,1);f$(wm1); INK aw;AT f(1,2),f(1,1)-1;f$(wm):\
     LET f(1,1)=f(1,1)-1:\
     FOR i=2 TO 3:\
     LET py=f(i,2)+1*(f(i,2)<10)-1*(f(i,2)>9):\
     LET px=f(i,1)-1:\
     LET des=ATTR (py,px)
 361 IF des=102 AND (py+px>24) THEN PRINT INK 6;AT f(i,2),f(i,1);f$(wm1+2*(f(i,2)<10)):\
     PRINT INK aw;AT py,px;f$(wm+2*(py<10)):\
     LET f(i,2)=py:\
     LET f(i,1)=px:\
     GO TO 363
 362 PRINT INK 6;AT f(i,2),f(i,1);f$(wm1+2*(f(i,2)<10)); INK aw;AT f(i,2),f(i,1);f$(wm+2*(f(i,2)<10))
 363 NEXT i
 365 FOR i=1 TO 3:\
     LET py=g(i,2)+1*(g(i,2)<10)-1*(g(i,2)>9):\
     LET px=g(i,1)-1:\
     LET des=ATTR (py,px)
 366 IF des=102 AND (py+px>23) THEN PRINT INK 6;AT g(i,2),g(i,1);f$(wm+2*(g(i,2)<10)):\
     PRINT INK ho;AT py,px;f$(wm1+2*(py<10)):\
     LET g(i,2)=py:\
     LET g(i,1)=px:\
     GO TO 368
 367 PRINT INK 6;AT g(i,2),g(i,1);f$(wm+2*(g(i,2)<10)); INK ho;AT g(i,2),g(i,1);f$(wm1+2*(g(i,2)<10))
 368 NEXT i
 379 RETURN
 400 BORDER 7:\
     BRIGHT 1:\
     INK 6:\
     PAPER 4:\
     LET was=6:\
     LET f$="\g\h\i\j\e\o\m\b":\
     LET d$="\k":\
     LET k$="\m\b":\
     LET k(3)=1:\
     CLS
 401 PLOT 184,88:\
     DRAW 16,-8:\
     DRAW 8,-16:\
     DRAW -24,0:\
     PLOT 247,0:\
     DRAW -175,175:\
     PLOT 183,64:\
     DRAW 0,24:\
     DRAW -48,48:\
     DRAW 0,-24:\
     PLOT 191,56:\
     DRAW -24,0:\
     DRAW -64,64:\
     DRAW 24,0:\
     PLOT 223,24:\
     DRAW -96,0:\
     DRAW -115,115:\
     DRAW 96,0
 402 PLOT 136,135:\
     DRAW 16,-8:\
     DRAW 8,-16:\
     DRAW -24,0
 403 PLOT 153,126:\
     DRAW 48,-48:\
     PLOT 94,84:\
     DRAW 2,0:\
     PLOT 94,85:\
     DRAW 2,0:\
     PLOT 55,96:\
     DRAW 40,-40,2*PI /5
 404 OVER 1
 410 LET f(1,2)=3+FN r(18):\
     LET f(1,1)=6-FN r(6):\
     LET d(1)=f(1,1)+1:\
     LET d(2)=f(1,2):\
     LET d(3)=1:\
     LET d(4)=0:\
     LET k(1)=20-FN r(2)-2*(f(1,2)<11)+2*(f(1,2)>10):\
     LET k(2)=k(1)-8
 411 FOR i=2 TO 3
 412 LET f(i,1)=21-FN r(20):\
     LET f(i,2)=FN r(21)
 413 IF f(i,1)-f(i,2)>6 OR f(i,1)<f(1,1)+4 THEN GO TO 412
 414 FOR j=1 TO 3:\
     IF (f(i,2)=f(j,2)) AND (j<>i) THEN GO TO 412
 415 NEXT j:\
     NEXT i
 416 FOR i=1 TO 3
 417 LET g(i,1)=21-FN r(10):\
     LET g(i,2)=FN r(18)
 418 IF g(i,1)-g(i,2)>7 OR g(i,1)<f(1,1)+4 THEN GO TO 417
 419 FOR j=1 TO 3:\
     IF (g(i,2)=f(j,2)) OR ((g(i,2)=g(j,2)) AND (j<>i)) THEN GO TO 417
 420 NEXT j:\
     NEXT i
 422 PRINT INK ho;AT f(1,2),f(1,1);f$(1):\
     FOR i=2 TO 3:\
     PRINT INK ho;AT f(i,2),f(i,1);f$(1+2*(f(i,2)<10)):\
     NEXT i
 423 FOR i=1 TO 3:\
     PRINT INK aw;AT g(i,2),g(i,1);f$(2+2*(g(i,2)<10)):\
     NEXT i
 425 PRINT INK 1;AT d(2),d(1);d$
 426 PRINT INK aw;AT k(2),k(1);k$(1)
 440 LET oop=0:\
     LET dri=FN r(3)*2-1:\
     LET wm=1
 441 FOR e=1 TO dri:\
     LET wm1=wm:\
     LET wm=INT (1.5/wm)+1:\
     PRINT INK 6;AT d(2),d(1);d$; INK 1;AT d(2),d(1)+1;d$:\
     LET d(1)=d(1)+1:\
     GO SUB 460:\
     NEXT e
 442 FOR j=1 TO 3:\
     PRINT INK 6;AT g(j,2),g(j,1);f$(wm1+2*(g(j,2)<10)); INK aw;AT g(j,2),g(j,1);f$(5):\
     NEXT j:\
     FOR j=2 TO 3:\
     PRINT INK 6;AT f(j,2),f(j,1);f$(wm+2*(f(j,2)<10)); INK ho;AT f(j,2),f(j,1);f$(5):\
     NEXT j:\
     PRINT INK 6;AT f(1,2),f(1,1);f$(2)
 443 PRINT INK ho;AT f(1,2),f(1,1);f$(1):\
     BEEP .15,-40:\
     LET d(4)=(d(2)<8)-(d(2)>15)+(d(2)>12 AND d(2)<16)*(FN r(2)-2):\
     LET d(3)=2:\
     GO SUB 450:\
     GO SUB 450:\
     GO SUB 450:\
     PRINT INK ho;AT f(1,2),f(1,1);f$(1);AT f(1,2),f(1,1);f$(5)
 444 IF oop<>1 THEN GO SUB 450:\
     GO TO 444
 445 IF (d(1)-d(2)>9) AND (d(2)<14) AND (d(2)>4) AND (d(1)>16) AND (d(1)<25) AND NOT (d(1)=24 AND d(2)=13 AND d(4)<0) THEN LET s(1)=s(1)+1:\
     GO SUB 290:\
     GO TO 447
 446 OVER 0:\
     PRINT INK 0; PAPER 7;AT 1,10;"NO GOAL!":\
     BEEP .25,-50
 447 PAUSE 200
 449 RETURN
 450 LET px=d(1)+d(3):\
     LET py=d(2)+d(4):\
     LET des=ATTR (py,px):\
     IF ((px-py=7) OR (px-py=6) OR (px-py=5) OR (px-py=4)) AND py>7 AND py<14 THEN GO SUB 280
 451 IF px-py>9 OR py<0 OR py>21 OR px<0 THEN LET oop=1:\
     PRINT INK was;AT d(2),d(1);d$:\
     LET d(2)=py:\
     LET d(1)=px:\
     GO TO 458
 452 IF des<>102 THEN LET d(3)=(des=96+ho)*2+(des=96+aw)*-2:\
     LET d(4)=(d(3)=2)*(FN r(2)-2)+(d(3)=-2)*(FN r(3)-2):\
     PRINT INK was;AT d(2),d(1);d$; INK (des-96);AT py,px;d$;AT py,px;f$(5*(px-py<>8)+(px-py=8)*(6+k(3)));AT py,px;f$(6):\
     BEEP .15,-30:\
     BEEP .08,-40:\
     PRINT INK (des-96);AT py,px;f$(6);AT py,px;f$(5*(px-py<>8)+(px-py=8)*(6+k(3))):\
     LET d(2)=py:\
     LET d(1)=px:\
     GO TO 459
 453 PRINT INK was;AT d(2),d(1);d$; INK 1;AT py,px;d$:\
     LET d(2)=py:\
     LET d(1)=px:\
     GO TO 459
 458 IF (px-py>9) AND (py>=0) AND (py<=21) AND (px>=0) AND (px<=31) THEN PRINT INK 1;AT py,px;d$:\
     GO TO 459
 459 LET was=des-96:\
     RETURN
 460 PRINT INK 6;AT f(1,2),f(1,1);f$(wm1); INK ho;AT f(1,2),f(1,1)+1;f$(wm):\
     LET f(1,1)=f(1,1)+1:\
     FOR i=2 TO 3:\
     LET py=f(i,2)+1*(f(i,2)<10)-1*(f(i,2)>9):\
     LET px=f(i,1)+1:\
     LET des=ATTR (py,px)
 461 IF des=102 AND (px-py<7) THEN PRINT INK 6;AT f(i,2),f(i,1);f$(wm1+2*(f(i,2)<10)):\
     PRINT INK ho;AT py,px;f$(wm+2*(py<10)):\
     LET f(i,2)=py:\
     LET f(i,1)=px:\
     GO TO 463
 462 PRINT INK 6;AT f(i,2),f(i,1);f$(wm1+2*(f(i,2)<10)); INK ho;AT f(i,2),f(i,1);f$(wm+2*(f(i,2)<10))
 463 NEXT i
 465 FOR i=1 TO 3:\
     LET py=g(i,2)+1*(g(i,2)<10)-1*(g(i,2)>9):\
     LET px=g(i,1)+1:\
     LET des=ATTR (py,px)
 466 IF des=102 AND (px-py<8) THEN PRINT INK 6;AT g(i,2),g(i,1);f$(wm+2*(g(i,2)<10)):\
     PRINT INK aw;AT py,px;f$(wm1+2*(py<10)):\
     LET g(i,2)=py:\
     LET g(i,1)=px:\
     GO TO 468
 467 PRINT INK 6;AT g(i,2),g(i,1);f$(wm+2*(g(i,2)<10)); INK aw;AT g(i,2),g(i,1);f$(wm1+2*(g(i,2)<10))
 468 NEXT i
 479 RETURN
 800 SAVE "football" LINE 100
 805 INPUT "Do you want to play some more?"' LINE i$:\
     IF i$<>"y" AND i$<>"Y" AND i$<>"yes" AND i$<>"YES" THEN NEW
 810 GO TO 100
1000 PRINT ,,"You've \`";m;" \{i2}You owe \`";l\{i0}''
1002 RETURN
1010 CLS :\
     PRINT ' BRIGHT 1; INVERSE 1;"You haven't enough money!"
1015 RETURN
1020 PRINT ,,a$(7);t(t1-lt);TAB 13;\{i1}"League match no.=";\{i0}ml
1022 RETURN
1030 GO SUB 1180:\
     BEEP .2,0:\
     INPUT BRIGHT 1; INK 0; PAPER 6;"Hit ENTER to continue"; LINE y$
1031 IF Y$="H" OR y$="h" THEN COPY :\
     GO TO 1030
1032 RETURN
1040 IF xz<1 THEN LET xz=1
1041 IF xz>20 THEN LET xz=20
1043 RETURN
1050 CLS
1052 PRINT "\{i3vi}p\{i3i0i0vn} = picked to play, \{i4vi}i\{i0vn} = injured"
1053 RETURN
1080 PRINT BRIGHT 1; INK 0; PAPER 6;"\{vivn}OR type 99 to continue":\
     BEEP .2,0
1084 RETURN
1090 PRINT INK 0; PAPER 7;t$(x(1));TAB 12;s(1),t$(x(2));TAB 28;s(2)
1092 RETURN
1100 PRINT TAB 8;a$(6);d1
1102 RETURN
1120 LET p=0
1122 LET p1=0
1125 FOR r=1 TO 24
1130 IF p(r)=2 THEN LET p=p+1
1135 IF p(r)>0 THEN LET p1=p1+1
1140 NEXT r
1142 PRINT "\{vi}PLAYERS PICKED\{vn}=";\{i0}p''
1145 RETURN
1150 FOR q=1 TO 100*FN r(10)
1151 NEXT q
1159 RETURN
1160 LET xz=a(i)
1165 GO SUB 1040
1166 LET a(i)=xz
1169 RETURN
1170 GO SUB 1180:\
     INPUT LINE i$
1171 IF i$="h" OR i$="H" THEN COPY :\
     GO TO 1170
1172 FOR q=1 TO LEN i$:\
     IF CODE i$(q)<48 OR CODE i$(q)>57 THEN GO TO 1170
1175 NEXT q
1178 LET q=VAL ("0"+i$)
1179 RETURN
1180 PRINT AT 21,24;"(h=copy)"
1189 RETURN
2000 CLS
2020 PRINT "TO -","TYPE -",,,"\{i2}Sell or list"\{i0},," \{i2}your Players\{i0}","  - a",,,"\{i1}Print score etc\{i0}","  - s",,,"\{i2}Obtain a loan","  - l",,,"\{i1}Pay off loan","  - p"''"\{i0}Change your"'"   skill level","  - level"''"\{i0}Change team or"'"  player names","  - change",,,"Save game","  - keep",,,
2040 GO SUB 1080
2180 GO SUB 1180:\
     INPUT LINE x$
2181 IF x$="h" OR x$="H" THEN COPY :\
     GO TO 2180
2200 IF x$="a" OR x$="A" THEN GO SUB 2400:\
     GO TO 2000
2202 IF x$="l" OR x$="L" THEN GO SUB 2800:\
     GO TO 2000
2204 IF x$="s" OR x$="S" THEN GO SUB 3000:\
     GO TO 2000
2206 IF x$="p" OR x$="P" THEN GO SUB 2900:\
     GO TO 2000
2208 IF x$="change" OR x$="CHANGE" THEN GO SUB 9400:\
     GO SUB 9500:\
     GO TO 2000
2210 IF x$="level" OR x$="LEVEL" THEN GO SUB 3200:\
     GO TO 2000
2220 GO TO 2000+299*(x$="keep" OR x$="KEEP" OR x$="99")
2299 RETURN
2400 GO SUB 1050
2435 GO SUB 2540
2440 FOR n=1 TO 24
2443 IF p(n)=0 THEN GO TO 2460
2445 LET pl=n
2450 GO SUB 2550
2460 NEXT n
2462 GO SUB 1120
2470 PRINT "\{i1vi}TYPE NO. OF PLAYER TO BE SOLD\{i0vn}"
2471 GO SUB 1080
2473 GO SUB 1170
2474 LET i=q
2475 IF i=99 THEN GO TO 2539
2476 IF i<1 OR i>24 THEN GO TO 2473
2477 IF p(i)=0 THEN GO TO 2473
2478 IF i=99 THEN GO TO 2539
2479 CLS
2480 IF p(i)<>3 THEN GO TO 2484
2481 PRINT "\{i2}He is injured- nobody wants him!\{i0}"
2482 GO SUB 1030
2483 GO TO 2539
2484 LET o=INT (((RND *5+8)*v(i))/10)
2485 PRINT t$(FN r(64));" \{i1}have offered \`";\{i0}o," \{i1}for ";p$(i)''"He is worth \`";v(i):\
     GO SUB 1180:\
    \{i2} INPUT "Do you accept?\{i0}", LINE i$\{i0}
2486 IF i$="h" OR i$="H" THEN COPY :\
     CLS :\
     GO TO 2485
2492 IF i$="YES" OR i$="yes" OR i$="Y" OR i$="y" THEN GO TO 2500
2494 GO TO 2535
2500 LET p(i)=0
2505 LET m=m+o
2509 CLS
2510 PRINT p$(i);" has been sold"
2512 GO SUB 1030
2516 GO TO 2539
2535 IF FN r(3)=1 THEN GO TO 2539
2536 LET p(i)=3
2539 RETURN
2540 PRINT BRIGHT 1; PAPER 6;"  NAME   NO. \{i0}SKILL \{i0}ENERGY VALUE\{i0p0p7b0}"
2545 RETURN
2550 PRINT INK FN p(pl)-1; INVERSE 1;r$(INT ((pl-1)/8+1)); INVERSE 0;p$(pl);" ";pl;TAB 15;r(pl);TAB 20;y(pl);TAB 24;"\`";v(pl);TAB 31;q$(p(pl)+(p(pl)=0))
2555 RETURN
2800 CLS
2802 GO SUB 1000
2804 PRINT '"\{vii1}Type loan amount required (\`)"\{vn}
2805 GO SUB 1170
2806 LET i=q
2807 CLS
2820 IF i+l>250000*d2 THEN PRINT "\{i2vi}Sorry, your credit limit is\{vnvnvi}-\{vn}",,"\` ";250000*d2:\
     GO SUB 1030:\
     GO TO 2800
2830 LET m=m+i:\
     LET l=l+i
2834 GO SUB 1000
2838 GO SUB 1030
2840 \{i0} RETURN
2900 CLS :\
     GO SUB 1000
2905 PRINT '"\{i1vi}Type amount you want to pay off your loan (\`)"\{i0vn}
2910 GO SUB 1170
2915 LET i=q
2917 CLS
2920 IF i>l THEN PRINT "\{vi}YOU DON'T OWE THAT MUCH!\{vn}":\
     GO SUB 1030:\
     GO TO 2900
2925 IF i>m THEN GO SUB 1010:\
     GO SUB 1030:\
     GO TO 2900
2930 LET l=l-i:\
     LET m=m-i
2935 GO SUB 1000
2940 GO SUB 1030
2945 RETURN
3000 CLS
3002 PRINT t$(t1),"Colours = ";("Black" AND (tco=0))+("White" AND (tco=7))
3004 PRINT '"Manager : ";m$'
3007 IF s5=0 THEN GO TO 3010
3008 LET s1=INT (s/s5)*2
3009 IF s1>100 THEN LET s1=100
3010 PRINT '"\{i2vi}Managerial Rating(Max 100)= ";s1\{vni0}
3012 PRINT '"\{i2}Level ";l1\{i0}, BRIGHT 1; INK l1; PAPER 9;l$(l1); BRIGHT 0;"\{i0p7} "''"Seasons ";s5\{i0}
3016 GO SUB 1000
3020 PRINT a$(2);a(2)
3030 GO SUB 1020
3032 GO SUB 1030
3040 RETURN
3200 CLS
3205 PRINT \{i0}"Your present skill level is -"'"Level ";l1, BRIGHT 1; INK l1; PAPER 9;l$(l1):\
     PRINT ''"The choices are -"''
3210 FOR i=1 TO 7
3215 PRINT i, BRIGHT 1; INK i; PAPER 9;l$(i)
3220 NEXT i
3230 PRINT "Enter your chosen level number":\
     GO SUB 1170
3240 IF q<1 OR q>7 THEN CLS :\
     PRINT "1\#0557 please!":\
     PAUSE 300:\
     GO TO 3200
3250 LET l1=q:\
     CLS :\
     PRINT \{i0}"Your new skill level is -"'"Level ";l1, BRIGHT 1; INK l1; PAPER 9;l$(l1):\
     GO SUB 1030
3260 RETURN
4000 LET ma=ma+1
4001 LET lc=2
4005 IF ma=3 THEN LET ma=0:\
     LET lc=1
4010 IF fa=1 THEN LET lc=2
4025 GO SUB 4100
4029 RETURN
4100 CLS
4105 IF lc<>1 THEN GO TO 4120
4110 LET c=c+1
4118 LET v1=INT ((8-c)*8+FN r(8))
4119 IF v1=t1 THEN GO TO 4118
4120 IF lc<>2 THEN GO TO 4140
4121 LET ml=ml+1
4125 LET v1=ml+lt
4130 IF v1=t1 THEN LET v1=lt+16
4140 FOR i=1 TO 5
4150 IF lc=1 THEN LET u(i)=INT (FN r(16)+l1+((t1-1)/16)-((v1-1)/16+1))
4152 IF lc=2 THEN LET u(i)=INT (FN r(14)+l1+(z(v1-lt)/ml))
4155 LET xz=u(i):\
     GO SUB 1040:\
     LET u(i)=xz
4160 NEXT i
4190 IF lc=1 THEN GO SUB 4500:\
     LET h=FN r(2)
4200 IF lc=2 THEN LET h=INT ((1.5/h1)+1):\
     LET h1=h
4205 LET v=INT ((1.5/h)+1)
4210 IF lc=1 THEN GO SUB 4600
4215 IF lc=2 THEN GO SUB 4700
4220 LET x(h)=t1
4222 LET x(v)=v1
4224 LET s(1)=0
4225 LET s(2)=0
4230 IF lc=1 THEN PRINT "\{i2}F.A.Cup Match - Round ";c$\{i0}
4232 IF lc=2 THEN PRINT "\{i1}League Match - ";a$(6);d1\{i0}
4235 GO SUB 4240
4236 GO TO 4245
4240 PRINT 'TAB 6;t$(x(1));" v ";t$(x(2)),,,a$(5+lc);x1;TAB 20;x2
4242 RETURN
4245 GO SUB 1030
4250 GO SUB 6000
4280 GO SUB 5000
4322 PRINT "\{i1vi}Gate receipts \`";x9\{vn}
4325 LET m=m+x9
4326 GO SUB 1030
4329 IF lc=2 THEN GO TO 4340
4330 IF s(h)<>s(v) THEN GO TO 4340
4332 CLS
4333 PRINT "\{vni3}Replay-"\{i0}
4334 GO SUB 1030
4335 CLS
4336 LET h=INT ((1.5/h)+1)
4337 LET v=INT ((1.5/v)+1)
4338 GO TO 4210
4340 IF lc=1 THEN GO SUB 5200
4342 IF lc=2 THEN GO SUB 7000
4350 IF s(h)>s(v) THEN LET a(2)=a(2)+INT ((20-a(2))/2)
4360 IF s(h)<s(v) THEN LET a(2)=INT (a(2)/2)
4370 LET i=2
4374 GO SUB 1160
4380 IF lc=2 THEN GO SUB 7500:\
     GO SUB 7710
4499 RETURN
4500 IF c<7 THEN LET c$=STR$ c
4510 IF c=7 THEN LET c$="Semi-Final"
4520 IF c=8 THEN LET c$="Final"
4530 RETURN
4600 IF h=1 THEN LET x1=d1:\
     LET x2=INT ((v1-1)/16)+1:\
     LET x9=g
4610 IF h=2 THEN LET x1=INT ((v1-1)/16)+1:\
     LET x2=d1:\
     LET x9=(5-x1)*10000
4620 IF c=7 THEN LET x9=50000
4622 IF c=8 THEN LET x9=100000
4630 RETURN
4700 IF h=1 THEN LET x1=t(t1-lt):\
     LET x2=t(v1-lt):\
     LET x9=g
4710 IF h=2 THEN LET x1=t(v1-lt):\
     LET x2=t(t1-lt):\
     LET x9=(17-t(v1-lt))*d2*500
4720 RETURN
5000 PRINT BRIGHT 1; INK 7; PAPER 3;"**MATCH HIGHLIGHTS TO FOLLOW!-**"
5001 LET ho=(h=1)*tco+(h<>1)*(7-tco):\
     LET aw=7-ho:\
     GO SUB 260
5002 FOR o=1 TO 5
5005 LET n=FN r(100)+(a(o)-u(o))*5
5010 IF n>=75 THEN GO SUB 300+100*(h=1):\
     GO SUB 300+100*(h=1)
5050 LET n=FN r(100)+(u(o)-a(o))*5
5060 IF n>=75 THEN GO SUB 300+100*(v=1):\
     GO SUB 300+100*(v=1)
5100 NEXT o
5101 IF s(1)+s(2)=0 THEN GO SUB 400:\
     GO SUB 300
5105 INK 0:\
     PAPER 7:\
     BRIGHT 0:\
     OVER 0:\
     CLS :\
     PRINT INVERSE 1; INK 2;"**** FINAL SCORE ****":\
     GO SUB 1090:\
     OVER 0
5110 RETURN
5200 CLS
5204 IF s(h)<s(v) THEN LET fa=1:\
     PRINT \{vi}"+++You're out of the Cup+++"\{vn}:\
     LET a(2)=INT (a(2)/2):\
     GO TO 5230
5210 IF c<8 THEN PRINT "\{i2vi}****You are through to the next",,"round!****      "\{vn}
5212 IF c<>8 THEN GO TO 5220
5213 PRINT BRIGHT 1; INK 1; PAPER 6;'"            \{vi}      \{vn}                        \{vi}          \{vn}                      \{vi} \{vn} \{vi}      \{vn} \{vi} \{vn}                      \{vi}          \{vn}                        \{vi}      \{vn}                           \{vi}    \{vn}                             \{vi}  \{vn}                              \{vi}  \{vn}                             \{vi}    \{vn}                           \{vi}      \{vn}              "
5214 PRINT FLASH 1; BRIGHT 1;"\{i1vi}!!!!!!!!!You've won the !!!!!!!!!!!!!!!!!  F.A. CUP     !!!!!!!!"\{i0vni0vn}
5216 FOR i=1 TO 9:\
     PRINT FLASH 1; BRIGHT 1;"\{i2vi}********************************":\
     BEEP .2,i\{i0vn}:\
     NEXT i
5218 LET fa=1
5220 LET a(2)=a(2)+INT ((20-a(2))/2)
5230 LET i=2
5237 GO SUB 1160:\
     GO SUB 1030
5299 RETURN
6000 IF ml=1 AND c=0 THEN GO TO 6112
6020 FOR i=1 TO 24
6030 LET y(i)=y(i)+(p(i)=1 OR p(i)=3)*10+(p(i)=2)*-1
6050 IF p(i)=3 THEN LET p(i)=1
6060 LET xz=y(i)
6062 GO SUB 1040
6064 LET y(i)=xz
6070 IF p(i)=0 OR FN r(20)<20 THEN GO TO 6100
6080 LET p(i)=3
6100 NEXT i
6112 CLS
6113 GO SUB 6500
6115 GO SUB 1120
6120 PRINT "\{i1vi}Type c to change team"\{i0vn}
6130 GO SUB 1080
6135 GO SUB 1180:\
     INPUT LINE i$:\
     IF i$="h" OR i$="H" THEN COPY :\
     GO TO 6135
6136 IF i$="99" THEN CLS :\
     GO TO 6499
6142 GO SUB 1050
6145 GO SUB 2540
6150 FOR i=1 TO 24
6151 IF p(i)=0 THEN GO TO 6180
6152 LET pl=i
6160 GO SUB 2550
6180 NEXT i
6190 GO SUB 1120
6200 IF p>11 THEN GO TO 6300
6210 PRINT "\{i1vi}Type Player No. to add to team"\{i0vn}
6215 GO SUB 1080
6216 GO SUB 1170
6217 LET i=q
6218 IF i=99 THEN GO TO 6112
6220 IF i<1 OR i>24 THEN PRINT "\{vi}PLAYER NO. OUT OF RANGE"\{vn}:\
     GO TO 6216
6225 IF p(i)<>1 THEN PRINT "\{vi}PLAYER NOT AVAILABLE"\{vn}:\
     GO TO 6216
6230 LET p(i)=2
6240 GO TO 6142
6300 PRINT "\{i1vi}Type player no. to remove from"'"team"
6310 \{i0vn} GO SUB 1170
6312 LET i=q
6320 IF i<1 OR i>24 THEN PRINT "\{vi}PLAYER NO. OUT OF RANGE\{vn}":\
     GO TO 6310
6325 IF p(i)<>2 THEN PRINT "\{vi}PLAYER NOT IN TEAM\{vn}":\
     GO TO 6310
6330 LET p(i)=1
6340 GO TO 6142
6499 RETURN
6500 FOR i=1 TO 5
6501 LET a(i)=a(i)*(i=2)
6502 NEXT i
6505 FOR i=1 TO 24
6510 IF p(i)<>2 THEN GO TO 6550
6520 LET q=INT ((i-1)/8)+3
6530 LET a(q)=a(q)+r(i)
6540 LET a(1)=a(1)+y(i)
6550 NEXT i
6560 LET a(1)=INT (a(1)/11)
6605 PRINT TAB 10;t$(t1);TAB 22;t$(v1)
6610 FOR i=1 TO 5
6615 GO SUB 1160
6620 PRINT a$(i);TAB 13;a(i);TAB 25;u(i)
6630 NEXT i
6640 RETURN
7000 LET b(t1-lt)=b(t1-lt)+s(h)
7005 LET c(t1-lt)=c(t1-lt)+s(v)
7010 LET b(v1-lt)=b(v1-lt)+s(v)
7015 LET c(v1-lt)=c(v1-lt)+s(h)
7020 IF s(h)=s(v) THEN LET z(t1-lt)=z(t1-lt)+1:\
     LET z(v1-lt)=z(v1-lt)+1:\
     GO TO 7099
7030 IF s(h)<s(v) THEN LET g=g-INT (g/10):\
     LET g=g+(g<1000)*(1000-g):\
     LET z(v1-lt)=z(v1-lt)+3:\
     GO TO 7099
7070 LET g=g+INT (((10000*d2)-g)/10):\
     LET z(t1-lt)=z(t1-lt)+3
7099 RETURN
7500 CLS
7510 PRINT "\{vi}OTHER MATCHES-"\{vn}
7520 GO SUB 1100
7530 FOR i=1 TO 16
7532 LET t(i)=0
7534 NEXT i
7540 LET t(t1-lt)=1
7542 LET t(v1-lt)=1
7550 FOR i=1 TO 7
7560 LET r=FN r(16)
7570 IF t(r)=1 THEN GO TO 7560
7580 LET t(r)=1
7585 LET r1=FN r(16)
7590 IF t(r1)=1 THEN GO TO 7585
7600 LET t(r1)=1
7610 LET r2=INT ((z(r)/ml)+RND *4)
7620 LET r3=INT ((z(r1)/ml)+RND *4)
7630 PRINT t$(r+lt);TAB 12;r2,t$(r1+lt);TAB 28;r3
7640 LET b(r)=b(r)+r2
7645 LET b(r1)=b(r1)+r3
7650 LET c(r)=c(r)+r3
7655 LET c(r1)=c(r1)+r2
7660 IF r2>r3 THEN LET z(r)=z(r)+3
7670 IF r2<r3 THEN LET z(r1)=z(r1)+3
7682 LET z(r)=z(r)+(r2=r3)
7684 LET z(r1)=z(r1)+(r2=r3)
7690 NEXT i
7700 GO SUB 1030
7705 RETURN
7710 CLS
7720 PRINT INK 1; PAPER 6; FLASH 1; BRIGHT 1;"Please wait while the league    table is calculated-            "
7729 IF ml>1 THEN GO TO 7734
7730 \{i0vn} FOR i=1 TO 16
7732 LET u$(i)=CHR$ (i)
7733 NEXT i
7734 LET pass=1
7735 LET change=0
7736 FOR i=1 TO 16-pass
7738 LET q=CODE u$(i):\
     LET q1=CODE u$(i+1)
7742 IF z(q)>z(q1) THEN GO TO 7800
7744 IF z(q)<z(q1) THEN GO TO 7770
7746 IF b(q)-c(q)>b(q1)-c(q1) THEN GO TO 7800
7748 IF b(q)-c(q)<b(q1)-c(q1) THEN GO TO 7770
7749 IF b(q)>b(q1) THEN GO TO 7800
7750 GO TO 7770
7770 LET q2=CODE (u$(i)):\
     LET u$(i)=u$(i+1):\
     LET u$(i+1)=CHR$ (q2):\
     LET change=1
7800 NEXT i
7801 LET pass=pass+1:\
     IF change THEN GO TO 7735
7802 GO SUB 7805
7803 RETURN
7805 CLS
7806 PRINT INK 7; PAPER 1; BRIGHT 1;"TEAM","  F   A    PTS"
7807 FOR i=1 TO 16
7808 LET q1=CODE u$(i)
7810 PRINT t$(q1+lt);TAB 18;b(q1);TAB 22;c(q1);TAB 28;z(q1)
7820 LET t(q1)=i
7830 NEXT i
7840 GO SUB 1020
7845 GO SUB 1030
7850 RETURN
8000 CLS
8020 LET w=0
8022 FOR i=1 TO 24
8024 IF p(i)>0 THEN LET w=w+r(i)*100*d2
8027 NEXT i
8032 PRINT "\{i2vi}****WEEKLY BILLS****"\{i0vn}''"\{i2vn}Wage Bill = \`";w'"Ground rent = \`";x'"Loan Interest = \`";INT (l/100)
8036 \{i0} LET m=m-w-x-INT (l/100)
8040 LET i=m-l-xp:\
     PRINT "\{i1}Weekly Balance = "\{i0}; INK 0+(i<0)*2;"\`";i\{i0}
8045 LET xp=m-l
8050 IF m>=0 THEN GO TO 8060
8051 LET l=l-m
8052 LET m=0
8056 PRINT "\{vi}LOAN INCREASED TO PAY BILLS"\{vn}
8060 IF l>250000*d2 THEN PRINT "\{vii4}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\{i0}YOU OWE OVER \`";250000*D2'"\{i4}++++\{i0}YOU'VE BEEN SACKED BY THE \{i4}+++++++++++++++++++++++++++\{i0}CLUB!\{i4}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\{i0vn}":\
     GO SUB 1030:\
     NEW
8070 GO SUB 1030
8099 RETURN
8100 IF ml<15 OR fa=0 THEN GO TO 8499
8120 CLS
8130 PRINT "\{i2vi}****End of Season****"\{i0vn}
8135 GO SUB 1030
8140 GO SUB 7805
8145 CLS
8146 LET r1=17-t(t1-lt)
8150 LET s=s+r1+c*2*d1
8220 LET m=m+r1*5000*d2
8222 PRINT "\{vii4}League Success Bonus Money =",,"        \`";r1*5000*d2\{i0vn}
8230 LET s5=s5+1
8235 FOR i=1 TO 16
8240 GO SUB 8500
8243 GO SUB 8600
8246 NEXT i
8250 GO SUB 8800
8260 PRINT "\{i1vi}****New Season****\{i0vn}"
8270 GO SUB 1100
8280 GO SUB 1030
8499 RETURN
8500 IF t(i)>3 THEN GO TO 8579
8515 IF d1=1 THEN GO TO 8570
8520 PRINT t$(lt+i);" \{i1}are promoted*****************************************"\{i0}
8530 LET x$=t$(lt-t(i))
8540 LET t$(lt-t(i))=t$(lt+i)
8550 LET t$(lt+i)=x$
8552 IF lt+i=t1 THEN LET t1=(lt-t(i))
8560 GO TO 8579
8570 IF t(i)=1 THEN PRINT t$(lt+i);"\{i2} are League Champions*********************************"\{i0}
8579 RETURN
8600 IF d1=4 THEN GO TO 8699
8610 IF t(i)<14 THEN GO TO 8699
8620 PRINT t$(lt+i);" \{i3}are relegated++++++++++++++++++++++++++++++++++++++++"\{i0}
8630 LET x$=t$(d1*16+17-t(i))
8640 LET t$(d1*16+17-t(i))=t$(lt+i)
8645 LET t$(lt+i)=x$
8650 IF lt+i=t1 THEN LET t1=d1*16+17-t(i)
8699 RETURN
8700 IF ml=0 THEN GO TO 8780
8702 LET r1=FN r(24)
8704 IF p(r1)>0 THEN GO TO 8700
8705 CLS
8710 PRINT "\{i4vi}****Transfer Market****"\{i0vn}''
8711 IF p1>15 THEN PRINT "\{i3}You cannot buy a player because you have 16 in your squad - thatis the maximum allowed under    F.A. rules."\{i0}:\
     GO TO 8778
8715 GO SUB 1000
8720 GO SUB 2540
8725 LET pl=r1
8730 GO SUB 2550
8740 PRINT '"\{i1vi}Type your bid (\`)"\{i0vn}''
8742 GO SUB 1080
8745 GO SUB 1170
8746 LET n=q
8750 IF n=99 THEN GO TO 8780
8755 IF m>=n THEN GO TO 8760
8756 GO SUB 1010
8757 GO SUB 1030
8758 GO TO 8705
8760 LET r=(FN r(10)*n)/v(r1)
8761 CLS
8762 IF r>=5 THEN GO TO 8770
8766 GO SUB 8785:\
     GO SUB 1030
8768 GO TO 8705
8770 PRINT p$(r1);" has joined your team"
8773 LET v(r1)=r(r1)*5000*d2
8774 LET m=m-n
8775 LET p(r1)=1
8778 GO SUB 1030
8780 RETURN
8785 LET v(r1)=INT (v(r1)+v(r1)/5)
8786 PRINT '"\{vi}YOUR BID IS REFUSED"\{vn}
8788 RETURN
8800 LET d1=INT (((t1-1)/16)+1)
8801 LET fa=0
8802 LET lt=(d1-1)*16
8803 LET lc=0
8804 LET h=1
8805 LET d2=5-d1
8806 LET ma=1
8807 LET ml=0
8808 LET y=0
8809 LET z=0
8810 FOR i=1 TO 16
8811 LET z(i)=0
8812 LET t(i)=0
8813 LET b(i)=0
8814 LET c(i)=0
8818 NEXT i
8819 LET v=0
8820 FOR i=1 TO 24
8824 LET v(i)=INT (5000*d2*FN r(5))
8827 LET r(i)=INT (v(i)/(5000*d2))
8830 LET y(i)=FN r(20)
8832 NEXT i
8834 LET z(17)=-1
8835 LET a(2)=10
8840 LET g=5000*d2
8845 LET c=0
8850 LET x=500*d2
8855 LET h1=2
8890 RETURN
8900 LET d1=0
8902 LET d1=d1+1
8905 IF d1>4 THEN GO TO 8900
8910 CLS
8912 PRINT BRIGHT 1;"\{i1vi}CHOOSE TEAM TO MANAGE -\{i0vn}"
8915 PRINT "\{i1}NUMBER\{i0i0i1}","NAME"\{i0}
8916 LET lt=(d1-1)*16
8920 FOR i=lt+1 TO lt+16
8925 PRINT i,t$(i)
8930 NEXT i
8935 PRINT INK 0; PAPER 6;"Type team number of the team youwant to manage (or 99 for more  choice)"
8937 GO SUB 1170
8938 LET t1=q
8940 IF t1=99 THEN GO TO 8902
8945 IF t1<lt+1 OR t1>lt+16 THEN GO TO 8935
8947 LET d1=4
8950 LET y$=t$(64)
8951 LET t$(64)=t$(t1)
8952 LET t$(t1)=y$
8953 LET t1=64
8955 CLS
8957 FOR i=1 TO 7:\
     PRINT i, BRIGHT 1; INK i; PAPER 9;l$(i):\
     NEXT i
8960 PRINT "\{i1}Type your level (1-7)"\{i0}
8962 GO SUB 1170
8963 LET l1=q
8965 IF l1<1 OR l1>7 THEN GO TO 8955
8966 CLS :\
     PRINT "Enter your team colours (0=Blackor 7=White)":\
     GO SUB 1170:\
     LET tco=q:\
     CLS :\
     IF tco<>0 AND tco<>7 THEN PRINT "0 or 7 please!":\
     PAUSE 200:\
     GO TO 8966
8970 FOR i=1 TO 12
8975 LET r=FN r(24)
8980 IF p(r)>0 THEN GO TO 8975
8985 LET p(r)=2
8986 IF i=12 THEN LET p(r)=1
8987 NEXT i
8990 GO SUB 8800
8999 RETURN
9000 RESTORE 9030
9005 FOR i=1 TO 24
9010 READ p$(i)
9020 NEXT i
9030 DATA "P.Parkes","D.Watson","P.Neal","A.Martin","K.Sansom","M.Mills","R.Osman","S.Foster","B.Robson","G.Hoddle","G.Rix","S.Hunt","G.Owen","R.Moses","B.Talbot","S.McCall","C.Regis","P.Withe","T.Morley","P.Barnes","E.Gates","K.Reeves","K.Keegan","G.Shaw"
9155 LET a$(1)="Energy"
9160 LET a$(2)="Morale"
9165 LET a$(3)="Defence"
9170 LET a$(4)="Midfield"
9175 LET a$(5)="Attack"
9180 LET a$(6)="Division "
9190 LET a$(7)="Lge.Pos. "
9191 LET l$(1)="Beginner":\
     LET l$(2)="Novice":\
     LET l$(3)="Average":\
     LET l$(4)="Good":\
     LET l$(5)="Expert":\
     LET l$(6)="Super Expert":\
     LET l$(7)="Genius"\{i0p7}
9199 RESTORE 9230
9200 FOR i=1 TO 64
9210 READ t$(i)
9220 NEXT i
9230 DATA "\{i2}Arsenal","\{i3}Aston V.","\{i1}Brighton","\{i1}Coventry","\{i1}Everton","\{i1}Ipswich","\{i2}Liverpool","\{i0}Luton","\{i1}Man.City","\{i2}Man.Utd","\{i4}Norwich","\{i2}Notts.F.","\{i0}Swansea","\{i1}Spurs","\{i0}Watford","\{i3}West Ham"\{i0}
9240 DATA "\{i1}Blackburn","\{i0}Bolton","\{i0}Cambridge","\{i2}Charlton","\{i1}Chelsea","\{i0}Crystal P.","\{i0i0}Derby Co.","\{i0}Fulham","\{i0}Grimsby","\{i1}Leeds","\{i2}Middlesbro","\{i0}Newcastle","\{i1}Oldham","\{i1}Q.P.R.","\{i2}Rotherham","\{i1}Sheff.Wed"
9250 DATA "\{i3}Bradford","\{i2}Brentford","\{i1}Bristol R.","\{i1}Cardiff","\{i0}Doncaster","\{i2}Exeter","\{i2}Lincoln","\{i1}Millwall","\{i0}Newport","\{i2}Orient","\{i0}Oxford","\{i4}Plymouth","\{i0}Preston","\{i1}Reading","\{i1}Southend","\{i2}Walsall"
9260 DATA "\{i0}Blackpool","\{i0}Bury","\{i1}Colchester","\{i2}Crewe","\{i0}Darlington","\{i1}Halifax","\{i1}Hartlepool","\{i0}Hereford","\{i0}Hull","\{i0}Mansfield","\{i0}Port Vale","\{i1}Rochdale","\{i2}Scunthorpe","\{i1}Stockport","\{i0}Torquay","\{i2}York City"
9270 LET q$(1)="\{i6vi} \{i0vn}"
9271 LET q$(2)="\{i3vi}p\{i0vn}"
9272 LET q$(3)="\{i4vi}i\{i0vn}"
9273 LET r$(1)="D\::"
9274 LET r$(2)="M\::"
9275 LET r$(3)="A\::"
9299 RETURN
9400 CLS
9405 INPUT "\{i1}Do you want to change any team  names (y/n)?", LINE i$
9410 \{i0} IF i$<>"y" AND i$<>"Y" AND i$<>"yes" AND i$<>"YES" THEN GO TO 9499
9415 LET d3=0
9420 LET d3=d3+1
9425 IF d3>4 THEN GO TO 9415
9430 CLS :\
     PRINT a$(6);d3
9435 PRINT "\{i1}NUMBER","NAME"\{i0}:\
     LET low=(d3-1)*16
9440 FOR i=low+1 TO low+16:\
     PRINT i,t$(i):\
     NEXT i
9445 PRINT "\{p6b1}Type no. of team to be changed  OR 99 for more choice           "\{b0p7}
9450 GO SUB 1170:\
     IF q=99 THEN GO TO 9420
9455 IF q<low+1 OR q>low+16 THEN PRINT "\{vi}TEAM NUMBER OUT OF RANGE"\{vn}:\
     GO TO 9450
9460 LET i=q:\
     PRINT "Present team is ";t$(i)
9465 INPUT "\{i1}Type new team name",\{i0} LINE i$
9466 IF i$="h" OR i$="H" THEN COPY :\
     GO TO 9465
9467 IF LEN i$=0 THEN GO TO 9465
9471 IF CODE i$(1)<>16 THEN GO TO 9476
9472 IF CODE i$(2)<0 OR CODE i$(2)>4 THEN PRINT "\{vi}INVALID COLOUR"\{vn}:\
     GO TO 9465
9473 IF CODE i$(3)<65 OR CODE i$(3)>122 THEN PRINT "\{vi}INVALID TEAM NAME"\{vn}:\
     GO TO 9465
9474 IF LEN i$>12 THEN PRINT "\{vi}TEAM NA\{i0}ME TOO LONG- max 10 chars\{vn}":\
     GO TO 9465
9475 GO TO 9478
9476 IF CODE i$(1)<65 OR CODE i$(1)>122 THEN PRINT "\{vi}INVALID TEAM NAME"\{vn}:\
     GO TO 9465
9477 IF LEN i$>10 THEN PRINT "\{vi}TEAM NA\{i0}ME TOO LONG- max 10 chars\{vn}":\
     GO TO 9465
9478 LET t$(i)=i$:\
     PRINT "New team name ";t$(i)
9479 INPUT "\{i1}Any more changes (y/n)?"\{i0}, LINE i$:\
     IF i$="h" OR i$="H" THEN COPY :\
     GO TO 9479
9480 \{i0} IF i$="y" OR i$="Y" OR i$="yes" OR i$="YES" THEN GO TO 9430
9499 RETURN
9500 CLS
9505 INPUT "\{i1}Do you want to change any playernames (y/n)?"\{i0}, LINE i$
9510 \{i0} IF i$<>"y" AND i$<>"Y" AND i$<>"yes" AND i$<>"YES" THEN GO TO 9599
9515 LET d3=0
9516 LET d3=d3+1
9520 IF d3>3 THEN GO TO 9515
9525 CLS :\
     PRINT a$(d3+2)
9530 PRINT "\{i1}NUMBER","NAME":\
     LET low=(d3-1)*8\{i0}
9535 FOR i=low+1 TO low+8:\
     PRINT i,p$(i):\
     NEXT i
9540 PRINT PAPER 6; BRIGHT 1;"Type no. of player to be changedOR 99 for more choice"
9545 GO SUB 1170:\
     IF q=99 THEN GO TO 9516
9550 IF q<low+1 OR q>low+8 THEN PRINT "\{vi}PLAYER NO. OUT OF RANGE\{vn}":\
     GO TO 9545
9555 LET i=q:\
     PRINT "Present player is ";p$(i)
9560 INPUT "\{i1}Type new player name",\{i0} LINE i$:\
     IF i$="h" OR i$="H" THEN COPY :\
     GO TO 9560
9561 IF LEN i$=0 THEN GO TO 9560
9565 IF CODE i$(1)<65 OR CODE i$(1)>122 THEN PRINT "\{vi}INVALID PLAYER NAME"\{vn}:\
     GO TO 9560
9570 IF LEN i$>8 THEN PRINT "\{vi}PLAYER NAME TOO LONG-max 8 chars"\{vn}:\
     GO TO 9560
9575 LET p$(i)=i$:\
     PRINT "New player name ";p$(i)
9580 INPUT "\{i1}Any more changes (y/n)?";\{i0} LINE i$:\
     IF i$="h" OR i$="H" THEN COPY :\
     GO TO 9580
9585 \{i0} IF i$="y" OR i$="Y" OR i$="yes" OR i$="YES" THEN GO TO 9525
9599 RETURN
