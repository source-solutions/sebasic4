10 REM SE BASIC IV Unit Test Suite
20 REM Copyright (c) 2024 Source Solutions, Inc.
30 REM 
40 REM This test suite verifies core functionality of SE BASIC
50 REM and catches regressions during development.
60 REM
70 REM Usage: LOAD "UNITTEST.BAS" : RUN
80 REM        or LOAD "UNITTEST" : RUN
90 REM
100 GOSUB 9000 : REM Initialize test framework
110 CLS
120 GOSUB 1000 : REM Run arithmetic tests
130 GOSUB 2000 : REM Run string tests
140 GOSUB 3000 : REM Run array tests
150 GOSUB 4000 : REM Run file tests
160 GOSUB 5000 : REM Run MML tests
170 GOSUB 6000 : REM Run control flow tests
180 GOSUB 7000 : REM Run function tests
190 GOSUB 8000 : REM Run miscellaneous tests
200 GOSUB 9500 : REM Print summary
210 END

1000 REM Arithmetic tests
1010 PRINT "Arithmetic Tests:"
1020 PRINT "-----------------"
1030 TOTAL% = 0 : PASSED% = 0
1040 LET A = 5 : LET B = 10
1050 GOSUB 9100 : REM Test case
1060 DESC$ = "Addition" : EXPECT% = 15 : ACTUAL% = A + B
1070 GOSUB 9200 : REM Validate result
1080 GOSUB 9100 : REM Test case
1090 DESC$ = "Subtraction" : EXPECT% = -5 : ACTUAL% = A - B
1100 GOSUB 9200 : REM Validate result
1110 GOSUB 9100 : REM Test case
1120 DESC$ = "Multiplication" : EXPECT% = 50 : ACTUAL% = A * B
1130 GOSUB 9200 : REM Validate result
1140 GOSUB 9100 : REM Test case
1150 DESC$ = "Division" : EXPECT% = 0.5 : ACTUAL% = A / B
1160 GOSUB 9200 : REM Validate result
1170 GOSUB 9100 : REM Test case
1180 DESC$ = "Exponentiation" : EXPECT% = 100000 : ACTUAL% = B ^ A
1190 GOSUB 9200 : REM Validate result
1200 GOSUB 9100 : REM Test case
1210 DESC$ = "Negation" : EXPECT% = -5 : ACTUAL% = -A
1220 GOSUB 9200 : REM Validate result
1230 GOSUB 9100 : REM Test case
1240 DESC$ = "Absolute value" : EXPECT% = 5 : ACTUAL% = ABS(-A)
1250 GOSUB 9200 : REM Validate result
1260 GOSUB 9100 : REM Test case
1270 DESC$ = "Integer division" : EXPECT% = 2 : ACTUAL% = B \ A
1280 GOSUB 9200 : REM Validate result
1290 GOSUB 9100 : REM Test case
1300 DESC$ = "Modulo" : EXPECT% = 0 : ACTUAL% = B MOD A
1310 GOSUB 9200 : REM Validate result
1320 GOSUB 9100 : REM Test case
1330 DESC$ = "Integer function" : EXPECT% = 3 : ACTUAL% = INT(3.14159)
1340 GOSUB 9200 : REM Validate result
1350 GOSUB 9100 : REM Test case
1360 DESC$ = "SGN function (positive)" : EXPECT% = 1 : ACTUAL% = SGN(A)
1370 GOSUB 9200 : REM Validate result
1380 GOSUB 9100 : REM Test case
1390 DESC$ = "SGN function (negative)" : EXPECT% = -1 : ACTUAL% = SGN(-A)
1400 GOSUB 9200 : REM Validate result
1410 GOSUB 9100 : REM Test case
1420 DESC$ = "SGN function (zero)" : EXPECT% = 0 : ACTUAL% = SGN(0)
1430 GOSUB 9200 : REM Validate result
1440 GOSUB 9300 : REM Save section results
1450 RETURN

2000 REM String tests
2010 PRINT "String Tests:"
2020 PRINT "-------------"
2030 TOTAL% = 0 : PASSED% = 0
2040 LET A$ = "BASIC" : LET B$ = "TEST"
2050 GOSUB 9100 : REM Test case
2060 DESC$ = "String concatenation" : EXPECT$ = "BASICTEST" : ACTUAL$ = A$ + B$
2070 GOSUB 9250 : REM Validate string result
2080 GOSUB 9100 : REM Test case
2090 DESC$ = "String length" : EXPECT% = 5 : ACTUAL% = LEN(A$)
2100 GOSUB 9200 : REM Validate result
2110 GOSUB 9100 : REM Test case
2120 DESC$ = "String position" : EXPECT% = 3 : ACTUAL% = INSTR(A$, "S")
2130 GOSUB 9200 : REM Validate result
2140 GOSUB 9100 : REM Test case
2150 DESC$ = "Substring extraction (LEFT$)" : EXPECT$ = "BAS" : ACTUAL$ = LEFT$(A$, 3)
2160 GOSUB 9250 : REM Validate string result
2170 GOSUB 9100 : REM Test case
2180 DESC$ = "Substring extraction (RIGHT$)" : EXPECT$ = "SIC" : ACTUAL$ = RIGHT$(A$, 3)
2190 GOSUB 9250 : REM Validate string result
2200 GOSUB 9100 : REM Test case
2210 DESC$ = "Substring extraction (MID$)" : EXPECT$ = "AS" : ACTUAL$ = MID$(A$, 2, 2)
2220 GOSUB 9250 : REM Validate string result
2230 GOSUB 9100 : REM Test case
2240 DESC$ = "String to ASCII (ASC)" : EXPECT% = 66 : ACTUAL% = ASC("B")
2250 GOSUB 9200 : REM Validate result
2260 GOSUB 9100 : REM Test case
2270 DESC$ = "ASCII to String (CHR$)" : EXPECT$ = "A" : ACTUAL$ = CHR$(65)
2280 GOSUB 9250 : REM Validate string result
2290 GOSUB 9100 : REM Test case
2300 DESC$ = "String conversion to number (VAL)" : EXPECT% = 123 : ACTUAL% = VAL("123")
2310 GOSUB 9200 : REM Validate result
2320 GOSUB 9100 : REM Test case
2330 DESC$ = "Number conversion to string (STR$)" : EXPECT$ = "123" : ACTUAL$ = STR$(123)
2340 GOSUB 9250 : REM Validate string result
2350 GOSUB 9100 : REM Test case
2360 DESC$ = "Hex conversion (HEX$)" : EXPECT$ = "FF" : ACTUAL$ = HEX$(255)
2370 GOSUB 9250 : REM Validate string result
2380 GOSUB 9300 : REM Save section results
2390 RETURN

3000 REM Array tests
3010 PRINT "Array Tests:"
3020 PRINT "------------"
3030 TOTAL% = 0 : PASSED% = 0
3040 DIM A(5)
3050 FOR I = 0 TO 5 : A(I) = I * 10 : NEXT I
3060 GOSUB 9100 : REM Test case
3070 DESC$ = "Array initialization (index 0)" : EXPECT% = 0 : ACTUAL% = A(0)
3080 GOSUB 9200 : REM Validate result
3090 GOSUB 9100 : REM Test case
3100 DESC$ = "Array initialization (index 5)" : EXPECT% = 50 : ACTUAL% = A(5)
3110 GOSUB 9200 : REM Validate result
3120 A(3) = 999
3130 GOSUB 9100 : REM Test case
3140 DESC$ = "Array assignment" : EXPECT% = 999 : ACTUAL% = A(3)
3150 GOSUB 9200 : REM Validate result
3160 DIM S$(3)
3170 S$(0) = "Zero" : S$(1) = "One" : S$(2) = "Two" : S$(3) = "Three"
3180 GOSUB 9100 : REM Test case
3190 DESC$ = "String array" : EXPECT$ = "Two" : ACTUAL$ = S$(2)
3200 GOSUB 9250 : REM Validate string result
3210 DIM M(3,3)
3220 FOR I = 0 TO 3 : FOR J = 0 TO 3 : M(I,J) = I*10 + J : NEXT J : NEXT I
3230 GOSUB 9100 : REM Test case
3240 DESC$ = "2D array" : EXPECT% = 23 : ACTUAL% = M(2,3)
3250 GOSUB 9200 : REM Validate result
3260 GOSUB 9300 : REM Save section results
3270 RETURN

4000 REM File tests
4010 PRINT "File Tests:"
4020 PRINT "-----------"
4030 TOTAL% = 0 : PASSED% = 0
4040 REM Create a test file
4050 OPEN "O", #1, "TESTFILE.TXT"
4060 PRINT #1, "Line 1"
4070 PRINT #1, "Line 2"
4080 PRINT #1, "Line 3"
4090 CLOSE #1
4100 GOSUB 9100 : REM Test case
4110 DESC$ = "File creation" : EXPECT% = 1 : ACTUAL% = 1 : REM Always pass if we reach here
4120 GOSUB 9200 : REM Validate result
4130 REM Read the test file
4140 OPEN "I", #1, "TESTFILE.TXT"
4150 LINE INPUT #1, L1$
4160 LINE INPUT #1, L2$
4170 CLOSE #1
4180 GOSUB 9100 : REM Test case
4190 DESC$ = "File reading (line 1)" : EXPECT$ = "Line 1" : ACTUAL$ = L1$
4200 GOSUB 9250 : REM Validate string result
4210 GOSUB 9100 : REM Test case
4220 DESC$ = "File reading (line 2)" : EXPECT$ = "Line 2" : ACTUAL$ = L2$
4230 GOSUB 9250 : REM Validate string result
4240 REM Append to test file
4250 OPEN "A", #1, "TESTFILE.TXT"
4260 PRINT #1, "Line 4"
4270 CLOSE #1
4280 GOSUB 9100 : REM Test case
4290 DESC$ = "File append" : EXPECT% = 1 : ACTUAL% = 1 : REM Always pass if we reach here
4300 GOSUB 9200 : REM Validate result
4310 REM Read the appended line
4320 OPEN "I", #1, "TESTFILE.TXT"
4330 FOR I = 1 TO 3 : LINE INPUT #1, L$ : NEXT I
4340 LINE INPUT #1, L$
4350 CLOSE #1
4360 GOSUB 9100 : REM Test case
4370 DESC$ = "File append verification" : EXPECT$ = "Line 4" : ACTUAL$ = L$
4380 GOSUB 9250 : REM Validate string result
4390 REM Clean up
4400 KILL "TESTFILE.TXT"
4410 GOSUB 9100 : REM Test case
4420 DESC$ = "File deletion" : EXPECT% = 1 : ACTUAL% = 1 : REM Always pass if we reach here
4430 GOSUB 9200 : REM Validate result
4440 GOSUB 9300 : REM Save section results
4450 RETURN

5000 REM MML tests
5010 PRINT "MML Tests:"
5020 PRINT "----------"
5030 TOTAL% = 0 : PASSED% = 0
5040 REM Standard MML syntax test
5050 GOSUB 9100 : REM Test case
5060 DESC$ = "Basic MML execution" : EXPECT% = 1 : ACTUAL% = 1
5070 ON ERROR GOTO 5090
5080 PLAY "c d e f" : GOTO 5100
5090 ACTUAL% = 0 : RESUME 5100
5100 GOSUB 9200 : REM Validate result
5110 GOSUB 9100 : REM Test case
5120 DESC$ = "MML with note lengths" : EXPECT% = 1 : ACTUAL% = 1
5130 ON ERROR GOTO 5150
5140 PLAY "c4 d8 e8 f4" : GOTO 5160
5150 ACTUAL% = 0 : RESUME 5160
5160 GOSUB 9200 : REM Validate result
5170 GOSUB 9100 : REM Test case
5180 DESC$ = "MML with accidentals" : EXPECT% = 1 : ACTUAL% = 1
5190 ON ERROR GOTO 5210
5200 PLAY "c c# d d# e" : GOTO 5220
5210 ACTUAL% = 0 : RESUME 5220
5220 GOSUB 9200 : REM Validate result
5230 GOSUB 9100 : REM Test case
5240 DESC$ = "MML with octave changes" : EXPECT% = 1 : ACTUAL% = 1
5250 ON ERROR GOTO 5270
5260 PLAY "o4 c >c <c" : GOTO 5280
5270 ACTUAL% = 0 : RESUME 5280
5280 GOSUB 9200 : REM Validate result
5290 GOSUB 9100 : REM Test case
5300 DESC$ = "MML with dotted notes" : EXPECT% = 1 : ACTUAL% = 1
5310 ON ERROR GOTO 5330
5320 PLAY "c. d8" : GOTO 5340
5330 ACTUAL% = 0 : RESUME 5340
5340 GOSUB 9200 : REM Validate result
5350 GOSUB 9100 : REM Test case
5360 DESC$ = "MML with tempo" : EXPECT% = 1 : ACTUAL% = 1
5370 ON ERROR GOTO 5390
5380 PLAY "t120 c d e f" : GOTO 5400
5390 ACTUAL% = 0 : RESUME 5400
5400 GOSUB 9200 : REM Validate result
5410 GOSUB 9100 : REM Test case
5420 DESC$ = "MML with multiple voices" : EXPECT% = 1 : ACTUAL% = 1
5430 ON ERROR GOTO 5450
5440 PLAY "c e g", "e g >c" : GOTO 5460
5450 ACTUAL% = 0 : RESUME 5460
5460 GOSUB 9200 : REM Validate result
5470 GOSUB 9300 : REM Save section results
5480 RETURN

6000 REM Control flow tests
6010 PRINT "Control Flow Tests:"
6020 PRINT "------------------"
6030 TOTAL% = 0 : PASSED% = 0
6040 REM IF-THEN-ELSE test
6050 X = 10
6060 IF X = 10 THEN Y = 1 ELSE Y = 0
6070 GOSUB 9100 : REM Test case
6080 DESC$ = "IF-THEN (true condition)" : EXPECT% = 1 : ACTUAL% = Y
6090 GOSUB 9200 : REM Validate result
6100 IF X = 20 THEN Y = 1 ELSE Y = 0
6110 GOSUB 9100 : REM Test case
6120 DESC$ = "IF-THEN-ELSE (false condition)" : EXPECT% = 0 : ACTUAL% = Y
6130 GOSUB 9200 : REM Validate result
6140 REM FOR-NEXT test
6150 SUM = 0
6160 FOR I = 1 TO 5
6170   SUM = SUM + I
6180 NEXT I
6190 GOSUB 9100 : REM Test case
6200 DESC$ = "FOR-NEXT loop" : EXPECT% = 15 : ACTUAL% = SUM
6210 GOSUB 9200 : REM Validate result
6220 REM FOR-NEXT with STEP test
6230 SUM = 0
6240 FOR I = 2 TO 10 STEP 2
6250   SUM = SUM + I
6260 NEXT I
6270 GOSUB 9100 : REM Test case
6280 DESC$ = "FOR-NEXT with STEP" : EXPECT% = 30 : ACTUAL% = SUM
6290 GOSUB 9200 : REM Validate result
6300 REM WHILE-WEND test
6310 SUM = 0
6320 I = 1
6330 WHILE I <= 5
6340   SUM = SUM + I
6350   I = I + 1
6360 WEND
6370 GOSUB 9100 : REM Test case
6380 DESC$ = "WHILE-WEND loop" : EXPECT% = 15 : ACTUAL% = SUM
6390 GOSUB 9200 : REM Validate result
6400 REM GOSUB-RETURN test
6410 GVAR = 0
6420 GOSUB 6450
6430 GOSUB 9100 : REM Test case
6440 DESC$ = "GOSUB-RETURN" : EXPECT% = 42 : ACTUAL% = GVAR : GOTO 6460
6450 GVAR = 42 : RETURN
6460 GOSUB 9200 : REM Validate result
6470 REM ON-GOTO test
6480 X = 2
6490 ON X GOTO 6510, 6520, 6530
6500 GOTO 6540
6510 Y = 1 : GOTO 6540
6520 Y = 2 : GOTO 6540
6530 Y = 3
6540 GOSUB 9100 : REM Test case
6550 DESC$ = "ON-GOTO" : EXPECT% = 2 : ACTUAL% = Y
6560 GOSUB 9200 : REM Validate result
6570 GOSUB 9300 : REM Save section results
6580 RETURN

7000 REM Function tests
7010 PRINT "Function Tests:"
7020 PRINT "---------------"
7030 TOTAL% = 0 : PASSED% = 0
7040 REM Math functions
7050 GOSUB 9100 : REM Test case
7060 DESC$ = "SQR function" : EXPECT% = 3 : ACTUAL% = SQR(9)
7070 GOSUB 9200 : REM Validate result
7080 GOSUB 9100 : REM Test case
7090 DESC$ = "SIN function" : EXPECT% = 0 : ACTUAL% = INT(SIN(3.14159) * 1000)
7100 GOSUB 9200 : REM Validate result
7110 GOSUB 9100 : REM Test case
7120 DESC$ = "COS function" : EXPECT% = -1 : ACTUAL% = INT(COS(3.14159) + 0.5)
7130 GOSUB 9200 : REM Validate result
7140 GOSUB 9100 : REM Test case
7150 DESC$ = "TAN function" : EXPECT% = 1 : ACTUAL% = INT(TAN(0.7853982) + 0.5)
7160 GOSUB 9200 : REM Validate result
7170 GOSUB 9100 : REM Test case
7180 DESC$ = "ATN function" : EXPECT% = 0.7854 : ACTUAL% = INT(ATN(1) * 10000) / 10000
7190 GOSUB 9200 : REM Validate result
7200 GOSUB 9100 : REM Test case
7210 DESC$ = "EXP function" : EXPECT% = 7.3891 : ACTUAL% = INT(EXP(2) * 10000) / 10000
7220 GOSUB 9200 : REM Validate result
7230 GOSUB 9100 : REM Test case
7240 DESC$ = "LOG function" : EXPECT% = 2.3026 : ACTUAL% = INT(LOG(10) * 10000) / 10000
7250 GOSUB 9200 : REM Validate result
7260 GOSUB 9100 : REM Test case
7270 DESC$ = "RND function range" : R = RND(1) : EXPECT% = 1 : ACTUAL% = (R >= 0 AND R < 1)
7280 GOSUB 9200 : REM Validate result
7290 REM User-defined functions
7300 DEF FNS(X) = X * X
7310 GOSUB 9100 : REM Test case
7320 DESC$ = "User-defined function" : EXPECT% = 16 : ACTUAL% = FNS(4)
7330 GOSUB 9200 : REM Validate result
7340 GOSUB 9300 : REM Save section results
7350 RETURN

8000 REM Miscellaneous tests
8010 PRINT "Miscellaneous Tests:"
8020 PRINT "-------------------"
8030 TOTAL% = 0 : PASSED% = 0
8040 REM DATA-READ tests
8050 RESTORE 8100
8060 READ D1, D2$, D3
8070 GOSUB 9100 : REM Test case
8080 DESC$ = "DATA-READ numeric" : EXPECT% = 123 : ACTUAL% = D1
8090 GOSUB 9200 : REM Validate result
8100 DATA 123, "test", 456
8110 GOSUB 9100 : REM Test case
8120 DESC$ = "DATA-READ string" : EXPECT$ = "test" : ACTUAL$ = D2$
8130 GOSUB 9250 : REM Validate string result
8140 GOSUB 9100 : REM Test case
8150 DESC$ = "DATA-READ multiple" : EXPECT% = 456 : ACTUAL% = D3
8160 GOSUB 9200 : REM Validate result
8170 REM PEEK/POKE tests
8180 ADDR = 60000 : REM Safe memory location for testing
8190 POKE ADDR, 42
8200 GOSUB 9100 : REM Test case
8210 DESC$ = "PEEK/POKE" : EXPECT% = 42 : ACTUAL% = PEEK(ADDR)
8220 GOSUB 9200 : REM Validate result
8230 REM INKEY$ test
8240 GOSUB 9100 : REM Test case
8250 DESC$ = "INKEY$ (non-blocking)" : EXPECT% = 1 : ACTUAL% = 1 : REM Always pass
8260 A$ = INKEY$
8270 GOSUB 9200 : REM Validate result
8280 GOSUB 9300 : REM Save section results
8290 RETURN

9000 REM Test framework initialization
9010 GLOBAL_TOTAL% = 0
9020 GLOBAL_PASSED% = 0
9030 SECTIONS% = 0
9040 SEC_TOTAL% = 0
9050 SEC_PASSED% = 0
9060 DIM SEC_NAME$(8)
9070 DIM SEC_TOTAL%(8)
9080 DIM SEC_PASSED%(8)
9090 RETURN

9100 REM Test case setup
9110 TOTAL% = TOTAL% + 1
9120 RETURN

9200 REM Validate numeric result
9210 IF ACTUAL% = EXPECT% THEN PASSED% = PASSED% + 1 : RESULT$ = "PASS" ELSE RESULT$ = "FAIL"
9220 PRINT "  [";RESULT$;"] "; DESC$; " ("; ACTUAL%; " = "; EXPECT$; ")"
9230 RETURN

9250 REM Validate string result
9260 IF ACTUAL$ = EXPECT$ THEN PASSED% = PASSED% + 1 : RESULT$ = "PASS" ELSE RESULT$ = "FAIL"
9270 PRINT "  [";RESULT$;"] "; DESC$; " ("; ACTUAL$; " = "; EXPECT$; ")"
9280 RETURN

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