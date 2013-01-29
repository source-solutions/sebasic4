   5 REM CREATIVE COMPUTING 1978 adapted
  10 RESTORE
  30 LET c$="": LET p$="": DIM u(43): DIM v(43): DIM w(43)
  70 LET n1=43: LET n2=16: LET n3=121
  80 RESTORE 2200
  90 FOR x=1 TO n1: READ u(x): READ l1: LET v(x)=u(x): LET w(x)=u(x)+l1-1: NEXT x
 120 LET x$="Hi,I'm Eliza,whats your problem?"
 130 GO SUB 2240
 150 INPUT LINE a$
 152 LET flag=0
 155 IF a$="" THEN LET x$="Well,say something!!!": GO SUB 2240: GO TO 150
 157 LET x$="/"+a$: LET a$=" "+a$+"  ": GO SUB 9000
 160 IF a$="shut up" THEN LET x$="There is no need to be rude!!": GO SUB 2240: STOP
 250 LET i$=a$
 260 GO SUB 2140
 350 RESTORE
 360 LET s=0
 370 FOR k=1 TO n1
 380 READ k$
 390 IF s>0 THEN GO TO 430
 400 FOR l=1 TO LEN i$-LEN k$
 410 IF i$(l TO l+LEN k$-1)=k$ THEN LET s=k: LET t=l: LET f$=k$
 420 NEXT l
 430 NEXT k
 440 IF s>0 THEN LET k=s: LET l=t: GO TO 470
 450 LET k=n1: GO TO 3000
 500 RESTORE 900
 510 LET c$=" "+i$(l+LEN f$ TO )
 520 FOR x=1 TO n2/2
 530 READ s$,r$
 540 FOR l=1 TO LEN c$
 550 IF l+LEN s$>LEN c$ THEN GO TO 600
 560 IF c$(l TO l+LEN s$-1)<>s$ THEN GO TO 600
 570 LET c$=c$( TO l-1)+r$+c$(l+LEN s$ TO )
 580 LET l=l+LEN r$
 590 GO TO 640
 600 IF l+LEN r$>LEN c$ THEN GO TO 640
 610 IF c$(l TO l+LEN r$-1)<>r$ THEN GO TO 640
 620 LET c$=c$( TO l-1)+s$+c$(l+LEN r$ TO )
 630 LET l=l+LEN s$
 640 NEXT l
 650 NEXT x
 655 IF LEN c$<2 THEN GO TO 670
 660 IF c$(1)=" " THEN LET c$=c$(2 TO )
 700 RESTORE 940+10*v(k)
 710 READ f$
 720 LET v(k)=v(k)+1: IF v(k)>w(k) THEN LET v(k)=u(k)
 730 IF f$(LEN f$)="*" THEN GO TO 740
 732 LET x$=f$
 734 IF flag=0 AND k<>20 AND (k<20 OR k=21 OR k=31 OR k=32 OR k=33 OR k=36 OR k>40) AND k<>n1 THEN LET p$=p$+CHR$ 201+i$
 736 GO TO 130
 740 IF c$="" THEN GO TO 746
 741 IF c$(LEN c$)=" " THEN LET c$=c$( TO LEN c$-1): GO TO 741
 742 IF c$(1)=" " THEN LET c$=c$(2 TO ): GO TO 742
 746 LET x$=f$( TO LEN f$-1)+" "+c$
 747 IF x$(1)="?" THEN LET x$=x$(2 TO )+"?"
 748 GO SUB 2240
 750 IF flag=0 AND k<>20 AND (k<20 OR k=21 OR k=31 OR k=32 OR k=33 OR k=36 OR k>40) AND k<>n1 THEN LET p$=p$+CHR$ 201+i$
 755 GO TO 150
 800 DATA " sex"," bloody "," damn "," hell "," shit "," fucked "," fuck ","can you","can i","you are","your","i dont","i feel"
 820 DATA "why dont you","why cant i","are you","i cant","i am","im"
 830 DATA " you ","i want","what","how","who","where","when","why"
 840 DATA "name","cause","sorry","dream","hello","hi ","maybe"
 850 DATA " no","your","always","think","alike","yes","friend","computer","nokeyfound"
 900 DATA " are "," am "," were "," was "," you "," i "," your "," my "," ive "," youve "," im "," youre "," me "," me "," you "," yourself "," myself "
 950 DATA "?Dont you believe I can*"
 960 DATA "?Perhaps you would like to be able to*"
 970 DATA "?You want me to be able to*"
 980 DATA "?Perhaps you dont want to*"
 990 DATA "?Do you want to be able to*"
1000 DATA "?What makes you think I am*"
1010 DATA "?Does it please you to believe I am*"
1020 DATA "?Perhaps you would like to be*"
1030 DATA "?Perhaps you sometimes wish you were*"
1040 DATA "?Dont you really*"
1050 DATA "?Why dont you*"
1060 DATA "?Maybe you wish to be able to*"
1070 DATA "Does that trouble you?"
1080 DATA "Tell me more about your feelings"
1090 DATA "?Do you often feel*"
1100 DATA "?Do you enjoy feeling*"
1110 DATA "?Do you really believe I dont*"
1120 DATA "Perhaps in good time I will*"
1130 DATA "?Perhaps you want me to*"
1140 DATA "?Maybe you think you should be able to*"
1150 DATA "?Why cant you*"
1160 DATA "?Why are you interested in whether or not I am*"
1170 DATA "?Would you prefer it if I were not*"
1180 DATA "?Perhaps in your fantasies I am*"
1190 DATA "?How do you know you cant*"
1200 DATA "?Have you tried*"
1210 DATA "Perhaps you can now*"
1220 DATA "?Did you come to me because you are*"
1230 DATA "?How long have you been*"
1240 DATA "?Do you believe it is normal to be*"
1250 DATA "?Do you enjoy being*"
1260 DATA "We were discussing you,not me"
1270 DATA "Oh,I*"
1280 DATA "Your not really talking about me,are you?"
1290 DATA "?What would it mean to you if you got*"
1300 DATA "?Why do you want*"
1310 DATA "?Suppose you soon got*"
1320 DATA "?What if you never got*"
1330 DATA "I sometimes also want*"
1340 DATA "Why do you ask?"
1350 DATA "Does that question interest you?"
1360 DATA "What answer would please you the most?"
1370 DATA "What do you think?"
1380 DATA "Are such questions on your mind often?"
1390 DATA "What is it that you really want to know?"
1400 DATA "Have you asked such questions before?"
1410 DATA "Have you asked anyone else?"
1420 DATA "What else comes to mind when you ask that?"
1430 DATA "Names dont interest me"
1440 DATA "I dont care about names--please go on"
1450 DATA "Is that the real reason?"
1460 DATA "Dont any other reasons come to mind?"
1470 DATA "Does that reason explain anything else?"
1480 DATA "What other reasons might there be?"
1490 DATA "Please dont apologise"
1500 DATA "Apologies are not necessary"
1510 DATA "What feelings do you have when you apologise?"
1520 DATA "Dont be so defensive"
1530 DATA "What does that dream suggest to you?"
1540 DATA "Tell me more about your dream"
1550 DATA "What persons appear in your dreams?"
1560 DATA "Are you disturbed by your dreams?"
1570 DATA "How do you do--please state your problem"
1580 DATA "You dont seem to be very certain"
1590 DATA "Why the uncertain tonr?"
1600 DATA "Can you be more positive?"
1610 DATA "Arent you sure?"
1620 DATA "Dont you know?"
1630 DATA "Are you saying no just to be negative?"
1640 DATA "You are being a bit negative"
1650 DATA "Why not?"
1660 DATA "Why are you so sure?"
1670 DATA "Why no?"
1680 DATA "?Why are you concerned about my*"
1690 DATA "?What about your own*"
1700 DATA "Can you think of a specific example?"
1710 DATA "When?"
1720 DATA "What are you thinking of?"
1730 DATA "Really,always?"
1740 DATA "Do you really think so?"
1750 DATA "But you are not sure you*"
1760 DATA "?Do you doubt you*"
1770 DATA "In what way?"
1780 DATA "What resemblance do you see?"
1790 DATA "What does the similarity suggest to you?"
1800 DATA "What other connections do you see?"
1810 DATA "Could there really be some connection?"
1820 DATA "How?"
1830 DATA "You seem quite positive"
1840 DATA "Why are you so sure?"
1850 DATA "I see"
1860 DATA "I understand"
1870 DATA "Why do you bring up the topic of friends?"
1880 DATA "Perhaps your friends worry you?"
1890 DATA "Maybe your friends pick on you?"
1900 DATA "What sort of friends do you have?"
1910 DATA "Do you impose on your friends?"
1920 DATA "Perhaps your love for friends worries you?"
1930 DATA "Maybe computers worry you?"
1940 DATA "Are you talking about me in particular?"
1950 DATA "Are you frightened by machines?"
1960 DATA "Why do you mention computers?"
1970 DATA "What do you think machines have to do with your problem?"
1980 DATA "Dont you think computers can help people?"
1990 DATA "What is it about machines that worries you?"
2000 DATA "Say,do you have any psychological problems?"
2010 DATA "What does that suggest to you?"
2020 DATA "I see"
2030 DATA "I am not sure I understand you fully"
2040 DATA "Come,come,elucidate your thoughts!"
2050 DATA "Can you elaborate on that?"
2060 DATA "That is quite interesting"
2070 DATA "Why do you mention sex?"
2080 DATA "Is your sex life satisfactory?"
2090 DATA "Do you feel like sex at the moment?"
2100 DATA "Please dont swear,there is a lady present(me!!!)"
2110 DATA "There is no need to swear!"
2120 DATA "swearing will not help anybody"
2130 DATA "Please dont BLOODY WELL SWEAR!!!"
2140 DATA "There is no need to be obscene"
2150 DATA "Dont be so disgusting!!!"
2200 DATA 113,3,116,4,116,4,116,4,116,4,120,2,120,2,1,3,4,2,6,4,6,4,10,4,14,3,17,3,20,2,22,3,25,3,28
2210 DATA 4,28,4,32,3,35,5,40,9,40,9,40,9,40,9,40,9,40,9,49
2220 DATA 2,51,4,55,4,59,4,63,1,63,1,64,5,69,5,74,2,76,4,80
2230 DATA 3,83,7,90,3,93,6,99,7,106,6
2240 LET flag1=0: IF x$(1)="/" THEN LET flag1=1: LET x$=x$(2 TO )
2320 POKE 23692,255: PRINT AT 21,31;"  "
2330 PRINT INVERSE flag1;AT 21,0;x$
2340 RETURN
3000 IF p$="" THEN GO TO 700
3005 LET pos=LEN p$
3010 IF p$(pos)<>CHR$ 201 THEN LET pos=pos-1: GO TO 3010
3020 LET i$=p$(pos+1 TO )
3030 LET p$=p$( TO pos-1)
3040 LET flag=1: GO TO 350
4000 IF x$(1)=" " THEN LET x$=x$(2 TO ): GO TO 4000
4010 IF x$(LEN x$)=" " THEN LET x$=x$( TO LEN x$-1): GO TO 4010
4020 FOR p=1 TO LEN x$-2
4030 IF x$(p TO p+2)=" i " THEN LET x$(p TO p+2)=" I "
4035 IF p+3>LEN x$ THEN GO TO 4050
4040 IF x$(p TO p+3)=" im " THEN LET x$(p TO p+3)=" Im "
4050 NEXT p
4060 RETURN
9000 FOR p=1 TO LEN a$
9005 IF p>LEN a$ THEN GO TO 9017
9010 IF (a$(p)<"A" AND a$(p)>" ") OR (a$(p)>"Z" AND a$(p)<"a") OR a$(p)>"z" THEN LET a$=a$( TO p-1)+a$(p+1 TO ): LET p=p-1
9015 NEXT p
9017 FOR p=1 TO LEN a$
9020 IF a$(p)<"a" AND a$(p)<>" " THEN LET a$(p)=CHR$ (CODE a$(p)+32)
9025 NEXT p
9030 RETURN
