Auto 1
  10 REM Brainfuck Interpreter
  20 CLEAR PEEK 23675+256*PEEK 23676-30020
  30 LET e=0
  40 LET c$="++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>."
  50 LET p=20+PEEK 23730+256*PEEK 23731: GO SUB 500
 100 LET e=e+1: IF e>LEN c$ THEN STOP
 110 IF c$(e)="+" THEN POKE p,PEEK p+1-(255*(PEEK p=255)): GO TO 100
 120 IF c$(e)=">" THEN LET p=p+1: GO TO 100
 130 IF c$(e)="<" THEN LET p=p-1: GO TO 100
 140 IF c$(e)="-" THEN POKE p,PEEK p-1+(255*(PEEK p=0)): GO TO 100
 150 IF c$(e)="." THEN PRINT CHR$ PEEK p;: GO TO 100
 160 IF c$(e)="," THEN INPUT b$: POKE p,CODE b$: GO TO 100
 170 IF c$(e)="[" THEN IF PEEK p=0 THEN GO SUB 200: GO TO 100
 180 IF c$(e)="]" THEN IF PEEK p<>0 THEN GO SUB 300: GO TO 110
 190 GO TO 100
 200 LET b=1
 210 LET e=e+1: IF c$(e)="[" THEN LET b=b+1
 220 IF c$(e)="]" THEN LET b=b-1: IF b=0 THEN RETURN
 230 GO TO 210
 300 LET b=1
 310 LET e=e-1: IF c$(e)="]" THEN LET b=b+1
 320 IF c$(e)="[" THEN LET b=b-1: IF b=0 THEN RETURN
 330 GO TO 310
 500 RESTORE 510: FOR b=p-20 TO p-2: READ e: POKE b,e: NEXT b: RANDOMIZE USR (p-20): LET e=0: RETURN
 510 DATA 237,91,178,92,33,20,0,25,1,48,117,84,93,54,0,19,237,176,201
