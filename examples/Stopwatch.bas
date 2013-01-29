Auto 0

# Run-time Variables

Var time: Num = 8904
Var tenths: Num = 17808
Var seconds: Num = 58
Var minutes: Num = 2
Var s$: Str = "0"
Var m$: Str = "0"
Var t$: Str = "0"

# End Run-time Variables

  10 REM fast
  20 POKE 23672, 0:\
     POKE 23673, 0
  35 LET time=PEEK (23672)+(256*PEEK (23673))
  40 LET tenths=time*2
  50 LET tenths=tenths-(INT (tenths/100)*100)
  60 LET seconds=INT (time/50)
  70 LET minutes=INT (seconds/60)
  80 LET seconds=seconds-(INT (seconds/60)*60)
  90 LET m$="":\
     LET S$="":\
     LET t$=""
 100 IF minutes<10 THEN LET m$="0"
 110 IF seconds<10 THEN LET s$="0"
 120 IF tenths<10 THEN LET T$="0"
 130 PRINT AT 0,0;m$;minutes;":";s$;Seconds;":";t$;tenths;"    "
 140 GO TO 30
