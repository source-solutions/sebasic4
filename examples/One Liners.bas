Auto 0
   1 CLS :\
     PRINT " 1) SPREADSHEET","23) TRAILSEEKER"," 2) GUESS THE \{vn}#","24) SHOOT IT"," 3) SPACETRIP","25) COLORIS"," 4) MASTERMIND","26) BOUNCER"'" 5) HANGMAN","27) CATCH"'" 6) MEMORY","28) 2D CUBE"'" 7) METEORSTORM","29) TAKE&RUN"'" 8) BLOCKKILLER"'" 9) TIMERACER"'"10) REBOUND"'"11) MINEFIELD"'"12) MUSICPLAYER"'"13) SNAKE"'"14) FROGGER"'"15) BINGO"'"16) PACMAN"'"17) SHIFTPUZZLE"'"18) TOWERS OF HANOI"'"19) US BOWLING"'"20) CAVETRIP"'"21) TANKBATTLE (2 PERS)"'"22) MAZEGENERATOR":\
     INPUT "MAKE CHOICE ";s:\
     CLS :\
     GO SUB 2*s:\
     FOR q=1 TO 250:\
     NEXT q:\
     RUN
   2 DEF FN w(a,s)=VAL ((a$(a,s) AND a$(a,s)>"#")+"+0"):\
     LET x=1:\
     LET y=1:\
     DIM b$(32):\
     DIM a$(21,4,32):\
     INPUT "LOAD?";n$:\
     FOR h=1 TO n$>"":\
     LOAD n$ DATA a$():\
     NEXT h:\
     CLS :\
     FOR h=0 TO 1:\
     FOR f=1 TO 21:\
     PRINT AT f,0;f:\
     FOR g=1 TO 4:\
     PRINT AT 0,g*7;g;AT f,g*7-3;((STR$ FN w(f,g)+b$ AND a$(f,g)>"#")+a$(f,g,2 TO ))( TO 35-g*7) AND a$(f,g)>"!":\
     NEXT g:\
     NEXT f:\
     FOR s=0 TO 1:\
     PAUSE 1-s:\
     LET k=CODE INKEY$ :\
     PRINT OVER 1;AT y,x*7-3;"\::\::\::\::\::\::\::";#1;AT 0,0;a$(y,x):\
     NEXT s:\
     FOR j=1 TO k=13:\
     INPUT a$(y,x):\
     NEXT j:\
     LET x=x+(k=56)*(x<4)-(k=53)*(x>1):\
     LET y=y+(k=54)*(y<21)-(k=55)*(y>1):\
     LET s=k*(k>60)-1:\
     NEXT s:\
     LET h=k=81:\
     NEXT h:\
     INPUT "SAVE?";n$:\
     IF n$>"" THEN SAVE n$ DATA a$()
   3 RETURN
   4 LET a$="LOWER RIGHT HIGHER":\
     LET x=INT (RND *1000)+1:\
     FOR f=1 TO 99:\
     INPUT "ENTER NUMBER ";a:\
     LET c=(SGN (x-a)+1)*6+1:\
     PRINT a$(c TO c+5);" ";a,"GUESSES=";f:\
     IF a<>x THEN NEXT f
   5 RETURN
   6 LET d=15:\
     FOR a=0 TO 99999:\
     POKE 23692,0:\
     IF SCREEN$ (10,d)<"*" THEN PRINT AT 10,d;"O";AT 21,d+RND *5-RND *5;"*"''AT 0,0;"SCORE=";a:\
     LET d=d+(INKEY$ ="8")*(d<25)-(INKEY$ ="5")*(d>5):\
     NEXT a
   7 RETURN
   8 DIM a(4):\
     DIM b(4):\
     FOR z=0 TO 1:\
     LET p=0:\
     FOR f=1 TO 4:\
     LET a(f)=INT (RND *6)+1:\
     NEXT f:\
     FOR h=1 TO 3:\
     FOR g=h+1 TO 4:\
     LET p=p+(a(h)=a(g)):\
     NEXT g:\
     NEXT h:\
     LET z=(p=0):\
     NEXT z:\
     FOR z=1 TO 10:\
     INPUT "ENTER "; LINE b$:\
     FOR f=1 TO 4:\
     LET b(f)=VAL b$(f):\
     NEXT f:\
     LET d=0:\
     LET c=0:\
     FOR f=1 TO 4:\
     FOR g=1 TO 4:\
     LET c=c+(a(f)=b(g)):\
     NEXT g:\
     LET d=d+(a(f)=b(f)):\
     NEXT f:\
     PRINT AT z,0;b$,"oooo"( TO c-d);"####"( TO d);AT z,21;"GUESSES=";z:\
     IF d<4 THEN NEXT z:\
     PRINT '"THE WORD WAS:";a(1);a(2);a(3);a(4)
   9 RETURN
  10 DATA 0,0,"",10,11,"\::\::\::",0,0,"",3,13,"\::\::\::",4,15,"\::",5,15,"O",6,14,"\::\::\::",7,15,"\::",8,14,"\::",8,16,"\::":\
     LET e=0:\
     LET q$="":\
     LET s=0:\
     INPUT "Guessword="; LINE a$:\
     LET l=LEN a$:\
     DIM b(l):\
     FOR a=1 TO 99:\
     LET p=0:\
     RESTORE :\
     FOR w=0 TO s:\
     READ x,y,v$:\
     NEXT w:\
     PRINT AT 19,0;("DEAD,word="+a$ AND s=9)+("Right!" AND e=l);AT 16,0;"used letters=";q$;AT x,y;v$:\
     FOR f=3 TO 9:\
     PRINT AT f,12;"\::" AND s=2:\
     NEXT f:\
     FOR f=1 TO l:\
     PRINT AT 0,f;CHR$ b(f):\
     NEXT f:\
     IF s<>9 AND e<>l THEN LET e=0:\
     INPUT "letter="; LINE x$:\
     FOR f=1 TO l:\
     LET b(f)=b(f)+(CODE x$ AND x$=a$(f) AND b(f)=0):\
     LET p=p+(x$<>a$(f)):\
     LET e=e+SGN b(f):\
     NEXT f:\
     LET s=s+(p=l):\
     LET q$=q$+x$:\
     NEXT a
  11 RETURN
  12 DIM a$(32):\
     DIM b$(32,4):\
     FOR h=130 TO 161:\
     FOR f=0 TO 1:\
     LET x=RND *31+1:\
     LET f=a$(x)=" ":\
     NEXT f:\
     LET a$(x)=CHR$ (h/2.01):\
     NEXT h:\
     INPUT "PLAYERS?";p:\
     DIM s(p):\
     DIM c$(p,9):\
     FOR f=1 TO p:\
     INPUT "NAME";c$(f):\
     NEXT f:\
     LET u=1:\
     FOR f=1 TO 32:\
     LET b$(f)=STR$ f:\
     NEXT f:\
     FOR w=1 TO 16:\
     FOR f=1 TO 32:\
     PRINT b$(f);:\
     NEXT f:\
     PRINT c$(u):\
     DIM n(2):\
     FOR q=1 TO 2:\
     INPUT "FIELD";n(q):\
     LET y=INT (n(q)/8.3):\
     PRINT AT y,(n(q)-8*y-1)*4;a$(n(q));" ":\
     NEXT q:\
     LET e=(a$(n(1))=a$(n(2)))-(n(1)=n(2)):\
     LET s(u)=s(u)+e:\
     FOR b=1 TO 2:\
     LET v$=b$(n(b)):\
     LET b$(n(b))=" ":\
     LET b$(n(b))=v$ AND e=0:\
     NEXT b:\
     LET u=u-e:\
     LET u=u*(u<p)+1:\
     LET w=w-(e=0):\
     PAUSE H:\
     CLS :\
     NEXT w:\
     FOR f=1 TO p:\
     PRINT c$(f);s(f);" POINTS":\
     NEXT f
  13 RETURN
  14 LET l=100:\
     LET p=0:\
     DIM a$(32):\
     CLS :\
     FOR f=0 TO 2:\
     PRINT AT 15,13;"<\::\::\::>";AT 16+f,14;"\ :\::\: ";AT 20-f,0; INVERSE 1; INK 1;a$:\
     NEXT f:\
     FOR f=0 TO 1:\
     LET x=15+SGN (INT (RND *5)-2)*(INT (RND *12)+3):\
     FOR h=2 TO 20-(x=15)*6:\
     PRINT AT h,x;"O":\
     LET b$=INKEY$ :\
     PLOT 124,51:\
     LET k=((b$="0")-(b$="1"))*(l>0):\
     DRAW k*124,0:\
     PLOT 124+k*18,51:\
     DRAW OVER 1;k*106,0:\
     LET m=ATTR (h+1,x)=57:\
     PRINT AT h+m,x;" ";AT h,x;" ";AT 0,20;"LASERS=";l;" ":\
     LET h=h+m*130+200*((b$="0")*(x>15)*(h=15)+(b$="1")*(x<15)*(h=15))*(l>0):\
     LET l=l-(b$<>"")*(l>0)*5:\
     NEXT h:\
     LET p=p+(h>200):\
     LET f=(h=21):\
     LET l=l+((x=15)+m)*5:\
     PRINT AT 0,0;"SCORE=";p:\
     NEXT f:\
     FOR f=0 TO 30:\
     PLOT 127,0:\
     DRAW INK RND *6;RND *120*SGN (f-15),RND *120:\
     NEXT f
  15 RETURN
  16 POKE 23658,0:\
     LET s=0:\
     FOR f=1 TO 6:\
     PRINT AT 0,f*5-2;"QWERTY"(f);AT 3*f+1,0;f:\
     PLOT 0,f*25:\
     DRAW 255,0:\
     PLOT 255-40*f,0:\
     DRAW 0,175:\
     NEXT f:\
     FOR f=0 TO 9:\
     LET a=0:\
     FOR g=0 TO 1:\
     LET x=INT (RND *6)+1:\
     LET y=INT (RND *6)+1:\
     LET g=ATTR (y*3+1,x*5-2)=56:\
     NEXT g:\
     PRINT AT y*3+1,x*5-2; FLASH 1;"\::":\
     FOR p=1 TO INT ((RND *5)+1)*8:\
     BEEP .05,10:\
     BEEP .05,5:\
     LET k$=INKEY$ :\
     LET a=a+(a=0)*(k$="qwerty"(x))+(a=1)*(STR$ y=k$):\
     LET p=p+50*(a=2):\
     NEXT p:\
     PRINT AT y*3+1,x*5-2; INVERSE (a<2); INK (a<2);" ":\
     LET f=f-(a=2):\
     LET s=s+(a=2):\
     NEXT f:\
     PRINT AT 21,0;"FINAL SCORE=";s
  17 RETURN
  18 CLS :\
     LET p=0:\
     LET a=15:\
     LET b=15:\
     PLOT 6,6:\
     DRAW 243,0:\
     DRAW 0,106:\
     DRAW -243,0:\
     DRAW 0,-106:\
     FOR g=0 TO 4:\
     LET y=INT (RND *13)+8:\
     LET x=INT (RND *30)+1:\
     PRINT AT y,x;"*":\
     FOR t=25 TO 1 STEP -1:\
     PRINT AT a,b;"o";AT 6,1;"TIME=";t;" ";AT 6,10;"MISSES=";g;AT 6,20;"SCORE=";p;AT a,b;" ":\
     LET b$=INKEY$ :\
     LET a=a+(b$="6")*(a<20)-(b$="7")*(a>8):\
     LET b=b+(b$="8")*(b<30)-(b$="5")*(b>1):\
     LET n=(a=y)*(b=x):\
     LET p=p+n*t:\
     LET t=t-50*n:\
     NEXT t:\
     PRINT AT y,x;" ":\
     BEEP (n=0)*.5,20:\
     BEEP (n=0),10:\
     LET g=g-n:\
     NEXT g
  19 RETURN
  20 LET p=0:\
     LET a=5:\
     CLS :\
     PLOT 0,7:\
     DRAW 247,0:\
     PLOT 80,7:\
     DRAW 0,41:\
     DRAW 87,0:\
     DRAW 0,-41:\
     PLOT 0,7:\
     DRAW 0,41:\
     DRAW 82,82:\
     DRAW 84,0:\
     DRAW 82,-82:\
     DRAW 0,-41:\
     FOR m=0 TO 2:\
     LET x=INT (RND *9)+21:\
     LET y=21:\
     FOR g=1 TO 5:\
     LET y=y-1:\
     FOR h=1 TO 5:\
     PRINT AT y,x;"*";AT 20,1;"         ";AT 20,a;"^":\
     LET b$=INKEY$ :\
     FOR f=1 TO 2*(b$="7"):\
     OVER f-1:\
     PLOT 8*a+3,13:\
     DRAW 0,(36+a*8)*(b$="7"):\
     DRAW (242-16*a)*(b$="7"),0:\
     DRAW 0,(-37-a*8)*(b$="7"):\
     NEXT f:\
     OVER 0:\
     LET a=a+(b$="8")*(a<9)-(b$="5")*(a>1):\
     LET p=p+(a=30-x)*(b$="7"):\
     LET h=h+(a=30-x)*(b$="7")*99:\
     NEXT h:\
     PRINT AT 0,0;"SCORE=";p;AT y,x;" ";AT 0,20;"MISSES=";m:\
     LET g=g+(h>50)*9:\
     NEXT g:\
     LET m=m-(g>8):\
     BEEP g<8,0:\
     NEXT m
  21 RETURN
  22 DIM m(12,12):\
     FOR f=0 TO 9:\
     LET z=RND *10+1.5:\
     LET y=RND *10+1.5:\
     LET x=m(z,y)<9:\
     LET m(z,y)=9:\
     FOR n=z-x TO z+x:\
     FOR k=y-x TO y+x:\
     LET m(n,k)=m(n,k)+x:\
     NEXT k:\
     NEXT n:\
     LET f=f-1+x:\
     NEXT f:\
     LET y=1:\
     CLS :\
     FOR g=1 TO f:\
     PRINT AT g,1;"\::\::\::\::\::\::\::\::\::\::":\
     NEXT g:\
     FOR p=1 TO f:\
     FOR h=0 TO 1:\
     PRINT AT y,x; OVER 1;"\::":\
     PAUSE h:\
     LET k$=INKEY$ :\
     NEXT h:\
     LET x=x+(k$="8")*(x<10)-(k$="5")*(x>1):\
     LET y=y+(k$="6")*(y<10)-(k$="7")*(y>1):\
     LET h=3*((k$="9")+(k$="0"))-1:\
     NEXT h:\
     LET z=(k$="0"):\
     LET l=m(x+1,y+1):\
     LET l=(l>8)*9+(l<9)*l:\
     PRINT AT 13,1;"Mines=";p-z;AT y,x; INVERSE 1;"x.12345678+"(z*(l+1)+1):\
     LET p=p-(l<9)+50*z*(l>8):\
     NEXT p:\
     PRINT AT 15,1;"Mine free" AND p<40;"Dead" AND p>40
  23 RETURN
  24 LET S=0:\
     LET A$="":\
     FOR F=0 TO 9999:\
     LET A$=A$+"1234"(RND *4+.5):\
     LET Z=LEN A$:\
     FOR G=1 TO 25:\
     NEXT G:\
     FOR G=1 TO Z:\
     LET R=VAL A$(G):\
     PRINT AT 9+R*2,7;R;" =>"; INK R;" \::":\
     BEEP .6,R:\
     PRINT AT 9+R*2,9;"  ":\
     NEXT G:\
     FOR G=1 TO Z:\
     FOR H=0 TO 1:\
     LET K=CODE INKEY$ :\
     LET H=(K<53)*(K>48):\
     NEXT H:\
     LET K=K-48:\
     LET R=VAL A$(G):\
     IF K=R THEN LET S=S+1:\
     PRINT AT 0,0;"SCORE=";S;AT 9+R*2,9;"=>":\
     BEEP .6,R:\
     PRINT AT 9+R*2,9;"  ":\
     NEXT G:\
     FOR H=0 TO 7:\
     BORDER H:\
     NEXT H:\
     NEXT F
  25 RETURN
  26 BORDER 0:\
     CLS :\
     LET x$=" ":\
     LET x=9:\
     LET y=9:\
     LET d$="8":\
     FOR f=1 TO 100:\
     FOR h=0 TO 1:\
     LET a=INT (RND *22):\
     LET b=INT (RND *32):\
     LET h=SCREEN$ (a,b)=" ":\
     NEXT h:\
     PRINT AT A,B;"*":\
     FOR h=0 TO 1:\
     PRINT AT y,x;"o":\
     LET x$(F*2-1)=CHR$ x:\
     LET x$=x$+CHR$ Y+" ":\
     LET k$=INKEY$ :\
     LET k$=K$+D$:\
     LET x=x+(k$(1)="8")*(x<31)-(k$(1)="5")*(x>0):\
     LET y=y+(k$(1)="6")*(y<21)-(k$(1)="7")*(y>0):\
     LET d$(1)=k$:\
     LET m=SCREEN$ (y,x)="o":\
     LET h=(a=y)*(b=x)+m:\
     PRINT AT CODE X$(2),CODE x$(1);" " AND h=0:\
     LET Y$=X$:\
     LET x$=x$(3 TO ):\
     NEXT h:\
     BORDER 7*m:\
     IF M=0 THEN LET X$=Y$:\
     PRINT #1;AT 0,0;"Score=";f:\
     NEXT f:\
     PRINT #1;AT 1,3;"The snake is fullgrown!":\
     PAUSE 0:\
     BORDER 7
  27 RETURN
  28 LET s=0:\
     DIM c$(32):\
     LET a$=c$:\
     LET b$=a$:\
     FOR f=1 TO 4:\
     LET l=INT (RND *7)*4+1:\
     LET p=INT (RND *4)*7+1:\
     LET f=f-(a$(p)<>" "):\
     LET b$(l TO l+2)="<=>":\
     LET a$(p TO p+2)="<=>":\
     NEXT f:\
     FOR h=0 TO 2:\
     PRINT AT 0,0;"SCORE=";s,"FROGS DEAD=";h:\
     LET x=15:\
     LET y=5:\
     FOR f=0 TO 1:\
     PRINT AT 5,0;c$; PAPER 6;a$;b$;a$;b$:\
     PRINT c$; PAPER 6;b$;a$;b$;a$:\
     LET f=SCREEN$ (y,x)<>" ":\
     PRINT AT y,x;"o":\
     LET k$=INKEY$ :\
     LET y=y+(k$="6")*(y<15)-(k$="7")*(y>6):\
     LET x=x+(k$="8")*(x<31)-(k$="5")*(x>0):\
     LET b$=b$(32)+b$( TO 31):\
     LET a$=a$(2 TO )+a$(1):\
     NEXT f:\
     LET s=s+(y=15):\
     LET h=h-(y=15):\
     BEEP (y<15),0:\
     BEEP (y<15),5:\
     PRINT AT y,x;" ":\
     NEXT h
  29 RETURN
  30 LET q=0:\
     LET x=90:\
     DIM l(x):\
     FOR f=1 TO x:\
     LET l(f)=f:\
     NEXT f:\
     INPUT "Number players (<=6):";r:\
     DIM z(r,15):\
     FOR h=1 TO r:\
     FOR i=1 TO 15:\
     LET y=INT (RND *x)+1:\
     LET z(h,i)=l(y):\
     LET l(y)=l(x):\
     LET l(x)=z(h,i):\
     LET x=x-1:\
     NEXT i:\
     NEXT h:\
     LET y=0:\
     FOR f=0 TO 89:\
     FOR h=1 TO r:\
     PRINT AT h*3-3,0;"player ";h;":   ";:\
     LET k=0:\
     LET m=1:\
     FOR i=1 TO 15:\
     LET n=z(h,i)<>y:\
     LET m=m*n:\
     LET z(h,i)=z(h,i)*n:\
     LET l=z(h,i):\
     PRINT (" " AND l<10)+STR$ l+"  " AND l;:\
     LET k=k+l:\
     NEXT i:\
     PRINT "    ":\
     LET q=q+(k=0)*h:\
     LET h=h+(m=0)*9:\
     NEXT h:\
     LET v=INT (RND *(90-f))+1:\
     LET y=l(v):\
     LET l(v)=l(90-f):\
     LET l(90-f)=y:\
     INPUT "The "+STR$ (f+1)+"th nr.="+STR$ y AND q=0;"Winner="+STR$ q AND q; LINE k$:\
     IF q=0 THEN NEXT f
  31 RETURN
  32 CLS :\
     LET s=0:\
     DIM a$(11,11):\
     LET a$(1)="\::\::\::\::\::\::\::\::\::\::\::":\
     FOR d=1 TO 1:\
     LET y=6:\
     FOR x=1 TO 5:\
     LET a$(x*2)="\::.........\::":\
     LET a$(x*2+1)="\::.\::\::\::.\::\::\::.\::":\
     NEXT x:\
     LET A$(2,3)="\::":\
     LET a$(5,6)="\::":\
     LET r=8:\
     FOR q=1 TO 10:\
     PRINT AT q,1;a$(q):\
     NEXT q:\
     LET a$(q)=a$(1):\
     FOR b=0 TO 54:\
     LET k=CODE INKEY$ -48:\
     LET t=y:\
     LET z=(k=6)-(k=7):\
     LET y=y+z*(a$(y+z,x)<"\::"):\
     LET z=(k=8)-(k=5):\
     LET x=x+z*(a$(y,x+z)<"\::"):\
     LET z=SGN (y-q):\
     LET m=q:\
     LET q=q+z*(a$(q+z,r)<"\::"):\
     LET d=d+(SGN (x-r)-d)*((m<>q)+(q*r=24)+(q*r=8)):\
     LET r=r+d*(a$(q,r+d)<"\::")*(m=q):\
     PRINT AT m,1;a$(m);AT t,1;a$(t);AT y,x;"\@";AT q,r;"A";AT 12,1;s+b:\
     LET b=b+99*(q=y)*(x=r)-(a$(y,x)=" "):\
     LET a$(y,x)=" ":\
     NEXT b:\
     LET s=s+b:\
     LET d=b>60:\
     NEXT d
  33 RETURN
  34 LET a$=" ONMLKJIHGFEDCBA":\
     LET x=1:\
     LET y=0:\
     FOR f=0 TO 4:\
     FOR g=1 TO 4:\
     PLOT 12,172-f*16:\
     DRAW 64,0:\
     PLOT 12+f*16,172:\
     DRAW 0,-64:\
     NEXT g:\
     NEXT f:\
     FOR p=0 TO 1:\
     FOR f=0 TO 3:\
     FOR g=1 TO 4:\
     PRINT AT 1+f*2,g*2;a$(f*4+g):\
     NEXT g:\
     NEXT f:\
     LET p=a$="ABCDEFGHIJKLMNO ":\
     PAUSE p:\
     LET k$=INKEY$ :\
     LET q=y:\
     LET r=x:\
     LET y=y-(k$="6")*(y>0)+(k$="7")*(y<3):\
     LET x=x-(k$="8")*(x>1)+(k$="5")*(x<4):\
     LET a$(q*4+r)=a$(y*4+x):\
     LET a$(y*4+x)=" ":\
     LET p=p+(k$=" "):\
     NEXT p
  35 RETURN
  36 DIM d(3):\
     PRINT AT 20,5;"1         2          3":\
     LET a$="\::\::\::\::\::\::\::\::\::\::\::\::":\
     LET d(3)=9:\
     LET d(2)=9:\
     LET d(1)=4:\
     DIM a(3,10):\
     FOR f=1 TO 5:\
     LET a(1,10-f)=6-f:\
     NEXT f:\
     FOR j=0 TO 1:\
     FOR f=1 TO 9:\
     LET j=j+a(3,f):\
     NEXT f:\
     LET j=j=16:\
     FOR f=1 TO 9:\
     FOR s=1 TO 3:\
     PRINT AT 9+f,(s-1)*11-(s>1);"     \::     ";AT 9+f,s*11-a(s,f)-6-(s>1); INK 4*(A(S,F)/2=INT (A(S,F)/2));a$( TO 2*a(s,f)+1):\
     NEXT s:\
     NEXT f:\
     IF j=0 THEN INPUT "From ";v:\
     INPUT "To ";n:\
     LET h=(d(v)<9)*((a(n,d(n)+1)=0)+(a(n,d(n)+1)>a(v,d(v)+1))):\
     LET a(n,d(n))=a(n,d(n))*(h=0)+a(v,d(v)+1)*h:\
     LET a(v,d(v)+1)=a(v,d(v)+1)*(h=0):\
     LET d(v)=d(v)+h:\
     LET d(n)=d(n)-h:\
     NEXT j
  37 RETURN
  38 CLS :\
     DIM a$(22,9):\
     LET s=0:\
     FOR g=1 TO 10:\
     LET l=0:\
     FOR x=2 TO 5:\
     LET a$(x,x TO 10-x)="o o o o"( TO 11-x-x):\
     NEXT x:\
     FOR j=0 TO 1:\
     LET e=0:\
     FOR x=1 TO 5:\
     PRINT AT x,0;a$(x):\
     NEXT x:\
     LET y=20:\
     LET d=.4:\
     FOR f=0 TO 1:\
     LET x=x+d:\
     PRINT AT y,x-1;" O ":\
     LET d=d-2*d*(ABS (x-4)>3):\
     LET f=INKEY$ ="7":\
     NEXT f:\
     FOR f=0 TO 1:\
     LET k=CODE INKEY$ :\
     LET y=y-(y>1):\
     LET x=x+(y>1)*e*(x>.4)*(x<7.5):\
     PRINT AT y,x;"O"'a$(y+1):\
     LET e=e+.9*(e=0)*((k=56)-(k=53)):\
     LET m=x+1:\
     LET r=y:\
     FOR z=1 TO a$(r,m)="o":\
     LET l=l+(a$(r,m)="o"):\
     LET a$(r,m)=" ":\
     LET r=r-1:\
     LET m=m-e:\
     LET z=r<1:\
     NEXT z:\
     LET f=y*k=54:\
     NEXT f:\
     LET j=j+(l>9):\
     NEXT j:\
     LET s=s+l+(l>9)*(50-j*15):\
     PRINT AT 1,12;"Throw=";g+(g<10);", Score=";s:\
     NEXT g
  39 RETURN
  40 LET s=0:\
     FOR g=10 TO 18:\
     CLS :\
     LET a=15:\
     LET b=100:\
     INK 1:\
     PLOT b,8:\
     DRAW 0,100:\
     PLOT 180,8:\
     DRAW 0,100:\
     POKE 23692,0:\
     LET d=10:\
     FOR f=0 TO 130:\
     LET x=8*SGN (INT (RND *3)-1):\
     LET m=d:\
     LET d=d-(f/20=INT (f/20)):\
     INK 1:\
     PLOT b,8:\
     LET c=b:\
     LET b=b+x*(b+x>0)*(b+x<180):\
     LET x=x*(b<>c):\
     DRAW x,-8:\
     PLOT c+d*8+8*(m>d),8:\
     DRAW x-8*(m>d),-8:\
     INK 0:\
     LET c=a:\
     LET a=a+(INKEY$ ="8")-(INKEY$ ="5"):\
     LET l=ATTR (g+1,a)=56:\
     PRINT AT g,c;" ";AT 21,0''AT g,a; OVER 1;"V":\
     FOR v=1 TO 1-l:\
     PRINT AT 0,0;"Score=";s+f,"Level=";g-9:\
     NEXT v:\
     IF l THEN NEXT f:\
     LET s=s+f:\
     PRINT AT 9,0;"The next level awaits <ENTER>" :\
     INPUT LINE k$:\
     NEXT g:\
     PRINT AT 10,0;"All levels done, Score=";s
  41 RETURN
  42 CLS :\
     LET y=10:\
     LET x=y:\
     LET q=20:\
     LET p=1:\
     FOR f=0 TO 1:\
     LET b=IN 63486:\
     LET a=IN 61438:\
     LET v=64*(a<200):\
     LET b=b+v-250:\
     LET a=a+v-250:\
     LET q=q-(b=3)*(q=20)-(q<20)*(q>0)+20*(q=0):\
     LET p=p+(a=3)*(p=1)+(p>1)*(p<21)-20*(p=21):\
     LET y=y+(y<29)*(a=4)-(y>2)*(a=1):\
     LET x=x+(x<29)*(b=1)-(x>2)*(b=4):\
     PRINT AT q+1,x-1;"   " AND q<20;AT p-1,y-1;"   " AND p>1;AT 0,y-2;" \''\::\'' ";AT 21,x-2;" \..\::\.. ";AT q,x-1;" o " AND q>0;AT p,y-1;" o " AND p<21:\
     LET f=((q=0)+(p=21))*(ABS (x-y)<=1):\
     NEXT f:\
     PRINT AT 10,5;"The winner is : ";"UP" AND p=21;"DOWN" AND q=0
  43 RETURN
  44 DIM d(22,22):\
     FOR f=2 TO 21:\
     LET d(1,f)=3:\
     LET d(f,1)=5:\
     LET d(f,22)=1:\
     LET d(22,f)=1:\
     NEXT f:\
     LET d(1,1)=7:\
     LET d(RND *20+2,1)=7:\
     LET d(2,2)=1:\
     FOR y=2 TO 21:\
     FOR x=2 TO 21:\
     PRINT AT 0,0;y,x;" ":\
     LET a=y:\
     LET b=x:\
     FOR f=1 TO d(y+1,x)*d(y,x-1)*d(y,x+1)*d(y-1,x)=0:\
     LET p=SGN (RND *2-(a>2)-(a=21))*INT (RND *2):\
     LET q=SGN (RND *2-(b>2)-(b=21))*(p=0):\
     FOR h=1 TO d(a+p,b+q)=0:\
     LET d(a,b)=d(a,b)+2*(q=1)+4*(p=1):\
     LET a=a+p:\
     LET b=b+q:\
     LET d(a,b)=1+4*(p=-1)+2*(q=-1):\
     NEXT h:\
     LET f=d(a+1,b)*d(a-1,b)*d(a,b+1)*d(a,b-1)>0:\
     NEXT f:\
     LET x=x-(f=2):\
     NEXT x:\
     NEXT y:\
     LET h=RND *20+2:\
     LET d(h,21)=d(h,21)+2:\
     CLS :\
     FOR k=1 TO 21:\
     FOR l=1 TO 21:\
     PRINT AT k,l;"\.:\:.\..\':\ : \ ."(d(k,l)):\
     NEXT l:\
     NEXT k:\
     INPUT "PRESS ENTER";K$
  45 RETURN
  46 CLS :\
     FOR j=1 TO 9:\
     DIM a$(30):\
     LET c=-1:\
     FOR y=29 TO 6 STEP c:\
     LET a$(y)="\\/++/\\-|+"(RND *9+.5):\
     NEXT y:\
     FOR x=1 TO 5:\
     PRINT AT x,1;a$(x*5+1 TO x*5+5);"    -"(x):\
     NEXT x:\
     LET a=5:\
     LET b=5:\
     LET d=0:\
     FOR f=1 TO 1:\
     LET s=CODE SCREEN$ (y,x):\
     FOR g=1 TO 20:\
     LET k=CODE INKEY$ -48:\
     LET r=b:\
     LET t=a:\
     LET a=a-(k=8)*(a>1)+(k=5)*(a<5):\
     LET b=b+(k=7)*(b<5)-(k=6)*(b>1):\
     LET h=(a=x)*(b=y):\
     LET a=a+(t-a)*h:\
     LET b=b+(r-b)*h:\
     LET a$(r*5+t)=a$(b*5+a):\
     LET a$(b*5+a)=" ":\
     PRINT AT b,a;" ";AT 1,9;j;AT r,t;a$(r*5+t);AT y,x; OVER 1;"O":\
     NEXT g:\
     LET h=d:\
     LET d=d*((s=43)+(s=124))+c*((s=92)-(s=47)):\
     LET c=c*((s=43)+(s=45))+h*((s=92)-(s=47)):\
     LET y=y+d:\
     LET x=x+c:\
     IF d+c THEN LET f=(y=5)*(x=6):\
     NEXT f:\
     NEXT j
  47 RETURN
  48 CLS :\
     LET s=0:\
     LET a$="*   *   *   *   *   *   *   *   ":\
     FOR f=0 TO 7:\
     PRINT AT 10,0;a$;AT 21,15;"^":\
     FOR g=1 TO INKEY$ ="7":\
     LET f=f+(a$(16)="*"):\
     LET s=s+1:\
     OVER 1:\
     FOR h=0 TO 1:\
     PLOT 123,8:\
     DRAW 0,100:\
     NEXT h:\
     OVER 0:\
     LET a$(16)=" ":\
     NEXT g:\
     LET a$=a$(2 TO )+a$(1):\
     LET f=f-1:\
     NEXT f:\
     PRINT AT 0,0;"Hitratio=";INT (8/s*10000)/100
  49 RETURN
  50 CLS :\
     LET s=0:\
     LET t=99:\
     DIM a$(3):\
     FOR c=1 TO 1:\
     FOR a=1 TO 10:\
     FOR f=1 TO 3:\
     LET a$(f)=STR$ (RND *6+1):\
     NEXT f:\
     FOR b=1 TO 29:\
     PRINT AT a,b-1;" ";:\
     FOR g=1 TO 3:\
     PRINT PAPER VAL a$(g);" ";:\
     NEXT g:\
     LET a$=a$(2-(INKEY$ <>"0") TO )+a$(1):\
     LET b=b+99*(ATTR (a,b+3)<56):\
     NEXT b:\
     LET b=b-1-99*(b>90):\
     LET t=b*(b<t)+t*(b>=t):\
     FOR h=a-1 TO a:\
     LET w=s:\
     FOR m=t TO 31:\
     LET l=ATTR (h,m):\
     LET l=(l<56)*((l=ATTR (h+1,m))+2*(l=ATTR (h,m-1))):\
     FOR j=1 TO l>0:\
     LET s=s+10:\
     FOR q=m TO t STEP -1:\
     PRINT AT 12,0;"Score=";s;TAB 22;"^";AT h,q; PAPER ATTR (h,q-1-(l>1))/8;" ";AT h+1,q; PAPER ATTR (h+1,q-1)/8;" " AND l=1:\
     NEXT q:\
     PRINT AT h,q;" ":\
     NEXT j:\
     NEXT m:\
     LET h=h*(s=w):\
     NEXT h:\
     NEXT a:\
     LET c=t<22:\
     NEXT c
  51 RETURN
  52 LET i=6:\
     LET s=0:\
     LET q=1:\
     DIM o(33):\
     LET n=i:\
     DIM s(33):\
     DIM h(33):\
     DIM m(33):\
     FOR g=1 TO 33:\
     LET h(g)=-20:\
     LET m(g)=-h(g)*.8:\
     NEXT g:\
     FOR h=0 TO 1:\
     FOR f=1 TO n:\
     LET h(f)=h(f)+(m(f)>h(f))*SGN ((h(f)<m(f))-.5):\
     FOR g=1 TO m(f)<=h(f):\
     LET s(f)=s(f)+1:\
     LET m(f)=INT (m(f)*.8):\
     LET h(f)=-h(f):\
     NEXT g:\
     LET t=20-ABS h(f):\
     PRINT AT o(f),f;" ";AT t,f;s(f):\
     LET o(f)=t:\
     FOR g=1 TO (h(f)=0)*(q=f):\
     LET m(f)=20:\
     LET s=s+s(f):\
     PRINT #1;AT 0,0;"SCORE=";s:\
     LET s(f)=0:\
     LET n=INT (s/100)+i:\
     NEXT g:\
     LET h=2*((m(f)=0)+(h>1)):\
     LET k$=INKEY$ :\
     LET q=q+(k$="8")*(q<30)-(k$="5")*(q>1):\
     PRINT AT 21,q-1;" \:: ":\
     NEXT f:\
     NEXT h
  53 RETURN
  54 LET p=0:\
     LET a=15:\
     FOR F=0 TO 2:\
     LET x=INT (RND *22):\
     FOR h=0 TO 21:\
     CLS :\
     PRINT AT h,x;"o";AT 21,a;"U":\
     LET a=a+(INKEY$ ="8")*(a<30)-(INKEY$ ="5")*(a>0):\
     NEXT h:\
     BEEP (x<>a),0:\
     LET p=p+(a=x):\
     LET f=f-(a=x):\
     NEXT F:\
     PRINT AT 0,0;"FINAL SCORE=";p
  55 RETURN
  56 POKE 23658,8:\
     LET A$="ABCDEFGHIJKLMNOP":\
     LET B$=A$:\
     FOR F=1 TO 16:\
     LET X=RND *16+.5:\
     LET Y=RND *16+.5:\
     LET K$=A$(X):\
     LET A$(X)=A$(Y):\
     LET A$(Y)=K$:\
     NEXT F:\
     CLS :\
     FOR F=0 TO 1:\
     LET F=A$=B$:\
     FOR G=1 TO 4:\
     PRINT AT 9,14;"efgh";AT 10+G,12;CHR$ (g+96);" ";A$(G*4-3 TO G*4);" ";CHR$ (g+104);AT 16,14;"mnop":\
     NEXT G:\
     PAUSE F:\
     LET K=CODE INKEY$ -64:\
     LET n=(k>8)*(k<13):\
     LET m=(k>12)*(k<17):\
     LET k=k-(m+n)*8:\
     FOR G=1 TO 2*n+(K<5)*(K>0):\
     LET A$(K*4-3 TO K*4)=A$(K*4-2 TO K*4)+A$(K*4-3):\
     NEXT G:\
     FOR G=1 TO 2*m+(K>4)*(K<9):\
     LET K$=A$(K-4):\
     FOR H=0 TO 2:\
     LET A$(K+H*4-4)=A$(K+H*4):\
     NEXT H:\
     LET A$(K+8)=K$:\
     NEXT G:\
     NEXT F
  57 RETURN
  58 LET d=1:\
     LET y=10:\
     LET x=15:\
     LET n=0:\
     LET m=0:\
     LET a=7:\
     LET b=20:\
     FOR j=0 TO 9e9:\
     LET q=INT (RND *19)+1:\
     LET w=INT (RND *30)+1:\
     FOR f=0 TO 1:\
     CLS :\
     PRINT AT q,w;"*";AT a,b;"O";AT m,x;"|";AT 21-m,x;"|";AT y,n;"-";AT y,31-n;"-";AT y,0;">";AT y,31;"<";AT 0,x;"v";AT 21,x;"^";#0;AT 1,0;"Score=";j:\
     LET n=n+SGN (n+(a=y))-16*(n=15):\
     LET m=m+SGN (m+(b=x))-12*(m=11):\
     LET x=x+SGN (b-x)*(m=0):\
     LET y=y+SGN (a-y)*(n=0):\
     LET f=SCREEN$ (a,b)<>"O":\
     IF 1-f THEN LET k$=("Q" AND d)+INKEY$ :\
     LET d=1-d:\
     LET a=a+(k$="6")*(a<20)-(k$="7")*(a>1):\
     LET b=b+(k$="8")*(b<30)-(k$="5")*(b>1):\
     LET f=(a=q)*(b=w):\
     NEXT f:\
     NEXT j
  59 RETURN
9999 RETURN
