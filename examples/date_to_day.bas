   10 REM convert date to day 
   20 DIM d$(7,6): REM days of week 
   30 FOR n = 1 TO 7: READ d$(n): NEXT n 
   40 DIM m(12): REM lengths of months 
   50 FOR n = 1 TO 12: READ m(n): NEXT n 
  100 REM input date 
  110 INPUT "day? "; day 
  120 INPUT "month? "; month 
  130 INPUT "year (20th century only)? "; year 
  140 IF year < 1901 THEN PRINT "20th century starts at 1901": GOTO 100
  150 IF YEAR > 2000 THEN PRINT "20th century ends at 2000": GOTO 100 
  160 IF month < 1 THEN GOTO 210
  170 IF MONTH > 12 THEN GOTO 210 
  180 IF year / 4 - INT(year / 4) = 0 THEN LET m(2) = 29: REM leap year 
  190 IF day > m(month) THEN PRINT "This month has only "; m(month); " days.": GOTO 500 
  200 IF day > 0 THEN GOTO 300 
  210 PRINT "Stuff and nonsense. Give me a real date." 
  220 GOTO 500 
  300 REM convert date to number of days since start of century 
  310 LET y = year - 1901 
  320 LET b = 365 * y + INT (y / 4): REM number of days to start of year 
  330 FOR n = 1 TO month -1: REM add on previous months 
  340 LET b = b + m(n): NEXT n 
  350 LET b = b + day 
  400 REM convert to day of week
  410 LET b = b - 7 * INT (b / 7) + 1 
  420 PRINT day; "/"; month; "/"; year 
  430 FOR n = 6 TO 3 STEP -1: REM remove trailing spaces 
  440 IF d$(b,n) <> " " THEN GOTO 460 
  450 NEXT n
  460 LET e$ = d$(b, TO n)
  470 PRINT " is a "; e$; "day"
  500 LET m(2) = 28: REM restore February
  510 INPUT "again? "; a$
  520 IF a$ = "n" THEN GOTO 540
  530 IF a$ <> "N" THEN GOTO 100
 1000 REM days of week
 1010 DATA "Mon", "Tues", "Wednes"
 1020 DATA "Thurs", "Fri", "Satur", "Sun"
 1100 REM lengths of months
 1110 DATA 31, 28, 31, 30, 31, 30
 1120 DATA 31, 31, 30, 31, 30, 31