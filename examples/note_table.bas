   10 CLEAR 
   20 REM LOAD "notes" DATA n$()
   30 GO SUB 9900: REM load notes data
   40 GO SUB 9932: REM set notes values
   50 GO SUB 9934: REM set channel values
   60 SOUND Av, 13; P, 62
   70 FOR o = 1 TO 8
   80 RESTORE 9928
   90 FOR x = 1 TO 12
  100 READ n
  110 GO SUB 9930
  120 NEXT x
  130 NEXT o
  140 STOP 
 9900 REM create note table
 9901 RESTORE 9920
 9902 DIM n$(8, 12, 2)
 9903 FOR o = 1 TO 4
 9904 FOR n = 1 TO 12
 9905 FOR p = 1 TO 2
 9906 READ a
 9907 LET n$(o, n, p) = CHR$ a
 9908 NEXT p
 9909 NEXT n
 9910 NEXT o
 9911 FOR o = 5 TO 8
 9912 FOR n = 1 TO 12
 9913 READ a
 9914 LET n$(o, n, 1) = CHR$ 0
 9915 LET n$(o, n, 2) = CHR$ a
 9916 NEXT n
 9917 NEXT o
 9918 REM SAVE "notes" DATA n$()
 9919 RETURN 
 9920 DATA 13, 16, 12, 85, 11, 164, 10, 252, 10, 95, 9, 202, 9, 61, 8, 184, 8, 59, 7, 197, 7, 85, 6, 236
 9921 DATA 6, 136, 6, 42, 5, 210, 5, 126, 5, 47, 4, 229, 4, 158, 4, 92, 4, 29, 3, 226, 3, 171, 3, 118
 9922 DATA 3, 68, 3, 21, 2, 233, 2, 191, 2, 152, 2, 114, 2, 79, 2, 46, 2, 15, 1, 241, 1, 213, 1, 187
 9923 DATA 1, 162, 1, 139, 1, 116, 1, 96, 1, 76, 1, 57, 1, 40, 1, 23, 1, 7, 0, 249, 0, 235, 0, 221
 9924 DATA 209, 197, 186, 176, 166, 157, 148, 140, 132, 124, 117, 111
 9925 DATA 105, 99, 93, 88, 83, 78, 74, 70, 66, 62, 59, 55
 9926 DATA 52, 49, 47, 44, 41, 39, 37, 35, 33, 31, 29, 28
 9927 DATA 26, 25, 23, 22, 21, 20, 18, 17, 16, 16, 15, 14
 9928 REM tune data
 9929 DATA C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B
 9930 REM play note (channel A)
 9931 SOUND Ac, CODE n$(o, n, 1); Af, CODE n$(o, n, 2): PAUSE 5: RETURN 
 9932 REM note values
 9933 LET C = 1: LET Db = 2: LET D = 3: LET Eb = 4: LET E = 5: LET F = 6: LET Gb = 7: LET G = 8: LET Ab = 9: LET A = 10: LET Bb = 11: LET B = 12: RETURN 
 9934 REM channel values
 9935 LET Ac = 1: LET Af = 0: LET Bc = 3: LET Bf = 2: LET Cc = 5: LET Cf = 4: LET N = 6: LET P = 7: LET Av = 8: LET Bv = 9: LET Cv = 10: LET Ec = 12: LET Ef = 11: LET Es = 13: RETURN
16383 REM END