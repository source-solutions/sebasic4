Auto 0

# Run-time Variables

Var x: Num = 23
Var y: Num = 21
Var score: Num = 48
Var ox: Num = 23
Var oy: Num = 21

# End Run-time Variables

  10 LET score=0
  20 LET x=10: LET y=10
  30 LET ox=1: LET oy=1
  40 PRINT AT 0,0;"Score:";score
  50 PRINT AT oy,ox;"\.'\':\:'\'.";AT oy+1,ox;"\'.  \.'"
  60 PRINT AT y,x;" \..  ";AT y+1,x;"\''\''\''\''"
  70 LET y=y-(INKEY$ ="q")
  80 LET y=y+(INKEY$ ="a")
  90 LET x=x+(INKEY$ ="p")
 100 LET x=x-(INKEY$ ="o")
 101 PAUSE 5
 102 LET score=score+1
 105 PRINT AT oy,ox;"    ";AT oy+1,ox;"  \   "
 110 IF x<ox THEN LET ox=ox-1
 120 IF x>ox THEN LET ox=ox+1
 130 IF y<oy THEN LET oy=oy-1
 140 IF y>oy THEN LET oy=oy+1
 150 GO TO 40
