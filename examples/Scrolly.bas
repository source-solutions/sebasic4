Auto 0

  10 LET address=32768
  20 READ a: IF a<>65535 THEN POKE address,a: LET address=address+1: GO TO 20
  30 DATA 33,255,87,14,192,6,32,183,203,22,43,16,251,13,32,245,201
  40 DATA 65535
  45 REM fast
  46 DIM b(8)
  50 LET s$="... \*2004 Dave's Scrollys Ltd... "
  60 FOR l=1 TO LEN (s$)
  70 LET Address=((CODE s$(l)-32)*8)+(PEEK 23606+256*PEEK 23607)+256: LET b(1)=PEEK (address): LET b(2)=PEEK (address+1): LET b(3)=PEEK (address+2): LET b(4)=PEEK (address+3): LET b(5)=PEEK (address+4): LET b(6)=PEEK (address+5): LET b(7)=PEEK (address+6): LET b(8)=PEEK (address+7)
  80 FOR g=7 TO 0 STEP -1: FOR h=1 TO 8: IF 2*INT (b(h)/2^(g+1))<>INT (b(h)/2^g) THEN PRINT AT h-1,31;"\::"
  90 NEXT h
 999 FOR f=1 TO 8: RANDOMIZE USR 32768: PAUSE 1: NEXT f: NEXT g: NEXT l: GO TO 60
