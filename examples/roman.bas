  10 REM Converts arabic to roman
  20 REM By Mike Lord MCMLXXXII
 100 DIM r(9)
 110 DATA 1000,500,100,50,10,5,1,0,0
 120 FOR X=1 TO 9: READ r(x): NEXT x
 130 LET r$="MDCLXVI"
 132 LET a=1982: GO TO 210
 200 INPUT "Number (0 to stop) ";a
 210 IF a=0 THEN GO TO 999
 220 PRINT : PRINT a;" = ";
 230 FOR x=1 TO 7
 240 IF a>=r(x) THEN PRINT r$(x);: LET a=a-r(x): GO TO 240
 250 LET y=1+2*INT ((x+1)/2)
 260 IF a>=r(x)-r(y) THEN PRINT r$(y);: LET a=a+r(y): GO TO 240
 270 NEXT x
 300 GO TO 200
 999 REM END
