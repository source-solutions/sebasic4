     Auto 5

   1 REM \* COMPUTER RENTALS Ltd. 1982
   2 SAVE "d" LINE 5
   5 GO TO 70
   7 REM \{vi}BACKGROUND ROUTINE - RACE\{vn}
   8 RESTORE 302:\
     FOR f=0 TO 7:\
     READ ff:\
     POKE USR "G"+f,ff:\
     NEXT f:\
     GO TO 15
   9 GO TO 15
  10 IF j=8 THEN GO TO 8
  15 PRINT AT 5,0; INK 1; BRIGHT 0;J$(j TO j+31)
  20 PRINT AT 6,0; INK 7; BRIGHT 0;H$(k TO k+31)
  25 IF m>121 THEN GO TO 60
  30 PRINT AT 4,0; PAPER 4; INK 1; BRIGHT 0;O$(m TO m+31)
  35 PRINT AT 3,0; PAPER 5; INK 0; BRIGHT 0;M$(m TO m+31)
  40 PRINT AT 2,0; PAPER 5; INK 1; BRIGHT 0;N$(m TO m+31)
  45 PRINT AT 18,0; INK 1; BRIGHT 0;J$(j+9 TO j+40)
  50 PRINT AT 17,0; INK 7; BRIGHT 0;H$(k TO k+31)
  51 LET j=j+1:\
     LET k=k+1:\
     LET m=m+1
  55 RETURN
  60 PRINT AT 5,31; INK 2; BRIGHT 1;"\q"
  62 PRINT AT 3,3; PAPER 5; INK 0; BRIGHT 0;"\p\o\o\o\p\o\o\p\p\o\p\p\o\p\o\p\p\o\o\o\p\o\p\p\p\p\p"
  65 PAUSE 1
  66 PRINT AT 3,3; PAPER 5; INK 0; BRIGHT 0;"\o\p\o\o\p\p\o\p\p\o\o\p\p\p\o\p\p\p\o\o\p\o\p\o\p\o\o"
  67 RETURN
  69 REM \{vi}SET-UPINITIALARRAYS\{vn}
  70 LET H$="\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r\u\u\u\r"
  75 LET J$="                                         \o \p     \p          \p\o\p\g        \p\p\o\p\p\p           \o\p\g       \p\p  \p\o\p\p\o   \p\o\p\o\p   \p\p\p\g     \p\p\p\o\p\o\p\o\p\p\o\o\p\o     \o\o\p\p\p\o\p\p\o\p\o\p    \o\p\p\o\o\p\p "
  80 LET O$="                                                                                           \ :\s\s\s\s\s\s\s\s\s\s\:  \ :\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\::\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\::\s\s\s\s\s\:  \ :\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s"
  85 LET N$="                                                                                                                          \::\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\::                                                   "
  90 LET M$="                                                                                                                          \::\o\p\o\o\p\p\o\p\p\o\o\p\p\p\o\p\p\p\o\o\p\o\p\o\p\o\o\::                                                   "
  95 GO TO 8000
  99 REM \{vi}RACEROUTINE\{vn}
 100 PAPER 4:\
     INK 0:\
     BORDER 1:\
     FLASH 0:\
     BRIGHT 0:\
     CLS
 105 LET sound=-50
 110 FOR f=0 TO 3:\
     PRINT AT f,0; PAPER 5;"                                ":\
     NEXT f
 114 PRINT AT 4,0; BRIGHT 0; PAPER 4;"                                "
 115 PRINT AT 5,0; BRIGHT 0; PAPER 4;"                                "
 120 FOR f=7 TO 16:\
     PRINT AT f,0; BRIGHT 1;"                                ":\
     NEXT f
 130 FOR f=18 TO 21:\
     PRINT AT f,0; BRIGHT 0;"                                ":\
     NEXT f
 140 FOR f=6 TO 17 STEP 11
 150 PRINT AT f,0; INK 7;H$(1 TO 32)
 160 NEXT f
 170 BRIGHT 1
 180 PLOT 32,119:\
     DRAW INK 7;0,-79
 190 PRINT AT 7,0; INK 7;"1";AT 7,2; INK 7;"\a";AT 7,3; INK 0;"\b"
 200 PRINT AT 8,1;"\{vivn} \c\d"
 210 PRINT AT 9,0; INK 7;"2";AT 9,2; INK 5;"\a";AT 9,3; INK 0;"\b"
 220 PRINT AT 10,1;"\{vivn} \c\d"
 230 PRINT AT 11,0; INK 7;"3";AT 11,2; INK 0;"\a";AT 11,3; INK 0;"\b"
 240 PRINT AT 12,1;"\{vivn} \c\d"
 250 PRINT AT 13,0; INK 7;"4";AT 13,2; INK 6;"\a";AT 13,3; INK 0;"\b"
 260 PRINT AT 14,1;"\{vivn} \c\d"
 270 PRINT AT 15,0; INK 7;"5";AT 15,2; INK 2;"\a";AT 15,3; INK 0;"\b"
 280 PRINT AT 16,1;"\{vivn} \c\d"
 285 LET a=2:\
     LET b=2:\
     LET c=2:\
     LET d=2:\
     LET e=2
 290 LET j=2:\
     LET k=2:\
     LET m=39
 300 DATA 0,4,15,12,4,10,10,10
 301 DATA .05,15,.05,15,.3,15,.05,12,.05,12,.3,12,.05,8,.05,8,.3,8,.1,5,.1,5,.1,5,.2,3,.1,8,.1,8,.1,8,.1,12,.1,12,.1,12,.1,15,.1,15,.1,15,1,8
 302 DATA 0,0,0,0,33,126,60,36
 310 RESTORE 300:\
     FOR f=0 TO 7:\
     READ ff:\
     POKE USR "G"+f,ff:\
     NEXT f
 315 BRIGHT 0
 320 PRINT INK 1; PAPER 4;AT 5,4;"\g"
 322 PLOT INK 4;41,135:\
     DRAW INK 7;2,0
 325 LET j$(6)="\g"
 340 RESTORE 301:\
     FOR f=1 TO 23:\
     READ l1,l2:\
     BEEP l1,l2:\
     NEXT f
 350 FOR f=1 TO 100:\
     NEXT f
 360 FOR f=1 TO 5:\
     PLOT INK 7;41,136-f:\
     DRAW INK 7;2,0:\
     PRINT AT 5,5;" ":\
     NEXT f
 370 BRIGHT 1
 375 BEEP .02,1:\
     BEEP .005,1
 380 PLOT 32,119:\
     DRAW INK 4;0,-79
 390 GO TO 1000
 400 DIM Q$(40,10)
 410 LET Q$(1)="SNAIL     "
 420 LET Q$(2)="TORTOISE  "
 430 LET Q$(3)="SPEEDY    "
 440 LET Q$(4)="LAME DUCK "
 450 LET Q$(5)="DR. WHO   "
 460 LET Q$(6)="NO CHANCE "
 470 LET Q$(7)="RED WINE  "
 480 LET Q$(8)="BEER BARON"
 490 LET Q$(9)="OVERCOAT  "
 500 LET Q$(10)="PINK TIGER"
 510 LET Q$(11)="YOGI BEAR "
 520 LET Q$(12)="RAINBOW II"
 530 LET Q$(13)="SUNNY BOY "
 540 LET Q$(14)="JASMINE   "
 550 LET Q$(15)="JERRY CAN "
 560 LET Q$(16)="TOBAMORRA "
 570 LET Q$(17)="HOBBYHORSE"
 580 LET Q$(18)="KING KONG "
 590 LET Q$(19)="QUEEN BEE "
 600 LET Q$(20)="ROYAL ANDY"
 610 LET Q$(21)="RED RUM   "
 620 LET Q$(22)="EASY GO   "
 630 LET Q$(23)="DAWN DIVER"
 640 LET Q$(24)="CANOODLE  "
 650 LET Q$(25)="LADYFISH  "
 660 LET Q$(26)="MISS SHAPE"
 670 LET Q$(27)="POPSIS JOY"
 680 LET Q$(28)="ORANGE TIP"
 690 LET Q$(29)="TEA-POT   "
 700 LET Q$(30)="WINDY LAD "
 710 LET Q$(31)="WARGAME   "
 720 LET Q$(32)="SIR GERARD"
 730 LET Q$(33)="FAIR MADAM"
 740 LET Q$(34)="STAR WARS "
 750 LET Q$(35)="LUXURY   "
 760 LET Q$(36)="GREENHORN "
 770 LET Q$(37)="GIGGLE    "
 780 LET Q$(38)="SECRET SIN"
 790 LET Q$(39)="SEA PAGO  "
 795 LET Q$(40)="HARRY O   "
 798 RETURN
 799 REM \{vi}MELODY\{vn}
 800 REM \{vi}VERSE800\{vn}
 810 BEEP .2,10:\
     BEEP .2,10:\
     BEEP .2,10:\
     BEEP .2,7:\
     BEEP .2,10:\
     BEEP .2,12:\
     BEEP .2,10:\
     BEEP .4,7
 811 BEEP .2,7:\
     BEEP .4,5:\
     BEEP .2,7:\
     BEEP .4,5
 812 BEEP .2,10:\
     BEEP .2,10:\
     BEEP .2,10:\
     BEEP .2,7:\
     BEEP .2,10:\
     BEEP .2,12:\
     BEEP .2,10:\
     BEEP .4,7
 813 BEEP .2,7:\
     BEEP .2,5:\
     BEEP .2,7:\
     BEEP .2,5:\
     BEEP .4,3
 814 BEEP .2,10:\
     BEEP .2,10:\
     BEEP .2,10:\
     BEEP .2,7:\
     BEEP .1,10:\
     BEEP .1,10:\
     BEEP .2,12:\
     BEEP .2,10:\
     BEEP .4,7
 815 BEEP .2,7:\
     BEEP .4,5:\
     BEEP .2,7:\
     BEEP .4,5
 816 BEEP .2,10:\
     BEEP .2,10:\
     BEEP .2,10:\
     BEEP .2,7:\
     BEEP .1,10:\
     BEEP .1,10:\
     BEEP .1,12:\
     BEEP .1,12:\
     BEEP .1,10:\
     BEEP .1,10:\
     BEEP .4,7
 817 BEEP .2,7:\
     BEEP .2,5:\
     BEEP .2,7:\
     BEEP .2,5:\
     BEEP .8,3
 819 RETURN
 820 REM \{vi}ALTERNATIVE1\{vn}
 821 BEEP .2,7:\
     BEEP .1,11:\
     BEEP .2,9:\
     BEEP .1,12:\
     BEEP .1,11:\
     BEEP .1,14:\
     BEEP .1,11:\
     BEEP .2,7
 822 BEEP .2,7:\
     BEEP .1,11:\
     BEEP .2,9:\
     BEEP .1,12:\
     BEEP .3,11:\
     BEEP .3,7:\
     BEEP .2,7:\
     BEEP .1,11:\
     BEEP .2,9:\
     BEEP .1,12:\
     BEEP .1,11:\
     BEEP .1,14:\
     BEEP .1,11:\
     BEEP .2,7
 823 BEEP .3,16\{i0}:\
     BEEP .2,9:\
     BEEP .1,12:\
     BEEP .25,11:\
     BEEP .25,7
 829 RETURN
 830 REM \{vi}ALTERNATIVE2\{vivn}
 831 BEEP .6,9:\
     BEEP .2,9:\
     BEEP .2,10:\
     BEEP .2,9:\
     BEEP .2,7:\
     BEEP 1,5:\
     BEEP .6,14:\
     BEEP .2,14:\
     BEEP .2,10:\
     BEEP .2,12:\
     BEEP .2,14:\
     BEEP 1,12
 832 BEEP .2,12:\
     BEEP .2,14:\
     BEEP .2,14:\
     BEEP .2,14:\
     BEEP .2,10:\
     BEEP .2,12:\
     BEEP .2,14:\
     BEEP .2,12:\
     BEEP .2,14:\
     BEEP .2,12:\
     BEEP .4,9
 833 BEEP .2,12:\
     BEEP .2,14:\
     BEEP .2,14:\
     BEEP .2,14:\
     BEEP .2,10:\
     BEEP .2,12:\
     BEEP .2,14:\
     BEEP .2,12:\
     BEEP .2,14:\
     BEEP .2,12:\
     BEEP .4,9
 834 BEEP .2,10:\
     BEEP .4,12:\
     BEEP .2,12:\
     BEEP .2,10:\
     BEEP .2,9:\
     BEEP .2,7:\
     BEEP .8,5
 839 RETURN
 840 \{vivivn} REM \{vi}A\{vnvi}LTERNATIVE3\{vnvn}
 841 BEEP .6,8:\
     BEEP .2,10:\
     BEEP .2,8:\
     BEEP .2,5:\
     BEEP .2,3:\
     BEEP .2,1:\
     BEEP .2,3:\
     BEEP .2,1:\
     BEEP .2,5:\
     BEEP .2,1:\
     BEEP .2,-2:\
     BEEP .8,-4
 842 BEEP .6,8:\
     BEEP .2,10:\
     BEEP .2,8:\
     BEEP .2,5:\
     BEEP .2,3:\
     BEEP .2,1:\
     BEEP .2,5:\
     BEEP .2,1:\
     BEEP .2,5:\
     BEEP .2,5:\
     BEEP .8,3
 843 BEEP .6,8:\
     BEEP .2,10:\
     BEEP .2,8:\
     BEEP .2,5:\
     BEEP .2,3:\
     BEEP .2,1:\
     BEEP .2,3:\
     BEEP .2,1:\
     BEEP .2,5:\
     BEEP .2,1:\
     BEEP .2,-2:\
     BEEP .4,-4
 844 BEEP .2,1:\
     BEEP .2,3:\
     BEEP .2,1:\
     BEEP .2,5:\
     BEEP .2,1:\
     BEEP .2,-2:\
     BEEP .2,-4:\
     BEEP .2,-2:\
     BEEP .2,1:\
     BEEP .2,5:\
     BEEP .2,1:\
     BEEP .2,5:\
     BEEP .2,5:\
     BEEP .2,1
 849 RETURN
 850 REM \{vi}ALTERNATIVE\{vi}4\{vnvn}
 851 BEEP .1,\{vivn}0:\
     BEEP .1,5:\
     BEEP .2,5:\
     BEEP .3,5:\
     BEEP .1,5:\
     BEEP .2,4:\
     BEEP .2,7:\
     BEEP .4,7
 852 BEEP .1,0:\
     BEEP .1,7:\
     BEEP .2,7:\
     BEEP .3,7:\
     BEEP .1,7:\
     BEEP .2,5:\
     BEEP .2,9:\
     BEEP .4,9
 853 BEEP .1,5:\
     BEEP .1,9:\
     BEEP .2,9:\
     BEEP .3,9:\
     BEEP .1,9:\
     BEEP .2,10:\
     BEEP .2,14:\
     BEEP .4,14
 854 BEEP .1,14:\
     BEEP .2,12:\
     BEEP .2,12:\
     BEEP .2,10:\
     BEEP .2,4:\
     BEEP .6,5
 859 RETURN
 900 REM \{vi}CHORUS900\{vn}
 910 BEEP .2,3:\
     BEEP .1,3:\
     BEEP .2,7:\
     BEEP .2,10:\
     BEEP .8,15
 911 BEEP .2,12:\
     BEEP .1,12:\
     BEEP .2,15:\
     BEEP .2,12:\
     BEEP .4,10
 912 BEEP .2,7:\
     BEEP .2,10:\
     BEEP .2,10:\
     BEEP .1,7:\
     BEEP .1,7:\
     BEEP .1,10:\
     BEEP .1,10:\
     BEEP .2,12:\
     BEEP .2,10:\
     BEEP .4,7
 913 BEEP .2,5:\
     BEEP .1,7:\
     BEEP .1,8:\
     BEEP .2,7:\
     BEEP .1,5:\
     BEEP .1,5:\
     BEEP .8,3
 915 RETURN
 920 REM \{vi}SMILE\{vn}
 921 FOR f=.9 TO .75 STEP -.05
 922 PLOT 50,94:\
     DRAW INK 2;20,0,f*PI :\
     NEXT f
 923 FOR f=.3 TO .45 STEP .05
 924 PLOT 50,94:\
     DRAW INK 2;20,0,f*PI :\
     NEXT f
 925 RETURN
 930 REM \{vi}FROWN\{vn}
 931 FOR f=-.8 TO -.65 STEP .05
 932 PLOT 50,86:\
     DRAW INK 2;20,0,f*PI :\
     NEXT f
 933 FOR f=-.3 TO -.45 STEP -.05
 934 PLOT 50,86:\
     DRAW INK 2;20,0,f*PI :\
     NEXT f
 935 RETURN
1000 REM \{vi}STARTOFRACE\{vn}
1010 PRINT AT 7,0;" ";AT 9,0;" ";AT 11,0;" ";AT 13,0;" ";AT 15,0;" "
1050 GO TO 1150
1100 LET g=INT (RND *5+1)
1110 IF g=1 THEN LET a=a+1
1120 IF g=2 THEN LET b=b+1
1130 IF g=3 THEN LET c=c+1
1140 IF g=4 THEN LET d=d+1
1145 IF g=5 THEN LET e=e+1
1150 PRINT AT 7,a;" ";AT 7,a+1; INK 7;"\e";AT 7,a+2; INK 0;"\f";AT 8,a;" \i\h"
1160 PRINT AT 9,b;" ";AT 9,b+1; INK 5;"\e";AT 9,b+2; INK 0;"\f";AT 10,b;" \i\h"
1170 PRINT AT 11,c;" ";AT 11,c+1; INK 0;"\e";AT 11,c+2; INK 0;"\f";AT 12,c;" \i\h"
1180 PRINT AT 13,d;" ";AT 13,d+1; INK 6;"\e";AT 13,d+2; INK 0;"\f";AT 14,d;" \i\h"
1190 PRINT AT 15,e;" ";AT 15,e+1; INK 2;"\e";AT 15,e+2; INK 0;"\f";AT 16,e;" \i\h"
1200 IF a=29 THEN GO TO 3100
1210 IF b=29 THEN GO TO 3200
1220 IF c=29 THEN GO TO 3300
1230 IF d=29 THEN GO TO 3400
1240 IF e=29 THEN GO TO 3500
1250 PRINT AT 8,a;" \i\j";AT 10,b;" \i\j";AT 12,c;" \i\j";AT 14,d;" \i\j";AT 16,e;" \i\j"
1255 GO SUB 10
1260 PRINT AT 8,a;" \m\l";AT 10,b;" \m\l";AT 12,c;" \m\l";AT 14,d;" \m\l";AT 16,e;" \m\l"
1270 BEEP .15,sound
1280 PRINT AT 8,a;" \k\l";AT 10,b;" \k\l";AT 12,c;" \k\l";AT 14,d;" \k\l";AT 16,e;" \k\l"
1290 BEEP .15,SOUND
1300 GO SUB 10
1400 LET g=INT (RND *5+1)
1410 IF g=1 THEN LET a=a+1
1420 IF g=2 THEN LET b=b+1
1430 IF g=3 THEN LET c=c+1
1440 IF g=4 THEN LET d=d+1
1450 IF g=5 THEN LET e=e+1
1500 PRINT AT 7,a;" ";AT 7,a+1; INK 7;"\a";AT 7,a+2; INK 0;"\b";AT 8,a;" \m\n"
1510 PRINT AT 9,b;" ";AT 9,b+1; INK 5;"\a";AT 9,b+2; INK 0;"\b";AT 10,b;" \m\n"
1520 PRINT AT 11,c;" ";AT 11,c+1; INK 0;"\a";AT 11,c+2; INK 0;"\b";AT 12,c;" \m\n"
1530 PRINT AT 13,d;" ";AT 13,d+1; INK 6;"\a";AT 13,d+2; INK 0;"\b";AT 14,d;" \m\n"
1540 PRINT AT 15,e;" ";AT 15,e+1; INK 2;"\a";AT 15,e+2; INK 0;"\b";AT 16,e;" \m\n"
1550 IF a=29 THEN GO TO 3100
1560 IF b=29 THEN GO TO 3200
1570 IF c=29 THEN GO TO 3300
1580 IF d=29 THEN GO TO 3400
1590 IF e=29 THEN GO TO 3500
1600 LET sound=sound+.25
2000 GO TO 1100
3000 REM \{vi}ENDRACE\{vi}-\{vnvi}PRINTWINNER\{vnvn}
3100 PRINT AT 20,4; PAPER 7; INK 0; FLASH 1;"No. 1 is the WINNER"
3110 PRINT AT 5,31; INK 2; BRIGHT 1;"\q"
3150 GO TO 3600
3200 PRINT AT 20,4; PAPER 5; INK 7; FLASH 1;"No. 2 is the WINNER"
3210 PRINT AT 5,31; INK 2; BRIGHT 1;"\q"
3250 GO TO 3600
3300 PRINT AT 20,4; PAPER 0; INK 7; FLASH 1;"No. 3 is the WINNER"
3310 PRINT AT 5,31; INK 2; BRIGHT 1;"\q"
3350 GO TO 3600
3400 PRINT AT 20,4; PAPER 6; INK 0; FLASH 1;"No. 4 is the WINNER"
3410 PRINT AT 5,31; INK 2; BRIGHT 1;"\q"
3450 GO TO 3600
3500 PRINT AT 20,4; PAPER 2; INK 7; FLASH 1;"No. 5 is the WINNER"
3510 PRINT AT 5,31; INK 2; BRIGHT 1;"\q"
3600 FOR f=-50 TO 50 STEP 5
3610 BEEP .03,f
3620 NEXT f
3800 REM \{vivivivi}ENDOFRACE\{vn}
4000 REM \{vi}DETERMINEPLACES\{vn}
4100 DIM w(5)
4110 LET w(1)=a*10+1
4120 LET w(2)=b*10+2
4130 LET w(3)=c*10+3
4140 LET w(4)=d*10+4
4150 LET w(5)=e*10+5
4200 FOR l=1 TO 5
4210 FOR f=1 TO 4
4220 IF w(f)>=w(f+1) THEN GO TO 4260
4230 LET v=w(f)
4240 LET w(f)=w(f+1)
4250 LET w(f+1)=v
4260 NEXT f
4270 NEXT l
4280 IF INT (w(2)/10)<>INT (w(3)/10) THEN GO TO 4300
4290 LET z=INT (RND *10)+1
4291 IF z>=6 THEN GO TO 4300
4292 LET v=w(3)
4293 LET w(3)=w(2)
4294 LET w(2)=v
4300 FOR f=1 TO 5
4310 LET l=INT (w(f)/10)
4320 LET w(f)=w(f)-l*10
4330 NEXT f
4340 LET p1=w(1)
4350 LET p2=w(2)
4360 LET p3=w(3)
4370 LET p4=w(4)
4380 LET p5=w(5)
4400 IF a=b OR a=c OR a=d OR a=e OR b=c OR b=d OR b=e OR c=d OR c=e OR d=e\{vivn} THEN GO TO 4420
4410 GO TO 4450
4420 PRINT AT 21,0;"\{vi}WAITING FOR PHOTO FOR PLACES\{vn}"
4430 FOR f=1 TO 300:\
     NEXT f
4440 PRINT AT 21,0;"                                "
4450 PRINT AT 21,0;"   2nd - No.";p2;"     3rd - No.";p3
4460 FOR f=1 TO 300:\
    : NEXT f
4470 INK 7
4500 IF ah=p1 THEN LET aw=INT (as*o(ah,1)/o(ah,2)+.5)
4510 IF ah=p2 THEN LET aw=INT (((as*o(ah,1)/o(ah,2))/4)+.5)
4520 IF ah=p3 OR ah=p4 OR ah=p5 THEN LET aw=-INT as
4530 LET aa=aa+aw
4534 PRINT AT 7,2;A$:\
     IF aw>0 THEN PRINT AT 7,12;" Wins  ";l$;aw;p$
4535 IF aw<0 THEN PRINT AT 7,12;" Loses ";l$;aw;p$
4540 IF p=1 THEN GO TO 4900
4550 IF bh=p1 THEN LET bw=INT (bs*o(bh,1)/o(bh,2)+.5)
4560 IF bh=p2 THEN LET bw=INT (((bs*o(bh,1)/o(bh,2))/4)+.5)
4570 IF bh=p3 OR bh=p4 OR bh=p5 THEN LET bw=-INT bs
4575 LET bb=bb+bw
4576 PRINT AT 9,2;B$:\
     IF bw>0 THEN PRINT AT 9,12;" Wins  ";l$;bw;p$
4577 IF bw<0 THEN PRINT AT 9,12;" Loses ";l$;bw;p$
4580 IF p=2 THEN GO TO 4900
4600 IF ch=p1 THEN LET cw=INT (cs*o(ch,1)/o(ch,2)+.5)
4610 IF ch=p2 THEN LET cw=INT (((cs*o(ch,1)/o(ch,2))/4)+.5)
4620 IF ch=p3 OR ch=p4 OR ch=p5 THEN LET cw=-INT cs
4625 LET cc=cc+cw
4626 PRINT AT 11,2;C$:\
     IF cw>0 THEN PRINT AT 11,12;" Wins  ";l$;cw;p$
4627 IF cw<0 THEN PRINT AT 11,12;" Loses ";l$;cw;p$
4630 IF p=3 THEN GO TO 4900
4650 IF dh=p1 THEN LET dw=INT (ds*o(dh,1)/o(dh,2)+.5)
4660 IF dh=p2 THEN LET dw=INT (((ds*o(dh,1)/o(dh,2))/4)+.5)
4670 IF dh=p3 OR dh=p4 OR dh=p5 THEN LET dw=-INT ds
4675 LET dd=dd+dw
4676 PRINT AT 13,2;D$:\
     IF dw>0 THEN PRINT AT 13,12;" Wins  ";l$;dw;p$
4677 IF dw<0 THEN PRINT AT 13,12;" Loses ";l$;dw;p$
4680 IF p=4 THEN GO TO 4900
4700 IF eh=p1 THEN LET ew=INT (es*o(eh,1)/o(eh,2)+.5)
4710 IF eh=p2 THEN LET ew=INT (((es*o(eh,1)/o(eh,2))/4)+.5)
4720 IF eh=p3 OR eh=p4 OR eh=p5 THEN LET ew=-INT es
4725 LET ee=ee+ew
4726 PRINT AT 15,2;E$:\
     IF ew>0 THEN PRINT AT 15,12;" Wins  ";l$;ew;p$
4727 IF ew<0 THEN PRINT AT 15,12;" Loses ";l$;ew;p$
4730 INK 0
4900 LET r=r+1
4905 LET sound=-46
4910 LET as=0:\
     LET bs=0:\
     LET cs=0:\
     LET ds=0:\
     LET es=0
4920 LET ah=0:\
     LET bh=0:\
     LET ch=0:\
     LET dh=0:\
     LET eh=0
4930 LET ss=0:\
     LET st=0:\
     LET pp=0
4935 LET bkr=aw+bw+cw+dw+ew
4936 IF SGN bkr=1 THEN LET mouth=930
4937 IF SGN bkr<1 THEN LET mouth=920
4940 LET aw=0:\
     LET bw=0:\
     LET cw=0:\
     LET dw=0:\
     LET ew=0
4950 LET tune=(INT (RND *5+2)*10)+800:\
     GO SUB tune
4960 PAPER 6:\
     INK 0:\
     BORDER 5:\
     FLASH 0:\
     CLS
4970 LET bkr=aa+bb+cc+dd+ee
4980 IF bkr=0 THEN GO TO 5000
4985 IF bkr>100000 THEN GO TO 5500
4986 IF r>=8 THEN GO TO 5800
4990 GO TO 8340
4999 REM \{vi}LOSTALLMONEY\{vn}
5000 PAPER 5:\
     INK 0:\
     BORDER 0:\
     FLASH 0:\
     CLS
5010 PRINT AT 1,0;"  Oh dear, everyone has lost"
5020 PRINT AT 3,0;"  all their money!"
5030 BEEP .4,2:\
     BEEP .2,6:\
     BEEP .2,7:\
     BEEP .6,9:\
     BEEP .2,9:\
     BEEP .2,11:\
     BEEP .2,14:\
     BEEP .2,13:\
     BEEP .2,11:\
     BEEP .6,9:\
     PAUSE 10
5035 BEEP .4,2:\
     BEEP .2,6:\
     BEEP .2,7:\
     BEEP .6,9:\
     BEEP .2,9:\
     BEEP .2,11:\
     BEEP .2,9:\
     BEEP .2,7:\
     BEEP .2,6:\
     BEEP .6,4:\
     PAUSE 10
5040 BEEP .4,2:\
     BEEP .2,6:\
     BEEP .2,7:\
     BEEP .6,9:\
     BEEP .2,9:\
     BEEP .2,11:\
     BEEP .2,14:\
     BEEP .2,13:\
     BEEP .2,11:\
     BEEP .6,9
5050 BEEP .2,14:\
     BEEP .2,13:\
     BEEP .2,14:\
     BEEP .2,16:\
     BEEP .2,13:\
     BEEP .2,14:\
     BEEP .2,11:\
     BEEP .2,9:\
     BEEP .2,11:\
     BEEP .4,6:\
     BEEP .4,4:\
     BEEP .6,2
5060 BEEP .2,9:\
     BEEP .2,6:\
     BEEP .4,9:\
     BEEP .2,9:\
     BEEP .2,6:\
     BEEP .4,9:\
     BEEP .2,9:\
     BEEP .2,11:\
     BEEP .2,14:\
     BEEP .2,13:\
     BEEP .2,11:\
     BEEP .6,9
5070 BEEP .2,14:\
     BEEP .2,13:\
     BEEP .2,14:\
     BEEP .2,16:\
     BEEP .2,13:\
     BEEP .2,14:\
     BEEP .2,11:\
     BEEP .2,9:\
     BEEP .2,11:\
     BEEP .4,6:\
     BEEP .4,4:\
     BEEP .8,2
5130 PRINT AT 5,0;"  Do you want to start again?"
5140 PRINT AT 7,0;" Press 'y' for yes"
5150 PRINT AT 8,0;"   or  'n' for no"
5160 IF INKEY$ ="y" THEN GO TO 70
5170 IF INKEY$ ="n" THEN GO TO 5190
5180 GO TO 5160
5190 PRINT AT 14,0;" O.K. Hope you enjoyed the game."
5195 PRINT AT 18,0;" Bye!  \o"
5200 PAUSE 200
5205 PRINT AT 19,6;"\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s"
5206 PRINT AT 17,28;\{vivn}"\{vi}Exit\{vnvnvn}"
5210 FOR f=7 TO 30
5220 PRINT AT 18,f;" \o"
5225 PAUSE 10
5230 NEXT f
5240 PRINT AT 18,31;" "
5250 GO TO 9999
5500 REM \{vi}WINOVER\`100000\{vn}
5510 PAPER 6:\
     INK 0:\
     BORDER 3:\
     FLASH 0:\
     CLS
5520 PRINT AT 1,0;" Well done!  "
5530 PRINT AT 3,0;" You have won over ";l$;"100,000";p$
5540 PRINT AT 5,0;" between you!"
5550 PAUSE 250
5560 PRINT AT 7,0;" Unfortunately it looks as if"
5570 PRINT AT 9,0;" the bookmaker has left!...."
5575 PAUSE 150
5580 PRINT AT 13,6;"\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s"
5590 PRINT AT 11,28;\{vivn}"\{vi}Exit\{vnvnvn}"
5600 FOR f=6 TO 30
5610 PRINT AT 12,f;" \p"
5620 NEXT f
5630 PRINT AT 12,31;" "
5640 PAUSE 100
5650 PRINT AT 14,0;"If he'd stayed you'd have had;-"
5700 PRINT AT 15,6;A$;AT 15,16;" ";l$;aa;p$:\
     IF p=1 THEN GO TO 5750
5710 PRINT AT 16,6;B$;AT 16,16;" ";l$;bb;p$:\
     IF p=2 THEN GO TO 5750
5720 PRINT AT 17,6;C$;AT 17,16;" ";l$;cc;p$:\
     IF p=3 THEN GO TO 5750
5730 PRINT AT 18,6;D$;AT 18,16;" ";l$;dd;p$:\
     IF p=4 THEN GO TO 5750
5740 PRINT AT 19,6;E$;AT 19,16;" ";l$;ee;p$
5750 PAUSE 200
5760 PRINT AT 21,0;"Press 'y' for another game."
5770 IF INKEY$ ="" THEN GO TO 5770
5780 IF INKEY$ ="y" THEN GO TO 70
5785 FOR f=14 TO 21:\
     PRINT AT f,0;"                                ":\
     NEXT f
5790 GO TO 5190
5800 REM \{vi}RACEDAYOVER\{vn}
5810 PAPER 6:\
     INK 0:\
     BORDER 3:\
     FLASH 0:\
     CLS
5820 PRINT AT 4,0;"   That's the end of the day's   racing."
5830 PRINT AT 8,0;"   Let's see how much you all    have left!"
5840 FOR f=1 TO 100:\
     NEXT f
5850 GO TO 5700
6000 REM \{vi}SELECTRUNNERS&ODDS\{vn}
6005 DIM r(5)
6010 FOR f=1 TO 5
6015 LET q=INT (RND *40)+1
6016 IF q<1 OR q>40 THEN GO TO 6015
6020 IF r(1)=q OR r(2)=q OR r(3)=q OR r(4)=q OR r(5)=q THEN GO TO 6015
6025 LET r(f)=q
6030 NEXT f
6035 IF version=3 THEN GO TO 6159
6040 IF version=1 THEN GO TO 6120
6050 LET odds=INT (RND *9)+2
6060 GO TO 6130
6120 LET odds=20
6130 DIM o(5,5)
6135 FOR f=1 TO 5
6140 LET q=INT (RND *odds)+1
6145 LET o(f,1)=q:\
     LET o(f,2)=1
6150 NEXT f
6155 GO TO 6160
6159 DIM o(5,2)
6160 PAPER 0:\
     INK 7
6165 PRINT AT 5,14;"1 ";Q$(r(1))
6166 IF version<>3 THEN PRINT AT 5,27;o(1,1);AT 5,29;"/";o(1,2)
6170 PRINT AT 7,14;"2 ";Q$(r(2))
6171 IF version<>3 THEN PRINT AT 7,27;o(2,1);AT 7,29;"/";o(2,2)
6175 PRINT AT 9,14;"3 ";Q$(r(3))
6176 IF version<>3 THEN PRINT AT 9,27;o(3,1);AT 9,29;"/";o(3,2)
6180 PRINT AT 11,14;"4 ";Q$(r(4))
6181 IF version<>3 THEN PRINT AT 11,27;o(4,1);AT 11,29;"/";o(4,2)
6185 PRINT AT 13,14;"5 ";Q$(r(5))
6186 IF version<>3 THEN PRINT AT 13,27;o(5,1);AT 13,29;"/";o(5,2)
6190 INK 0:\
     PAPER 6
6200 RETURN
7000 REM \{vi}ACCEPTBETS&DISPLAY\{vn}
7005 LET st=INT ss
7010 IF pp=1 THEN GO TO 7100
7020 IF pp=2 THEN GO TO 7200
7030 IF pp=3 THEN GO TO 7300
7040 IF pp=4 THEN GO TO 7400
7050 IF pp=5 THEN GO TO 7500
7100 IF st>aa THEN GO TO 7650
7110 LET as=st:\
     LET ah=hh
7120 PRINT AT 16,21;ah;AT 16,23;l$;as;p$;" "
7130 GO TO 7600
7200 IF st>bb THEN GO TO 7650
7210 LET bs=st:\
     LET bh=hh
7220 PRINT AT 17,21;bh;AT 17,23;l$;bs;p$;" "
7230 GO TO 7600
7300 IF st>cc THEN GO TO 7650
7310 LET cs=st:\
     LET ch=hh
7320 PRINT AT 18,21;ch;AT 18,23;l$;cs;p$;" "
7330 GO TO 7600
7400 IF st>dd THEN GO TO 7650
7410 LET ds=st:\
     LET dh=hh
7420 PRINT AT 19,21;dh;AT 19,23;l$;ds;p$;" "
7430 GO TO 7600
7500 IF st>ee THEN GO TO 7650
7510 LET es=st:\
     LET eh=hh
7520 PRINT AT 20,21;eh;AT 20,23;l$;es;p$;" "
7530 GO TO 7600
7600 RETURN
7650 PRINT AT 0,0; FLASH 1;\{vivn}"\{vi} \{vi}YOU CAN'T AFFORD IT-BET AGAIN \{vnvnvnvn}"
7660 GO TO 7600
7690 REM \{vi}ENDOFBETSUB-ROUTINE\{vn}
7999 REM \{vi}INTRODUCTION\{vn}
8000 PAPER 6:\
     INK 0:\
     BORDER 5:\
     FLASH 0:\
     CLS
8010 PRINT AT 1,11;"DERBY DAY"
8020 PRINT AT 1,11; OVER 1;"_________"
8030 PRINT AT 2,0;"    This is  a race meeting of"
8040 PRINT AT 3,0;"  seven races.    See how many","  winners you can pick."
8050 PRINT AT 5,0;"    Your Spectrum  will be the","  bookmaker to take your bets."
8060 PRINT AT 8,0;"   Up to five players may make","  bets.    Each  player starts","  with \`100 (or 100p), and may "
8070 PRINT AT 11,0;"  back one horse in each race."
8080 PRINT AT 13,0;"   Your  'friendly'  bookmaker","  'Honest Clive' Spectrum will","  pay  the  full odds  on  the","  winner and  1/4 the odds  on","  second place."
8085 GO SUB 9000
8090 GO SUB 800:\
     REM \{vi}VERSE\{vn}
8093 GO SUB 900:\
     REM \{vi}CHORUS\{vn}
8096 PRINT AT 19,0;"   Press any key to see other      options available."
8099 IF INKEY$ ="" THEN GO TO 8099
8100 PAPER 6:\
     INK 0:\
     BORDER 5:\
     FLASH 0:\
     CLS
8110 PRINT AT 0,0;"   There  are  4  alternative      versions available:-"
8115 PRINT AT 2,0;"   1) FUN                              Automatic selection  of         horses and long odds."
8120 PRINT AT 5,0;"   2) AMATEUR PUNTER                   Automatic selection  of         horses but shorter odds."
8125 PRINT AT 8,0;"   3) SERIOUS PUNTER                   Automatic selection  of         horses  but  YOU  enter         the odds."
8130 PRINT AT 12,0;"   4) DEAD SERIOUS PUNTER              YOU name the horses and         enter the odds!"
8135 PRINT AT 15,0;" (Note:- In all  versions  BETS  are only accepted in either \`'s or p's (option on  next screen) and winnings are rounded UP to  the nearest \` or p.)"
8140 GO SUB 400:\
     REM \{vi}LOADHORSES\{vn}
8144 PRINT AT 21,0;"CHOOSE VERSION - Press 1 to 4"
8145 LET version=CODE INKEY$ -48
8146 IF version<1 OR version>4 THEN GO TO 8145
8147 PRINT FLASH 1;AT 21,0;"     VERSION ";version;" CHOSEN.          "
8148 FOR f=1 TO 200:\
     NEXT f
8149 CLS
8150 PRINT AT 0,9;"Value of Stake"; OVER 1;AT 0,9;"______________"
8151 PRINT AT 2,0;"  The final option is whether    to have an initial stake and    place bets in '\`'s or 'p's.    "
8152 PRINT AT 6,0;"  ""Press  'L'  for 'Pounds'          or   'P'  for 'Pence'     "
8153 IF INKEY$ ="l" THEN GO TO 8160
8154 IF INKEY$ ="p" THEN GO TO 8170
8155 GO TO 8153
8160 LET l$="\`":\
     LET p$=" "
8161 PRINT AT 14,0;"  You have chosen  '\`'s  "
8162 GO TO 8175
8170 LET l$=" ":\
     LET p$="p"
8171 PRINT AT 14,0;"  You have chosen  'p's  "
8175 FOR f=1 TO 200:\
     NEXT f
8176 CLS
8179 GO TO 8200
8180 REM \{vi}ACCEPTPLAYERSNAMES\{vn}
8190 PRINT AT 21,0;"Sorry, I said 1 to 5 players."
8200 INPUT "How many players?",p
8210 IF p<1 OR p>5 THEN GO TO 8190
8220 CLS
8230 PRINT AT 0,2;"O.K. ";p;" person(s) want to play."
8240 PRINT AT 2,2;"Please tell me their name(s) - "
8250 FOR h=1 TO p
8260 GO SUB 8600
8270 NEXT h
8300 INPUT "If names correct - enter 'Y'",F$
8310 IF F$="y" OR f$="Y" THEN GO TO 8320
8315 GO TO 8220
8320 LET r=1
8325 PAPER 6:\
     INK 0:\
     BORDER 5:\
     FLASH 0:\
     CLS
8330 IF r=1 THEN PRINT AT 1,0;"  Thank you."
8340 PRINT AT 3,0;"  Lets meet the bookmaker  and"
8350 PRINT AT 5,0;"  see what the odds are on the"
8360 IF r=1 THEN PRINT AT 7,0;"  first race."
8365 IF r>1 THEN PRINT AT 7,0;"  next race."
8370 PAUSE 200
8371 IF r>1 THEN GO TO 8400
8372 REM \{vi}SETINITIALVALUES\{vn}
8373 LET aw=0:\
     LET bw=0:\
     LET cw=0:\
     LET dw=0:\
     LET ew=0
8374 LET ah=0:\
     LET bh=0:\
     LET ch=0:\
     LET dh=0:\
     LET eh=0
8375 LET aa=0:\
     LET bb=0:\
     LET cc=0:\
     LET dd=0:\
     LET ee=0
8380 LET aa=100:\
     IF p=1 THEN GO TO 8395
8381 LET bb=100:\
     IF p=2 THEN GO TO 8395
8382 LET cc=100:\
     IF p=3 THEN GO TO 8395
8383 LET dd=100:\
     IF p=4 THEN GO TO 8395
8384 LET ee=100:\
     IF p=5 THEN GO TO 8395
8395 LET mouth=920
8399 REM \{vi}BOOKMAKERDISPLAY\{vn}
8400 CLS :\
     PAPER 6:\
     INK 0:\
     BORDER 5:\
     FLASH 0
8404 FOR f=0 TO 3:\
     PRINT AT f,0; PAPER 4;"                                ":\
     NEXT f
8405 PRINT AT 0,0; PAPER 4; INK 6;"  ";"\{vi}Parade Ring\{vn}";"                    "
8406 PRINT AT 3,0; PAPER 4; INK 7;"\t\t\t\t\t\t\t\t\t\t\t\t\t\t"
8410 FOR f=1 TO 15:\
     PRINT AT f,14; PAPER 0;"                  ":\
     NEXT f
8415 PRINT PAPER 7; INK 2;AT 2,16;" HONEST CLIVE "
8420 PRINT AT 5,5; INK 1;"\s\s\s\s\s";AT 6,5;"\s\s\s\s\s"
8421 PRINT AT 7,3; INK 1;"\..\..\::\::\::\::\::\..\.."
8422 PRINT AT 8,5; PAPER 7; INK 5;" \* \* ";AT 9,5; INK 3;"  U  "
8423 PRINT AT 9,4; PAPER 6; INK 7;"\ :";AT 9,10;"\: "
8424 PRINT AT 10,5; PAPER 7;"     "
8425 PRINT AT 11,5; PAPER 7;"     "
8426 PRINT AT 11,5; PAPER 6; INK 2;"\':";AT 11,9;"\:'"
8427 PRINT AT 3,19; PAPER 0; INK 7;"RACE ";r;AT 3,19; OVER 1;"______"
8428 PRINT AT 12,6; INK 2;"\':\::\:'";AT 13,6; PAPER 7;" \'' "
8429 PRINT AT 13,2; PAPER 4; INK 7;"    \ '\::\'     "
8430 PRINT AT 14,2; PAPER 4;"           "
8431 GO TO 8440
8432 IF r=1 THEN PRINT PAPER 2; INK 7;AT 0,14;"  NOVICES  PLATE  "
8433 IF r=2 THEN PRINT PAPER 2; INK 7;AT 0,14;"  RAMTOP  STAKES  "
8434 IF r=3 THEN PRINT PAPER 2; INK 7;AT 0,14;" JOCKEYS HANDICAP "
8435 IF r=4 THEN PRINT PAPER 2; INK 7;AT 0,14;"  SELLERS  PLATE  "
8436 IF r=5 THEN PRINT PAPER 2; INK 7;AT 0,14;"  CHALLENGE  CUP  "
8437 IF r=6 THEN PRINT PAPER 2; INK 7;AT 0,14;"  RAINBOW STAKES  "
8438 IF r=7 THEN PRINT PAPER 7; INK 2; BRIGHT 1;AT 0,14;"    THE  DERBY    "
8439 RETURN
8440 REM \{vi}SELECTRUNNERS+ODDS\{vn}
8441 GO SUB 8432
8445 IF version=4 THEN GO TO 9500
8450 GO SUB 6000
8455 IF version=3 THEN GO TO 9600
8470 PRINT AT 15,0; PAPER 7; INK 0;"    PLAYER     HORSE No  STAKE  "
8475 \{vnvnvn} PRINT AT 16,0;l$;aa;p$;AT 16,8;"\{vi}1\{vn} ";A$:\
     IF p=1 THEN GO TO 8480\{vn}
8476 PRINT AT 17,0;l$;bb;p$;AT 17,8;"\{vi}2\{vn} ";B$:\
     IF p=2 THEN GO TO 8480
8477 \{vnvnvn} PRINT AT 18,0;l$;cc;p$;AT 18,8;"\{vi}3\{vn} ";C$:\
     IF p=3 THEN GO TO 8480
8478 \{vnvnvn} PRINT AT 19,0;l$;dd;p$;AT 19,8;"\{vi}4\{vn} ";D$:\
     IF p=4 THEN GO TO 8480\{vn}
8479 \{vnvnvn} PRINT AT 20,0;l$;ee;p$;AT 20,8;"\{vi}5\{vn} ";E$\{vn}
8480 GO SUB mouth
8487 GO TO 8500
8489 REM \{vi}HORSEPARADE-BOOKMAKER\{vn}
8490 LET IK =INT (RND *8):\
     IF IK =3 OR IK =4 OR IK =5 THEN GO TO 8490
8491 FOR f=0 TO 10
8492 PRINT AT 2,f; PAPER 4;\{i0}" "; INK IK ;"\a"; INK 0;"\b":\
     PAUSE 10
8493 IF INKEY$ <>"" THEN GO TO 8497
8494 PRINT AT 2,f; PAPER 4;\{i0}" "; INK IK ;"\e"; INK 0;"\f":\
     PAUSE 10
8495 IF INKEY$ <>"" THEN GO TO 8497
8496 NEXT f
8497 PRINT AT 2,f; PAPER 4;"   "
8498 IF INKEY$ ="" THEN GO TO 8490
8499 RETURN
8500 PRINT PAPER 4;AT 21,0;" Player (1 to 5) or (9 to end)  "
8501 IF INKEY$ ="" THEN GO SUB 8490
8502 LET pp=CODE INKEY$ -48
8503 PRINT AT 21,0; PAPER 6;"                                "
8504 IF pp=9 THEN GO TO 8570
8505 IF pp<1 OR pp>p THEN GO TO 8500
8506 IF pp=1 THEN LET g$=A$
8507 IF pp=2 THEN LET g$=B$
8508 IF pp=3 THEN LET g$=C$
8509 IF pp=4 THEN LET g$=D$
8510 IF pp=5 THEN LET g$=E$
8511 PRINT PAPER 4; FLASH 1;AT 21,0;" ";g$;" "; FLASH 0;AT 21,12;"Horse No.? (1 TO 5)"
8512 PAUSE 100
8516 IF INKEY$ ="" THEN GO TO 8516
8517 LET hh=CODE INKEY$ -48
8518 PRINT AT 21,0; PAPER 6;"                                "
8520 IF hh<1 OR hh>5 THEN GO TO 8515
8521 PAUSE 100
8525 PRINT AT 21,0; PAPER 4;" ";hh;" -Bet (Min. ";l$;"1";p$;" - Max.= All  )"
8526 INPUT ss
8530 IF ss<0 THEN GO TO 8525
8540 PRINT AT 0,0; PAPER 4; INK 6;"  ";"\{vi}Parade Ring\{vn}";" "
8541 GO SUB 8432
8545 PRINT AT 21,0; PAPER 6; INK 0;"                           "
8550 GO SUB 7000
8560 GO TO 8500
8570 PRINT AT 21,0;"\{vi}No more bets - lets start race \{vn}"
8580 FOR f=1 TO 100:\
     NEXT f
8590 GO TO 100
8595 REM \{vi}ENDOFBOOKMAKER\{vn}
8599 REM \{vi}PLAYERNAMESUB-ROUTINE\{vn}
8600 PRINT AT h*4,2;"Player No.";h;" is "
8700 INPUT "Max.10 letters",F$
8710 IF LEN F$<1 OR LEN F$>10 THEN GO TO 8700
8720 IF h=1 THEN LET A$=F$
8730 IF h=1 THEN PRINT AT 4,18;A$
8740 IF h=2 THEN LET B$=F$
8750 IF h=2 THEN PRINT AT 8,18;B$
8760 IF h=3 THEN LET C$=F$
8770 IF h=3 THEN PRINT AT 12,18;C$
8780 IF h=4 THEN LET D$=F$
8790 IF h=4 THEN PRINT AT 16,18;D$
8800 IF h=5 THEN LET E$=F$
8810 IF h=5 THEN PRINT AT 20,18;E$
8820 RETURN
8830 REM \{vi}ENDNAMEROUTINE\{vn}
9000 REM \{vi}DEFINEUSERGRAPHICS\{vn}
9001 REM \{vi}SUB-ROUTINE\{vn}
9010 RESTORE 9200
9020 REM \{vi}ENTERCONSTANTS\{vn}
9030 LET a=BIN 11111111:\
     LET b=BIN 11100000:\
     LET c=BIN 11110000:\
     LET d=BIN 00011111:\
     LET e=BIN 00000110:\
     LET f=BIN 00100000:\
     LET g=BIN 01000000:\
     LET h=BIN 00011001:\
     LET j=BIN 00010000:\
     LET k=BIN 01110000:\
     LET l=BIN 00011100:\
     LET m=BIN 00001000
9040 LET n=BIN 00001110:\
     LET o=BIN 00000111:\
     LET p=BIN 01100011
9050 LET q=BIN 10001000:\
     LET r=BIN 00000000:\
     LET s=BIN 11111111
9100 FOR X=144 TO 164
9110 FOR Y=0 TO 7
9120 READ Z
9125 LET V$=CHR$ X
9130 POKE USR V$+Y,Z
9140 NEXT Y
9150 NEXT X
9160 RETURN
9199 REM \{vi}ENTERDATAFOR21CHARS\{vn}
9200 DATA 0,0,0,e,m,n,n,o
9210 DATA 0,0,0,j,BIN 00111000,BIN 00111100,BIN 01100100,c
9220 DATA BIN 00111111,BIN 01011111,BIN 01011001,j,f,j,j,j
9230 DATA c,c,b,f,f,f,f,f
9240 DATA 0,0,0,BIN 00000011,n,n,e,o
9250 DATA 0,0,0,0,l,n,h,c
9260 DATA 0,0,0,0,BIN 00100001,BIN 01111110,BIN 00111100,BIN 00100100
9270 DATA c,c,b,j,m,j,f,g
9280 DATA BIN 00111111,BIN 01011111,BIN 10011001,j,f,BIN 00011000,BIN 00000100,BIN 00000000
9290 DATA c,c,b,j,m,j,BIN 01100000,0
9300 DATA a,d,BIN 00011000,j,f,g,BIN 10000000,0
9310 DATA c,c,c,BIN 00011000,BIN 00000100,BIN 00000010,BIN 00000001,0
9320 DATA BIN 01111111,BIN 10011111,l,BIN 00011000,BIN 00110000,j,j,f
9330 DATA c,c,b,f,j,m,m,j
9340 DATA f,f,k,BIN 10101000,BIN 10101010,BIN 01110111,BIN 01110010,BIN 01010010
9350 DATA BIN 01000100,BIN 01000100,BIN 11101110,BIN 11101110,BIN 01000100,BIN 10101010,BIN 10101010,BIN 10101010
9360 DATA l,BIN 00111110,p,p,p,BIN 00111110,l,m
9370 DATA BIN 10000000,BIN 10000000,q,a,q,q,q,q
9380 DATA r,s,r,s,r,s,r,s
9390 DATA a,a,a,s,r,s,r,s
9400 DATA 0,0,q,a,q,q,q,q
9410 DATA 0,0,0,0,0,0,0,0
9500 REM \{vi}ENTERHORSESNAMES\{vn}
9501 FOR f=5 TO 13 STEP 2
9502 PRINT PAPER 0;AT f,14;"            "
9503 NEXT f
9510 PRINT AT 18,0;"Please enter names of 5 horses  "
9520 PRINT AT 20,0;" (Maximum 10 letters each.)"
9530 FOR f=1 TO 5
9540 INPUT z$
9550 IF LEN z$>10 THEN GO TO 9540
9560 PRINT PAPER 0; INK 7;AT f*2+3,14;f;" ";z$
9570 NEXT f
9580 PRINT AT 18,0;"                                "
9585 PRINT AT 20,0;"Press 'Y' if correct 'N' if not"
9586 LET z$=INKEY$
9590 IF z$="n" OR z$="N" THEN GO TO 9501
9595 IF z$="y" OR z$="Y" THEN GO TO 9600
9596 GO TO 9585
9601 FOR f=5 TO 13 STEP 2
9602 PRINT PAPER 0;AT f,27;"     "
9603 NEXT f
9605 DIM o(5,2)
9610 PRINT AT 16,0;"Please enter odds for each horse"
9620 PRINT AT 17,0;"(Both figures required -        "
9630 PRINT AT 18,0;" e.g. 4/1 enter 4 then 1        "
9640 PRINT AT 19,0;"      2/7 enter 2 then 7        "
9650 PRINT AT 20,0;"(Maximum 2 digits for each No. "
9655 PAPER 0
9660 INPUT "Horse 1 ",z
9665 IF z<1 OR z>99 THEN GO TO 9660
9670 PRINT INK 7;AT 5,27;z;AT 5,29;"/"
9671 LET o(1,1)=z
9675 INPUT "to ",z
9676 IF z<1 OR z>99 THEN GO TO 9675
9680 PRINT INK 7;AT 5,30;z
9681 LET o(1,2)=z
9690 INPUT "Horse 2 ",z
9695 IF z<1 OR z>99 THEN GO TO 9690
9700 PRINT INK 7;AT 7,27;z;AT 7,29;"/"
9701 LET o(2,1)=z
9705 INPUT "to ",z
9706 IF z<1 OR z>99 THEN GO TO 9705
9710 PRINT INK 7;AT 7,30;z
9711 LET o(2,2)=z
9740 INPUT "Horse 3 ",z
9745 IF z<1 OR z>99 THEN GO TO 9740
9750 PRINT INK 7;AT 9,27;z;AT 9,29;"/"
9751 LET o(3,1)=z
9755 INPUT "to ",z
9756 IF z<1 OR z>99 THEN GO TO 9755
9760 PRINT INK 7;AT 9,30;z
9761 LET o(3,2)=z
9790 INPUT "Horse 4 ",z
9795 IF z<1 OR z>99 THEN GO TO 9790
9800 PRINT INK 7;AT 11,27;z;AT 11,29;"/"
9801 LET o(4,1)=z
9805 INPUT "to ",z
9806 IF z<1 OR z>99 THEN GO TO 9805
9810 PRINT INK 7;AT 11,30;z
9811 LET o(4,2)=z
9840 INPUT "Horse 5 ",z
9845 IF z<1 OR z>99 THEN GO TO 9840
9850 PRINT INK 7;AT 13,27;z;AT 13,29;"/"
9851 LET o(5,1)=z
9855 INPUT "to ",z
9856 IF z<1 OR z>99 THEN GO TO 9855
9860 PRINT INK 7;AT 13,30;z
9861 LET o(5,2)=z
9862 PAPER 6:\
     INK 0
9870 FOR f=16 TO 21
9871 PRINT AT f,0;"                                ":\
     NEXT f
9880 PRINT AT 20,0;"Press 'Y' if correct 'N' if not"
9885 LET Z$=INKEY$
9890 IF z$="n" OR z$="N" THEN GO TO 9600
9900 IF z$="y" OR z$="Y" THEN GO TO 9920
9910 GO TO 9885
9920 PRINT AT 20,0;"                                "
9930 GO TO 8470
9989 REM \{vi}SIZEOFPROGRAMROUTINE\{vn}
9990 LET z=PEEK 23653+256*PEEK 23654
9991 PRINT (z-16384);" Total memory"
9993 LET z=z-(PEEK 23635+256*PEEK 23636)
9994 PRINT z;" Basic program"
9999 STOP
