Auto 1

# Run-time Variables

Var a: Num = 95
Var x: Num = 28.6013031
Var y: Num = 4.1323
Var ik: Num = 6
Var ppr: Num = 7
Var brt: Num = 1
Var f: NumFOR = 65384, 65383, 1, 30, 2

# End Run-time Variables

  10 REM fast
  20 BORDER 0:\
     PAPER 0:\
     INK 5:\
     BRIGHT 1:\
     CLS
  30 FOR f=USR "a" TO USR "b"+7:\
     READ a:\
     POKE f,a:\
     NEXT f
  40 DATA 175,95,175,95,250,245,250,245
  50 DATA 250,245,250,245,175,95,175,95
  60 LET x=RND*31:\
     LET y=RND*21
  70 LET ik=INT (RND*8):\
     LET ppr=INT (RND*8):\
     LET brt=INT (RND*2):\
     IF ik=ppr THEN GO TO 70
  80 INK ik:\
     PAPER ppr:\
     BRIGHT brt
  90 PRINT AT y,x;"\a";AT y,31-x;"\b";AT 21-y,x;"\b";AT 21-y,31-x;"\a"
 100 GO TO 60
