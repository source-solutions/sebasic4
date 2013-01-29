Auto 0

# Run-time Variables

Var ox: Num = 127.959329485893
Var oy: Num = 1.99450418073684
Var pt: Num = 3
Var nx: Num = 127.959329485893
Var ny: Num = 1.99450418073684
Var x: NumArray(3) = 127, 0, 255
Var y: NumArray(3) = 0, 175, 175
Var f: NumFOR = 4, 3, 1, 20, 2

# End Run-time Variables

   5 REM Sierpinski's Triangle
  10 DIM x(3):\
     DIM y(3)
  20 FOR f=1 TO 3:\
     READ x(f),y(f):\
     NEXT f
  30 DATA 127,0,0,175,255,175
  40 LET ox=x(1):\
     LET oy=y(1)
  50 LET pt=INT (RND *3)+1
  60 LET nx=x(pt):\
     LET ny=y(pt)
  70 LET nx=((nx-ox)/2)+ox:\
     LET ny=((ny-oy)/2)+oy
  80 PLOT nx,ny
  90 LET ox=nx:\
     LET oy=ny
 100 GO TO 50
