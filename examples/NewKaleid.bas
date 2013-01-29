Auto 0

# Run-time Variables

Var a: Num = 245
Var d: Num = 34.4438781
Var s: Num = 23216
Var l: Num = 9
Var k: Num = 71
Var inc: Num = 0.68887756
Var f: NumFOR = 5, 4, 1, 21, 2
Var i: NumFOR = 10, 15, 1, 90, 2
Var j: NumFOR = 4, 9, 1, 100, 2
Var a$: Str = "\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b"
Var b$: Str = "\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'"
Var c$: Str = "\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'."
Var d$: Str = "\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a"

# End Run-time Variables

   1 POKE 23692,255
  10 BORDER 0: PAPER 0: INK 7: CLS
  11 GO SUB 9000
  15 LET a$="\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b"
  16 LET b$="\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'"
  17 LET c$="\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'."
  18 LET d$="\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\b\.'\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a\'.\a"
  20 FOR f=0 TO 5: PRINT INK 7; PAPER 0;a$;b$: NEXT f
  21 FOR f=0 TO 4: PRINT INK 7; PAPER 0;AT (f*2)+12,0;c$;d$;: NEXT f
  50 LET D=0
  60 LET S=22928
  70 LET INC=((RND *70)+3)/100
  80 LET L=0
  90 FOR I=1 TO 15
 100 FOR J=0 TO L
 110 LET D=D+INC
 120 LET K=INT (64*SIN D)+64
 130 POKE S+32-31*I+32*J,K
 140 POKE S-31*I-32*J,K
 150 POKE S-33*I+31+32*J,K
 160 POKE S-33*I-1-32*J,K
 170 IF I>12 THEN GO TO 220
 180 POKE S+J,K
 190 POKE S-J-1,K
 200 POKE S-64*I+31-J,K
 210 POKE S-64*I+32+J,K
 220 NEXT J
 230 LET L=L+1
 240 LET S=S+32
 250 NEXT I
 260 GO TO 50
9000 RESTORE 9001: FOR F=65368 TO 65383: READ A: POKE F,A: NEXT F
9010 DATA 245,250,245,250,95,175,95,175
9020 DATA 175,95,175,95,250,245,250,245
9999 RETURN
