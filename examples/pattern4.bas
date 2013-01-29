Auto 1

# Run-time Variables

Var a: Num = 255
Var ik: Num = 3
Var pp: Num = 2
Var f: NumFOR = 65400, 65399, 1, 200, 3
Var a$: Str = "\b"

# End Run-time Variables

  10 BORDER 0: PAPER 0: INK 6: CLS
  20 GO SUB 70
  30 LET a$=CHR$ (144+RND*3)
  40 LET ik=INT (RND*6)+1: LET pp=INT (RND*6)+1: IF ik=pp THEN GO TO 40
  50 PRINT INK ik; PAPER pp; BRIGHT RND*1;a$;
  60 GO TO 30
  70 RESTORE 80: FOR F=65368 TO 65399: READ A: POKE F,A: NEXT F: RETURN
  80 DATA 255,254,252,248,240,224,192
  90 DATA 128,255,127,63,31,15,7,3
 100 DATA 1,1,3,7,15,31,63,127
 110 DATA 255,128,192,224,240,248,252,254,255
