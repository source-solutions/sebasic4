
# Run-time Variables

Var a: Num = 54
Var x: Num = 10
Var y: Num = 10
Var f: NumFOR = 8, 7, 1, 10, 2

# End Run-time Variables

  10 FOR f=0 TO 7:\
     READ a:\
     POKE USR "a"+f,a:\
     NEXT f
  20 DATA BIN 00000000, BIN 00110000, BIN 00110000, BIN 00011111, BIN 00011111, BIN 00010011, BIN 00010010, BIN 00110110
  30 LET x=10
  40 LET y=10
  50 PRINT AT y,x;"\a"
  60 IF INKEY$ ="p" THEN PRINT AT y,x;" ":\
     LET x=x+1
  70 IF INKEY$ ="o" THEN PRINT AT y,x;" ":\
     LET x=x-1
  80 GO TO 50
