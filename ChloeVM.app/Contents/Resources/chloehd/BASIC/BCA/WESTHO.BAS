100 CLS : KEY OFF
110 LOCATE 10, 31 : PRINT "Westward Ho! 1847" : PRINT : PRINT
120 PRINT TAB(28) "(c) David H. Ahl, 1986" : LOCATE 23, 21
130 '
140 'Initialization
150 DIM DA$(20), EP(20), MP(15), PL$(15)
160 GOSUB 3430 : GOSUB 3530 : GOSUB 3700 : 'Put data in variables
170 PRINT "Press any key when you're ready to go" : RN = -32768!
180 WHILE LEN(INKEY$) = 0 : RN = RN + 1 : WEND
190 WHILE RN > 32767 : RN = RN - 65535! : WEND : RANDOMIZE RN : CLS
200 GOSUB 490 : 'Display the scenario
210 GOSUB 690 : 'Make initial purchases
220 GOSUB 920 : 'How good a shot are you?
230 PRINT : PRINT " Your trip is about to begin…" : PRINT : GOSUB 3830
240 '
250 'Main program
260 IF M > 2039 THEN 3190 : 'Reached the final segment?
270 J = J + 1 : 'Iterate through 2-week trip segments
280 IF J > 20 THEN 3080 : 'On the trail too long?
290 PRINT : PRINT "Monday, " DA$(J) ", 1847. You are ";
300 FOR I = 1 TO 15 : IF M > MP(I) THEN NEXT I ELSE PRINT PL$(I)
310 IF F < 6 THEN PRINT "You're low on food. Better buy some or go hunting soon."
320 IF KS< >1 AND KH< >1 THEN 370 : 'Any sickness or injuries?
330 T = T - 10 : IF T < 0 THEN 3010 ELSE PRINT "Doctor charged $10 for his services";
340 PRINT "to treat your "; : IF KS = 1 THEN PRINT "illness." ELSE PRINT "injuries."
350 KS = 0 : KH = 0 : 'Set illness and injury flags to normal
360 M = INT(M) : MA = M : 'Update cumulative mileage
370 IF MP = 1 THEN PRINT "Total mileage to date is 950." : MP = 0 : GOTO 400
380 PRINT "Total mileage to date is" INT(M + .5)
390 M = M + 200 + (A - 110) / 2.5 + 10 * RND(1) : 'Calculate how far we travel in 2 weeks
400 PRINT "Here's what you now have (no. of bullets, $ worth of other items) :"
410 GOSUB 3350 : 'Print inventory
420 GOSUB 1000 : 'Stop at fort, hunt, or push on routine
430 GOSUB 1310 : 'Eating routine
440 GOSUB 1390 : PRINT : 'Riders - attack routine
450 GOSUB 1800 : PRINT : 'Hazards - and - events routine
460 GOSUB 2640 : 'Mountains routine
470 GOTO 260 : 'End of the 2-week trip segment
480 '
490 'Subroutine to print initial scenario
500 PRINT TAB(23) "Westward Ho! 1847" : PRINT
510 PRINT " Your journey over the Oregon Trail takes place in 1847. Start."
520 PRINT "ing in Independence, Missouri, you plan to take your family of"
530 PRINT "five over 2040 tough miles to Oregon City."
540 PRINT " Having saved $420 for the trip, you bought a wagon for $70 and"

550 PRINT "now have to purchase the following items :" : PRINT
560 PRINT " * Oxen (spending more will buy you a larger and better team which"
570 PRINT " will be faster so you'll be on the trail for less time)"
580 PRINT " * Food (you'll need ample food to keep up your strength and health)"
590 PRINT " * Ammunition ($1 buys a belt of 50 bullets. You'll need ammo for"
600 PRINT " hunting and for fighting off attacks by bandits and animals)"
610 PRINT " * Clothing (you'll need warm clothes, especially when you hit the"
620 PRINT " snow and freezing weather in the mountains)"
630 PRINT " * Other supplies (includes medicine, first-aid supplies, tools, and"
640 PRINT " wagon parts for unexpected emergencies)" : PRINT
650 PRINT " You can spend all your money at the start or save some to spend"
660 PRINT "at forts along the way. However, items cost more at the forts. You"
670 PRINT "can also hunt for food if you run low." : PRINT : RETURN
680 '
690 'Subroutine to get initial purchases of player
700 PRINT : INPUT "How much do you want to pay for a team of oxen";A : A = INT(A)
710 IF A < 100 THEN PRINT "No one in town has a team that cheap." : GOTO 700
720 IF A < 151 THEN 760
730 PRINT "You choose an honest dealer who tells you that $" A "is too much for"
740 PRINT "a team of oxen. He charges you $150 and gives you $" A.150 "change."
750 A = 150
760 INPUT "How much do you want to spend on food";F : F = INT(F)
770 IF F > 13 THEN 790 ELSE PRINT "That won't even get you to the Kansas River";
780 PRINT " — better spend a bit more." : GOTO 760
790 IF A + F > 300 THEN PRINT "You won't have any for ammo and clothes." : GOTO 760
800 INPUT "How much do you want to spend on ammunition";B : B = INT(B)
810 IF B < 2 THEN PRINT "Better take a bit just for protection." : GOTO 800
820 IF A + F + B > 320 THEN PRINT "That won't leave any money for clothes." : GOTO 800
830 INPUT "How much do you want to spend on clothes";C : C = INT(C)
840 IF C > 24 THEN 860 ELSE PRINT "Your family is going to be mighty cold in";
850 PRINT " the mountains." : PRINT "Better spend a bit more." : GOTO 830
860 IF A + F + B + C > 345 THEN PRINT "That leaves nothing for medicine." : GOTO 830
870 INPUT "How much for medicine, bandages, repair parts, etc.";R
880 R = INT(R) : IF R < 5 THEN PRINT "That's not at all wise." : GOTO 870
890 IF A + F + B + C + R > 350 THEN PRINT "You don't have that much money." : GOTO 870
900 T = 350 - A - F - B - C - R : PRINT : PRINT "You now have $" T "left." : B = 50 * B : RETURN
910 '
920 'Subroutine to initialize shooting routine
930 PRINT : PRINT "Please rank your shooting (typing) ability as follows :"
940 PRINT " (1) Ace marksman (2) Good shot (3) Fair to middlin'"
950 PRINT " (4) Need more practice (5) Shaky knees"
960 INPUT "How do you rank yourself";DR
970 IF DR > 1 AND DR < 6 THEN RETURN
980 PRINT "Please enter 1, 2, 3, 4, or 5." : GOTO 960
990 '
1000 'Subroutine to stop at fort, hunt, or push on
1010 IF INT(J / 2)< >J / 2 THEN 1060 : 'Are we on an even trip segment?
1020 INPUT "Want to (1) stop at next fort, (2) hunt, or (3) push on";X
1030 IF X < 1 OR X > 3 THEN PRINT "Enter a 1, 2, or 3 please." : GOTO 1020
1040 IF X = 3 THEN RETURN ELSE ON X GOSUB 1100, 1200
1050 IF KQ = 1 THEN 1020 ELSE RETURN : 'Not enough ammo to hunt?
1060 INPUT "Would you like to (1) hunt or (2) continue on";X
1070 IF X < 1 OR X > 2 THEN PRINT "Enter a 1 or 2 please." : GOTO 1060
1080 IF X = 2 THEN RETURN ELSE GOSUB 1200 : RETURN
1090 '
1100 'Subroutine to stop at a fort
1110 IF T > 0 THEN 1130 ELSE PRINT "You sing with the folks there and get a good"
1120 PRINT "night's sleep, but you have no money to buy anything." : RETURN
1130 PRINT "What would you like to spend on each of the following;"
1140 INPUT "Food";P1 : INPUT "Ammunition";P2 : INPUT "Clothing";P3
1150 INPUT "Medicine and supplies";P4 : P = P1 + P2 + P3 + P4 : P1 = .67 * P1 : P2 = 33 * P2
1160 PRINT "The storekeeper tallies up your bill. It comes to $" P
1170 IF T >= P THEN T = T - P : F = F + P1 : B = B + P2 : C = C + .67 * P3 : R = R + .67 * P4 : RETURN
1180 PRINT "Uh, oh. That's more than you have. Better start over." GOTO 1130
1190 '
1200 'Subroutine to hunt
1210 KQ = 0 : IF B > 39 THEN 1230 : 'Enough ammo to hunt?
1220 PRINT "Tough luck. You don't have enough ammo to hunt." : KQ = 1 : RETURN
1230 M = M - 45 : GOSUB 3870 : IF BR <= 1 THEN 1270
1240 IF 100 * RND(1) < 13 * BR THEN 1290
1250 PRINT "Nice shot…right on target…good eatin' tonight!"
1260 F = F + 24 - 2 * BR : B = B - 10 - 3 * BR : RETURN
1270 PRINT "Right between the eyes…you got a big one!" : F = F + 26 + 3 * RND(1)
1280 PRINT "Full bellies tonight!" : B = B - 10 - 4 * RND(1) : RETURN
1290 PRINT "You missed completely…and your dinner got away." : RETURN
1300 '
1310 'Subroutine to eat
1320 IF F < 5 THEN 3000 : 'Not enough food?
1330 INPUT "Do you want to eat (1) poorly (2) moderately or (3) well";E
1340 IF E < 1 OR E > 3 THEN PRINT "Enter a 1, 2, or 3, please." : GOTO 1330
1350 F = F - 4 - 2.5 * E : IF F > 0 THEN RETURN : 'Eating more food than you have?
1360 IF E = 1 THEN RETURN
1370 F = F + 4 + 2.5 * E : PRINT "You don't have enough to eat that well." : GOTO 1330
1380 '
1390 'Subroutine for riders attack
1400 IF RND(1) * 10 > ((M / 100 - 4) ^ 2 + 72) / ((M / 100 - 4) ^ 2 + 12) - 1 THEN RETURN
1410 X$ = "" : GH = 0 : IF RND(1) > .2 THEN X$ = "don't " : GH = 1
1420 PRINT : PRINT "Riders ahead! They " X$ "look hostile."
1430 PRINT "You can (1) run, (2) attack, (3) ignore them, or (4) circle wagons."
1440 INPUT "What do you want to do";GT
1450 IF GT < 1 OR GT > 4 THEN PRINT "Please enter 1, 2, 3, or 4." : GOTO 1440
1460 IF RND(1) < .2 THEN GH = 1 - GH : 'Maybe they're hostile after all
1470 IF GH = 1 THEN 1680 : 'Are they friendly?
1480 ON GT GOTO 1510, 1540, 1610, 1650
1490 '
1500 'Try to run away
1510 M = M + 20 : R = R - 7 : B = B - 150 : A = A - 20 : GOTO 1730 : 'Lose stuff when you run
1520 '
1530 'Attack the riders
1540 GOSUB 3870 : B = B - BR * 40 - 80 : 'Firefight uses ammo
1550 IF BR <= 1 THEN PRINT "Nice shooting — you drove them off." : GOTO 1730
1560 IF BR <= 4 THEN PRINT "Kind of slow with your Colt .45." : GOTO 1730
1570 PRINT "Pretty slow on the draw, partner. You got a nasty flesh wound."
1580 KH = 1 : PRINT "You'll have to see the doc soon as you can." : GOTO 1730
1590 '
1600 'Ignore the riders
1610 IF RND(1) > .8 THEN PRINT "They did not attack. Whew!" : RETURN
1620 B = B - 150 : R = R - 7 : GOTO 1730
1630 '
1640 'Circle wagons
1650 GOSUB 3870 : B = B - BR * 30 - 80 : M = M - 25 : GOTO 1550
1660 '
1670 'Cost of each tactic if riders were friendly
1680 IF GT = 1 THEN M = M + 15 : A = A - 5 : GOTO 1730
1690 IF GT = 2 THEN M = M - 5 : B = B - 100 : GOTO 1730
1700 IF GT = 3 THEN 1730 ELSE M = M - 20
1710 '
1720 'Final messages about riders
1730 IF GH = 0 THEN 1750 : 'Were riders hostile?
1740 PRINT "Riders were friendly, but check for possible losses." : RETURN
1750 PRINT "Riders were hostile. Better check for losses!"
1760 IF B >= 0 THEN RETURN ELSE PRINT : GOSUB 3740 : PRINT "Oh, my gosh!";
1770 PRINT "They're coming back and you're out of ammo! Your dreams turn to"
1780 PRINT "dust as you and your family are massacred on the prairie." : GOTO 3110
1790 '
1800 'Subroutine to deal with hazards and special events
1810 RN = 100 * RND(1) : 'RN determines which event happens
1820 FOR I = 1 TO 15 : 'Iterate through possible events
1830 IF RN > EP(I) THEN NEXT I : I = 16 : 'If event happened, exit loop
1840 IF I > 8 THEN 1860
1850 ON I GOTO 1880, 1910, 1940, 1980, 2010, 2040, 2080, 2180
1860 ON I - 8 GOTO 2290, 2320, 2350, 2410, 2440, 2530, 2560, 2610
1870 '
1880 PRINT "Your wagon breaks down. It costs you time and supplies to fix it."
1890 M = M - 15 - 5 * RND(1) : R = R - 4 : RETURN
1900 '
1910 PRINT "An ox gores your leg. That slows you down for the rest of the trip."
1920 M = M - 25 : A = A - 10 : RETURN
1930 '
1940 PRINT "Bad luck…your daughter breaks her arm. You must stop and"
1950 PRINT "make a splint and sling with some of your medical supplies."
1960 M = M - 5 - 4 * RND(1) : R = R - 1 - 2 * RND(1) : RETURN
1970 '
1980 PRINT "An ox wanders off and you have to spend time looking for it."
1990 M = M - 17 : RETURN
2000 '
2010 PRINT "Your son gets lost and you spend half a day searching for him."
2020 M = M - 10 : RETURN
2030 '
2040 PRINT "Nothing but contaminated and stagnant water near the trail."
2050 PRINT "You lose time looking for a clean spring or creek."
2060 M = M - 2 - 10 * RND(1) : RETURN
2070 '
2080 IF M > 950 THEN 2130 : 'If in mountains, go to snow; otherwise rain
2090 PRINT "Heavy rains. Traveling is slow in the mud and you break your spare"
2100 PRINT "ox yoke using it to pry your wagon out of the mud. Worse yet, some"
2110 PRINT "of your ammo is damaged by the water."
2120 M = M - 5 - 10 * RND(1) : R = R - 7 : B = B - 400 : F = F - 5 : RETURN
2130 PRINT "Cold weather…Brrrrrrr!…You ";
2140 IF C < 11 + 2 * RND(1) THEN PRINT "don't "; : C1 = 1
2150 PRINT "have enough clothing to keep warm."
2160 IF C1 = 0 THEN RETURN ELSE GOSUB 2880 : RETURN
2170 '
2180 PRINT "Bandits attacking!" : GOSUB 3870
2190 B = B - 20 * BR : IF B > 0 THEN 2220 ELSE T = T / 3
2200 PRINT "You try to drive them off but you run out of bullets."
2210 PRINT "They grab as much cash as they can find." : GOTO 2230
2220 IF BR <= 1 THEN 2260 : 'Good response time?
2230 PRINT "You get shot in the leg — "; : GOSUB 3740 : KH = 1
2240 PRINT "and they grab one of your oxen." : A = A - 10 : R = R - 2
2250 PRINT "Better have a doc look at your leg…and soon!" : RETURN
2260 PRINT "That was the quickest draw outside of Dodge City."
2270 PRINT "You got at least one and drove 'em off." : RETURN
2280 '
2290 PRINT "You have a fire in your wagon. Food and supplies are damaged."
2300 M = M - 15 : F = F - 20 : B = B - 400 : R = R - 2 * 6 * RND(1) : RETURN
2310 '
2320 PRINT "You lose your way in heavy fog. Time lost regaining the trail."
2330 M = M - 10 - 5 * RND(1) : RETURN
2340 '
2350 PRINT "You come upon a rattlesnake and before you are able to get your gun"
2360 PRINT "out, it bites you." : B = B - 10 : R = R - 2 : IF R < 0 THEN 2390
2370 PRINT "Fortunately, you acted quickly, sucked out the poison, and"
2380 PRINT "treated the wound. It is painful, but you'll survive." : RETURN
2390 PRINT "You have no medical supplies left, and you die of poison." : GOTO 3060
2400 '
2410 PRINT "Your wagon gets swamped fording a river; you lose food and clothes."
2420 M = M - 20 - 20 * RND(1) : F = F - 15 : C = C - 10 : RETURN
2430 '
2440 PRINT "You're sound asleep and you hear a noise…get up to investigate."
2450 GOSUB 3740 : PRINT "It's wild animals! They attack you!" : GOSUB 3870
2460 IF B > 39 THEN 2480 ELSE PRINT "You're almost out of ammo; can't reach more."
2470 PRINT "The wolves come at you biting and clawing." : KH = 1 : GOTO 3030
2480 IF BR > 2 THEN 2500
2490 PRINT "Nice shooting, pardner…They didn't get much." : RETURN
2500 PRINT "Kind of slow on the draw. The wolves got at your food and clothes."
2510 B = B - 20 * BR : C = C - 2 * BR : F = F - 4 * BR : RETURN
2520 '
2530 PRINT "You're caught in a fierce hailstorm; ammo and supplies are damaged."
2540 M = M - 5 - 10 * RND(1) : B = B - 150 : R = R - 2 - 2 * RND(1) : RETURN
2550 '
2560 'Problems from not eating well enough?
2570 IF E = 1 THEN GOSUB 2880 : RETURN : 'If eating poorly, go to sickness routine
2580 IF E = 2 AND RND(1) > .25 THEN GOSUB 2880 : RETURN
2590 IF E = 3 AND RND(1) > .5 THEN GOSUB 2880 : RETURN
2600 '
2610 PRINT "Helpful Indians show you where to find more food."
2620 F = F + 7 : RETURN
2630 '
2640 'Subroutine to travel through mountains
2650 IF M <= 975 THEN RETURN : 'Not in mountains yet?
2660 IF 10 * RND(1) > 9 - ((M / 100 - 15) ^ 2 + 72) / ((M / 100 - 15) ^ 2 + 12) THEN 2750
2670 PRINT "You're in rugged mountain country." : IF RND(1) > .1 THEN 2700
2680 PRINT "You get lost and lose valuable time trying to find the trail."
2690 M = M - 60 : GOTO 2750
2700 IF RND(1) > .11 THEN 2730
2710 PRINT "Trail cave in damages your wagon. You lose time and supplies."
2720 M = M - 20 - 30 * RND(1) : B = B - 200 : R = R - 3 : GOTO 2750
2730 PRINT "The going is really slow; oxen are very tired." : M = M - 45 - 50 * RND(1)
2740 '
2750 'South Pass routine
2760 IF KP = 1 THEN 2790 : 'Is the South Pass clear?
2770 KP = 1 : IF RND(1) < .8 THEN 2840 : '80% chance of blizzard
2780 PRINT "You made it safely through the South Pass....no snow!"
2790 IF M < 1700 THEN 2810
2800 IF KM = 1 THEN 2810 : 'Through Blue Mts yet?
2810 KM = 1 : IF RND(1) < .7 THEN 2840 ELSE RETURN : 'Get through without mishap?
2820 MP = 1 : RETURN : 'Set South Pass flag
2830 '
2840 PRINT "Blizzard in the mountain pass. Going is slow; supplies are lost."
2850 KB = 1 : M = M - 30 - 40 * RND(1) : F = F - 12 : B = B - 200 : R = R - 5
2860 IF C < 18 + 2 * RND(1) THEN GOTO 2880 ELSE RETURN : 'Enough clothes?
2870 '
2880 'Subroutine to deal with illness
2890 IF 100 * RND(1) < 10 + 35 * (E - 1) THEN 2930
2900 IF 100 * RND(1) < 100 - (40 / 4 ^ (E - 1)) THEN 2950
2910 PRINT "Serious illness in the family. You'll have to stop and see a doctor"
2920 PRINT "soon. For now, your medicine will work." : R = R - 5 : KS = 1 : GOTO 2970
2930 PRINT "Mild illness. Your own medicine will cure it."
2940 M = M - 5 : R = R - 1 : GOTO 2970
2950 PRINT "The whole family is sick. Your medicine will probably work okay."
2960 M = M . 5 : R = R . 2.5
2970 IF R > 0 THEN RETURN ELSE PRINT " …if only you had enough." : GOTO 3020
2980 '
2990 'Many ways to die on the trail
3000 PRINT "You run out of food and starve to death." : GOTO 3110
3010 T = 0 : PRINT "You need a doctor badly, but can't afford one." : GOTO 3030
3020 PRINT "You have run out of all medical supplies."
3030 PRINT : PRINT "The wilderness is unforgiving and you die of ";
3040 IF KH = 1 THEN PRINT "your injuries." : GOTO 3060
3050 PRINT "pneumonia."
3060 PRINT "Your family tries to push on, but finds the going too rough";
3070 PRINT " without you." : GOTO 3110
3080 PRINT "Your oxen are worn out and can't go another step. You try pushing"
3090 PRINT "ahead on foot, but it is snowing heavily and everyone is exhausted."
3100 PRINT : GOSUB 3740 : PRINT "You stumble and can't get up...."
3110 PRINT : GOSUB 3740 : PRINT "Some travelers find the bodies of you and your"
3120 PRINT "family the following spring. They give you a decent"
3130 PRINT "burial and notify your next of kin." : PRINT
3140 D = INT(14 * (J + ML)) : DM = INT(D / 30.5) : DD = INT(D - 30.5 * DM)
3150 PRINT "At the time of your unfortunate demise, you had been on the trail"
3160 PRINT "for" DM "months and" DD "days and had covered" INT(M + 70) " miles."
3170 PRINT " You had a few supplies left :" : GOSUB 3350 : PRINT : GOTO 3310
3180 '
3190 'Made it!
3200 ML = (2040 - MA) / (M - MA) : F = F + (1 - ML) * (8 + 5 * E) : GOSUB 3830
3210 PRINT "You finally arrived at Oregon City after 2040 long miles."
3220 PRINT "You're exhausted and haggard, but you made it! A real pioneer!"
3230 D = INT(14 * (J + ML)) : DM = INT(D / 30.5) : DD = INT(D - 30.5 * DM)
3240 PRINT "You've been on the trail for" DM "months and" DD "days."
3250 PRINT "You have few supplies remaining :" : GOSUB 3350
3260 PRINT : PRINT "President James A. Polk sends you his heartiest"
3270 PRINT "congratulations and wishes you a prosperous life in your new home."
3280 GOTO 3310
3290 '
3300 'Play - again query
3310 PRINT : INPUT "Would you like to play again";A$ : GOSUB 3770
3320 IF A = 0 THEN PRINT "Okay, good luck!" : GOSUB 3740 : RUN
3330 PRINT "Okay. So long for now." : GOSUB 3740 : KEY ON : CLS : END
3340 '
3350 'Subroutine to print inventory
3360 PRINT "Cash", "Food", "Ammo", "Clothes", "Medicine, parts, etc."
3370 IF F < 0 THEN F = 0 ELSE F = INT(F)
3380 IF B < 0 THEN B = 0 ELSE B = INT(B)
3390 IF C < 0 THEN C = 0 ELSE C = INT(C)
3400 IF R < 0 THEN R = 0 ELSE R = INT(R)
3410 PRINT T, F, B, C, R : PRINT : RETURN
3420 '
3430 'Subroutine to read shooting words and dates
3440 FOR I = 1 TO 8 : READ S$(I) : NEXT I
3450 DATA "POW", "BANG", "BLAM", "WHOP", "pow", "bang", "blam", "whop"
3460 FOR I = 1 TO 20 : READ DA$(I) : NEXT I : RETURN
3470 DATA "March 29", "April 12", "April 26", "May 10", "May 24", "June 7", "June 21"
3480 DATA "July 5", "July 19", "August 2", "August 16", "August 31", "September 13"
3490 DATA "September 27", "October 11", "October 25", "November 8", "November 22"
3500 DATA "December 6", "December 20"
3510 '
3520 'Subroutine to read distances and place names
3530 FOR I = 1 TO 15 : READ MP(I), PL$(I) : NEXT I : RETURN
3540 DATA 5, "on the high prairie."
3550 DATA 200, "near Independence Crossing on the Big Blue River."
3560 DATA 350, "following the Platte River."
3570 DATA 450, "near Fort Kearney."
3580 DATA 600, "following the North Platte River."
3590 DATA 750, "within sight of Chimney Rock."
3600 DATA 850, "near Fort Laramie."
3610 DATA 1000, "close upon Independence Rock."
3620 DATA 1050, "in the Big Horn Mountains."
3630 DATA 1150, "following the Green River."
3640 DATA 1250, "not too far from Fort Hall."
3650 DATA 1400, "following the Snake River."
3660 DATA 1550, "not far from Fort Boise."
3670 DATA 1850, "in the Blue Mountains."
3680 DATA 2040, "following the Columbia River."
3690 '
3700 'Read probabilities of events
3710 FOR I = 1 TO 15 : READ EP(I) : NEXT : RETURN
3720 DATA 6, 11, 13, 15, 17, 22, 32, 35, 37, 42, 44, 54, 64, 69, 95
3730 '
3740 'Subroutine to create a short pause
3750 FOR I = 1 TO 1000 : NEXT I : RETURN
3760 '
3770 'Subroutine to read a yes/no answer
3780 X$ = LEFT$(A$, 1) : IF X$ = "Y" OR X$ = "y" THEN A = 0 : RETURN
3790 IF X$ = "N" OR X$ = "n" THEN A = 1 : RETURN
3800 PRINT "Don't understand your answer of " A$ "."
3810 INPUT "Please enter Y for 'yes' or N for 'no.' Which is it";A$ : GOTO 3780
3820 '
3830 'Subroutine to play a fanfare
3840 FQ = 220 : SOUND FQ, 3 : SOUND FQ * 1.333, 3 : SOUND FQ * 1.584, 3
3850 SOUND FQ * 1.885, 5 : SOUND FQ * 1.584, 2 : SOUND FQ * 1.885, 10 : RETURN
3860 '
3870 'Subroutine to shoot gun
3880 RN = 1 + INT(4 * RND(1)) : 'Pick a random shooting word
3890 S1 = 60 * VAL(MID$(TIME$, 4, 2)) + VAL(RIGHT$(TIME$, 2)) : 'Start timer
3900 PRINT "Type " S$(RN); : INPUT X$
3910 IF S$(RN)< >X$ AND S$(RN + 4)< >X$ THEN PRINT "Nope. Try again. "; : GOTO 3900
3920 S2 = 60 * VAL(MID$(TIME$, 4, 2)) + VAL(RIGHT$(TIME$, 2)) : 'End timer
3930 BR = S2 - S1 - DR - 1 : RETURN