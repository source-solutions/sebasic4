Auto 1

# Run-time Variables

Var n: Num = 0
Var w: Num = 45
Var k: Num = 1
Var a: Num = 2
Var u: Num = 128
Var v: Num = 88
Var h: Num = 0.5
Var c: Num = 0.70710678
Var s: Num = 0.70710678
Var y: Num = 1.9784946
Var x: Num = 2
Var z: Num = 0.010962843
Var k1: Num = 30
Var rd: Num = 0.017453293
Var dx: Num = 3
Var dy: Num = 5
Var af: Num = 0.021505376
Var xg: Num = 255
Var yg: Num = 153
Var f1: Num = 0
Var x1: Num = 255
Var y1: Num = 153
Var f2: Num = 0
Var x2: Num = 255
Var y2: Num = 153
Var h: NumArray(256) = 54, 58, 61, 61, 65, 69, 72, 76, 79, 83, 83, 86, 90, 93, 97, 101, 101, 104, 107, 111, 114, 118, 121, 121, 125, 128, 132, 135, 139, 142, 142, 146, 150, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 154, 154, 154, 154, 154, 154, 154, 154, 154, 154, 154, 154, 154, 154, 154, 154, 154, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000
Var l: NumFOR = 86, 256, 1, 210, 2
Var p: NumFOR = 97, 93, 5, 250, 2
Var q: NumFOR = 96, 93, 3, 270, 2

# End Run-time Variables

   1 REM fast
  50 INPUT "choose example(0-5):";n:\
     IF n<0 OR n>5 THEN GO TO 50
  70 PRINT "try:";("35>.6>2>33" AND n=1);("45>.5>180>35" AND n=2);("45>.5>108or180>50" AND n=3);("45>.5>90>30" AND n=4);("45>.5>90>30" AND (n=5 OR n=6))
 100 REM grafic z=f(x,y) hidden lines. change function in line 1000 for different effects
 120 INPUT "Alpha in degree's(45-135)";w
 130 INPUT "reduce factor(.5-.75)";k
 140 INPUT "rightborder for x(>0)";a
 150 INPUT "Enlargement factor(30-80)";k1
 160 LET u=128:\
     LET v=88
 170 LET h=.5:\
     LET rd=PI /180
 180 LET c=k*COS (w*rd):\
     LET s=k*SIN (w*rd)
 190 LET dx=3:\
     LET dy=5:\
     LET af=a/93
 200 DIM h(256)
 210 FOR l=1 TO 256
 220 LET h(l)=-1000
 230 NEXT l
 240 CLS
 250 FOR p=-93 TO 93 STEP dy
 260 LET y=p*af
 270 FOR q=-93 TO 93 STEP dx
 280 LET x=q*af:\
     GO SUB 1000+(50*n)
 290 LET xg=INT (u+q+c*p+h)
 300 LET yg=INT (v+s*p+z+h)
 310 IF xg<0 THEN LET xg=0
 315 IF xg>255 THEN LET xg=255
 320 IF yg<0 OR yg>175 THEN PRINT "wrong enlarge":\
     STOP
 330 IF q>-93 THEN GO TO 370
 340 LET f1=0:\
     LET l=INT (xg/dx)+1
 350 IF yg>h(l) THEN LET f1=1:\
     LET h(l)=yg
 360 LET x1=xg:\
     LET y1=yg:\
     GO TO 420
 370 LET f2=0:\
     LET l=INT (xg/dx)+1
 380 IF yg>h(l) THEN LET f2=1:\
     LET h(l)=yg
 390 LET x2=xg:\
     LET y2=yg
 400 IF f1*f2=1 THEN PLOT x1,y1:\
     DRAW x2-x1,y2-y1
 410 LET x1=x2:\
     LET y1=y2:\
     LET f1=f2
 420 NEXT q
 430 NEXT p
 440 IF INKEY$ ="" THEN GO TO 440
 450 STOP
1000 LET z=k1*EXP (-x*x-y*y)
1010 RETURN
1050 LET r=SQR (x*x+y*y)*rd
1060 LET z=k1*(COS (r)-COS (3*r)/3+COS (5*r)/5-COS (7*r)/7)
1070 RETURN :\
     REM input w=45:\
    k=0.5:\
    a=180 degr:\
    k1=35
1100 LET r=SQR (x*x+y*y)*rd:\
     IF r=0 THEN LET z=k1:\
     RETURN
1110 LET z=k1*SIN (r)/r
1120 RETURN :\
     REM input w=45:\
    k=.5:\
    a=108 or 180??(type error1080 degree??):\
    k1=50
1150 LET r=SQR (x*x+y*y):\
     LET z=k1*EXP (-COS (r/16)):\
     RETURN :\
     REM input w=45:\
    k=.5:\
    a=90:\
    k1=30
1200 LET r=SQR (x*x+y*y):\
     LET z=k1*COS (r/16):\
     RETURN :\
     REM w=45:\
    k=.5:\
    a=90:\
    k1=50
1250 LET r=SQR (x*x+y*y):\
     LET z=k1*SIN (r/16):\
     RETURN :\
     REM w=45:\
    k=.5:\
    a=90:\
    k1=50
2010 RETURN
