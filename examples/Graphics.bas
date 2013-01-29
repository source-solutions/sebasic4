Auto 0

# Run-time Variables

Var c: Num = 5
Var dx: Num = 16
Var x1: Num = 16
Var g: NumFOR = 0, 1, 1, 1710, 5
Var k: NumFOR = 4, 15, 1, 1720, 2
Var n: NumFOR = 1, 1, 1, 1720, 3
Var x: NumFOR = 3, 15, 1, 1720, 4

# End Run-time Variables

  50 REM rainbow
 100 BORDER 0:\
     INK 7:\
     PAPER 0:\
     RESTORE 1000:\
     FOR m=0 TO 7
 110 READ a,b,c:\
     FOR n=0 TO 11*(m<7):\
     PLOT PAPER b; INK c; INVERSE a;0,n+12*m:\
     DRAW PAPER b; INK c; INVERSE a;255,0,-1.5:\
     IF ABS ((m/2)-INT (m/2))>.1 THEN LET n=n+7
 120 NEXT n:\
     NEXT m
 130 PAPER 0:\
     INK 7:\
     INVERSE 0
 140 STOP
1000 DATA 0,0,2,1,6,2,0,6,4,1,5,4,0,5,1,1,3,1,0,3,0,1,0,0
1700 REM interference
1705 BORDER 0:\
     INK 7:\
     PAPER 0:\
     BRIGHT 1:\
     CLS :\
     OVER 1
1710 LET dx=8*2^(1+INT (RND *3)):\
     LET x1=256/dx:\
     LET c=5+INT (RND *2):\
     FOR g=0 TO 1:\
     INK c:\
     IF G THEN INK 8-C
1720 FOR k=0 TO x1-1:\
     FOR n=0 TO 1:\
     FOR x=0 TO dx-1:\
     PLOT dx*k,175*n:\
     DRAW x,175-350*n:\
     PLOT dx*(k+1)-1, 175*N:\
     DRAW -x, 175-350*N:\
     NEXT x:\
     NEXT n:\
     NEXT k
1730 NEXT g:\
     GO TO 1700
