    0 REM 24 color background
   10 BORDER 0: PALETTE 64, 1
   20 POKE USR "a", 60
   30 POKE USR "a" + 1, 126
   40 POKE USR "a" + 2, 255
   50 POKE USR "a" + 3, 255
   60 POKE USR "a" + 4, 255
   70 POKE USR "a" + 5, 255
   80 POKE USR "a" + 6, 126
   90 POKE USR "a" + 7, 60
  100 REM set 24 PAPER colours
  110 FOR i = 0 TO 7
  120 PALETTE 8 + i, 1 + 4 * i
  130 PALETTE 24 + i, 2 + 32 * i
  140 PALETTE 40 + i, 3 + 4 * i + 32 * i
  150 NEXT i
  160 REM paint backdrop
  170 FOR i = 0 TO 21
  180 COLOR i * 8
  190 PRINT "                                "; 
  200 NEXT i
  210 PRINT #0; AT 0, 0; PEN 0; PAPER 6; CLUT 2; "                                "; PAPER 7; "                                "
  220 REM do animation
  230 LET x =  -1: LET y =  -1: LET xd = 1: LET yd = 1:
  240 LET x = x + xd: LET y = y + yd
  250 IF x = 0 THEN LET xd = 1
  260 IF y = 0 THEN LET yd = 1
  270 IF x = 23 THEN LET xd =  -1
  280 IF y = 31 THEN LET yd =  -1
  290 IF x < 22 THEN PRINT AT x, y; PAPER 8; CLUT 8; CHR$ 144
  300 IF x = 0 OR y = 0 OR x = 23 OR y = 32 THEN LET c = INT (RND * 256): PALETTE 0, c: PALETTE 16, c: PALETTE 32, c
  310 IF x > 21 THEN PRINT #0; AT x - 22, y; PEN 0; PAPER 8; CLUT 8; CHR$ 144
  320 PAUSE 5
  330 IF x < 22 THEN PRINT AT x, y; PAPER 8; CLUT 8; " "
  340 IF x > 21 THEN PRINT #0; AT x - 22, y; PAPER 8; CLUT 2; " "
  350 GO TO 240