Auto 0

# Run-time Variables

Var b: Num = 18.75
Var t: Num = 77.25
Var r: Num = 5.2391687
Var z: Num = 80.25
Var alt: Num = 1
Var lx: Num = 51
Var ly: Num = 96
Var x: NumFOR = 51, 215, 1, 100, 2
Var y: NumFOR = 100, 144, 4, 120, 2

# End Run-time Variables

   1 REM fast
   5 REM Sombrero by Mike Lord 1982
 100 FOR x=40 TO 215
 110 LET b=999: LET t=0: LET alt=0
 120 FOR y=16 TO 144 STEP 4
 130 LET r=SQR ((x-127)*(x-127)+(y-80)*(y-80))/15
 140 LET z=INT (y+90*EXP (-r/3)*COS r)*0.75
 150 IF z<b OR z>t THEN PLOT x,z
 151 LET alt=1-alt: IF alt=0 THEN DRAW x-lx,y-ly
 152 LET lx=x: LET ly=y
 160 IF z<b THEN LET b=z
 170 IF z>t THEN LET t=z
 180 NEXT y
 190 NEXT x
