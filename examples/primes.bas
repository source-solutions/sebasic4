   1 REM PRIME NUMBERS
   2 REM by Mike Lord 1982
  10 LET t=1
  20 FOR a=0 TO 79
  30 LET t=t+2
  40 FOR f=3 TO SQR t STEP 2
  50 IF t=f*INT (t/f) THEN GO TO 30
  60 NEXT f
  70 PRINT TAB 8*a;t;
  80 NEXT a
