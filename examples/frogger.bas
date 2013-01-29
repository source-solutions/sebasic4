Auto 1

   1 REM FROGGER
   2 REM \* C.BLOOR 1983
  10 BORDER 0:\
     PAPER 0:\
     INK 4
  20 CLEAR 32243:\
     GO TO 40
  25 BEEP .04,b-a
  30 PRINT OVER 1; PAPER 8; INK 8;AT a,y2;"\g":\
     RETURN
  40 PRINT AT 4,2; INK 4; BRIGHT 1;"\..\..\.. \..\..\.. \..\..\.. \..\..\.. \..\..\.. \..\..\.. \..\..\..     \:.\..\..\  \:.\..\.: \:  \ : \:  \{vn}\.. \:  \.. \:.\..  \:.\..\.:     \:    \:  \'. \:.\..\.: \:.\..\.: \:.\..\.: \:.\..\.. \:  \'."
  45 PRINT AT 9,4; INK 6;"written by C.BLOOR 1983"
  48 PRINT AT 12,9;"CONTROLS are";AT 14,9;"O LEFT";AT 16,9;"P RIGHT";AT 18,9;"Q UP"
  50 FOR a=32244 TO 32494
  60 READ b:\
     POKE a,b:\
     NEXT a
  70 DATA 14,8,229,17,31,0,25,126,237,82,31,6,32,126,31,119,35,16,250,225,36,13,32,234,201
  80 DATA 14,8,175,229,17,31,0,237,82,126,25,23,6,32,126,23,119,43,16,250,225,36,13,32,233,201
  90 DATA 33,95,64,205,13,126,33,128,64,205,244,125,33,128,64,205,244,125,33,223,64,205,13,126,33,0,72,205,244,125,33,0,72,205,244,125,33,0,72,205,244,125
 100 DATA 58,121,92,0,0,0,0,0,0,0,230,2,40,20,33,64,72,205,244,125,33,64,72,205,244,125,33,64,72,205,244,125,24,18,33,95,72,205,13,126,33,95,72,205,13,126,33,95,72,205,13,126
 110 DATA 33,128,72,205,244,125,33,192,72,205,244,125,33,192,72,205,244,125,33,31,80,205,13,126,33,31,80,205,13,126,33,95,80,205,13,126,0
 120 DATA 33,128,72,205,244,125,33,192,72,205,244,125,33,31,80,205,13,126,33,95,80,205,13,126,201
 130 DATA 33,95,64,205,13,126,33,128,64,205,244,125,33,0,72,205,244,125,201
 140 DATA 33,95,64,205,13,126,33,223,64,205,13,126,33,128,72,205,244,125,33,192,72,205,244,125,201
 150 LET a=USR "a"
 160 FOR b=a TO a+167
 170 READ c:\
     POKE b,c:\
     NEXT b
 180 DATA 15,17,33,127,199,147,171,16,128,64,32,255,227,201,213,8
 190 DATA 255,255,255,255,192,145,170,17,255,255,255,255,127,63,191,0
 200 DATA 124,74,201,255,227,201,85,8,24,24,36,126,60,90,165,66
 210 DATA 153,189,90,60,60,126,90,195,1,2,4,255,199,147,171,16
 220 DATA 240,136,132,254,227,201,213,8,62,82,147,255,199,147,170,16
 230 DATA 255,255,255,255,255,252,253,0,255,255,255,255,3,137,85,136
 240 DATA 16,41,199,0,38,0,0,0,1,255,255,1,1,255,255,1
 250 DATA 0,33,83,141,87,35,80,136,0,132,234,177,234,196,10,17
 260 DATA 32,32,32,32,255,127,63,31,0,0,0,0,240,240,255,255
 270 DATA 16,62,42,63,254,252,248,240,0,0,0,0,0,0,7,31,0,0,1,2,62,104,241,255
 271 PRINT AT 20,9; INK 6;"PRESS ANY KEY":\
     PAUSE 0
 400 BRIGHT 1:\
     PAPER 5:\
     BORDER 0:\
     INK 0:\
     CLS
 405 PRINT AT 21,18; PAPER 0;"              ":\
     PRINT AT 21,6; PAPER 0;"       "
 410 LET hi=0
 420 PRINT PAPER 4;AT 10,0;"               \o\p               "
 430 LET lives=5:\
     LET score=0:\
     LET home=0
 440 POKE 32425,201:\
     POKE 32450,201:\
     POKE 32469,201
 450 PRINT AT 0,0; PAPER 4;"\n\n\n\n\n\n";" "; PAPER 4;"\n\n\n\n\n";" "; PAPER 4;"\n\n\n\n\n\n";" "; PAPER 4;"\n\n\n\n\n";" "; PAPER 4;"\n\n\n\n\n\n"
 455 IF home<>0 THEN GO TO 660
 460 PRINT INK 5;"\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\.."
 470 PRINT INK 0;"\q\r\r\r\s    \q\r\r\s  \q\r\r\s    \q\r\r\r\s    "
 480 PRINT INK 7;"\m\m\m\m   \m\m\m\m\m   \m\m\m   \m\m \m\m\m \m\m\m\m"
 490 PRINT INK 2;" \t\u   \t\u  \t\u    \t\u  \t\u    \t\u \t\u "
 500 PRINT INK 7;"\m\m\m \m\m\m   \m\m\m\m  \m\m  \m\m\m   \m\m\m\m \m"
 510 PRINT INK 0;" \q\r\r\r\s  \q\r\r\s   \q\r\r\s    \q\r\r\r\r\s   "
 520 PRINT INK 7;"\m\m\m \m\m  \m\m \m\m   \m\m\m  \m\m\m    \m\m "
 530 PRINT INK 0;"\t\u   \t\u     \t\u \t\u   \t\u    \t\u    "
 540 PRINT PAPER 4; INK 7;"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
 550 PRINT PAPER 0; INK 7;AT 11,0;"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
 560 PRINT PAPER 0; INK 2;" \a\b \f \a\b  \c\d\c\d\e \f \f    \c\d\e      "
 570 PRINT PAPER 0; INK 7;"--------------------------------"
 580 PRINT PAPER 0; INK 4;" \a\b   \a\b     \a\b   \a\b       \a\b   "
 590 PRINT PAPER 0; INK 7;"================================"
 600 PRINT PAPER 0; INK 6;"\b     \h\i    \h\i        \h\i       \h"
 610 PRINT PAPER 0; INK 7;"--------------------------------"
 620 PRINT PAPER 0; INK 3;"\k\l    \h\i   \h\i \f  \f   \j\k\l\k\l  \f  \j"
 630 PRINT PAPER 4;"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
 640 PRINT PAPER 4;"                                "
 650 PRINT AT 21,0; PAPER 0; INK 6;"SCORE:        ";AT 21,15; INK 4;"\g  "; PAPER 0; INK 7;AT 21,14;lives; PAPER 0; INK 6;AT 21,17;"BEST:"
 660 LET x1=20:\
     LET y1=16:\
     LET x2=x1:\
     LET y2=y1
 670 PAUSE 5:\
     PRINT AT x1,y1;"\{i8p8} "
 680 RANDOMIZE USR 32295
 690 IF SCREEN$ (x2,y2)=" " THEN GO TO 880
 700 LET a=x2:\
     FOR b=25 TO 35:\
     GO SUB 25:\
     GO SUB 25:\
     NEXT b
 730 FOR a=x2 TO 20 STEP 2:\
     GO SUB 25:\
     GO SUB 25:\
     NEXT a
 740 LET lives=lives-1:\
     PRINT AT 21,14; PAPER 0; INK 7;lives
 750 LET x2=20
 760 IF lives<>0 THEN GO TO 680
 770 IF hi>score THEN GO TO 790
 780 LET hi=score:\
     PRINT AT 21,22; PAPER 0; INK 7;hi
 785 IF score>hi THEN GO TO 780
 790 PRINT FLASH 1; PAPER 2;AT 12,0;"           GAME  OVER           "
 800 PRINT AT 14,0; PAPER 7;"   ANOTHER GAME? (Y)es   (N)o   "
 840 IF INKEY$ ="n" THEN RANDOMIZE USR 0
 850 IF INKEY$ <>"y" THEN GO TO 840
 860 PRINT PAPER 0;AT 21,6;"          ":\
     GO TO 415
 880 IF x2<>0 THEN GO TO 1050
 890 PRINT PAPER 8; INK 8;AT x1,y1;" ":\
     PRINT AT x2,y2;"\g"
 900 RESTORE 920
 910 FOR a=1 TO 8:\
     READ b,c:\
     BEEP b,c:\
     NEXT a
 920 DATA .1,11,.1,11,.8,16,.05,11,.05,16,.05,11,.05,16,1,20
 930 LET home=home+1:\
     LET score=score+100:\
     PRINT AT 21,6; PAPER 0; INK 7;score
 950 IF home/4<>INT (home/4) THEN GO TO 660
 960 IF home=4 THEN POKE 32425,0
 970 IF home=8 THEN POKE 32450,0
 980 IF home=12 THEN POKE 32469,0
 985 IF home>36 THEN GO TO 450
 990 LET a=RND *31
1000 LET a=a+1
1005 IF a>31 THEN LET a=0
1010 IF SCREEN$ (10,a)="" THEN GO TO 1000
1030 PRINT PAPER 4;AT 10,a;"\o\p"
1035 RESTORE 920:\
     FOR a=1 TO 10:\
     READ b,c:\
     BEEP b,c:\
     NEXT a
1040 GO TO 450
1050 PRINT AT x2,y2;"\{p8i8}\g"
1060 LET x1=x2:\
     LET y1=y2
1070 IF INKEY$ <>"q" THEN GO TO 1100
1080 BEEP .02,2
1090 LET x2=x2-2:\
     LET score=score+15:\
     PRINT AT 21,6; PAPER 0; INK 7;score
1100 LET y2=y2+(INKEY$ ="p" AND y2<>31)-(INKEY$ ="o" AND y2<>0)
1110 GO TO 670
