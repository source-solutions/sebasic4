100 CLS : KEY OFF
110 LOCATE 10, 1 : X$ = "Appalachian Trail" : GOSUB 5590
120 LOCATE 13, 1 : X$ = "(c) by David H. Ahl, 1986" : GOSUB 5590
130 LOCATE 23, 1 : X$ = "Press any key to continue." : GOSUB 5590
140 WHILE LEN(INKEY$) = 0 : RN = RN + 1 : WEND
150 WHILE RN > 32767 : RN = RN - 65535! : WEND : RANDOMIZE RN : CLS : GOSUB 5620
160 DIM HZ(25), DLC(25), LC$(25)
170 WHILE LEN(INKEY$) = 0 : RN = RN + 1 : WEND : DB = 300 : 'New boot gives 300 extra mi
180 '
190 'Data Input Section
200 CLS : PRINT "First we need some data about you." : PRINT
210 INPUT "Your sex (male or female)";A$ : GOSUB 5540
220 IF A$< >"M" AND A$< >"F" THEN PRINT "Answer 'M' or 'F' please." : GOTO 210
230 INPUT "Your weight in pounds";WB
240 IF WB > 79 AND WB < 401 THEN 260
250 PRINT "Surely you jest. Let's try that one again." : GOTO 230
260 PRINT "What is your physical condition (1 = excellent, 2 = good, ";
270 INPUT "3 = fair, 4 = poor)";PC
280 IF PC < 1 OR PC > 4 THEN PRINT "Answer 1, 2, 3, or 4 please." : GOTO 260
290 PRINT : PRINT "Walking pace: You may change your pace as the hike progresses."
300 PRINT "Remember, a faster pace covers the distance more quickly but"
310 PRINT "burns more calories and has a higher risk of injury."
320 PRINT "Slow and deliberate......1.7 mph"
330 PRINT "Moderate and vigorous......3 mph"
340 PRINT "Fast and very difficult....4 mph"
350 INPUT "At what rate in mph do you wish to walk (number & decimal okay)";RW
360 IF RW < 1 OR RW > 4.2 THEN PRINT "A rate of" RW "mph is silly." : GOTO 350
370 PRINT : PRINT "Walking hours per day: You may change this as time goes on."
380 INPUT "To start, how many hours do you wish to walk per day";TW
390 IF TW > 14 THEN PRINT "That's just too ambitious." : GOTO 380
400 IF TW * RW < 7 THEN PRINT "You won't even reach NJ by Christmas." : GOTO 380
410 PRINT : PRINT "Your sensitivity to poison ivy:"
420 PRINT " (1) Highly sensitive" : PRINT " (2) Moderately sensitive"
430 PRINT " (3) Immune" : PRINT " (4) Had series of desensitization shots"
440 INPUT "Which number describes you";IVY
450 IF IVY < 1 OR IVY > 4 THEN PRINT "What's that? Let's try again." : GOTO 440
460 PRINT : PRINT "People who have hiked the Trail have different feelings ";
470 PRINT "about rain:" : PRINT " (1) Let it pour, I love it."
480 PRINT " (2) No problem as long as the sun comes out every few days."
490 PRINT " (3) Five solid days of rain really gets me down."
500 PRINT " (4) If I foresee a long stretch of rain, I'll hole up in a"
510 PRINT " shelter or motel and wait it out."
520 INPUT "Which number most closely describes your feeling";RAIN
530 IF RAIN < 1 OR RAIN > 4 THEN PRINT "Not possible. Again please." : GOTO 520
540 '
550 'Data on what to carry
560 PRINT : PRINT "You must make some decisions about what to pack."
570 FOR I = 1 TO 7 : READ SP$(I) : PRINT : PRINT SP$(I) ":"
580 FOR J = 1 TO 4 : READ ITM$(J), WHT(J), CST(J), VL(J) : PRINT J ".. " ITM$(J)
590 WEIGHT = WHT(J) : PRINT " "; : GOSUB 5430
600 IF VL(J) > 0 THEN PRINT "," VL(J) "cu in";
610 IF CST(J) > 0 THEN PRINT ", price: $" CST(J)
620 NEXT J
630 INPUT "Which one do you want (number)";A
640 IF A < 1 OR A > 4 THEN PRINT "Come on now; answer 1, 2, 3, or 4" : GOTO 630
650 ITEM$(I) = ITM$(A) : WT(I) = WHT(A) : COST(I) = CST(A) : VOL(I) = VL(A) : NEXT I
660 VOL1 = VOL(1) + VOL(5) + VOL(7) : VOL2 = VOL(3) + VOL(4) : PRINT
670 IF COST(2) > 135 THEN IF VOL(2) > 3000 + VOL1 THEN 720 ELSE 690
680 IF VOL(2) > 3000 + VOL1 + VOL2 THEN 720 : 'Internal pack hold stuff?
690 PRINT "Your pack is too small to hold all those things plus clothes and"
700 PRINT "food. You'll have to take a larger pack or some smaller items."
710 PRINT : PRINT "Let's try again…" : RESTORE : GOTO 570
720 INPUT "How many changes of underwear do you want to take";U
730 IF U > 6 THEN PRINT "This is not a picnic. Take fewer." : GOTO 720
740 INPUT "Do you want to take a walking stick (Y or N)";A$ : GOSUB 5540
750 IF A$ = "Y" THEN STK = 1 ELSE STK = 0
760 PRINT : PRINT "To summarize, here is what you have chosen:"
770 FOR I = 1 TO 7 : PRINT SP$(I) " : " ITEM$(I) : NEXT I
780 PRINT "Changes of underwear:" U
790 IF STK = 1 THEN PRINT "Walking stick."
800 PRINT " In addition, you must carry (or wear) a hat, short-sleeve shirt,
810 PRINT "chamois shirt, light jacket, long underwear, hiking shorts, long"
820 PRINT "pants, 3 pairs socks, eating gear, water bottle, soap, toilet tissue,
830 PRINT "toilet supplies, towel, first-aid kit, snakebite kit, flashlight,
840 PRINT "100' nylon cord, watch, compass, lighter, bandanna, sewing kit, insect
850 PRINT "repellent, Swiss Army knife, water-purifier tablets, notebook, maps,
860 PRINT "guidebook, stuff sacks, moleskin, camera, and money." : PRINT
870 FOR I = 1 TO 7 : WP = WP + WT(I) : CST = CST + COST(I) : NEXT I : 'Summarize weights
880 WP = WP + 190 + U * 4 : IF STK = 1 THEN WP = WP + 24
890 PRINT "If you bought everything new, the total cost would be $" 225 + CST
900 PRINT "The total weight of what you are wearing and carrying is";
910 WEIGHT = WP : GOSUB 5430 : PRINT : PRINT ".... not including food or water."
920 '
930 'Data on food
940 GOSUB 5390 : PRINT : PRINT "Common systems of food supply include:"
950 PRINT " (1) Caches buried along the trail. Pros: no wasted time leaving"
960 PRINT " the Trail for food, heavy items can be buried."
970 PRINT " (2) Food sent to post offices along the way. Pros: more flexible"
980 PRINT " than caches. Cons: P.O.s closed nights, Sat pm and Sun."
990 PRINT " (3) Grocery stores and restaurants. Pros: good variety, cheap."
1000 PRINT " Cons: wasted time leaving Trail, limited opening hours."
1010 INPUT "Which will be your major method of food supply"; FOOD
1020 IF FOOD < 1 OR FOOD > 3 THEN PRINT "Sorry, try again." : GOTO 1010
1030 IF FOOD = 1 THEN RT = 1 ELSE RT = .95 : 'Off-trail excursions reduce walking rate
1040 RM = RT : GOSUB 5510 : 'Short pause before screen clears
1050 CLS
1060 PRINT "Obviously, you will carry your food in the most efficient form:"
1070 PRINT "dried, dehydrated, concentrated, etc. However, you must specify"
1080 PRINT "the percentage of your diet accounted for by each of the following"
1090 PRINT "food groups (remember, all five must add up to 100)."
1100 PRINT " (1) Dairy foods, cheese, yogurt"
1110 PRINT " (2) Fruits and vegetables"
1120 PRINT " (3) Meat, poultry, fish, eggs"
1130 PRINT " (4) Bread, cereal, seeds, nuts,"
1140 PRINT " (5) Margarine, lard, oils, fats"
1150 CT = 0 : FOR I = 1 TO 5 : LOCATE I + 4, 39 : INPUT FD(I) : CT = CT + FD(I) : NEXT I
1160 LOCATE 10, 39 : PRINT CT "%" : PRINT
1170 IF CT = 100 THEN PRINT "Very good." : GOTO 1220
1180 PRINT "Sorry, but your percentages add up to" CT "rather than to 100%."
1190 PRINT : PRINT "Press any key when you're ready to try again."
1200 WHILE LEN(INKEY$) = 0 : WEND : GOTO 1050
1210 '
1220 'Calculate calorie usage
1230 DM = RW * TW : IF DM > 30 THEN DM = 30 : 'Desired distance = rate * time
1240 'Calories = metabolism + walking + climbing + camp activities
1250 CD = INT(WB * 11.5 + WB * DM * .3 + (WB + WP / 16) * DM * .21 + WB * (15 - TW) * .22)
1260 PRINT : PRINT "Given your weight and that of your supplies, your walking"
1270 PRINT "speed, and your walking time per day, you can expect"
1280 PRINT "to burn at least" CD "calories per day."
1290 PRINT : INPUT "How many calories worth of food do you want to eat"; CAL
1300 IF CAL > .6 * CD THEN 1330
1310 PRINT "Your body will rebel against burning that much body fat."
1320 PRINT "Better eat a bit more…" : GOTO 1290
1330 IF CAL > 1.5 * CD THEN PRINT "No blimps allowed on the trail." : GOTO 1290
1340 FWT = INT(CAL * 3.2/(4 * FD(1) + 3 * FD(2) + 4 * FD(3) + 4 * FD(4) + 9 * FD(5))) : WEIGHT = FWT
1350 PRINT "That means eating an approx food weight per day of"; : GOSUB 5430
1360 PRINT : PRINT : IF FOOD = 3 THEN DY = 2 ELSE DY = 3 : 'Avg days of food carried
1370 WADD = DY * FWT + 17 : CADD = WADD * DM * .21 : WP = WP + WADD : CD = CD + CADD
1380 PRINT "Food and water add" WADD "oz. to your trail weight bringing your"
1390 PRINT "total weight (worn and carried) to"; : WEIGHT = WP : GOSUB 5430 : PRINT
1400 PRINT : X$ = "Preparations are finally complete!" : GOSUB 5590 : GOSUB 5510
1410 '
1420 'Main Hiking Section
1430 'Initial calculations, data, and messages
1440 WP = WP / 16 : GOSUB 1930 : 'Calculate true hiking pace
1450 PRINT : PRINT : GOSUB 5100 : 'Read locations
1460 PRINT " It is April 1 and you briskly step out on the approach trail"
1470 PRINT "at Amicalola Falls, Georgia. You hike the 6.9 miles to the peak"
1480 PRINT "of Springer Mountain and sign the trail log, the first of many"
1490 PRINT "that you intend to sign. Your hike will take you through 14"
1500 PRINT "states as the Trail wanders 2007 miles along the Appalachian"
1510 PRINT "Mountains to Baxter Peak on Mt. Katahdin in Maine. It is a"
1520 PRINT "challenging trail with an average climb of 200 feet each mile."
1530 PRINT "Fewer than 2000 people have walked its entire length. Good luck!"
1540 PRINT : GOSUB 5390
1550 '
1560 'Main loop starts here
1570 T = T + 3 : TD = INT(T + .5) : PRINT : GOSUB 5200 : 'Check on the hiker every 3 days
1580 DDAYS = 3 * RM * DINPT : D = D + DDAYS : IF D > 1999 THEN 4560
1590 PRINT "You have walked" INT(D) "miles. ";
1600 FOR I = 1 TO 21 : IF D > DLC(I) - 17 AND D < DLC(I) + 17 THEN 1620 : 'Near anyplace?
1610 NEXT I : PRINT : GOTO 1630
1620 PRINT "You are near" LC$(I)
1630 IF D > 1466 THEN R(10) = .85 : TSLOW(10) = 2007 : 'Slow going in mountains
1640 GOSUB 1710 : 'Any mishaps recently?
1650 IF T > 12 THEN GOSUB 4030 : 'Long stretch of rain?
1660 IF D > 1545 AND T > 166 THEN GOSUB 4260 : 'Snow in New England
1670 IF D > 1845 AND KEN = 0 THEN GOSUB 4380 : 'Kennebec River crossing
1680 IF D > (STV + 1) * 400 THEN GOSUB 1820 : 'Allow user to reset input variables
1690 GOSUB 5390 : GOTO 1570 : 'Go back to start of hiking loop
1700 '
1710 'Subroutine to determine which mishap, if any, occurs
1720 TM = 0 : RN = INT(1 + 40 * RND(1)) : IF RN > 35 THEN RN = 36 : 'Mishap occurs
1730 IF RN > 12 THEN 1760
1740 ON RN GOSUB 2070, 2110, 2150, 2220, 2260, 2300, 2320, 2340, 2390, 2410, 2430, 2460
1750 GOTO 1800
1760 IF RN > 24 THEN 1790
1770 ON RN - 12 GOSUB 2530, 2570, 2600, 2630, 2670, 2710, 2750, 2770, 2790, 2820, 2870, 2910
1780 GOTO 1800
1790 ON RN - 24 GOSUB 2960, 2990, 3010, 3040, 3070, 3100, 3130, 3170, 3200, 3220, 3260, 3340
1800 T = T + TM : GOSUB 2020 : RETURN : 'Time delay resulting from mishap
1810 '
1820 'Subroutine to let user reset input variables
1830 STV = STV + 1 : INPUT "Want to change walking pace or hours of walking"; A$
1840 GOSUB 5540 : IF A$< >"y "THEN 1910
1850 INPUT "New walking pace (mph)"; RW
1860 IF RW < 1 OR RW > 4.5 THEN PRINT "A rate of" RW "mph is silly." : GOTO 1850
1870 INPUT "New hours per day on the trail"; TW
1880 IF TW > 14 THEN PRINT "Come now; that's just too ambitious." : GOTO 1870
1890 IF STK = 1 THEN 1910 ELSE PRINT "Want to change your mind and carry a";
1900 INPUT "walking stick";A$ : GOSUB 5540 : IF A$ = "Y" THEN STK = 1
1910 PRINT : GOSUB 1930 : RETURN
1920 '
1930 'Subroutine to establish true hiking pace
1940 DINPT = RW * TW : 'Desired distance = walking rate * hours per day
1950 IF D > 600 THEN PC = 1 : 'Under 600 miles physical condition limits mileage
1960 DMAX = 6 + 6 * (5 - PC) : IF DINPT > DMAX THEN DINPT = DMAX
1970 IF WB / WP > 6 THEN 1990 : 'Body weight to pack weight ratio under 6?
1980 DINPT = (.49 + .086 * WB / WP) * DINPT : 'Heavy pack cuts down speed
1990 IF STV = 0 THEN RETURN : 'No chance to change diet at the start
2000 GOSUB 3820 : RETURN : 'Chance to change diet as trip progresses
2010 '
2020 'Subroutine to alter hiking rate due to mishaps
2030 RM = RT : FOR I = 1 TO 10 : IF TSLOW(I) > T THEN RM = RM * R(I)
2040 NEXT I : RETURN
2050 '
2060 'Subroutines for 35 assorted mishaps follow
2070 IF D > 360 OR HZ(6) = 1 THEN RETURN ELSE TM = .5 : HZ(6) = 1
2080 PRINT "You run into Rangers on military exercises who advise you to avoid"
2090 PRINT "the trail for the next few miles because of booby traps." : RETURN
2100 '
2110 IF D < 800 OR HZ(12) = 1 THEN RETURN ELSE TM = 1 : HZ(12) = 1
2120 PRINT "The back-support strap on your backpack has worn through. You'll"
2130 PRINT "have to find a shoemaker to sew on a piece of heavy leather." : RETURN
2140 '
2150 IF D - DB < 500 THEN RETURN ELSE IF HZ(15) = 1 THEN 2180 ELSE TM = 1 : HZ(15) = 1
2160 PRINT "The soles of your boots have worn through. You'll have to get new"
2170 PRINT "soles at a shoemaker." : RETURN
2180 IF D - DB < 800 THEN RETURN ELSE TM = 1.5 : DB = D : HZ(15) = 0
2190 PRINT "Your repaired boot soles are going again. You'll have to buy a new"
2200 PRINT "pair of boots along the way." : RETURN
2210 '
2220 IF D - DB < 700 THEN RETURN ELSE IF HZ(24) = 1 THEN RETURN ELSE TM = 1 : HZ(24) = 1
2230 PRINT "The uppers on your boots are starting to separate from the soles."
2240 PRINT "You'll have to get them repaired by shoemaker." : RETURN
2250 '
2260 IF D < 1000 OR HZ(23) = 1 THEN RETURN ELSE TM = .4 : HZ(23) = 1
2270 PRINT "The seat of your pants has worn through. You can take off the"
2280 PRINT "pockets and sew them over the holes." : RETURN
2290 '
2300 TM = .3 : PRINT "Mice got into your food last night. Yuck." : RETURN
2310 '
2320 TM = .3 : PRINT "Some Boy Scouts kept you awake 'til 1 am last night." : RETURN
2330 '
2340 IF D > 900 THEN RETURN ELSE TM = .1
2350 PRINT "Curs attack you as you are walking through a small town."
2360 IF STK = 1 THEN PRINT "You drive them off with your walking stick." : RETURN
2370 PRINT "They nip at your heels. You should really carry a stick." : RETURN
2380 '
2390 TM = .3 : PRINT "Trail is poorly marked and you get temporarily lost." : RETURN
2400 '
2410 TM = .2 : PRINT "Broken zipper on your pack. Lose time drying stuff." : RETURN
2420 '
2430 TM = .3 : PRINT "Route marked on map is out of date. You lose time trying"
2440 PRINT "to get back on the trail." : RETURN
2450 '
2460 IF HZ(1) > 1 THEN RETURN ELSE TM = 2 : HZ(1) = HZ(1) + 1 : DOC = 1
2470 PRINT "You forget to shake out your boot and a snake has curled up inside"
2480 PRINT "for the night. You're scared and he's mad." : GOSUB 5510
2490 IF RND(1) < .9 THEN PRINT "He slithers away and all is okay. Whew!" : RETURN
2500 PRINT "It's a rattler and he bites you. You'll have to get a doctor."
2510 GOTO 3360
2520 '
2530 IF D > 165 OR HZ(7) = 1 THEN RETURN ELSE HZ(7) = 1 : RN = INT(1 + 4 * RND(1)) : TM = RN
2540 PRINT "Late snow in the Smokies. The trail is unpassable for" RN "days."
2550 RETURN
2560 '
2570 IF HZ(8) > 3 THEN RETURN ELSE HZ(8) = HZ(8) + 1 : R(1) = .9 : TSLOW(1) = T + 14
2580 PRINT "You have some nasty blisters that will slow your pace." : RETURN
2590 '
2600 IF HZ(9) > 2 THEN RETURN ELSE HZ(9) = HZ(9) + 1 : R(2) = .7 : TSLOW(2) = T + 3
2610 PRINT "You have bad indigestion from an unbalanced diet." : RETURN
2620 '
2630 IF D > 870 OR HZ(10) = 1 THEN RETURN ELSE HZ(10) = 1 : TM = .5
2640 PRINT "A bear got into your food and ripped your pack last night. It's"
2650 PRINT "a good thing he wasn't hungry for human burgers." : RETURN
2660 '
2670 IF HZ(11) > 1 THEN RETURN ELSE HZ(11) = HZ(11) + 1 : R(3) = .75 : TSLOW(3) = T + 6
2680 PRINT "You twisted your ankle crossing a stream. That will slow your"
2690 PRINT "pace for a few days. Be more careful!" : RETURN
2700 '
2710 IF HZ(2) = 1 THEN RETURN ELSE HZ(2) = 1 : DOC = 2
2720 PRINT "You slipped on some rocks on a ledge. It's incredibly painful!"
2730 PRINT "Better see a doctor." : GOTO 3360
2740 '
2750 TM = .3 : PRINT "A branch snaps in your eye. Lose time to treat it." : RETURN
2760 '
2770 TM = .3 : PRINT "Bad case of constipation. Better change diet." : RETURN
2780 '
2790 TM = .5 : PRINT "You fell in a stream and everything got wet. Lose time"
2800 PRINT "drying out your sleeping bag and clothes." : RETURN
2810 '
2820 IF HZ(13) = 1 THEN RETURN ELSE HZ(13) = 1 : TM = 1.5
2830 PRINT "Last night you saw an animal moving near you and swatted at it."
2840 GOSUB 5510 : PRINT "Big mistake! It was a skunk. You'll have to wash"
2850 PRINT "what you can and replace the rest." : RETURN
2860 '
2870 IF HZ(14) = 1 THEN RETURN ELSE HZ(14) = 1 : TM = 2
2880 PRINT "Lowliest of the low! Someone stole your pack while you were taking"
2890 PRINT "a shower. You'll have to replace everything." : RETURN
2900 '
2910 IF HZ(3) = 1 THEN RETURN ELSE HZ(3) = 1 : TM = 3 : DOC = 3
2920 PRINT "After five solid days of rain, everything is soaked and you just"
2930 PRINT "can't stop shivering. You feel so terrible that you'll have to"
2940 PRINT "see a doctor." : GOTO 3360
2950 '
2960 IF HZ(16) = 1 THEN RETURN ELSE HZ(16) = 1 : TM = .4
2970 PRINT "You cut your hand badly with your knife. Be careful!" : RETURN
2980 '
2990 TM = .3 : PRINT "Socks worn through. You'll have to buy new ones." : RETURN
3000 '
3010 IF HZ(17) = 1 THEN RETURN ELSE HZ(17) = 1 : TM = 1
3020 PRINT "Bad toothache. You'll have to find a dentist soon." : RETURN
3030 '
3040 IF HZ(18) = 2 OR WT(1) = 0 THEN RETURN ELSE HZ(18) = HZ(18) + 1 : TM = .5
3050 PRINT "Tent ripped. You'll have to sew on a patch." : RETURN
3060 '
3070 IF D < 1000 OR HZ(19) = 1 THEN RETURN ELSE HZ(19) = 1 : TM = .3
3080 PRINT "Your groundcloth is in shreds. Must buy a new one." : RETURN
3090 '
3100 IF D < 500 OR HZ(20) = 1 OR WT(7) = 0 THEN RETURN ELSE HZ(20) = 1 : TM = .4
3110 PRINT "Bad rip in raingear. Must get a replacement." : RETURN
3120 '
3130 IF D < 600 OR HZ(21) = 1 OR STK = 0 THEN RETURN ELSE HZ(21) = 1 : R(4) = .9 : TM = .4
3140 PRINT "Your walking stick breaks. You can get a new one in the next"
3150 PRINT "town. Maybe they make 'em better up here." : TSLOW(4) = T + 4 : RETURN
3160 '
3170 IF HZ(22) = 1 THEN RETURN ELSE HZ(22) = 1 : TM = .4
3180 PRINT "Your water bag springs a leak. Better get a new one soon!" : RETURN
3190 '
3200 TM = .2 : PRINT "You run out of toilet tissue. Yucko!" : RETURN
3210 '
3220 PRINT "You run out of water and the springs marked on the map seem"
3230 PRINT "to have vanished or dried up. Better take it easy for a bit."
3240 HZ(5) = 1 : R(5) = .9 : TSLOW(5) = T + 3 : RETURN
3250 '
3260 IF HZ(4) = 3 THEN RETURN ELSE HZ(4) = HZ(4) + 1 : DOC = 4
3270 PRINT "Oh oh, you stumble into a thicket of poison ivy. Zowie!"
3280 IF IVY = 1 OR (IVY = 2 AND RND(1) > .5) THEN 3290 ELSE 3300
3290 PRINT "You got it really bad. You'll have to see a doctor." : GOTO 3360
3300 PRINT "Like it or not, you got a mild case. It itches like crazy but the"
3310 PRINT "calamine seems to have it under control. It slows you down tho'."
3320 R(6) = .9 : TSLOW(6) = T + 7 : TM = .4 : RETURN
3330 '
3340 PRINT "Walking…walking…walking…walking." : RETURN
3350 '
3360 'Subroutine to deal with serious injuries and illnesses
3370 PRINT : PRINT "You're feeling horrible, but you found a nice country doctor."
3380 ON DOC GOTO 3410, 3480, 3570, 3640, 3700
3390 '
3400 'Rattlesnake bite
3410 PRINT "He examines your swollen leg and says," : GOSUB 5510
3420 PRINT "'Good thing you got here so quickly. I'll give you a shot of anti-"
3430 PRINT "venin but you're going to be out of commission for a good 4 days—"
3440 PRINT "and even after that you'll have to take it easy for a while.'"
3450 TM = 4 : R(7) = .7 : TSLOW(7) = T + 15 : RETURN
3460 '
3470 'Broken or sprained leg
3480 PRINT "He examines your leg and says," : GOSUB 5510 : IF RND(1) > .7 THEN 3520
3490 PRINT "'That's a very nasty sprain. I'll tape it up, but you'll have to"
3500 PRINT "take it easy for at least a month.'"
3510 TM = 1.5 : R(8) = .6 : TSLOW(8) = T + 30 : RETURN
3520 PRINT "'Bad news, my young friend. Your leg is broken. I'm surprised you"
3530 PRINT "got here under your own power. But this is the end of your hike."
3540 PRINT "Sorry, but maybe you can try again next year.'" : GOTO 4610
3550 '
3560 'Hypothermia
3570 PRINT "He examines you and says," : GOSUB 5510 : TM = INT(5 + 6 * RND(1))
3580 PRINT "'That prolonged rain and cold has put you in a condition that we"
3590 PRINT "call hypothermia. You can stay in town here at a motel and I'll"
3600 PRINT "keep an eye on you, but you can't go back on the Trail for at"
3610 PRINT "least" TM "days. Sorry, but that's the way it is.'" : RETURN
3620 '
3630 'Poison Ivy
3640 PRINT "He only needs a glance to see that you are suffering from an"
3650 PRINT "extremely bad case of poison ivy. He puts you in a clinic for"
3660 PRINT "a few days and tells you what you already knew—that you'll just"
3670 PRINT "have to let it run its course." : TM = 5 : RETURN
3680 '
3690 'Excessive weight loss
3700 PRINT "He examines you and says," : GOSUB 5510 : IF WTLOST > .33 * WB THEN 3770
3710 PRINT "'You may want to lose some weight, but it's coming off far too"
3720 PRINT "quickly. Your body just can't cope. I'm going to keep you here"
3730 PRINT "for a week on a controlled diet—and then for the rest of the trip"
3740 PRINT "you'll have to go at a slower pace. Also, I want you to consume"
3750 PRINT "at least as many calories per day as your body is using up.'"
3760 WB = 1.18 * WB : TM = 7 : R(9) = .8 : TSLOW(9) = T + 30 : RETURN
3770 PRINT "'Believe it or not, you are in an advanced stage of starvation."
3780 PRINT "You're going to have to remain here for a few weeks on a controlled"
3790 PRINT "diet to stabilize your body chemistry. And then you will go home—"
3800 PRINT "yes, HOME, and not back to the Trail this year.'" : GOTO 4610
3810 '
3820 'Subroutine to examine weight loss
3830 CALOFF = CD - 1.03 * CAL : 'Augment diet by 3% with ice cream, etc.
3840 TS = T - TL : TL = T : 'Time (in days) of this trip segment
3850 WTLOSS = CALOFF * TS / 3500 : WTLOST = WTLOST + WTLOSS : IF WTLOSS < 1 THEN RETURN
3860 PRINT "Since the start of the trip, you have lost" INT(WTLOST) "pounds."
3870 IF WTLOST > .07 * WB THEN 3900 : 'Lost more than 7% of orig body weight?
3880 PRINT "Right now you are feeling fit as a fiddle, but remember, you"
3890 PRINT "still have a long way to go." : GOTO 3970
3900 IF WTLOST>.15 * WB THEN 3930 : 'Lost more than 15% of orig body weight?
3910 PRINT "You occasionally feel a bit lightheaded and shaky. You really"
3920 PRINT "should eat a bit more." : GOTO 3970
3930 PRINT "That's far too much weight to lose in this short period of time."
3940 IF WTLOST > .24 * WB THEN HZ(5) = 1 : DOC = 5 : GOSUB 3360 : GOTO 3970
3950 PRINT "You frequently feel lightheaded, nauseated, and sluggish. You'd"
3960 PRINT "better add to your diet…and soon!"
3970 WB = WB.WTLOSS : CD = INT(WB * 11.5 + WB * DINPT * .3 + (WB + WP) * DINPT * .21 + WB * (15 - TW) * .22)
3980 PRINT "At your current pace, you are burning" CD "calories per day."
3990 PRINT : INPUT "How many calories worth of food do you want to eat";CAL
4000 IF CD - CAL > 400 THEN PRINT "Okay, suit yourself."
4010 RETURN
4020 '
4030 'Subroutine to deal with a long period of rain
4040 IF RND(1) < .94 THEN HZ(5) = 0 : RETURN : '6% chance of heavy rain
4050 IF HZ(5) = 1 THEN HZ(5) = 0 : RETURN : 'In a dry stretch?
4060 HZ(25) = HZ(25) + 1 : TM = RAIN * 1.7 : IF HZ(25) > 4 THEN HZ(25) = 4
4070 ON HZ(25) GOTO 4080, 4130, 4150, 4180
4080 PRINT "It has been raining steadily for the past week and you are"
4090 PRINT "thoroughly soaked—your clothes, your sleeping bag, your food,"
4100 PRINT "and, yes, your spirits. What a bummer." : GOSUB 5510
4110 PRINT "If it continues for another week, you're going to have fungus"
4120 PRINT "growing on your skin." : RETURN
4130 PRINT "Good grief! More rain—torrential, blustery, miserable rain."
4140 PRINT "This is really beginning to get you down." : RETURN
4150 PRINT "Would you believe it? It is raining again. Not the pitter-patter"
4160 PRINT "of the songwriters, but steady, heavy, cold rain." : GOSUB 5510
4170 PRINT "…and more rain. Won't it ever stop?" : RETURN
4180 PRINT "Unbelievable…it is raining again…and has been for the past week.
4190 IF (RAIN = 2 OR RAIN = 3) AND D < 1900 THEN 4230 ELSE RETURN
4200 IF RAIN = 4 THEN PRINT "Okay, you resign yourself to wait it out." : RETURN
4210 PRINT "Even your cheerful attitude toward rain is taking a beating, but"
4220 PRINT "you keep slogging along, hoping for a letup." : RETURN
4230 GOSUB 5510 : PRINT : PRINT "That's it. You can't take any more. Maybe"
4240 PRINT "you'll try again next year, but that's it for now." : GOTO 4610
4250 '
4260 'Subroutine to deal with snow in New England
4270 IF T > 200 AND RND(1) > .5 THEN 4290 : '50% chance of snow after Oct 15
4280 IF RND(1) > .2 THEN RETURN : '20% chance of snow
4290 SNO = SNO + 1 : PRINT "Oh oh, New England is getting some snow…"
4300 IF SNO = 1 THEN PRINT "but you keep pushing on." : RETURN
4310 IF SNO > 2 THEN 4350 : '3 heavy snowfalls and you're out
4320 PRINT "You pushed through the last flurries but this looks"
4330 PRINT "more serious. You say to yourself, 'I've gone this"
4340 PRINT "far, I'm going to go all the way.' And on you go…" : RETURN
4350 PRINT "You made a gallant attempt to get through, but the Park"
4360 PRINT "Rangers won't let you go on. Too bad." : GOTO 4610
4370 '
4380 'Subroutine to deal with the Kennebec River
4390 KEN = 1 : PRINT : PRINT "You have arrived at the Kennebec River."
4400 INPUT "Did you make prior arrangements to get across";A$ : GOSUB 5540
4410 IF A$< >"Y" THEN 4450 ELSE RN = RND(1) : IF RN > .5 THEN 4440
4420 PRINT "Fortunately the person you called showed up to meet you with"
4430 PRINT "a canoe. You get across in jig time." : TM = .5 : GOTO 4540
4440 GOSUB 5510 : PRINT "Too bad; the guy you called didn't show up." : GOTO 4460
4450 PRINT "That wasn't very sensible. What will you do now?" : GOSUB 5510
4460 IF RND(1) > .7 THEN 4520 : '30% chance you can ford the river
4470 PRINT "The river is running very high and the logs from the sawmill are"
4480 PRINT "very dangerous. You'll have to hang around until another hiker"
4490 PRINT "(who, hopefully, has arranged for a canoe) shows up or hope that"
4500 PRINT "someone comes along." : GOSUB 5510 : TM = INT(2 + 3 * RND(1))
4510 PRINT "Finally…you're across, but it cost you" TM "days." : GOTO 4540
4520 PRINT "Fortunately the river isn't running too high and you can probably"
4530 PRINT "wade across downstream at the ford. Boy, were you lucky!" : TM = .6
4540 T = T + TM : RETURN
4550 '
4560 'Reached end of trail!
4570 PRINT "You reached the end of the trail at Baxter Peak on Mt. Katahdin!"
4580 FOR J = 1 TO 3 : GOSUB 5510 : NEXT J : CLS : FOR J = 1 TO 10
4590 BEEP : X$ = "CONGRATULATIONS!" : LOCATE 12, 1 : GOSUB 5590
4600 FOR I = 1 TO 100 : NEXT I : CLS : FOR I = 1 TO 50 : NEXT I : NEXT J : D = 2007
4610 TD = INT(T + .5) : D = INT(D) : X = (INT(.5 + 10 * D / TD)) / 10 : 'End game statistics
4620 PRINT : PRINT "It is now "; : GOSUB 5220 : PRINT "and you have been on the"
4630 PRINT "trail for" TD "days. You have covered" D "miles. Your average"
4640 PRINT "speed, considering all the delays, was ";
4650 PRINT USING "##.#";X; : PRINT " miles per day."
4660 WB = INT(WB + .5) : WL = INT(WTLOST + .5) : IF WL > 0 THEN X$ = "less" : GOTO 4680
4670 X$ = "more" : WL = -WL
4680 PRINT "You weighed" WB "pounds at the end," WL X$ " than at the start."
4690 PRINT "Nice going!"
4700 PRINT : INPUT "Would you like to try again (Y or N)"; A$ : GOSUB 5540
4710 IF A$ = "Y" THEN RUN ELSE CLS : KEY ON : END
4720 '
4730 'Names of items that can be carried
4740 DATA "Tent"
4750 DATA "Sierra Designs Divine Light, 20 sq ft, max height 34 in.", 35, 135, 214
4760 DATA "Eureka! Crescent Bike, 22 sq ft, height 43 in.", 48, 125, 353
4770 DATA "Moss Starlet, 29 sq ft; with vestibule, 37; height 39 in.", 78, 250, 334
4780 DATA "None. Use trail shelters and sleep in open.", 0, 0, 0
4790 DATA "Pack"
4800 DATA "Kelty Mountaineer external - frame with Seneca pack", 69, 139, 3975
4810 DATA "Jansport D2 external - frame pack", 99, 169, 5520
4820 DATA "Camp Trails Grey Wolf internal - frame pack, large", 82, 119, 5975
4830 DATA "Coleman Peak 1 model 680 internal - frame pack", 58, 115, 4013
4840 DATA "Sleeping bag"
4850 DATA "North Face Blue Kazoo, mummy, goose down, rated 25 deg", 34, 140, 452
4860 DATA "Slumberjack Bike Lite, mummy, Quallofil, rated 30 deg", 50, 65, 808
4870 DATA "REI 747 Wide Body, semi-rect, Quallofil, rated 30 deg", 54, 90, 1884
4880 DATA "L.L. Bean Ultra - Lite, rectangular, Quallofil, rated 35 deg", 58, 80, 804
4890 DATA "Sleeping pad/mattress"
4900 DATA "Sevylor Superlight air mattress", 32, 20, 360
4910 DATA "Therm-A-Rest self - inflating ultra-lite pad", 28, 48, 325
4920 DATA "Ensolite 1/2 in. pad", 24, 23, 300
4930 DATA "None.", 0, 0, 0
4940 DATA "Stove"
4950 DATA "MSR Whisperlite, uses white gas (available along trail)", 18, 37, 120
4960 DATA "Gaz Bleuet, fuel: butane cartridge (light and reliable)", 16, 20, 106
4970 DATA "Primus Grasshopper, fuel: propane cylinder (long life)", 22, 19, 90
4980 DATA "None (incidentally, wood fires are PROHIBITED on the trail)", 0, 0, 0
4990 DATA "Boots"
5000 DATA "Asolo Trail II S, mid-ankle leather boots", 49, 140, 0
5010 DATA "Danner Featherlight Trail, mid-ankle leather & Gore-Tex boot", 52, 95, 0
5020 DATA "Timberland Lightweight Hiker, mid-ankle fabric and Gore-Tex", 46, 50, 0
5030 DATA "Raichle Montagnas, full-height leather boots", 80, 125, 0
5040 DATA "Raingear"
5050 DATA "Early Winters Ultralight Gore-Tex rain parka" 13, 145, 25
5060 DATA "Patagonia featherweight Gore-Tex shell" 7, 58, 15
5070 DATA "Campmor nylon poncho", 16, 25, 22
5080 DATA "None.", 0, 0, 0
5090 '
5100 FOR I = 1 TO 21 : READ DLC(I), LC$(I) : NEXT I : RETURN
5110 DATA 79, "Bly Gap, GA", 165, "Doe Knob, NC", 302, "Big Bald Mt., NC"
5120 DATA 384, "Wilbur Lake, TN", 483, "Big Walker Lookout, VA", 602, "Tinker Mt., VA"
5130 DATA 698, "Salt Log Gap, VA", 800, "Fishers Gap, VA", 889, "Potomac River, WV"
5140 DATA 966, "Piney Mt., PA", 1099, "Baer Rocks, PA", 1190, "High Point, NC"
5150 DATA 1272, "Shenandoah Mt., NY", 1361, "Sages Ravine, CT", 1435
5160 DATA "Mt. Greylock, MA", 1554, "Killington, VT", 1687, "Mt. Washington, NH"
5170 DATA 1776, "Bemis Pond, ME", 1855, "Kennebec River, ME", 1922
5180 DATA "Chairback Mt., ME", 1992, "Penobscot West Branch, ME"
5190 '
5200 'Subroutine to print the date
5210 IF TT = TD THEN RETURN : 'Printed this date already?
5220 IF TD < 31 THEN 5250 ELSE IF TD < 62 THEN 5260 ELSE IF TD < 90 THEN 5270
5230 IF TD < 121 THEN 5280 ELSE IF TD < 152 THEN 5290 ELSE IF TD < 182 THEN 5300
5240 IF TD < 213 THEN 5310 ELSE IF TD < 225 THEN 5320 ELSE GOTO 5340
5250 MO$ = "April" : MD = TD : GOTO 5330
5260 MO$ = "May" : MD = TD - 30 : GOTO 5330
5270 MO$ = "June" : MD = TD - 61 : GOTO 5330
5280 MO$ = "July" : MD = TD - 89 : GOTO 5330
5290 MO$ = "August" : MD = TD - 120 : GOTO 5330
5300 MO$ = "September" : MD = TD - 151 : GOTO 5330
5310 MO$ = "October" : MD = TD - 181 : GOTO 5330
5320 MO$ = "November" : MD = TD - 212
5330 PRINT MO$; MD; : TT = TD : RETURN
5340 PRINT : PRINT "It's November 12 and all the New England states are covered"
5350 PRINT "with snow. You have no chance of finishing the trail. Better"
5360 PRINT "luck next year. You have been out on the"
5370 TD = INT(T + .5) : D = INT(D) : X = (INT(.5 + 10 * D / TD)) / 10 : GOTO 4630
5380 '
5390 'Subroutine to temporarily break execution
5400 PRINT : X$ = "Press any key to continue" : GOSUB 5590
5410 WHILE LEN(INKEY$) = 0 : WEND : PRINT : RETURN
5420 '
5430 'Subroutine to print weights by pounds and ounces
5440 WTPND = INT(WEIGHT / 16) : WTOZ = WEIGHT - 16 * WTPND
5450 IF WTPND > 1 THEN PRINT WTPND "pounds"; : GOTO 5470
5460 IF WTPND = 1 THEN PRINT " 1 pound"; : GOTO 5470
5470 IF WTOZ > 1 THEN PRINT WTOZ "ounces"; : RETURN
5480 IF WTOZ = 1 THEN PRINT " 1 ounce";
5490 RETURN
5500 '
5510 'Subroutine to make a short pause
5520 FOR I = 1 TO 900 : NEXT I : RETURN
5530 '
5540 'Subroutine to extract the first letter of an input answer
5550 IF A$ = "" THEN A$ = "Y" : RETURN
5560 A$ = LEFT$(A$, 1) : IF A$ >= "A" AND A$ <= "Z" THEN RETURN
5570 A$ = CHR$(ASC(A$) - 32) : RETURN
5580 '
5590 'Subroutine to print centered lines
5600 PRINT TAB((70 - LEN(X$)) / 2) X$; : RETURN
5610 '
5620 'Subroutine to print the instructions
5630 X$ = "Appalachian Trail" : GOSUB 5590 : PRINT : PRINT
5640 PRINT " You are a hiker whose goal is to walk the entire 2007 miles of"
5650 PRINT "the Appalachian Trail from Springer Mt., GA, to Mt. Katahdin, Maine."
5660 PRINT "You set out in April as soon as the Smokies are clear of snow, and"
5670 PRINT "you must reach the northern terminus before it is blocked by snow."
5680 PRINT " Your hike is divided into three-day segments. Along the way,"
5690 PRINT "you encounter natural hazards, difficulties with your equipment,"
5700 PRINT "and physical problems."
5710 PRINT " Careful planning for your hike is very important. In deciding"
5720 PRINT "what to pack, you have to make trade-offs—generally between weight"
5730 PRINT "and comfort. Of course, everything must fit in your pack."
5740 PRINT " You must decide how you will obtain food along the route, how"
5750 PRINT "much to eat in each food group, and how many calories to replenish."
5760 PRINT " You must decide at what pace you will walk, and how long to"
5770 PRINT "hike each day. Of course, a faster pace will cover mileage more"
5780 PRINT "quickly than a slower one, but it is much harder on your body."
5790 PRINT " You don't have many choices when dealing with mishaps. It is"
5800 PRINT "assumed that you are a sensible hiker, make repairs when necessary,"
5810 PRINT "replace things that wear out, and see a doctor if you get sick."
5820 PRINT "Nevertheless, mishaps cost you time, of which you have little to"
5830 PRINT "spare as you take another of the five million steps towards Maine."
5840 PRINT : X$ = "Press any key when you're ready to go." : GOSUB 5590 : RETURN