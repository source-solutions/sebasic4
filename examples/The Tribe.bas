Auto 1

# Run-time Variables

Var a: Num = 0
Var ye: Num = 1
Var st: Num = 50
Var cash: Num = 0
Var rs: Num = 0
Var ls: Num = 0
Var ls1: Num = 0
Var ic: Num = 0
Var z: NumArray(30) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var a: NumArray(4) = 20, 0, 0, 0
Var b: NumArray(4) = 0, 0, 0, 0
Var c: NumArray(4) = 0, 0, 0, 0
Var s: NumArray(3) = 1, 0, 1
Var f: NumFOR = 149, 148, 1, 9600, 3
Var g: NumFOR = 8, 7, 1, 9600, 4

# End Run-time Variables

   1 REM Tribe 4
   2 REM \* S.Robert Speel 1984
   5 POKE 23609,40
  10 CLS :\
     GO SUB 9000
 100 PRINT AT 2,10;"THE TRIBE"''
 110 PRINT " You have been elected Chief of a small tribe. You must make thetribe prosper and become wealthywithin 25 years.If  you do not  please the people, the will     dispose of you."
 120 GO SUB 7500
1000 INK 7:\
     PAPER 0:\
     BORDER 0:\
     CLS
1010 INK 1:\
     PAPER 5:\
     PRINT BRIGHT 1; PAPER 6;"SITUATION REPORT: Start Year ";ye;TAB 32
1020 LET ls2=ls1:\
     LET ls1=ls
1030 FOR f=1 TO 4:\
     LET c(f)=b(f):\
     LET b(f)=a(f):\
     NEXT f
1050 PRINT AT 2,3;"Workers:";TAB 15;AT 3,3;TAB 15
1060 DATA "Hunters","Gatherers","Fishers","Farmers"
1070 RESTORE 1060:\
     FOR f=1 TO 4:\
     READ b$:\
     PRINT PAPER 0;TAB 3; PAPER 5;b$;TAB 13;a(f);TAB 15:\
     NEXT f
1080 PRINT AT 2,20; PAPER 5;"Treasury   ";AT 3,20;TAB 31;AT 3,25;cash
1100 PRINT AT 9,3; PAPER 5;"Retirements "':\
     IF ye=1 THEN LET c=0:\
     GO TO 1120
1110 LET c=0:\
     RESTORE 1060:\
     FOR f=1 TO 4:\
     READ b$:\
     LET a=RND:\
     IF a<a(f)/30 THEN LET b=INT (RND*a(f)/(4-3*(a(f)<5)))+1:\
     LET b=b-(b>4)*(b-4)-(b>a(f))*(a(f)-b):\
     PRINT PAPER 0;TAB 3; PAPER 5;b;" ";b$( TO LEN b$-(b=1));TAB 15:\
     LET a(f)=a(f)-b:\
     LET c=1
1120 NEXT f
1130 IF NOT c THEN PRINT PAPER 5;AT 10,3;"****NONE****"
1140 PRINT AT 5,20; PAPER 5;"Food stored";AT 6,20;TAB 31;AT 6,25;st
1150 PRINT AT 8,20; PAPER 5;"Your hoard ";AT 9,20;TAB 31;AT 9,25;rs
1200 LET tp=0:\
     FOR f=1 TO 4:\
     LET tp=tp+a(f):\
     NEXT f
1210 LET np=INT (RND*tp/9)+2
1220 PRINT AT 15,2;"Recruits needing work: ";np;" "
1230 LET tp=tp+np
1300 RESTORE 1060:\
     FOR f=1 TO 4:\
     READ b$
1310 INPUT ("new ";b$;"? ");a:\
     LET a=INT ABS a:\
     IF a>np THEN BEEP 1,0:\
     BEEP 1,0:\
     BEEP 1,0:\
     GO TO 1310
1320 LET np=np-a:\
     LET a(f)=a(f)+a:\
     PRINT AT f+3,13;a(f);TAB 15;AT 15,25;np:\
     IF np>0 THEN NEXT f
1330 IF np THEN GO TO 1300
1340 PRINT AT 15,2; FLASH 1;"ALL RECRUITS PLACED"; FLASH 0; PAPER 0;TAB 30
1350 GO SUB 7500
3000 PAPER 2:\
     CLS :\
     INK 1:\
     PAPER 6
3010 PRINT AT 1,3;"AFTER THE HARVEST"
3020 PRINT AT 3,5;"Weather: ";
3030 LET we=INT (RND*4)+1
3040 IF RND<.1 THEN LET w=5:\
     BEEP .5,15:\
     BEEP .5,10
3050 DATA "Warm & dry","Warm & wet","Cold & dry","Cold & wet","Drought"
3060 RESTORE 3050:\
     FOR f=1 TO we:\
     READ b$:\
     NEXT f:\
     PRINT b$;" "
3100 PRINT AT 5,2;"Food received";AT 6,2;"from workers:";AT 7,2;TAB 15
3200 DATA "2514030203","4624242314","0236022400","3647130201"
3210 LET ha=0:\
     FOR f=1 TO 4:\
     IF a(f)=0 THEN GO TO 3250
3220 RESTORE 1060:\
     FOR g=1 TO f:\
     READ b$:\
     NEXT g:\
     PRINT PAPER 2;TAB 2; PAPER 6;b$;TAB 12;
3230 RESTORE 3200:\
     FOR g=1 TO f:\
     READ b$:\
     NEXT g:\
     LET a=0:\
     FOR g=1 TO a(f):\
     LET a=a+INT (RND*(VAL b$(we*2)-VAL b$(we*2-1)))+VAL b$(we*2-1):\
     NEXT g
3240 PRINT a;TAB 15;TAB 15:\
     LET ha=ha+a
3250 NEXT f
3300 PRINT AT 15,2;"Total harvest....";ha;" "
3310 LET st=st+ha
3320 PRINT ' PAPER 2;TAB 2; PAPER 6;"Total food available: ";st;" ";''
3330 PRINT AT 5,23;"Total   ";AT 6,23;"workers ";AT 7,23;TAB 26;tp;TAB 31
3340 PRINT AT 9,23;"Treasury";AT 10,23;"  ";cash;TAB 31
3500 INPUT "How much food for the workers? ";a:\
     GO SUB 4200
3510 LET s(1)=INT (a/tp)
3520 LET sp=INT (RND*4)+1+ic:\
     INPUT "Selling price for food  is"',(sp);" ingots/sack"'"How many sacks food sold? ";a
3530 GO SUB 4200
3540 LET cash=cash+a*sp
3550 PRINT AT 10,25;cash;TAB 31
3560 PRINT AT 21,0;"Would you like a poll? (y/n) ":\
     LET a$=INKEY$:\
     IF a$<>"y" AND a$<>"n" THEN GO TO 3560
3570 PRINT AT 21,0;TAB 31:\
     IF a$="y" THEN GO TO 7600
3580 GO SUB 7500
4000 PAPER 6:\
     INK 1:\
     CLS :\
     PAPER 7
4010 PRINT AT 1,2;"DEVELOPMENTS"
4020 PRINT AT 3,2;"Treasury";AT 4,2;"  ";cash;TAB 10;AT 3,20;"Your hoard";AT 4,20;"   ";rs;TAB 0
4030 LET b=(s(2)+2+INT (RND*3))*tp:\
     PRINT AT 6,2;"Hiring builders to improve";AT 7,2;"the  people's housing would";AT 8,2;"cost ";b;" ingots."
4040 PRINT AT 21,0;"Do you hire builders? (y/n) ":\
     LET a$=INKEY$:\
     IF a$<>"y" AND a$<>"n" THEN GO TO 4040
4050 PRINT AT 21,0; PAPER 6;TAB 31:\
     IF a$="n" THEN GO TO 4100
4060 PRINT AT 10,2;"You hire builders.":\
     IF cash<b THEN PRINT AT 10,2;"The builders, finding that";AT 11,2;"you cannot pay them, smash";AT 12,2;"up all existing houses!   ":\
     LET s(2)=0:\
     GO TO 4100
4070 LET s(2)=s(2)+1:\
     LET cash=cash-b
4080 PRINT AT 12,2;"New building standard: ";s(2);" "
4090 LET a=0:\
     GO SUB 4250
4100 IF ye>4 AND RND<.1 AND ic<4 THEN BEEP .5,15:\
     BEEP .5,10:\
     PRINT AT 16,2; FLASH 1;"BONUS";:\
     PRINT " food prices increase!":\
     LET ic=ic+1
4110 GO TO 4300
4200 IF a>st THEN LET a=st
4210 LET st=st-a
4220 PRINT AT 17,24;st;TAB 28
4230 RETURN
4250 IF a>cash THEN LET a=cash
4260 LET cash=cash-a
4270 PRINT AT 4,4; FLASH (cash<0);cash; FLASH 0;TAB 10;AT 4,23;rs;TAB 30
4280 RETURN
4300 GO SUB 7500:\
     INK 7:\
     PAPER 5:\
     CLS :\
     PAPER 1:\
     PRINT AT 1,12;"WAGES"
4310 PRINT AT 3,2;"Treasury";AT 4,2;"  ";cash;TAB 10;AT 3,20;"Yout hoard";AT 4,20;"   ";rs;TAB 30
4320 LET wi=0:\
     IF RND<.1 THEN LET wi=1+INT (RND*3):\
     BEEP .5,15:\
     BEEP .5,10:\
     PRINT AT 6,2;"The workers demand that   ";AT 7,2;"their wages be increased. "
4330 PRINT AT 8,2;"Wages currently cost ";s(3)*tp;TAB 28
4340 PRINT AT 9,2;"A wage increase would make";AT 10,2;"this ";tp*(s(3)+1);TAB 28
4350 PRINT AT 20,0; INK 0; PAPER 4;"Do you 1)Increase, 2)decrease or3)not change  the wages?";TAB 32:\
     LET a$=INKEY$:\
     IF a$<"1" OR a$>"3" THEN GO TO 4350
4360 PRINT AT 20,0; PAPER 5;TAB 31;" ";TAB 31;" "
4370 LET a=VAL a$:\
     PRINT AT 12,4;"Wages ";("Increased" AND a=1);("decreased" AND a=2);("unchanged" AND a=3)
4380 LET s(3)=s(3)+(a=1)-(a=2)
4390 LET cash=cash-s(3)*tp
4400 GO SUB 4270
4410 LET a=10-(cash<-189)*(-189-cash):\
     IF a<1 THEN LET a=0
4420 LET cash=cash-a
4430 PRINT AT 14,2;"You take your tithe.":\
     LET rs=rs+a:\
     GO SUB 4270
4440 LET di=0:\
     IF cash<1 THEN GO TO 4500
4450 INPUT "How much of the treasury do you divert to your own funds? ";a:\
     IF a>cash THEN LET a=cash
4460 IF a THEN LET cash=cash-a:\
     LET rs=rs+a:\
     IF a>(cash+a)/5 AND RND<.5 THEN LET di=2
4470 GO SUB 4270
4500 LET ls=0:\
     FOR f=1 TO 3:\
     LET ls=ls+s(f):\
     NEXT f:\
     LET z(ye)=ls
4510 IF cash>-200 THEN GO TO 4600
4520 PRINT AT 16,2;"The treasury owes too much";AT 17,2;"money to continue, and you";AT 18,2;"are thrown out of office!":\
     GO TO 7300
4600 LET us=100:\
     FOR f=1 TO 4:\
     IF NOT a(f) THEN GO TO 4620
4610 LET us=us-INT (a(f)/tp*100*((b(f)>a(f))+(c(f)>b(f))*.75+(b(f)=a(f))*.2))
4620 NEXT f:\
     LET sb=0
4630 IF us>55 THEN GO TO 5000
4640 PRINT AT 16,2;"The guild fathers say that";AT 17,2;"they will force an election."
4650 PRINT AT 21,0;"Do you try to bribe them? (y/n) ":\
     LET a$=INKEY$:\
     IF a$<>"y" AND a$<>"n" THEN GO TO 4650
4660 PRINT AT 21,0;TAB 31:\
     IF a$<>"y" THEN GO TO 5000
4670 INPUT "How much? ";a:\
     IF a>rs THEN LET a=rs
4680 PRINT AT 18,2;"You bribe them.":\
     LET rs=rs-a:\
     LET us=us+INT (a*10/tp):\
     IF RND<.3 THEN LET sb=1
5000 GO SUB 7500
5010 INK 2:\
     PAPER 1:\
     CLS :\
     PAPER 7
5020 PRINT AT 1,2;"LIVING STANDARDS"
5030 DATA "food","housing","wages"
5040 LET a=1:\
     FOR f=1 TO 3:\
     IF s(f)>a THEN LET a=s(f)
5050 NEXT f
5060 RESTORE 5030:\
     FOR f=1 TO 3:\
     READ b$:\
     PRINT AT 3+f*2,5;b$;TAB 13;:\
     FOR g=1 TO s(f):\
     PRINT INK 0;CHR$ (143+f);:\
     NEXT g:\
     PRINT TAB 14+a;AT f*2+4,5;TAB 14+a:\
     NEXT f
6000 LET sat=(ls-ls1)*2+ls-ls2+s(3)-(s(1)=0)*50-wi-di+(ls-ye)/2
6010 LET sat=sat+(sat<-1)*(-1-sat)-(sat>3)*(sat-3)-sb
6020 IF us<0 THEN LET us=0
6100 PRINT AT 12,2;" Guild support = ";us;"%"
6110 DATA "rioting","annoyed","restless","satisfied","happy"
6120 RESTORE 6110:\
     FOR f=-1 TO sat:\
     READ b$:\
     NEXT f
6130 PRINT AT 14,2;"The people are ";b$
6140 IF sat<0 OR us<50 THEN GO TO 7000
6150 LET ye=ye+1
6160 GO SUB 7500
6170 IF (ye+1)/3=INT ((ye+1)/3) THEN GO SUB 8000
6180 GO TO 1000
7000 PRINT AT 16,2;"The ";("guild" AND us<50);("people" AND sat<0 AND us>=50);" force you to hold";TAB 30;AT 17,2;"an election!";TAB 30
7010 IF rs<50 THEN PRINT AT 18,2;"You do not have enough";TAB 30;AT 19,2;"ingots to fight an election.":\
     GO TO 7300
7020 PRINT AT 18,2;"You have to spend 50 ingots ";AT 19,2;"to stand."
7030 LET rs=rs-50:\
     GO SUB 7500
7040 LET vty=0:\
     LET vtn=0
7050 INK 1:\
     PAPER 4:\
     CLS :\
     PAPER 7:\
     PRINT INK 1;AT 1,5;"\.'\.'\.' ELECTION \'.\'.\'."
7060 PRINT AT 4,2;"PEOPLE   FOR YOU  AGAINST YOU"
7100 RESTORE 1060:\
     FOR f=1 TO 4:\
     READ b$:\
     IF a(f)=0 THEN GO TO 7190
7110 PRINT AT f*2+4,2;b$;TAB 13
7120 LET vt=50-40*(s(1)=0)-5*(s(2)=0)-25*(s(3)=0)+5*s(1)+5*s(2)+8*s(3)+20*(ls>ls1)+10*(ls1>ls2)-25*(ls<ls1)-5*(ls1<ls2)-5*(ls=ls1)-40*(a(f)<b(f))-30*(b(f)<c(f))-10*(a(f)=b(f))-5*(b(f)=c(f))+20*(a(f)>b(f))+10*(b(f)>c(f))
7130 LET vt=vt+(ls-ye*4/5)*4
7140 LET vo=0:\
     FOR g=1 TO a(f)
7150 LET vu=vt+INT (RND*10)-INT (RND*10)-wi*10
7160 LET vo=vo+(RND<vu/100):\
     PRINT AT f*2+4,13;vo;TAB 25;g-vo;TAB 30:\
     NEXT g
7170 LET vty=vty+vo:\
     LET vtn=vtn+a(f)-vo
7180 PRINT AT f*2+5,2;TAB 30
7190 NEXT f
7200 PRINT AT 15,2;"Total votes for you = ";vty;" "
7210 PRINT AT 17,2;"Total votes against you = ";vtn;" "
7220 IF vty>=vtn THEN PRINT AT 19,2;"You have been re-elected!.":\
     GO TO 6150
7300 PRINT AT 20,2;"You have been sacked.";TAB 30
7310 GO SUB 7500
7320 INK 1:\
     PAPER 5:\
     BORDER 2:\
     CLS
7330 PRINT AT 1,5; PAPER 6;"THE END OF YOUR REIGN"
7340 PRINT AT 4,2;"You were Ruler for ";ye;" years,"
7350 PRINT AT 6,2;"during which time you";TAB 30;AT 7,2;"ammased ";rs;" ingots.";TAB 30
7360 PRINT AT 10,10;"SCORE:";AT 12,2;"For time in power.......";50*ye:\
     LET po=50*ye
7370 PRINT AT 14,2;"For living standards....";:\
     LET a=0:\
     FOR f=1 TO 30:\
     LET a=a+z(f):\
     PRINT AT 14,26;a*2:\
     NEXT f:\
     LET po=po+a*2
7380 PRINT AT 16,2;"For population growth...";(tp-20)*5:\
     LET po=po+(tp-20)*5:\
     PRINT AT 18,2;"For your hoard..........";rs*2+(ye>24)*500:\
     LET po=po+rs*2+(ye>24)*500
7390 PRINT AT 20,6; BRIGHT 1;"TOTAL POINTS.....";po:\
     STOP
7500 BEEP .5,\{f0}-40:\
     PRINT AT 21,2; INK 2; PAPER 7;"Press "; FLASH 1;"ENTER"; FLASH 0;" to continue"
7510 IF INKEY$<CHR$ 1 THEN GO TO 7510
7520 RETURN
7600 INK 7:\
     PAPER 3:\
     BORDER 1:\
     CLS :\
     PAPER 2
7610 PRINT AT 1,7;"ELECTORAL POLL"
7620 LET a=INT (RND*11)+10
7630 PRINT AT 4,2;"Prices:";AT 6,2;"1) Quick poll.....";a;AT 7,2;"2) Large poll.....";a*2;AT 8,2;"3) In-depth poll..";a*3;" ingots"
7640 PRINT AT 3,20;"Your Hoard";AT 4,20;"   ";rs;TAB 30
7650 PRINT AT 21,2;"PRESS 1,2,3 or 0 for no poll"
7660 LET a$=INKEY$:\
     IF a$<"0" OR a$>"3" THEN GO TO 7660
7670 PRINT AT 21,0; PAPER 3;TAB 31;" ":\
     IF a$="0" THEN GO TO 4000
7680 FOR f=1 TO 3:\
     PRINT AT 5+f,2; PAPER 3;TAB 4+(VAL a$<>f)*27:\
     NEXT f
7690 IF rs<a*VAL a$ THEN PRINT AT 18,2; PAPER 0;"You cannot afford this poll!":\
     FOR f=1 TO 5:\
     BEEP .5,20:\
     NEXT f:\
     GO SUB 7500:\
     GO TO 4000
7700 LET rs=rs-a*VAL a$
7710 PRINT AT 4,23;rs;TAB 30
7720 LET vty=0:\
     LET vtn=0
7800 RESTORE 1060:\
     FOR f=1 TO 4:\
     READ b$:\
     IF a(f)=0 THEN GO TO 7890
7810 PRINT AT f*2+8,2;b$
7820 LET vt=50-40*(s(1)=0)-30*(s(2)=0)-5*(s(3)=0)+5*s(1)+5*s(2)+8*s(3)+20*(ls>ls1)+10*(ls1>ls2)-25*(ls<ls1)-5*(ls1<ls2)-5*(ls=ls1)-40*(a(f)<b(f))-30*(b(f)<c(f))-10*(a(f)=b(f))-5*(b(f)=c(f))+20*(a(f)>b(f))+10*(b(f)>c(f))
7830 LET vo=0:\
     FOR g=1 TO a(f)/(4-VAL a$)
7840 LET vu=vt+INT (RND*10)-INT (RND*10)-wi
7850 LET vo=vo+(RND<vu/100):\
     NEXT g:\
     LET vo=INT (vo*(4-VAL a$))
7860 LET vty=vty+vo
7870 LET vtn=vtn+a(f)-vo
7880 PRINT TAB 13;vo;TAB 25;a(f)-vo;TAB 30;AT f*2+9,2;TAB 30
7890 NEXT f
7900 PRINT AT 18,2;"Estimated votes for you=";vty
7910 PRINT AT 19,2;"Est. votes against you=";vtn
7920 GO SUB 7500
7930 GO TO 4000
8000 BORDER 5:\
    : PAPER 5:\
     CLS
8010 PRINT AT 1,2; INK 6; PAPER 1;"GROWTH OF LIVING STANDARDS"
8020 PRINT AT 3,20; PAPER 7;"YEAR ";ye-1
8100 INK 0:\
     PLOT 31,150:\
     DRAW 0,-111:\
     DRAW 212,0
8110 FOR f=1 TO 12:\
     PRINT AT 17-f,1;f*2:\
     NEXT f
8120 FOR f=1 TO 25 STEP 3:\
     PRINT AT 18,f+3;f;AT 17,f+3; OVER 1;"|":\
     NEXT f
8130 BRIGHT 1:\
     PRINT AT 4,5; INK 3; PAPER 7;CHR$ 147;:\
     PRINT "=IDEAL L.S.";AT 6,5;\{i5i0} INK 2;CHR$ 148;:\
     PRINT "=ACTUAL L.S."
8140 PRINT OVER 1;AT 3,0;"L.S"
8150 PRINT AT 20,26;"YEAR":\
     BRIGHT 0
8200 FOR f=1 TO 25:\
     FOR g=1 TO f*2/5:\
     PRINT AT 17-g,f+3; INK 3; PAPER 7;CHR$ 147:\
     NEXT g:\
     NEXT f
8210 FOR f=1 TO ye:\
     FOR g=1 TO z(f)/2:\
     PRINT OVER 1; INK 2;AT 17-g,f+3; PAPER 8;CHR$ 148:\
     NEXT g:\
     NEXT f
8220 GO SUB 7500
8230 IF ye<25 THEN GO TO 1000
8240 INK 4:\
     PAPER 0:\
     BORDER 3:\
     CLS
8250 PRINT AT 2,6;"25 YEARS OF POWER"
8260 PRINT AT 4,2;"You have successfully ruled";AT 5,2;"the Tribe for 25 years!"
8270 PRINT AT 7,2;"You are rewarded with lands";AT 8,2;"and 500 ingots by the grateful";AT 9,2;"people."
8280 GO TO 7360
9000 RANDOMIZE
9010 LET ye=1:\
     LET st=50:\
     LET cash=0:\
     LET rs=0:\
     LET ls=0:\
     LET ls1=0:\
     LET ic=0
9020 DIM z(30):\
     DIM a(4):\
     DIM b(4):\
     DIM c(4):\
     LET a(1)=20
9030 DIM s(3):\
     LET s(1)=1:\
     LET s(3)=1
9500 DATA 0,60,24,60,126,126,60,0
9510 DATA 16,40,68,124,68,84,124,0
9520 DATA 0,0,30,38,74,244,152,240
9530 DATA 255,129,129,129,129,129,129,255
9540 DATA 0,0,60,60,60,60,0,0
9600 RESTORE 9500:\
     FOR f=144 TO 148:\
     FOR g=0 TO 7:\
     READ a:\
     POKE USR CHR$ f+g,a:\
     NEXT g:\
     NEXT f
9990 RETURN
