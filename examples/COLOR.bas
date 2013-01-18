    0 REM works with or without ULAplus
   10 PALETTE 64, 1
   20 INPUT "CLUT (0-3) "; c
   30 INPUT "PEN (0-7) "; i
   40 INPUT "PAPER (0-7) "; p
   50 BORDER p
   60 LET a = VAL ("\" + STR$ (c) + STR$ (p) + STR$ (i))
   70 PRINT COLOR a;
   80 COLOR a
   90 CLS
  100 LIST