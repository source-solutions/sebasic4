Auto 1

# Run-time Variables

Var c: Num = 3000
Var i: NumFOR = 11, 10, 1, 20, 2
Var a$: Str = "Polygon"

# End Run-time Variables

  10 CLS
  20 FOR i=1 TO 10
  30 READ a$,c
  40 PRINT a$
  50 PLOT 128,13
  60 DRAW 0,150,c
  70 PRINT AT 21,0;"Press any key":\
     PAUSE 0
  80 CLS
  90 NEXT i
 100 DATA "arc",3.1415926
 110 DATA "Hexagon",260
 120 DATA "Square I",405
 130 DATA "Square II",436
 140 DATA "Triangle",481
 150 DATA "Sunburst",801
 160 DATA "Disc",808
 170 DATA "Spikes",813
 180 DATA "Star",951
 190 DATA "Polygon",3000
