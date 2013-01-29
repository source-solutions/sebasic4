Auto 1

# Run-time Variables

Var a: Num = 0
Var x: Num = 2
Var y: Num = 2

# End Run-time Variables

   1 REM Fractal posted to CSS by Matthew Westcott
  10 BORDER 0: PAPER 0: INK 5: BRIGHT 1: CLS : PLOT 180,60: LET a=12: LET x=2: LET y=2: GO SUB 20: STOP
  20 IF a=0 THEN DRAW x,0: RETURN
  30 LET a=a-1: GO SUB 20: GO SUB 40: LET a=a+1: RETURN
  40 IF a=0 THEN DRAW 0,y: RETURN
  50 LET a=a-1: LET y=-y: LET x=-x: GO SUB 20: LET y=-y: LET x=-x: GO SUB 40: LET a=a+1: RETURN
