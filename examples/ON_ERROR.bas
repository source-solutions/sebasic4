   10 ON ERROR GOTO 100
   20 INPUT "Enter a number: "; a
   30 PRINT "You entered: "; a
   40 ON ERROR CONTINUE
   50 PRINT b
   60 ON ERROR STOP
   70 PRINT b
  100 CLS: PRINT "Thats not a number!"
  110 GOTO 20