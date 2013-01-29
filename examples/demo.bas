# (for Emacs) -*- indented-text -*-

# this file `demo.bas' demonstrates the features of zmakebas
# (basically just the escape sequences), and gives you an example of
# what the input can look like if you use all the bells and whistles. :-)
#
# See `demolbl.bas' for a label-using version.


10 rem zmakebas demo

# tabs (as below) are fine (they're removed)
20 let init=	1000:\
   let header=	2000:\
   let udgdem=	3000:\
   let blockdem=4000

auto 10

30 gosub init
40 gosub header
50 gosub udgdem
60 gosub blockdem
70 stop


# init

1000 for f=usr "a"+7 to usr "u"+7 step 8
1010 poke f,255
1020 next f
1030 let is48=1

# init all attrs just in case
1040 border 7:paper 7:ink 7:bright 0:flash 0:cls

# check for 48k speccy or 48k mode. This is a pretty nasty way to do
# it, but seems to be the most sane way (from Basic at least).
1050 print "\t"
1060 if screen$(0,0)="S" then let is48=0
1070 ink 0:print at 0,0;
1090 return


# header

2000 print ink 5;"\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..";\
	         "\..\..\..\..\..\..\..\..\..\..\..\..\..\..\.."
2010 print paper 5;"  Non-ASCII chars in zmakebas  "
2020 print ink 5;"\''\''\''\''\''\''\''\''\''\''\''\''\''\''\''\''";\
	         "\''\''\''\''\''\''\''\''\''\''\''\''\''\''\''"
2030 print
2040 return


# udgdem

3000 print "Here are the UDGs:"''
3010 print ink 1;"\a\b\c\d\e\f\g\h\i\j\k\l\m\n\o\p\q\r\s";
3020 if is48 then print ink 1;"\t\u";
3030 print ''"(They should be underlined.)"
3040 return


# blockdem

#                   01234567890123456789012345678901
4000 print at 11,0;"The block graphics, first as"'\
		   "listed by a for..next loop, then"'\
		   "via zmakebas's escape sequences:"
4010 ink 7
4020 print at 15,0;
4030 for f=128 to 143:print chr$(f);" ";:next f:print ''
4040 print at 17,0;"\   \ ' \'  \'' \ . \ : \'. \': ";\
		   "\.  \.' \:  \:' \.. \.: \:. \::"
# draw boxes around them to make it look less confusing
4050 ink 1
4060 for y=0 to 1
4070 for x=0 to 15
4080 plot x*16,55-y*16:draw 7,0:draw 0,-7:draw -7,0:draw 0,7
4090 next x
4100 next y
4110 ink 0
4120 print at 20,0;"And finally here's the copyright"'\
		   "symbol (";ink 1;"\*";ink 0;\
		   ") and pound sign (";ink 1;"`";ink 0;")."
4130 return
