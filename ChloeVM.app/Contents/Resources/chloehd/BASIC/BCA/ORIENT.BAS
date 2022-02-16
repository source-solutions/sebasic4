100 CLS : KEY OFF : ON ERROR GOTO 3160
110 LOCATE 10, 27 : PRINT "The Orient Express, 1923"
120 LOCATE 13, 28 : PRINT "(c) David H. Ahl, 1986" : LOCATE 23, 27
130 PRINT "Press any key to continue." : RN = -32768!
140 WHILE LEN(INKEY$) = 0 : RN = RN + 1 : WEND
150 WHILE RN > 32767 : RN = RN - 65535! : WEND : RANDOMIZE RN : CLS
160 PRINT TAB(22) "The Mysterious Arms Deal" : PRINT : GOSUB 1710
170 '
180 'Initialization
190 DIM C$(25), CN(25), CP(25), DA(25), HZ(25), LA$(25), LB$(25), ME(25), N$(25)
200 DIM TA(25), TD(25), CS(25), MB$(15), MD$(26)
210 GOSUB 1880 : 'Read data about journey segments
220 GOSUB 2160 : 'Read statements of travelers
230 GOSUB 2430 : 'Read names of those on the train
240 GOSUB 2530 : 'Read menu selections
250 GOSUB 2760 : 'Shuffle 24 integers for later use
260 PRINT "Press any key to call a taxi…" : WHILE LEN(INKEY$) = 0 : WEND
270 '
280 'Main program
290 FOR J = 1 TO 24 : 'Iterate through locations
300 PRINT : PRINT "February" DA(J) + 13 + HY "1923" : 'Print date
310 TN = 18 - INT(27 * RND(1)) : TB = TA(J) + TN : T = TB : IF J = 1 THEN 450
320 GOSUB 3110 : PRINT "You have arrived at " LA$(J) ", " LB$(J) " at"; : GOSUB 3060
330 IF TN > 1 THEN PRINT "just" TN "minutes late." : GOTO 360
340 IF TN < -1 THEN PRINT "almost"; TN "minutes early." : GOTO 360
350 PRINT "— right on time!"
360 IF TB > TD(J) -2 THEN T = TB + 4 ELSE T = TD(J) : 'Make sure departure is after arrival
370 IF J = 24 THEN 3190 ELSE IF ME(J) < 4 THEN 400 : 'Is it daytime?
380 PRINT "Asleep in your compartment, you barely notice that the"
390 PRINT "departure was right on time at"; : GOSUB 3060 : GOSUB 2860 : GOTO 490
400 IF J = 23 THEN GOSUB 1340 : 'Time to identify the killer and defector?
410 PRINT "Departure is at"; : GOSUB 3060 : PRINT
420 INPUT "Would you like to get off and stretch your legs";A$ : GOSUB 2810
430 IF A = 1 THEN PRINT "Okay, you stay in your compartment." : GOTO 470
440 PRINT "Okay, but be sure not to miss the train." : GOTO 470
450 PRINT "The taxi has dropped you at Victoria Station in London."
460 PRINT "The Orient Express is standing majestically on Track 14."
470 PRINT : SOUND 500, 15 : GOSUB 2860 : SOUND 500, 30 : PRINT "All aboard…";
480 GOSUB 2860 : PRINT "train is leaving." : GOSUB 2860
490 GOSUB 2990 : 'Train noises
500 GOSUB 2860 : IF J > 1 THEN 570 : 'First leg of trip?
510 X = 3 + INT(20 * RND(1))
520 PRINT : PRINT "You speak to some of the passengers—" N$(X) ","
530 PRINT N$(X + 1) ", " N$(X + 2) " and others—and ask them to keep"
540 PRINT "their eyes and ears open and to pass any information—no
550 PRINT "matter how trivial—to you in compartment 13. The Channel"
560 PRINT "crossing is pleasant and the first part of the trip uneventful."
570 IF J = 23 THEN GOSUB 1490 : 'Time to identify the killer and defector?
580 IF ME(J) > 0 AND ME(J) < 4 THEN ON ME(J) GOSUB 770, 720, 640 : 'Meals
590 GOSUB 860 : 'Talk to passengers
600 IF HZ(J) > 0 THEN ON HZ(J) GOSUB 970, 1110 : 'Snow or bandits on this leg?
610 GOSUB 1220 : 'Other hazards
620 NEXT J
630 '
640 'Subroutine to serve breakfast
650 PRINT : PRINT "Breakfast is now being served in the restaurant car."
660 PRINT "Press any key when you're ready to have breakfast."
670 WHILE LEN(INKEY$) = 0 : WEND : CLS : LOCATE 3, 33 : PRINT "BREAKFAST MENU"
680 FOR I = 1 TO 4 : X = 3 * (I - 1) + 1 + INT(3 * RND(1))
690 LOCATE 4 + 3 * I, (80 - LEN(MB$(X))) / 2 : PRINT MB$(X) : NEXT
700 LOCATE 19, 20 : PRINT MB$(13) : GOSUB 2950 : RETURN
710 '
720 'Subroutine to serve lunch
730 PRINT : PRINT "An enormous buffet luncheon has been laid out in the ";
740 PRINT "restaurant car." : PRINT "Press any key when you have finished.";
750 WHILE LEN(INKEY$) = 0 : WEND : PRINT " B-U-R-P !" : RETURN
760 '
770 'Subroutine to serve dinner
780 PRINT : PRINT "Dinner is now being served in the restaurant car."
790 PRINT "Press any key when you're ready to have dinner."
800 WHILE LEN(INKEY$) = 0 : WEND : CLS : LOCATE 1, 34 : PRINT "DINNER MENU"
810 FOR I = 1 TO 7 : X = 3 * (I - 1) + 1 + INT(3 * RND(1))
820 LOCATE 2 + 2 * I, (80 - LEN(MD$(X))) / 2 : PRINT MD$(X) : NEXT
830 LOCATE 18, 24 : PRINT MD$(22) : LOCATE 20, 30 : PRINT MD$(23)
840 LOCATE 22, 32 : PRINT MD$(24) : GOSUB 2950 : RETURN
850 '
860 'Subroutine to have conversations
870 FOR K = 1 TO CN(J) : 'Iterate through conversations in this trip segment
880 GOSUB 2890 : CM = CM + 1 : 'Ring compartment buzzer and open door
890 IF CP(CS(CM)) > 0 THEN X = CP(CS(CM)) ELSE X = 3 + INT(23 * RND(1))
900 PRINT "Standing there is "N$(X) ", who tells you:" : X = CS(CM)
910 IF LEN(C$(X)) < 81 THEN PRINT C$(X) : GOTO 950 : 'If short message, print it
920 CS(RN) = CS(CM) : FOR KA = 79 TO 1 STEP -1
930 IF MID$(C$(X), KA, 1)< >" " THEN NEXT KA : 'Find a space near end of line
940 PRINT LEFT$(C$(X), KA) : PRINT RIGHT$(C$(X), LEN(C$(X)) - KA)
950 NEXT K : RETURN
960 '
970 'Subroutine for snow
980 X = RND(1) : IF X > .65 THEN RETURN : '65% chance of snow
990 PRINT : PRINT "It is snowing heavily ";
1000 IF X < .01 THEN 1030 : '1% chance of getting stuck in the snow
1010 PRINT "but the tracks have been cleared and the train"
1020 PRINT "will not be delayed." : RETURN
1030 PRINT "and the train is forced to slow down." : PRINT
1040 PRINT "Oh no! The train is coming to a stop. Let's hope this is"
1050 PRINT "not a repeat of the trip of January 29, 1929 when the Orient"
1060 PRINT "Express was stuck in snowdrifts for five days." : PRINT : GOSUB 2860
1070 PRINT "But it looks like it is!" : GOSUB 2860
1080 PRINT "You are stranded for two days until a snowplow clears the track."
1090 PRINT "The train is now exactly two days behind schedule." : HY = HY + 2 : RETURN
1100 '
1110 'Subroutine for bandits
1120 IF RND(1) > .04 THEN RETURN : '4% chance of bandits
1130 IF HX = 1 THEN RETURN ELSE HX = 1 : 'Only one bandit attack
1140 PRINT : PRINT "You are rudely awakened from a deep sleep by a loud noise"
1150 PRINT "as the train jerks to a halt." : GOSUB 2890
1160 PRINT "You are shocked to see a bandit waving a gun in your face."
1170 PRINT "He demands that you give him your wallet, jewelry, and watch." : PRINT
1180 GOSUB 2860 : PRINT "The bandits are off the train in a few moments with"
1190 PRINT "their loot. They disappear into the forest. No one"
1200 PRINT "was injured, and the train resumes its journey." : RETURN
1210 '
1220 'Subroutine to deal with miscellaneous hazards
1230 IF RND(1) > .02 THEN RETURN : '2% chance of derailment
1240 IF HW = 1 THEN RETURN ELSE HW = 1 : 'Only one derailment
1250 PRINT : PRINT "You hear a loud screeching noise as the train comes to a"
1260 PRINT "crashing stop. The engine, tender, and first coach are"
1270 PRINT "leaning at a crazy angle. People are screaming." GOSUB 2860
1280 PRINT : PRINT "While not as bad as the derailment at Vitry-le-Francois in"
1290 PRINT "November 1911, there is no question that the front of the"
1300 PRINT "train has left the track." : GOSUB 2860 : PRINT
1310 PRINT "You are stranded for exactly one day while the track is"
1320 PRINT "repaired and a new locomotive obtained." : HY = HY + 1 : RETURN
1330 '
1340 'Subroutine to identify defector and killer
1350 PRINT : PRINT "The Turkish police have boarded the train. They have been"
1360 PRINT "asked to assist you, but for them to do so you will have to"
1370 PRINT "identify the killer (the dealer in machine guns) and the defector"
1380 PRINT "(the Scotch drinker) to them. The arms dealers are lined"
1390 PRINT "up as follows:" : PRINT : PRINT " (1) Austrian, (2) Turk, ";
1400 PRINT "(3) Pole, (4) Greek, (5) Rumanian." : PRINT
1410 INPUT "Who is the defector (a number please)";A1
1420 INPUT "and who is the killer";A2 : GOSUB 2860
1430 PRINT : PRINT "The police take into custody the man you identified as the"
1440 PRINT "killer and provide a guard to ride on the train with the"
1450 PRINT "defector. You return to your compartment, praying that"
1460 PRINT "you made the correct deductions and identified the right men."
1470 PRINT : GOSUB 2860 : RETURN
1480 '
1490 'Subroutine to check the identities
1500 IF A1 = A3 OR A1 = A4 THEN 1600 : 'Defector saved?
1510 PRINT : PRINT "You are suddenly awakened by what sounded like a gunshot."
1520 PRINT "You rush to the defector's compartment, but he is okay."
1530 PRINT "However, one of the other arms dealers has been shot." : GOSUB 2860
1540 PRINT : PRINT "You review the details of the case in your mind and realize"
1550 PRINT "that you came to the wrong conclusion and due to your mistake"
1560 PRINT "a man lies dead at the hands of bandits. You return to your"
1570 PRINT "compartment and are consoled by the thought that you correctly"
1580 PRINT "identified the killer and that he will hang for his crimes."
1590 '
1600 IF A2 = A4 THEN A5 = 1 : RETURN : 'Killer is still on the train
1610 GOSUB 2890 : PRINT "A man is standing outside. He says, 'You made a"
1620 PRINT "mistake. A bad one. You see, I am the machine-gun dealer."
1630 IF A1< >A4 THEN 1660 : 'Wrongly identified defector as killer?
1640 PRINT "Moreover, you incorrectly identified the man who was cooperating"
1650 PRINT "with you as the killer. So the state will take care of him. Ha."
1660 PRINT : GOSUB 2860 : PRINT "He draws a gun. BANG. You are dead."
1670 PRINT : PRINT "You never know that the train arrived at 12:30, right on"
1680 PRINT "time at Constantinople, Turkey." : GOSUB 2860 : GOSUB 2860
1690 PRINT : PRINT : GOTO 3190
1700 '
1710 'Subroutine to set the scenario
1720 PRINT " It is February 1923. The following note is received at"
1730 PRINT "Whitehall: 'If you will furnish me with a new identity and a"
1740 PRINT "lifetime supply of Scotch, I will give up my life of arms dealing"
1750 PRINT "and will provide you with much valuable information. I will be"
1760 PRINT "on the Orient Express tonight. But you must contact me before"
1770 PRINT "the train reaches Uzunkopru or that swine dealer of Maxim machine"
1780 PRINT "guns will have me killed by bandits like he did to Baron Wunster"
1790 PRINT "last month.' The note is not signed."
1800 PRINT " You, a British agent, are assigned to take the train, rescue"
1810 PRINT "the defector, and arrest the killer."
1820 PRINT " You know there are five notorious arms dealers of different"
1830 PRINT "nationalities operating in Europe under an uneasy truce as each"
1840 PRINT "deals in a different kind of weapon. But it is obvious that the"
1850 PRINT "truce has ended." : A4 = A5 : PRINT : PRINT : RETURN
1860 PRINT "Press any key to call a taxi…" : WHILE LEN(INKEY$) = 0 : WEND : RETURN
1870 '
1880 'Subroutine to read meals, conversations, hazards, day, times, location
1890 FOR I = 1 TO 24 : READ X, ME(I), CN(I), DA(I), TA(I), TD(I), LA$(I), LB$(I)
1900 NEXT I : RETURN
1910 DATA 1, 0, 0, 0, 1, 0, 1430, "London", "England"
1920 DATA 2, 1, 2, 0, 1, 1855, 1919, "Calais", "France"
1930 DATA 3, 0, 1, 0, 1, 2233, 2253, "Paris (Nord)", "France"
1940 DATA 4, 4, 0, 0, 1, 2316, 2350, "Paris (Lyon)", "France"
1950 DATA 5, 4, 0, 1, 2, 600, 620, "Vallorbe", "Switzerland"
1960 DATA 6, 0, 1, 0, 2, 700, 707, "Lausanne", "Switzerland"
1970 DATA 7, 3, 1, 1, 2, 732, 734, "Montreux", "Switzerland"
1980 DATA 8, 0, 1, 1, 2, 919, 927, "Brig", "Switzerland"
1990 DATA 9, 0, 3, 0, 2, 1005, 1025, "Domodossola", "Italy"
2000 DATA 10, 2, 2, 0, 2, 1223, 1320, "Milan", "Italy"
2010 DATA 11, 1, 2, 0, 2, 1705, 1730, "Venice (S. Lucia)", "Italy"
2020 DATA 12, 0, 1, 0, 2, 1954, 2014, "Trieste", "(Free State)"
2030 DATA 13, 0, 1, 0, 2, 2044, 2110, "Opicina", "Italy"
2040 DATA 14, 0, 2, 0, 2, 2119, 2225, "Sezana", "Slovenia"
2050 DATA 15, 4, 0, 0, 3, 21, 107, "Ljubljana", "Slovenia"
2060 DATA 16, 4, 0, 0, 3, 310, 330, "Zagreb", "Croatia"
2070 DATA 17, 3, 2, 0, 3, 900, 956, "Belgrade", "Serbia"
2080 DATA 18, 2, 1, 0, 3, 1334, 1356, "Crveni Krst", "Serbia"
2090 DATA 19, 0, 2, 0, 3, 1555, 1634, "Caribrod", "Serbia"
2100 DATA 20, 1, 2, 0, 3, 1856, 1935, "Sofia", "Bulgaria"
2110 DATA 21, 4, 0, 2, 4, 45, 120, "Svilengrad", "Bulgaria"
2120 DATA 22, 4, 0, 2, 4, 406, 445, "Pithion", "Greece"
2130 DATA 23, 3, 0, 3, 4, 505, 545, "Uzunkopru", "Turkey"
2140 DATA 24, 0, 0, 0, 4, 1230, 0, "Constantinople", "Turkey"
2150 '
2160 'Subroutine to read statements of travelers
2170 FOR I = 1 TO 24 : READ CS(I), CP(I), C$(I) : NEXT I : RETURN
2180 DATA 1, 0, "I've heard they all have different color chalets on a north-south ridge in the Tyrol region."
2190 DATA 2, 0, "The Austrian said he likes the look of natural wood and would never paint his chalet."
2200 DATA 3, 0, "They gave the waiter a difficult time. The Turk ordered beer and the other four all ordered different drinks."
2210 DATA 4, 0, "The Greek told me he hunts deer, but he never hunts with any of the others because they all hunt different animals."
2220 DATA 5, 1, "My brother delivered a case of Kirsch to the green chalet. He remembers it being just south of the gaudy red chalet."
2230 DATA 6, 0, "The Pole asked me—can you imagine that?—if I wanted to buy any howitzers."
2240 DATA 7, 2, "One of them asked me to cook some pheasant that he shot. He said that I should come to the yellow chalet."
2250 DATA 8, 1, "One time my brother said he delivered a case of Cognac to the middle chalet."
2260 DATA 9, 0, "The Rumanian said he had the shortest distance to drive from his chalet to the railroad station at Munich."
2270 DATA 10, 0, "One of them bragged that his military rifles were so accurate that he bagged a fox with one of them."
2280 DATA 11, 0, "The man who hunts wild boar said that the pistol dealer who lives in the chalet next to his often gives loud parties."
2290 DATA 12, 0, "The pheasant hunter complained that the arms dealer in the chalet next to his makes far too much noise testing his mortars."
2300 DATA 13, 0, "The gin drinker bragged that he shot sixty warthogs on a single day last August."
2310 DATA 14, 0, "The Rumanian said he looks out on a blue chalet."
2320 DATA 15, 0, "The Cognac drinker bragged that he is the best hunter and can drink more than all of the rest of them combined."
2330 DATA 16, 0, "The one carrying the pistol said he thinks the boar's head over his neighbor's doorway is revolting."
2340 DATA 17, 0, "One of them said that one day he'd like to lob a mortar shell at the string of pheasants drying in his neighbor's yard."
2350 DATA 18, 0, "The Kirsch drinker said he loved the roast chicken he had to eat last night."
2360 DATA 19, 0, "The one carrying the pistol had a second helping of pie."
2370 DATA 20, 0, "One commented that his beef dinner wasn't nearly as good as the boar that he shot last week."
2380 DATA 21, 0, "The Pole asked for more soup."
2390 DATA 22, 0, "The one eating all the cheese mumbled that it was the same color as his chalet."
2400 DATA 23, 0, "The Rumanian and Austrian got completely drunk last night."
2410 DATA 24, 0, "I'd like to visit the blue chalet. The owner is said to serve excellent lobster."
2420 '
2430 'Subroutine to read the names of those on the train
2440 FOR I = 1 TO 25 : READ N$(I) : NEXT I : RETURN
2450 DATA "R. Brundt (a waiter)", "C. D'Arcy (a chef)"
2460 DATA "Herbert Hoover", "Baron Rothschild", "Guido Famadotta", "Gustav Mahler"
2470 DATA "Robert Baden-Powell", "Fritz Kreisler", "Dame Melba", "Gerald Murphy"
2480 DATA "Calouste Gulbenkian", "Captain G.T. Ward", "Sir Ernest Cassel"
2490 DATA "Major Custance", "F. Scott Fitzgerald", "Elsa Maxwell", "Mata Hari"
2500 DATA "Clayton Pasha", "Arturo Toscanini", "Maharajah Behar", "Leon Wenger"
2510 DATA "Sarah Bernhardt", "Arthur Vetter", "Isadora Duncan", "David K.E. Bruce"
2520 '
2530 'Subroutine to read menus
2540 FOR I = 1 TO 13 : READ MB$(I) : NEXT I : 'Breakfast selections
2550 FOR I = 1 TO 26 : READ MD$(I) : NEXT I : 'Dinner selections
2560 RETURN
2570 DATA "Variete Jus de Fruits", "Prunes Macerees dans le Vin"
2580 DATA "Demi Pamplemouse", "Trois Oeufs sur le Plat", "Oeufs Poches"
2590 DATA "Omelette aux Champignons", "Tranches de Pain Beurees et Confiturees"
2600 DATA "Galettes", "Pommes-Frites", "Patisseries", "Croissants", "Yogurt"
2610 DATA "Cafe, The, Lait, Vin, Eau Minerale"
2620 DATA "Huitres de Beernham", "Cantaloup glace au Marsale"
2630 DATA "Compote des Tomates Fraiches", "Potage Reine"
2640 DATA "La Natte de Sole au Beurre", "Truite de riviere meuniere"
2650 DATA "Poulet de grain grille a Diable", "Roti de Veau a l'Osille"
2660 DATA "Truite Saumonee a la Chambord", "Chaud-froid de Caneton"
2670 DATA "Chaudfroix des Langouste a la Parisienne"
2680 DATA "Les Noisettes de Chevreuil Renaissance", "Becasses a la Monaco"
2690 DATA "Pointes d'asperge a la creme", "Parfait de foies gras"
2700 DATA "Salade Catalane", "Truffes au Champagne"
2710 DATA "Tagliatelle de carottes et courgettes", "Souffle d'Anisette"
2720 DATA "Creme de Caramel blond", "Sorbet aux Mures de Framboisier"
2730 DATA "La selection du Maitre Fromager", "Corbeille de Fruits"
2740 DATA "Les Mignardises", "Selection du vins et liquors"
2750 '
2760 'Subroutine to shuffle 24 integers
2770 FOR I = 1 TO 23
2780 K = I + INT((25 - I) * RND(1)) : X = CS(I) : CS(I) = CS(K) : CS(K) = X : NEXT I
2790 RETURN
2800 '
2810 'Subroutine to check for yes or no answer
2820 IF LEFT$(A$, 1) = "Y" OR LEFT$(A$, 1) = "y" THEN A = 0 : RETURN
2830 IF LEFT$(A$, 1) = "N" OR LEFT$(A$, 1) = "n" THEN A = 1 : RETURN
2840 INPUT "Please enter Y for 'yes' or N for 'no.' Which is it";A$ : GOTO 2810
2850 '
2860 'Subroutine creates a short pause
2870 FOR X = 1 TO 1000 : NEXT X : RETURN
2880 '
2890 'Subroutine to ring buzzer and open door
2900 PRINT : PRINT "Your compartment buzzer rings…"
2910 BEEP : FOR KA = 1 TO 300 : NEXT : BEEP : 'Ring the buzzer
2920 PRINT "Press any key to open the door."
2930 WHILE LEN(INKEY$) = 0 : WEND : RETURN
2940 '
2950 'Subroutine to finish eating
2960 LOCATE 24, 18 : PRINT "Press any key when you have finished eating";
2970 A3 = A3 + 5 * (J + 1) - POS(X) : WHILE LEN(INKEY$) = 0 : WEND : CLS : RETURN
2980 '
2990 'Subroutine to produce train noises
3000 PRINT : PRINT "Clackety clack…clackety clack…clackety clack"
3010 IF RND(1) > .5 THEN RETURN ELSE FOR KA = 6 TO 1 STEP -1
3020 FOR I = 1 TO 4 : SOUND 130, .5 : FOR K = 1 TO 180 : NEXT : NEXT
3030 IF KA = 4 THEN GOSUB 3110
3040 FOR K = 1 TO 50 + KA * 120 : NEXT : NEXT : RETURN
3050 '
3060 'Subroutine to print time
3070 T = T + 10000 : T$ = STR$(T) : IF VAL(RIGHT$(T$, 2)) > 59 THEN T = T + 40
3080 T$ = STR$(T) : PRINT " " MID$(T$, 3, 2) ":" RIGHT$(T$, 2) " ";
3090 RETURN
3100 '
3110 'Subroutine to blow train whistle
3120 IF RND(1) > .5 THEN RETURN
3130 SOUND 500, 15 : FOR K = 1 TO 1400 : NEXT : SOUND 500, 3
3140 FOR K = 1 TO 200 : NEXT : SOUND 500, 20 : RETURN
3150 '
3160 'Error-handling subroutine
3170 A5 = ERR : RESUME NEXT
3180 '
3190 End of journey
3200 PRINT : PRINT "Your journey has ended. Georges Nagelmackers and the"
3210 PRINT "management of Cie. Internationale des Wagons-Lits "
3220 PRINT "hope you enjoyed your trip on the Orient Express, the"
3230 PRINT "most famous train in the world." : PRINT : PRINT
3240 IF A5< >1 THEN 3310 ELSE BEEP : BEEP : BEEP : X = 0
3250 PRINT "Whitehall telegraphs congratulations for identifying both"
3260 PRINT "the killer and defector correctly." : GOSUB 2860 : GOSUB 2860
3270 FOR I = 1 TO 25 : FOR K = 1 TO 100 : NEXT K : LOCATE 15, 30 : PRINT X$ : BEEP
3280 IF X = 0 THEN X$ = "CONGRATULATIONS !" : X = 1 : GOTO 3300
3290 X$ = " " : X = 0 : 'X$ = 17 spaces to erase congratulations
3300 NEXT I : PRINT : PRINT : PRINT
3310 INPUT "Would you like to ride again";A$ : GOSUB 2810
3320 IF A = 0 THEN PRINT "Okay. Good journey!" : GOSUB 2860 : RUN
3330 PRINT "Okay. So long for now." : GOSUB 2860 : KEY ON : CLS : END