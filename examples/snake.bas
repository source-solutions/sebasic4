Auto 1

10 REM \* Snake in the Triangles
20 GO SUB 9000:\
   LET hi = 0
30 GO SUB 8000
40 PRINT AT 9,h;" "
50 LET h = h + 2 * (INKEY$="8" AND v<29):\
   IF h > 0 THEN LET h = h - 1
54 IF SCREEN$ (10,h) = "" THEN GO TO 1000
55 PRINT AT 9,h; INK 6;"\b";AT 10,h;"\c"
60 PRINT AT 21,0;
70 PRINT TAB INT (RND * 31); INK 1;"\a"
80 POKE 23692,255
90 LET sc=sc+1: PRINT
95 PAUSE 5
100 GO TO 40
1000 PRINT AT 0,0; OVER 1; PAPER 8; INK 2; v$(1)
1010 PRINT AT 1,10; FLASH 1;"GAME OVER"
1020 PRINT AT 5,7; "You scored "; sc
1030 IF sc>hi THEN LET hi=sc
1040 PRINT AT 10,5;"Highest score today ";hi
1050 INPUT "Press "; PAPER 1;"ENTER"; PAPER 0;" to play again "; LINE a$: IF A$ <> "n" THEN GO TO 30
1090 STOP 
8000 BORDER 0:\
     PAPER 0:\
     INK 9:\
     CLS:\
     LET v=10:\
     LET h=15
8010 LET sc=0: RANDOMIZE
8020 DIM v$(1,704)
8030 RETURN
9000 FOR a = USR "a" to USR "c" + 7
9010 READ user:\
     POKE a,user
9020 NEXT a:\
     RETURN
9030 DATA 255,126,126,60,60,24,24,0
9040 DATA 0,99,119,127,62,28,0,0
9050 DATA 99,119,73,73,127,62,28,0
