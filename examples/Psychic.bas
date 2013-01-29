Auto 1

# Run-time Variables

Var b: Num = 7
Var a: NumArray(100) = 12, 9, 3, 9, 9, 11, 20, 19, 4, 7, 11, 18, 13, 14, 4, 10, 15, 13, 7, 15, 6, 8, 2, 16, 9, 13, 9, 7, 18, 6, 14, 17, 15, 9, 15, 1, 7, 14, 18, 4, 20, 18, 18, 9, 15, 7, 5, 14, 4, 4, 2, 2, 9, 19, 7, 18, 6, 11, 5, 14, 13, 15, 4, 7, 19, 3, 17, 19, 19, 17, 12, 7, 7, 20, 19, 10, 14, 6, 6, 3, 4, 7, 11, 8, 5, 9, 17, 13, 20, 10, 7, 19, 15, 8, 14, 7, 15, 5, 11, 11
Var f: NumFOR = 101, 100, 1, 80, 2
Var c$: Str = "!\`$%&*+=<>\@#{}[]()/:"

# End Run-time Variables

  10 REM 24 BASin Mind Reader
  20 REM \* 2004 Paul Dunn
  30 REM
  40 BORDER 0: PAPER 0: INK 6: BRIGHT 0: CLEAR : PRINT AT 0,0; PAPER 1; INK 7; BRIGHT 1;"                                      The Psychic Spectrum                                      "
  50 PRINT AT 5,3;"Please wait - Initialising"
  60 DIM a(100): LET c$="!\`$%&*+=<>\@#{}[]()/:"
  70 LET b=INT (RND*20)+1: FOR f=1 TO 10: LET a((f*9)+1)=b: NEXT f
  80 FOR f=1 TO 100: IF a(f)=0 THEN LET a(f)=INT (RND*20)+1
  90 NEXT f
 100 PRINT AT 5,0;"Choose any two digit number, addtogether both digits and then   subtract the total from your    original number."
 110 PRINT AT 10,0;"When you've done, press any key to see a table of symbols."''"Find your number on this list"'"and remember which symbol"'"matches it."
 120 PAUSE 1: PAUSE 0
 130 CLS : PRINT AT 0,0; PAPER 1; INK 7; BRIGHT 1;"                                      The Psychic Spectrum                                      "
 140 PRINT : FOR f=1 TO 17
 150 IF f<11 THEN PRINT " ";
 160 PRINT " ";f-1;"=";c$(a(f));" ";
 170 PRINT f+16;"=";c$(a(f+17));" ";
 180 PRINT f+33;"=";c$(a(f+34));" ";
 190 PRINT f+50;"=";c$(a(f+51));" ";
 200 PRINT f+67;"=";c$(a(f+68));" ";
 210 IF f<16 THEN PRINT f+84;"=";c$(a(f+85));" ";
 220 PRINT ""
 230 NEXT f
 240 PRINT AT 1,1; PAPER 1; INK 7; BRIGHT 1;"   Press any key to continue"
 250 PAUSE 1: PAUSE 0
 260 CLS : PRINT AT 0,0; PAPER 1; INK 7; BRIGHT 1;"                                      The Psychic Spectrum                                      "
 270 PRINT AT 5,0;"       Your symbol was...       "
 280 PRINT AT 21,0; INK 0; PAPER 0;c$(a(10))
 290 FOR x=0 TO 7: FOR y=0 TO 7: IF POINT (x,y)=1 THEN PRINT AT (7-y)+7,x+12;"\::"
 300 NEXT y: NEXT x
 310 PRINT AT 21,0; INK 5;"    Press a key to try again"
 320 PAUSE 1: PAUSE 0: GO TO 10
