 10 'Chloe 280SE Boot Menu (c) 2022 Source Solutions, Inc.
 20 cls
 30 print "Welcome to the Chloe 280SE 512K Personal Color Computer"
 40 print
 50 print "Choose from the following options:"
 60 print
 70 print "Animation demos:        A) BOING ","B) JUGGLER","C) KAYAHARA"''
 80 print "DMA demos:              D) AARDMAN","E) BADAPPLE","F) TAKEONME"''
 90 print "Emulator:               G) TC2048"''
100 print "Grahpics demos:         H) SCRSHOW","I) VDPTEST"''
110 print "Music demos:            J) LASTV8","K) SKYFALL"''
120 print "Exit:                   X) BASIC"
130 input a$
140 if a$="A" then run "boing"
150 if a$="B" then run "juggler"
160 if a$="C" then run "kayahara"
170 if a$="D" then run "aardman"
180 if a$="E" then run "badapple"
190 if a$="F" then run "takeonme"
200 if a$="G" then run "tc2048"
210 if a$="H" then run "scrshow"
220 if a$="I" then run "vdptest"
230 if a$="J" then run "lastv8"
240 if a$="K" then run "skyfall"
250 if a$="X" then new
260 goto 130
