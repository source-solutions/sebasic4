100 CLS : KEY OFF
110 LOCATE 10, 1 : X$ = "The Journey of Marco Polo, 1271" : GOSUB 3760
120 LOCATE 13, 1 : X$ = "(c) David H. Ahl, 1986" : GOSUB 3760
130 LOCATE 23, 1 : GOSUB 3720 : CLS
140 DIM EP(20)
150 JL = 300 : C = 2 : W = 30 : M = 5 : FP = 5 : BSK = 99 : 'Initial quantities of stuff
160 GOSUB 360 : GOSUB 3560 : 'Display the scenario
170 WHILE RN > 32767 : RN = RN - 65535! : WEND : RANDOMIZE RN
180 PRINT : GOSUB 720 : 'Purchase initial supplies
190 GOSUB 600 : 'Input hunting skill level
195 X$ = "Press any key to begin your trek!" : GOSUB 3760 : GOSUB 3740 : PRINT
200 '
210 'Main program
220 J = J + 1 : GOSUB 3510 : 'Next two-month segment
230 DT = DT + D : IF DT > 6000 THEN 3360 : 'Reached end of trip?
240 D = 40 + BA * 20 + INT(100 * RND(1)) : PRINT "You have traveled" DT "miles."
245 PRINT "Here is what you now have :" : GOSUB 3200
250 GOSUB 910 : 'Check for no jewels or clothes
260 GOSUB 1020 : 'Check for sickness
270 IF BSK = J THEN BSK = 99 : BL = B : BA = BA + 1 : 'Camel recover yet?
280 IF J > 1 AND JL > 1 THEN GOSUB 1190 : 'Barter for supplies
290 IF C = 0 THEN GOSUB 1400 : 'No clothes?
300 GOSUB 1500 : 'Eating routine
310 IF DZ = 0 AND RND(1) < .18 THEN GOSUB 3020 : '18% chance to hunt for food
320 PRINT : GOSUB 1780 : 'Desert sections
330 IF DZ = 0 THEN GOSUB 1940 : 'Event happens
340 GOSUB 3110 : GOTO 220
350 '
360 'Subroutine to print initial scenario
370 X$ = "The Journey of Marco Polo-1271" : GOSUB 3760 : PRINT : PRINT
380 PRINT " Starting from Venice in 1271 you travel by sailing ship to the"
390 PRINT "port of Armenia. Upon arrival, you prepare for a 6000-mile trek to"
400 PRINT "the court of the Great Kublai Khan in Shang-tu, Cathay. Having set"
410 PRINT "aside" JL "precious jewels to finance your planned 3-year trip, you"
420 PRINT "must barter for the following supplies in Armenia :"
450 PRINT " * Camels (Sturdier animals will cost more. You will probably"
460 PRING " want 8 to 10 camels to carry your many supplies.)"
470 PRINT " * Food (You must barter for food as you travel along. However,"
480 PRINT " prices tend to be lower in port cities, so you should pack"
490 PRINT " in a good supply at the start.)
500 PRINT " * Oil for lamps and cooking (Over much of the trip, you will be"
510 PRINT " able to use wood to build fires. However, in the Persian,"
520 PRINT " Lop, and Gobi deserts you will need oil.)" : PRINT
522 PRINT " From Venice you have also packed clothing, weapons (crossbows),"
524 PRINT "and medicines (balms and unguents); however, your provisions will be"

530 PRINT "depleted as you go along and you must replenish them. The selection"
540 PRINT "and price of supplies is quite different in various regions, so you"
550 PRINT "must barter wisely. As a merchant, you are not skilled in fishing"
560 PRINT "or hunting, although occasionally you might be able to try to get"
570 PRINT "some food in this way."
580 GOSUB 3720 : PRINT : RETURN
590 '
600 'Subroutine to initialize hunting skill level
610 S$(1) = "SPLAT" : S$(2) = "SPRONG" : S$(3) = "TWACK" : S$(4) = "ZUNK"
620 FA$(1) = "wild boar" : FA$(2) = "big stag" : FA$(3) = "black bear"
625 PRINT : PRINT "Before you begin your journey, please rank your skill with"
630 PRINT "the crossbow on the following scale:"
640 PRINT " (1) Can hit a charging boar at 300 paces"
650 PRINT " (2) Can hit a deer at 50 paces"
660 PRINT " (3) Can hit a sleeping woodchuck at 5 paces"
670 PRINT " (4) Occasionally hit own foot when loading
680 INPUT "How do you rank yourself";HX
690 IF HX > 1 AND HX < 5 THEN PRINT : RETURN
700 PRINT "Please enter 1, 2, 3, or 4" : GOTO 680
710 '
720 'Subroutine to get initial supplies
730 PRINT " After three months at sea, you have arrived at the seaport of"
740 PRINT "Laiassus, Armenia. There are many merchants in the port city and"
750 PRINT "you can easily get the supplies you need. Several traders offer you"
760 A1 = 17 : A2 = 24 : PRINT "camels at prices between" A1 "and" A2 "jewels each."
770 INPUT "How much do you want to pay for a camel";A : GOSUB 3790 : BA = A
780 PRINT "You will need at least 7 camels, but not more than 12."
790 A1 = 7 : A2 = 12 : INPUT "How many camels do you want to buy";A : GOSUB 3790
800 B = A : JL = JL - BA * B : A2 = 3 * B - 6 : 'Camels—number, cost, amount they can carry
810 PRINT " One large sack of food costs 2 jewels. You will need at least"
820 PRINT "8 sacks to get to Babylon (Baghdad); you can carry a maximum of" A2
830 A1 = 8 : INPUT "sacks. How many do you want";A : GOSUB 3790
840 F = A : JL = JL - A * 2 : A2 = 3 * B - A : 'Food & cost, amount of oil camels can carry
850 PRINT " A skin of oil costs 2 jewels each. You should have at least 6"
860 PRINT "full skins for cooking in the desert. Your camels can carry" A2
870 A1 = 5 : INPUT "skins. How many do you want";A : GOSUB 3790
880 BL = B : L = A : JL = JL - 2 * L : 'Oil-amount and cost : return
900 '
910 'Subroutine to check for being out of jewels and clothes
920 IF JL > 15 THEN 980 : 'Still have a few jewels?
930 PRINT "You have only" JL "jewels with which to barter." : IF B > 2 THEN 950
940 PRINT "You push on with your" B "camels." : RETURN
950 INPUT "Would you like to sell a camel";A$ : GOSUB 3840 : IF A$ = "N" THEN 940
960 RN = INT(8 + 9 * RND(1)) : PRINT "You get" RN "jewels for your best camel."
970 JL = JL + RN : B = B - 1 : BL = BL - 1 : 'Add jewels, subtract camel

980 IF C > 0 THEN RETURN : 'Have some clothes?
990 PRINT "You should try to replace that tent you have been wearing as a"
1000 PRINT "robe. It is badly torn and the Tartars find it insulting." : RETURN
1010 '
1020 'Subroutine to deal with sickness
1030 IF PSK > 0 THEN PSKT = PSKT + PSK : PSK = 0 : 'Sickness total
1040 IF PWD > 0 THEN PWDT = PWDT + PWD : PWD = 0 : 'Injuries total
1050 IF FE = 3 THEN PFD = PFD + .4
1060 IF PSKT + PWDT + PFD < 3 THEN RETURN
1070 IF RND(1) > .7 THEN RETURN : '70% chance of delay due to recurring illness
1080 PRINT "As a result of sickness, injuries, and poor eating, you must stop"
1090 PRINT "and regain your health. You trade a few jewels to stay in a hut."
1100 RN = INT(1 + 3.2 * RND(1)) : IF RN > 3 THEN 1160 : '6% chance of dying
1110 PRINT "You grow steadily stronger, but it is" RN * 2 "months until you"
1120 PRINT "are again fit to travel." : PSKT = 0 : PWDT = 0 : PFD = 0 : J = J + RN
1130 M = INT(M / 2) : F = F / 2 : IF F < 3 THEN F = 3
1140 IF JL > 20 THEN JL = JL - 10 ELSE JL = INT(JL / 2) : 'Costs money for lodging
1150 GOSUB 3510 : RETURN
1160 FOR I = 1 TO 2500 : NEXT : PRINT "You stay for" RN "months but grow"
1170 PRINT "steadily weaker and finally pass away." : J = J + RN : GOTO 3320
1180 '
1190 'Subroutine to barter for supplies
1200 PRINT "You have" JL; : INPUT "jewels. Do you want to barter here";A$
1210 GOSUB 3840 : IF A$ = "N" THEN 1380
1220 RN = INT(17 + 8 * RND(1)) : PRINT "Camels cost" RN "jewels here. ";
1230 A1 = 0 : A2 = INT(JL / RN) : INPUT "How many do you want";A : GOSUB 3790
1240 B = B + A : BL = BL + A : BA = BA - A : 'Lower quality animals along route
1250 JL = JL - A * RN : RN = INT(2 + 4 * RND(1)) : PRINT "Sacks of food cost" RN "jewels. ";
1260 A2 = (INT(JL / RN)) : INPUT "How many do you want";A : GOSUB 3790 : F = F + A
1270 IF F + L > 3 * BL THEN PRINT "Camels can't carry that much." : F = F - A : GOTO 1260
1280 JL = JL - A * RN : RN = INT(2 + 4 * RND(1)) : PRINT "Skins of oil cost" RN "jewels. ";
1290 A2 = (INT(JL / RN)) : INPUT "How many do you want";A : GOSUB 3790 : L = L + A
1300 IF F + L > 3 * BL THEN PRINT "Camels can't carry that much." : L = L - A : GOTO 1290
1310 JL = JL - A * RN : RN = INT(8 + 8 * RND(1)) : PRINT "A set of clothes costs" RN;
1320 A2 = (INT(JL / RN)) : INPUT "jewels. How many do you want";A : GOSUB 3790
1330 C = C + A : JL = JL - A * RN : PRINT "You can get a bottle of balm for 2 jewels. ";
1340 A2 = JL / 2 : INPUT "How many do you want";A : GOSUB 3790 : JL = JL - 2 * A : M = M + A
1350 A2 = JL : RN = INT(6 + 6 * RND(1)) : PRINT "You can get" RN "arrows for 1 jewel."
1360 INPUT "How many jewels do you want to spend on arrows";A : GOSUB 3790
1370 JL = JL - A : W = W + RN * A : IF C > 1 THEN CZ = 0
1380 PRINT : PRINT "Here is what you now have:" : GOSUB 3200 : RETURN
1390 '
1400 'Subroutine to deal with no clothes
1410 PRINT : PRINT "You were warned about getting more modest clothes."
1420 PRINT "Furthermore, your sandals are in shreds." : IF CZ = 1 THEN 1470

1430 PRINT "The Tartars chase you from town and ";
1440 IF RND(1) > .2 THEN PRINT "warn you not to return." : CZ = 1 : RETURN
1450 PRINT "stone you." : PRINT "You are badly wounded and vow to get";
1460 PRINT "new clothes as soon as possible." : PWD = 1.5 : CZ = 1 : RETURN
1470 PRINT "Word has been received about your disreputable appearance.
1480 PRINT "The people are not willing to deal with you and they "; : GOTO 1450
1490 '
1500 'Subroutine to eat
1510 IF F < 3 THEN GOSUB 1650 : 'Out of food?
1520 PRINT "On the next stage of your journey, how do you want to eat :"
1530 PRINT " (1) Reasonably well (can walk further; Less chance of sickness)"
1540 INPUT " (2) Adequately, or (3) Poorly";A : IF A > 0 AND A < 4 THEN 1560
1550 PRINT "That's not a choice. Now then, (1) Well,"; : GOTO 1540
1560 FE = 6 - A : IF FE <= F THEN 1580
1570 PRINT "You don't have enough food to eat that well. Try again." : GOTO 1520
1580 FR = INT(.5 + 10 * (F - FE)) / 10 : IF FR > 3 THEN 1630
1590 IF FR = 1 THEN X$ = "" ELSE X$ = "s"
1600 PRINT "Your food reserve will then be just" FR "sack" X$ : IF A = 3 THEN 1630
1610 INPUT "Do you want to change your mind about how much you will eat";A$
1620 GOSUB 3840 : IF A$ = "Y" THEN 1520
1630 F = F - FE : D = D - (A - 1) * 50 : FQ = FP + FE : FP = FE : RETURN
1640 '
1650 'Out of food section
1660 PRINT "You don't have enough food to go on."
1670 IF JL < 15 THEN 1730
1680 PRINT "You should have bought food at the market. Now it will cost you"
1690 RN = INT(5 + 4 * RND(1)) : PRINT RN "jewels per sack."; : A1 = 1 : A2 = (INT(JL / RN))
1700 INPUT " How many sacks do you want";A : GOSUB 3790
1710 F = F + A : JL = JL - A * RN : IF F >= 3 THEN RETURN
1720 PRINT "You still don't have enough food and there is nothing to hunt."
1730 IF B < 1 THEN 1760 ELSE INPUT "Do you want to eat a camel";A$
1740 GOSUB 3840 : IF A$ = "N" THEN 3280 ELSE B = B - 1 : RN = INT(3 + 2 * RND(1)) : F = F + RN
1750 PRINT "You manage to get about" RN "sacks of food out of it." : RETURN
1760 PRINT "You don't even have a camel left to eat." : GOTO 3280
1770 '
1780 'Subroutine for desert sections
1790 DZ = 0 : IF DT < 2100 OR DT > 5900 THEN RETURN : 'No desert at far ends
1800 IF DT > 2600 AND DT < 4100 THEN RETURN : 'Tigris River Valley
1810 IF DT > 4600 AND DT < 5400 THEN RETURN : 'No desert in middle
1820 IF DT < 4100 THEN X$ = "Dasht-e-Kavir (Persian)" : GOTO 1840
1830 IF DT > 5399 THEN X$ = "Gobi (Cathay)" ELSE X$ = "Taklimakan (Lop)"
1840 PRINT "You are in the " X$ " desert."
1850 IF L >= 3 THEN L = L - 3 : PRINT "Use 3 skins of oil for cooking." : GOTO 1900
1860 PRINT "You ran out of oil for cooking."
1870 IF L > 1 THEN IF RND(1) > .5 THEN L = 0 : GOTO 1900

1880 PRINT "You get horribly sick from eating raw and undercooked food."
1890 L = 0 : PSK = 1 : D = D - 80 : M = M - 1
1900 ON INT(1 + 7 * RND(1)) GOSUB 2250, 2310, 2420, 2450, 2480, 2510, 1920
1910 DZ = 1 : GOSUB 3110 : RETURN
1920 PRINT "You get through this stretch of desert without mishap!" : GOTO 1910
1930 '
1940 'Subroutine to deal with special events
1950 RN = INT(EPT * RND(1)) : FOR I = 1 TO 14 : 'Iterate thru possible events
1960 IF RN > EP(I) THEN NEXT I : I = 14 : 'If event happened, exit lop
1970 IF I > 10 THEN 1990
1980 ON I GOTO 2000, 2250, 2310, 2340, 2360, 2380, 2400, 2420, 2450, 2480
1990 ON I - 10 GOTO 2540, 2570, 2600, 2660
2000 PRINT "A camel injures its leg. Do you want to (1) Nurse it along or"
2010 INPUT "(2) Abandon it, or (3) Sell it";A
2020 IF A = 1 THEN 2040 ELSE IF A = 2 THEN 2050 ELSE IF A = 3 THEN 2090
2030 PRINT "That is not a choice. Answer (1) to Nurse it along, " : GOTO 2010
2040 BSK = J + 2 : GOSUB 2120 : RETURN
2050 B = B - 1 : GOSUB 2120 : FC = 3 * BL - F - L : IF FC <= 0 THEN RETURN
2060 PRINT "You kill the camel for food." : IF FC > 2 THEN FC = 3
2070 F = F + FC : IF FC = 1 THEN X$ = "" ELSE X$ = "s"
2080 PRINT "You get the equivalent of" FC "sack" X$ " of food." : RETURN
2090 B = B - 1 : PRINT "It is a poor beast and you can get only 10 jewels for it."
2100 JL = JL + 10 : GOSUB 2120 : RETURN
2110 '
2120 'Exceed load carrying capacity of camels?
2130 BL = B : IF BSK <= J THEN BL = B - .6 : BA = BA - 1 : 'If sick camel reduce load, speed
2140 IF F + L <= 3 * BL THEN RETURN
2150 PRINT "You have too large a load for your camels." : FC = INT(F + L - 3 * BL + .9)
2160 IF FC = 1 THEN X$ = "" ELSE X$ = "s"
2170 PRINT "You'll have to sell" FC "sack" X$ " of food or skin" X$ " of oil."
2180 FS = INT(FC / 2) : LS = FC - FS : 'How much to sell of food and oil
2190 IF LS > L THEN LS = LS - 1 : FS = FS + 1 : GOTO 2190
2200 IF FS > F THEN FS = FS - 1 : LS = LS + 1 : GOTO 2200
2210 F = F - FS : L = L - LS : JL = JL + FS + LS : 'Decrease food and oil, add jewels
2220 PRINT "You sell" FS "of food," LS "of oil for which you get only";
2230 PRINT FS + LS "jewel" X$ "." : RETURN
2240 '
2250 PRINT "One of your camels is very sick and can't carry a full load."
2260 INPUT "Want to (1) Keep it with you, (2) Slaughter it, or (3) Sell it";A
2270 IF A = 1 THEN 2290 ELSE IF A = 2 THEN 2050 ELSE IF A = 3 THEN 2090
2280 PRINT "That is not a choice. Again, please." : GOTO 2260
2290 BSK = J + 2 : GOSUB 2120 : RETURN
2300 '
2310 PRINT "Long stretch with bad water. Costs time to find clean wells."
2320 D = D - 50 : RETURN

2330 '
2340 PRINT "You get lost trying to find an easier route." : D = D - 100 : RETURN
2350 '
2360 PRINT "Heavy rains completely wash away the route." : D = D - 90 : RETURN
2370 '
2380 PRINT "Some of your food rots in the humid weather." : F = F - 1 : RETURN
2390 '
2400 PRINT "Marauding animals got into your food supply." : F = F - 1 : RETURN
2410 '
2420 PRINT "A fire flares up and destroys some of your food and clothes."
2430 F = F - .4 : C = C - 1 : GOSUB 3110 : IF L < 1 THEN RETURN ELSE L = L - .5 : RETURN
2440 '
2450 PRINT "Two camels wander off. You finally find them after spending"
2455 PRINT "several days searching for them."
2460 D = D - 20 : RETURN
2470 '
2480 PRINT "You get a nasty burn from an oil fire."
2490 PWD = .5 : GOSUB 2840 : RETURN
2500 '
2510 PRINT "High winds, sand storms, and ferocious heat slow you down."
2520 D = D - 70 : RETURN
2530 '
2540 PRINT "A gash in your leg looks infected. It hurts like the blazes."
2550 GOSUB 2840 : D = D - 50 : PWD = .7 : RETURN
2560 '
2570 PRINT "Jagged rocks tear your sandals and clothing. You'll have to get"
2580 PRINT "replacements as soon as you can." : C = C - 1 : D = D - 30 : RETURN
2590 '
2600 RN = RND(1) * FQ : IF RN < 2 THEN 2610 ELSE IF RN < 3.5 THEN 2630 ELSE RETURN
2610 PRINT "All of you have horrible stomach cramps and intestinal disorders"
2620 PRINT "and are laid up for over a month." : D = D - 275 : RETURN
2630 PRINT "You're running a high fever and your muscles feel like jelly."
2640 PRINT "Your party slows down for you." : PSK = .7 : D = D - 125 : RETURN
2650 '
2660 PRINT "Blood-thirsty bandits are attacking your small caravan!"
2670 PRINT "You grab your crossbow…"; : GOSUB 3620
2680 IF W > 5 THEN 2700 ELSE PRINT "You try to drive them off, but you run out"
2690 PRINT "of arrows. They grab some jewels and food." : F = F - 1 : GOTO 2720
2700 IF SR <= 1 THEN 2810 ELSE IF SR <= 3 THEN 2780
2710 PRINT "Better stick to trading; your aim is terrible."
2720 IF RND(1) > .8 THEN 2750 : '80% chance of surviving attack
2730 PRINT "They are savage, evil barbarians — they kill you and take"
2740 PRINT "your remaining camels and jewels." : JL = 0 : B = 0 : GOTO 3320
2750 PRINT "You caught a knife in the shoulder. That's going to take quite"
2760 PRINT "a while to heal." : GOSUB 2840

2770 PWD = 1.5 : JL = JL - 10 : W = W - 4 - 2 * SR : GOSUB 3110 : RETURN
2780 PRINT "With practice you could shoot the crossbow, but most of your shots"
2790 PRINT "missed. An iron mace got you in the chest. They took some jewels."
2800 PWD = 1 : JL = JL - 5 : GOSUB 2840 : W = W - 3 - 2 * SR : GOSUB 3110 : RETURN
2810 PRINT "Wow! Sensational shooting. You drove them off with no losses."
2820 W = W - 4 : RETURN
2830 '
2840 'Subroutine to deal with using balm
2850 RN = INT(1 + 2 * RND(1)) : IF RN > 1 THEN X$ = "s" ELSE X$ = ""
2860 IF RND(1) > .5 THEN XA$ = "balm" ELSE XA$ = "unguent"
2870 M = M - RN : IF M < 0 THEN M = 0 : GOTO 2890
2880 PRINT "You use" RN "bottle" X$ " of " XA$ " treating your wound." : RETURN
2890 PRINT "You need more " XA$ " to treat your wound." : IF JL < 8 THEN 2940
2900 PRINT "Fortunately, you find some nomads who offer to sell you 2 bottles"
2910 PRINT "of" XA$ "for the outrageous price of 4 jewels each."
2920 INPUT "Do you want to buy it";A$ : GOSUB 3840 : IF A$ = "N" THEN 2950
2930 PRINT "It works well and you're soon feeling better." : M = 0 : JL = JL - 8 : RETURN
2940 PRINT "But, alas, you don't have enough jewels to buy any."
2950 PRINT "Your wound is badly infected, "; : IF RND(1) < .8 THEN 3000
2960 PRINT "but you keep going anyway." : PRINT
2970 PRINT "Unfortunately, the strain is too much for you and, after weeks of"
2980 PRINT "agony, you succumb to your wounds and die in the wilderness."
2990 GOTO 3320
3000 PRINT "but you push on for the next village." : PWD = 3 : RETURN
3010 '
3020 'Subroutine to hunt for food
3030 IF W < 15 THEN PRINT "You don't have enough arrows to hunt for food." : RETURN
3040 PRINT "There goes a " FA$(INT(1 + 3 * RND(1))) "…"; : W = W - 15 : GOSUB 3620
3050 IF SR <= 1 THEN 3080 ELSE IF SR <= 3 THEN 3070
3060 PRINT "Were you too excited? All your shots went wild." : RETURN
3070 PRINT "Not bad; you finally brought one down." : FA = 2 : GOTO 3090
3080 PRINT "With shooting that good, the Khan will want you in his army." : FA = 3
3090 PRINT "Your hunting yields" FA "sacks of food." : F = F + FA : RETURN
3100 '
3110 'Subroutine to check for zero quantities
3120 IF JL < 0 THEN JL = 0 : 'Can't have negative jewels
3130 IF F < 0 THEN F = 0 : 'or food
3140 IF L < 0 THEN L = 0 : 'or oil
3150 IF C < 0 THEN C = 0 : 'or clothing
3160 IF M < 0 THEN M = 0 : 'or medicine
3170 IF W < 0 THEN W = 0 : 'or arrows
3180 RETURN
3190 '
3200 'Subroutine to print inventory
3210 PRINT TAB(22) "Sacks of Skins of Robes and Balms and Crossbow"

3220 PRINT "Jewels Camels Food Oil Sandals";
3230 PRINT "Unguents Arrows" : GOSUB 3110
3240 PRINT USING "#####";JL; : X$ = "###########" : XAS = "#########.#"
3250 PRINT USING X$; B; : PRINT USING XA$; F; : PRINT USING XA$; L;
3260 PRINT USING X$; C; : PRINT USING X$; M; : PRINT USING X$; W : PRINT : RETURN
3270 '
3280 'End game - out of food
3290 PRINT "You keep going as long as you can, trying to find berries and"
3300 PRINT "edible plants. But this is barren country and you fall ill and,"
3310 PRINT "after weeks of suffering, you collapse into eternal sleep."
3320 PRINT : J = J + 1 : GOSUB 3510 : PRINT "You had the following left at the end :"
3330 GOSUB 3200 : PRINT "You traveled for" J * 2 "months!"
3340 PRINT : PRINT "Sorry, you didn't make it to Shang-tu." : GOTO 3490
3350 '
3360 'End of trip section
3370 GOSUB 3110 : 'Can't have negative jewels at end
3380 FOR I = 1 TO 3000 : NEXT I : CLS : FOR I = 1 TO 10
3390 BEEP : X$ = "CONGRATULATIONS !" : LOCATE 12, 1 : GOSUB 3760
3400 FOR K = 1 TO 100 : NEXT K : CLS : FOR K = 1 TO 50 : NEXT K : NEXT I
3410 CLS : PRINT "You have been traveling for" J * 2 "months !" : PRINT
3420 PRINT "You are ushered into the court of the Great Kublai Khan."
3430 PRINT "He surveys your meager remaining supplies :" : GOSUB 3200
3440 PRINT "… and marvels that you got here at all. He is disappointed"
3450 PRINT "that the Pope did not see fit to send the 100 men of learning"
3460 PRINT "that he requested and, as a result, keeps the three of you as"
3470 PRINT "his personal envoys for the next 21 years. Well done!" : PRINT
3480 '
3490 PRINT : INPUT "Would you like to try again"A$ : GOSUB 3840
3500 IF A$ = "Y" THEN RUN ELSE CLS : KEY ON : PRINT "Bye for now." : END
3505 '
3510 'Subroutine to print the date
3520 MO = J : WHILE MO > 6 : MO = MO - 6 : WEND
3530 YR = 1271 + INT(J / 6)
3540 PRINT : PRINT "Date :" MO$(MO) YR : RETURN
3550 '
3560 'Subroutine to read event probabilities
3570 FOR I = 1 TO 14 : READ A : EPT = EPT + A : EP(I) = EPT : NEXT I
3580 DATA 6, 4, 4, 6, 6, 6, 6, 4, 4, 1, 6, 8, 18, 10
3590 FOR I = 1 TO 6 : READ MO$(I) : NEXT I : RETURN
3600 DATA "March", "May", "July", "September", "November", "January"
3610 '
3620 'Subroutine to shoot crossbow
3630 RN = 1 + INT(4 * RND(1)) : 'Print random shooting word
3640 S1 = 60 * VAL(MID$(TIME$, 4, 2)) + VAL(RIGHT$(TIME$, 2)) : 'Start timer
3650 PRINT "Type :" S$(RN) " "; : INPUT X$ : IF X$ = S$(RN) THEN 3680

3660 FOR I = 1 TO LEN(X$) : 'Iterate through letters for possible lowercase
3670 IF MID$(S$(RN), I, 1)< >CHR$(ASC(MID$(X$, I, 1)) - 32) THEN 3700 ELSE NEXT I
3680 S2 = 60 * VAL(MID$(TIME$, 4, 2)) + VAL(RIGHT$(TIME$, 2)) : 'End timer
3690 SR = S2 - S1 - HX : RETURN : 'Shooting response
3700 PRINT "That's not it. Try again."; : GOTO 3650
3710 '
3720 'Subroutine to hit continue key
3730 X$ = "Press any key to continue." : GOSUB 3760
3740 WHILE LEN(INKEY$) = 0 : RN = RN + 1 : WEND : RETURN
3750 '
3760 'Subroutine to print a centered line
3770 PRINT TAB((70 - LEN(X$)) / 2) X$; : RETURN
3780 '
3790 'Subroutine to check if answer entered is in range
3800 IF A >= A1 AND A <= A2 THEN RETURN
3810 IF A < A1 THEN X$ = "few" ELSE X$ = "many"
3820 PRINT "That is too" X$; : INPUT ". Your answer please"; A : GOTO 3800
3830 '
3840 'Subroutine to process a yes/no answer
3850 GOSUB 3880 : IF A$ = "Y" OR A$ = "N" THEN RETURN
3860 INPUT "Don't understand answer. Enter 'Y' or 'N' please";A$ : GOTO 3850
3870 '
3880 'Subroutine to extract the first letter of an answer
3890 IF A$ = "" THEN A$ = "Y" : RETURN
3900 A$ = LEFT$(A$, 1) : IF A$ >= "A" AND A$ <= "Z" THEN RETURN
3910 A$ = CHR$(ASC(A$) - 32) : RETURN