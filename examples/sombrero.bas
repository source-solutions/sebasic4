   5 REM Sombrero by Mike Lord 1982
 100 FOR x=40 TO 215
 110 LET b=999: LET t=0
 120 FOR y=16 TO 144 STEP 4
 130 LET r=SQR ((x-127)*(x-127)+(y-80)*(y-80))/15
 140 LET z=INT (y+90*EXP (-r/3)*COS r)
 150 IF z<b OR z>t THEN PLOT x,z
 160 IF z<b THEN LET b=z
 170 IF z>t THEN LET t=z
 180 NEXT y
 190 NEXT x
