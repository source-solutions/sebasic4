Auto 1

# Run-time Variables

Var a: Num = 10.573975
Var d: Num = 50
Var b: Num = 28.0899963
Var l: Num = 17
Var c: Num = 0
Var y: Num = 15
Var x: Num = 0
Var z: Num = 0
Var hs: Num = 0
Var lent: Num = 3
Var sc: Num = 0
Var ml: Num = 10
Var mc: Num = 16
Var scr: Num = 0
Var l: NumArray(12) = 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var c: NumArray(12) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var n: NumFOR = 201, 200, 1, 500, 5
Var h$: Str = "Me"
Var a$: Str = "a"

# End Run-time Variables

   1 GO SUB 9000:\
     LET hs=0:\
     LET h$="Me"
   5 BORDER 2:\
     PAPER 7:\
     CLS :\
     INK 0
   7 INPUT ""
  10 LET LENT=3
  30 LET sc=0
  40 LET ml=10:\
     LET mc=16
  50 LET d=50
  60 GO SUB 1000
  70 LET scr=0
 100 PRINT INK 4;AT l,c;"\a";AT l-l(1),c-c(1);"\b";AT y,x;" "
 105 BEEP .01,10
 110 FOR n=LENT TO 2 STEP -1:\
     LET l(n)=l(n-1):\
     LET c(n)=c(n-1):\
     NEXT n
 120 LET a$=CHR$ PEEK 23560
 130 LET l(1)=-1*(a$="q")+(a$="a")
 140 LET c(1)=-1*(a$="o")+(a$="p")
 150 LET l=l+l(1):\
     LET c=c+c(1)
 160 LET y=y+l(LENT):\
     LET x=x+c(LENT)
 170 IF l<0 OR l>21 OR c<0 OR c>31 OR ATTR (l,c)=50 THEN GO TO 500
 180 IF ATTR (l,c)=15 THEN GO SUB 200
 190 GO TO 100
 200 LET q=VAL SCREEN$ (l,c):\
     LET sc=sc+q
 205 BEEP .01,30
 210 LET z=z+1:\
     IF q<>z THEN GO TO 500
 220 IF z=9 THEN GO TO 300
 230 LET LENT=LENT+1:\
     LET l(LENT)=l(LENT-1):\
     LET c(LENT)=c(LENT-1):\
     LET y=y-l(LENT):\
     LET x=x-c(LENT)
 240 RETURN
 300 LET LENT=3:\
     LET sc=sc+100*scr:\
     LET scr=scr+1:\
     LET d=d+20:\
     POKE 23659,1:\
     PRINT AT 22,0; PAPER 6; FLASH 1;"  BONUS! BONUS! BONUS! BONUS!   ":\
     FOR i=0 TO 60:\
     BEEP .01,i:\
     NEXT i:\
     PRINT AT 22,0;"                                ":\
     POKE 23659,2:\
     GO SUB 1000:\
     RETURN
 500 BEEP .2,-10:\
     BORDER 2:\
     INPUT "":\
     FOR n=1 TO 200:\
     BORDER 1:\
     BORDER 1:\
     BORDER 1:\
     BORDER 1:\
     BORDER 2:\
     BORDER 2:\
     BORDER 2:\
     BORDER 2:\
     NEXT n
 505 BORDER 2
 520 PAPER 2:\
     CLS :\
     INK 7
 530 PRINT ''''TAB 5;"You cleared ";scr;" screens"''TAB 5;"and scored ";sc;" points."
 540 IF sc>hs THEN PRINT ''TAB 5;"The high score was ";hs''TAB 5;"Held by ";h$''TAB 5;"But it is now ";sc;".":\
     LET hs=sc:\
     INPUT "What is your name?;:"; LINE h$:\
     PRINT 'TAB 5;"Held by ";h$:\
     GO TO 560
 550 PRINT ''TAB 5;"The high score is ";hs''TAB 5;"Held by ";h$
 560 PRINT ''TAB 5;"Another game?"
 570 IF INKEY$="y" THEN GO TO 5
 580 IF INKEY$="n" THEN PRINT '''TAB 10; FLASH 1; INK 3;"Thanks for the game"; FLASH 0:\
     STOP
 590 GO TO 570
1000 CLS :\
     FOR n=1 TO d:\
     BEEP .01,0:\
     PRINT AT RND*21,RND*31; INK 2; PAPER 6;"\c":\
     NEXT n
1010 FOR n=1 TO 9
1015 BEEP .01,20:\
     LET a=RND*20+1:\
     LET b=RND*30+1:\
     IF SCREEN$ (a,b)<>" " THEN GO TO 1015
1020 PRINT AT a,b; PAPER 1; INK 7;n:\
     NEXT n
1030 DIM l(12):\
     DIM c(12)
1040 LET l=0:\
     LET c=0:\
     LET y=0:\
     LET x=0:\
     LET z=0
1050 POKE 23560,32
1060 RETURN
9000 FOR n=0 TO 23:\
     READ a:\
     POKE USR "a"+n,a:\
     NEXT n
9010 DATA BIN 01111110,BIN 10000001,BIN 10100101,BIN 10000001,BIN 10100101,BIN 10111101,BIN 10000001,BIN 01111110
9020 DATA BIN 01111110,255,255,255,255,255,255,BIN 01111110
9030 DATA 255,255,BIN 11000011,BIN 11000011,BIN 11000011,BIN 11000011,255,255
9040 RETURN
