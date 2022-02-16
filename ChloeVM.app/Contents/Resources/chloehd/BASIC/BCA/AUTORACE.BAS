100 CLS : KEY OFF
110 LOCATE 10, 23 : PRINT "The Longest Automobile Race, 1908" : PRINT
120 PRINT : PRINT TAB(29) "(c) David H. Ahl, 1986" : LOCATE 23, 21
130 '
140 'Initialization
150 DIM LA$(20), LB$(20), TX(20), C(20), WX(20), DX(20)
160 DIM FA$(20), FB$(20), FC$(20), FT(2, 20), FL(2, 20)
170 Z = 1000 : GF = .25 : 'Starting cash and gas price
180 GOSUB 2970 : 'Initialize text variables
190 GOSUB 3060 : 'Initialize location data
200 GOSUB 3310 : 'Initialize mechanical breakdown data
210 PRINT "Press any key when you're ready to go" : RN = -32768!
220 WHILE LEN(INKEY$) = 0 : RN = RN + 1 : WEND
230 WHILE RN > 32767 : RN = RN - 65535! : WEND : RANDOMIZE RN : GOSUB 4010
240 '
250 'Main program
260 J = J + 1 : T = 0 : GOSUB 3710 : GOSUB 3630 : 'New location, road data, etc.
270 DA = 0 : W = WX(J) : D = DX(J) : TE = TX(J) : 'Set variables for new location
280 GOSUB 940 : 'Print the date
290 PRINT "You are at " LA$(J) ", " LB$(J) "."
300 PRINT "You currently have"; : PRINT USING "$$####.##";Z : IF J = 1 THEN 420
310 IF FX = 0 THEN 340 : 'Any unfixed mechanical parts?
320 PRINT "A sympathetic garage owner will fix the " FA$(FX) " here." : FX = 0
330 TZ = INT(1 + 3 * RND(1)) : PRINT "It will take" TZ "day(s)." : GOSUB 2590
340 IF J > 7 AND J < 11 THEN GOSUB 2290 : 'Ocean voyage?
350 IF JV = 1 THEN JV = 0 : TL = TL + TE : GOTO 260 : 'End of ocean voyage?
360 PRINT : PRINT "You have driven" INT(DC) "miles in" TD "days."
370 IF J = 20 THEN 3740 : 'Finished the race?
380 IF TD < TL THEN 400 ELSE IF TD = TL THEN 410
390 PRINT "The race leader passed this point" TD - TL "day(s) ago." : GOTO 420
400 PRINT "You are the race leader and are" TL - TD "day(s) ahead." : GOTO 420
410 PRINT "You and the Italian Zust are running even with each other."
420 TL = TL + TE : 'Elapsed time of race leader
430 IF J = 7 OR J = 12 THEN GOSUB 2290 : 'Ocean voyage after land segment?
440 IF JV = 1 THEN JV = 0 : GOTO 260 : 'End of ocean voyage?
450 PRINT "Roads to the west of here are " C$(C(J)) "."
460 PRINT "The weather forecast is " W$(W) "."
470 PRINT "You set a goal of making" D "miles in the next" TE - 2 "days."
480 GOSUB 640 : 'Buy gas and oil
490 GOSUB 730 : 'Get desired speed
500 GOSUB 820 : 'Get desired driving hours per day
510 '
520 'Go through this race segment day by day
530 TZ = 1 : GOSUB 2590 : 'Increment through each day of travel
540 GOSUB 1120 : 'Weather subroutine
550 GOSUB 1640 : 'Mechanical breakdown subroutine
560 GOSUB 1930 : 'Accident subroutine
570 DD = SP * HP * PW : DA = DA + DD : DC = DC + DD : 'Daily and cumulative distances
580 GM = .07 * DD * (.8 + .4 * RND(1)) : 'Gas used today
590 IF GM < GG THEN GG = GG - GM : GOTO 620 : 'Subtract gas used from supply
600 BEEP : BEEP : BEEP : GOSUB 940 : PRINT "You ran out of gas on the road."
610 GF = .33 : GOSUB 640 : GG = GG - GM : 'Buy gas
620 IF DA >= D THEN 260 ELSE 520 : 'Complete a travel segment?
630 '
640 'Fuel and oil subroutine
650 GP = GF * (.7 + .6 * RND(1)) : PRINT "Gas costs" INT(100 * GP) "cents per gallon here."
660 INPUT "How many gallons do you want for the segment ahead"; GG
670 GF = .25 : ZN = GG * GP : PRINT "That will cost"; : PRINT USING "$$###.##";ZN
680 GOSUB 2660 : 'Do you have enough money?
690 IF A = 0 THEN RETURN : 'Enough money now?
700 IF Z < 2 THEN PRINT "Your car won't run on fumes. It's all over." : GOTO 3910
710 GG = INT(Z / GP) : PRINT "Sorry, you could only get" GG "gallons." : RETURN
720 '
730 'Input desired speed subroutine
740 INPUT "How fast (mph) do you want to drive";SP
750 IF SP > 54 THEN PRINT "Top speed of your car is only 54 mph." : GOTO 740
760 IF SP < 8 THEN PRINT "At that rate, you'll never get there." : GOTO 740
770 IF W < 3 AND SP > 30 THEN 780 ELSE 790
780 PRINT "That's too fast for these weather and road conditions." : GOTO 740
790 PB = SP * SP / 7000 : 'Probability of mechanical breakdown is related to speed
800 RETURN
810 '
820 'Input desired driving hours subroutine
830 K = 0 : 'Counter for pushing too hard
840 INPUT "How many hours do you want to drive each day"; HP
850 IF K = 1 THEN 910 : 'Did we ask about pushing too hard already?
860 IF HP > 8 THEN PRINT "That's too much for both you and your car." : GOTO 840
870 IF HP < 2 THEN PRINT "No one is that lazy!" : GOTO 840
880 HC = HC + HP : IF J > 2 AND HC / J > 7.55 THEN 890 ELSE 910
890 PRINT "You've been pushing yourself and your crew pretty hard."
900 PRINT "You should probably back off a bit." : K = 1 : GOTO 840
910 PF = HP ^ 3 / 1000 - .15 : IF PF < .01 THEN PF = .01 : 'Probability of fatigue problem
920 RETURN
930 '
940 'Date subroutine
950 IF TT = TD THEN RETURN : 'Printed this date already?
960 IF TD < 19 THEN 990 ELSE IF TD < 50 THEN 1000 ELSE IF TD < 80 THEN 1010
970 IF TD < 111 THEN 1020 ELSE IF TD < 141 THEN 1030 ELSE IF TD < 172 THEN 1040
980 IF TD < 203 THEN 1050 ELSE GOSUB 3630 : GOTO 1070
990 MO$ = "February" : MD = TD + 11 : GOTO 1060
1000 MO$ = "March" : MD = TD - 18 : GOTO 1060
1010 MO$ = "April" : MD = TD - 49 : GOTO 1060
1020 MO$ = "May" : MD = TD - 79 : GOTO 1060
1030 MO$ = "June" : MD = TD - 110 : GOTO 1060
1040 MO$ = "July" : MD = TD - 140 : GOTO 1060
1050 MO$ = "August" : MD = TD - 171
1060 PRINT : PRINT "Date: " MO$; MD ", 1908" : TT = TD : RETURN
1070 PRINT : PRINT "It's September 1 and the winning car crossed the finish"
1080 PRINT "line in Paris over a month ago. Your factory refuses to give"
1090 PRINT "you any more money to continue. Better luck next time."
1100 GOTO 3890
1110 '
1120 'Weather subroutine
1130 ON W GOTO 1150, 1230, 1290, 1350, 1350, 1490
1140 '
1150 'Heavy snow and blizzard conditions
1160 RN = RND(1) : IF RN < .33 THEN 1170 ELSE IF RN > .83 THEN 1190 ELSE 1210
1170 GOSUB 960 : PW = .03 + .08 * RND(1) : 'Speed factor in blizzard
1180 PRINT "Blizzard conditions. Tough going today." : GOSUB 3710 : RETURN
1190 GOSUB 960 : PW = .05 + .1 * RND(1) : 'Speed factor in very heavy snow
1200 PRINT "You're stuck in a huge snow drift." : GOSUB 1530 : RETURN
1210 PW = .14 + .17 * RND(1) : RETURN : 'Speed factor on heavy snow day
1220 '
1230 'Snow conditions
1240 IF RND(1) < .1 THEN 1260 : '10% chance of getting stuck in snow
1250 PW = .3 + .4 * RND(1) : RETURN : 'Speed factor on normal snowy day
1260 PW = .15 + .1 * RND(1) : GOSUB 960 : PRINT "You have skidded into a ditch."
1270 GOSUB 1530 : RETURN : 'Hire farmer to pull you out of ditch?
1280 '
1290 'Rainy weather
1300 IF RND(1) < .2 THEN GOSUB 960 : GOTO 1320 : 'Bogged down in mud?
1310 PW = .35 + .4 * RND(1) : RETURN : 'Speed factor on normal rainy day
1320 PW = .02 + .04 * RND(1) : PRINT "You are totally bogged down in the mud."
1330 GOSUB 1530 : RETURN : 'Hire farmer to pull you out of mud?
1340 '
1350 'Cloudy and mixed weather
1360 RN = RND(1) : IF RN > .08 THEN 1470 ELSE GOSUB 960 : 'Normal cloudy day?
1370 IF RN < .01 THEN PRINT "An unexpected downpour!" : GOTO 1320
1380 PRINT "River ahead with no bridge. Some locals tell you there is a bridge"
1390 PRINT "'some distance' north. They also offer to take you across by boat"
1400 ZN = 3 + 2 * INT(3 * RND(1)) : PRINT "for $" ZN; : INPUT ". Want to go by boat";A$
1410 GOSUB 3530 : IF A = 1 THEN 1450 : 'Not willing to pay?
1420 GOSUB 2660 : 'Go to pay the bill routine
1430 IF A = 1 THEN 1450 : 'Still not enough money?
1440 PRINT "They got you across in" 2 + INT(3 * RND(1)) "hours." : PW = .3 : RETURN
1450 TZ = INT(1 + 2 * RND(1)) : PRINT "It took" TZ "day(s) for you to drive north ";
1460 PRINT "and find the bridge." : GOSUB 2590 : RETURN
1470 PW = .4 + .4 * RND(1) : RETURN : 'Normal cloudy day
1480 '
1490 'Clear and sunny
1500 IF RND(1) < .025 THEN GOSUB 960 : GOTO 1380 : 'River with no bridge
1510 PW = .45 + .5 * RND(1) : RETURN : 'Normal sunny day
1520 '
1530 'Pull you out of ditch subroutine
1540 ZN = 5 * INT(1 + 4 * RND(1)) : PRINT "A farmer offers to pull you out for $" ZN
1550 INPUT "Do you want to pay him to pull you out";A$ : GOSUB 3530
1560 IF A = 1 THEN 1610 : 'Not willing to pay?
1570 GOSUB 2660 : 'If not enough money try to get some
1580 IF A = 1 THEN 1610 : 'Still not enough money?
1590 RQ = INT(1.5 + 5 * RND(1)) : PRINT "It took" RQ "hours for him to pull you out."
1600 IF RQ < 5 THEN RETURN ELSE TZ = 1 : GOSUB 2590 : PW = PW * 1.5 : RETURN
1610 TZ = INT(1 + 1.3 * RND(1)) : PRINT "It took" TZ "day(s) for you and your mechanic"
1620 PRINT "to pull the car out by yourselves." : GOSUB 2590 : PW = PW * 1.5 : RETURN
1630 '
1640 'Mechanical breakdowns subroutine
1650 IF RND(1) > PB THEN RETURN : 'If no mechanical breakdown then return
1660 F = INT(1 + 15 * RND(1)) : IF F > 13 THEN F = INT(14 + 5 * RND(1)) : 'What malfunction
1670 BEEP : BEEP : BEEP : GOSUB 940 : 'Sound warning beeper and print date
1680 PRINT "Uh oh. You have a problem. It's a " FA$(F) "."
1690 PRINT "Here's what you can do about the problem:"
1700 PRINT TAB(7) "(1) Try to keep going with it"
1710 PRINT TAB(7) "(2) " FB$(F) ", cost $" FL(1, F)
1720 IF FC$(F) = "" THEN 1740 : 'Only one way to fix it?
1730 PRINT TAB(7) "(3) " FC$(F) ", cost $" FL(2, F)
1740 INPUT "Which would you like to do";FQ
1750 IF FQ = 1 THEN 1840 : 'Decided to do nothing?
1760 IF FQ = 2 OR FQ = 3 THEN 1770 ELSE PRINT "Please enter a number." : GOTO 1740
1770 FQ = FQ - 1 : FU = FT(FQ, F) : IF FU < 8 THEN FD$ = "hours" ELSE 1790
1780 IF FU < 5 THEN 1810 ELSE TZ = 1 : GOTO 1800 : 'Lose a day for repairs?
1790 FU = FT(FQ, F) / 8 : TZ = FU : IF FU = 1 THEN FD$ = "day" ELSE FD$ = "days"
1800 PW = PW * 1.5 : GOSUB 2590 : 'Allow for 1/2 day driven & increase day counters
1810 ZN = FL(FQ, F) : PRINT "Repairs will take" FU;FD$ " and will cost $" ZN
1820 GOSUB 2660 : 'Pay the repair bill
1830 IF A = 0 THEN RETURN : 'Enough money?
1840 PRINT "You try to nurse the car along to the next major city."
1850 IF FX = 0 THEN 1870 : 'Any unfixed malfunction?
1860 PRINT "But with the other problem you just can't make it and" : GOTO 1890
1870 IF RND(1) > .4 THEN 1900 : '60% chance that you can nurse it along
1880 GOSUB 3710 : PRINT : PRINT "Unfortunately, it just won't make it and"
1890 PRINT "reluctantly you admit defeat." : GOTO 3890
1900 PRINT "It looks like you'll make but at a drastically reduced speed."
1910 PW = PW * .5 : FX = F : RETURN : 'Cut speed factor in half, note unfixed item
1920 '
1930 'Accidents and special situations subroutine
1940 IF RND(1) > PF THEN 2100 : 'If driving long hours is not a problem, go on
1950 BEEP : BEEP : BEEP : BEEP : GOSUB 940 : PRINT "You dozed off and your car has run ";
1960 ON INT(1 + 4 * RND(1)) GOTO 1970, 1980, 1990, 2000, 2000
1970 PRINT "into a tree." : TZ = 2 : ZN = 24 : GOTO 2010
1980 PRINT "off the road." : TZ = 1 : ZN = 12 : GOTO 2010
1990 PRINT "into a gaping hole." : TZ = 1 : ZN = 18 : GOTO 2010
2000 PRINT "into a farmer's wagon." : TZ = 2 : ZN = 25
2010 PRINT "You can try to fix it or get a tow to the next village for $15."
2020 INPUT "Want to try to bang out the damage on the spot";A$ : GOSUB 3530
2030 IF A = 0 THEN 2070 ELSE PRINT "The tow costs $15 and the repairs cost $" ZN
2040 ZN = ZN + 15 : GOSUB 2660 : 'Pay the bills
2050 IF A = 0 THEN 2100 : 'Enough money now?
2060 PRINT "The locals impound your car for your unpaid debt." : GOTO 3890
2070 PRINT "You finally manage to do it but it takes" TZ "day(s)."
2080 PW = PW * 1.5 : GOSUB 2590 : 'Allow for 1/2 day driven & increase day counters
2090 '
2100 'Drive on railraod ties routine
2110 IF J< >2 AND J< >5 AND J< >13 AND J< >14 THEN 2190 : 'In area with railroads?
2120 IF RND(1) > .4 THEN 2190 ELSE GOSUB 940 : '40% chance to drive on rwy tracks
2130 PRINT "In this area of terrible roads, you can save some time by driving"
2140 PRINT "on the railraod tracks. However, it is murder on your wheels,"
2150 PRINT "tires, and whole car. "; : INPUT "Want to drive on the tracks";A$
2160 GOSUB 3530 : IF A = 1 THEN RETURN
2170 PW = PW * 1.7 : PB = PB * 1.25 : RETURN : 'Increase speed and chance of trouble
2180 '
2190 'No grease routine
2200 IF J< >15 AND J< >16 THEN RETURN : 'In central Russia?
2210 IF RND(1) > .2 THEN RETURN : '20% chance of no grease
2220 BEEP : BEEP : BEEP : GOSUB 940 : PRINT "Your differential is dry and there is"
2230 PRINT "no grease available here. However, you can get Vaseline."
2240 INPUT "Want to use it in place of grease";A$ : GOSUB 3530
2250 IF A = 0 THEN PRINT "Okay, you buy 20 jars for $4." : Z = Z - 4 : RETURN
2260 PRINT "The gears sound horrible. You'll have to cut your speed in half."
2270 PW = PW * .5 : RETURN
2280 '
2290 'Ocean voyage subroutine
2300 JV = 1 : TZ = INT(1 + 3.5 * RND(1)) : 'Length of time in port
2310 IF J = 12 THEN 2510 ELSE IF J = 10 THEN 2480
2320 IF J = 9 THEN 2420 ELSE IF J = 8 THEN 2390
2330 PRINT "You're stuck in port for" TZ + 1 "days before you can get a steamer"
2340 PRINT "for Seattle. You use the time to get new countershaft"
2350 PRINT "housings, springs, wheels, drive chains, and tires."
2360 IF Z > 300 THEN PRINT "The cost of these items is $164." : Z = Z - 164 : GOTO 2380
2370 PRINT "These were all furnished by the local Thomas Flyer dealer."
2380 TZ = TZ + 1 : TD = TD + 3 : GOSUB 2590 : GOSUB 3660 : RETURN
2390 PRINT "It took 3 days on the steamer. The next steamer for Valdez"
2400 PRINT "Leaves in" TZ "days. Nothing to do but wait." : GOSUB 2590
2410 GOSUB 3660 : TD = TD + 7 : RETURN
2420 PRINT "The steamer made many stops up the coast and it took 7 days."
2430 PRINT "It is apparent that the race organizers have never been in Alaska"
2440 PRINT "and have no idea that it is impossible to drive on the snow and"
2450 PRINT "ice at all, much less across the Bering Strait to Russia. You'll"
2460 PRINT "have to return to Seattle. Next steamer goes in" TZ "days."
2470 GOSUB 2590 : GOSUB 3660 : TD = TD + 7 : RETURN
2480 PRINT "It took 7 days to get back to Seattle. Now you have a" TZ "day"
2490 PRINT "wait before you can get a freighter for Japan."
2500 GOSUB 2590 : GOSUB 3660 : TD = TD + 21 : RETURN
2510 PRINT "The freighter across the Pacific takes a leisurely 21 days making"
2520 PRINT "stops at Hawaii, Guam, and the Philippines. Also the Chinese"
2530 PRINT "crewmen made sandals out of your leather fenders and mud flaps."
2540 PRINT "You can't replace them in Japan, but you can at Vladivostock,"
2550 PRINT "Russia. There you'll have to spend several days arranging for"
2560 PRINT "fuel also. But hurry now. A steamer to Russia leaves tonight."
2570 GOSUB 3660 : TD = TD + 7 : RETURN
2580 '
2590 'Time delay and hotel bills routine
2600 T = T + TZ : TD = TD + TZ : 'Increment time counters
2610 ZN = 10 * TZ : GOSUB 2660 : 'Pay for hotel and meals
2620 IF A = 0 THEN RETURN : 'Did we have enough money?
2630 PRINT : PRINT "You don't even have enough money to pay for meals."
2640 PRINT "That's the end of the road for you." : PRINT : GOTO 3890
2650 '
2660 'Pay the bills routine
2670 IF Z < ZN THEN GOSUB 2710 ELSE 2690 : 'Enough money to pay bills?
2680 IF Z < ZN THEN A = 1 : RETURN : 'Couldn't get money from home
2690 Z = Z - ZN : A = 0 : RETURN : 'Subtract money from kitty
2700 '
2710 'Need more money subroutine
2720 ZB = ZB + 1 : IF ZB < 3 THEN ZW = 1000 ELSE ZW = 500 : 'Money request and amount
2730 PRINT : PRINT "You don't have enough money to continue. Your only hope is"
2740 PRINT "to send a telegram back to Mr. Thomas at the factory and ask"
2750 PRINT "for more money. Remember, telegrams in 1908 used all capital"
2760 PRINT "letters, had no commas, and were short."
2770 INPUT "What is your message";A$ : PRINT "Sending telegram now…"
2780 GOSUB 3590 : IF ZB > 3 THEN 2940
2790 AS = 0 : AP = 0 : L = LEN(A$) : IF L < 12 THEN 2920
2800 FOR I = 1 TO L - 2 : AT$ = MID$(A$, I, 3) : 'Look at 3-letter groups in telegram
2810 IF AT$ = "PLE" OR AT$ = "BEG" OR AT$ = "SOR" OR AT$ = "IMP" THEN AP = 1
2820 IF AT$ = "SOO" OR AT$ = "QUI" OR AT$ = "EAR" OR AT$ = "FAS" OR AT$ = "HUR" THEN AS = 1
2830 IF AT$ = "IMM" OR AT$ = "ONC" OR AT$ = "URG" THEN AS = 1
2840 NEXT I : IF AP = 0 THEN 2880 ELSE IF AS = 0 THEN 2860
2850 PRINT "Mr. Thomas wired back $ "ZW" and said 'GOOD LUCK!" : Z = Z + ZW : RETURN
2860 PRINT "Mr. Thomas didn't know you needed the money right away and waited"
2870 PRINT "3 days before wiring back $" ZW : Z = Z + ZW : TZ = 3 : GOSUB 2590 : RETURN
2880 IF AS = 0 THEN 2910
2890 PRINT "Mr. Thomas wired back, 'YOU COULD AT LEAST BE POLITE,' but did"
2900 ZW = ZW / 2 : PRINT "include a draft for $" ZW : Z = Z + ZW : RETURN
2910 PRINT "Mr. Thomas was offended by your telegram and refused to" : GOTO 2930
2920 PRINT "Your message was short all right. Too short. Mr. Thomas didn't"
2930 PRINT "send any money. Sorry." : RETURN
2940 PRINT "Mr. Thomas wires back: I AM FED UP WITH THIS ADVENTURE STOP"
2950 PRINT "YOU WILL GET NO MORE MONEY FROM ME STOP" : RETURN
2960 '
2970 'Subroutine to put verbal data into constants
2980 FOR I = 1 TO 6 : READ C$(I) : NEXT I
2990 FOR I = 1 TO 6 : READ W$(I) : NEXT I
3000 DATA "hard packed gravel", "muddy ruts", "slightly improved wagon tracks"
3010 DATA "built for narrow carts", "practically non-existent", "horrible"
3020 DATA "blizzard conditions", "snow and sleet", "rain"
3030 DATA "cloudy with a chance of rain", "mixed", "sunny and dry"
3040 RETURN
3050 '
3060 'Location, expected weather, road conditions, need to use rail,
3070 ' expected days to next location, distance to next location
3080 FOR I = 1 TO 20 : READ X, LA$(I), LB$(I), WX(I), C(I), TX(I), DX(I) : NEXT I
3090 RETURN
3100 DATA 1, "New York", "New York", 2, 1, 8, 897
3110 DATA 2, "Kendallville", "Indiana", 1, 1, 6, 166
3120 DATA 3, "Chicago", "Illinois", 3, 2, 7, 634
3130 DATA 4, "Omaha", "Nebraska", 6, 3, 4, 482
3140 DATA 5, "Laramie", "Wyoming", 2, 3, 7, 467
3150 DATA 6, "Ogden", "Utah", 6, 1, 8, 1237
3160 DATA 7, "San Francisco", "California", 5, 7, 8, 0
3170 DATA 8, "Seattle", "Washington", 5, 7, 8, 0
3180 DATA 9, "Valdez", "Alaska", 5, 7, 8, 0
3190 DATA 10, "Seattle", "Washington", 5, 7, 25, 0
3200 DATA 11, "Kobe", "Japan", 4, 4, 4, 350
3210 DATA 12, "Tsuruga", "Japan", 4, 7, 7, 0
3220 DATA 13, "Vladivostock", "Russia", 3, 5, 15, 558
3230 DATA 14, "Tsitsihar", "Manchuria", 5, 6, 10, 659
3240 DATA 15, "Chita", "Russia", 3, 3, 8, 1116
3250 DATA 16, "Kansk", "Russia" 4, 3, 6, 1075
3260 DATA 17, "Omsk", "Russia", 5, 1, 7, 820
3270 DATA 18, "Perm", "Russia", 3, 2, 14, 1090
3280 DATA 19, "St. Petersburg", "Russia", 3, 1, 8, 1575
3290 DATA 20, "Paris", "France", 0, 0, 0, 0
3300 '
3310 'Mechanical breakdown descriptions, time to fix, cost
3320 FOR I = 1 TO 18
3330 READ X, FA$(I), FB$(I), FC$(I), FT(1, I), FL(1, I), FT(2, I), FL(2, I) : NEXT I : RETURN
3340 DATA 1, "tire blowout", "Patch the hole", "Replace the tire", 2, 1, 2, 7
3350 DATA 2, "skipping cylinder", "New spark plugs", "Grind cylinder", 1, 2, 8, 2
3360 DATA 3, "rough running engine", "Do a tune up", "", 4, 5, 0, 0
3370 DATA 4, "binding axle bearing", "Regrind bearing", "Get a new one", 8, 2, 4, 8
3380 DATA 5, "cracked spring", "New spring", "Weld angle iron to it", 8, 26, 8, 4
3390 DATA 6, "cracked wheel", "New wheel", "Weld brace on it", 2, 42, 8, 4
3400 DATA 7, "slipping clutch", "Adjust clutch", "New clutch plate", 4, 4, 8, 54
3410 DATA 8, "stripped gear", "Weld teeth back on", "New gear", 16, 6, 8, 24
3420 DATA 9, "radiator leak", "Weld a patch on it", "", 4, 2, 0, 0
3430 DATA 10, "brakes failure", "Replace the linings", "", 8, 7, 0, 0
3440 DATA 11, "crack in the countershaft housing", "A new housing", "", 24, 40, 0, 0
3450 DATA 12, "broken drive pinion" "Weld teeth back on", "New pinion", 16, 6, 8, 18
3460 DATA 13, "broken rear axle", "Get a new axle", "", 16, 68, 0, 0
3470 DATA 14, "cracked transmission housing", "New one from factory", "", 24, 60, 0, 0
3480 DATA 15, "broken motor support", "Make a new one of scrap iron", "", 16, 16, 0, 0
3490 DATA 16, "worn down clutch shaft", "A new clutch shaft", "", 8, 28, 0, 0
3500 DATA 17, "cracked frame", "Weld on braces of angle iron", "", 24, 26, 0, 0
3510 DATA 18, "total transmission failure", "A new one from factory", "", 40, 225, 0, 0
3520 '
3530 'Check for yes or no answer
3540 IF A$ = "" OR A$ = "Y" OR A$ = "y" THEN A = 0 : RETURN
3550 IF A$ = "N" OR A$ = "n" THEN A = 1 : RETURN
3560 PRINT "Don't understand your answer of ";A$; "."
3570 INPUT "Please enter Y for 'yes' or N for 'no.'";A$ : GOTO 3530
3580 '
3590 'Telegraph routine
3600 FOR I = 1 TO 4 : X = 1 + 3 * RND(1) : FOR K = 1 TO X : BEEP : NEXT K
3610 FOR K = 1 TO 500 : NEXT K : NEXT I : RETURN
3620 '
3630 'Warning beeper routine
3640 PRINT : FOR I = 1 TO 3 : BEEP : BEEP : FOR K = 1 TO 500 : NEXT K : NEXT I : RETURN
3650 '
3660 'Ready to go? routine
3670 PRINT : PRINT "Press any key when you're ready to go aboard."
3680 WHILE LEN(INKEY$) = 0 : WEND
3690 RETURN
3700 '
3710 'Pause routine
3720 FOR I = 1 TO 500 : NEXT I : RETURN
3730 '
3740 'Finished the race in Paris!
3750 FOR K = 1 TO 3 : GOSUB 3720 : BEEP : BEEP : BEEP : NEXT K : CLS : X = 0
3760 FOR I = 1 TO 30 : FOR K = 1 TO 100 : NEXT K : LOCATE 10, 30 : PRINT X$ : BEEP
3770 IF X = 0 THEN X$ = "CONGRATULATIONS!" : X = 1 : GOTO 3790
3780 X$ = "" : X = 0 : 'X$ = 17 spaces to erase congratulations
3790 NEXT I : PRINT : PRINT
3800 IF TD < TL THEN 3830 ELSE IF TD = TL THEN 3850
3810 PRINT "You made it to Paris! The German Protos beat you by"
3820 PRINT TD - TL "days but just to finish is a great honor!" : GOTO 3860
3830 PRINT "You reached Paris first! The next car is" TL - TD "days behind."
3840 GOTO 3860
3850 PRINT "You reached Paris in a dead tie with the French Motobloc!"
3860 PRINT : PRINT "You reached Paris in" TD "days. In 1908, the Thomas Flyer"
3870 PRINT "won the race reaching Paris on July 30 after 169 days." : GOTO 3970
3880 '
3890 'End of race and summary statistics
3900 PRINT : GOSUB 3630 : PRINT
3910 PRINT "Sorry you were unsuccessful. Only three of the"
3920 PRINT "cars in the 1908 race ever finished." : PRINT
3930 PRINT "In the" TD "days since the start of the race on February 12, 1908,"
3940 PRINT "you covered" INT(DC) "miles. You almost made it to"LA$(J + 1) ", ";
3950 PRINT LB$(J + 1) ". " : PRINT "Not bad, but you can do better." : PRINT
3960 '
3970 PRINT : INPUT "Would you like to try again (Y or N)";A$ : GOSUB 3530
3980 IF A = 0 THEN PRINT "Okay. Good Luck!" : GOSUB 3720 : CLS : RUN
3990 PRINT "Okay. So long for now." : GOSUB 3720 : KEY ON : CLS : END
4000 '
4010 'Subroutine to print the instructions
4020 CLS : PRINT TAB(18) "The Longest Automobile Race, 1908" : 1908 : PRINT
4030 PRINT " In this program, you are the captain of the Thomas Flyer team."
4040 PRINT "It is your job to get the car from New York to Paris—east to west—
4050 PRINT "as quickly as possible. The race starts on Febraury 12, 1908."
4060 PRINT " You must overcome many problems : bad weather, accidents,"
4070 PRINT "mechanical breakdowns, fatigue, and a lack of gas stations."
4080 PRINT " For each leg of the trip, buy as much gas as you need, but no"
4090 PRINT "more. You car gets approximately 14 mph, although this will vary."
4100 PRINT "You will carry what fuel you can and ship the rest ahead by rail to"
4110 PRINT "locations along your route to be held for you (called 'spotting')."
4120 PRINT " Your car has a top speed of 54 mph. However, the probability"
4130 PRINT "of a breakdown increases substantially at speeds over 35 mph. Like-
4140 PRINT "wise, driving more than six hours per day increases your chance of"
4150 PRINT "having an accident. But don't forget, this IS a race."
4160 PRINT " If you get stuck, you can pay someone to pull you out (costs"
4170 PRINT "money) or try to get out on your own (costs time)."
4180 PRINT " You can choose to repair a mechanical problem on the spot or"
4190 PRINT "wait until the next large town to get it fixed. Either choice has"
4200 PRINT "associated risks."
4210 PRINT " If and when you run out of money, you can wire Mr. Thomas for"
4220 PRINT "more, but your request must be carefully and politely worded Also,"
4230 PRINT "your telegram must be in all UPPER CASE letters."
4240 PRINT TAB(21) "Press any key to continue.";
4250 WHILE LEN(INKEY$) = 0 : WEND : CLS : RETURN