Auto 0
  10 REM     Mazerunner                    \* Raymond Blake
  50 GO SUB 9000
 200 LET i$=INKEY$
 210 IF i$<>"" THEN GO SUB 1000
 220 LET x=x+x1:\
     LET y=y+y1
 230 IF POINT (x,y)=1 THEN GO TO 5000
 240 PLOT x,y
 250 IF x=255 THEN GO TO 4000
 260 LET s=s+1
 390 GO TO 200
1000 IF (i$="p" OR i$="o") AND x1<>0 THEN RETURN
1020 IF (i$="a" OR i$="q") AND y1<>0 THEN RETURN
1100 LET x1=(i$="p")-(i$="o")
1120 LET y1=(i$="a")-(i$="q")
1500 RETURN
4000 FOR i=0 TO 30:\
     BEEP .01,i:\
     BEEP .01,i-2:\
     BEEP .01,i+2:\
     NEXT i
4010 LET s=s+5000
4100 PRINT #0;AT 1,2;"Well done - you have escaped"
4950 GO TO 600
5000 FOR i=30 TO 0 STEP -1:\
     BEEP .01,i:\
     BEEP .01,i+2:\
     BEEP .01,i-2:\
     NEXT i
5100 PRINT #0;AT 1,4;"Unlucky - you hit a wall"
6000 PAUSE 1:\
     PAUSE 120
6100 INPUT ""
6120 PRINT #0;AT 1,7;"Your score is ";s
6300 BEEP .5,0:\
     BEEP .5,25
6500 PAUSE 1:\
     PAUSE 400
6950 RUN
9000 RESTORE 9020:\
     FOR i=USR "a" TO USR "f"+7:\
     READ a:\
     POKE i,a:\
     NEXT i
9020 DATA 255,a,192,a,a,a,195,a,255,a,3,a,a,a,195,a
9030 DATA 195,a,192,a,a,a,255,a,195,a,3,a,a,a,255,a
9040 DATA 195,a,a,a,a,a,a,a,255,a,0,a,a,a,255,a
9100 BORDER 1:\
     PAPER 7:\
     INK 1:\
     CLS
9150 FOR i=1 TO 3:\
     PRINT "\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::":\
     NEXT i
9155 PRINT "\::\a\f\f\f\f\f\f\b\a\b\a\f\f\f\f\f\f\f\f\f\f\b\a\f\f\f\f\f\f\b\::"
9160 PRINT "\::\e\a\f\f\f\f\b\e\e\e\e\a\f\f\f\f\f\f\b\a\f\d\e\a\f\f\f\f\b\e\::"
9165 PRINT "\::\e\c\f\f\f\b\e\e\e\e\e\e\a\f\f\f\f\b\e\c\f\b\e\c\f\f\f\b\e\e\::"
9170 PRINT "\::\e\a\f\f\b\e\e\e\e\e\e\e\e\a\f\f\b\e\e\a\f\d\c\f\f\f\b\e\c\d\::"
9175 PRINT "\::\e\e\a\b\e\e\e\e\e\e\e\e\e\e\a\b\e\e\e\c\f\f\f\f\f\b\e\c\f\b\::"
9180 PRINT "\::\e\c\d\e\c\d\c\d\e\e\e\e\e\c\d\e\e\e\e\a\f\f\f\f\f\d\c\f\b\e\::"
9185 PRINT "\::\e\a\b\c\f\f\f\f\d\e\e\e\c\f\f\d\e\e\e\c\f\f\f\f\f\f\f\f\d\e\::"
9190 PRINT "\::\e\e\c\f\f\f\f\f\f\d\e\c\f\f\f\f\d\e\e\a\f\f\f\f\b\a\b\a\b\e\::"
9195 PRINT "\::\e\e\a\b\a\b\a\b\a\b\c\b\a\f\f\f\f\d\e\c\f\f\f\b\c\d\c\d\c\d\::"
9200 PRINT "\::\e\e\e\c\d\c\d\c\d\c\b\e\e\a\b\a\f\b\e\a\f\f\f\d\a\f\f\f\f\b\::"
9205 PRINT "\::\e\e\c\f\f\f\f\f\f\b\e\e\e\e\e\e\a\d\e\c\f\f\f\f\d\a\f\f\f\d\::"
9210 PRINT "\::\e\c\f\f\f\f\f\f\f\d\e\e\c\d\c\d\c\b\e\a\f\f\f\f\b\e\a\f\f\b\::"
9215 PRINT "\::\e\a\f\f\f\f\f\f\f\b\e\c\f\f\f\f\b\e\e\e\a\b\a\b\e\e\c\f\b\e\::"
9220 PRINT "\::\e\c\f\f\b\a\f\f\b\e\e\a\f\f\f\f\d\e\e\e\e\e\e\e\e\c\f\f\d\e\::"
9225 PRINT "\::\e\a\f\f\d\e\a\f\d\e\e\e\a\f\f\f\f\d\e\e\e\e\e\e\c\f\f\f\f\d\::"
9230 PRINT "\::\e\c\f\f\b\e\c\f\f\d\e\e\c\f\f\f\f\b\e\e\e\e\e\c\f\f\f\f\f\b\::"
9235 PRINT "\::\e\a\f\f\d\c\f\f\f\f\d\c\f\f\f\f\f\d\e\e\e\e\c\f\f\b\a\f\f\d\::"
9240 PRINT "\::\e\c\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\d\c\d\c\f\f\f\d\c\f\f\f\f"
9245 PRINT "\::\e\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::\::"
9260 PRINT AT 1,1;"MAZERUNNER     \* Raymond Blake"
9280 PRINT INVERSE 1;AT 21,0;"^";AT 21,2;"^";AT 19,31;">";AT 21,31;">"
9300 LET x=12:\
     LET y=0:\
     LET s=0
9320 LET x1=0:\
     LET y1=-1
9950 RETURN
