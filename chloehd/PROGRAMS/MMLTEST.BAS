10 REM Standard MML Test Suite
20 REM Copyright (c) 2024 Source Solutions, Inc.
30 REM 
40 REM This test suite verifies the Standard MML implementation
50 REM in SE BASIC.
60 REM
70 REM Usage: LOAD "MMLTEST.BAS" : RUN
80 REM
90 GOSUB 9000 : REM Initialize test framework
100 CLS
110 PRINT "Standard MML Test Suite"
120 PRINT "======================="
130 PRINT
140 GOSUB 1000 : REM Run basic MML tests
150 GOSUB 2000 : REM Run note length tests
160 GOSUB 3000 : REM Run accidental tests
170 GOSUB 4000 : REM Run dotted note tests
180 GOSUB 5000 : REM Run repeat and tempo tests
190 GOSUB 6000 : REM Run multi-voice tests
200 GOSUB 9500 : REM Print summary
210 END

1000 REM Basic MML tests
1010 PRINT "Basic MML Tests:"
1020 PRINT "---------------"
1030 TOTAL% = 0 : PASSED% = 0
1040 REM Test basic notes
1050 GOSUB 9100 : REM Test case
1060 DESC$ = "Basic notes (a-g)" : EXPECT% = 1 : ACTUAL% = 1
1070 ON ERROR GOTO 1090
1080 PLAY "c d e f g a b" : GOTO 1100
1090 ACTUAL% = 0 : RESUME 1100
1100 GOSUB 9200 : REM Validate result
1110 REM Test octave switching
1120 GOSUB 9100 : REM Test case
1130 DESC$ = "Uppercase notes (C-G)" : EXPECT% = 1 : ACTUAL% = 1
1140 ON ERROR GOTO 1160
1150 PLAY "C D E F G A B" : GOTO 1170
1160 ACTUAL% = 0 : RESUME 1170
1170 GOSUB 9200 : REM Validate result
1180 GOSUB 9100 : REM Test case
1190 DESC$ = "Octave command (o)" : EXPECT% = 1 : ACTUAL% = 1
1200 ON ERROR GOTO 1220
1210 PLAY "o3 c o4 c o5 c" : GOTO 1230
1220 ACTUAL% = 0 : RESUME 1230
1230 GOSUB 9200 : REM Validate result
1240 GOSUB 9100 : REM Test case
1250 DESC$ = "Octave up/down (>/<)" : EXPECT% = 1 : ACTUAL% = 1
1260 ON ERROR GOTO 1280
1270 PLAY "c > c < c" : GOTO 1290
1280 ACTUAL% = 0 : RESUME 1290
1290 GOSUB 9200 : REM Validate result
1300 GOSUB 9100 : REM Test case
1310 DESC$ = "Rest (r)" : EXPECT% = 1 : ACTUAL% = 1
1320 ON ERROR GOTO 1340
1330 PLAY "c r c r c" : GOTO 1350
1340 ACTUAL% = 0 : RESUME 1350
1350 GOSUB 9200 : REM Validate result
1360 GOSUB 9300 : REM Save section results
1370 RETURN

2000 REM Note length tests
2010 PRINT "Note Length Tests:"
2020 PRINT "-----------------"
2030 TOTAL% = 0 : PASSED% = 0
2040 REM Test default length setting
2050 GOSUB 9100 : REM Test case
2060 DESC$ = "Default length (l)" : EXPECT% = 1 : ACTUAL% = 1
2070 ON ERROR GOTO 2090
2080 PLAY "l4 c d e f" : GOTO 2100
2090 ACTUAL% = 0 : RESUME 2100
2100 GOSUB 9200 : REM Validate result
2110 REM Test individual note lengths
2120 GOSUB 9100 : REM Test case
2130 DESC$ = "Individual note lengths" : EXPECT% = 1 : ACTUAL% = 1
2140 ON ERROR GOTO 2160
2150 PLAY "c4 d8 e2 f1" : GOTO 2170
2160 ACTUAL% = 0 : RESUME 2170
2170 GOSUB 9200 : REM Validate result
2180 REM Test mixed length specification
2190 GOSUB 9100 : REM Test case
2200 DESC$ = "Mixed length specification" : EXPECT% = 1 : ACTUAL% = 1
2210 ON ERROR GOTO 2230
2220 PLAY "l8 c d e l4 f g a" : GOTO 2240
2230 ACTUAL% = 0 : RESUME 2240
2240 GOSUB 9200 : REM Validate result
2250 REM Test individual lengths override default
2260 GOSUB 9100 : REM Test case
2270 DESC$ = "Individual lengths override default" : EXPECT% = 1 : ACTUAL% = 1
2280 ON ERROR GOTO 2300
2290 PLAY "l2 c4 d e8 f" : GOTO 2310
2300 ACTUAL% = 0 : RESUME 2310
2310 GOSUB 9200 : REM Validate result
2320 GOSUB 9300 : REM Save section results
2330 RETURN

3000 REM Accidental tests
3010 PRINT "Accidental Tests:"
3020 PRINT "----------------"
3030 TOTAL% = 0 : PASSED% = 0
3040 REM Test sharp notes
3050 GOSUB 9100 : REM Test case
3060 DESC$ = "Sharp notes (#)" : EXPECT% = 1 : ACTUAL% = 1
3070 ON ERROR GOTO 3090
3080 PLAY "c c# d d# e" : GOTO 3100
3090 ACTUAL% = 0 : RESUME 3100
3100 GOSUB 9200 : REM Validate result
3110 REM Test flat notes
3120 GOSUB 9100 : REM Test case
3130 DESC$ = "Flat notes (-)" : EXPECT% = 1 : ACTUAL% = 1
3140 ON ERROR GOTO 3160
3150 PLAY "c b- a- g-" : GOTO 3170
3160 ACTUAL% = 0 : RESUME 3170
3170 GOSUB 9200 : REM Validate result
3180 REM Test alternate sharp symbol
3190 GOSUB 9100 : REM Test case
3200 DESC$ = "Alternate sharp (+)" : EXPECT% = 1 : ACTUAL% = 1
3210 ON ERROR GOTO 3230
3220 PLAY "c c+ d d+" : GOTO 3240
3230 ACTUAL% = 0 : RESUME 3240
3240 GOSUB 9200 : REM Validate result
3250 REM Test accidentals with lengths
3260 GOSUB 9100 : REM Test case
3270 DESC$ = "Accidentals with lengths" : EXPECT% = 1 : ACTUAL% = 1
3280 ON ERROR GOTO 3300
3290 PLAY "c#4 d-8 e+2" : GOTO 3310
3300 ACTUAL% = 0 : RESUME 3310
3310 GOSUB 9200 : REM Validate result
3320 REM Test tied notes with accidentals
3330 GOSUB 9100 : REM Test case
3340 DESC$ = "Tied notes with accidentals" : EXPECT% = 1 : ACTUAL% = 1
3350 ON ERROR GOTO 3370
3360 PLAY "c#&c# d-&d-" : GOTO 3380
3370 ACTUAL% = 0 : RESUME 3380
3380 GOSUB 9200 : REM Validate result
3390 GOSUB 9300 : REM Save section results
3400 RETURN

4000 REM Dotted note tests
4010 PRINT "Dotted Note Tests:"
4020 PRINT "-----------------"
4030 TOTAL% = 0 : PASSED% = 0
4040 REM Test basic dotted notes
4050 GOSUB 9100 : REM Test case
4060 DESC$ = "Basic dotted notes" : EXPECT% = 1 : ACTUAL% = 1
4070 ON ERROR GOTO 4090
4080 PLAY "c. d. e." : GOTO 4100
4090 ACTUAL% = 0 : RESUME 4100
4100 GOSUB 9200 : REM Validate result
4110 REM Test dotted notes with lengths
4120 GOSUB 9100 : REM Test case
4130 DESC$ = "Dotted notes with lengths" : EXPECT% = 1 : ACTUAL% = 1
4140 ON ERROR GOTO 4160
4150 PLAY "c4. d8. e2." : GOTO 4170
4160 ACTUAL% = 0 : RESUME 4170
4170 GOSUB 9200 : REM Validate result
4180 REM Test dotted notes with accidentals
4190 GOSUB 9100 : REM Test case
4200 DESC$ = "Dotted notes with accidentals" : EXPECT% = 1 : ACTUAL% = 1
4210 ON ERROR GOTO 4230
4220 PLAY "c#. d-. e+." : GOTO 4240
4230 ACTUAL% = 0 : RESUME 4240
4240 GOSUB 9200 : REM Validate result
4250 REM Test complex combination
4260 GOSUB 9100 : REM Test case
4270 DESC$ = "Complex combination" : EXPECT% = 1 : ACTUAL% = 1
4280 ON ERROR GOTO 4300
4290 PLAY "c#4. d-8. e+2." : GOTO 4310
4300 ACTUAL% = 0 : RESUME 4310
4310 GOSUB 9200 : REM Validate result
4320 GOSUB 9300 : REM Save section results
4330 RETURN

5000 REM Repeat and tempo tests
5010 PRINT "Repeat and Tempo Tests:"
5020 PRINT "---------------------"
5030 TOTAL% = 0 : PASSED% = 0
5040 REM Test basic repeats
5050 GOSUB 9100 : REM Test case
5060 DESC$ = "Basic repeats" : EXPECT% = 1 : ACTUAL% = 1
5070 ON ERROR GOTO 5090
5080 PLAY "[c d e]" : GOTO 5100
5090 ACTUAL% = 0 : RESUME 5100
5100 GOSUB 9200 : REM Validate result
5110 REM Test nested repeats
5120 GOSUB 9100 : REM Test case
5130 DESC$ = "Nested repeats" : EXPECT% = 1 : ACTUAL% = 1
5140 ON ERROR GOTO 5160
5150 PLAY "[c [d e] f]" : GOTO 5170
5160 ACTUAL% = 0 : RESUME 5170
5170 GOSUB 9200 : REM Validate result
5180 REM Test tempo changes
5190 GOSUB 9100 : REM Test case
5200 DESC$ = "Tempo changes" : EXPECT% = 1 : ACTUAL% = 1
5210 ON ERROR GOTO 5230
5220 PLAY "t120 c d t160 e f" : GOTO 5240
5230 ACTUAL% = 0 : RESUME 5240
5240 GOSUB 9200 : REM Validate result
5250 REM Test tempo with repeats
5260 GOSUB 9100 : REM Test case
5270 DESC$ = "Tempo with repeats" : EXPECT% = 1 : ACTUAL% = 1
5280 ON ERROR GOTO 5300
5290 PLAY "t100 [c d] t120 [e f]" : GOTO 5310
5300 ACTUAL% = 0 : RESUME 5310
5310 GOSUB 9200 : REM Validate result
5320 REM Test volume changes
5330 GOSUB 9100 : REM Test case
5340 DESC$ = "Volume changes" : EXPECT% = 1 : ACTUAL% = 1
5350 ON ERROR GOTO 5370
5360 PLAY "v15 c v10 d v5 e v1 f" : GOTO 5380
5370 ACTUAL% = 0 : RESUME 5380
5380 GOSUB 9200 : REM Validate result
5390 GOSUB 9300 : REM Save section results
5400 RETURN

6000 REM Multi-voice tests
6010 PRINT "Multi-voice Tests:"
6020 PRINT "-----------------"
6030 TOTAL% = 0 : PASSED% = 0
6040 REM Test two voices
6050 GOSUB 9100 : REM Test case
6060 DESC$ = "Two voices" : EXPECT% = 1 : ACTUAL% = 1
6070 ON ERROR GOTO 6090
6080 PLAY "c e g", "e g >c" : GOTO 6100
6090 ACTUAL% = 0 : RESUME 6100
6100 GOSUB 9200 : REM Validate result
6110 REM Test three voices
6120 GOSUB 9100 : REM Test case
6130 DESC$ = "Three voices" : EXPECT% = 1 : ACTUAL% = 1
6140 ON ERROR GOTO 6160
6150 PLAY "c e g", "e g >c", "g >c e" : GOTO 6170
6160 ACTUAL% = 0 : RESUME 6170
6170 GOSUB 9200 : REM Validate result
6180 REM Test with different lengths
6190 GOSUB 9100 : REM Test case
6200 DESC$ = "Different lengths" : EXPECT% = 1 : ACTUAL% = 1
6210 ON ERROR GOTO 6230
6220 PLAY "l4 c d e f", "l8 c c d d e e f f" : GOTO 6240
6230 ACTUAL% = 0 : RESUME 6240
6240 GOSUB 9200 : REM Validate result
6250 REM Test with different tempos
6260 GOSUB 9100 : REM Test case
6270 DESC$ = "Different tempos" : EXPECT% = 1 : ACTUAL% = 1
6280 ON ERROR GOTO 6300
6290 PLAY "t120 c d e f", "t120 g a b >c" : GOTO 6310
6300 ACTUAL% = 0 : RESUME 6310
6310 GOSUB 9200 : REM Validate result
6320 GOSUB 9300 : REM Save section results
6330 RETURN

9000 REM Test framework initialization
9010 GLOBAL_TOTAL% = 0
9020 GLOBAL_PASSED% = 0
9030 SECTIONS% = 0
9040 SEC_TOTAL% = 0
9050 SEC_PASSED% = 0
9060 DIM SEC_NAME$(6)
9070 DIM SEC_TOTAL%(6)
9080 DIM SEC_PASSED%(6)
9090 RETURN

9100 REM Test case setup
9110 TOTAL% = TOTAL% + 1
9120 RETURN

9200 REM Validate numeric result
9210 IF ACTUAL% = EXPECT% THEN PASSED% = PASSED% + 1 : RESULT$ = "PASS" ELSE RESULT$ = "FAIL"
9220 PRINT "  [";RESULT$;"] "; DESC$; " ("; ACTUAL%; " = "; EXPECT%; ")"
9230 RETURN

9300 REM Save section results
9310 SECTIONS% = SECTIONS% + 1
9320 SEC_NAME$(SECTIONS%) = MID$(DESC$, 1, INSTR(DESC$, " ")-1)
9330 IF SEC_NAME$(SECTIONS%) = "" THEN SEC_NAME$(SECTIONS%) = "Section " + STR$(SECTIONS%)
9340 SEC_TOTAL%(SECTIONS%) = TOTAL%
9350 SEC_PASSED%(SECTIONS%) = PASSED%
9360 GLOBAL_TOTAL% = GLOBAL_TOTAL% + TOTAL%
9370 GLOBAL_PASSED% = GLOBAL_PASSED% + PASSED%
9380 PRINT "  -> Results: "; PASSED%; "/"; TOTAL%; " tests passed (";
9390 IF TOTAL% > 0 THEN PRINT INT(PASSED% * 100 / TOTAL%); ELSE PRINT "0";
9400 PRINT "%)"
9410 PRINT
9420 RETURN

9500 REM Print summary
9510 PRINT "Test Summary:"
9520 PRINT "============="
9530 FOR I = 1 TO SECTIONS%
9540   PRINT SEC_NAME$(I); " Tests: "; SEC_PASSED%(I); "/"; SEC_TOTAL%(I); " (";
9550   IF SEC_TOTAL%(I) > 0 THEN PRINT INT(SEC_PASSED%(I) * 100 / SEC_TOTAL%(I)); ELSE PRINT "0";
9560   PRINT "%)"
9570 NEXT I
9580 PRINT "-------------"
9590 PRINT "Overall: "; GLOBAL_PASSED%; "/"; GLOBAL_TOTAL%; " (";
9600 IF GLOBAL_TOTAL% > 0 THEN PRINT INT(GLOBAL_PASSED% * 100 / GLOBAL_TOTAL%); ELSE PRINT "0";
9610 PRINT "%)"
9620 RETURN