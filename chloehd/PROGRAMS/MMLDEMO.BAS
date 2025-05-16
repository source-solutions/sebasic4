10 REM Standard MML Demo
20 REM Shows examples of the standard MML syntax
30 CLS
40 PRINT "Standard MML Demo"
50 PRINT "================="
60 PRINT
70 PRINT "1. Simple scale"
80 PRINT "2. Scale with note lengths"
90 PRINT "3. Dotted notes"
100 PRINT "4. Accidentals (sharps/flats)"
110 PRINT "5. Repeats"
120 PRINT "6. Multiple voices"
130 PRINT "7. Mary Had a Little Lamb"
140 PRINT "8. Exit"
150 PRINT
160 INPUT "Choose a demo (1-8): "; D
170 IF D < 1 OR D > 8 THEN GOTO 150
180 ON D GOSUB 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000
190 GOTO 30

1000 REM Simple scale
1010 PRINT "Playing a simple C major scale..."
1020 PLAY "t120 o4 cdefgab>c"
1030 RETURN

2000 REM Scale with note lengths
2010 PRINT "Playing a scale with different note lengths..."
2020 PLAY "t120 o4 c2d4e8f8g4a4b2>c1"
2030 RETURN

3000 REM Dotted notes
3010 PRINT "Playing a melody with dotted notes..."
3020 PLAY "t120 o4 c.d8e.f8g2"
3030 RETURN

4000 REM Accidentals
4010 PRINT "Playing a chromatic scale with sharps and flats..."
4020 PLAY "t120 o4 c c# d d# e f f# g g# a a# b >c"
4030 PLAY "t120 o4 c d- d e- e f g- g a- a b- b >c"
4040 RETURN

5000 REM Repeats
5010 PRINT "Playing a phrase with repeats..."
5020 PLAY "t120 o4 [cde] [fga] [>c<ba] g2"
5030 RETURN

6000 REM Multiple voices
6010 PRINT "Playing multiple voices..."
6020 PLAY "t120 o3 l4 cegcegce", "t120 o4 l8 ccggaag>c<"
6030 RETURN

7000 REM Mary Had a Little Lamb
7010 PRINT "Playing 'Mary Had a Little Lamb'..."
7020 PLAY "t120 o4 l4 edcd eee2 ddd2 eee2"
7030 PLAY "t120 o4 l4 edcd eee ede d2"
7040 RETURN

8000 REM Exit
8010 RETURN