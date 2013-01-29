Auto 0
   1 REM SLOW
  10 REM Sierpinski's Triangle
  20 CLS :\
     INPUT "No of Points: ";Pts:\
     PRINT AT 0,0;"Setting up...":\
     DIM x(pts):\
     DIM y(pts):\
     LET a=0:\
     LET s=(2*PI )/pts:\
     FOR f=1 TO pts:\
     LET x(f)=127+(COS (a)*87):\
     LET y(f)=87+(SIN (a)*87):\
     LET a=a+s:\
     NEXT f:\
     CLS :\
     PRINT #1;"    Press any key to restart    "
  25 REM FAST
  30 LET ox=x(1):\
     LET oy=y(1):\
     FOR f=1 TO 2:\
     LET pt=INT (RND *pts)+1:\
     LET ox=((x(pt)-ox)/2)+ox:\
     LET oy=((y(pt)-oy)/2)+oy:\
     PLOT ox,oy:\
     LET f=2*(INKEY$ <>""):\
     NEXT f:\
     GO TO 1
