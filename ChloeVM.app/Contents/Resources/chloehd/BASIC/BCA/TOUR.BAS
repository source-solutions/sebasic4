100 CLS : KEY OFF
110 LOCATE 10, 1 : X$ = "Tour de France Bicycle Race" : GOSUB 3470
120 LOCATE 13, 1 : X$ = "(c) David H. Ahl, 1986" : GOSUB 3470
130 LOCATE 23, 1 : X$ = "Press any key to continue." : GOSUB 3470
140 WHILE LEN(INKEY$) = 0 : RN = RN + 1 : WEND
150 CLS : GOSUB 3500 : 'Display initial scenario
160 DIM PLACE$(23), TYPE(23), DIST(23), PP(14)
170 GDGR = 1 : PLACE$(0) = "Reims"
180 GOSUB 1430 : 'Read event probabilities
190 GOSUB 3050 : GOSUB 3300 : 'Read data about places
200 LOCATE 23, 1 : X$ = "Press any key to continue." : GOSUB 3470
210 WHILE LEN(INKEY$) = 0 : RN = RN + 1 : WEND
220 WHILE RN > 32767 : RN = RN - 65535! : WEND : RANDOMIZE RN : CLS
230 '
240 'Enter pre - race data
250 INPUT "Do you have the timing loop value from a previous run";A$
260 GOSUB 3350 : IF A$ = "N" THEN 290
270 INPUT "Please enter the value";PT : IF PT > 500 AND PT < 5000 THEN 300
280 INPUT "That doesn't sound right. Please enter it again";PT : GOTO 300
290 GOSUB 2820 : 'Calculate pedaling time (takes 20 seconds)
300 PRINT : PRINT "About your physical fitness: are you (1) in fantastic health,"
310 PRINT " (2) excellent shape, (3) quite good, (4) okay, (5) poor"
320 INPUT " Please enter a number between 1 and 5";A
330 IF A < 1 OR A > 5 THEN PRINT "Huh? I don't understand." : GOTO 320
340 FIT = .57 - .04 * A : 'Physical fitness factor
350 PRINT "How many weeks do you intend to take off from work or school to"
360 INPUT "practice and prepare for the race";WK : IF WK > 12 THEN WK = 12
370 IF WK > 5 THEN 390 ELSE PRINT "You must be joking. You'll need at least six"
380 PRINT "weeks if you want to be a real contender. Now…" : GOTO 350
390 FIT = FIT - (12 - WK) * .05 : 'Modify fitness factor for amount of practice
400 GOSUB 2760 : 'Assign keys to pedals
410 PRINT "Thank you. Let's go out for a practice run."
420 PFRQ = 10 : PTM = 1 : GOSUB 2890 : PD = 0 : PRINT : 'Pedal bicycle
430 PRINT "In an upper-middle gear ratio (52 / 17)," RPM "rpm would translate"
440 PRINT "to a speed of approximately" INT(.3956 * RPM + .5) "kilometers per hour."
450 IF RPM > 60 THEN 480 ELSE PRINT "That speed is barely competitive. Next time"
460 PRINT "you play, try a timing-loop value of" INT(80 * PT / RPM) "but for now"
470 PRINT "you may want to have the computer do most of the pedaling."
480 PRINT : PRINT "How much do you want to pedal your bike (on the keyboard)?"
490 PRINT "1 = hardly at all, 3 = occasionally, 7 = frequently, 10 = every opportunity"
500 INPUT "Please enter a number between 1 and 10";PFRQ : IF PFRQ < 1 THEN PFRQ = 1
510 IF PFRQ > 10 THEN PFRQ = 10
520 '
530 'Beginning of main riding section
540 DAY = DAY + 1
550 PRINT : PRINT "Date : July" DAY " You are at " PLACE$(DAY - 1) "."
560 IF TYPE(DAY) < 5 THEN 580
570 PRINT "Today, thank goodness, is a rest and recuperation day." : GOTO 540
580 PRINT "Your destination is " PLACE$(DAY) "," DIST(DAY) "km from here."
590 PRINT "Type of racing this stage:" TYPE$(TYPE(DAY))
600 IF TYPE(DAY)< >TYPE(DAY - 1) THEN 650
610 '
620 'Select gear range
630 INPUT "Do you want a different basic gear range than yesterday";A$
640 GOSUB 3350 : IF A$ = "N" THEN 850 ELSE GDGR = 1
650 PRINT "Naturally you will shift gears, but what will be your basic gear"
660 INPUT "range (ring and cog) for the day. First the ring (40 or 52)";RNG
670 IF RNG = 40 OR RNG = 52 THEN 690 ELSE PRINT "You don't have that ring."
680 INPUT "Enter 40 or 52 please"; RNG : GOTO 670
690 INPUT "Which cog (13, 15, 17, 19, 21, 23, or 25)"; CG
700 IF CG = 13 OR CG = 15 OR CG = 17 OR CG = 19 OR CG = 21 OR CG = 23 OR CG = 25 THEN 720
710 PRINT "Sorry, you don't have that cog. Please try again." : GOTO 690
720 IF (CG = 13 AND RNG = 40) OR (CG = 25 AND RNG = 52) THEN 730 ELSE GR = RNG / CG : GOTO 750
730 PRINT "The chain line will be badly skewed with that combination."
740 PRINT "Let's do it again. First the ring. "; : GOTO 680
750 IF TYPE(DAY) = 4 THEN 850
760 IF GR > 3.2 THEN X$ = "high" ELSE IF GR < 1.8 THEN X$ = "low" ELSE GOTO 790
770 PRINT "That ratio sounds very " X$; : INPUT ". Do you want to change it";A$
780 GOSUB 3350 : IF A$ = "Y" THEN 740
790 IF TYPE(DAY) = 3 AND GR > 2.3 THEN 800 ELSE 830
800 PRINT "For mountainous terrain, that's a rather high basic gear ratio."
810 INPUT "Do you want to stick with it";A$ : GOSUB 3350 : IF A$ = "N" THEN 740
820 GDGR = 1.3 - .19 * GR : GOTO 840 : 'Penalty for too high gear ratio in mts
830 IF GR > 3 THEN GDGR = 1.35 - .14 * GR : 'Penalty for too high gear on flat route
840 '
850 'Start of stage
860 TDEP = 100 + INT(59 * RND(1))
870 PRINT "Your departure time is scheduled at 9 : "; : PRINT RIGHT$(STR$(TDEP), 2)
880 GOSUB 3440 : PTM = 1 : RPS = 130 : GOSUB 2890 : KPH = RPM * .1292706 * GR * GDGR
890 PRINT USING "##.#"; KPH; : PRINT " kph." : PRINT
900 TDL = 0 : GOSUB 1510 : 'Road hazards
910 CR = 0 : PRINT : GOSUB 1760 : 'Mechanical breakdowns
920 IF TYPE(DAY) = 3 AND GR > 2.7 THEN PP(1) = PP(1) + 10 : PPT = PPT + 10 : PPX = 1
930 PRINT : GOSUB 2140 : 'Physical problems
940 IF PPX = 1 THEN PPX = 0 : PP(1) = PP(1) - 10 : PPT = PPT - 10
950 PRINT : PRINT "Time for a quick breather. You have about";
960 PRINT INT(20 + 20 * RND(1)) "km to go."
970 PRINT "Press any key when you're ready to go."
980 WHILE LEN(INKEY$) = 0 : WEND : PRINT "Okay, on the road again…"
990 '
1000 'Sprint at end of stage
1010 GOSUB 3440 : PRINT : PRINT "You're coming up on 10 km from the end."
1020 PRINT "During the countdown (in 0.1-kilometer increments) you can"
1030 PRINT "press any key when you want to start your sprint." : GOSUB 3440
1040 PRINT : FOR DSP = 10 TO 0 STEP - .1 : 'Count down from 10km by 0.1 increments
1050 LOCATE 23, 10 : PRINT USING "##.#";DSP : IF LEN(INKEY$) > 0 THEN 1070
1060 NEXT DSP : KSR = 1 : GOTO 1090
1070 PTM = DSP / 2 : RPS = 140 : GOSUB 2890 : KSR = RPM * .396 : 'Sprint speed
1080 PRINT USING "##.#"; KSR; : PRINT " kph." : PRINT
1090 TMSD = DSP / KSR : TMRD = (DIST(DAY) - DSP) / KPH : TTM(1) = TMSD + TMRD + TDL
1100 IF DSP > 3 THEN PRINT "Puff…puff…puff. That was a L-O-N-G sprint!"
1110 '
1120 'Calculate top six riders
1130 PRINT : PRINT "Race summary (total times in hours) :"
1140 PRINT " Rider 1 (you) 2 3 4 5 6"
1150 TTS = TTM(1) : WS = 1 : PRINT "Stage time", : PRINT USING "#####.##"; TTM(1);
1160 IF TYPE(DAY) = 3 THEN GQ = .3 ELSE GQ = .4
1170 FOR I = 2 TO 6 : RPM = 70 + 20 * RND(1)
1180 TTM(I) = DIST(DAY) / (GQ * RPM) + 1.4 * RND(1) : PRINT USING "#####.##"; TTM(I);
1190 IF TTM(I) < TTS THEN TTS = TTM(I) : WS = I
1200 NEXT I
1210 TTT = 1000 : WT = 0 : PRINT : PRINT "Total time", : FOR I = 1 TO 6
1220 TTR(I) = TTR(I) + TTM(I) : PRINT USING "#####.##"; TTR(I);
1230 IF TTR(I) < TTT THEN TTT = TTR(I) : WT = I
1240 NEXT I : PRINT : PRINT
1250 PRINT " Stage winner : Rider" WS " Overall leader : Rider" WT
1260 WSG(WS) = WSG(WS) + 1
1270 IF DAY < 22 THEN 540
1280 '
1290 'End-of-race summary
1300 PRINT : PRINT "The Tour de France has ended!" : PRINT : X = 0
1310 FOR I = 1 TO 6 : IF WSG(I) > X THEN X = WSG(I) : WS = I
1320 NEXT I : PRINT "Winner of the most stages (" X ") was Rider" WS;
1330 IF WS = 1 THEN PRINT " That's YOU!" ELSE PRINT
1340 PRINT "Overall winner by elapsed time was Rider" WT;
1350 IF WT = 1 THEN PRINT " That's YOU!" ELSE PRINT
1360 TTT = 1000 : WT = 0 : FOR I = 1 TO 6
1370 IF TTR(I) - 2 * WSG(I) < TTT THEN TTT = TTR(I) - 2 * WSG(I) : WT = I
1380 NEXT I
1390 PRINT "Overall points winner (time and stages) was Rider" WT;
1400 IF WT = 1 THEN PRINT " That's YOU!" ELSE PRINT
1410 GOTO 2730
1420 '
1430 'Subroutine to read event probabilities
1440 FOR I = 1 TO 10 : READ A : PRT = PRT + A : PR(I) = PRT : NEXT I
1450 DATA 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
1460 FOR I = 1 TO 8 : READ A : PMT = PMT + A : PM(I) = PMT : NEXT I
1470 DATA 5, 5, 5, 5, 5, 5, 10, 5
1480 FOR I = 1 TO 14 : READ A : PPT = PPT + A : PP(I) = PPT : NEXT I : RETURN
1490 DATA 8, 5, 5, 5, 5, 5, 5, 5, 5, 8, 5, 5, 5, 3
1500 '
1510 'Subroutine to deal with road hazards
1520 RN = INT(PRT * RND(1)) : FOR I = 1 TO 10
1530 IF RN > PR(I) THEN NEXT I : I = 10 : 'If event happened, exit loop
1540 ON I GOTO 1550, 1570, 1590, 1610, 1630, 1650, 1670, 1690, 1720, 1740
1550 PRINT "Mostly gravel roads this stage. You'll have to slow down."
1560 TDL = TDL + .8 : RETURN
1570 PRINT "The roads in this area are very bumpy and will slow you down."
1580 TDL = TDL + .5 : RETURN
1590 PRINT "Hot weather in this area has caused the roads to become very"
1600 PRINT "slippery from oil seepage." : TDL = TDL + .3 : RETURN
1610 PRINT "The wind is at your back making for a very fast ride!"
1620 TDL = TDL + -.3 : RETURN
1630 PRINT "You're heading straight into the wind today. Tough going."
1640 TDL = TDL + .5 : RETURN
1650 PRINT "There is a gusty sidewind today creating balance problems."
1660 TDL = TDL + .3 : RETURN
1670 PRINT "Dreary day: drizzle, fog, and clammy chill in the air."
1680 TDL = TDL + .2 : RETURN
1690 PRINT "Horrible weather! Icy rain that hits you like 1000 needles,"
1700 PRINT "stinging your face and arms. Your shoes are soaked. And there"
1710 PRINT "are few spectators to cheer you on." : TDL = TDL + .5 : RETURN
1720 PRINT "Mud and puddles on the road cause you to slide and skid all over."
1730 TDL = TDL + .4 : RETURN
1740 PRINT "Today is a crisp, clear day in the French countryside." : RETURN
1750 '
1760 'Subroutine to deal with mechanical breakdowns
1770 RN = INT(PMT * RND(1)) : FOR I = 1 TO 8 : 'Select event
1780 IF RN > PM(I) THEN NEXT I : I = 8 : 'If event happened, exit loop
1790 ON I GOTO 1800, 1830, 1850, 1890, 1930, 1970, 1990, 2120
1800 INPUT "You have a broken spoke. Want to fix it now";A$ : GOSUB 3350
1810 IF A$ = "Y" THEN TDL = TDL + .1 ELSE TDL = TDL + .15
1820 RETURN
1830 PRINT "You got a flat tire. You'll have to change it now."
1840 TDL = TDL + .1 : RETURN
1850 PRINT "Your brakes tend to lock every time you apply them hard. You can"
1860 INPUT "nurse them along or fix them here. Want to fix them now";A$
1870 GOSUB 3350 : IF A$ = "Y" THEN TDL = TDL + .2 ELSE TDL = TDL + .4
1880 RETURN
1890 PRINT "You seem to be missing shifts to your 19 cog. Perhaps one or"
1900 PRINT "more teeth are worn. You can shift around it or fix it here."
1910 INPUT "Want to fix it now";A$ : GOSUB 3350 : IF A$ = "Y" THEN TDL = TDL + .2 : RETURN
1920 TDL = TDL + .4 : RETURN
1930 PRINT "On a tight corner, you narrowly missed a spill, but your toe clip"
1940 INPUT "got bent on a boulder near the road. Want to bend it out now";A$
1950 IF A$ = "Y" THEN TDL = TDL + .1 ELSE TDL = TDL + .2
1960 RETURN
1970 PRINT "Uh oh! Chain broke. You've no choice but to fix it now."
1980 TDL = TDL + .15 : RETURN
1990 PRINT "WHOOPS! Took a corner too fast, lost traction, slid, and CRASHED!"
2000 GOSUB 3440 : CR = 1 : RN = RND(1) : IF RN < .03 THEN 2080 ELSE IF RN < .5 THEN 2040
2010 PRINT "You pick up yourself and your bicycle. You're both"
2020 PRINT "scratched and a bit beaten up but there seems to be no"
2030 PRINT "serious damage so you get on your way." : TDL = TDL + .3 : RETURN
2040 PRINT "You twisted your ankle and it is very painful. You know it will"
2050 PRINT "slow you down. However, there is no way you would drop out of the"
2060 PRINT "race, so you pick up your bicycle and get on your way."
2070 TDL = TDL + .8 : RETURN
2080 PRINT "Blood is all over the place; ambulance is called and"
2090 PRINT "you are rushed to the local hospital." : GOSUB 3440
2100 PRINT "Bad news! You dislocated your shoulder and you're out of the race."
2110 GOTO 2700
2120 PRINT "Bicycle ran like a charm today. No problems at all!" : RETURN
2130 '
2140 'Subroutine to deal with physical problems
2150 RN = INT(PPT * RND(1)) : FOR I = 1 TO 14
2160 IF RN > PP(I) THEN NEXT I : I = 14 : 'If event happened, exit loop
2170 IF I > 10 THEN 2190
2180 ON I GOTO 2200, 2320, 2340, 2370, 2390, 2420, 2440, 2470, 2500, 2530
2190 ON I - 10 GOTO 2560, 2600, 2640, 2660
2200 X = INT(DIST(DAY) / 50) : IF X < 2 THEN X = 2
2210 PRINT "You're pushing yourself to the absolute limit and after" X "hours"
2220 PRINT "you totally collapse. The medics give you oxygen and bring you"
2230 PRINT "around, but warn you against resuming the race." : IF CL > 0 THEN 2290
2240 CL = 1 : IF RND(1) > .8 THEN 2270
2250 GOSUB 3440 : PRINT "But nothing can defeat your competitive spirit and you"
2260 PRINT "vow to press on regardless." : TDL = TDL + 1 : RETURN
2270 GOSUB 3440 : PRINT "You heard of another rider dying from overexertion last"
2280 PRINT "year, so you follow the doctor's advice and withdraw." : GOTO 2700
2290 GOSUB 3440 : PRINT "This is the second time you collapsed in this race,"
2300 PRINT "so you reluctantly concede that this just isn't your year"
2310 PRINT "and you withdraw from the race." : GOTO 2700
2320 PRINT "You have a terrible abdominal pain…something you ate, perhaps?"
2330 PRINT "You'll have to slow down a bit." : TDL = TDL + .4 : RETURN
2340 PRINT "You're having difficulty breathing and you're feeling lightheaded."
2350 PRINT "You recognize this as an early warning signal of total collapse"
2360 PRINT "and wisely decide to slow your pace a bit." : TDL = TDL + .3 : RETURN
2370 PRINT "You seem to be seeing through a haze…and it's not the weather."
2380 PRINT "Occasionally, you can't seem to focus at all." : GOTO 2350
2390 PRINT "Uh oh! A muscle in your calf seems to have turned to jelly. It's"
2400 PRINT "not particularly painful, but it seems to be completely out of"
2410 PRINT "control. You'll have to slow down a bit." : TDL = TDL + .3 : RETURN
2420 PRINT "You have a sharp pain in your lower back. It doesn't seem to be"
2430 PRINT "injured…perhaps you're just overly tense." : TDL = TDL + .2 : RETURN
2440 PRINT "The gearing you've been using is really tough on your legs and"
2450 PRINT "you have developed shin splints. You'll have to back off your"
2460 PRINT "blistering pace a bit." : TDL = TDL + .3 : RETURN
2470 PRINT "Terrible pain in the balls of your feet. Your toe clip seems to be"
2480 PRINT "adjusted correctly. Maybe it's these new cleats. In any event,"
2490 PRINT "you decide to back off a bit…just for today." : TDL = TDL + .3 : RETURN
2500 PRINT "A medic takes a look at you during lunch break and declares you"
2510 PRINT "have a salt/water imbalance. 'Drink more water along the way,'"
2520 PRINT "he recommends, 'and don't forget your salt pills.'" : RETURN
2530 IF TYPE< >3 THEN 2660
2540 PRINT "The altitude is getting to you in the mountains. You're short of"
2550 PRINT "breath and you feel lightheaded. : goto 2445
2560 PRINT "Your saddle feels like it has appended itself to your body. A cyst"
2570 PRINT "seems to be starting, something you want to avoid at all costs."
2580 PRINT "You put some extra padding on the saddle and back off on your"
2590 PRINT "pace just a tad." : TDL = TDL + .15 : RETURN
2600 PRINT "The blistering pace you've been keeping has played havoc with your"
2610 PRINT "knees. You've heard of football players with bad knees, but a"
2620 PRINT "bicycle racer? Nevertheless, you'll have to slow down a bit."
2630 TDL = TDL + .2 : RETURN
2640 PRINT "You developed a bad cramp in your legs. You'll have to take it"
2650 PRINT "just a bit easier." : TDL = TDL + .15 : RETURN
2660 IF CR = 1 THEN 2150 : 'Can't feel too great after a crash
2670 PRINT "You're feeling fit as a fiddle and have no physical problems today."
2680 RETURN
2690 '
2700 'It's all over
2710 PRINT : PRINT "Too bad. That's it for this year, but there's always"
2720 PRINT "next year...."
2730 PRINT : INPUT "Would you like to ride again";A$ : GOSUB 3350
2740 IF A$ = "Y" THEN RUN ELSE KEY ON : CLS : PRINT "Bye for now." : END
2750 '
2760 'Subroutine to assign keys to pedals
2770 PRINT "To pedal your computer bike, you will strike two keys alternately"
2780 PRINT "With two fingers (one hand or two, it's up to you)."
2790 INPUT "Which key do you want for your left pedal";LF$
2800 INPUT "and which key for the right";RT$ : RETURN
2810 '
2820 'Subroutine to calculate time to pedal as a function of processor speed
2830 PRINT "Calculating timing-loop value takes 20 seconds. Please be patient."
2840 PRINT : EN = 20 + 60 * VAL(MID$(TIME$, 4, 2)) + VAL(RIGHT$(TIME$, 2))
2850 WHILE 60 * VAL(MID$(TIME$, 4, 2)) + VAL(RIGHT$(TIME$, 2)) < EN : PT = PT + 1 : WEND
2860 PT = PT * 2 : PRINT "The timing-loop value for your computer is"PT
2870 PRINT "Please write it down for playing this game in the future." : RETURN
2880 '
2890 'Subroutine to pedal bicycle
2900 IF DAY = 8 AND PD = 0 THEN 2950 : 'Must get at least one chance to pedal
2910 IF DAY = 17 AND PD = 1 THEN 2950 : 'Second chance to pedal
2920 IF PFRQ >= 9.92 * RND(1) THEN PD = PD + 1 : GOTO 2950 : 'Human pedal bike?
2930 RPM = INT((RPS + 40 * RND(1)) * FIT) : PRINT "Computer is pedaling your bicycle."
2940 GOSUB 3440 : X$ = "It" : GOTO 3020
2950 PRINT "Start pedaling"; : GOSUB 3440 : PRINT " NOW!" : PRINT
2960 K = 0 : FOR I = 1 TO PT * PTM
2970 A$ = INKEY$ : IF LEN(A$) = 0 OR A$ = B$ THEN 2990
2980 IF A$ = LF$ OR A$ = RT$ THEN K = K + 1 : B$ = A$
2990 NEXT I
3000 PRINT "Okay, stop pedaling." : RPM = INT(.9 * FIT * K / PTM) : X$ = "You"
3010 IF RPM > 95 THEN RPM = INT(84 + 10 * RND(1))
3020 PRINT X$ " pedaled at a rate of" RPM "rpm. Calculating speed....";
3030 A$ = "" : FOR I = 1 TO 800 : B$ = INKEY$ : NEXT I : RETURN
3040 '
3050 'Subroutine to read data about routes
3060 FOR I = 1 TO 22 : READ N, PLACE$(I), TYPE(I), DIST(I) : NEXT I : RETURN
3070 DATA 1, "Lille", 1, 213
3080 DATA 2, "Arras", 4, 52
3090 DATA 3, "Caen", 1, 308
3100 DATA 4, "Le Mans", 1, 172
3110 DATA 5, "Nantes", 1, 192
3120 DATA 6, "Bordeaux", 1, 338
3130 DATA 7, "Biarritz/Bayonne", 1, 184
3140 DATA 8, "Lourdes", 3, 168
3150 DATA 9, "Lourdes", 5, 0
3160 DATA 10, "Toulouse", 2, 172
3170 DATA 11, "Rodez", 2, 176
3180 DATA 12, "Avignon", 2, 294
3190 DATA 13, "Grenoble", 2, 228
3200 DATA 14, "l'Alpe-d'Huez", 4, 39
3210 DATA 15, "Lansleburg", 3, 225
3220 DATA 16, "Martigny, Switzerland", 3, 230
3230 DATA 17, "Annecy", 3, 218
3240 DATA 18, "Annecy", 5, 0
3250 DATA 19, "Lyon", 2, 182
3260 DATA 20, "Dijon", 1, 212
3270 DATA 21, "Fountainbleau", 1, 259
3280 DATA 22, "Paris", 1, 210
3290 '
3300 'Subroutine to read words
3310 FOR I = 1 TO 5 : READ TYPE$(I) : NEXT I : RETURN
3320 DATA "Mostly flat with small hills.", "Hills, gorges, steep slopes."
3330 DATA "Mountains." ,"Time trial against the clock.", "Rest."
3340 '
3350 'Subroutine to read yes/no answer
3360 GOSUB 3390 : IF A$ = "Y" OR A$ = "N" THEN RETURN
3370 INPUT "Don't understand your answer. Enter 'Y' or 'N' please";A$ : GOTO 3360
3380 '
3390 'Subroutine to read first letter of answer and convert to uppercase
3400 IF A$ = "" THEN A$ = "Y" : RETURN
3410 A$ = LEFT$(A$, 1) : IF A$ >= "A" AND A$ <= "Z" THEN RETURN
3420 A$ = CHR$(ASC(A$) - 32) : RETURN
3430 '
3440 'Subroutine to make a short pause
3450 FOR PAUSE = 1 TO 300 : X = X + 1 : NEXT PAUSE : RETURN
3460 '
3470 'Subroutine to print a centered line
3480 PRINT TAB((70 - LEN(X$)) / 2) X$ : RETURN
3490 '
3500 'Subroutine to display initial scenario
3510 X$ = "Tour de France Bicycle Race" : GOSUB 3470 : PRINT
3520 PRINT " You are a bicycle racer entered in the 22-day Tour de France"
3530 PRINT "bicycle race around France. Your objective is to win the race by"
3540 PRINT "having the lowest overall elapsed time. In addition, you must try"
3550 PRINT "to win as many individual 'stages' or daily races as possible, as"
3560 PRINT "wins on these stages count toward the overall points prize."
3570 PRINT " Each day you pedal your bicycle by alternately pressing two"
3580 PRINT "keys on your computer keyboard as quickly as possible (you may opt"
3590 PRINT "to have the computer do some of the pedaling for you)."
3600 PRINT " While racing, various hazards occur (weather, mechanical"
3610 PRINT "breakdowns, road conditions, and physical problems) that hamper"
3620 PRINT "your progress."
3630 PRINT " At the end of each stage (day), you may sprint to the finish"
3640 PRINT "line. The computer will count down the distance starting ten"
3650 PRINT "kilometers from the end of the race. During this countdown, you"
3660 PRINT "must decide when to start your sprint. Remember, if you start too"
3670 PRINT "soon, you may become too exhausted to maintain your sprint to the"
3680 PRINT "end, but if you start too late, other riders may overtake you."
3690 RETURN