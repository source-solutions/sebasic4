  10 PRINT TAB 10;"Calendar"
  20 LET m$="JanFebMarAprMayJunJulAugSepOctNovDec"
  30 LET n$="312831303130313130313031"
  40 INPUT "Year (>1752) ";y: IF y<1753 THEN GO TO 40
  50 INPUT "Month (1-12) ";m: IF m<1 OR m>12 THEN GO TO 50
  60 PRINT AT 4,8;m$(3*m-2 TO 3*m);TAB 18;y
  70 PRINT AT 7,2;"Mon Tue Wed Thu Fri Sat Sun"''
  80 IF y=4*INT (y/4) AND (y<>100*INT (y/100) OR y=400*INT (y/400)) THEN LET n$(3 TO 4)="29"
  90 LET d=5+y+INT ((y-1)/4)-INT ((y-1)/100)+INT ((y-1)/400)
 100 FOR a=1 TO m-1: LET d=d+VAL n$(2*a-1 TO 2*a): NEXT a
 110 FOR a=1 TO VAL n$(2*m-1 TO 2*m)
 120 LET p=2+4*(a+d-7*INT ((a+d)/7))
 130 PRINT TAB p;a;
 140 NEXT a
