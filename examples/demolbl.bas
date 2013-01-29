# (for Emacs) -*- indented-text -*-

# this is a label-using version of `demo.bas', which shows how much
# nicer it is not to have to deal with line numbers. :-)

auto @Start

@Start:
   rem zmakebas demo

   gosub @init
   gosub @header
   gosub @udgdem
   gosub @blockdem
   stop


@init:
   for f=usr "a"+7 to usr "u"+7 step 8
   poke f,255
   next f
   let is48=1

# init all attrs just in case
   border 7:paper 7:ink 7:bright 0:flash 0:cls

# check for 48k speccy or 48k mode. This is a pretty nasty way to do
# it, but seems to be the most sane way (from Basic at least).
   print "\t"
   if screen$(0,0)="S" then let is48=0
   ink 0:print at 0,0;
   return

@header:
   print "\{i5}\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..";\
              "\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\{i0}"
   print "\{p5}  Non-ASCII chars in zmakebas  \{p7}"
   print "\{i5}\''\''\''\''\''\''\''\''\''\''\''\''\''\''\''\''";\
	      "\''\''\''\''\''\''\''\''\''\''\''\''\''\''\''\{i0}"
   print
   return


@udgdem:
   print "Here are the UDGs:"''
   print ink 1;"\a\b\c\d\e\f\g\h\i\j\k\l\m\n\o\p\q\r\s";
   if is48 then print ink 1;"\t\u";
   print ''"(They should be underlined.)"
   return


@blockdem:
   print at 11,0;"The block graphics, first as"'\
	         "listed by a for..next loop, then"'\
	         "via zmakebas's escape sequences:"
   ink 0
   print at 15,0;
   for f=128 to 143:print chr$(f);" ";:next f:print ''
   print at 17,0;"\{i0p7}\   \{i1}\ ' \{i2}\'  \{i3}\'' \{i4}\ . \{i5p0}\ :\{p7} \{i6p0}\'.\{p7} \{i7p0}\':\{p7} ";\
 	         "\{i7p0}\. \{p7} \{i6p0}\.'\{p7} \{i5p0}\: \{p7} \{i4p7}\:' \{i3}\.. \{i2}\.: \{i1}\:. \{i0}\::"
# draw boxes around them to make it look less confusing
   ink 8
   for y=0 to 1
   for x=0 to 15
   plot x*16,55-y*16:draw 7,0:draw 0,-7:draw -7,0:draw 0,7
   next x
   next y
   ink 0
   print at 20,0;"And finally here's the copyright"'\
	         "symbol (";ink 1;"\*";ink 0;\
	         ") and pound sign (";ink 1;"`";ink 0;")."
   return
