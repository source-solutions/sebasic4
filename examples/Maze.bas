	Auto 0

	CLS 
@GenMaze:
	DIM d(22,32)
	FOR f=2 TO 31
		LET d(1,f)=3
		LET d(22,f)=1
	NEXT f
	FOR f=2 TO 21
		LET d(f,1)=5
		LET d(f,32)=1
	NEXT f
	LET d(1,1)=7
	LET d(RND *20+2,1)=7
	LET d(2,2)=1
	FOR y=2 TO 21
		FOR x=2 TO 31
			PRINT AT 0,0;y,x;" "
			LET a=y
			LET b=x
			FOR f=1 TO d(y+1,x)*d(y,x-1)*d(y,x+1)*d(y-1,x)=0
				LET p=SGN (RND *2-(a>2)-(a=21))*INT (RND *2)
				LET q=SGN (RND *2-(b>2)-(b=31))*(p=0)
				FOR h=1 TO d(a+p,b+q)=0
					LET d(a,b)=d(a,b)+2*(q=1)+4*(p=1)
					LET a=a+p
					LET b=b+q
					LET d(a,b)=1+4*(p=-1)+2*(q=-1)
				NEXT h
				LET f=d(a+1,b)*d(a-1,b)*d(a,b+1)*d(a,b-1)>0
			NEXT f
			LET x=x-(f=2)
		NEXT x
	NEXT y
	LET h=RND *20+2
	LET d(h,31)=d(h,31)+2

@DrawMaze:
	CLS
	FOR k=1 TO 21
		FOR l=1 TO 31
			PRINT AT k,l;"\.:\:.\..\':\ : \ ."(d(k,l))
		NEXT l
	NEXT k
