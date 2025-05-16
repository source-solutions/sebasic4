10 REM RIFF File Format Demo
20 REM This program demonstrates creating and reading RIFF files
30 REM
40 PRINT "RIFF File Format Demo"
50 PRINT "====================="
60 PRINT
70 PRINT "1. Create a RIFF file"
80 PRINT "2. Read a RIFF file"
90 PRINT "3. Exit"
100 PRINT
110 INPUT "Select option (1-3): ";O
120 IF O<1 OR O>3 THEN GOTO 110
130 ON O GOTO 200, 500, 900

200 REM Create a RIFF file
210 PRINT
220 PRINT "Creating a RIFF file..."
230 PRINT
240 INPUT "Enter filename: ";F$
250 REM Use CALL to access SE/OS API for RIFF operations
260 REM Call SERIFFCreate to create a RIFF file with WAVE type
270 CALL USR(27, 0) REM Initialize system variables
280 POKE 23867, ASC("W")
290 POKE 23868, ASC("A")
300 POKE 23869, ASC("V")
310 POKE 23870, ASC("E")
320 CALL USR(29, @F$) REM Create RIFF file with WAVE type
330 IF USR(28) = 0 THEN GOTO 400
340 PRINT "Error creating RIFF file!"
350 GOTO 100

400 REM File created successfully, now add fmt and data chunks
410 REM Add fmt chunk with PCM format (16-bit, 44100Hz, stereo)
420 REM Initialize fmt chunk data
430 LET H = USR(28) REM Get file handle from last operation
440 REM Format data: PCM, 2 channels, 44100Hz, 176400 bytes/sec, 4 bytes/sample, 16 bits
450 POKE 23880, 1: POKE 23881, 0 REM Format = PCM (1)
460 POKE 23882, 2: POKE 23883, 0 REM Channels = 2 (stereo)
470 POKE 23884, 68: POKE 23885, 172: POKE 23886, 0: POKE 23887, 0 REM Sample rate = 44100
480 POKE 23888, 16: POKE 23889, 177: POKE 23890, 2: POKE 23891, 0 REM Bytes/sec = 176400
490 POKE 23892, 4: POKE 23893, 0 REM Block align = 4
500 POKE 23894, 16: POKE 23895, 0 REM Bits/sample = 16
510 REM Call SERIFFWriteChunk to write fmt chunk
520 POKE 23867, ASC("f")
530 POKE 23868, ASC("m")
540 POKE 23869, ASC("t")
550 POKE 23870, ASC(" ")
560 CALL USR(30, H, 23880, 16) REM Write fmt chunk
570 IF USR(28) = 0 THEN GOTO 600
580 PRINT "Error writing fmt chunk!"
590 GOTO 100

600 REM Add data chunk with some simple sample data
610 REM Generate a simple sine wave (one period, 100 samples)
620 FOR I = 0 TO 199
630   LET V = INT(32000 * SIN(I/32))
640   POKE 23880+I, V AND 255
650   POKE 23881+I, (V/256) AND 255
660 NEXT I
670 REM Call SERIFFWriteChunk to write data chunk
680 POKE 23867, ASC("d")
690 POKE 23868, ASC("a")
700 POKE 23869, ASC("t")
700 POKE 23870, ASC("a")
710 CALL USR(30, H, 23880, 200) REM Write data chunk
720 IF USR(28) = 0 THEN GOTO 750
730 PRINT "Error writing data chunk!"
740 GOTO 100

750 REM Close the file
760 CALL USR(1, H)
770 PRINT "RIFF file created successfully!"
780 GOTO 100

500 REM Read a RIFF file
510 PRINT
520 PRINT "Reading a RIFF file..."
530 PRINT
540 INPUT "Enter filename: ";F$
550 REM Call SERIFFOpen to open and validate the RIFF file
560 CALL USR(27, 0) REM Initialize system variables
570 CALL USR(27, @F$) REM Open RIFF file
580 IF USR(28) = 0 THEN GOTO 600
590 PRINT "Error opening file or not a valid RIFF file!"
595 GOTO 100

600 REM File opened successfully, now read chunks
610 LET H = USR(28) REM Get file handle
620 PRINT "RIFF file opened successfully!"
630 PRINT

640 REM Read fmt chunk
650 POKE 23867, ASC("f")
660 POKE 23868, ASC("m")
670 POKE 23869, ASC("t")
680 POKE 23870, ASC(" ")
690 CALL USR(28, H, 23880, 23867) REM Read fmt chunk
700 IF USR(28) <> 0 THEN PRINT "fmt chunk not found!": GOTO 800
710 LET S = USR(29) REM Get size from last operation
720 PRINT "Format type: ";PEEK(23880) + 256*PEEK(23881)
730 PRINT "Channels: ";PEEK(23882) + 256*PEEK(23883)
740 PRINT "Sample rate: ";PEEK(23884) + 256*PEEK(23885) + 65536*PEEK(23886) + 16777216*PEEK(23887)
750 PRINT "Bits per sample: ";PEEK(23894) + 256*PEEK(23895)
760 PRINT

800 REM Read data chunk size
810 POKE 23867, ASC("d")
820 POKE 23868, ASC("a")
830 POKE 23869, ASC("t")
840 POKE 23870, ASC("a")
850 CALL USR(28, H, 23880, 23867) REM Read data chunk header only
860 IF USR(28) <> 0 THEN PRINT "data chunk not found!": GOTO 880
870 LET S = USR(29) REM Get size from last operation
880 PRINT "Data size: ";S;" bytes"

890 REM Close the file
900 CALL USR(1, H)
910 GOTO 100

900 REM Exit program
910 PRINT
920 PRINT "Exiting..."
930 END