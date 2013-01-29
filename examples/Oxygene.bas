Auto 1

# Run-time Variables

Var n: NumFOR = 5, 4, 1, 70, 2
Var p: NumFOR = -1, 0, -1, 70, 3

# End Run-time Variables

  10 BORDER 3: PAPER 3: INK 7: CLS
  20 PRINT AT 4,7;"JEAN MICHEL JARRE"
  30 CIRCLE 127,60,57: CIRCLE 88,60,8: PLOT 97,52: DRAW 10,16: PLOT 97,68: DRAW 10,-16: PLOT 109,68: DRAW 5,-8: DRAW 5,8: PLOT 114,60: DRAW 0,-8
  40 PLOT 136,60: DRAW -16,0,-PI: PLOT 120,60: DRAW 12,8,-PI/1.8: PLOT 136,60: DRAW 0,-8
  50 PLOT 148,52: DRAW -10,0: DRAW 0,16: DRAW 10,0: PLOT 138,62: DRAW 9,0: PLOT 150,52: DRAW 0,16: DRAW 10,-16: DRAW 0,16
  60 PLOT 172,52: DRAW -10,0: DRAW 0,16: DRAW 10,0: PLOT 162,62: DRAW 9,0
  70 FOR n=1 TO 4: FOR p=5 TO 0 STEP -1: PRINT AT 13,9; OVER 1; PAPER p;"              ";AT 14,9; OVER 1; PAPER p;"              ";AT 15,9; PAPER p; OVER 1;"              ": PAUSE 2: NEXT p: NEXT n: PRINT AT 17,13; INK 6;"Part 4"
  80 PAUSE 100
  90 LET e$="T100O4V9((1C&C#a&C&&g&&#a))1C&C#a&C&&g&&#aH"
 100 LET c$="UX1100W4O3M35N1d&&O7X2000W0N1d&dO3W4X1100N1d&dO8X260N1D&&)"
 110 LET o$="T100O5V11(5_1C1g3#d4g6c&1&)H"
 120 LET p$="O2V10N3C1C3#a4C1g3g1#a)"
 130 LET q$="T100O5V11N5_1#a1a3g4a6d&1&(3a1g3f6c1&)H": LET r$="O2V10(3D1D3C4D1g3C1g)(3F1F3#D4C1F3#D1C)"
 140 LET u$="("+p$( TO LEN p$-1)+")"+r$
 150 LET m$=q$( TO 26)+"H": LET n$=r$( TO 21)
 160 LET s$="T100O6V10(1cgc3gc1&&&&&)(d#ad3#ad1&&&&&)(fCf3Cf1&&&&&)H"
 170 LET t$="O4V11(1#DD#D3Cg1&&&&&)(#aa#a3gd1&&&&&)(aga3fC1&&&&&)"
 180 RESTORE 190: FOR q=0 TO 13: READ fa: OUT 65533,q: OUT 49149,fa: NEXT n
 190 DATA 0,0,0,0,0,0,7,71,20,20,20,0,38,14
 200 FOR m=1 TO 1450: NEXT m
 210 PLAY e$,p$,c$
 220 PLAY o$,p$,c$
 230 PLAY m$,n$,c$
 240 PLAY o$,p$,c$
 250 PLAY q$,r$,c$
 260 PLAY o$,p$,c$
 270 PLAY q$,r$,c$
 280 PLAY o$,p$,c$
 290 PLAY q$,r$,c$
 300 PLAY s$,u$,c$
 310 PLAY s$,t$,c$
 320 PLAY s$,t$,c$
 330 PLAY o$,p$,c$
 340 PLAY q$,r$,c$
 350 PLAY o$,p$,c$
 360 PLAY q$,r$,c$
 370 PLAY s$,u$,c$
 380 PLAY s$,t$,c$: PLAY s$,t$,c$
 390 PLAY o$,p$
 400 FOR V=10 TO 0 STEP -1: PLAY "T110O3V"+STR$ V+"N1c#dg": NEXT v
