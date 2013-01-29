   5 REM "MU" Model Universe
   6 REM \* W.R.Masefield 1983
  10 REM Input Data
  20 CLS :\
     PRINT "MODEL UNIVERSE":\
     PRINT
  30 INPUT "First Body: Mass? ";m1,"Velocity? ";v1,"Angle? ";a1,"x coord? ";x1,"y coord? ";y1,"Second Body: Mass? ";m2,"Velocity? ";v2,"Angle? ";a2,"x coord? ";x2,"y coord? ";y2,"Gravitational Constant? ";g:\
     CLS
  40 PRINT TAB 23;"M1=";m1:\
     PRINT TAB 23;"v1=";v1:\
     PRINT TAB 23;"A1=";a1:\
     PRINT TAB 23;"x1=";x1:\
     PRINT TAB 23;"y1=";y1:\
     PRINT TAB 23;"M2=";m2:\
     PRINT TAB 23;"v2=";v2:\
     PRINT TAB 23;"A2=";a2:\
     PRINT TAB 23;"x2=";x2:\
     PRINT TAB 23;"y2=";y2:\
     PRINT TAB 24;"G=";g
  50 LET dt=0.1:\
     LET a1=a1*PI /180:\
     LET a2=a2*PI /180:\
     LET x1=x1+10:\
     LET x2=x2+10
  60 CIRCLE x1,y1,2:\
     CIRCLE x2,y2,2
  70 LET v1x=v1*COS a1:\
     LET v2x=v2*COS a2
  80 LET v1y=v1*SIN a1:\
     LET v2y=v2*SIN a2
 100 REM Processing
 110 LET fg=g*m1*m2/((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
 120 IF x2=x1 THEN LET phi=PI /2:\
     GO TO 140
 130 LET phi=ATN ABS ((y2-y1)/(x2-x1))
 140 LET f1x=fg*COS phi*SGN (x2-x1):\
     LET f2x=-f1x
 150 LET f1y=fg*SIN phi*SGN (y2-y1):\
     LET f2y=-f1y
 160 LET a1x=f1x/m1:\
     LET a2x=f2x/m2
 170 LET s1x=v1x*dt+a1x*dt*dt/2:\
     LET s2x=v2x*dt+a2x*dt*dt/2
 180 LET v1x=v1x+a1x*dt:\
     LET v2x=v2x+a2x*dt
 190 LET a1y=f1y/m1:\
     LET a2y=f2y/m2
 200 LET s1y=v1y*dt+a1y*dt*dt/2:\
     LET s2y=v2y*dt+a2y*dt*dt/2
 210 LET v1y=v1y+a1y*dt:\
     LET v2y=v2y+a2y*dt
 300 REM Plot
 310 PLOT x1,y1:\
     DRAW s1x,s1y:\
     PLOT x2,y2:\
     DRAW s2x,s2y
 320 LET x1=x1+s1x:\
     LET x2=x2+s2x
 330 LET y1=y1+s1y:\
     LET y2=y2+s2y
 340 GO TO 100
