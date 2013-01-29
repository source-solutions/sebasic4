Auto 0

# Run-time Variables

Var f: Num = 2
Var a$: Str = "matty"
Var b$: Str = "attymay"

# End Run-time Variables

  10 PRINT "PIG LATIN"
  20 INPUT "Give me a word: ";a$
  30 LET F=1
  40 IF A$(F)<>"a" AND a$(f)<>"A" AND a$(f)<>"e" AND a$(f)<>"E" AND a$(f)<>"i" AND a$(f)<>"I" AND a$(f)<>"o" AND a$(f)<>"O" AND a$(f)<>"u" AND a$(f)<>"U" THEN LET f=f+1: GO TO 40
  50 LET b$=a$(F TO )+a$( TO F-1)+"ay"
  60 PRINT 'a$;"=";b$
  70 GO TO 20
