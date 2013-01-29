   5 REM Hangman
  10 REM set up screen
  20 INK 0: PAPER 7: CLS
  30 LET x=240: GO SUB 1000: REM draw man
  40 PLOT 238,128: DRAW 4,0: REM mouth
 100 REM set up word
 110 INPUT w$: REM word to guess
 120 LET b=LEN w$: LET v$=" "
 130 FOR n=2 TO b: LET v$=v$+" "
 140 NEXT n: REM v$=word guessed so far
 150 LET c=0: LET d=0: REM guess & mistake counts
 160 FOR n=0 TO b-1
 170 PRINT AT 20,n;"-"
 180 NEXT n: REM write -'s instead of        letters
 200 INPUT "Guess a letter: ";g$
 210 IF g$="" THEN GO TO 200
 220 LET g$=g$(1): REM 1st letter only
 230 PRINT AT 0,c;g$
 240 LET c=c=1: LET u$=v$
 250 FOR n=1 TO b: REM update guessed word
 260 IF w$(n)=g$ THEN LET v$(n)=g$
 270 NEXT n
 280 PRINT AT 19,0;v$
 290 IF v$=w$ THEN GO TO 500: REM word guessed
 300 IF v$<>u$ THEN GO TO 200: REM guess was right
 400 REM draw next part of           the gallows
 410 IF d=8 THEN GO TO 600: REM hanged
 420 LET d=d+1
 430 READ x0,y0,x,y
 440 PLOT x0,y0: DRAW x,y
 450 GO TO 200
 500 REM free man
 510 OVER 1: REM rub out man
 520 LET x=240: GO SUB 1000
 530 PLOT 238,128: DRAW 4,0: REM mouth
 540 OVER 0: REM redraw man
 550 LET x=146: GO SUB 1000
 560 PLOT 143,129: DRAW 6,0,PI /2: REM smile
 570 GO TO 800
 600 REM hang man
 610 OVER 1: REM rub out floor
 620 PLOT 255,65: DRAW -48,0
 630 DRAW 0,-48: REM open trapdoor
 640 PLOT 238,128: DRAW 4,0: REM rub out mouth
 650 REM move limbs
 660 PLOT 255,117: DRAW -15,-15: DRAW -15,15
 670 OVER 0
 680 PLOT 236,81: DRAW 4,21: DRAW 4,-21
 690 OVER 1: REM legs
 700 PLOT 255,66: DRAW -15,15: DRAW -15,-15
 710 OVER 0
 720 PLOT 236,60: DRAW 4,21: DRAW 4,-21
 730 PLOT 237,127: DRAW 6,0,-PI /2: REM frown
 740 PRINT AT 19,0;w$
 800 INPUT "again? ";a$
 820 LET a$=a$(1)
 830 IF a$(1)="n" THEN STOP
 840 IF a$(1)="N" THEN STOP
 850 RESTORE : GO TO 5
1000 REM draw man at column x
1010 REM head
1020 CIRCLE x,132,8
1030 PLOT x+4,134: PLOT x-4,134: PLOT x,131
1040 REM body
1050 PLOT x,123: DRAW 0,-20
1055 PLOT x,101: DRAW 0,-19
1060 REM legs
1070 PLOT x-15,66: DRAW 15,15: DRAW 15,-15
1080 REM arms
1090 PLOT x-15,117: DRAW 15,-15: DRAW 15,15
1100 RETURN
2000 DATA 120,65,135,0,184,65,0,91
2010 DATA 168,65,16,16,184,81,16,-16
2020 DATA 184,156,68,0,184,140,16,16
2030 DATA 204,156,-20,-20,240,156,0,-16
