Auto 0

# Run-time Variables

Var f: NumFOR = 22528, 7, 2, 10, 2
Var y: NumFOR = 22, 21, 1, 20, 2
Var x: NumFOR = 32, 31, 1, 20, 3
Var g: NumFOR = 22528, 22527, 1, 60, 2

# End Run-time Variables

  10 FOR f=0 TO 7 STEP 2:\
     POKE USR "a"+f,BIN 10101010:\
     POKE USR "a"+F+1,BIN 01010101:\
     NEXT f
  20 FOR y=0 TO 21:\
     FOR x=0 TO 31:\
     PRINT AT y,x;"\a":\
     NEXT x:\
     NEXT y
  30 PAUSE 0:\
     CLS
  40 LET f=16384
  50 FOR g=f TO f+255:\
     POKE g,85:\
     NEXT g
  60 FOR g=f+256 TO f+511:\
     POKE g,170:\
     NEXT g
  70 LET f=f+512
  80 IF f<22528 THEN GO TO 50
  90 PAUSE 0
