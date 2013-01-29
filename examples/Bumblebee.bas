Auto 1

# Run-time Variables

Var x: Num = 16
Var a: Num = 0
Var d: Num = -1

# End Run-time Variables

  10 LET x=0: LET a=11: LET d=1: GO SUB 20: STOP
  20 IF a=0 THEN LET x=x+d: BEEP .03,x: RETURN
  30 LET a=a-1: GO SUB 20: GO SUB 40: LET a=a+1: RETURN
  40 IF a=0 THEN LET x=x+d: BEEP .03,x: RETURN
  50 LET a=a-1: LET d=-d: GO SUB 20
  60 LET d=-d: GO SUB 40: LET a=a+1: RETURN
