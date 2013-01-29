Auto 1

# Run-time Variables

Var a: Num = 0
Var xc: Num = 10
Var yc: Num = 10
Var dx: Num = 88
Var dy: Num = 88
Var ik: Num = 2
Var f: NumFOR = 65536, 65535, 1, 32, 3
Var y: NumFOR = 20, 19, 1, 1050, 2
Var c$: Str = "\a1\a2\a3\a4\a5\a6\a7\a8\a9\a0\aJ\aQ\aK\b1\b2\b3\b4\b5\b6\b7\b8\b9\b0\bJ\bQ\bK\d1\d2\d3\d4\d5\d6\d7\d8\d9\d0\dJ\dQ\dK\c1\c2\c3\c4\c5\c6\c7\c8\c9\c0\cJ\cQ\cK"
Var a$: Str = "\a1"

# End Run-time Variables

  10 REM Pontoon by Dunny, 2005
  11 REM Initialise the screen and graphics
  20 BORDER 4:\
     INK 0:\
     PAPER 4:\
     BRIGHT 1:\
     CLS
  30 PLOT 0,0:\
     DRAW 255,0:\
     DRAW 0,175:\
     DRAW -255,0:\
     DRAW 0,-175
  31 PRINT AT 1,10;"PLEASE WAIT"
  32 RESTORE 33:\
     FOR F=65368 TO 65535:\
     READ A:\
     POKE F,A:\
     NEXT F
  33 DATA 0,102,255,255,255,126,60,24,24,60,126,255,255,90,24,126,24,60,126,255,255,126,60,24,24,60,60,90,255,255,24,60
  34 DATA 15,63,127,127,255,255,255,255,240,252,254,254,255,255,255,255,255,255,255,255,127,127,63,15,255,255,255,255,254,254,252,240
  35 DATA 153,66,36,145,137,36,66,153,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  36 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  37 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  38 DATA 0,0,0,0,0,0,0,0
  40 LET c$="\a1\a2\a3\a4\a5\a6\a7\a8\a9\a0\aJ\aQ\aK":\
     LET c$=c$+"\b1\b2\b3\b4\b5\b6\b7\b8\b9\b0\bJ\bQ\bK":\
     LET c$=c$+"\d1\d2\d3\d4\d5\d6\d7\d8\d9\d0\dJ\dQ\dK":\
     LET c$=c$+"\c1\c2\c3\c4\c5\c6\c7\c8\c9\c0\cJ\cQ\cK"
  45 LET xc=10:\
     LET yc=10:\
     LET a$=c$(1 TO 2)
1000 REM Draw a card. Type is in a$ - suit,number
1010 REM Coordinates are in XC,YC
1020 REM
1030 PRINT AT YC,XC; INK 7;"\e"; PAPER 7;"     "; PAPER 4;"\f";AT YC+1,XC; PAPER 7; INK 0;"       ";AT YC+2,XC;"       ";AT YC+3,XC;"       ";AT YC+4,XC;"       ";AT YC+5,XC;"       ";AT YC+6,XC;"       ";AT YC+7,XC;"       ";AT YC+8,XC;"       ";AT YC+9,XC;"       ";AT YC+10,XC; INK 7; PAPER 4;"\g"; PAPER 7;"     "; PAPER 4;"\h"
1035 LET dx=8+XC*8:\
     LET dy=(21-YC)*8:\
     PLOT dx,dy:\
     DRAW PAPER 7; INK 0;39,0:\
     PLOT dx-1,dy-1:\
     DRAW 0,-71:\
     PLOT dx,dy-73:\
     DRAW 39,0:\
     PLOT dx+40,dy-72:\
     DRAW 0,71
1040 LET IK=0:\
     IF A$(1)="\a" OR a$(1)="\c" THEN LET IK=2
1050 FOR y=yc+1 TO yc+9:\
     PRINT AT y,xc+1; INK 1; PAPER 7;"\i\i\i\i\i":\
     NEXT y
