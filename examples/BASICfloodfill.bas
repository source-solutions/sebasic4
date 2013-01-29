Auto 0

# Run-time Variables

Var x: Num = 98
Var y: Num = 88

# End Run-time Variables

  10 CIRCLE 128,88,40:\
     CIRCLE 128,88,30
  20 LET x=100:\
     LET y=100
  30 GO SUB 1000:\
     STOP
1000 PLOT x,y
1010 IF NOT POINT (x+1,y) THEN LET x=x+1:\
     GO SUB 1000:\
     LET x=x-1
1020 IF NOT POINT (x-1,y) THEN LET x=x-1:\
     GO SUB 1000:\
     LET x=x+1
1030 IF NOT POINT (x,y+1) THEN LET y=y+1:\
     GO SUB 1000:\
     LET y=y-1
1040 IF NOT POINT (x,y-1) THEN LET y=y-1:\
     GO SUB 1000:\
     LET y=y+1
1050 RETURN
