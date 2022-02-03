100 CLS : KEY OFF
110 LOCATE 10, 1 : X$ = "Voyage to Neptune, 2100" : GOSUB 1680
120 LOCATE 13, 1 : X$ = "(c) by David H. Ahl, 1986" : GOSUB 1680
130 LOCATE 23, 1 : GOSUB 1550
140 WHILE RN > 32767 : RN = RN - 65535! : WEND : RANDOMIZE RN : CLS
150 GOSUB 1180 : 'Display initial scenario
160 BREED = 120 : FUTOT = 3000 : GOSUB 1420 : 'Set initial values
170 '
180 'Loop through trip segments
190 SEG = SEG + 1 : 'Trip segment counter
200 IF SEG = 7 THEN 940 : 'Reach Neptune?
210 '
220 'Print current conditions
230 PRINT : PRINT "Current conditions are as follows:"
240 PRINT " Location :" PLAN$(SEG)
250 PRINT " Distance to Neptune:" 2701-DIST "million miles."
260 IF SEG = 1 THEN 350 : 'First trip segment?
270 PRINT " Distance from Earth:" DIST "million miles."
280 PRINT "Over the last segment, your average speed was" INT(RATE) "mph,"
290 PRINT " and you covered" DIS(SEG - 1) "million miles in" TIME "days."
300 TM = .81 * DIST : PRINT "Time est for this total distance:"; : GOSUB 1460
310 TM = TOTIME : PRINT "Your actual cumulative time was:"; : GOSUB 1460
320 PRINT "You used" UBREED "cells which produced" FUBR "pounds of fuel each."
330 IF FUDCY = 0 THEN 350
340 PRINT FUDCY "pounds of fuel in storage decayed into an unusable state."
350 PRINT "Pounds of of nuclear fuel ready for use:" FUTOT
360 PRINT "Operational breeder-reactor cells:" BREED : PRINT
370 '
380 'Trade fuel for breeder-reactor cells
390 TRADE = INT(150 + 80 * RND(1)) : IF SEG > 1 THEN 420
400 PRINT "Before leaving, you can trade fuel for breeder-reactor cells at"
410 GOTO 430
420 PRINT "Here at " PLAN$(SEG) ", breeder cells and nuclear-fuel trade at"
430 PRINT "the rate of" TRADE "pounds of fuel per cell." : PRINT
440 IF FUTOT - TRADE < 1501 THEN PRINT "You have too little fuel to trade." : GOTO 500
450 INPUT " Would you like to procure more breeder cells (Y or N)";A$ : GOSUB 1590
460 IF A$< >"Y" THEN 500
470 INPUT "How many cells do you want";A
480 F = FUTOT - A * TRADE : IF F > 1500 THEN FUTOT = F : BREED = BREED + A : GOTO 570
490 PRINT "That doesn't leave enough fuel to run the engines." : GOTO 470
500 INPUT "Would you like to trade some breeder cells for fuel";A$ : GOSUB 1590
510 IF A$< >"Y" THEN 570
520 INPUT "How many cells would you like to trade";A
530 F = BREED - A : IF F > 49 THEN BREED = F : FUTOT = FUTOT + A * TRADE : GOTO 570
540 PRINT "That would leave only" F "cells. The reactor requires a minimum"

550 PRINT "of 50 cells to remain operational." : GOTO 520
560 '
570 'Engine power
580 PRINT "At this distance from the sun, your solar collectors can fulfill"
590 PRINT 56 - SEG * 8 "% of the fuel requirements of the engines. How many pounds"
600 INPUT "of nuclear fuel do you want to use on this segment";FUSEG
610 IF FUSEG <= FUTOT THEN FUTOT = FUTOT - FUSEG : GOTO 650 : 'Enough fuel?
620 PRINT "That's more fuel than you have. Now then, how many pounds" : GOTO 600
630 '
640 'Breeder reactor usage
650 INPUT "How many breeder-reactor cells do you want to operate";UBREED
660 IF UBREED > BREED THEN PRINT "You don't have that many cells." : GOTO 650
670 IF FUSEG / 20 >= UBREED THEN 700 : 'Enough spent fuel from engines?
680 PRINT "The spent fuel from your engines is only enough to operate" FUSEG / 20
690 PRINT " breeder reactor cells. Again please…" : GOTO 650
700 IF UBREED * 5 <= FUTOT THEN 730 : 'Enough new seed fuel?
710 PRINT "You have only enough fuel to seed" INT(FUTOT / 5) "breeder cells."
720 PRINT "Please adjust your number accordingly." : GOTO 650
730 FUTOT = FUTOT - 5 * UBREED
740 '
750 'Calculate the results of input data
760 EFF = 56 - SEG * 8 + FUSEG / 40 : IF EFF > 104 THEN EFF = 104 : 'Efficiency = 104% max
770 EF = RND(1) : IF EF < .1 THEN GOSUB 860 : '10% chance of engine problem
780 RATE = EFF * 513.89 : DIST = DIST + DIS(SEG) : 'Rate in mph, dist in million miles
790 TIME = INT(DIS(SEG) * 41667! / RATE) : 'Time in days
800 TOTIME = TOTIME + TIME : 'Total trip time
810 FUBR = INT(16 + 18 * RND(1)) : FUTOT = FUTOT + FUBR * UBREED : 'New fuel from breeder
820 FD = RND(1) : IF FD < .2 THEN FUDCY = INT(FD * FUTOT) : 'How much fuel decayed?
830 FUTOT = FUTOT - FUDCY : 'Decrease fuel by amount that decayed
840 GOTO 190
850 '
860 'Subroutine for engine problem
870 CLS : FOR J = 1 TO 7
880 BEEP : PRINT : X$ = "ENGINE MALFUNCTION !" : LOCATE 12, 1 : GOSUB 1680
890 FOR I = 1 TO 80 : NEXT I : CLS : FOR I = 1 TO 50 : NEXT I : NEXT J
900 PRINT "You will have to operate your engines at a" INT(300 * EF)"% reduction"
910 PRINT "in speed until you reach " PLAN$(SEG + 1) "." : PRINT
920 EFF = EFF * (1 - 3 * EF) : RETURN
930 '
940 'End of trip segment
950 PRINT : PRINT "You finally reached Neptune in"; : TM = TOTIME : GOSUB 1460
960 PRINT "Had your engines run at 100% efficiency the entire way, you would"
970 PRINT "have averaged 51, 389 mph and completed the trip in exactly 6 years."
980 IF TM > 2220 THEN 1000
990 PRINT : X$ = "Congratulations! Outstanding job!" : GOSUB 1680 : PRINT : GOTO 1070

1000 TM = TOTIME - 2190 : PRINT : PRINT "Your trip took longer than this by";
1010 GOSUB 1460 : PRINT "Your performance was"; : YR = YR + 1 : IF YR > 4 THEN YR = 4
1020 ON YR GOTO 1030, 1040, 1050, 1060
1030 PRINT "excellent (room for slight improvement)." : GOTO 1070
1040 PRINT "quite good (but could be better)." : GOTO 1070
1050 PRINT "marginal (could do much better)." : GOTO 1070
1060 PRINT "abysmal (need lots more practice)."
1070 PRINT : IF BREED < 105 THEN 1100
1080 PRINT "Fortunately you have" BREED "operational breeder-reactor cells"
1090 PRINT "for your return trip. Very good." : GOTO 1120
1100 PRINT "I guess you realize that the return trip will be extremely"
1110 PRINT "chancy with only" BREED "breeder-reactor cells operational."
1120 PRINT "With your remaining" FUTOT "pounds of fuel and" BREED "breeder"
1130 TM = 42250! / (8 + FUTOT / 40) : IF TM < 405 THEN TM = 405
1140 PRINT "cells, to get back to Theta 2 will take"; : GOSUB 1460
1150 PRINT : INPUT "Would you like to try again (Y or N)";A$
1160 GOSUB 1590 : IF A$ = "Y" THEN RUN ELSE CLS : KEY ON : PRINT "Bye!" : END
1170 '
1180 'Subroutine to print the scenario
1190 CLS : X$ = "Voyage to Neptune" : GOSUB 1680 : PRINT : PRINT
1200 PRINT " It is the Year 2100 and you are in command of the first manned"
1210 PRINT "spaceship to Neptune. Manned space stations have been established"
1220 PRINT "which orbit Callisto, Titan, and Ariel, as well as at two inter-"
1230 PRINT "mediate points between Saturn and Uranus, and Uranus and Neptune."
1240 PRINT "You must travel about 2700 million miles. At an average speed of"
1250 PRINT "over 50, 000 miles per hour, the entire trip should take about"
1260 PRINT "six years."
1270 PRINT " Your spaceship is a marvel of 21st century engineering. Since"
1280 PRINT "you may have to stop at space stations along the way, you will not"
1290 PRINT "be able to use the gravitational 'slingshot' effect of the planets."
1300 PRINT "However, your engines are highly efficient using both energy from"
1310 PRINT "the sun captured by giant parabolic arrays and nuclear fuel carried"
1320 PRINT "on board. You will not be able to carry enough fuel for the whole"
1330 PRINT "trip, so you also have a multi-celled nuclear breeder reactor"
1340 PRINT "(which takes spent fuel from your engines along with a small amount"
1350 PRINT "of primary fuel and turns it into a much greater amount of primary"
1360 PRINT "fuel)."
1370 PRINT " The space stations along the way usually have a small stock of"
1380 PRINT "engine repair parts, breeder-reactor cells, and nuclear fuel which"
1390 PRINT "are available to you on a barter basis." : GOSUB 1550 : RETURN
1400 '
1410 'Subroutine to read location names and distances
1420 FOR I = 1 TO 7 : READ PLAN$(I), DIS(I) : NEXT I : RETURN
1430 DATA "Earth", 391, "Callisto", 403, "Titan", 446, "Alpha 1", 447
1440 DATA "Ariel", 507, "Theta 2", 507, "Neptune", 0

1450 '
1460 'Subroutine to calculate and print time in years
1470 YR = INT(TM / 365) : IF YR < 1 THEN 1490
1480 IF YR = 1 THEN PRINT " 1 year"; ELSE PRINT YR "years";
1490 MO = INT((TM / 365 - YR) * 12) : IF MO < 1 THEN 1510
1500 IF MO = 1 THEN PRINT ", 1 month"; ELSE PRINT "," MO "months";
1510 DY = INT(TM - YR * 365 - MO * 30.5) : IF DY < 1 THEN PRINT "." : RETURN
1520 IF DY = 1 THEN PRINT ", 1 day." ELSE PRINT "," DY "days."
1530 RETURN
1540 '
1550 'Subroutine to temporarily break execution
1560 PRINT : X$ = "Press any key to continue." : GOSUB 1680
1570 WHILE LEN(INKEY$) = 0 : RN = RN + 1 : WEND : PRINT : PRINT : RETURN
1580 '
1590 'Subroutine to read yes/no answer
1600 GOSUB 1630 : IF A$ = "Y" OR A$ = "N" THEN RETURN
1610 INPUT "Don't understand your answer. Enter 'Y' or 'N' please";A$ : GOTO 1600
1620 '
1630 'Subroutine to extract the first letter of an input answer (in upper case)
1640 IF A$ = "" THEN A$ = "Y" : RETURN
1650 A$ = LEFT$(A$, 1) : IF A$ >= "A" AND A$ <= "Z" THEN RETURN
1660 A$ = CHR$(ASC(A$) - 32) : RETURN
1670 '
1680 'Subroutine to print centered lines
1690 PRINT TAB((70 - LEN(X$)) / 2) X$; : RETURN