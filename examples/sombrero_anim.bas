Auto 0

# Run-time Variables

Var b: Num = -37
Var t: Num = 0
Var r: Num = 7.855642
Var z: Num = -19
Var miny: Num = 2
Var maxy: Num = 174
Var m: NumFOR = 2.5, 10, 0.1, 10, 2
Var x: NumFOR = 68, 255, 1, 100, 2
Var y: NumFOR = -22, 202, 4, 120, 2

# End Run-time Variables

   1 REM fast
   5 REM Sombrero by Mike Lord 1982
  10 FOR m=0.1 TO 10 STEP 0.1
  20 CLS : GO SUB 100
  30 SAVE "som"+STR$ m+".scr"SCREEN$
  40 NEXT m
  50 STOP
 100 FOR x=0 TO 255
 110 LET b=999: LET t=0
 120 FOR y=-38 TO 202 STEP 4
 130 LET r=SQR ((x-127)*(x-127)+(y-80)*(y-80))/15
 140 LET z=INT (y+90*EXP (-r/m)*SIN r)
 150 IF Z>=0 THEN IF Z<175 THEN IF z<b OR z>t THEN PLOT x,z
 160 IF z<b THEN LET b=z
 170 IF z>t THEN LET t=z
 180 NEXT y
 190 NEXT x
 200 RETURN
