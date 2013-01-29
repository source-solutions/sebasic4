Auto 0

# Run-time Variables

Var maxrand: Num = 10
Var rand: Num = 5
Var randomnumber: Num = 9
Var f: NumFOR = 11, 10, 1, 50, 2
Var z$: Str = "\#004\#005\#007\#008\#010"

# End Run-time Variables

   1 LET z$=""
   3 GO SUB 10
   4 PRINT randomnumber
   5 GO TO 3
  10 REM Random number
  20 LET MaxRand=10
  30 IF LEN (Z$)>0 THEN GO TO 60
  40 LET z$=""
  50 FOR F=1 TO MaxRand: LET Z$=Z$+CHR$ (F): NEXT F
  60 LET Rand=INT (RND *LEN (Z$)+1): LET RandomNumber=CODE (Z$(Rand)): LET Z$=Z$( TO Rand-1)+Z$(Rand+1 TO )
  70 RETURN
