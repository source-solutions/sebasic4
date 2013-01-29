Auto 10

# Run-time Variables

Var b: Num = 0
Var x: Num = 26
Var shipx: Num = 14
Var score: Num = 0
Var a: NumFOR = 24, 23, 1, 10, 2
Var f: NumFOR = 32, 31, 1, 30, 3
Var b$: Str = "\#000\#001\#002\#003\#004\#005\#006\#007\#008\#009\#010\#011\#012\#013\#014\#015\#016\#017\#018\#019\#020\#021\#025\#026\#027\#028\#029\#030\#031"
Var a$: Str = "\#000\#001\#002\#003\#004\#005\#006\#007\#008\#009\#010\#011\#012\#013\#014\#016\#017\#018\#019\#020\#021\#025\#027\#028\#029\#030\#031"

# End Run-time Variables

  10 FOR a=0 TO 23:\
     READ b:\
     POKE USR "a"+a,b:\
     NEXT a:\
     DATA 36,189,255,165,165,189,189,24,0,0,0,16,0,0,0,0,0,0,0,24,24,0,0,0
  20 BORDER 1:\
     PAPER 0:\
     INK 7:\
     CLS
  25 LET shipx=15:\
     LET score=0
  30 LET a$="":\
     FOR f=0 TO 31:\
     LET a$=a$+CHR$ f:\
     NEXT f:\
     LET b$=a$
  40 LET x=INT (RND *LEN (a$))+1:\
     PRINT AT 21,CODE (a$(x)); INK 2;"\b":\
     LET a$=a$( TO x-1)+a$(x+1 TO )
  50 LET x=INT (RND *LEN (a$))+1:\
     PRINT AT 21,CODE (a$(x)); INK 2;"\c":\
     LET a$=a$( TO x-1)+a$(x+1 TO )
  60 POKE 23692,-1:\
     PRINT
  65 PRINT AT 0,shipx; INK 5;"\a"
  70 PAUSE 3
  80 IF a$="" THEN LET a$=b$
  90 LET shipx=shipx+((INKEY$ ="p") AND shipx<31)-((INKEY$ ="o") AND shipx>0)
 100 GO TO 40
