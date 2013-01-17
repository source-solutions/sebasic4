   10 REM set volume to max for channels A -C
   20 SOUND 8, 15; 9, 15; 10, 15
   30 REM enable all channels
   40 SOUND 7, 63 - 1 - 2 - 4
   50 REM first chord
   60 SOUND 0, 162; 1, 1; 2, 23; 3, 1; 4, 235; 5, 0
   70 BEEP .25, -12: BEEP .25, -12: BEEP .25, -9: BEEP .25, -9: BEEP .25, -7: BEEP .25, -7: BEEP .25, -2: BEEP .25, -2
   80 REM second chord
   90 SOUND 0, 162; 1, 1; 2, 57; 3, 1; 4, 249; 5, 0
  100 BEEP .25, -3: BEEP .25, -3: BEEP .25, -7: BEEP .25, -7: BEEP .25, -9: BEEP .25, -9: BEEP .25, -14: BEEP .25, -14
  110 REM third chord
  120 SOUND 0, 162; 1, 1; 2, 96; 3, 1; 4, 23; 5, 1
  130 BEEP .25, -12: BEEP .25, -12: BEEP .25, -9: BEEP .25, -9: BEEP .25, -7: BEEP .25, -7: BEEP .25, -2: BEEP .25, -2
  140 REM fourth chord
  150 SOUND 0, 241; 1, 1; 2, 162; 3, 1; 4, 57; 5, 1
  160 BEEP .25, -3: BEEP .25, -3: BEEP .25, -7: BEEP .25, -7: BEEP .25, -9: BEEP .25, -9: BEEP .25, -14: BEEP .25, -14
  170 GO TO 50