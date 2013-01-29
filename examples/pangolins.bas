   5 REM pangolins
  10 LET nq=100: REM number of questions and aimals
  15 DIM q$(nq,50): DIM a(nq,2): DIM r$(1)
  20 LET qf=8
  30 FOR n=1 TO qf/2-1
  40 READ q$(n): READ a(n,1): READ a(n,2)
  50 NEXT n
  60 FOR n=n TO qf-1
  70 READ q$(n): NEXT n
 100 REM Start playing
 110 PRINT "Think of an animal.","Press any key to continue."
 120 PAUSE 0
 130 LET c=1: REM start with 1st question
 140 IF a(c,1)=0 THEN GO TO 300
 150 LET p$=q$(c): GO SUB 910
 160 PRINT "?": GO SUB 1000
 170 LET VIN=1: IF r$="y" THEN GO TO 210
 180 IF r$="Y" THEN GO TO 210
 190 LET VIN=2: IF r$="n" THEN GO TO 210
 200 IF r$<>"N" THEN GO TO 150
 210 LET c=a(c,VIN): GO TO 140
 300 REM animal
 310 PRINT "Are you thinking of"
 320 LET p$=q$(c): GO SUB 900: PRINT "?"
 330 GO SUB 1000
 340 IF r$="y" THEN GO TO 400
 350 IF r$="Y" THEN GO TO 400
 360 IF r$="n" THEN GO TO 500
 370 IF r$="N" THEN GO TO 500
 380 PRINT "Answer me properly when I'm","talking to you.": GO TO 300
 400 REM guessed it
 410 PRINT "I thought as much": GO TO 800
 500 REM new animal
 510 IF qf>nq-1 THEN PRINT "I'm sure your animal is very","interesting, but I don't have","room for it just now.": GO TO 800
 520 LET q$(qf)=q$(c): REM move old animal
 530 PRINT "What is it then?": INPUT q$(qf+1)
 540 PRINT "Tell me a question that dist-","inguishes between "
 550 LET p$=q$(qf): GO SUB 900: PRINT " and"
 560 LET p$=q$(qf+1): GO SUB 900: PRINT " "
 570 INPUT s$: LET b=LEN s$
 580 IF s$(b)="?" THEN LET b=b-1
 590 LET q$(c)=s$( TO b): REM insert question
 600 PRINT "What is the answer for"
 610 LET p$=q$(qf+1): GO SUB 900: PRINT "?"
 620 GO SUB 1000
 630 LET VIN=1: LET io=2: REM answer for new and old animals
 640 IF r$="y" THEN GO TO 700
 650 IF r$="Y" THEN GO TO 700
 660 LET VIN=2: LET io=1
 670 IF r$="n" THEN GO TO 700
 680 IF r$="N" THEN GO TO 700
 690 PRINT "That's no good": GO TO 600
 700 REM update answers
 710 LET a(c,VIN)=qf+1: LET a(c,io)=qf
 720 LET qf=qf+2: REM next free animal space
 730 PRINT "That fooled me."
 800 REM again?
 810 PRINT "Do you want another go?": GO SUB 1000
 820 IF r$="y" THEN GO TO 100
 830 IF r$="Y" THEN GO TO 100
 840 STOP
 900 REM print without trailing spaces
 905 PRINT " ";
 910 FOR n=50 TO 1 STEP -1
 920 IF p$(n)<>" " THEN GO TO 940
 930 NEXT n
 940 PRINT p$( TO n);: RETURN
1000 REM get reply
1010 INPUT r$: IF r$="" THEN RETURN
1020 LET r$=r$(1): RETURN
2000 REM initial animals
2010 DATA "Does it live in the sea",4,2
2020 DATA "Is it scaly",3,5
2030 DATA "Does it eat ants",6,7
2040 DATA "a whale","a blancmange","a pangolin","an ant"
