   10 INPUT "yards?", yd, "feet?", ft, "inches?", in
   40 GOSUB 2000: REM print the values
   50 PRINT " = ";
   70 GOSUB 1000: REM the adjustment
   80 GOSUB 2000: REM print the adjusted values
   90 PRINT
  100 GOTO 10
 1000 REM subroutine to adjust yd, ft, in to the normal form for yards, feet and inches
 1010 LET in = 36 * yd + 12 * ft + in: REM now everything is in inches
 1030 LET s = SGN in: LET in = ABS in: REM we work with in positive, holding its sign in s
 1060 LET ft = INT (in / 12): LET in = (in - 12 * ft) * s: REM now in is ok
 1080 LET yd = INT (ft / 3) * s: LET ft = ft * s - 3 * yd: RETURN
 2000 REM subroutine to print yd, ft and in
 2010 PRINT yd; "yd "; ft; "ft "; in; "in ";: RETURN