Auto 0

# Run-time Variables

Var n: Num = 11
Var x: NumArray(11) = 29520, 38900, 8467, 8174, 23216, 19615, 34887, 49207, 28854, 14526, 62719
Var y: NumArray(11) = 4198, 3903, 21690, 44168, 133, 133, 42120, 22970, 3135, 4454, 0
Var j: NumFOR = 12, 11, 1, 70, 2
Var k: NumFOR = 11, 10, 1, 140, 2
Var m: NumFOR = 12, 11, 1, 150, 2

# End Run-time Variables

  10 REM Graphs
  20 REM COPYRIGHT TALENT COMPUTER SYSTEMS 1983
  30 DEF FN x(q)=128+127*SIN (q*2*PI /n)
  40 DEF FN y(q)=88+87*COS (q*2*PI /n)
  50 INPUT "Number of points:";n
  60 DIM x(n):\
     DIM y(n)
  70 FOR j=1 TO n
  80 LET x(j)=FN x(j)
  90 LET y(j)=FN y(j)
 100 NEXT j
 110 CLS
 120 PAPER 7
 130 INK 0
 140 FOR k=1 TO n-1
 150 FOR m=k+1 TO n
 160 PLOT x(k),y(k)
 170 DRAW x(m)-x(k),y(m)-y(k)
 180 NEXT m
 190 NEXT k
