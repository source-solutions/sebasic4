Auto 0

# Run-time Variables

Var x: Num = 13
Var y: Num = 8
Var level: Num = 1
Var ox: Num = 13
Var oy: Num = 8
Var score: Num = 370
Var lives: Num = 1
Var fc: Num = 9
Var ft: Num = 4
Var nodots: Num = 2
Var gx1: Num = 23
Var gy1: Num = 16
Var gdx1: Num = -1
Var gdy1: Num = 0
Var gs1: Num = 1
Var gz1: Num = 1
Var gx2: Num = 16
Var gy2: Num = 10
Var gdx2: Num = 0
Var gdy2: Num = 1
Var gs2: Num = 1
Var gz2: Num = 0
Var gx3: Num = 16
Var gy3: Num = 10
Var gdx3: Num = -1
Var gdy3: Num = 0
Var gz3: Num = 0
Var gs3: Num = 1
Var gc: Num = 0
Var gox1: Num = 24
Var goy1: Num = 16
Var dx: Num = 13
Var dy: Num = 8
Var h: NumArray(5) = 230, 25, 16, 12, 10
Var f: NumFOR = 11, 10, 1, 1710, 3
Var w: NumFOR = 21, 20, 1, 1910, 4
Var z: NumFOR = 2, 25, 1, 1910, 5
Var n: NumFOR = 4, 3, 1, 5130, 5
Var n$: Str = "DUN"
Var g$: Str = "abcdefghij"
Var r$: Str = " "
Var s$: Str = " "
Var z$: Str = "34"
Var p$: Str = "#"
Var q$: Str = " "
Var a$: Str = ""
Var h$: StrArray(5, 3) = "DUNMKOWDYDAMMEL"
Var b$: StrArray(22, 19) = "\e\k\k\k\k\k\k\k\k\i\k\k\k\k\k\k\k\k\f\l-  -   -\l-   -  -\l\l \a\b \a\s\b \l \a\s\b \a\b \l\l \c\d \c\t\d \o \c\t\d \c\d \l\l-  - - - - - -  -\l\l \r\q \p \r\k\i\k\q \p \r\q \l\l-  -\l- -\l- -\l-  -\l\g\k\k\f \m\k\q \o \r\k\n \e\k\k\h   \l \l-  -  -\l \l   \e\k\k\h \o \r\q \r\q \o \g\k\k\f\l   - -     - -   \l\g\k\k\f \p \r\q \r\q \p \e\k\k\h   \l \l-  -  -\l \l   \e\k\k\h \o \r\k\i\k\q \o \g\k\k\f\l-  -   -\l-      -\l\l \r\f \r\k\q \o \r\k\q \e\q \l\l--\l-   - -   -\l--\l\m\q \o \p \r\k\i\k\q \p \o \r\n\l-- -\l- -\l- -\l- --\l\l \r\k\k\j\k\q \o \r\k\j\k\k\q \l\l-      - -      -\l\g\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\h"
Var c$: StrArray(22, 19) = "                                                                                                                                                                                                                                                                                                                                                                                                     .                            "

# End Run-time Variables

  10 CLEAR 64599: LOAD "1.bsc"CODE : POKE 23606,88: POKE 23607,251: DIM h$(5,3): DIM h(5): LET h$(1)="DUN": LET h$(2)="MKO": LET h$(3)="WDY": LET h$(4)="DAM": LET h$(5)="MEL": FOR f=1 TO 5: LET h(f)=INT (50/F): NEXT f
 110 BORDER 0: PAPER 0: INK 7: CLS : GO TO 6000
 210 INK 7: LET level=1: LET x=16: LET y=20: LET ox=0: LET oy=0: LET p$="&": LET score=0: LET lives=3: LET fc=0: LET ft=1
 409 REM fast
 410 PRINT AT 3,0; INK 6;"LEVEL";AT 4,0; INK 2;level: GO SUB 2310: GO SUB 1910: GO SUB 4720: REM slow
 420 PRINT AT y,x; INK 6;p$: LET ox=x: LET oy=y
 421 IF x=gx1 THEN IF y=gy1 THEN GO TO 1600
 422 IF level>1 THEN IF x=gx2 THEN IF y=gy2 THEN GO TO 1600
 423 IF level>2 THEN IF x=gx3 THEN IF y=gy3 THEN GO TO 1600
 424 LET fc=fc+1: IF fc=100 THEN LET c$(13,10)="klmno"(ft): PRINT AT 12,16;"klmno"(ft): LET ft=ft+1: IF ft=6 THEN LET ft=1
 425 IF fc=150 THEN LET c$(13,10)=" ": LET fc=0: PRINT AT 12,16;" "
 428 LET gox1=gx1: LET goy1=gy1: IF b$(gy1+1,gx1-6)="-" THEN GO TO 450
 429 IF SCREEN$ (gy1+gdy1,gx1+gdx1)="" THEN GO TO 450
 430 LET gy1=gy1+gdy1: LET gx1=gx1+gdx1
 431 GO TO 490
 450 IF gs1=1 THEN LET dx=x: LET dy=y: GO TO 460
 451 IF gs1=2 THEN LET dx=32-x: LET dy=22-y: GO TO 460
 455 LET dx=16: LET dy=10
 460 IF gdx1=0 THEN LET gdx1=SGN (dx-gx1): LET gdy1=0: IF gdx1<>0 THEN IF SCREEN$ (gy1+gdy1,gx1+gdx1)<>"" THEN GO TO 430
 470 LET gdy1=SGN (dy-gy1): LET gdx1=0: IF gdy1<>0 THEN IF SCREEN$ (gy1+gdy1,gx1+gdx1)<>"" THEN GO TO 430
 471 LET z$="": IF SCREEN$ (gy1-1,gx1)<>"" THEN LET z$="1"
 472 IF SCREEN$ (gy1,gx1+1)<>"" THEN LET z$=z$+"2"
 473 IF SCREEN$ (gy1,gx1-1)<>"" THEN LET z$=z$+"3"
 474 IF SCREEN$ (gy1+1,gx1)<>"" THEN LET z$=z$+"4"
 475 LET z=INT (RND *LEN (z$))+1: IF LEN (z$)>1 AND VAL z$(z)=gz1 THEN GO TO 475
 476 IF z$(z)="1" THEN LET gdx1=0: LET gdy1=-1: LET gz1=4: GO TO 430
 477 IF z$(z)="2" THEN LET gdx1=1: LET gdy1=0: LET gz1=3: GO TO 430
 478 IF z$(z)="3" THEN LET gdx1=-1: LET gdy1=0: LET gz1=2: GO TO 430
 479 IF z$(z)="4" THEN LET gdx1=0: LET gdy1=1: LET gz1=1
 480 GO TO 430
 490 PRINT AT goy1,gox1;q$: LET q$=c$(gy1+1,gx1-6): IF gs1=1 THEN PRINT AT gy1,gx1; INK 5;"\u": GO TO 520
 491 PRINT AT gy1,gx1; INK 1;"\u"
 520 IF level<2 THEN GO TO 700
 521 LET gox2=gx2: LET goy2=gy2: IF b$(gy2+1,gx2-6)="-" THEN GO TO 550
 522 IF SCREEN$ (gy2+gdy2,gx2+gdx2)="" THEN GO TO 550
 530 LET gy2=gy2+gdy2: LET gx2=gx2+gdx2
 531 GO TO 590
 550 IF gs2=1 THEN LET dx=x: LET dy=y: GO TO 560
 551 IF gs2=2 THEN LET dx=32-x: LET dy=22-y: GO TO 560
 555 LET dx=16: LET dy=10
 560 IF gdx2=0 THEN LET gdx2=SGN (dx-gx2): LET gdy2=0: IF gdx2<>0 THEN IF SCREEN$ (gy2+gdy2,gx2+gdx2)<>"" THEN GO TO 530
 570 LET gdy2=SGN (dy-gy2): LET gdx2=0: IF gdy2<>0 THEN IF SCREEN$ (gy2+gdy2,gx2+gdx2)<>"" THEN GO TO 530
 571 LET z$="": IF SCREEN$ (gy2-1,gx2)<>"" THEN LET z$="1"
 572 IF SCREEN$ (gy2,gx2+1)<>"" THEN LET z$=z$+"2"
 573 IF SCREEN$ (gy2,gx2-1)<>"" THEN LET z$=z$+"3"
 574 IF SCREEN$ (gy2+1,gx2)<>"" THEN LET z$=z$+"4"
 575 LET z=INT (RND *LEN (z$))+1: IF LEN (z$)>1 AND VAL z$(z)=gz2 THEN GO TO 575
 576 IF z$(z)="1" THEN LET gdx2=0: LET gdy2=-1: LET gz2=4: GO TO 530
 577 IF z$(z)="2" THEN LET gdx2=1: LET gdy2=0: LET gz2=3: GO TO 530
 578 IF z$(z)="3" THEN LET gdx2=-1: LET gdy2=0: LET gz2=2: GO TO 530
 579 IF z$(z)="4" THEN LET gdx2=0: LET gdy2=1: LET gz2=1
 580 GO TO 530
 590 PRINT AT goy2,gox2;r$: LET r$=c$(gy2+1,gx2-6): IF gs2=1 THEN PRINT AT gy2,gx2; INK 4;"\u": GO TO 620
 591 PRINT AT gy2,gx2; INK 1;"\u"
 620 IF level<3 THEN GO TO 700
 621 LET gox3=gx3: LET goy3=gy3: IF b$(gy3+1,gx3-6)="-" THEN GO TO 650
 622 IF SCREEN$ (gy3+gdy3,gx3+gdx3)="" THEN GO TO 650
 630 LET gy3=gy3+gdy3: LET gx3=gx3+gdx3
 640 GO TO 690
 650 IF gs3=1 THEN LET dx=x: LET dy=y: GO TO 660
 651 IF gs3=2 THEN LET dx=32-x: LET dy=22-y: GO TO 660
 655 LET dx=16: LET dy=10
 660 IF gdx3=0 THEN LET gdx3=SGN (dx-gx3): LET gdy3=0: IF gdx3<>0 THEN IF SCREEN$ (gy3+gdy3,gx3+gdx3)<>"" THEN GO TO 630
 670 LET gdy3=SGN (dy-gy3): LET gdx3=0: IF gdy3<>0 THEN IF SCREEN$ (gy3+gdy3,gx3+gdx3)<>"" THEN GO TO 630
 671 LET z$="": IF SCREEN$ (gy3-1,gx3)<>"" THEN LET z$="1"
 672 IF SCREEN$ (gy3,gx3+1)<>"" THEN LET z$=z$+"2"
 673 IF SCREEN$ (gy3,gx3-1)<>"" THEN LET z$=z$+"3"
 674 IF SCREEN$ (gy3+1,gx3)<>"" THEN LET z$=z$+"4"
 675 LET z=INT (RND *LEN (z$))+1: IF LEN (z$)>1 AND VAL z$(z)=gz3 THEN GO TO 675
 676 IF z$(z)="1" THEN LET gdx3=0: LET gdy3=-1: LET gz3=4: GO TO 630
 677 IF z$(z)="2" THEN LET gdx3=1: LET gdy3=0: LET gz3=3: GO TO 630
 678 IF z$(z)="3" THEN LET gdx3=-1: LET gdy3=0: LET gz3=2: GO TO 630
 679 IF z$(z)="4" THEN LET gdx3=0: LET gdy3=1: LET gz3=1
 680 GO TO 630
 690 PRINT AT goy3,gox3;s$: LET s$=c$(gy3+1,gx3-6): IF gs3=1 THEN PRINT AT gy3,gx3; INK 3;"\u": GO TO 700
 691 PRINT AT gy3,gx3; INK 1;"\u"
 701 IF x=gx1 THEN IF y=gy1 THEN GO TO 1600
 702 IF level>1 THEN IF x=gx2 THEN IF y=gy2 THEN GO TO 1600
 703 IF level>2 THEN IF x=gx3 THEN IF y=gy3 THEN GO TO 1600
 711 LET a$=INKEY$
 810 IF a$="q" THEN IF SCREEN$ (y-1,x)<>"" THEN LET y=y-1: LET p$="#": GO TO 1310
 910 IF a$="a" THEN IF SCREEN$ (y+1,x)<>"" THEN LET y=y+1: LET p$="$": GO TO 1310
1010 IF a$="o" THEN IF SCREEN$ (y,x-1)<>"" THEN LET x=x-1: LET p$="&": GO TO 1310
1110 IF a$="p" THEN IF SCREEN$ (y,x+1)<>"" THEN LET x=x+1: LET p$="!": GO TO 1310
1210 GO TO 420
1310 IF c$(y+1,x-6)="." THEN LET score=score+1: PRINT AT 1,0; INK 2;score: LET c$(y+1,x-6)=" ": LET nodots=nodots-1
1320 IF c$(y+1,x-6)="*" THEN LET score=score+10: LET gc=20: LET gs1=2: LET gs2=2: LET gs3=2: LET c$(y+1,x-6)=" ": PRINT AT 1,0; INK 2;score: LET nodots=nodots-1
1321 IF nodots<=2 THEN GO TO 7000
1322 IF c$(y+1,x-6)>="a" THEN LET score=score+50: LET fc=0: LET c$(y+1,x-6)=" ": PRINT AT 1,0; INK 2;score
1330 IF gc>0 THEN LET gc=gc-1: IF gc=0 THEN LET gs1=1: LET gs2=1: LET gs3=1
1335 IF y=10 THEN IF x=8 OR x=24 THEN LET x=32-x
1410 PRINT AT oy,ox;" "
1510 GO TO 420
1600 IF gc=0 THEN GO TO 1700
1610 IF x=gx1 AND y=gy1 THEN LET gx1=16: LET gy1=10: LET gs1=1: LET score=score+100
1620 IF level>1 THEN IF x=gx2 AND y=gy2 THEN LET gx2=16: LET gy2=10: LET gs2=1: LET score=score+100
1630 IF level>2 THEN IF x=gx3 AND y=gy3 THEN LET gx3=16: LET gy3=10: LET gs3=1: LET score=score+100
1640 PRINT AT 1,0; INK 2;score: GO TO 1410
1700 REM die
1710 LET g$="abcdefghij": FOR f=1 TO 10: PRINT AT y,x; INK 6;g$(f): BEEP .05,20+(10-f): NEXT f: PRINT AT y,x; INK 7;"j": BEEP 1,-20
1720 LET lives=lives-1: PRINT AT 1,28+lives;" ": IF lives=0 THEN GO TO 5000
1730 LET x=16: LET y=20: LET ox=0: LET oy=0: LET p$="&": PRINT AT gy1,gx1; INK 7;q$;AT gy2,gx2;r$;AT gy3,gx3;s$: GO SUB 4720: GO TO 420
1910 PRINT INK 0;AT 10,15;"...": LET nodots=0: FOR w=1 TO 20: FOR z=8 TO 25: IF (w<8 OR w>13) OR (z>10 AND z<22) THEN IF SCREEN$ (w,z)=" " THEN PRINT AT w,z; INK 7;".": LET c$(w+1,z-6)=".": LET nodots=nodots+1
2010 NEXT z: NEXT w: PRINT INK 6;AT 1,8;"*";AT 1,24;"*";AT 20,8;"*";AT 20,24;"*": LET c$(2,2)="*": LET c$(2,18)="*": LET c$(21,2)="*": LET c$(21,18)="*"
2011 LET nodots=nodots-1: PRINT AT 12,16;" ": LET c$(12,10)=" ": RETURN
2110 SAVE "1.bsc"CODE 64600,(21+96)*8
2210 STOP
2310 DIM b$(22,19): DIM c$(22,19)
2410 LET b$(01)="\e\k\k\k\k\k\k\k\k\i\k\k\k\k\k\k\k\k\f"
2510 LET b$(02)="\l-  -   -\l-   -  -\l"
2610 LET b$(03)="\l \a\b \a\s\b \l \a\s\b \a\b \l"
2710 LET b$(04)="\l \c\d \c\t\d \o \c\t\d \c\d \l"
2810 LET b$(05)="\l-  - - - - - -  -\l"
2910 LET b$(06)="\l \r\q \p \r\k\i\k\q \p \r\q \l"
3010 LET b$(07)="\l-  -\l- -\l- -\l-  -\l"
3110 LET b$(08)="\g\k\k\f \m\k\q \o \r\k\n \e\k\k\h"
3210 LET b$(09)="   \l \l-  -  -\l \l   "
3310 LET b$(10)="\e\k\k\h \o \r\q \r\q \o \g\k\k\f"
3410 LET b$(11)="\l   - -     - -   \l"
3510 LET b$(12)="\g\k\k\f \p \r\q \r\q \p \e\k\k\h"
3610 LET b$(13)="   \l \l-  -  -\l \l   "
3710 LET b$(14)="\e\k\k\h \o \r\k\i\k\q \o \g\k\k\f"
3810 LET b$(15)="\l-  -   -\l-      -\l"
3910 LET b$(16)="\l \r\f \r\k\q \o \r\k\q \e\q \l"
4010 LET b$(17)="\l--\l-   - -   -\l--\l"
4110 LET b$(18)="\m\q \o \p \r\k\i\k\q \p \o \r\n"
4210 LET b$(19)="\l-- -\l- -\l- -\l- --\l"
4310 LET b$(20)="\l \r\k\k\j\k\q \o \r\k\j\k\k\q \l"
4410 LET b$(21)="\l-      - -      -\l"
4510 LET b$(22)="\g\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\k\h"
4610 PRINT AT 0,0; INK 6; BRIGHT 1;"SCORE";AT 0,28;"MEN";AT 1,0; BRIGHT 0; INK 2;"0";AT 1,28;"&&&"
4710 FOR f=1 TO 22: PRINT INK 1; BRIGHT 0;AT f-1,7;b$(f): NEXT f: BRIGHT 1: RETURN
4720 LET gx1=16: LET gy1=10: LET gdx1=0: LET gdy1=-1: LET gs1=1: LET gz1=0: LET q$=" "
4721 LET gx2=16: LET gy2=10: LET gdx2=0: LET gdy2=+1: LET gs2=1: LET gz2=0: LET r$=" "
4722 LET gx3=16: LET gy3=10: LET gdx3=-1: LET gdy3=0: LET gz3=0: LET gs3=1: LET s$=" "
4723 LET gc=0: LET fc=0
4730 RETURN
5000 FOR f=0 TO 21: PRINT AT f,0;"                                ": NEXT f: INK 7
5001 PRINT AT 5,4;"\e\k\k\f \e\k\k\f \e\k\i\k\f \e\k\k\q"
5010 PRINT AT 6,4;"\l  \o \l  \l \l \l \l \l   "
5020 PRINT AT 7,4;"\l \r\f \m\k\k\n \l \o \l \m\k\q "
5030 PRINT AT 8,4;"\l  \l \l  \l \l   \l \l   "
5040 PRINT AT 9,4;"\g\k\k\h \o  \o \o   \o \g\k\k\q"
5041 REM
5050 PRINT AT 11,4;"   \e\k\k\f \p   \p \e\k\k\q \e\k\k\f"
5060 PRINT AT 12,4;"   \l  \l \l   \l \l    \l  \o"
5070 PRINT AT 13,4;"   \l  \l \g\f \e\h \m\k\q  \l   "
5080 PRINT AT 14,4;"   \l  \l  \l \l  \l    \l   "
5090 PRINT AT 15,4;"   \g\k\k\h  \g\k\h  \g\k\k\q \o   "
5100 LET s$="YOUR SCORE: "+STR$ (Score)
5110 PRINT AT 18,16-(LEN s$/2); INK 5;s$
5120 IF h(5)>score THEN PRINT AT 20,2; INK 2;"YOU DID NOT GET A HIGH SCORE": PAUSE 1: PAUSE 0: GO TO 6000
5130 PRINT AT 20,5; INK 4;"YOU GOT A HIGH SCORE";AT 21,4; INK 5;"ENTER YOUR INITIALS "; INK 1;"___": PAUSE 1: LET n$="": FOR n=1 TO 3
5140 LET a$=INKEY$ : IF a$="" THEN GO TO 5140
5145 IF a$>="a" THEN LET a$=CHR$ (CODE (a$)-32)
5150 LET n$=n$+a$: PRINT AT 21,24; INK 6;n$
5160 IF INKEY$ <>"" THEN GO TO 5160
5170 NEXT n
5180 FOR f=1 TO 5: IF h(f)<=score THEN LET h(f)=score: LET h$(f)=n$: GO TO 6000
5190 NEXT f
5900 PAUSE 1: PAUSE 0: PAUSE 0
6000 CLS : INK 6
6010 PRINT AT 0,0;" \e\k\k\f \e\k\f \e\k\f \e\k\f \e\k\i\k\f \e\k\f \e\k\f "
6020 PRINT AT 1,0;" \l  \o \l \l \l \l \l \o \l \l \l \l \l \l \l "
6030 PRINT AT 2,0;" \g\k\k\f \m\k\h \m\k\n \l   \l \o \l \m\k\n \l \l "
6040 PRINT AT 3,0;" \p  \l \l   \l \l \l \p \l   \l \l \l \l \l "
6050 PRINT AT 4,0;" \g\k\k\h \o   \o \o \g\k\h \o   \o \o \o \o \o "
6060 PRINT AT 6,0; INK 2;" \* 2004 DEFINITELY NOT BY DUNNY "
6061 PRINT AT 10,10; INK 3;"HIGH SCORES"
6062 FOR f=1 TO 5: PRINT AT f+11,10; INK 4;h$(f);"  "; INK 5;h(f): NEXT f
6070 PRINT AT 21,5; INK 5;"PRESS ANY KEY TO START"
6080 PAUSE 1: PAUSE 0: CLS : GO TO 210
7000 REM done the maze!
7010 FOR g=1 TO 3: FOR f=1 TO 22: PRINT AT f-1,7; INK 7;b$(f): NEXT f: FOR f=1 TO 22: PRINT AT f-1,7; INK 1;b$(f): NEXT f: NEXT g: INK 7: LET x=16: LET y=20: LET ox=0: LET oy=0: LET p$="&": LET level=level+1: GO TO 409
