Auto 10

  10 CLS
  20 PRINT "Times Table Program"'"Press L to Learn"'"Or T to Test"
  30 LET a$=INKEY$ : IF a$<>"T" AND a$<>"t" AND a$<>"L" AND a$<>"l" THEN GO TO 30
  40 IF a$="T" OR a$="t" THEN GO TO 200
  50 IF a$="L" OR a$="l" THEN GO TO 100
  60 STOP
 100 CLS
 110 PRINT "Times Table Learner": PRINT : FOR f=1 TO 12: PRINT f: NEXT f: PRINT '"Select a Times Table"
 120 INPUT "Type it's Number: ";A: IF a<1 OR a>12 THEN GO TO 120
 130 CLS : PRINT "This is the ";a;" Times Table:"
 140 FOR f=1 TO 12: PRINT f;"=";"x";a;"=";f*a: NEXT f
 150 PRINT '"Press any key to restart Program"
 160 PAUSE 0: GO TO 10
 200 CLS : RANDOMIZE
 210 PRINT "Select the Times Table"'"You want to be tested on"
 220 INPUT "Type it's Number: ";a: IF a<1 OR a>12 THEN GO TO 220
 230 CLS
 240 PRINT a;" Times Table Tester"''"Press any key to begin"
 250 PAUSE 0: LET Correct=0
 260 FOR Q=0 TO 11
 270 LET b=INT (RND *12)+1
 280 CLS : PRINT b;"x";a;"=?"
 290 INPUT c
 300 IF c>a*b THEN GO TO 400
 310 IF c<a*b THEN GO TO 500
 320 CLS : PRINT "Well Done!"''b;"x";a;"=";a*b: LET Correct=Correct+1: PAUSE 150
 330 NEXT Q
 340 CLS
 350 PRINT "End of Test"''"You Scored ";correct;"/12"''"Press any key to restart program"
 360 PAUSE 0: RUN
 400 CLS : PRINT "Answer too Big"'"Correct Answer: "'b;"x";a;"=";b*a''"LEARN IT"''"Press any key to continue": PAUSE 0: GO TO 330
 500 CLS : PRINT "Answer too Small"'"Correct Answer: "'b;"x";a;"=";b*a''"LEARN IT"''"Press any key to continue": PAUSE 0: GO TO 330
