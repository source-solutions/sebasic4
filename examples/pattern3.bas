Auto 1

# Run-time Variables

Var a: Num = 255
Var b: Num = 255.5
Var n: NumFOR = 11, 10, 1, 180, 2
Var f: NumFOR = 16, 15, 1, 160, 2

# End Run-time Variables

  10 LET A=0: LET b=128: FOR n=0 TO 7: POKE USR "a"+n,a: POKE USR "b"+n,b: POKE USR "c"+7-n,a: POKE USR "d"+7-n,b: LET a=a*2+1: LET b=b/2+128: NEXT n
  20 BORDER 3: PAPER 3: BRIGHT 1: CLS
  30 FOR f=0 TO 15: INK 7-f+8*INT (f/8): FOR n=0 TO 10: PRINT AT N*2,F*2; PAPER 7-N+8*INT (N/8);"\a\b"; AT N*2+1,F*2; PAPER 6-N+8*INT ((N+1)/8);"\c\d";: NEXT n: NEXT f
