Auto 0

# Run-time Variables

Var b: Num = 32785
Var a: Num = 65535
Var f: NumFOR = 1, 8, 1, 90, 2

# End Run-time Variables

  10 LET b=32768
  20 READ a: IF a<>65535 THEN POKE b,a: LET b=b+1: GO TO 20
  30 DATA 33,255,87,14,192,6,32,183,203,22,43,16,251,13,32,245,201
  40 DATA 65535
  45 REM fast
  50 LET s$="... \*2004 DAVE's Scrollers Ltd ... "
  60 FOR l=1 TO LEN (s$)
  70 LET bit=1: LET Address=CODE s$(l)-32+(PEEK 23606+256*PEEK 23607): LET b1=PEEK (address): LET b2=PEEK (address+1): LET b3=PEEK (address+2): LET b4=PEEK (address+3): LET b5=PEEK (address+4): LET b6=PEEK (address+5): LET b7=PEEK (address+6): LET b8=PEEK (address+7): FOR b=0 TO 7
 999 FOR f=1 TO 8: RANDOMIZE USR 32768: PAUSE 1: NEXT f: GO TO 60
