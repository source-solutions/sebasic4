Auto 0

# Run-time Variables

Var m: NumFOR = 2.8, 10, 0.1, 10, 2

# End Run-time Variables

   1 REM fast
   5 REM Sombrero by Mike Lord 1982
  10 FOR m=0.1 TO 10 STEP 0.1
  20 REM CLS : GO SUB 100
  30 PRINT AT 0,0;: LOAD "som"+STR$ m+".scr"SCREEN$
  40 PAUSE 1: NEXT m
  50 FOR m=99 TO 1 STEP -1
  60 PRINT AT 0,0;: LOAD "som"+STR$ (m/10)+".scr"SCREEN$
  70 PAUSE 1: NEXT m
  80 GO TO 10
