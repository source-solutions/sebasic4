    0 REM open tape containing code page before running
   10 MODE 1
   20 LOAD "" CODE
   30 CLS
   40 UDG 8
   50 FOR C = 32 TO 255
   60 PRINT CHR$ C; " ";
   70 NEXT C