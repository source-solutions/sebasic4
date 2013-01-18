    0 REM hi-res screen loader
   10 MODE 1
   20 CLEAR 36863
   30 LOAD "" CODE 36864: REM this assumes a single 12288 byte file
   40 REM LOAD "" CODE 43008: REM uncomment if you have two 6144 byte files
   50 OUT 32765, 15
   60 PUT 36864, 49152, 6144
   70 PUT 43008, 57344, 6144
   80 OUT 32765, 8
   90 PAUSE