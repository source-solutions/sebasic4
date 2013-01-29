
# Run-time Variables

Var b: Num = 24
Var na: Num = 7
Var pu: Num = 175
Var a: NumFOR = 8, 7, 1, 10, 2
Var a$: Str = ""

# End Run-time Variables

  10 FOR a=0 TO 7:\
     READ b:\
     POKE USR "a"+a, b:\
     NEXT a:\
     DATA 36,189,255,165,165,189,189,24:\
     LET na=5:\
     LET pu=0:\
     CLS
  20 PAUSE 5:\
     PRINT AT 20, RND *31;"*":\
     PRINT AT 20, RND *31;"*":\
     PRINT :\
     POKE 23692, -1:\
     PRINT :\
     LET pu=pu+1:\
     IF SCREEN$ (0, na)="*" THEN PRINT AT 0,0; FLASH 1; "PUNTOS ";pu:\
     FOR a=0 TO 50:\
     BEEP .01, RND *40:\
     NEXT a:\
     RUN
  30 LET a$=INKEY$ :\
     IF a$="z" THEN LET na=na-1:\
     IF na=-1 THEN LET na=0
  40 IF a$="m" THEN LET na=na+1:\
     IF na=32 THEN LET na=31
  50 PRINT AT 0,na;"\a":\
     GO TO 20:\
     REM MASTERS GAMES
