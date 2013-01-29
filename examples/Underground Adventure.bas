Auto 1

# Run-time Variables

Var df: Num = 0
Var gf: Num = 1
Var gs: Num = 0
Var fl: Num = 0
Var oc: Num = 0
Var tb: Num = 0
Var vb: Num = 0
Var pd: Num = 0
Var zz: Num = 0
Var sc: Num = 0
Var lc: Num = 0
Var br: Num = 0
Var np: Num = 0
Var x: NumArray(9) = 0, 0, 0, 0, 0, 0, 0, 0, 0
Var i: NumFOR = 35, 88, 1, 9000, 3
Var c$: Str = "\#013"

# End Run-time Variables

   1 REM ***UNDERGROUND-ADVENTURE***
   2 LET df=0:\
     LET gf=1:\
     LET gs=0:\
     LET fl=0:\
     LET oc=0
   3 LET tb=0:\
     LET vb=0:\
     LET pd=0:\
     LET zz=0:\
     LET sc=0:\
     LET lc=0:\
     LET gs=0:\
     LET br=0:\
     LET np=0
   4 DIM x(9)
   5 LET c$=CHR$ (13)
  10 GO SUB 9000:\
     GO SUB 2001:\
     LET cp=1
  15 LET d$="It is now pitch dark.   Carry onany further and you'll fall intoa deep, deep pit."
  20 LET i$="You can't go that way."
  25 LET g$="The gate is now shut."
  26 LET l$="Going down.....!"
  27 LET f$="The door is now shut."
 200 GO SUB 5000
 206 IF tb THEN LET o(9)=cp
 208 IF tb=1 THEN PRINT :\
     PRINT "You're being followed by a tame bear."
 209 IF tb AND cp=45 THEN PRINT "The ladder snaps in two under   the weight of the bear!!":\
     LET o(13)=0:\
     LET p(45,2)=0:\
     LET cp=45
 210 GO SUB 390
 220 IF vb=34 THEN GO TO 1950
 225 IF vb>9 AND a$="" THEN PRINT "You need a direct object.":\
     GO TO 210
 226 IF (vb=2 OR vb=6) AND a$="" THEN PRINT "You're not helping me here!":\
     GO TO 210
 227 IF a$<>"" AND vb=1 AND no=0 THEN PRINT "That doesn't make any sense.":\
     GO TO 210
 240 GO TO vb*50+250
 300 IF a$<>"" AND no=0 THEN PRINT "You have me baffled.":\
     GO TO 210
 302 IF no>28 OR no<21 THEN PRINT "I don't understand you.":\
     GO TO 210
 304 IF no>24 THEN LET no=no-4
 306 LET no=no-20
 308 IF no AND cp=3 AND gf=1 THEN GO TO 5200
 310 IF no AND pd THEN PRINT "You have fallen into a very deeppit.  This could be trouble.":\
     GO TO 612
 312 IF p(cp,no)=0 THEN PRINT "Nope!  You can't go that way.":\
     GO TO 210
 314 IF cp=53 AND no=2 THEN GO TO 6300
 316 LET cp=p(cp,no):\
     GO TO 200
 350 IF no=0 THEN GO TO 1900
 352 GO SUB 5300
 354 IF o(no)=-1 THEN PRINT "You've already got it!":\
     GO TO 210
 356 IF o(no)<>cp THEN PRINT "I can't see it here.":\
     GO TO 210
 358 IF no=18 AND o(19)<>-1 THEN PRINT "You haven't got a container.":\
     GO TO 210
 360 IF no=39 AND o(19)<>-1 THEN PRINT "You haven't got a container.":\
     GO TO 210
 362 IF no=39 AND o(19)=-1 THEN LET o(39)=0:\
     LET no=52:\
     LET o(19)=o:\
     LET zz=zz-1:\
     GO TO 380
 364 IF no=18 AND o(19)=-1 THEN LET o(18)=0:\
     LET no=51:\
     LET o(19)=0:\
     LET zz=zz-1:\
     GO TO 380
 366 IF no=1 OR no=3 OR no=6 OR no=9 AND no=11 OR no=17 THEN PRINT "Don't be ridiculous!":\
     GO TO 210
 368 IF no=20 OR no=29 OR no=30 OR no=31 OR no=32 OR no=35 OR no=36 THEN PRINT "I can't do that!":\
     GO TO 210
 370 IF no=40 OR no=41 OR no=43 OR no=49 THEN PRINT "It can't be done!":\
     GO TO 210
 372 IF no=8 OR no=50 THEN PRINT "There's no point carrying that, so I won't!":\
     GO TO 210
 374 IF zz>4 THEN PRINT "You're carrying too much.":\
     GO TO 210
 376 IF no=12 AND cp=10 THEN LET p(10,4)=0:\
     LET p$(10)="faced by a vast chasm.":\
    
 378 IF no=15 AND sc=0 THEN PRINT "You can't get it yet.":\
     GO TO 210
 380 LET zz=zz+1:\
     LET o(no)=-1:\
     PRINT "OK.":\
     GO TO 21
 390 PRINT :\
     PRINT :\
     PRINT "What Now * ?";:\
     GO SUB 8000:\
     PRINT m$:\
     PRINT
 391 LET a$="":\
     LET b$="":\
     LET vb=0:\
     LET no=0
 392 LET lc=LEN m$:\
     FOR i=1 TO lc:\
     IF m$(i TO i)<>" " THEN LET b$=b$+m$(i TO i):\
     NEXT i
 393 LET e$=b$:\
     IF e$="go" THEN GO TO 397
 394 IF LEN e$<3 THEN PRINT "I don't understand you at times!":\
     GO TO 210
 395 LET b$=e$(1 TO 3):\
     FOR i=1 TO nv:\
     IF b$=v$(i) THEN LET vb=i:\
     GO TO 398
 396 NEXT i
 397 LET vb=1:\
     LET a$=b$:\
     GO TO 402
 398 IF LEN e$+1>=LEN m$ THEN LET no=0:\
     RETURN
 399 GO TO 402
 400 GO TO 200
 402 LET a$=m$(LEN e$+2 TO LEN m$)
 403 IF LEN a$<3 THEN PRINT "Je ne comprends pas!"
 404 LET h$=a$:\
     LET a$=a$(1 TO 3):\
     FOR i=1 TO nn:\
     IF a$=j$(i) THEN GO TO 407
 405 NEXT i
 406 LET no=0:\
     RETURN
 407 LET no=i:\
     RETURN
 450 PRINT "You are carrying the following:":\
     LET gs=0:\
     LET zz=0
 452 FOR i=1 TO lo:\
     IF o(i)=-1 THEN PRINT o$(i):\
     LET gs=gs+1:\
     LET zz=zz+1
 454 NEXT i
 456 IF gs=0 THEN PRINT "Not a lot!"
 458 GO TO 210
 500 PRINT "There are no points to be scoredin this game, old chum.         You've just got to find a way   out of here."
 502 GO TO 210
 550 IF no=0 THEN GO TO 1900
 552 GO SUB 5300
 554 IF o(no)<>-1 THEN PRINT "You aren't even carrying it!":\
     GO TO 210
 556 IF no=19 THEN PRINT "Smash...":\
     LET o(19)=0:\
     LET o(59)=cp:\
     LET zz=zz-1:\
     GO TO 210
 558 IF no=51 THEN PRINT "Smash...":\
     LET o(19)=0:\
     LET o(51)=cp:\
     LET zz=zz-1:\
     GO TO 210
 560 IF no=52 THEN PRINT "Smash...":\
     LET o(19)=0:\
     LET o(52)=cp:\
     LET zz=zz-1:\
     GO TO 210
 562 IF no=16 THEN PRINT "Oh dear!  It vanishes in a      sparkle of shattered glass!"
 564 IF no=16 THEN LET o(16)=0:\
     LET zz=zz-1:\
     GO TO 210
 566 IF no=46 THEN LET o(no)=0:\
     LET o(45)=cp:\
     LET zz=zz-1:\
     PRINT "OK.":\
     GO TO 210
 568 IF no<>12 THEN GO TO 576
 570 IF no<>10 THEN GO TO 576
 572 PRINT "Brilliant!  Now you can walk    across the plank!"
 574 LET o(12)=cp:\
     LET p(10,4)=14:\
     LET p$(10)="walking across the plank.":\
     LET zz=zz-1:\
     GO TO 210
 576 PRINT "OK.":\
     LET zz=zz-1:\
     LET o(no)=cp:\
     IF tb=1 THEN GO TO 580
 578 GO TO 210
 580 PRINT "The bear glares at you and runs away in a fit of pique.":\
     LET tb=0:\
     LET o(9)=INT (RND*40)+1
 582 LET zz=zz-1:\
     GO TO 210
 600 PRINT "I'm afraid that you won't get   much help from me, so just keep on trying things.  If nothing's happening, try using different  words instead."
 602 GO TO 210
 612 PRINT "You appear to have blown it.     You're dead.":\
     GO SUB 6800
 614 PRINT "Do you want another game (y/n)?"
 616 IF INKEY$="" THEN GO TO 616
 617 IF INKEY$="y" THEN RUN
 618 IF INKEY$="n" THEN CLS :\
     PRINT "Bye.":\
     PRINT AT 10,10; FLASH 1;"GAME OVER"; FLASH 0
 620 GO TO 616
 650 GO TO 1890
 700 IF no=15 THEN PRINT "Cross what?!":\
     GO TO 210
 702 IF cp<>15 AND cp<>10 THEN PRINT "There's nothing here to cross.":\
     GO TO 210
 704 IF no<>1 AND no<>6 AND no<>12 THEN PRINT "Mmmmm. What a strange idea.":\
     GO TO 210
 706 PRINT "Why don't you just type in a    direction instead?":\
     GO TO 210
 750 GO TO 350
 800 IF no=0 THEN PRINT "Open what?!":\
     GO TO 210
 802 IF cp<>60 AND cp<>3 THEN PRINT "There's nothing here to open.":\
     GO TO 210
 804 IF cp=60 THEN GO TO 812
 806 IF gf=1 THEN PRINT "But it is open!":\
     GO TO 210
 808 IF o(42)<>-1 THEN PRINT "But you haven't got the key.":\
     GO TO 210
 810 PRINT "The gate swings open.":\
     LET gf=1:\
     LET p(3,1)=2:\
     GO TO 2510
 814 IF o(33)<>-1 THEN PRINT "You've nothing strong enough to open it with.":\
     GO TO 210
 816 PRINT "You'll just have to try and do  this some other way.":\
     GO TO 210
 850 IF no=0 THEN PRINT "Close what?!":\
     GO TO 210
 852 IF no<>32 AND no<>35 THEN PRINT "Que?":\
     GO TO 210
 854 IF cp=3 THEN GO TO 860
 856 IF df=0 THEN PRINT "It's already closed.":\
     GO TO 210
 858 PRINT "OK.":\
     LET p(60,2)=0:\
     LET df=0:\
     LET p$(60)="faced with a closed door.":\
     GO TO 210
 860 IF gf=0 THEN PRINT "But it's already closed.":\
     GO TO 210
 862 PRINT "The gate is a magical one and,  once opened, it can never be    closed by mere humans like you.":\
     GO TO 210
 900 IF no=0 THEN GO TO 1900
 902 GO SUB 5300
 904 IF o(no)<>-1 AND o(no)<>cp THEN PRINT "I can't see it here.":\
     GO TO 210
 906 IF no<>10 THEN PRINT "I don't think so somehow.":\
     GO TO 210
 908 PRINT "Mmmm-mmmm!  That was delicious.":\
     LET o(10)=0:\
     LET zz=zz-1:\
     GO TO 210
 950 IF no=0 THEN PRINT "I don't understand you.":\
     GO TO 210
 952 IF no<>9 THEN PRINT "It isn't hungry!":\
     GO TO 210
 954 IF o(10)<>-1 THEN PRINT "You've nothing to feed it with.":\
     GO TO 210
 956 GO TO 1072
1000 IF no=0 THEN GO TO 1900
1002 GO SUB 5300
1004 IF no<>51 AND no<>52 THEN PRINT "You must be joking!":\
     GO TO 210
1006 IF no=51 THEN PRINT "Urggh!":\
     LET o(51)=0:\
     LET o(19)=-1:\
     GO TO 210
1008 PRINT "Glug-glug-glug .... hic!":\
     LET o(52)=0:\
     LET o(19)=-1:\
     GO TO 210
1050 IF no=0 THEN PRINT "Offer what?!":\
     GO TO 210
1052 GO SUB 5300
1054 IF o(no)<>-1 THEN PRINT "You've got to have it to offer  it!":\
     GO TO 210
1056 IF no=10 THEN GO TO 1070
1058 IF no<>52 THEN PRINT "You've nothing worth offering.":\
     GO TO 210
1060 IF cp<>50 THEN PRINT "There's no-one here who wants it(except perhaps for you)":\
     GO TO 210
1062 PRINT "The denizen of the caverns downsit in one draught, and          gratefully shows you a new      tunnel."
1064 PRINT :\
     PRINT "He then stumbles away to sleep  it all off!"
1066 LET o(52)=0:\
     LET o(19)=-1:\
     LET p(50,4)=55:\
     LET p$(50)="walking past the old spirits."
1067 LET o(29)=0:\
     GO TO 210
1070 IF cp<>27 THEN PRINT "There's nothing here that wants it!":\
     GO TO 210
1072 PRINT "The bear gratefully accepts the bun, and stands aside to reveal a new path way."
1074 PRINT :\
     PRINT "In a show of gratitude, he now  attatches himself to you like a limpet!":\
     LET p(27,1)=28
1075 LET p$(27)="walking past the scent of old   bear."
1076 LET o(10)=0:\
     LET zz=zz-1:\
     LET tb=1:\
     GO TO 210
1100 IF no=0 THEN GO TO 1900
1102 GO SUB 5300
1104 IF o(no)<>-1 AND o(no)<>cp THEN PRINT "But it ain't here!":\
     GO TO 210
1106 IF no<>2 THEN PRINT "Wave,wave,wave, but nothing     happens.":\
     GO TO 210
1108 IF cp<>15 THEN PRINT "Nothing happens.":\
     GO TO 210
1110 IF br=1 THEN PRINT "You've already done that.":\
     GO TO 210
1112 PRINT "A crystal bridge now spans the  chasm (lucky, aren't you)":\
     LET o(6)=cp:\
     LET p(15,2)=17
1114 LET p(15,3)=16:\
     LET p$(15)="walking across the chasm.":\
     LET br=1:\
     GO TO 210
1150 GO TO 1200:\
    
1200 IF no=0 THEN GO TO 1900
1202 GO SUB 5300
1204 IF o(no)<>-1 AND o(no)<>cp THEN PRINT "I can't see that here.":\
     GO TO 210
1205 IF no<>3 AND no<>15 AND no<>5 AND no<>12 AND no<>32 THEN PRINT "Not a chance!":\
     GO TO 210
1206 IF o(4)<>-1 THEN PRINT "You've got nothing to cut it    with.":\
     GO TO 210
1208 IF no<>3 AND no<>12 THEN PRINT "Your axe is not strong enough.":\
     GO TO 210
1210 IF no=3 THEN GO TO 1220
1212 PRINT "The plank is now nicely hewn,   but you'll need something else  before you can make a ladder."
1214 LET o(12)=0:\
     LET o(53)=-1:\
     GO TO 210
1220 PRINT "Timberrrr!  The tree crashes to the ground."
1222 LET p(21,3)=22:\
     LET p$(21)="walking past a dead tree.":\
     LET o$(3)="an ex-tree":\
     GO TO 210
1250 IF no<>3 AND no<>5 AND no<>13 THEN PRINT "I beg your pardon?":\
     GO TO 210
1252 IF no=3 THEN PRINT "Oh, these old war wounds!  sorrybut it can't be done.":\
     GO TO 210
1254 IF no=5 THEN GO TO 1266
1256 IF o(13)<>cp THEN PRINT "I can't see it anywhere around  here.":\
     GO TO 210
1257 IF cp<>45 AND cp<>47 THEN PRINT "There's no point in climbing theladder here.":\
     GO TO 210
1258 IF cp=45 THEN LET o(13)=47:\
     LET cp=47:\
     GO TO 200
1260 LET o(13)=45:\
     LET cp=45:\
     GO TO 200
1266 IF o(5)<>cp THEN PRINT "I don't see it on the ground    anywhere.":\
     GO TO 210
1267 IF cp<>35 AND cp<>36 THEN PRINT "There's no point climbing the   rope here.":\
     GO TO 210
1268 IF cp=35 THEN LET o(5)=36:\
     LET cp=36:\
     GO TO 200
1270 LET o(5)=35:\
     LET cp=35:\
     GO TO 200
1300 IF no=0 THEN GO TO 1900
1302 GO SUB 5300
1304 IF o(no)<>cp AND o(no)<>-1 THEN PRINT "I can't see it here.":\
     GO TO 210
1306 IF o(44)<>-1 THEN PRINT "You've nothing to light it with.":\
     GO TO 210
1308 IF no<>45 AND no<>7 THEN PRINT "Don't be silly.":\
     GO TO 210
1310 IF no=7 THEN GO TO 1320
1312 IF o(46)=-1 THEN PRINT "It's already lit!":\
     GO TO 210
1314 PRINT "OK.":\
     LET o(46)=-1:\
     LET o(45)=0:\
     LET pd=0:\
     GO TO 210
1320 IF o(7)=-1 THEN PRINT "Booooom!   You've just blown    yourself to bits!":\
     GO TO 612
1322 IF cp<>4 THEN PRINT "Kaboooom.  The dust slowly      clears to reveal ...  nothing's changed at all.":\
     LET o(7)=0
1324 PRINT "Kaboooom!  The wall's been blownto smithereens!"
1326 LET o(7)=0:\
     LET zz=zz-1:\
     LET p(4,4)=5:\
     LET p$(4)="walking along a dusty track.":\
     GO TO 210
1350 IF no=0 THEN PRINT "Attack what?":\
     GO TO 210
1351 GO SUB 5300:\
     IF o(no)<>cp AND o(no)<>-1 THEN PRINT "Where is it?!":\
     GO TO 210
1352 IF no<>9 AND no<>11 AND no<>29 AND no<>30 AND no<>31 THEN PRINT "What an odd request.":\
     GO TO 210
1354 PRINT "This is not one of your better  suggestions!":\
     GO TO 210
1400 IF no=0 THEN PRINT "Kill what?":\
     GO TO 210
1401 GO SUB 5300:\
     IF o(no)<>cp AND o(no)<>-1 THEN PRINT "Where is it?!":\
     GO TO 210
1402 GO TO 1352
1450 IF no=0 THEN PRINT "Hit what?":\
     GO TO 210
1452 GO SUB 5300:\
     IF o(no)<>cp AND o(no)<>-1 THEN PRINT "Where is it?!":\
     GO TO 210
1454 PRINT "You feel a slight twinge of painbut otherwise nothing happens.":\
     GO TO 210
1500 IF no=0 THEN PRINT "Make what?":\
     GO TO 210
1502 IF no<>13 THEN PRINT "I despair of you sometimes.":\
     GO TO 210
1504 IF o(53)<>-1 OR o(14)<>-1 OR o(4)<>-1 THEN PRINT "You need more materials.":\
     GO TO 210
1506 PRINT "You have a brand new ladder.":\
     LET o(13)=-1:\
     LET o(14)=0:\
     LET o(53)=0:\
     LET zz=zz-1
1508 GO TO 210
1550 IF no=0 THEN PRINT "Reflect what?":\
     GO TO 210
1552 IF no<>47 THEN PRINT "I don't compute this instruction":\
     GO TO 210
1554 IF cp<>93 THEN PRINT "Nothing happens.":\
     GO TO 210
1556 IF sc=1 THEN PRINT "You've already done that.":\
     GO TO 210
1558 PRINT :\
     PRINT "The light is reflected back and the shimmering curtain falls    aside."
1560 LET p(93,1)=95:\
     LET o(15)=cp:\
     LET p$(93)="walking past a shimmering light.":\
     LET sc=1:\
     GO TO 210
1600 IF no=0 THEN PRINT "Oil what?":\
     GO TO 210
1602 IF o(51)<>-1 THEN PRINT "But you've no oil.":\
     GO TO 210
1604 IF cp<>79 THEN PRINT "Nothing worth oiling around here":\
     GO TO 210
1605 IF no<>17 THEN PRINT "You've wasted a lot of oil.":\
     LET o(51)=0:\
     LET o(19)=-1:\
     GO TO 210
1606 PRINT "The track slides noiselessly    away, to reveal more tunnels!"
1608 LET o(51)=0:\
     LET o(19)=-1:\
     LET p(79,3)=80:\
     LET p(79,4)=81
1610 LET p$(79)="walking past a smooth track.":\
     LET o(17)=0:\
     GO TO 210
1650 IF no=0 THEN GO TO 1900
1651 GO SUB 5300
1652 IF o(no)<>cp AND o(no)<>-1 THEN PRINT "Where is it?!":\
     GO TO 210
1653 IF o(38)<>-1 THEN PRINT "You've nothing to stab it with.":\
     GO TO 210
1654 IF no<>30 THEN PRINT o$(no):\
     PRINT "is not impressed!":\
     GO TO 210
1656 PRINT "The spider dies in a glorious   display of bit-acting, and      reveals:"
1658 PRINT "a new passage way!":\
     LET p(84,3)=86:\
     LET p(84,4)=85:\
     LET o$(30)="a dead spider"
1660 LET p$(84)="walking past a dead      spider.":\
     GO TO 210
1700 IF no=0 THEN GO TO 1900
1701 GO SUB 5300
1702 IF o(no)<>cp AND o(no)<>-1 THEN PRINT "Where is it?!":\
     GO TO 210
1703 IF o(34)<>-1 THEN PRINT "You're not carrying any spray.":\
     GO TO 210
1704 IF no<>31 THEN PRINT "Cough-cough Splutter -splutter!":\
     GO TO 210
1706 PRINT "The evil fly coughs its last andreveals a hidden tunnel."
1708 LET p(74,4)=75:\
     LET p$(74)="walking past a dead fly!":\
     LET o$(31)="a dead fly":\
     GO TO 210
1735 IF no=4 AND np=1 THEN GO TO 6010
1750 IF no=0 THEN PRINT "Throw what?":\
     GO TO 210
1751 IF no<>33 AND no<>4 THEN GO TO 552
1752 IF no=4 AND np=0 THEN GO TO 552
1753 IF no=4 AND np=1 THEN GO TO 6010
1754 IF o(33)<>-1 THEN PRINT "But you haven't got it!":\
     GO TO 210
1755 IF cp<>60 THEN PRINT "OK!  It vanishes in a cloud of  dust.":\
     LET o(33)=0:\
     LET zz=zz-1:\
     GO TO 210
1756 PRINT "The door shatters under the     force of the blow, and reveals anew corridor."
1758 LET p(60,1)=61:\
     LET p(60,4)=65:\
     LET p$(60)="walking past the door.":\
     LET o(33)=0
1760 LET zz=zz-1:\
     LET df=1:\
     GO TO 210
1800 IF no=0 THEN GO TO 1900
1801 GO SUB 5300
1802 IF o(no)<>cp AND o(no)<>-1 THEN PRINT "Where is it?!":\
     GO TO 210
1803 PRINT "Interesting, but unrewarding.":\
     GO TO 210
1850 IF no=0 THEN GO TO 1900
1851 GO SUB 5300
1852 IF no<>48 THEN PRINT "There's nothing here to read.":\
     GO TO 210
1854 IF o(48)<>-1 THEN PRINT "You're not holding it.":\
     GO TO 210
1856 PRINT "There's material in here to make"
1858 PRINT "a ladder, like nails and planks"
1859 PRINT "and axes and things."
1860 PRINT "There's also more than a touch "
1862 PRINT "of magic in the air!":\
     GO TO 210
1890 PRINT "OK.":\
     PRINT "Do you want to save your        progress on to tape (Y/N)?"
1892 IF INKEY$="" THEN GO TO 1892
1893 IF INKEY$="y" THEN GO TO 3000
1894 IF INKEY$="n" THEN GO TO 614
1896 GO TO 1892
1900 IF no=0 THEN PRINT "What's a ";h$;"!":\
     GO TO 210
1901 IF no=43 OR no=1 OR no=6 THEN PRINT "There's nothing interesting here":\
     GO TO 210
1903 GO SUB 5300
1904 IF o(no)<>cp AND o(no)<>-1 THEN PRINT "Where is it?!":\
     GO TO 210
1905 IF no=2 OR no=16 OR no=33 OR no=37 OR no=38 THEN PRINT "This has useful powers.":\
     GO TO 210
1906 PRINT "It's nothing more than:":\
     PRINT o$(no):\
     GO TO 210
1950 IF cp=15 OR cp=10 OR cp=45 THEN PRINT "I told you so ....":\
     PRINT l$:\
     GO TO 612
1952 PRINT "Wheee!":\
     GO TO 210
1960 IF no=0 THEN PRINT "Break what?":\
     GO TO 210
1962 GO SUB 5300:\
     IF o(no)<>cp AND o(no)<>-1 THEN PRINT "I can't.  It isn't here.":\
     GO TO 210
1964 PRINT "You're not strong enough to     break anything by yourself!":\
     GO TO 210
1970 IF no=0 THEN PRINT "Push what?":\
     GO TO 210
1971 GO SUB 5300
1972 IF o(no)<>cp AND o(no)<>-1 THEN PRINT "I can't.  It isn't here.":\
     GO TO 210
1974 IF cp<>79 THEN PRINT "You can't":\
     GO TO 210
1976 PRINT "Try doing this another way, by  using something else.":\
     GO TO 210
1999 STOP
2000 GO TO 1960
2001 LET nv=38:\
     LET nn=53:\
     LET z=100:\
     LET lo=53:\
     DIM p$(z,48):\
     DIM p(z,4):\
     DIM o$(lo,10):\
     DIM o(lo):\
     DIM v$(nv,3):\
     DIM j$(nn,3):\
     DIM t$(4,5)
2002 LET p$(1)="on an old track heading  towards the caves.":\
     DATA 0,2,0,0
2003 LET p$(2)="getting ever nearer the  caves.":\
     DATA 1,3,0,0
2004 LET p$(3)="at the mouth of the caveswith paths everywhere."
2005 LET p$(5)="in a subterranean tomb,  dotted with crevices."
2006 LET p$(4)="in front of a solid wall of rock!"
2010 LET p$(6)="walking around the side  of the crevice room."
2012 LET p$(7)="surrounded by bricked up walls."
2013 DATA 2,15,20,4,0,0,3,0,6,13,4,9,0,5,0,7,0,9,6,8,0,10,7,0,7,12,5,10
2014 LET p$(8)="near the great chasm in the  rock, which plunges down    hundreds of feet."
2016 LET p$(9)="in the heart of crevice  room,with many tunnels."
2018 LET p$(10)="in front of a great chasmthat you cannot jump."
2019 DATA 8,11,9,0,10,0,12,0,9,0,13,11,5,0,0,12,0,0,10,0,3,0,0,0,0,18,0,15
2020 LET p$(11)="on the southern rim of   the chasm."
2021 DATA 15,33,18,19,16,34,0,17,0,32,17,0,0,0,21,3,0,0,0,20,23,0,0,21
2022 LET p$(12)="lost in chasm country!"
2024 LET p$(13)="in a room full of rocks, rocks, rocks and rocks."
2026 LET p$(14)="on the west side of the  chasm."
2028 LET p$(15)="faced with a crack that  is too wide to jump."
2030 LET p$(16)="in an east side chamber."
2032 LET p$(17)="on the main track throughthe caves."
2034 LET p$(18)="away from the main path  with a choice of route."
2037 LET p$(19)="in a sharply twisting    corridor."
2038 LET p$(20)="on a long east-west trackinto the depths!"
2040 LET p$(21)="forced to a halt by a    large underground tree."
2042 LET p$(22)="heading down a twisting  path into an old lair."
2044 LET p$(23)="surrounded by rock in a  mixture of corridors.":\
     DATA 25,22,24,0
2045 LET p$(24)="walking along an old     tunnel in the rocks."
2046 LET p$(25)="forced to turn sharply asthe path bends round.":\
     DATA 26,0,0,23,0,23,26,0,27,24,0,25
2048 LET p$(26)="walking along a fairly   large corridor."
2049 GO TO 2051
2050 GO TO 1970
2051 LET p$(27)="face to face with a very large bear!"
2052 LET p$(28)="at a T-junction behind   the bear's lair.":\
     DATA 0,26,0,0,0,27,30,29
2054 LET p$(29)="at a dead end.":\
     DATA 0,0,28,0,31,0,0,28,0,30,0,0
2056 LET p$(30)="near the heart of the    bear's hiding place."
2057 LET p$(31)="in an old cave used as a bear's resting place."
2058 LET p$(32)="heading down an offshoot from the main mine.":\
     DATA 19,42,33,41
2060 LET p$(33)="surrounded by shored up  timbers and walls."
2062 LET p$(34)="crawling over stones and rubble on a low path.":\
     DATA 17,0,34,32
2064 LET p$(35)="faced with a very deep   drop."
2065 DATA 18,0,35,33,0,0,0,34,0,0,38,39,0,37,0,0,36,0,0,40,37,0,0,0,39
2066 LET p$(36)="at the foot of the drop  with paths everywhere."
2068 LET p$(37)="walking along an easterlycorridor."
2070 LET p$(38)="forced into a sharp turn as the path bends."
2072 LET p$(39)="in a long, low east-west corridor."
2074 LET p$(40)="in a dead end and can go no further."
2075 DATA 0,0,32,0,32,0,0,0,42,0,44,46,0,45,0,43,44,0,0,0,0,0,43,0,0,52,49,48
2076 LET p$(41)="well and truly stopped bya vast wall of rock."
2078 LET p$(42)="face to face with a very angry panther!"
2080 LET p$(43)="at an underground   T-   junction."
2082 LET p$(44)="near a great incline."
2084 LET p$(45)="at the foot of a great   incline."
2086 LET p$(46)="in a dead end."
2088 LET p$(47)="at the top of the great  incline."
2090 LET p$(48)="near an old scary part ofthe caves."
2092 LET p$(49)="near a reputedly magical part of the caves ...."
2093 DATA 0,51,47,50,0,53,54,47,0,0,48,0,48,66,0,0,47,77,0,0,49,100,0,0,0,0,88,49
2094 LET p$(50)="halted by the  ghostly   spirit of the caves."
2096 LET p$(51)="on an offshoot from the  main track."
2097 LET p$(53)="stopped by an extremely  narrow squeeze."
2098 LET p$(52)="on an old path heading   north-south."
2099 GO TO 2101
2100 GO TO 3000
2101 DATA 56,57,50,58,0,55,0,0,55,0,0,0,0,0,55,59,60,0,58,0,0,59,0,0
2102 LET p$(55)="in an open corridor with many exits running off."
2103 LET p$(54)="near the magical caves."
2104 LET p$(56)="stuck in a dead end."
2106 LET p$(57)=p$(56)
2108 LET p$(58)="on a well trodden path   running east-west."
2110 LET p$(59)="forced to turn as the    path bobs and weaves."
2112 LET p$(60)="faced with door marked   'BEGONE STRANGER'."
2114 DATA 61,61,61,62,61,61,61,63,61,64,61,61,61,61,65,61,61,61,60,61
2115 LET p$(61)="in a tortured maze of    little passages."
2116 LET p$(62)=p$(61)
2117 LET p$(63)=p$(61)
2118 LET p$(64)=p$(61)
2119 LET p$(65)=p$(61)
2120 LET p$(66)="walking along a dim path with damp walls."
2122 DATA 51,67,0,68,66,0,0,69,66,0,68,0,67,0,71,69,0,70,72,0,74,71,0,0,73
2124 LET p$(67)="in a low,damp corridor."
2126 LET p$(68)="in a low corridor.It all seems very damp here."
2128 LET p$(69)="stopped by a wall of mistthat obscures light."
2130 LET p$(70)="on the south side of the mist in clearer air."
2132 LET p$(71)="heading along a good pathcut from living rock."
2134 LET p$(72)="in a sharply twisting    corridor."
2136 LET p$(73)="twisting and turning nearthe FLY room!"
2138 LET p$(74)="face to face with a giantfly blocking the path!"
2140 DATA 74,0,72,0,0,73,71,0,0,0,74,76,0,0,75,0
2142 LET p$(75)="in a low east-west tunneldevoid of insects!"
2144 LET p$(76)="in a complete dead end   and can go no further."
2146 DATA 52,78,0,0,77,79,0,0,78,0,0,0,0,83,0,79,0,82,0,79,0,81,0,0,0,80,84,0,0
2148 LET p$(77)="still heading north-south"
2149 GO TO 2151
2150 GO TO 3200
2151 LET p$(78)="at the bottom of a long  low north-south path.."
2152 LET p$(79)="halted by an old seized  up mining track."
2154 LET p$(80)="weaving around old and   dusty cobwebs."
2156 LET p$(81)="on the west side of the  track."
2158 LET p$(82)="in what was once known asthe salvage room."
2160 LET p$(83)="near to the SPIDER room!"
2162 LET p$(84)="in spider-land.The huge  spider here halts you!"
2164 LET p$(85)="in an old chamber known  as spider's grave!"
2166 LET p$(86)="near to the SPIDER room!"
2168 LET p$(87)="in a total dead end. Yourroute ends here."
2169 DATA 83,0,0,0,0,0,84,0,0,87,0,84,86,0,0,0
2170 DATA 89,90,92,54,0,88,91,0,88,94,0,0,0,92,93,89,91,0,97,88,0,97,0,91
2172 LET p$(88)="in the heart of the magiccaverns."
2173 LET p$(89)="in a northern offshoot   from the main path."
2174 LET p$(90)="walking along a magical  corridor."
2176 LET p$(91)="in a dimly lit tunnel."
2178 LET p$(92)="near to the source of themagic."
2180 LET p$(93)="halted by a magical shi-mmering curtain."
2182 DATA 90,0,0,0,0,93,96,0,98,95,93,0,0,92,0,0,0,96,0,96,0,0,53,0,0,0
2184 LET p$(94)="in no-mans land.The path ends here."
2186 LET p$(95)="on the northern side of  the shimmering curtain."
2188 LET p$(96)="in a low corridor."
2189 LET p$(97)="treading over dimly lit  rocks and rubble."
2190 LET p$(98)="in a dead end.  The wall is bricked up here."
2191 LET p$(99)="in a northern offshoot   from the main path."
2192 LET p$(100)="in an old warehouse once used to store tools."
2200 FOR i=1 TO z:\
     FOR j=1 TO 4:\
     READ p(i,j):\
     NEXT j:\
     NEXT i
2210 DATA 15,20,21,34,24,0,40,0,27,7,42,46,0,14,93,67,79,48,98,69
2212 DATA "vast chasm","a staff","a tree","an axe","a rope"
2214 DATA "a bridge","dynamite","rubble","a bear"
2216 DATA "a bun","a panther","a plank","a ladder","some nails"
2218 DATA "a curtain","a mirror","a track"
2220 DATA "some oil","a bottle","misty wall"
2222 FOR i=1 TO 20:\
     READ o(i):\
     NEXT i:\
     FOR i=1 TO 20:\
     READ o$(i):\
     NEXT i
2224 DATA 50,84,74,60,76,87,3,53,63,31,73,0,0,100,0,3,1,0,0,39,0,0,0,0,0
2226 DATA "the ghost!","a spider!"
2228 DATA "a fly!","a door","a mortar","fly spray"
2230 DATA "a gate","a crack","a stone","a sword","whisky!"
2232 DATA "a gargoyle","an knife","a key","a wall","matches","a torch"
2234 DATA "lit torch","a light","parchment","program"
2236 DATA "glass"
2238 DATA "oil bottle","whisky jar","timber"
2239 FOR i=29 TO lo:\
     READ o(i):\
     NEXT i
2240 FOR i=29 TO lo:\
     READ o$(i):\
     NEXT i
2250 DATA "cha","sta","tre","axe","rop","bri","dyn","rub","bea","bun","pan","pla","lad","nai","cur","mir","tra"
2252 DATA "oil","bot","mis","nor","sou","eas","wes","n","s","e","w","gho","spi","fly","doo","mor","spr","gat","cra"
2254 DATA "sto","swo","whi","gar","kni","key","wal","mat","tor","tor","lig","par","pro","gla","bot","bot","tim"
2256 DATA "go","get","loo","inv","sco","dro","hel","qui","cro","tak","ope","clo","eat","fee","dri","off","wav"
2258 DATA "cut","cho","cli","lig","att","kil","hit","mak","ref","oil","sta","spr","thr","rub","rea","exa","jum"
2260 DATA "bre","pus","sav","loa"
2262 FOR i=1 TO nn:\
     READ j$(i):\
     NEXT i
2264 FOR i=1 TO nv:\
     READ v$(i):\
     NEXT i
2266 DATA "north","south","east","west"
2268 FOR i=1 TO 4:\
     READ t$(i):\
     NEXT i
2270 RETURN
2510 CLS :\
     PRINT "And now you can leave the caves!":\
     PRINT :\
     PRINT "Congratulations!":\
     PRINT :\
     PRINT "And have a safe journey home!"
2512 GO TO 614
3000 CLS :\
     PRINT "Insert cassette in tape unit,   and tap the space bar when ready"
3001 IF INKEY$="" THEN GO TO 3001
3002 IF INKEY$<>"" THEN GO TO 3002
3003 LET x(1)=cp:\
     LET x(2)=tb:\
     LET x(3)=gf:\
     LET x(4)=pd:\
     LET x(5)=zz:\
     LET x(6)=sc:\
     LET x(7)=df:\
     LET x(8)=br:\
     LET x(9)=np
3004 PRINT "OK."
3006 SAVE "Data-1" DATA p$():\
     GO SUB 6900
3007 SAVE "Data-2" DATA p():\
     GO SUB 6900
3008 SAVE "Data-3" DATA o$():\
     GO TO 6900
3009 SAVE "Data-4" DATA o():\
     GO SUB 6900
3010 SAVE "Data-5" DATA x()
3026 GO TO 614
3200 CLS :\
     PRINT "Insert cassette in tape unit,   and tap the space bar when ready"
3201 IF INKEY$="" THEN GO TO 3201
3202 IF INKEY$<>"" THEN GO TO 3202
3204 PRINT "OK."
3206 LOAD "Data-1" DATA p$()
3207 LOAD "Data-2" DATA p()
3208 LOAD "Data-3" DATA o$()
3209 LOAD "Data-4" DATA o()
3210 LOAD "Data-5" DATA x()
3212 LET cp=x(1):\
     LET tb=x(2):\
     LET gf=x(3):\
     LET pd=x(4):\
     LET zz=x(5):\
     LET sc=x(6):\
     LET df=x(7):\
     LET br=x(8):\
     LET np=x(9)
3226 GO TO 200
5000 CLS
5001 PRINT "You're ";p$(cp):\
     LET pd=0
5003 IF cp=42 AND tb=1 AND p(42,2)=0 THEN GO TO 6054
5004 LET z$="You can see:                    "
5005 PRINT :\
     PRINT
5006 FOR i=1 TO lo:\
     IF o(i)=cp THEN PRINT z$;o$(i):\
     LET z$=""
5008 NEXT i
5009 IF cp=3 AND gf=0 THEN PRINT g$
5010 LET fl=0
5011 PRINT
5012 PRINT :\
     PRINT "You can go:":\
     FOR i=1 TO 4:\
     IF p(cp,i)<>0 THEN PRINT t$(i);" ";:\
     LET fl=1
5013 NEXT i
5014 IF fl=0 THEN PRINT "Nowhere."
5015 IF np=1 THEN GO TO 6000
5016 IF (cp>20 AND cp<88) AND (INT (RND*100>96)) THEN LET np=1:\
     GO TO 6000
5018 IF cp<>69 THEN RETURN
5020 IF p(69,4)=70 THEN RETURN
5022 IF o(19)<>-1 THEN PRINT "You can't pass yet.":\
     RETURN
5024 PRINT :\
     PRINT "The shimmering curtain washes  away the mist and reveals a new tunnel."
5025 LET p(69,4)=70:\
     LET o(15)=0:\
     LET zz=zz-1:\
     LET p$(69)="walking past an ice cold spot."
5026 LET o(20)=0:\
     RETURN
5200 CLS :\
     PRINT "Oh dear, the gate to the caves  appears to have slam shut!"
5202 PRINT :\
     PRINT "That's torn it. You'll have to find the key now before you can get out."
5204 PRINT :\
     PRINT "But don't worry.  It's in here  somewhere."
5205 LET p(3,1)=0
5206 LET gf=0:\
     GO TO 210
5300 IF no=45 AND o(46)=-1 THEN LET no=46:\
     RETURN
5302 IF no=19 AND o(51)=-1 THEN LET no=51:\
     RETURN
5304 IF no=19 AND o(52)=-1 THEN LET no=52:\
     RETURN
5306 IF no=18 AND o(51)=-1 THEN LET no=51:\
     RETURN
5308 IF no=39 AND o(52)=-1 THEN LET no=52:\
     RETURN
5310 RETURN
6000 PRINT :\
     PRINT "There's a hostile gargoyle peer-ing at you from the shadows!"
6001 IF INT (RND*100)>98 THEN GO TO 6020
6002 PRINT "He has a knife!  He throws it atyou!":\
     LET o(40)=cp
6004 IF INT (RND*100)>98 THEN PRINT "He's killed you!":\
     GO TO 612
6006 PRINT "It missed!":\
     RETURN
6010 IF INT (RND*11)>1 THEN PRINT "You've killed a gargoyle!":\
     LET o(40)=0:\
     GO TO 6014
6011 PRINT "You missed him!":\
     LET o(40)=cp
6012 LET o(4)=cp:\
     LET zz=zz-1
6013 FOR i=1 TO 50:\
     NEXT i:\
     GO TO 200
6014 LET np=0:\
     GO TO 6012
6020 PRINT "He appears from the shadows and steals:":\
     LET gs=0
6022 IF o(2)=-1 THEN LET o(2)=63:\
     PRINT o$(2):\
     LET gs=gs+1
6024 IF o(7)=-1 THEN LET o(7)=63:\
     PRINT o$(7):\
     LET gs=gs+1
6026 IF o(14)=-1 THEN LET o(14)=63:\
     PRINT o$(14):\
     LET gs=gs+1
6028 IF o(16)=-1 THEN LET o(16)=63:\
     PRINT o$(16):\
     LET gs=gs+1
6030 IF o(19)=-1 THEN LET o(19)=63:\
     PRINT o$(19):\
     LET gs=gs+1
6031 IF o(33)=-1 THEN LET o(33)=63:\
     PRINT o$(33):\
     LET gs=gs+1
6032 IF o(34)=-1 THEN LET o(34)=63:\
     PRINT o$(34):\
     LET gs=gs+1
6034 IF o(38)=-1 THEN LET o(38)=63:\
     PRINT o$(38):\
     LET gs=gs+1
6036 IF o(44)=-1 THEN LET o(44)=63:\
     PRINT o$(44):\
     LET gs=gs+1
6038 IF gs=0 THEN PRINT "Nothing!  You were lucky!"
6040 RETURN
6054 PRINT "The panther flees at the sight  of the bear!":\
     LET p(42,2)=43:\
     LET o(11)=0
6055 LET p$(42)="walking past the scent ofold panther":\
     GO TO 5004
6300 LET oc=0:\
     FOR i=1 TO lo:\
     IF o(i)=-1 THEN LET oc=oc+1
6302 NEXT i
6304 IF oc>1 THEN PRINT "Something won't fit through.":\
     GO TO 210
6306 IF o(37)<>-1 THEN PRINT "Sorry.  You can't fit through.":\
     GO TO 210
6308 LET cp=100:\
     PRINT "The stone glows with a shiny    light and lets you through."
6310 GO TO 210
6800 BEEP 1,0:\
     BEEP 1,2:\
     BEEP .5,3:\
     BEEP .5,2:\
     BEEP 1,0
6801 BEEP 1,0:\
     BEEP 1,2:\
     BEEP .5,3:\
     BEEP .5,2:\
     BEEP 1,0
6802 BEEP 1,3:\
     BEEP 1,5:\
     BEEP 2,7
6803 BEEP 1,3:\
     BEEP 1,5:\
     BEEP 2,7
6804 BEEP .75,7:\
     BEEP .25,8:\
     BEEP .5,7:\
     BEEP .5,5:\
     BEEP .5,3:\
     BEEP .5,2:\
     BEEP 1,0
6805 BEEP .75,7:\
     BEEP .25,8:\
     BEEP .5,7:\
     BEEP .5,5:\
     BEEP .5,3:\
     BEEP .5,2:\
     BEEP 1,0
6806 BEEP 1,0:\
     BEEP 1,-5:\
     BEEP 2,0
6807 BEEP 1,0:\
     BEEP 1,-5:\
     BEEP 2,0
6808 RETURN
6900 PRINT "Stop the tape but do NOT rewind it yet.":\
     PRINT :\
     PRINT "Press space bar when ready to   continue."
6902 IF INKEY$="" THEN GO TO 6902
6903 IF INKEY$<>"" THEN GO TO 6903
6904 RETURN
8000 INPUT LINE m$
8002 RETURN
9000 CLS :\
     FOR i=1 TO 88:\
     PRINT "DUCKSOFT";:\
     NEXT i:\
     FLASH 1:\
     PRINT AT 11,9;" HELLO THERE! ":\
     FLASH 0:\
     FOR i=1 TO 250:\
     NEXT i
9002 PAPER 6:\
     INK 0:\
     BORDER 1:\
     CLS
9004 PRINT "Welcome to Underground Adventure":\
     PRINT :\
     PRINT "Here you are,miles away from    home, trying to decide how to   spend you afternoons."
9006 PRINT :\
     PRINT "Do you look for peace and       solitude, or do you look  for   danger and adventure?"
9008 PRINT :\
     PRINT "Of course,you decide to look foradventure!  Life's too short!":\
     GO SUB 9500
9010 CLS :\
     PRINT "You are on a dusty old beaten   track, heading south towards    some caves hidden deep in the   hillside away in the distance."
9012 PRINT :\
     PRINT "It is rumoured that the caves   are dangerous.  Pah! you say,   and quite right to."
9014 PRINT :\
     PRINT "Who knows what is to be found   inside them?  You decide to go  and have a look."
9016 PRINT :\
     GO SUB 9500
9018 PRINT :\
     PRINT "OK, just setting it all up for  you.  Hang on!"
9020 RETURN
9500 PRINT :\
     PRINT "Press space bar to continue."
9501 IF INKEY$="" THEN GO TO 9501
9502 IF INKEY$<>" " THEN GO TO 9501
9504 RETURN
