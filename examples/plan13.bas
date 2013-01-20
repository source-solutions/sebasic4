    0 DEF FN A(Y,X)=(ATN(Y/X) AND X<>0)+(PI/2*SGN(Y) AND X=0)+(PI AND X<0)+(2*PI AND (((ATN(Y/X) AND X<>0)+(PI/2*SGN(Y) AND X=0)+(PI AND X<0))<0)): REM FNatn
    1 DEF FN D(Y,M,D)=INT((Y-(1 AND M<=2))*YM)+INT((M+1+(12 AND M<=2))*30.6)+D-428: REM Convert date to day-number
    2 DEF FN G(X)=X*180/PI: REM DEG
    3 DEF FN I(X)=INT(X+0.5): REM ROUND
    4 DEF FN M$(S$,S,L)=S$(S TO S-1+L): REM MID$
    5 DEF FN R(X)=X*PI/180: REM RAD
    6 DEF FN S$(I,I$)=I$+VAL$ """""+FN S$(I-1,I$)"(TO 2+(12 AND I<>1)): REM STRING$
    7 DEF FN V(X,Y)=X-Y*INT (X/Y): REM MOD
    8 LET init=1000: LET satvec=2000: LET sunvec=3000: LET rangevec=4000
    9 LET mode=4280: LET printdata=6000: LET header=6140: REM PROCedures
   10 LET V$="PLAN13": REM OSCAR-13 POSITION, SUN+ECLIPSE PLANNER
   20 REM
   30 LET I$="v2.0": REM Last modified 1990 Aug 12 by JRM
   40 REM
   50 REM          (C)1990 J.R. Miller G3RUH
   60 REM
   70 REM Proceeds from the sale of this software go directly to the
   80 REM Amateur Satellite Programme that helped fund AO-13.
   90 REM If you take a copy PLEASE also send a small donation to:
  100 REM           AMSAT-UK, LONDON, E12 5EQ.
  110  
  120 MODE 1:      REM Screen 80 columns
  130 GOSUB init:  REM Set up constants
  140  
  150 INPUT "Enter start date(e.g. 1990, 12, 25) ";YR;", ";MN;", ";DY
  160 INPUT "Enter number of days for printout   ";ND
  170 LET DS=FN D(YR,MN,DY):       REM Start  day No.
  180 LET DF=DS+ND-1:              REM Finish day No.
  190   FOR X=DS TO DF:            REM DN
  200     FOR Y=0 TO 23:           REM HR
  210       FOR Z=0 TO 45 STEP 15: REM MIN
  220         LET TN=(Y+Z/60)/24
  230         GOSUB satvec
  240         GOSUB rangevec
  250         GOSUB sunvec
  260         IF EL>0 THEN GOSUB printdata
  270 NEXT Z:NEXT Y:NEXT X
  280 STOP 

 1000 REM PROCinit
 1010 REM SATELLITE EPHEMERIS
 1020 REM -------------------
 1030 LET S$="OSCAR-13"
 1040 LET YE=1990      : REM Epoch Year    year
 1050 LET TE=191.145409: REM Epoch time    days
 1060 LET In=56.9975   : REM Inclination   deg
 1070 LET RA=146.4527  : REM R.A.A.N.      deg
 1080 LET EC=0.6986    : REM Eccentricity   -
 1090 LET WP=231.0027  : REM Arg perigee   deg
 1100 LET MA= 43.2637  : REM Mean anomaly  deg
 1110 LET MM=2.09695848: REM Mean motion   rev/d
 1120 LET M2=1E-8      : REM Decay Rate    rev/d/d
 1130 LET RV=1585      : REM Orbit number   -
 1140 LET ALON=180     : REM Sat attitude, deg. 180=nominal } See bulletins
 1150 LET ALAT=0       : REM Sat attitude, deg.   0=nominal } for latest
 1160   
 1170 REM Observer's location+North,+East, ASL(m)
 1180 LET L$="G3RUH": LET LA=52.21: LET LO=0.06: LET HT=79: REM Cambridge, UK
 1190  
 1200 LET LA=FN R(LA): LET LO=FN R(LO): LET HT=HT/1000
 1210 LET CL=COS(LA): LET SL=SIN(LA): LET CO=COS(LO): LET SO=SIN(LO)
 1220 LET RE=6378.137: LET FL=1/298.257224: REM WGS-84 Earth ellipsoid
 1230 LET RP=RE*(1-FL): LET XX=RE*RE: LET ZZ=RP*RP
 1240 LET D=SQR(XX*CL*CL+ZZ*SL*SL)
 1250 LET Rx=XX/D+HT: LET Rz=ZZ/D+HT
 1260  
 1270 REM Observer's unit vectors UP EAST and NORTH in GEOCENTRIC coords.
 1280 LET Ux=CL*CO: LET Ex=-SO: LET Nx=-SL*CO
 1290 LET Uy=CL*SO: LET Ey=CO : LET Ny=-SL*SO
 1300 LET Uz=SL   : LET Ez=0  : LET Nz=CL
 1310  
 1320 REM Observer's XYZ coords at Earth's surface
 1330 LET Ox=Rx*Ux: LET Oy=Rx*Uy: LET Oz=Rz*Uz
 1340  
 1350 REM Convert angles to radians etc.
 1360 LET RA=FN R(RA): LET In=FN R(IN): LET WP=FN R(WP)
 1370 LET MA=FN R(MA): LET MM=MM*2*PI : LET M2=M2*2*PI
 1380  
 1390 LET YM=365.25:      REM Mean Year,     days
 1400 LET YT=365.2421874: REM Tropical year, days
 1410 LET WW=2*PI/YT:     REM Earth's rotation rate, rads/whole day
 1420 LET WE=2*PI+WW:     REM       ditto            radians/day
 1430 LET W0=WE/86400:    REM       ditto            radians/sec
 1440  
 1450 LET VOx=-Oy*W0: LET VOy=Ox*W0: REM Observer's velocity, GEOCENTRIC coords.(VOz=0)
 1460  
 1470 REM Convert satellite Epoch to Day No. and Fraction of day
 1480 LET DE=FN D(YE,1,0)+INT(TE): LET TE=TE-INT(TE)
 1490  
 1500 REM Average Precession rates
 1510 LET GM=3.986E5:          REM Earth's Gravitational constant km^3/s^2
 1520 LET J2=1.08263E-3:       REM 2nd Zonal coeff, Earth's Gravity Field
 1530 LET N0=MM/86400:         REM Mean motion rad/s
 1540 LET A0=(GM/N0/N0)^(1/3): REM Semi major axis km
 1550 LET B0=A0*SQR(1-EC*EC):  REM Semi minor axis km
 1560 LET SI=SIN(IN): LET CI=COS(IN)
 1570 LET PC=RE*A0/(B0*B0): LET PC=1.5*J2*PC*PC*MM: REM Precession const, rad/Day
 1580 LET QD=-PC*CI:           REM Node precession rate, rad/day
 1590 LET WD=PC*(5*CI*CI-1)/2: REM Perigee precession rate, rad/day
 1600 LET DC=-2*M2/MM/3: REM Drag coeff. (Angular momentum rate)/(Ang mom) s^-1
 1610  
 1620 REM Sidereal and Solar data. NEVER needs changing. Valid to year ~2015
 1630 LET YG=2000: LET G0=98.9821: REM GHAA, Year YG, Jan 0.0
 1640 LET MAS0=356.0507: LET MASD=0.98560028: REM MA Sun and rate,deg,deg/day
 1650 LET INS=FN R(23.4393): LET CNS=COS(INS): LET SNS=SIN(INS): REM Sun's inclination
 1660 LET EQC1=0.03342: LET EQC2=0.00035: REM Sun's Equation of centre terms
 1670  
 1680 REM Bring Sun data to Satellite Epoch
 1690 LET TEG =(DE-FN D(YG,1,0))+TE: REM Elapsed Time:Epoch-YG
 1700 LET GHAE=FN R(G0)+TEG*WE:      REM GHA Aries, epoch
 1710 LET MRSE=FN R(G0)+TEG*WW+PI:   REM Mean RA Sun at Sat epoch
 1720 REM bug LET MASE=FN R(MAS0+MASD*TEG):  REM Mean MA Sun  ..
 1730  
 1740 REM Antenna unit vector in orbit plane coordinates.
 1750 LET CO=COS(FN R(ALON)): LET SO=SIN(FN R(ALON))
 1760 LET CL=COS(FN R(ALAT)): LET SL=SIN(FN R(ALAT))
 1770 LET ax=-CL*CO: LET ay=-CL*SO: LET az=-SL
 1780  
 1790 REM Miscellaneous
 1800 REM @%=&507: REM 5 decimals, field 7
 1810 LET OLDRN=-99999
 1820 PRINT V$;" ";I$;"   SATELLITE PREDICTIONS"
 1830 PRINT FN S$(35,"-")
 1840 RETURN
 
 2000 REM PROCsatvec
 2010 REM Calculate Satellite Position at DN,TN
 2020 LET T=(DN-DE)+(TN-TE):  REM Elapsed T since epoch, days
 2030 LET DT=DC*T/2: LET KD=1+4*DT: LET KDP=1-7*DT: REM Linear drag terms
 2040 LET M=MA+MM*T*(1-3*DT): REM Mean anomaly at YR,TN
 2050 LET DR=INT(M/(2*PI)):   REM Strip out whole no of revs
 2060 LET M=M-DR*2*PI:        REM M now in range 0-2pi
 2070 LET RN=RV+DR:           REM Current Orbit number
 2080   
 2090 REM Solve M=EA-EC*SIN(EA) for EA given M, by Newton's Method
 2100 LET EA=M:                       REM Initial solution
 2110 REM REPEAT
 2120   LET C=COS(EA): LET S=SIN(EA): LET DNOM=1-EC*C
 2130   LET D=(EA-EC*S-M)/DNOM:       REM Change to EA for better solution
 2140   LET EA=EA-D:                  REM by this amount
 2150 IF ABS(D)>=1E-5 THEN GOTO 2110: REM Until converged
 2160  
 2170 LET A=A0*KD: LET B=B0*KD: LET RS=A*DNOM: REM Distances
 2180  
 2190 REM Calc satellite position & velocity in plane of ellipse
 2200 LET Sx=A*(C-EC): LET Vx=-A*S/DNOM*N0
 2210 LET Sy=B*S:      LET Vy= B*C/DNOM*N0
 2220   
 2230 LET AP=WP+WD*T*KDP:   LET CW=COS(AP):   LET SW=SIN(AP)
 2240 LET RAAN=RA+QD*T*KDP: LET CQ=COS(RAAN): LET SQ=SIN(RAAN)
 2250  
 2260 REM Plane -> celestial coordinate transformation, [C]=[RAAN]*[IN]*[AP]
 2270 LET CXx=CW*CQ-SW*CI*SQ: LET CXy=-SW*CQ-CW*CI*SQ: LET CXz= SI*SQ
 2280 LET CYx=CW*SQ+SW*CI*CQ: LET CYy=-SW*SQ+CW*CI*CQ: LET CYz=-SI*CQ
 2290 LET CZx=SW*SI:          LET CZy= CW*SI:          LET CZz= CI
 2300  
 2310 REM Compute SATellite's position vector, ANTenna axis unit vector
 2320 REM and VELocity in CELESTIAL coordinates.(Note:Sz=0, Vz=0) 
 2330 LET SATx=Sx*CXx+Sy*CXy: LET ANTx=ax*CXx+ay*CXy+az*CXz: LET VELx=Vx*CXx+Vy*CXy
 2340 LET SATy=Sx*CYx+Sy*CYy: LET ANTy=ax*CYx+ay*CYy+az*CYz: LET VELy=Vx*CYx+Vy*CYy
 2350 LET SATz=Sx*CZx+Sy*CZy: LET ANTz=ax*CZx+ay*CZy+az*CZz: LET VELz=Vx*CZx+Vy*CZy
 2360  
 2370 REM Also express SAT,ANT and VEL in GEOCENTRIC coordinates:
 2380 LET GHAA=GHAE+WE*T: REM GHA Aries at elapsed time T
 2390 LET C=COS(-GHAA): LET S=SIN(-GHAA)
 2400 LET Sx=SATx*C-SATy*S: LET Ax=ANTx*C-ANTy*S: LET Vx=VELx*C-VELy*S
 2410 LET Sy=SATx*S+SATy*C: LET Ay=ANTx*S+ANTy*C: LET Vy=VELx*S+VELy*C
 2420 LET Sz=SATz:          LET Az=ANTz:          LET Vz=VELz
 2430 RETURN
 
 3000 REM PROCsunvec
 3010 REM bug LET MAS=MASE+FN R(MASD*T):          REM MA of Sun round its orbit
 3020 LET TAS=MRSE+WW*T+EQC1*SIN(MAS)+EQC2*SIN(2*MAS)
 3030 LET C=COS(TAS): LET S=SIN(TAS):             REM Sin/Cos Sun's true anomaly
 3040 LET SUNx=C: LET SUNy=S*CNS: LET SUNz=S*SNS: REM Sun unit vector - CELESTIAL coords
 3050  
 3060 REM Find Solar angle, illumination, and eclipse status.
 3070 LET SSA=-(ANTx*SUNx+ANTy*SUNy+ANTz*SUNz):    REM Sin of Sun angle -a.h
 3080 LET ILL=SQR(1-SSA*SSA):                      REM Illumination
 3090 LET CUA=-(SATx*SUNx+SATy*SUNy+SATz*SUNz)/RS: REM Cos of umbral angle-h.s
 3100 LET UMD=RS*SQR(1-CUA*CUA)/RE:                REM Umbral dist, Earth radii
 3110 IF CUA>=0 THEN LET E$="    +"
 3115 IF CUA<0  THEN LET E$="    -":               REM+for shadow side
 3120 IF UMD<=1 AND CUA>=0 THEN LET E$="   ECL":   REM-for sunny side
 3130  
 3140 REM Obtain SUN unit vector in GEOCENTRIC coordinates
 3150 LET C=COS(-GHAA): LET S=SIN(-GHAA)
 3160 LET Hx=SUNx*C-SUNy*S
 3170 LET Hy=SUNx*S+SUNy*C: REM If Sun more than 10 deg below horizon
 3180 LET Hz=SUNz:          REM satellite possibly visible
 3190 IF(Hx*Ux+Hy*Uy+Hz*Uz<-0.17) AND(E$<>"   ECL") THEN LET E$="   vis"
 3200 
 3210 REM Obtain Sun unit vector in ORBIT coordinates
 3220 LET Hx=SUNx*CXx+SUNy*CYx+SUNz*CZx
 3230 LET Hy=SUNx*CXy+SUNy*CYy+SUNz*CZy
 3240 LET Hz=SUNx*CXz+SUNy*CYz+SUNz*CZz
 3250 LET SEL=ASIN(Hz): LET SAZ=FN A(Hy,Hx)
 3260 RETURN

 4000 REM PROCrangevec
 4010 REM Compute and manipulate range/velocity/antenna vectors
 4020 LET Rx=Sx-Ox: LET Ry=Sy-Oy: LET Rz=Sz-Oz: REM Rangevec=Satvec-Obsvec
 4030 LET R=SQR(Rx*Rx+Ry*Ry+Rz*Rz):             REM Range magnitude
 4040 LET Rx=Rx/R: LET Ry=Ry/R: LET Rz=Rz/R: REM Normalise Range vector
 4050 LET U=Rx*Ux+Ry*Uy+Rz*Uz:               REM UP    Component of unit range
 4060 LET E=Rx*Ex+Ry*Ey:                     REM EAST    do  (Ez=0)
 4070 LET N=Rx*Nx+Ry*Ny+Rz*Nz:               REM NORTH   do
 4080 LET AZ=FN G(FN A(E,N)):                REM Azimuth
 4090 LET EL=FN G(ASIN(U)):                  REM Elevation
 4100  
 4110 REM Resolve antenna vector along unit range vector, -r.a=Cos(SQ)
 4120 LET SQ=FN G(ACOS(-(Ax*Rx+Ay*Ry+Az*Rz))): REM Hi-gain ant SQuint
 4130  
 4140 REM Calculate sub-satellite Lat/Lon
 4150 LET SLON=FN G(FN A(Sy,Sx)): REM Lon,+East
 4160 LET SLat=FN G(ASIN(Sz/RS)): REM Lat,+North
 4170  
 4180 REM Resolve Sat-Obs velocity vector along unit range vector.(VOz=0)
 4190 LET RR=(Vx-VOx)*Rx+(Vy-VOy)*Ry+Vz*Rz: REM Range rate, km/s
 4200 RETURN
 
 4280 REM PROCmode
 4290 LET M=INT(M*128/PI)
 4300 REM Mode switching MA/256
 4310 LET M$="-"
 4320 IF M>=  0 THEN LET M$="B"
 4330 IF M>=100 THEN LET M$="L"
 4340 IF M>=130 THEN LET M$="S"
 4350 IF M>=135 THEN LET M$="B"
 4360 IF M>=220 THEN LET M$="-"
 4370 RETURN
 
 5000 REM DEF FN D$(D)
 5010 REM Convert day-number to date; valid 1900 Mar 01-2100 Feb 28
 5015 LET D=DN
 5020 REM bug LET D=D+428: LET DW=FN V(D+5,7)
 5030 LET Y=INT((D-122.1)/YM): LET D=D-INT(Y*YM)
 5040 LET MN=INT(D/30.61): LET D=D-INT(MN*30.6)
 5050 LET MN=MN-1: IF MN>12 THEN LET MN=MN-12: LET Y=Y+1  
 5060 REM bug LET D$=STR$(Y)+" "+FN M$("JanFebMarAprMayJunJulAugSepOctNovDec",3*MN-2,3)
 5070 REM bug LET D$=D$+" "+STR$(D)+" ["+FN M$("SunMonTueWedThuFriSat",3*DW+1,3)+"]"
 5075 PRINT D$: RETURN

 6000 REM PROCprintdata
 6010 REM Construct time as a string
 6020 LET H$=STR$(HR): LET N$=STR$(MIN)
 6030 IF LEN(H$)<2 THEN LET H$="0"+H$
 6040 IF LEN(N$)<2 THEN LET N$="0"+N$
 6050 LET T$=H$+N$+"  "
 6060 
 6070 REM PROCmode: REM Get AO-13 mode.  Now round-off data
 6080 REM bug LET R=FN I(R): LET EL=FN I(EL): LET AZ=FN I(AZ): LET SQ=FN I(SQ): LET RR=FN I(RR*10)/10
 6090 REM bug LET HGT=FN I(RS-RE): LET SLON=FN I(SLON): LET SLat=FN I(SLat)
 6100 IF RN<>OLDRN THEN LET OLDRN=RN: GOSUB header
 6110 PRINT T$;STR$(M);"   ";M$,R,EL,AZ,SQ,RR,E$,HGT,SLat,SLON
 6120 RETURN
 6130 
 6140 REM header
 6150 LET RAAN=FN I(FN G(RAAN)): LET AP=FN I(FN G(AP)): LET SAZ=FN I(FN G(SAZ))
 6160 REM bug LET SEL=FN I(FN G(SEL)): LET ILL=FN I(100*ILL)
 6170 PRINT:PRINT
 6180 PRINT S$;" - ";L$;FN S$(16," ");"AMSAT DAY ";STR$(DN-722100);FN S$(12," ");: GOSUB 50000: REM FN D$(DN)
 6190 PRINT "ORBIT:";RN;"   AP/RAAN:";AP;"/";RAAN;"   ALON/ALAT:";ALON;"/";ALAT;
 6200 PRINT"   SAZ/SEL:";SAZ;"/";SEL;"   ILL:";ILL;"%"
 6210 PRINT
 6220 PRINT " UTC  MA  MODE  RANGE     EL     AZ     SQ     RR  ECL?    ";
 6230 PRINT "HGT    SLAT   SLON"
 6240 PRINT FN S$(77,"-")
 6250 RETURN
 6260 
 
16383 REM bug <- lines with this cannot be converted properly and must be edited after conversion