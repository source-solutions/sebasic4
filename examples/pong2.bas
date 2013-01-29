   5 REM PONG - use q and a for left hand controls
  10 LET demo=1
  20 LET ls=0: LET rs=0
  30 BORDER 0: PAPER 4: INK 7
  40 LET df=1: CLS : PRINT #0;AT 0,0; PAPER 3; INK 6;" You: ";ls;TAB 26;"ZX: ";rs;CHR$ 6;CHR$ 6;CHR$ 6
  50 FOR i=1 TO 40: NEXT i: IF rs>4 OR ls>4 THEN GO TO 999
  60 LET x=15: LET y=INT (20*RND )+1
  80 LET ly=15: LET ry=12: LET dy=1: LET dx=(1 AND (rs>ls))-(1 AND (rs<=ls))
 120 REM loop
 130 LET xo=x: LET yo=y: LET oy=ly: LET ob=ry
 170 LET x=x+dx
 180 LET y=y+dy*df: IF y>21 THEN LET y=21
 190 IF y<0 THEN LET y=0
 200 IF x>(18+(RND *7)) THEN LET ry=ry+df*((y>ry)-(y<ry)): IF ry>20 THEN LET ry=20
 210 IF demo THEN IF x<(14-(RND *7)) THEN LET ly=ly+df*((y>ly)-(y<ly)): IF ly>20 THEN LET ly=20
 220 PRINT AT y,x;"o";AT yo,xo;" "
 230 IF INKEY$ ="q" THEN LET ly=ly-(ly>0): LET demo=0
 240 IF INKEY$ ="a" THEN LET ly=ly+(ly<20)
 250 IF ob<>ry THEN PRINT AT ob,30;" ";AT ob+1,30;" "
 260 PRINT INK 1;AT ry,30;"|";AT ry+1,30;"|"
 270 IF oy<>ly THEN PRINT AT oy,1;" ";AT oy+1,1;" "
 280 PRINT INK 1;AT ly,1;"|";AT ly+1,1;"|"
 290 IF ATTR (y,x-1)<>39 THEN LET dx=1: BEEP .03,9: IF RND >.6 THEN LET df=1+(df=1)
 300 IF ATTR (y,x+1)<>39 THEN LET dx=-1: BEEP .03,18: IF RND >.6 THEN LET df=1+(df=1)
 310 IF x=0 THEN LET rs=rs+1: BEEP .07,1: GO TO 40
 320 IF x=31 THEN LET ls=ls+1: BEEP .07,1: GO TO 40
 330 IF y=21 THEN LET dy=-1: BEEP 0.03,14
 340 IF y=0 THEN LET dy=1: BEEP 0.03,17
 350 GO TO 130
 999 PRINT AT 10,4;"GAME OVER = You: ";ls;"   ZX: ";rs: PAUSE 100
