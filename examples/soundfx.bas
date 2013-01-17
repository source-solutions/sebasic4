   10 REM gunshots
   20 FOR x=1 TO 10
   30 SOUND 6, 15; 7, 7; 8, 16; 9, 16; 10, 16; 12, 16; 13, 0
   40 PAUSE 5
   50 NEXT x
  100 REM whistling bomb
  110 SOUND 7, 62; 8, 15
  120 FOR x=50 TO 100
  130 SOUND 0, x
  140 PAUSE 2
  150 NEXT x
  200 REM explosion
  210 SOUND 6, 6; 7, 7; 8, 16; 9, 16; 10, 16; 12, 56; 13, 8
  220 PAUSE 75
  230 SOUND 8, 0; 9, 0; 10, 0
  300 REM beep
  310 SOUND 0, 124; 1, 0; 8, 13; 7, 62
  320 PAUSE 5