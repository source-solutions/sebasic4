    5 RANDOMIZE 
   10 FOR m = 1 TO 6: REM for 6 throws 
   20 LET c = 0: REM initialize coin total to 0 
   30 FOR n = 1 TO 3: REM for 3 coins 
   40 LET c = c + 2 + INT (2 * RND) 
   50 NEXT n
   60 PRINT " "; 
   70 FOR n = 1 TO 2: REM 1st for the thrown hexagram, 2nd for the changes 
   80 PRINT "___";
   90 IF c = 7 THEN PRINT " "; 
  100 IF c = 8 THEN PRINT " "; 
  110 IF c = 6 THEN PRINT "X";: LET c = 7 
  120 IF c = 9 THEN PRINT "0";: LET c = 8
  130 PRINT "___ ";
  140 NEXT n
  150 PRINT
  160 INPUT a$
  170 NEXT m