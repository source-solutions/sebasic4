Auto 1

# Run-time Variables

Var x: NumFOR = 40, 39, 2, 60, 2
Var y: NumFOR = 10, 8, 2, 70, 2
Var a$: Str = "Hello"

# End Run-time Variables

  10 REM 4x4 Pixel magnifier
  20 CLS
  30 INPUT "Characters to render: "; LINE a$
  40 IF LEN (a$)>8 THEN PRINT AT 0,0;"Up to 8 Characters only!": PAUSE 0: CLS : GO TO 30
  50 PRINT AT 21,0; INK 7;a$
  60 FOR x=0 TO (LEN (a$)*8)-1 STEP 2
  70 FOR y=0 TO 8 STEP 2
  90 PRINT AT (8-y)/2,x/2;CHR$ (128+8*POINT (x,y)+4*POINT (x+1,y)+2*POINT (x,y+1)+POINT (x+1,y+1))
 100 NEXT y
 110 NEXT x
 120 PAUSE 0
 130 GO TO 20
