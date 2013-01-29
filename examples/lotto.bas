Check F2C72467
Auto 1

# Run-time Variables

Var b: Num = 3
Var g: NumFOR = 9, 8, 1, 20, 4
Var f: NumFOR = 7, 6, 1, 20, 6
Var a$: Str = "15"

# End Run-time Variables

  10 REM Lotto-picker by Dunny
  20 RANDOMIZE : LET a$=" !""#$%&'()*+,-./0123456789:;<=>?\*ABCDEFGHIJKLMNOPQ": FOR g=1 TO 8: PRINT AT g,0;"Line ";STR$ (g);":": FOR f=1 TO 6: LET b=1+INT (RND*LEN a$): PRINT AT g,5+f*3;" "( TO CODE a$(b)-32<10);CODE a$(b)-32;" ";: LET a$=a$( TO b-1)+a$(b+1 TO ): NEXT f: PRINT : NEXT g
