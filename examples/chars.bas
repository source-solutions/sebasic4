Auto 0

# Run-time Variables

Var addr: Num = 65359
Var ptr: Num = 1
Var a: NumArray(8) = 2, 3, 1, 3, 1, 1, 3, 2
Var f: NumFOR = 6, 8, 1, 85, 2
Var g: NumFOR = 4, 3, 1, 20, 4
Var b$: Str = "MPETALRL"
Var a$: StrArray(8, 3) = "FMSELPEAONRTATFLDZINRELG"

# End Run-time Variables

   1 REM fast
   5 LET addr=32000
  10 DIM a$(8,3)
  20 FOR f=1 TO 8:\
     READ b$:\
     FOR g=1 TO 3:\
     LET a$(f,g)=b$(g):\
     NEXT g:\
     NEXT f
  30 DATA "FMS","ELP","EAO","NRT","ATF","LDZ","INR","ELG"
  40 DIM a(8):\
     FOR f=1 TO 8:\
     LET a(f)=1:\
     NEXT f
  50 LET ptr=1
  55 GO SUB 80
  60 IF a(ptr)<3 THEN LET a(ptr)=a(ptr)+1:\
     GO SUB 80:\
     LET ptr=1:\
     GO TO 60
  70 LET a(ptr)=1:\
     LET ptr=ptr+1:\
     GO TO 60
  80 LET b$=a$(1,a(1))+a$(2,a(2))+a$(3,a(3))+a$(4,a(4))+a$(5,a(5))+a$(6,a(6))+a$(7,a(7))+a$(8,a(8))
  85 FOR f=1 TO LEN (b$):\
     POKE addr,CODE (b$(f)):\
     LET addr=addr+1:\
     NEXT f:\
     POKE addr, 13:\
     LET addr=addr+1
  86 PRINT AT 0,0;b$
  90 RETURN
