Auto @Start

@Start:
     BORDER 0:\
     PAPER 0:\
     INK 7:\
     CLS
     FOR f=0 TO 12:\
     PRINT AT f,0; INK 0; PAPER 0;"\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'":\
     NEXT f
     FOR f=13 TO 21:\
     PRINT AT f,0; INK 0; PAPER 0;"\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.":\
     NEXT f
     PRINT #1; INK 0; PAPER 0;"\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\.'\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'.\'."
@Loop:
     LET D=0
     LET S=22928
     LET INC=((RND *70)+3)/100
     LET L=0
     FOR I=1 TO 15
     FOR J=0 TO L
     LET D=D+INC
     LET K=INT (64*SIN D)+64
     POKE S+32-31*I+32*J,K
     POKE S-31*I-32*J,K
     POKE S-33*I+31+32*J,K
     POKE S-33*I-1-32*J,K
     IF I>12 THEN GOTO @SkipHoriz
     POKE S+J,K
     POKE S-J-1,K
     POKE S-64*I+31-J,K
     POKE S-64*I+32+J,K
@SkipHoriz:
     NEXT J
     LET L=L+1
     LET S=S+32
     NEXT I
     GO TO @Loop
