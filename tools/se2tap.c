/**********************************************************************************************************************************/
/* se2tap is a quick and dirty hack of bas2tap by ThunderWare Research                                                            */
/*                                                                                                                                */
/* OS type      : Generic                                                                                                         */
/*                Watcom C = wcl386 -mf -fp3 -fpi -3r -oxnt -w4 -we se2tap.c                                                      */
/*                MS C     = cl /Ox /G2 /AS se2tap.c /F 1000                                                                      */
/*                gcc      = gcc -Wall -O2 se2tap.c -o se2tap -lm ; strip se2tap                                                  */
/*                SAS/C    = sc link math=ieee se2tap.c                                                                           */
/* Libs needed  : math                                                                                                            */
/* Description  : Convert ASCII BASIC file to TAP tape image emulator file                                                        */
/*                                                                                                                                */
/* Notes        : There's a check for a define "__DEBUG__", which generates tons of output if defined.                            */
/*                                                                                                                                */
/*                Copyleft (C) 1998-2010 ThunderWare Research Center, written by Martijn van der Heide.                           */
/*                                                                                                                                */
/*                This program is free software; you can redistribute it and/or                                                   */
/*                modify it under the terms of the GNU General Public License                                                     */
/*                as published by the Free Software Foundation; either version 2                                                  */
/*                of the License, or (at your option) any later version.                                                          */
/*                                                                                                                                */
/*                This program is distributed in the hope that it will be useful,                                                 */
/*                but WITHOUT ANY WARRANTY; without even the implied warranty of                                                  */
/*                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                                                   */
/*                GNU General Public License for more details.                                                                    */
/*                                                                                                                                */
/*                You should have received a copy of the GNU General Public License                                               */
/*                along with this program; if not, write to the Free Software                                                     */
/*                Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                                     */
/*                                                                                                                                */
/**********************************************************************************************************************************/

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

/**********************************************************************************************************************************/
/* Some compilers don't define the following things, so I define them here...                                                     */
/**********************************************************************************************************************************/

#ifdef __WATCOMC__
#define x_strnicmp(_S1,_S2,_Len)  strnicmp (_S1, _S2, _Len)
#define x_log2(_X)                log2 (_X)
#else
int x_strnicmp (char *_S1, char *_S2, int _Len)                                        /* Case independant partial string compare */
{
    for ( ; _Len && *_S1 && *_S2 && toupper (*_S1) == toupper (*_S2) ; _S1 ++, _S2 ++, _Len --)
        ;
    return (_Len ? (int)toupper (*_S1) - (int)toupper (*_S2) : 0);
}
#define x_log2(_X)                (log (_X) / log (2.0))                     /* If your compiler doesn't know the 'log2' function */
#endif

//#define __DEBUG__

typedef unsigned char  byte;
#ifndef FALSE
typedef unsigned char  bool;                                              /* If your compiler doesn't know this variable type yet */
#define TRUE           1
#define FALSE          0
#endif

/**********************************************************************************************************************************/
/* Define the global variables                                                                                                    */
/**********************************************************************************************************************************/

struct TokenMap_s
{
    char *Token;
    byte  TokenType;
    /* Type   0 = No special meaning                                                   */
    /* Type   1 = Always keyword                                                       */
    /* Type   2 = Can be both keyword and non-keyword (colour parameters)              */
    /* Type   3 = Numeric expression token                                             */
    /* Type   4 = String expression token                                              */
    /* Type   5 = May only appear in (L)PRINT statements (AT and TAB)                  */
    /* Type   6 = Type-less (normal ASCII or expression token)                         */
    byte  KeywordClass[8];                                     /* The class this keyword belongs to, as defined in the Spectrum ROM */
    /* This table is used by expression tokens as well. Class 12 was added for this purpose */
    /* Class  0 = No further operands                                                  */
    /* Class  1 = Used in LET. A variable is required                                  */
    /* Class  2 = Used in LET. An expression, numeric or string, must follow           */
    /* Class  3 = A numeric expression may follow. Zero to be used in case of default  */
    /* Class  4 = A single character variable must follow                              */
    /* Class  5 = A set of items may be given                                          */
    /* Class  6 = A numeric expression must follow                                     */
    /* Class  7 = Handles colour items                                                 */
    /* Class  8 = Two numeric expressions, separated by a comma, must follow           */
    /* Class  9 = As for class 8 but colour items may precede the expression           */
    /* Class 10 = A string expression must follow                                      */
    /* Class 11 = Handles cassette routines                                            */
    /* The following classes are not available in the ROM but were needed              */
    /* Class 12 = One or more string expressions, separated by commas, must follow     */
    /* Class 13 = One or more expressions, separated by commas, must follow            */
    /* Class 14 = One or more variables, separated by commas, must follow (READ)       */
    /* Class 15 = DEF FN                                                               */
} TokenMap[] = {
    
    /* Extended BASIC token - keywords */
    {"DELETE",    1, { 8, 0 }},
    {"EDIT",      1, { 3, 0 }},
    {"RENUM",     1, { 5, 0 }},
    {"PALETTE",   1, { 8, 0 }},
    {"SOUND",     1, { 5, 0 }},
    {"ON ERROR",  1, { 5, 0 }},
    
    /* Everything below ASCII 32 */
    {"	", 1, { 0 }},                                                                                                 /* tab stop */
    {NULL, 6, { 0 }}, {NULL, 6, { 0 }}, {NULL, 6, { 0 }}, {NULL, 6, { 0 }}, {NULL, 6, { 0 }}, {NULL, 6, { 0 }},
    {"(eoln)", 6, { 0 }},                                                                                                    /* CR */
    {NULL, 6, { 0 }},                                                                                                    /* Number */
    {NULL, 6, { 0 }},
    {NULL, 6, { 0 }},                                                                                                       /* INK */
    {NULL, 6, { 0 }},                                                                                                     /* PAPER */
    {NULL, 6, { 0 }},                                                                                                     /* FLASH */
    {NULL, 6, { 0 }},                                                                                                    /* BRIGHT */
    {NULL, 6, { 0 }},                                                                                                   /* INVERSE */
    {NULL, 6, { 0 }},                                                                                                      /* OVER */
    {NULL, 6, { 0 }},                                                                                                        /* AT */
    {NULL, 6, { 0 }},                                                                                                       /* TAB */
    {NULL, 6, { 0 }}, {NULL, 6, { 0 }}, {NULL, 6, { 0 }}, {NULL, 6, { 0 }}, {NULL, 6, { 0 }}, {NULL, 6, { 0 }}, {NULL, 6, { 0 }},
    {NULL, 6, { 0 }},
    
    /* Normal ASCII set */
    {"\x20", 6, { 0 }}, {"\x21", 6, { 0 }}, {"\x22", 6, { 0 }}, {"\x23", 6, { 0 }}, {"\x24", 6, { 0 }}, {"\x25", 6, { 0 }},
    {"\x26", 6, { 0 }}, {"\x27", 6, { 0 }}, {"\x28", 6, { 0 }}, {"\x29", 6, { 0 }}, {"\x2A", 6, { 0 }}, {"\x2B", 6, { 0 }},
    {"\x2C", 6, { 0 }}, {"\x2D", 6, { 0 }}, {"\x2E", 6, { 0 }}, {"\x2F", 6, { 0 }}, {"\x30", 6, { 0 }}, {"\x31", 6, { 0 }},
    {"\x32", 6, { 0 }}, {"\x33", 6, { 0 }}, {"\x34", 6, { 0 }}, {"\x35", 6, { 0 }}, {"\x36", 6, { 0 }}, {"\x37", 6, { 0 }},
    {"\x38", 6, { 0 }}, {"\x39", 6, { 0 }}, {"\x3A", 2, { 0 }}, {"\x3B", 6, { 0 }}, {"\x3C", 6, { 0 }}, {"\x3D", 6, { 0 }},
    {"\x3E", 6, { 0 }}, {"\x3F", 6, { 0 }}, {"\x40", 6, { 0 }}, {"\x41", 6, { 0 }}, {"\x42", 6, { 0 }}, {"\x43", 6, { 0 }},
    {"\x44", 6, { 0 }}, {"\x45", 6, { 0 }}, {"\x46", 6, { 0 }}, {"\x47", 6, { 0 }}, {"\x48", 6, { 0 }}, {"\x49", 6, { 0 }},
    {"\x4A", 6, { 0 }}, {"\x4B", 6, { 0 }}, {"\x4C", 6, { 0 }}, {"\x4D", 6, { 0 }}, {"\x4E", 6, { 0 }}, {"\x4F", 6, { 0 }},
    {"\x50", 6, { 0 }}, {"\x51", 6, { 0 }}, {"\x52", 6, { 0 }}, {"\x53", 6, { 0 }}, {"\x54", 6, { 0 }}, {"\x55", 6, { 0 }},
    {"\x56", 6, { 0 }}, {"\x57", 6, { 0 }}, {"\x58", 6, { 0 }}, {"\x59", 6, { 0 }}, {"\x5A", 6, { 0 }}, {"\x5B", 6, { 0 }},
    {"\x5C", 6, { 0 }}, {"\x5D", 6, { 0 }}, {"\x5E", 6, { 0 }}, {"\x5F", 6, { 0 }}, {"\x60", 6, { 0 }}, {"\x61", 6, { 0 }},
    {"\x62", 6, { 0 }}, {"\x63", 6, { 0 }}, {"\x64", 6, { 0 }}, {"\x65", 6, { 0 }}, {"\x66", 6, { 0 }}, {"\x67", 6, { 0 }},
    {"\x68", 6, { 0 }}, {"\x69", 6, { 0 }}, {"\x6A", 6, { 0 }}, {"\x6B", 6, { 0 }}, {"\x6C", 6, { 0 }}, {"\x6D", 6, { 0 }},
    {"\x6E", 6, { 0 }}, {"\x6F", 6, { 0 }}, {"\x70", 6, { 0 }}, {"\x71", 6, { 0 }}, {"\x72", 6, { 0 }}, {"\x73", 6, { 0 }},
    {"\x74", 6, { 0 }}, {"\x75", 6, { 0 }}, {"\x76", 6, { 0 }}, {"\x77", 6, { 0 }}, {"\x78", 6, { 0 }}, {"\x79", 6, { 0 }},
    {"\x7A", 6, { 0 }}, {"\x7B", 6, { 0 }}, {"\x7C", 6, { 0 }}, {"\x7D", 6, { 0 }}, {"\x7E", 6, { 0 }}, {"\x7F", 6, { 0 }},
    
    /* Block graphics without shift */
    {"\x80", 6, { 0 }}, {"\x81", 6, { 0 }}, {"\x82", 6, { 0 }}, {"\x83", 6, { 0 }}, {"\x84", 6, { 0 }}, {"\x85", 6, { 0 }},
    {"\x86", 6, { 0 }}, {"\x87", 6, { 0 }},
    
    /* Block graphics with shift */
    {"\x88", 6, { 0 }}, {"\x89", 6, { 0 }}, {"\x8A", 6, { 0 }}, {"\x8B", 6, { 0 }}, {"\x8C", 6, { 0 }}, {"\x8D", 6, { 0 }},
    {"\x8E", 6, { 0 }}, {"\x8F", 6, { 0 }},
    
    /* UDGs */
    {"\x90", 6, { 0 }}, {"\x91", 6, { 0 }}, {"\x92", 6, { 0 }}, {"\x93", 6, { 0 }}, {"\x94", 6, { 0 }}, {"\x95", 6, { 0 }},
    {"\x96", 6, { 0 }}, {"\x97", 6, { 0 }}, {"\x98", 6, { 0 }}, {"\x99", 6, { 0 }}, {"\x9A", 6, { 0 }}, {"\x9B", 6, { 0 }},
    {"\x9C", 6, { 0 }}, {"\x9D", 6, { 0 }}, {"\x9E", 6, { 0 }}, {"\x9F", 6, { 0 }}, {"\xA0", 6, { 0 }}, {"\xA1", 6, { 0 }},
    {"\xA2", 6, { 0 }}, {"\xA3", 6, { 0 }}, {"\xA4", 6, { 0 }},
    
    /* BASIC tokens - expression */
    {"RND",       3, { 0 }},
    {"INKEY$",    4, { 0 }},
    {"PI",        3, { 0 }},
    {"FN",        3, { 1, '(', 13, ')', 0 }},
    {"POINT",     3, { '(', 8, ')', 0 }},
    {"SCREEN$",   4, { '(', 8, ')', 0 }},
    {"ATTR",      3, { '(', 8, ')', 0 }},
    {"AT",        5, { 8, 0 }},
    {"TAB",       5, { 6, 0 }},
    {"VAL$",      4, { 10, 0 }},
    {"CODE",      3, { 10, 0 }},
    {"VAL",       3, { 10, 0 }},
    {"LEN",       3, { 10, 0 }},
    {"SIN",       3, { 6, 0 }},
    {"COS",       3, { 6, 0 }},
    {"TAN",       3, { 6, 0 }},
    {"ASIN",      3, { 6, 0 }},
    {"ACOS",      3, { 6, 0 }},
    {"ATN",       3, { 6, 0 }},
    {"LOG",       3, { 6, 0 }},
    {"EXP",       3, { 6, 0 }},
    {"INT",       3, { 6, 0 }},
    {"SQR",       3, { 6, 0 }},
    {"SGN",       3, { 6, 0 }},
    {"ABS",       3, { 6, 0 }},
    {"PEEK",      3, { 6, 0 }},
    {"IN",        3, { 6, 0 }},
    {"USR",       3, { 6, 0 }},
    {"STR$",      4, { 6, 0 }},
    {"CHR$",      4, { 6, 0 }},
    {"NOT",       3, { 6, 0 }},
    {"BIN",       6, { 0 }},
    {"OR",        6, { 5, 0 }},   /*  -\                                                  */
    {"AND",       6, { 5, 0 }},   /*   |                                                  */
    {"<=",        6, { 5, 0 }},   /*   | These are handled directly within ScanExpression */
    {">=",        6, { 5, 0 }},   /*   |                                                  */
    {"<>",        6, { 5, 0 }},   /*  -/                                                  */
    {"LINE",      6, { 0 }},
    {"THEN",      6, { 0 }},
    {"TO",        6, { 0 }},
    {"STEP",      6, { 0 }},
    
    /* BASIC tokens - keywords */
    {"DEF FN",    1, { 15, 0 }},                 /* Special treatment - insertion of call-by-value room required for the evaluator */
    {"UDG",       1, { 6, 0 }},
    {"MODE",      1, { 6, 0 }},
    {"PUT",       1, { 9, ',', 6, 0 }},
    {"RESET",     1, { 0 }},
    {"OPEN #",    1, { 11, 0 }},
    {"CLOSE #",   1, { 11, 0 }},
    {"MERGE",     1, { 11, 0 }},
    {"VERIFY",    1, { 11, 0 }},
    {"BEEP",      1, { 8, 0 }},
    {"CIRCLE",    1, { 9, ',', 6, 0 }},
    {"PEN",       2, { 7, 0 }},
    {"PAPER",     2, { 7, 0 }},
    {"COLOR",     2, { 7, 0 }},
    {"CLUT",      2, { 7, 0 }},
    {"INVERSE",   2, { 7, 0 }},
    {"OVER",      2, { 7, 0 }},
    {"OUT",       1, { 8, 0 }},
    {"SLOW",      1, { 0 }},
    {"FAST",      1, { 0 }},
    {"STOP",      1, { 0 }},
    {"READ",      1, { 14, 0 }},
    {"DATA",      2, { 13, 0 }},
    {"RESTORE",   1, { 3, 0 }},
    {"NEW",       1, { 0 }},
    {"BORDER",    1, { 6, 0 }},
    {"CONTINUE",  1, { 0 }},
    {"DIM",       1, { 1, '(', 13, ')', 0 }},
    {"REM",       1, { 5, 0 }},                                                                 /* (Special: taken out separately) */
    {"FOR",       1, { 4, '=', 6, 0xCC, 6, 0xCD, 6, 0 }},                                /* (Special: STEP (0xCD) is not required) */
    {"GOTO",      1, { 6, 0 }},
    {"GOSUB",     1, { 6, 0 }},
    {"INPUT",     1, { 5, 0 }},
    {"LOAD",      1, { 11, 0 }},
    {"LIST",      1, { 3, 0 }},
    {"LET",       1, { 1, '=', 2, 0 }},
    {"PAUSE",     1, { 3, 0 }},
    {"NEXT",      1, { 4, 0 }},
    {"POKE",      1, { 8, 0 }},
    {"PRINT",     1, { 5, 0 }},
    {"PLOT",      1, { 9, 0 }},
    {"RUN",       1, { 3, 0 }},
    {"SAVE",      1, { 11, 0 }},
    {"RANDOMIZE", 1, { 3, 0 }},
    {"IF",        1, { 6, 0xCB, 0 }},
    {"CLS",       1, { 0 }},
    {"DRAW",      1, { 9, ',', 6, 0 }},
    {"CLEAR",     1, { 3, 0 }},
    {"RETURN",    1, { 0 }},
    {"CALL",      1, { 3, 0 }},
    
    /* Extended BASIC token - keywords */
    {"DELETE",    1, { 8, 0 }},
    {"EDIT",      1, { 3, 0 }},
    {"RENUM",     1, { 5, 0 }},
    {"PALETTE",   1, { 8, 0 }},
    {"SOUND",     1, { 5, 0 }},
    {"ON ERROR",  1, { 5, 0 }}};

size_t TokenMapSize = sizeof(TokenMap) / sizeof(struct TokenMap_s);

#define MAXLINELENGTH 1024

char ConvertedSpectrumLine[MAXLINELENGTH + 1];
byte ResultingLine[MAXLINELENGTH + 1];

struct TapeHeader_s
{
    byte LenLo1;
    byte LenHi1;
    byte Flag1;
    byte HType;
    char HName[10];
    byte HLenLo;
    byte HLenHi;
    byte HStartLo;
    byte HStartHi;
    byte HBasLenLo;
    byte HBasLenHi;
    byte Parity1;
    byte LenLo2;
    byte LenHi2;
    byte Flag2;
} TapeHeader = {19, 0,                                                            /* Len header */
    0,                                                                /* Flag header */
    0, {32, 32, 32, 32, 32, 32, 32, 32, 32, 32}, 0, 0, 0, 128, 0, 0,  /* The header itself */
    0,                                                                /* Parity header */
    0, 0,                                                             /* Len converted BASIC */
    255};                                                             /* Flag converted BASIC */

int   Is48KProgram    = -1;                                                                                       /* -1 = unknown */
/*  1 = 48K     */
/*  0 = 128K    */
int   UsesInterface1  = -1;                                                           /* -1 = unknown                             */
/*  0 = either Interface1 or Opus Discovery */
/*  1 = Interface1                          */
/*  2 = Opus Discovery                      */
bool  CaseIndependant = FALSE;
bool  Quiet           = FALSE;                                                 /* Suppress banner and progress indication if TRUE */
bool  NoWarnings      = FALSE;                                                                       /* Suppress warnings if TRUE */
bool  DoCheckSyntax   = TRUE;
bool  TokenBracket    = FALSE;
bool  HandlingDEFFN   = FALSE;                                                                         /* Exceptional instruction */
bool  InsideDEFFN     = FALSE;
#define DEFFN           0xCE
FILE *ErrStream;

/**********************************************************************************************************************************/
/* Let's be lazy and define a very commonly used error message....                                                                */
/**********************************************************************************************************************************/

#define BADTOKEN(_Exp,_Got)        fprintf (ErrStream, "ERROR in line %d, statement %d - Expected %s, but got \"%s\"\n", \
BasicLineNo, StatementNo, _Exp, _Got)

/**********************************************************************************************************************************/
/* And let's generate tons of debugging info too....                                                                              */
/**********************************************************************************************************************************/

#ifdef __DEBUG__
char ListSpaces[20];
int  RecurseLevel;
#endif

/**********************************************************************************************************************************/
/* Prototype all functions                                                                                                        */
/**********************************************************************************************************************************/

int  GetLineNumber     (char **FirstAfter);
int  MatchToken        (int BasicLineNo, bool WantKeyword, char **LineIndex, byte *Token);
int  HandleNumbers     (int BasicLineNo, char **BasicLine, byte **SpectrumLine);
int  HandleBIN         (int BasicLineNo, char **BasicLine, byte **SpectrumLine);
int  ExpandSequences   (int BasicLineNo, char **BasicLine, byte **SpectrumLine, bool StripSpaces);
int  PrepareLine       (char *LineIn, int FileLineNo, char **FirstToken);
bool ScanVariable      (int BasicLineNo, int StatementNo, int Keyword, byte **Index, bool *Type, int *NameLen, int AllowSlicing);
bool SliceDirectString (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool ScanStream        (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool ScanChannel       (int BasicLineNo, int StatementNo, int Keyword, byte **Index, byte *WhichChannel);
bool SignalInterface1  (int BasicLineNo, int StatementNo, int NewMode);
bool CheckEnd          (int BasicLineNo, int StatementNo, byte **Index);
bool ScanExpression    (int BasicLineNo, int StatementNo, int Keyword, byte **Index, bool *Type, int Level);
bool HandleClass01     (int BasicLineNo, int StatementNo, int Keyword, byte **Index, bool *Type);
bool HandleClass02     (int BasicLineNo, int StatementNo, int Keyword, byte **Index, bool Type);
bool HandleClass03     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass04     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass05     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass06     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass07     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass08     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass09     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass10     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass11     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass12     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass13     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass14     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool HandleClass15     (int BasicLineNo, int StatementNo, int Keyword, byte **Index);
bool CheckSyntax       (int BasicLineNo, byte *Line);

/**********************************************************************************************************************************/
/* Start of the program                                                                                                           */
/**********************************************************************************************************************************/

int GetLineNumber (char **FirstAfter)

/**********************************************************************************************************************************/
/* Pre   : The line must have been prepared into (global) `ConvertedSpectrumLine'.                                                */
/* Post  : The BASIC line number has been returned, or -1 if there was none.                                                      */
/* Import: None.                                                                                                                  */
/**********************************************************************************************************************************/

{
    int   LineNo     = 0;
    char *LineIndex;
    bool  SkipSpaces = TRUE;
    bool  Continue   = TRUE;
    
    LineIndex = ConvertedSpectrumLine;
    while (*LineIndex && Continue)
        if (*LineIndex == ' ')                                                                                 /* Skip leading spaces */
        {
            if (SkipSpaces)
                LineIndex ++;
            else
                Continue = FALSE;
        }
        else if (isdigit (*LineIndex))                                                                              /* Process number */
        {
            LineNo = LineNo * 10 + *(LineIndex ++) - '0';
            SkipSpaces = FALSE;
        }
        else
            Continue = FALSE;
    *FirstAfter = LineIndex;
    if (SkipSpaces)                                                                                          /* Nothing found yet ? */
        return (-1);
    else
        while ((**FirstAfter) == ' ')                                                                         /* Skip trailing spaces */
            (*FirstAfter) ++;
    return (LineNo);
}

int MatchToken (int BasicLineNo, bool WantKeyword, char **LineIndex, byte *Token)

/**********************************************************************************************************************************/
/* Pre   : `WantKeyword' is TRUE if we need in keyword match, `LineIndex' holds the position to match.                            */
/* Post  : If there was a match, the token value is returned in `Token' and `LineIndex' is pointing after the string plus any     */
/*         any trailing space.                                                                                                    */
/*         The return value is 0 for no match, -2 for an error, -1 for a match of the wrong type, 1 for a good match.             */
/* Import: None.                                                                                                                  */
/**********************************************************************************************************************************/

{
    int    Cnt;
    size_t Length;
    size_t LongestMatch = 0;
    bool   Match        = FALSE;
    bool   Match2;
    
    if ((**LineIndex) == ':')                                                                                  /* Special exception */
    {
        LongestMatch = 1;
        Match = TRUE;
        *Token = ':';
    }
    else for (Cnt = 165 ; Cnt < TokenMapSize ; Cnt ++)                                                   /* (Keywords start after the UDGs) */
    {
        Length = strlen (TokenMap[Cnt].Token);
        if (CaseIndependant)
            Match2 = !x_strnicmp (*LineIndex, TokenMap[Cnt].Token, Length);
        else
            Match2 = !strncmp (*LineIndex, TokenMap[Cnt].Token, Length);
        if (Match2)
            if (Length > LongestMatch)
            {
                LongestMatch = Length;
                Match = TRUE;
                if (0 && Cnt > 255)
                    *Token = Cnt - 256;
                else
                    *Token = Cnt;
            }
        
    }
    if (!Match)
        return (0);                                                                                               /* Signal: no match */
    if (isalpha (*(*LineIndex + LongestMatch - 1)) && isalpha (*(*LineIndex + LongestMatch)))         /* Continueing alpha string ? */
        return (0);                                            /* Then there's no match after all! (eg. 'INT' must not match 'INTER') */
    *LineIndex += LongestMatch;                                                                                /* Go past the token */
    while ((**LineIndex) == ' ')                                                                            /* Skip trailing spaces */
        (*LineIndex) ++;
    
    if ((WantKeyword && TokenMap[*Token].TokenType == 0) ||                                /* Wanted keyword but got something else */
        (!WantKeyword && TokenMap[*Token].TokenType == 1))                        /* Did not want a keyword but got one nonetheless */
        return (-1);                                                                              /* Signal: match, but of wrong type */
    else
        return (1);                                                                                                 /* Signal: match! */
}

int HandleNumbers (int BasicLineNo, char **BasicLine, byte **SpectrumLine)

/**********************************************************************************************************************************/
/* Pre   : `BasicLineNo' holds the current BASIC line number, `BasicLine' points into the line, `SpectrumLine' points to the      */
/*         TAPped Spectrum line.                                                                                                  */
/* Post  : If there was a (floating point) number at this position, it has been processed into `SpectrumLine' and `LineIndex' is  */
/*         pointing after the number.                                                                                             */
/*         The return value is: 0 = no number, 1 = number done, -1 = number error (already reported).                             */
/* Import: None.                                                                                                                  */
/**********************************************************************************************************************************/

{
#define SHIFT31BITS   (double)2147483648.0                                                                            /* (= 2^31) */
    char   *StartOfNumber;
    double  Value   = 0.0;
    double  Divider = 1.0;
    double  Exp     = 0.0;
    int     IntValue;
    byte    Sign    = 0x00;
    unsigned long Mantissa;
    
    if (!isdigit (**BasicLine) &&                                                             /* Current character is not a digit ? */
        (**BasicLine) != '.')                                                               /* And not a decimal point (eg. '.5') ? */
        return (0);                                                                                 /* Then it can hardly be a number */
    StartOfNumber = *BasicLine;
    while (isdigit (**BasicLine))                                                                    /* First read the integer part */
        Value = Value * 10 + *((*BasicLine) ++) - '0';
    if ((**BasicLine) == '.')                                                                                    /* Decimal point ? */
    {                                                                                                      /* Read the decimal part */
        (*BasicLine) ++;
        while (isdigit (**BasicLine))
            Value = Value + (Divider /= 10) * (*((*BasicLine) ++) - '0');
    }
    if ((**BasicLine) == 'e' || (**BasicLine) == 'E')                                                                 /* Exponent ? */
    {
        (*BasicLine) ++;
        if ((**BasicLine) == '+')                                                            /* Both "Ex" and "E+x" do the same thing */
            (*BasicLine) ++;
        else if ((**BasicLine) == '-')                                                                           /* Negative exponent */
        {
            Sign = 0xFF;
            (*BasicLine) ++;
        }
        while (isdigit (**BasicLine))                                                                      /* Read the exponent value */
            Exp = Exp * 10 + *((*BasicLine) ++) - '0';
        if (Sign == 0x00)                                                           /* Raise the resulting value to the read exponent */
            Value = Value * pow (10.0, Exp);
        else
            Value = Value / pow (10.0, Exp);
    }
    strncpy ((char *)*SpectrumLine, StartOfNumber, *BasicLine - StartOfNumber);                     /* Insert the ASCII value first */
    (*SpectrumLine) += (*BasicLine - StartOfNumber);
    IntValue = (int)floor (Value);
    if (Value == IntValue && Value >= -65536 && Value < 65536)                                                   /* Small integer ? */
    {
        *((*SpectrumLine) ++) = 0x0E;                                                                         /* Insert number marker */
        *((*SpectrumLine) ++) = 0x00;
        if (IntValue >= 0)                                                                                             /* Insert sign */
            *((*SpectrumLine) ++) = 0x00;
        else
        {
            *((*SpectrumLine) ++) = 0xFF;
            /*      IntValue += 65536; */                                    /* Maintain bug in Spectrum ROM - INT(-65536) will result in -1 */
        }
        *((*SpectrumLine) ++) = (byte)(IntValue & 0xFF);
        *((*SpectrumLine) ++) = (byte)(IntValue >> 8);
        *((*SpectrumLine) ++) = 0x00;
    }
    else                                                                             /* Need to store in full floating point format */
    {
        if (Value < 0)
        {
            Sign = 0x80;                                                                              /* Sign bit is high bit of byte 2 */
            Value = -Value;
        }
        else
            Sign = 0x00;
        Exp = floor (x_log2 (Value));
        if (Exp < -129 || Exp > 126)
        {
            fprintf (ErrStream, "ERROR - Number too big in line %d\n", BasicLineNo);
            return (-1);
        }
        Mantissa = (unsigned long)floor ((Value / pow (2.0, Exp) - 1.0) * SHIFT31BITS + 0.5);                   /* Calculate mantissa */
        *((*SpectrumLine) ++) = 0x0E;                                                                         /* Insert number marker */
        *((*SpectrumLine) ++) = (byte)Exp + 0x81;                                                                  /* Insert exponent */
        *((*SpectrumLine) ++) = (byte)((Mantissa >> 24) & 0x7F) | Sign;                                            /* Insert mantissa */
        *((*SpectrumLine) ++) = (byte)((Mantissa >> 16) & 0xFF);                                                     /* (Big endian!) */
        *((*SpectrumLine) ++) = (byte)((Mantissa >> 8) & 0xFF);
        *((*SpectrumLine) ++) = (byte)(Mantissa & 0xFF);
    }
    return (1);
}

int HandleBIN (int BasicLineNo, char **BasicLine, byte **SpectrumLine)

/**********************************************************************************************************************************/
/* Pre   : `BasicLineNo' holds the current BASIC line number, `BasicLine' points into the line just past the BIN token,           */
/*         `SpectrumLine' points to the TAPped Spectrum line.                                                                     */
/* Post  : If there was a BINary number at this position, it has been processed into `SpectrumLine' and `LineIndex' is pointing   */
/*         after the number.                                                                                                      */
/*         The return value is: 1 = number done, -1 = number error (already reported).                                            */
/* Import: None.                                                                                                                  */
/**********************************************************************************************************************************/

{
    int Value = 0;
    
    while ((**BasicLine) == '0' || (**BasicLine) == '1')                                                 /* Read only binary digits */
    {
        Value = Value * 2 + **BasicLine - '0';
        if (Value > 65535)
        {
            fprintf (ErrStream, "ERROR - Number too big in line %d\n", BasicLineNo);
            return (-1);
        }
        *((*SpectrumLine) ++) = *((*BasicLine) ++);                                                            /* (Copy digit across) */
    }
    *((*SpectrumLine) ++) = 0x0E;                                                                           /* Insert number marker */
    *((*SpectrumLine) ++) = 0x00;                                                                /* (A small integer by definition) */
    *((*SpectrumLine) ++) = 0x00;
    *((*SpectrumLine) ++) = (byte)(Value & 0xFF);
    *((*SpectrumLine) ++) = (byte)(Value >> 8);
    *((*SpectrumLine) ++) = 0x00;
    return (1);
}

int ExpandSequences (int BasicLineNo, char **BasicLine, byte **SpectrumLine, bool StripSpaces)

/**********************************************************************************************************************************/
/* Pre   : `BasicLineNo' holds the current BASIC line number, `BasicLine' points into the line, `SpectrumLine' points to the      */
/*         TAPped Spectrum line.                                                                                                  */
/* Post  : If there was an expandable '{...}' sequence at this position, it has been processed into `SpectrumLine', `LineIndex'   */
/*         is pointing after the sequence. Returned is -1 for error, 0 for no expansion, 1 for expansion.                         */
/* Import: None.                                                                                                                  */
/**********************************************************************************************************************************/

{
    char *StartOfSequence;
    byte  Attribute       = 0;
    byte  AttributeLength = 0;
    byte  AttributeVal1   = 0;
    byte  AttributeVal2   = 0;
    byte  OldCharacter;
    int   Cnt;
    
    if (**BasicLine != '{')
        return (0);
    StartOfSequence = (*BasicLine) + 1;
    /* 'CODE' and 'CAT' were added for the sole purpuse of allowing them to be OPEN #'ed as channels! */
    if (!x_strnicmp (StartOfSequence, "CODE}", 5))                                                               /* Special: 'CODE' */
    {
        *((*SpectrumLine) ++) = 0xAF;
        (*BasicLine) += 6;
        return (1);
    }
    if (!x_strnicmp (StartOfSequence, "CAT}", 4))                                                                 /* Special: 'CAT' */
    {
        *((*SpectrumLine) ++) = 0xCF;
        (*BasicLine) += 5;
        return (1);
    }
    if (!x_strnicmp (StartOfSequence, "(C)}", 4))
    {                                                                                             /* Form "{(C)}" -> copyright sign */
        *((*SpectrumLine) ++) = 0x7F;
        (*BasicLine) += 5;
        if (StripSpaces)
            while ((**BasicLine) == ' ')                                                                        /* Skip trailing spaces */
                (*BasicLine) ++;
        return (1);
    }
    if (*StartOfSequence == '+' && *(StartOfSequence + 1) >= '1' && *(StartOfSequence + 1) <= '8' && *(StartOfSequence + 2) == '}')
    {                                                                                   /* Form "{+X}" -> block graphics with shift */
        *((*SpectrumLine) ++) = 0x88 + (((*(StartOfSequence + 1) - '0') % 8) ^ 7);
        (*BasicLine) += 4;
        if (StripSpaces)
            while ((**BasicLine) == ' ')
                (*BasicLine) ++;
        return (1);
    }
    if (*StartOfSequence == '-' && *(StartOfSequence + 1) >= '1' && *(StartOfSequence + 1) <= '8' && *(StartOfSequence + 2) == '}')
    {                                                                                /* Form "{-X}" -> block graphics without shift */
        *((*SpectrumLine) ++) = 0x80 + (*(StartOfSequence + 1) - '0') % 8;
        (*BasicLine) += 4;
        if (StripSpaces)
            while ((**BasicLine) == ' ')
                (*BasicLine) ++;
        return (1);
    }
    if (toupper (*StartOfSequence) >= 'A' && toupper (*StartOfSequence) <= 'U' && *(StartOfSequence + 1) == '}')
    {                                                                                                          /* Form "{X}" -> UDG */
        if (toupper (*StartOfSequence) == 'T' || toupper (*StartOfSequence) == 'U')                                   /* 'T' or 'U' ? */
            switch (Is48KProgram)                                                                       /* Then the program must be 48K */
        {
            case -1 : Is48KProgram = 1; break;                                                                        /* Set the flag */
            case  0 : fprintf (ErrStream, "ERROR - Line %d contains UDGs \'T\' and/or \'U\'\n"
                               "but the program was already marked 128K\n", BasicLineNo);
                return (-1);
            case  1 : break;
        }
        *((*SpectrumLine) ++) = 0x90 + toupper (*StartOfSequence) - 'A';
        (*BasicLine) += 3;
        if (StripSpaces)
            while ((**BasicLine) == ' ')
                (*BasicLine) ++;
        return (1);
    }
    if (isxdigit (*StartOfSequence) && isxdigit (*(StartOfSequence + 1)) && *(StartOfSequence + 2) == '}')
    {                                                                                                    /* Form "{XX}" -> below 32 */
        if (*StartOfSequence <= '9')
            (**SpectrumLine) = *StartOfSequence - '0';
        else
            (**SpectrumLine) = toupper (*StartOfSequence) - 'A' + 10;
        if (*(StartOfSequence + 1) <= '9')
            (**SpectrumLine) = (**SpectrumLine) * 16 + *(StartOfSequence + 1) - '0';
        else
            (**SpectrumLine) = (**SpectrumLine) * 16 + toupper (*(StartOfSequence + 1)) - 'A' + 10;
        (*SpectrumLine) ++;
        (*BasicLine) += 4;
        if (StripSpaces)
            while ((**BasicLine) == ' ')
                (*BasicLine) ++;
        return (1);
    }
    if (!x_strnicmp (StartOfSequence, "INK", 3))
    {
        Attribute = 0x10;
        AttributeLength = 3;
    }
    else if (!x_strnicmp (StartOfSequence, "PAPER", 5))
    {
        Attribute = 0x11;
        AttributeLength = 5;
    }
    else if (!x_strnicmp (StartOfSequence, "COLOR", 5))
    {
        Attribute = 0x12;
        AttributeLength = 5;
    }
    else if (!x_strnicmp (StartOfSequence, "CLUT", 6))
    {
        Attribute = 0x13;
        AttributeLength = 6;
    }
    else if (!x_strnicmp (StartOfSequence, "INVERSE", 7))
    {
        Attribute = 0x14;
        AttributeLength = 7;
    }
    else if (!x_strnicmp (StartOfSequence, "OVER", 4))
    {
        Attribute = 0x15;
        AttributeLength = 4;
    }
    else if (!x_strnicmp (StartOfSequence, "AT", 2))
    {
        Attribute = 0x16;
        AttributeLength = 2;
    }
    else if (!x_strnicmp (StartOfSequence, "TAB", 3))
    {
        Attribute = 0x17;
        AttributeLength = 3;
    }
    if (Attribute > 0)
    {
        StartOfSequence += AttributeLength;
        while (*StartOfSequence == ' ')
            StartOfSequence ++;
        while (isdigit (*StartOfSequence))
            AttributeVal1 = AttributeVal1 * 10 + *(StartOfSequence ++) - '0';
        if (Attribute == 0x16 || Attribute == 0x17)
        {
            if (*StartOfSequence != ',')
                Attribute = 0;
            else
            {
                StartOfSequence ++;                                                                              /* (Step past the comma) */
                while (*StartOfSequence == ' ')
                    StartOfSequence ++;
                while (isdigit (*StartOfSequence))
                    AttributeVal2 = AttributeVal2 * 10 + *(StartOfSequence ++) - '0';
            }
        }
        if (*StartOfSequence != '}')                                                                          /* Need closing bracket */
            Attribute = 0;
        if (Attribute > 0)
        {
            *((*SpectrumLine) ++) = Attribute;
            *((*SpectrumLine) ++) = AttributeVal1;
            if (Attribute == 0x16 || Attribute == 0x17)
                *((*SpectrumLine) ++) = AttributeVal2;
            (*BasicLine) = StartOfSequence + 1;
            if (StripSpaces)
                while ((**BasicLine) == ' ')
                    (*BasicLine) ++;
            return (1);
        }
    }
    if (!NoWarnings)
    {
        for (Cnt = 0 ; *((*BasicLine) + Cnt) && *((*BasicLine) + Cnt) != '}' ; Cnt ++)
            ;
        if (*((*BasicLine) + Cnt) == '}')
        {
            OldCharacter = *((*BasicLine) + Cnt + 1);
            *((*BasicLine) + Cnt + 1) = '\0';
            printf ("WARNING - Unexpandable sequence \"%s\" in line %d\n", (*BasicLine), BasicLineNo);
            *((*BasicLine) + Cnt + 1) = OldCharacter;
            return (0);
        }
    }
    return (0);
}

int PrepareLine (char *LineIn, int FileLineNo, char **FirstToken)

/**********************************************************************************************************************************/
/* Pre   : `LineIn' points to the read line, `FileLineNo' holds the real line number.                                             */
/* Post  : Multiple spaces have been removed (unless within a string), the BASIC line number has been found and `FirstToken' is   */
/*         pointing at the first non-whitespace character after the line number.                                                  */
/*         Bad characters are reported, as well as any other error. The return value is the BASIC line number, -1 if error, or    */
/*         -2 if the (empty!) line should be skipped.                                                                             */
/* Import: GetLineNumber.                                                                                                         */
/**********************************************************************************************************************************/

{
    char  *IndexIn;
    char  *IndexOut;
    bool   InString        = FALSE;
    bool   SingleSeparator = FALSE;
    bool   StillOk         = TRUE;
    bool   DoingREM        = FALSE;
    int    BasicLineNo     = -1;
    static int PreviousBasicLineNo = -1;
    
    IndexIn = LineIn;
    IndexOut = ConvertedSpectrumLine;
    while (*IndexIn && StillOk)
    {
        if (*IndexIn == '\t')                                                                                   /* EXCEPTION: Print ' */
        {
            *(IndexOut ++) = 0x06;
            IndexIn ++;
        }
        else if (*IndexIn < 32 || *IndexIn >= 127)                                                /* (Exclude copyright sign as well) */
            StillOk = FALSE;
        else
        {
            if (!DoingREM)
                if (!x_strnicmp (IndexIn, " REM ", 5) ||                                                 /* Going through REM statement ? */
                    !x_strnicmp (IndexIn, ":REM ", 5))
                    DoingREM = TRUE;                                                          /* Signal: copy anything and everything ASCII */
            if (InString || DoingREM)
                *(IndexOut ++) = *IndexIn;
            else
            {
                if (*IndexIn == ' ')
                {
                    if (!SingleSeparator)                                                                         /* Remove multiple spaces */
                    {
                        SingleSeparator = TRUE;
                        *(IndexOut ++) = *IndexIn;
                    }
                }
                else
                {
                    SingleSeparator = FALSE;
                    *(IndexOut ++) = *IndexIn;
                }
            }
            if (*IndexIn == '\"' && !DoingREM)
                InString = !InString;
            IndexIn ++;
        }
    }
    *IndexOut = '\0';
    if (!StillOk)
        if (*IndexIn == 0x0D || *IndexIn == 0x0A)                                                        /* 'Correct' for end-of-line */
            StillOk = TRUE;                                                                     /* (Accept CR and/or LF as end-of-line) */
    BasicLineNo = GetLineNumber (FirstToken);
    if (InString)
        fprintf (ErrStream, "ERROR - %s line %d misses terminating quote\n",
                 BasicLineNo < 0 ? "ASCII" : "BASIC", BasicLineNo < 0 ? FileLineNo : BasicLineNo);
    else if (!StillOk)
        fprintf (ErrStream, "ERROR - %s line %d contains a bad character (code %02Xh)\n",
                 BasicLineNo < 0 ? "ASCII" : "BASIC", BasicLineNo < 0 ? FileLineNo : BasicLineNo, *IndexIn);
    else if (BasicLineNo < 0)                                                                         /* Could not read line number */
    {
        if (!(**FirstToken))                                                                            /* Line is completely empty ? */
        {
            if (!NoWarnings)
                printf ("WARNING - Skipping empty ASCII line %d\n", FileLineNo);
            return (-2);                                                                                    /* Signal: skip entire line */
        }
        else
        {
            fprintf (ErrStream, "ERROR - Missing line number in ASCII line %d\n", FileLineNo);
            StillOk = FALSE;
        }
    }
    else if (PreviousBasicLineNo >= 0)                                                                      /* Not the first line ? */
    {
        if (BasicLineNo < PreviousBasicLineNo)                                            /* This line number smaller than previous ? */
        {
            fprintf (ErrStream, "ERROR - Line number %d is smaller than previous line number %d\n", BasicLineNo, PreviousBasicLineNo);
            StillOk = FALSE;
        }
        else if (BasicLineNo == PreviousBasicLineNo && !NoWarnings)                                 /* Same line number as previous ? */
            printf ("WARNING - Duplicate use of line number %d\n", BasicLineNo);                  /* (BASIC can handle it after all...) */
    }
    else if (!(**FirstToken))                                                                 /* Line contains only a line number ? */
    {
        fprintf (ErrStream, "ERROR - Line %d contains no statements!\n", BasicLineNo);
        StillOk = FALSE;
    }
    PreviousBasicLineNo = BasicLineNo;                                                                 /* Remember this line number */
    if (!InString && StillOk)
        return (BasicLineNo);
    else
        return (-1);
}

bool CheckEnd (int BasicLineNo, int StatementNo, byte **Index)

/**********************************************************************************************************************************/
/* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Index' the current position in the line.     */
/* Post  : A check is made whether the end of the current statement has been reached.                                             */
/*         If so, an error is reported and TRUE is returned (so FALSE indicates that everything is still fine and dandy).         */
/* Import: none.                                                                                                                  */
/**********************************************************************************************************************************/

{
    if (**Index == ':' || **Index == 0x0D)                                                     /* End of statement or end of line ? */
    {
        fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected end of statement\n", BasicLineNo, StatementNo);
        return (TRUE);
    }
    return (FALSE);
}

bool ScanVariable (int BasicLineNo, int StatementNo, int Keyword, byte **Index, bool *Type, int *NameLen, int AllowSlicing)

/**********************************************************************************************************************************/
/* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Keyword' the keyword to which this operand   */
/*         belongs, `Index' the current position in the line.                                                                     */
/*         `AllocSlicing' is one of the following values:                                                                         */
/*         -1 = Don't check for slicing/indexing (used by DEF FN)                                                                 */
/*         0 = No slicing/indexing allowed                                                                                        */
/*         1 = Either slicing or indexing may follow (indices being numeric)                                                      */
/*         2 = Only numeric indexing may follow (used by LET and READ)                                                            */
/* Post  : A check has been made whether there's a variable at the current position. If so, it has been skipped.                  */
/*         Slicing is handled here as well, but notice that this is not necessarily correct!                                      */
/*         Single letter string variables can be either flat or array and both possibilities are considered here.                 */
/*         Both "a$(1 TO 10)" and "a$(1, 2)" are correct to BASIC, but depend on whether a "DIM" statement was used.              */
/*         The length of the found string (without any '$') is returned in `NameLen', its type is returned in `Type' (TRUE for    */
/*         numeric and FALSE for string variables). The return value is TRUE is all went well. Errors have already been reported. */
/*         The return value is FALSE either when no variable is at this point or an error was found.                              */
/*         `NameLen' is returned 0 if no variable was detected here, or > 0 if in error.                                          */
/* Import: ScanExpression.                                                                                                        */
/**********************************************************************************************************************************/

{
    bool SubType;
    bool IsArray = FALSE;
    bool SetTokenBracket = FALSE;
    
    Keyword = Keyword;                                                                                    /* (Keep compilers happy) */
    *Type = TRUE;                                                                                      /* Assume it will be numeric */
    *NameLen = 0;
    if (!isalpha (**Index))                                                /* The first character must be alphabetic for a variable */
        return (FALSE);
    *NameLen = 1;
    while (isalnum (*(++ (*Index))))                                                              /* Read on, until end of the word */
        (*NameLen) ++;
    if (**Index == '$')                                                                                 /* It's a string variable ? */
    {
        if (*NameLen > 1)                                                   /* String variables can only have a single character name */
        {
            fprintf (ErrStream, "ERROR in line %d, statement %d - String variables can only have single character names\n",
                     BasicLineNo, StatementNo);
            return (FALSE);
        }
        (*Index) ++;
        *Type = FALSE;
    }
#ifdef __DEBUG__
    printf ("DEBUG - %sScanVariable, Type is %s\n", ListSpaces, *Type ? "NUM" : "ALPHA");
#endif
    if (AllowSlicing >= 0 && **Index == '(')                                                                  /* Slice the string ? */
    {
#ifdef __DEBUG__
        printf ("DEBUG - %sScanVariable, reading index\n", ListSpaces);
#endif
        if (*NameLen > 1)                                                             /* Arrays can only have a single character name */
        {
            fprintf (ErrStream, "ERROR in line %d, statement %d - Arrays can only have single character names\n",
                     BasicLineNo, StatementNo);
            return (FALSE);
        }
        if (AllowSlicing == 0)                                                                      /* Slicing/Indexing not allowed ? */
        {
            fprintf (ErrStream, "ERROR in line %d, statement %d - Slicing/Indexing not allowed\n", BasicLineNo, StatementNo);
            return (FALSE);
        }
        (*Index) ++;                                                                                            /* (Skip the bracket) */
        if (**Index == ')')                                                                           /* Empty slice "a$()" is not ok */
        {
            fprintf (ErrStream, "ERROR in line %d, statement %d - Empty array index not allowed\n", BasicLineNo, StatementNo);
            return (FALSE);
        }
        if (**Index == 0xCC)                                                                           /* "a$( TO num)" or "a$( TO )" */
        {
            if (AllowSlicing == 2)
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - Slicing token \"TO\" inappropriate for arrays\n",
                         BasicLineNo, StatementNo);
                return (FALSE);
            }
        }
        else                                                                                      /* Not "a$( TO num)" nor "a$( TO )" */
        {
            if (!TokenBracket)
            {
                TokenBracket = TRUE;                                                                          /* Allow complex expression */
                SetTokenBracket = TRUE;
            }
            if (!ScanExpression (BasicLineNo, StatementNo, '(', Index, &SubType, 0))                                 /* First parameter */
                return (FALSE);
            if (SetTokenBracket)
                TokenBracket = FALSE;
            if (!SubType)                                                                                            /* Must be numeric */
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - Variables indices must be numeric\n", BasicLineNo, StatementNo);
                return (FALSE);
            }
            if (**Index == ')')                                                                                      /* "a$(num)" is ok */
            {
                (*Index) ++;
#ifdef __DEBUG__
                printf ("DEBUG - %sScanVariable, index ending, next char is \"%s\"\n", ListSpaces, TokenMap[**Index].Token);
#endif
                return (TRUE);
            }
        }
        if (**Index != 0xCC && **Index != ',')                                                          /* Either an array or a slice */
        {
            fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected index character \"%c\"\n",
                     BasicLineNo, StatementNo, **Index);
            return (FALSE);
        }
        if (**Index == ',')
            IsArray = TRUE;
        else
        {
            if (AllowSlicing == 2)
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - Slicing token \"TO\" inappropriate for arrays\n",
                         BasicLineNo, StatementNo);
                return (FALSE);
            }
            if (*Type)                                                                          /* Only character strings can be sliced */
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - Only character strings can be sliced\n", BasicLineNo, StatementNo);
                return (FALSE);
            }
        }
        do
        {
            (*Index) ++;                                                                  /* Skip each "," (or the "TO" for non-arrays) */
            if (!TokenBracket)
            {
                TokenBracket = TRUE;
                SetTokenBracket = TRUE;
            }
            if (!ScanExpression (BasicLineNo, StatementNo, '(', Index, &SubType, 0))                     /* Second or further parameter */
                return (FALSE);
            if (SetTokenBracket)
                TokenBracket = FALSE;
            if (!SubType)                                                                                            /* Must be numeric */
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - Variables indices must be numeric\n", BasicLineNo, StatementNo);
                return (FALSE);
            }
            if (!IsArray && **Index != ')')
            {
                BADTOKEN ("\")\"", TokenMap[**Index].Token);
                return (FALSE);
            }
            else if (IsArray && **Index != ',' && **Index != ')' && **Index != 0xCC)
            {
                BADTOKEN ("\",\"", TokenMap[**Index].Token);
                return (FALSE);
            }
        }
        while (**Index != ')');
        (*Index) ++;                                                                                   /* (Step past closing bracket) */
#ifdef __DEBUG__
        printf ("DEBUG - %sScanVariable, index ending, next char is \"%s\"\n", ListSpaces, TokenMap[**Index].Token);
#endif
    }
    return (TRUE);
}

bool SliceDirectString (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Keyword' the keyword to which this operand   */
/*         belongs, `Index' the current position in the line.                                                                     */
/*         A direct string has just been read and a '(' character is currently under the cursor.                                  */
/* Post  : Slicing is handled here.                                                                                               */
/*         Possible are "string"(), "string"(num), "string"( TO ), "string"(num TO ), "string"( TO num) and "string"(num TO num). */
/*         The return value is FALSE if an error was found (which has already been reported here).                                */
/* Import: ScanExpression.                                                                                                        */
/**********************************************************************************************************************************/

{
    bool SubType;
    bool SetTokenBracket = FALSE;
    
    Keyword = Keyword;                                                                                    /* (Keep compilers happy) */
    (*Index) ++;                                                                                   /* Step past the opening bracket */
    if (**Index == ')')                                                                                /* Empty slice "abc"() is ok */
    {
        (*Index) ++;
        return (TRUE);
    }
    if (**Index != 0xCC)                                                                      /* Not "abc"( TO num) nor "abc"( TO ) */
    {
        if (!TokenBracket)
        {
            TokenBracket = TRUE;
            SetTokenBracket = TRUE;
        }
        if (!ScanExpression (BasicLineNo, StatementNo, '(', Index, &SubType, 0))                                   /* First parameter */
            return (FALSE);
        if (SetTokenBracket)
            TokenBracket = FALSE;
        if (!SubType)                                                                                              /* Must be numeric */
        {
            fprintf (ErrStream, "ERROR in line %d, statement %d - Slice values must be numeric\n", BasicLineNo, StatementNo);
            return (FALSE);
        }
    }
    if (**Index == ')')                                                                                         /* "abc"(num) is ok */
    {
        (*Index) ++;
        return (TRUE);
    }
    if (**Index != 0xCC)                                                                                                  /* ('TO') */
    {
        fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected index character\n", BasicLineNo, StatementNo);
        return (FALSE);
    }
    (*Index) ++;
    if (**Index == ')')                                                                                     /* "abc"(num TO ) is ok */
    {
        (*Index) ++;
        return (TRUE);
    }
    if (!TokenBracket)
    {
        TokenBracket = TRUE;
        SetTokenBracket = TRUE;
    }
    if (!ScanExpression (BasicLineNo, StatementNo, '(', Index, &SubType, 0))                                    /* Second parameter */
        return (FALSE);
    if (SetTokenBracket)
        TokenBracket = FALSE;
    if (!SubType)                                                                                                /* Must be numeric */
    {
        fprintf (ErrStream, "ERROR in line %d, statement %d - Slice values must be numeric\n", BasicLineNo, StatementNo);
        return (FALSE);
    }
    if (**Index != ')')
    {
        BADTOKEN ("\")\"", TokenMap[**Index].Token);
        return (FALSE);
    }
    (*Index) ++;                                                                                     /* (Step past closing bracket) */
    return (TRUE);
}

bool ScanStream (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Keyword' the keyword to which this operand   */
/*         belongs, `Index' the current position in the line.                                                                     */
/*         A stream hash mark (`#') has just been read.                                                                           */
/* Post  : The following stream number is checked to be a numeric expression.                                                     */
/*         The return value is FALSE if an error was found (which has already been reported here).                                */
/* Import: HandleClass06.                                                                                                         */
/**********************************************************************************************************************************/

{
    if (!SignalInterface1 (BasicLineNo, StatementNo, 0))
        return (FALSE);
    return (HandleClass06 (BasicLineNo, StatementNo, Keyword, Index));                                   /* Find numeric expression */
}

bool SignalInterface1 (int BasicLineNo, int StatementNo, int NewMode)

/**********************************************************************************************************************************/
/* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `NewMode' holds the required hardware mode.   */
/* Post  : The required hardware is tested for conflicts.                                                                         */
/*         The return value is FALSE if there was a conflict (which has already been reported here).                              */
/* Import: none.                                                                                                                  */
/**********************************************************************************************************************************/

{
    if ((NewMode == 1 && UsesInterface1 == 2) ||                                 /* Interface1 required, but already flagged Opus ? */
        (NewMode == 2 && UsesInterface1 == 1))                                   /* Opus required, but already flagged Interface1 ? */
    {
        fprintf (ErrStream, "ERROR in line %d, statement %d - The program uses commands that are specific\n"
                 "for Interface 1 and Opus Discovery, but don't exist on both devices\n",
                 BasicLineNo, StatementNo);
        return (FALSE);
    }
    UsesInterface1 = NewMode;
    return (TRUE);
}

bool ScanChannel (int BasicLineNo, int StatementNo, int Keyword, byte **Index, byte *WhichChannel)

/**********************************************************************************************************************************/
/* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Keyword' the keyword to which this operand   */
/*         belongs, `Index' the current position in the line.                                                                     */
/* Post  : A channel identifier of the form   "x";n;   must follow. `x' is a single alphanumeric character, `n' is a numeric      */
/*         expression, the rest are required characters.                                                                          */
/*         The found channel identifier ('x') is returned (in lowercase) in `WhichChannel'.                                       */
/*         The return value is FALSE if an error was found (which has already been reported here).                                */
/* Import: HandleClass06, CheckEnd.                                                                                               */
/**********************************************************************************************************************************/

{
    int  NeededHardware = 0;                                                                            /* (Default to Interface 1) */
    
    *WhichChannel = '\0';
    if (CheckEnd (BasicLineNo, StatementNo, Index))
        return (FALSE);
    if (**Index != '\"')
    {
        if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))/* EXCEPTION: The Opus allows '<num>' to abbreviate '"m";<num>' */
        {
            fprintf (ErrStream, "Expected to find a channel identifier\n");
            return (FALSE);
        }
        *WhichChannel = 'm';
        if (!SignalInterface1 (BasicLineNo, StatementNo, 2))                                          /* Signal the Opus specificness */
            return (FALSE);
        if (CheckEnd (BasicLineNo, StatementNo, Index))
            return (FALSE);
        if (**Index != ';')
        {
            BADTOKEN ("\";\"", TokenMap[**Index].Token);
            return (FALSE);
        }
        (*Index) ++;
        if (CheckEnd (BasicLineNo, StatementNo, Index))
            return (FALSE);
    }
    else
    {
        (*Index) ++;
        if (CheckEnd (BasicLineNo, StatementNo, Index))
            return (FALSE);
        if (!isalpha (**Index) &&                                                                               /* (Ordinary channel) */
            **Index != '#' &&                                                                        /* (Linked channel, OPEN # only) */
            **Index != 0xAF &&                                                                       /* ('CODE' channel, OPEN # only) */
            **Index != 0xCF)                                                                          /* ('CAT' channel, OPEN # only) */
        {
            fprintf (ErrStream, "ERROR in line %d, statement %d - Channel name must be alphanumeric\n", BasicLineNo, StatementNo);
            return (FALSE);
        }
        *WhichChannel = tolower (**Index);
        (*Index) ++;
        if (CheckEnd (BasicLineNo, StatementNo, Index))
            return (FALSE);
        if (**Index != '\"')
        {
            fprintf (ErrStream, "ERROR in line %d, statement %d - Channel name must be single character\n", BasicLineNo, StatementNo);
            return (FALSE);
        }
        (*Index) ++;
        if (*WhichChannel == 'k' || *WhichChannel == 's' || *WhichChannel == 'p' ||                     /* (Normal Spectrum channels) */
            *WhichChannel == 'm' || *WhichChannel == 't' || *WhichChannel == 'b' ||
            *WhichChannel == '#' || *WhichChannel == 0xCF)                                                         /* ('CAT' channel) */
            NeededHardware = 0;
        else if (*WhichChannel == 'n')                                 /* Network channel is available on Interface 1 but not on Opus */
            NeededHardware = 1;
        else if (*WhichChannel == 'j' ||                                                                  /* (Opus: Joystick channel) */
                 *WhichChannel == 'd' ||                                                                      /* (Opus: disk channel) */
                 *WhichChannel == 0xAF)                                                                     /* (Opus: 'CODE' channel) */
            NeededHardware = 2;
        if (!SignalInterface1 (BasicLineNo, StatementNo, NeededHardware))
            return (FALSE);
        if (*WhichChannel == 'm' || *WhichChannel == 'd' || *WhichChannel == 'n' ||     /* Continue checking with these channels only */
            *WhichChannel == '#' || *WhichChannel == 0xCF)
        {
            if (CheckEnd (BasicLineNo, StatementNo, Index))
                return (FALSE);
            if (**Index != ';')
            {
                BADTOKEN ("\";\"", TokenMap[**Index].Token);
                return (FALSE);
            }
            (*Index) ++;
            if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))                                   /* Find numeric expression */
                return (FALSE);
            if (*WhichChannel == 'm')                                        /* Omly the 'm' channel requires a ';' character following */
            {
                if (CheckEnd (BasicLineNo, StatementNo, Index))
                    return (FALSE);
                if (**Index != ';')
                {
                    BADTOKEN ("\";\"", TokenMap[**Index].Token);
                    return (FALSE);
                }
                (*Index) ++;
                if (CheckEnd (BasicLineNo, StatementNo, Index))
                    return (FALSE);
            }
        }
    }
    return (TRUE);
}

bool ScanExpression (int BasicLineNo, int StatementNo, int Keyword, byte **Index, bool *Type, int Level)

/**********************************************************************************************************************************/
/* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Keyword' the keyword to which this operand   */
/*         belongs, `Index' the current position in the line.                                                                     */
/*         `Level' is used for recursion and must be 0 when called, unless when called from ScanVariable (then it must be 1).     */
/* Post  : An expression must be found, either numerical or string. Its type is returned in `Type' (TRUE for numerical).          */
/*         All subexpressions, between brackets, are dealt with using recursion.                                                  */
/*         The return value is FALSE if an error was found (which has already been reported here).                                */
/* Import: ScanExpression (recursive), SliceDirectString, ScanVariable, HandleClassXX.                                            */
/**********************************************************************************************************************************/

{
    bool More       = TRUE;
    bool SubType    = TRUE;                                                                          /* (Assume numeric expression) */
    bool SubSubType;
    bool TypeKnown  = FALSE;
    bool TotalTypeKnown = FALSE;
    bool Dummy;
    int  VarNameLen;
    int  ClassIndex = -1;
    byte ThisToken;
    
#ifdef __DEBUG__
    RecurseLevel ++;
    memset (ListSpaces, ' ', RecurseLevel * 2);
    ListSpaces[RecurseLevel * 2] = '\0';
    printf ("DEBUG - %sEnter ScanExpression\n", ListSpaces);
#endif
    if (**Index == '+' || **Index == '-')                                                                   /* Unary plus and minus */
    {
        *Type = TRUE;                                                                          /* Then we expect a numeric expression */
        TypeKnown = TRUE;
        (*Index) ++;                                                                                                 /* Skip the sign */
    }
    while (More)
    {
#ifdef __DEBUG__
        printf ("DEBUG - %sScanExpression sub (keyword \"%s\"), first char is \"%s\"\n",
                ListSpaces, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
        if (**Index == '(')                                                                                      /* Opening bracket ? */
        {
#ifdef __DEBUG__
            printf ("DEBUG - %sRecurse ScanExpression for \"(\"\n", ListSpaces);
#endif
            (*Index) ++;                                                                 /* The 'parent' steps past the opening bracket */
            if (!ScanExpression (BasicLineNo, StatementNo, '(', Index, &SubSubType, Level + 1))                              /* Recurse */
                return (FALSE);
            if (TypeKnown && SubSubType != SubType)                                                         /* Bad subexpression type ? */
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - Type conflict in expression\n", BasicLineNo, StatementNo);
                return (FALSE);
            }
            else if (!TypeKnown)                                                               /* We didn't have an expected type yet ? */
            {
                SubType = SubSubType;
                TypeKnown = TRUE;
            }
            (*Index) ++;                                                             /* The 'parent' steps past the closing bracket too */
            if (**Index == '(')                                                                                            /* Slicing ? */
            {
                if (!SubSubType)                                                                                 /* Result was a string ? */
                {
                    if (!SliceDirectString (BasicLineNo, StatementNo, Keyword, Index))
                        return (FALSE);
                }
                else                                                                       /* No, it was numerical, which you can't slice */
                {
                    fprintf (ErrStream, "ERROR in line %d, statement %d - cannot slice a numerical value\n",
                             BasicLineNo, StatementNo);
                    return (FALSE);
                }
            }
        }
        else if (**Index == ')')                                                                                 /* Closing bracket ? */
        {                                                  /* Leave the bracket for the parent, to allow functions (eg. "ATTR (...)") */
            if (!TotalTypeKnown)                                                                               /* 'Simple' expression ? */
                *Type = SubType;                                                                                       /* Set return type */
#ifdef __DEBUG__
            printf ("DEBUG - %sLeave ScanExpression, Type is %s next char is \"%s\"\n",
                    ListSpaces, *Type ? "NUM" : "ALPHA", TokenMap[**Index].Token);
            if (-- RecurseLevel > 0)
                memset (ListSpaces, ' ', RecurseLevel * 2);
            ListSpaces[RecurseLevel * 2] = '\0';
#endif
            return (TRUE);                                                                                 /* Step out of the recursion */
        }
        else if (**Index == ':' || **Index == 0x0D)                                              /* End of statement or end of line ? */
        {
            if (!TotalTypeKnown)                                                                               /* 'Simple' expression ? */
                *Type = SubType;                                                                                       /* Set return type */
            if (Level)                                                                                         /* Not on lowest level ? */
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - too few closing brackets\n", BasicLineNo, StatementNo);
                return (FALSE);
            }
            More = FALSE;
        }
        else if (isdigit (**Index) || **Index == '.' || **Index == 0xC4 || **Index == 0x26 || **Index == 0x5C)                                                  /* Number ? */
        {
            if (!TypeKnown)                                                                            /* Unknown expression type yet ? */
            {
                TypeKnown = TRUE;                                                                                /* Signal: it is numeric */
                SubType = TRUE;
            }
            else if (!SubType)                                                                         /* Type was known to be string ? */
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - Type conflict in expression\n", BasicLineNo, StatementNo);
                return (FALSE);
            }
            while (*(++ (*Index)) != 0x0E)                                                              /* Skip until the number marker */
                ;
            (*Index) ++;
        }
        else if (**Index == '\"')                                                                                  /* Direct string ? */
        {
            if (!TypeKnown)                                                                            /* Unknown expression type yet ? */
            {
                TypeKnown = TRUE;                                                                               /* Signal: it is a string */
                SubType = FALSE;
            }
            else if (SubType)                                                                         /* Type was known to be numeric ? */
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - Type conflict in expression\n", BasicLineNo, StatementNo);
                return (FALSE);
            }
            while (**Index == '\"')                         /* Concatenated strings are ok, since they allow the use of the " character */
            {
                while (*(++ (*Index)) != '\"')                                                                      /* Find closing quote */
                    ;
                (*Index) ++;                                                                                              /* Step past it */
            }
            if (**Index == '(')                                                                                   /* String is sliced ? */
                if (!SliceDirectString (BasicLineNo, StatementNo, Keyword, Index))
                    return (FALSE);
        }
        else if (ScanVariable (BasicLineNo, StatementNo, Keyword, Index, &SubSubType, &VarNameLen, 1))          /* Is it a variable ? */
        {
            if (!TypeKnown)                                                                            /* Unknown expression type yet ? */
            {
                TypeKnown = TRUE;                                                                                 /* Signal: it is string */
                SubType = SubSubType;
            }
            else if (SubType != SubSubType)                                                                /* Different type variable ? */
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - Type conflict in expression\n", BasicLineNo, StatementNo);
                return (FALSE);
            }
        }
        else if (VarNameLen != 0)                                                                                 /* (Not a variable) */
            return (FALSE);                                                                 /* (But an error that was already reported) */
        /* It's none of the above. Go check tokens */
        else switch (TokenMap[**Index].TokenType)
        {
            case 0 : fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected token \"%s\"\n",
                              BasicLineNo, StatementNo, TokenMap[**Index].Token);
                return (FALSE);
            case 1 :
            case 2 : fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected keyword \"%s\"\n",
                              BasicLineNo, StatementNo, TokenMap[**Index].Token);
                return (FALSE);
            case 3 :
            case 4 :
            case 5 : ThisToken = *((*Index) ++);
                if (TokenMap[ThisToken].TokenType == 5)
                {
                    if (Keyword != 0xF5 && Keyword != 0xE0)                                      /* Not handling a PRINT or LPRINT ? */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected token \"%s\"\n",
                                 BasicLineNo, StatementNo, TokenMap[**Index].Token);
                        return (FALSE);
                    }
                }
                else if (ThisToken == 0xC0 && **Index == '\"')                                                 /* Special: USR "x" */
                {
                    (*Index) ++;                                                                    /* (Step past the opening quote) */
                    if (CheckEnd (BasicLineNo, StatementNo, Index))
                        return (FALSE);
                    if (toupper (**Index) < 'A' || toupper (**Index) > 'U')                                   /* Bad UDG character ? */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - Bad UDG \"%s\"\n",
                                 BasicLineNo, StatementNo, TokenMap[**Index].Token);
                        return (FALSE);
                    }
                    (*Index) ++;
                    if (CheckEnd (BasicLineNo, StatementNo, Index))
                        return (FALSE);
                    if (**Index != '\"')                                                                   /* More than one letter ? */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - An UDG name may be only 1 letter\n",
                                 BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    (*Index) --;
                    if (toupper (**Index) == 'T' || toupper (**Index) == 'U')                        /* One of the UDGs 'T' or 'U' ? */
                        switch (Is48KProgram)                                                          /* Then the program must be 48K */
                    {
                        case -1 : Is48KProgram = 1; break;                                                           /* Set the flag */
                        case  0 : fprintf (ErrStream, "ERROR - Line %d contains UDGs \'T\' and/or \'U\'\n"
                                           "but the program was already marked 128K\n", BasicLineNo);
                            return (FALSE);
                        case  1 : break;
                    }
                    (*Index) += 2;                                                       /* Step past the UDG name and closing quote */
                    break;                                                                                         /* Done, step out */
                }
                else
                {
                    if (!TypeKnown)                                                                 /* Unknown expression type yet ? */
                    {
                        TypeKnown = TRUE;                                                                         /* Set expected type */
                        SubType = (TokenMap[ThisToken].TokenType == 3);
                    }
                    else if ((SubType && TokenMap[ThisToken].TokenType == 4) ||
                             (!SubType && TokenMap[ThisToken].TokenType == 3))
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - Type conflict in expression\n", BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                }
                ClassIndex = -1;
                while (TokenMap[ThisToken].KeywordClass[++ ClassIndex])                             /* Handle all class parameters */
                {
                    if (CheckEnd (BasicLineNo, StatementNo, Index))
                        return (FALSE);
                    else if (TokenMap[ThisToken].KeywordClass[ClassIndex] >= 32)                        /* Required token or class ? */
                    {
                        if (**Index != TokenMap[ThisToken].KeywordClass[ClassIndex])                               /* (Required token) */
                        {                                                                                         /* (Token not there) */
                            fprintf (ErrStream, "ERROR in line %d, statement %d - Expected \"%c\", but got \"%s\"\n",
                                     BasicLineNo, StatementNo, TokenMap[ThisToken].KeywordClass[ClassIndex], TokenMap[**Index].Token);
                            return (FALSE);
                        }
                        else
                        {
                            if (**Index == '(')
                            {
#ifdef __DEBUG__
                                printf ("DEBUG - %sTurning on token bracket\n", ListSpaces);
#endif
                                TokenBracket = TRUE;
                            }
                            else if (**Index == ')')
                            {
#ifdef __DEBUG__
                                printf ("DEBUG - %sTurning off token bracket\n", ListSpaces);
#endif
                                TokenBracket = FALSE;
                            }
                            (*Index) ++;
                        }
                    }
                    else                                                                                          /* (Command class) */
                    {
                        switch (TokenMap[ThisToken].KeywordClass[ClassIndex])
                        {
                            case  1 : if (!HandleClass01 (BasicLineNo, StatementNo, ThisToken, Index, &Dummy))          /* (Special: FN) */
                                return (FALSE);
                                break;
                            case  3 : if (!HandleClass03 (BasicLineNo, StatementNo, ThisToken, Index))
                                return (FALSE);
                                break;
                            case  5 : if (!HandleClass05 (BasicLineNo, StatementNo, ThisToken, Index))
                                return (FALSE);
                                break;
                            case  6 : if (!HandleClass06 (BasicLineNo, StatementNo, ThisToken, Index))
                                return (FALSE);
                                break;
                            case  8 : if (!HandleClass08 (BasicLineNo, StatementNo, ThisToken, Index))
                                return (FALSE);
                                break;
                            case 10 : if (!HandleClass10 (BasicLineNo, StatementNo, ThisToken, Index))
                                return (FALSE);
                                break;
                            case 12 : if (!HandleClass12 (BasicLineNo, StatementNo, ThisToken, Index))
                                return (FALSE);
                                break;
                            case 13 : if (!HandleClass13 (BasicLineNo, StatementNo, ThisToken, Index))
                                return (FALSE);
                                break;
                            case 14 : if (!HandleClass14 (BasicLineNo, StatementNo, ThisToken, Index))
                                return (FALSE);
                                break;
                        }
#ifdef __DEBUG__
                        printf ("DEBUG - %sScanExpression status, Type is %s, next char is \"%s\"\n",
                                ListSpaces, *Type ? "NUM" : "ALPHA", TokenMap[**Index].Token);
#endif
                    }
                }
                if (ThisToken == 0xA6)                                                                                 /* INKEY$ ? */
                    if (**Index == '#')                                                                  /* Type 'INKEY$#<stream>' ? */
                    {
                        (*Index) ++;
                        if (!ScanStream (BasicLineNo, StatementNo, ThisToken, Index))
                            return (FALSE);
                    }
                break;
        }
        /* Piece done, continue */
        if (TokenMap[Keyword].TokenType == 3 || TokenMap[Keyword].TokenType == 4)              /* Just did an operand to a function ? */
        {                                                                                    /* Then step back to evaluate the result */
            if (!TotalTypeKnown)
                *Type = SubType;
#ifdef __DEBUG__
            printf ("DEBUG - %sLeave ScanExpression, Type is %s, next char is \"%s\"\n",
                    ListSpaces, *Type ? "NUM" : "ALPHA", TokenMap[**Index].Token);
            if (-- RecurseLevel > 0)
                memset (ListSpaces, ' ', RecurseLevel * 2);
            ListSpaces[RecurseLevel * 2] = '\0';
#endif
            return (TRUE);
        }
        if (More)
        {
            if (**Index == 0xC5 || **Index == 0xC6)                                                                 /* ('OR' and 'AND') */
            {
#ifdef __DEBUG__
                printf ("DEBUG - %sRecurse ScanExpression for \"%s\"\n", ListSpaces, TokenMap[**Index].Token);
#endif
                //if (!TotalTypeKnown)                                                           /* 'Simple' expression before the AND/OR ? */
                //*Type = SubType;
                if (**Index == 0xC5 && !*Type)
                {
                    fprintf (ErrStream, "ERROR in line %d, statement %d - \"OR\" requires a numeric left value\n", BasicLineNo, StatementNo);
                    return (FALSE);
                }
                ThisToken = *((*Index) ++);                                                   /* Step over the operator - but remember it */
                if (!ScanExpression (BasicLineNo, StatementNo, ThisToken, Index, &SubSubType, 0))                /* Recurse - at level 0! */
                    return (FALSE);
                if (!SubSubType)                                       /* The expression at the right must be numeric for both AND and OR */
                {
                    fprintf (ErrStream, "ERROR in line %d, statement %d - \"%s\" requires a numeric right value\n",
                             BasicLineNo, StatementNo, TokenMap[ThisToken].Token);
                    return (FALSE);
                }
                if (!TypeKnown)                                                                  /* We didn't have an expected type yet ? */
                {
                    TypeKnown = TRUE;
                    TotalTypeKnown = TRUE;
                    SubType = *Type = (bool)(ThisToken == 0xC6 && !*Type ? FALSE : TRUE);                          /* Signal resulting type */
                    /* x$ AND y -> result is string */
                    /* x AND y -> result is numeric */
                    /* x OR y -> result is numeric */
                }
                More = FALSE;              /* (Because the recursing causes the expression to be evaluated right to left, we're done now) */
            }
            else if ((**Index == '=' || **Index == '<' || **Index == '>' ||     /* EXCEPTION: equations between brackets (side effects) */
                      **Index == 0xC7 || **Index == 0xC8 || **Index == 0xC9) &&                                /* ("<=", ">=" and "<>") */
                     Level)                                                                   /* Not on level 0: that is handled below! */
            {                                                /* Expressions like 'LET A=(INKEY$="A")'; we're now between these brackets */
                SubType = *Type = TRUE;                                                          /* Signal: result is going to be numeric */
                TotalTypeKnown = TRUE;
                TypeKnown = FALSE;                                                               /* Start with a fresh subexpression type */
                (*Index) ++;
            }
            else if ((TokenMap[Keyword].TokenType != 4 && TokenMap[Keyword].TokenType != 3) ||  /* Not evaluating an expression token ? */
                     TokenBracket)                                                             /* Or evaluating an operand of a token ? */
            {
                if (**Index == '+')                                                 /* (Can apply to both string and numeric expressions) */
                    (*Index) ++;
                else if (**Index == '-' || **Index == '*' || **Index == '/' || **Index == '^')                          /* (Numeric only) */
                {
                    if (!SubType)                                                                          /* Type was known to be string ? */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - Type conflict in expression\n", BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    (*Index) ++;
                }
                /* Equations and logical operators turn the total result numeric, but each subexpression may be of any type */
                else if ((**Index == '=' || **Index == '<' || **Index == '>' ||
                          **Index == 0xC7 || **Index == 0xC8 || **Index == 0xC9) &&                              /* ("<=", ">=" and "<>") */
                         !Level)                                                                       /* Only evaluate these on level 0! */
                {
                    TotalTypeKnown = TRUE;
                    *Type = TRUE;                                                                  /* Signal: result is going to be numeric */
                    TypeKnown = FALSE;                                                             /* Start with a fresh subexpression type */
                    (*Index) ++;
                }
                else
                    More = FALSE;
            }
            else
                More = FALSE;
        }
    }
    if (!TotalTypeKnown)                                                                                   /* 'Simple' expression ? */
        *Type = SubType;                                                                                           /* Set return type */
#ifdef __DEBUG__
    printf ("DEBUG - %sLeave ScanExpression, Type is %s, next char is \"%s\"\n",
            ListSpaces, *Type ? "NUM" : "ALPHA", TokenMap[**Index].Token);
    if (-- RecurseLevel > 0)
        memset (ListSpaces, ' ', RecurseLevel * 2);
    ListSpaces[RecurseLevel * 2] = '\0';
#endif
    return (TRUE);
}

bool HandleClass01 (int BasicLineNo, int StatementNo, int Keyword, byte **Index, bool *Type)

/**********************************************************************************************************************************/
/* Class 1 = Used in LET. A variable is required.                                                                                 */
/* `Type' is returned to handle the rest of this special statement (HandleClass02)                                                */
/* This function is also used to parse the variable name for DIM and FN.                                                          */
/**********************************************************************************************************************************/

{
    int VarNameLen;
    int ParseArray;
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 1, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    if (Keyword == 0xA8 || Keyword == 0xE9)                                    /* Do not parse any bracketing if checking DIM or FN */
        ParseArray = -1;
    else if (Keyword == 0xF1)                                                             /* LET is allowed to write to a substring */
        ParseArray = 1;
    else
        ParseArray = 2;
    if (!ScanVariable (BasicLineNo, StatementNo, Keyword, Index, Type, &VarNameLen, ParseArray))
    {
        if (VarNameLen == 0)
            BADTOKEN ("variable", TokenMap[**Index].Token);
        return (FALSE);
    }
    return (TRUE);
}

bool HandleClass02 (int BasicLineNo, int StatementNo, int Keyword, byte **Index, bool Type)

/**********************************************************************************************************************************/
/* Class 2 = Used in LET. An expression, numeric or string, must follow.                                                          */
/* `Type' is the type as returned previously by the HandleClass01 call                                                            */
/**********************************************************************************************************************************/

{
    bool SubType;
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 2, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    if (!ScanExpression (BasicLineNo, StatementNo, Keyword, Index, &SubType, 0))
        return (FALSE);
    if (SubType != Type)                                                                                              /* Must match */
    {
        fprintf (ErrStream, "ERROR in line %d, statement %d - Bad assignment expression type\n", BasicLineNo, StatementNo);
        return (FALSE);
    }
    return (TRUE);
}

bool HandleClass03 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 3 = A numeric expression may follow. Zero to be used in case of default.                                                 */
/**********************************************************************************************************************************/

{
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 3, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    if (**Index == ':' || **Index == 0x0D)                                                             /* No expression following ? */
        return (TRUE);                                                                                     /* Then we're done already */
    if (Keyword == 0xFD && **Index == '#')                   /* EXCEPTION: CLEAR may take a stream rather than a numeric expression */
    {
        (*Index) ++;
        if (!SignalInterface1 (BasicLineNo, StatementNo, 0))                                   /* (Which is Interface1/Opus specific) */
            return (FALSE);
        if (**Index == ':' || **Index == 0x0D)                                                           /* No expression following ? */
            return (TRUE);                                      /* (An empty stream is allowed as well - it clears all streams at once) */
    }
    return (HandleClass06 (BasicLineNo, StatementNo, Keyword, Index));                                   /* Find numeric expression */
}

bool HandleClass04 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 4 = A single character variable must follow.                                                                             */
/**********************************************************************************************************************************/

{
    bool Type;
    int  VarNameLen;
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 4, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    if (!ScanVariable (BasicLineNo, StatementNo, Keyword, Index, &Type, &VarNameLen, 0))
    {
        if (VarNameLen == 0)
            BADTOKEN ("variable", TokenMap[**Index].Token);
        return (FALSE);
    }
    if (VarNameLen != 1 || !Type)                                                  /* Not single letter or not a numeric variable ? */
    {
        fprintf (ErrStream, "ERROR in line %d, statement %d - Wrong variable type\n", BasicLineNo, StatementNo);
        return (FALSE);
    }
    return (TRUE);
}

bool HandleClass05 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 5 = A set of items may be given.                                                                                         */
/**********************************************************************************************************************************/

{
    bool Type;
    bool More = TRUE;
    int  VarNameLen;
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 5, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    while (More)
    {
        while (**Index == ';' || **Index == ',' || **Index == '\'' || **Index == '~')
        /* One of the separator characters ? */
            (*Index) ++;                                                                                  /* (More than one may follow) */
        if (**Index == ':' || **Index == 0x0D)                                                   /* End of statement or end of line ? */
            More = FALSE;
        else if (**Index == '#')                                                                                        /* A stream ? */
        {
            (*Index) ++;                                                                                    /* (Step past the '#' mark) */
            if (!ScanStream (BasicLineNo, StatementNo, Keyword, Index))
                return (FALSE);
        }
        else if (TokenMap[**Index].TokenType == 2 ||                                                          /* A colour parameter ? */
                 **Index == 0xAD)                                                                                            /* TAB ? */
        {
            (*Index) ++;                                                                                            /* (Skip the token) */
            if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))                       /* Find parameter (numeric expression) */
                return (FALSE);
        }
        else if (**Index == 0xAC)                                                                                             /* AT ? */
        {
            (*Index) ++;                                                                                            /* (Skip the token) */
            if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))                 /* Find first parameter (numeric expression) */
                return (FALSE);
            if (CheckEnd (BasicLineNo, StatementNo, Index))
                return (FALSE);
            if (**Index != ',')                                                                           /* (Required separator token) */
            {
                BADTOKEN ("\",\"", TokenMap[**Index].Token);
                return (FALSE);
            }
            (*Index) ++;                                                                                            /* (Skip the token) */
            if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))                /* Find second parameter (numeric expression) */
                return (FALSE);
        }
        else if (Keyword == 0xEE && **Index == 0xCA)                                                            /* INPUT may use LINE */
        {
            (*Index) ++;                                                                                            /* (Skip the token) */
            if (!ScanVariable (BasicLineNo, StatementNo, Keyword, Index, &Type, &VarNameLen, 0))
            {
                if (VarNameLen == 0)
                    BADTOKEN ("variable", TokenMap[**Index].Token);
                return (FALSE);
            }
            if (Type)                                                                                  /* Not a alphanumeric variable ? */
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - INPUT LINE requires an alphanumeric variable\n",
                         BasicLineNo, StatementNo);
                return (FALSE);
            }
        }
        else if (!ScanExpression (BasicLineNo, StatementNo, Keyword, Index, &Type, 0))                              /* Get expression */
            return (FALSE);
        if (**Index == ':' || **Index == 0x0D)                                                   /* End of statement or end of line ? */
            More = FALSE;
        if (More)
            if (**Index != ';' && **Index != ',' && **Index != '\'')                              /* One of the separator characters ? */
            {
                BADTOKEN ("separator \";\", \",\" or \"\'\"", TokenMap[**Index].Token);
                return (FALSE);
            }
    }
    return (TRUE);
}

bool HandleClass06 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 6 = A numeric expression must follow.                                                                                    */
/**********************************************************************************************************************************/

{
    bool Type=TRUE;
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 6, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    if (!ScanExpression (BasicLineNo, StatementNo, Keyword, Index, &Type, 0))                                     /* Get expression */
        return (FALSE);
    if (!Type && Keyword != 0xC0)                                                                                /* Must be numeric */
    {
        fprintf (ErrStream, "ERROR in line %d, statement %d - Expected numeric expression\n", BasicLineNo, StatementNo);
        return (FALSE);
    }
    return (TRUE);
}

bool HandleClass07 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 7 = Handles colour items.                                                                                                */
/* Effectively the same as Class 6                                                                                                */
/**********************************************************************************************************************************/

{
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 7, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    return (HandleClass06 (BasicLineNo, StatementNo, Keyword, Index));                                   /* Find numeric expression */
}

bool HandleClass08 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 8 = Two numeric expressions, separated by a comma, must follow.                                                          */
/**********************************************************************************************************************************/

{
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 8, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))                                 /* Find first numeric expression */
        return (FALSE);
    if (**Index != ',')
    {
        BADTOKEN ("\",\"", TokenMap[**Index].Token);
        return (FALSE);
    }
    (*Index) ++;
    return (HandleClass06 (BasicLineNo, StatementNo, Keyword, Index));                            /* Find second numeric expression */
}

bool HandleClass09 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 9 = As for class 8 but colour items may precede the expression.                                                          */
/* Used only by PLOT and DRAW. Colour items are TokenType 2                                                                       */
/**********************************************************************************************************************************/

{
    bool CheckColour = TRUE;
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 9, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    while (CheckColour)
    {
        if (CheckEnd (BasicLineNo, StatementNo, Index))
            return (FALSE);
        if (TokenMap[**Index].TokenType == 2)                                                                 /* A colour parameter ? */
        {
            (*Index) ++;                                                                                              /* Skip the token */
            if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))                       /* Find parameter (numeric expression) */
                return (FALSE);
            if (CheckEnd (BasicLineNo, StatementNo, Index))
                return (FALSE);
            if (**Index != ';')                                              /* All colour parameters must be separated with semicolons */
            {
                BADTOKEN ("\";\"", TokenMap[**Index].Token);
                return (FALSE);
            }
            (*Index) ++;                                                                                                /* Skip the ";' */
        }
        else
            CheckColour = FALSE;
    }
    if (CheckEnd (BasicLineNo, StatementNo, Index))
        return (FALSE);
    return (HandleClass08 (BasicLineNo, StatementNo, Keyword, Index));
}

bool HandleClass10 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 10 = A string expression must follow.                                                                                    */
/**********************************************************************************************************************************/

{
    bool Type;
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 10, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    if (!ScanExpression (BasicLineNo, StatementNo, Keyword, Index, &Type, 0))                                     /* Get expression */
        return (FALSE);
    if (Type)                                                                                                     /* Must be string */
    {
        fprintf (ErrStream, "ERROR in line %d, statement %d - Expected string expression\n", BasicLineNo, StatementNo);
        return (FALSE);
    }
    return (TRUE);
}

bool HandleClass11 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 11 = Handles cassette routines.                                                                                          */
/**********************************************************************************************************************************/

{
    bool Type;
    int  VarNameLen;
    int  MoveLoop;
    byte WhichChannel = '\0';                                                                  /* (Default is no channel; for tape) */
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 11, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    switch (Keyword)
    {
        case 0xEF:                                                                                                          /* (LOAD) */
        case 0xD6:                                                                                                        /* (VERIFY) */
        case 0xD5: if (**Index == '*')                                                                                     /* (MERGE) */
        {
            (*Index) ++;
            if (!ScanChannel (BasicLineNo, StatementNo, Keyword, Index, &WhichChannel))
                return (FALSE);
            if (WhichChannel != 'm' && WhichChannel != 'b' && WhichChannel != 'n')
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - You cannot LOAD/VERIFY/MERGE from the \"%s\" channel\n",
                         BasicLineNo, StatementNo, TokenMap[WhichChannel].Token);
                return (FALSE);
            }
        }
        else if (**Index == '!')                                                                        /* 128K RAM-bank ? */
        {
            (*Index) ++;
            switch (Is48KProgram)                                                           /* Then the program must be 128K */
            {
                case -1 : Is48KProgram = 0; break;                                                             /* Set the flag */
                case  1 : fprintf (ErrStream, "ERROR - Line %d contains 128K file I/O, but the program\n"
                                   "also uses UDGs \'T\' and/or \'U\'\n", BasicLineNo);
                    return (FALSE);
                case  0 : break;
            }
        }
            if (WhichChannel != '\0' && WhichChannel != 'm')                         /* Not tape nor microdrive/disk channel ? */
            {
                if (**Index != ':' && **Index != 0x0D &&                                                   /* (End of statement) */
                    **Index != 0xAF &&                                                                                 /* (CODE) */
                    **Index != 0xE4 &&                                                                                 /* (DATA) */
                    **Index != 0xCA &&                                                                                 /* (LINE) */
                    **Index != 0xAA)                                                                                /* (SCREEN$) */
                {
                    fprintf (ErrStream, "ERROR in line %d, statement %d - The \"%s\" channel does not use filenames\n",
                             BasicLineNo, StatementNo, TokenMap[WhichChannel].Token);
                    return (FALSE);
                }
            }
            else
            {
                if (**Index == '\"')                                                                      /* Look for a filename */
                {
                    while (**Index == '\"')            /* Concatenated strings are ok, since they allow the use of the " character */
                    {                                                             /* (And an empty string is allowed here as well) */
                        while (*(++ (*Index)) != '\"')                                                         /* Find closing quote */
                            if (**Index == 0x0D)                                                                      /* End of line ? */
                            {
                                fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected end of line\n", BasicLineNo, StatementNo);
                                return (FALSE);
                            }
                        (*Index) ++;                                                                                 /* Step past it */
                    }
                }
                else if (**Index == ':' || **Index == 0x0D ||                                              /* (End of statement) */
                         **Index == 0xAF ||                                                                            /* (CODE) */
                         **Index == 0xE4 ||                                                                            /* (DATA) */
                         **Index == 0xCA ||                                                                            /* (LINE) */
                         **Index == 0xAA)                                                                           /* (SCREEN$) */
                {
                    BADTOKEN ("filename", TokenMap[**Index].Token);
                    return (FALSE);
                }
                else if (!HandleClass10 (BasicLineNo, StatementNo, Keyword, Index))              /* Look for a string expression */
                    return (FALSE);
            }
            if (**Index != ':' && **Index != 0x0D)                                       /* (Continue unless end of statement) */
            {
                if (**Index == 0xAF)                                                                                     /* CODE */
                {
                    if (Keyword == 0xD5)                                                                /* (We were doing MERGE ?) */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - Cannot MERGE CODE\n", BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    (*Index) ++;
                    if (**Index != ':' && **Index != 0x0D)                                                   /* Optional address ? */
                    {
                        if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))          /* Find address (numeric expression) */
                            return (FALSE);
                        if (**Index == ',')                                                                /* Also optional length ? */
                        {
                            (*Index) ++;
                            if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))         /* Find length (numeric expression) */
                                return (FALSE);
                        }
                        else if (**Index != ':' && **Index != 0x0D)
                        {
                            BADTOKEN ("\",\"", TokenMap[**Index].Token);
                            return (FALSE);
                        }
                    }
                }
                else if (**Index == 0xAA)                                                                             /* SCREEN$ */
                    (*Index) ++;
                else if (**Index == 0xE4)                                                                                /* DATA */
                {
                    (*Index) ++;
                    if (CheckEnd (BasicLineNo, StatementNo, Index))
                        return (FALSE);
                    if (!ScanVariable (BasicLineNo, StatementNo, Keyword, Index, &Type, &VarNameLen, -1))
                    {
                        if (VarNameLen == 0)
                            BADTOKEN ("variable", TokenMap[**Index].Token);
                        return (FALSE);
                    }
                    if (VarNameLen != 1)                                                                    /* Not single letter ? */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - Wrong variable type; must be single character\n",
                                 BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    if (**Index != '(')                                         /* The variable must be followed by an empty index */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - DATA requires an array\n",
                                 BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    (*Index) ++;
                    if (**Index != ')')
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - DATA requires an empty array index\n",
                                 BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    (*Index) ++;
                }
                else
                {
                    fprintf (ErrStream, "ERROR in line %d, statement %d - Unknown file-type \"%s\"\n",
                             BasicLineNo, StatementNo, TokenMap[**Index].Token);
                    return (FALSE);
                }
            }
            break;
        case 0xF8: if (**Index == '*')                                                                                      /* (SAVE) */
        {
            (*Index) ++;
            if (!ScanChannel (BasicLineNo, StatementNo, Keyword, Index, &WhichChannel))
                return (FALSE);
            if (WhichChannel != 'm' && WhichChannel != 'b' && WhichChannel != 'n')
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - You cannot SAVE to the \"%s\" channel\n",
                         BasicLineNo, StatementNo, TokenMap[WhichChannel].Token);
                return (FALSE);
            }
        }
        else if (**Index == '!')                                                                        /* 128K RAM-bank ? */
        {
            (*Index) ++;
            switch (Is48KProgram)                                                           /* Then the program must be 128K */
            {
                case -1 : Is48KProgram = 0; break;                                                             /* Set the flag */
                case  1 : fprintf (ErrStream, "ERROR - Line %d contains 128K file I/O, but the program\n"
                                   "also uses UDGs \'T\' and/or \'U\'\n", BasicLineNo);
                    return (FALSE);
                case  0 : break;
            }
        }
            if (WhichChannel != '\0' && WhichChannel != 'm')                         /* Not tape nor microdrive/disk channel ? */
            {
                if (**Index != ':' && **Index != 0x0D &&                                                   /* (End of statement) */
                    **Index != 0xAF &&                                                                                 /* (CODE) */
                    **Index != 0xE4 &&                                                                                 /* (DATA) */
                    **Index != 0xCA &&                                                                                 /* (LINE) */
                    **Index != 0xAA)                                                                                /* (SCREEN$) */
                {
                    fprintf (ErrStream, "ERROR in line %d, statement %d - The \"%s\" channel does not use filenames\n",
                             BasicLineNo, StatementNo, TokenMap[WhichChannel].Token);
                    return (FALSE);
                }
            }
            else
            {
                if (**Index == '\"')                                                                      /* Look for a filename */
                {
                    if (*(*Index + 1) == '\"' &&                                                   /* Empty string (not allowed) ? */
                        *(*Index + 2) != '\"')                                    /* Concatenation - first char is a " (allowed) ? */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - Empty filename not allowed\n", BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    while (**Index == '\"')            /* Concatenated strings are ok, since they allow the use of the " character */
                    {
                        while (*(++ (*Index)) != '\"')                                                         /* Find closing quote */
                            if (**Index == 0x0D)                                                                      /* End of line ? */
                            {
                                fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected end of line\n", BasicLineNo, StatementNo);
                                return (FALSE);
                            }
                        (*Index) ++;                                                                                 /* Step past it */
                    }
                }
                else if (**Index == ':' || **Index == 0x0D ||                                              /* (End of statement) */
                         **Index == 0xAF ||                                                                            /* (CODE) */
                         **Index == 0xE4 ||                                                                            /* (DATA) */
                         **Index == 0xCA ||                                                                            /* (LINE) */
                         **Index == 0xAA)                                                                           /* (SCREEN$) */
                {
                    BADTOKEN ("filename", TokenMap[**Index].Token);
                    return (FALSE);
                }
                else if (!HandleClass10 (BasicLineNo, StatementNo, Keyword, Index))              /* Look for a string expression */
                    return (FALSE);
            }
            if (**Index != ':' && **Index != 0x0D)                                       /* (Continue unless end of statement) */
            {
                if (**Index == 0xAF)                                                                                     /* CODE */
                {
                    (*Index) ++;
                    if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))            /* Find address (numeric expression) */
                        return (FALSE);
                    if (**Index != ',')
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - %s CODE requires both address and length\n",
                                 BasicLineNo, StatementNo, TokenMap[Keyword].Token);
                        return (FALSE);
                    }
                    (*Index) ++;
                    if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))             /* Find length (numeric expression) */
                        return (FALSE);
                }
                else if (**Index == 0xE4)                                                                                /* DATA */
                {
                    (*Index) ++;
                    if (CheckEnd (BasicLineNo, StatementNo, Index))
                        return (FALSE);
                    if (!ScanVariable (BasicLineNo, StatementNo, Keyword, Index, &Type, &VarNameLen, -1))
                    {
                        if (VarNameLen == 0)
                            BADTOKEN ("variable", TokenMap[**Index].Token);
                        return (FALSE);
                    }
                    if (VarNameLen != 1)                                                                    /* Not single letter ? */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - Wrong variable type; must be single character\n",
                                 BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    if (**Index != '(')                                         /* The variable must be followed by an empty index */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - DATA requires an array\n",
                                 BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    (*Index) ++;
                    if (**Index != ')')
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - DATA requires an empty array index\n",
                                 BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    (*Index) ++;
                }
                else if (**Index == 0xAA)                                                                             /* SCREEN$ */
                    (*Index) ++;
                else if (**Index == 0xCA)                                                                                /* LINE */
                {
                    (*Index) ++;
                    if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))      /* Find starting line (numeric expression) */
                        return (FALSE);
                }
                else
                {
                    fprintf (ErrStream, "ERROR in line %d, statement %d - Unknown file-type \"%s\"\n",
                             BasicLineNo, StatementNo, TokenMap[**Index].Token);
                    return (FALSE);
                }
            }
            break;
        case 0xCF: if (!SignalInterface1 (BasicLineNo, StatementNo, 0))                                                      /* (CAT) */
            return (FALSE);
            if (**Index == '#')                                                       /* A stream may precede the drive number */
            {
                (*Index) ++;
                if (!ScanStream (BasicLineNo, StatementNo, Keyword, Index))
                    return (FALSE);
                if (**Index != ',')                                                                /* (Required separator token) */
                {
                    BADTOKEN ("\",\"", TokenMap[**Index].Token);
                    return (FALSE);
                }
            }
            if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))           /* Find drive number (numeric expression) */
                return (FALSE);
            break;
        case 0xD0: if (!ScanChannel (BasicLineNo, StatementNo, Keyword, Index, &WhichChannel))                            /* (FORMAT) */
            return (FALSE);
            switch (WhichChannel)
        {
            case 'm' : if (CheckEnd (BasicLineNo, StatementNo, Index))         /* "m" requires an additional new volume name */
                return (FALSE);
                if (**Index == '\"')                                                        /* Look for a volume name */
                {
                    if (*(*Index + 1) == '\"' &&                                        /* Empty string (not allowed) ? */
                        *(*Index + 2) != '\"')                         /* Concatenation - first char is a " (allowed) ? */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - Empty volume name not allowed\n",
                                 BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    while (**Index == '\"') /* Concatenated strings are ok, since they allow the use of the " character */
                    {
                        while (*(++ (*Index)) != '\"')                                              /* Find closing quote */
                            if (**Index == 0x0D)                                                           /* End of line ? */
                            {
                                fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected end of line\n",
                                         BasicLineNo, StatementNo);
                                return (FALSE);
                            }
                        (*Index) ++;                                                                      /* Step past it */
                    }
                }
                else if (!HandleClass10 (BasicLineNo, StatementNo, Keyword, Index))   /* Look for a string expression */
                    return (FALSE);
                break;
            case 't' :                                                 /* The port channels requires an additional baud rate */
            case 'b' :
            case 'j' : if (**Index != ';')                   /* The joystick channel requires a operand to turn it on or off */
            {
                BADTOKEN ("\";\"", TokenMap[**Index].Token);
                return (FALSE);
            }
                (*Index) ++;
                if (CheckEnd (BasicLineNo, StatementNo, Index))
                    return (FALSE);
                if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))       /* Look for a numeric expression */
                    return (FALSE);
                break;
            default  : fprintf (ErrStream, "ERROR in line %d, statement %d - You cannot FORMAT from the \"%s\" channel\n",
                                BasicLineNo, StatementNo, TokenMap[WhichChannel].Token);
                return (FALSE);
        }
            break;
        case 0xD1: for (MoveLoop = 0 ; MoveLoop < 2 ; MoveLoop ++)                                                          /* (MOVE) */
        {
            if (**Index == '#')
            {
                (*Index) ++;                                                                       /* (Step past the '#' mark) */
                if (!ScanStream (BasicLineNo, StatementNo, Keyword, Index))
                    return (FALSE);
            }
            else
            {
                if (!ScanChannel (BasicLineNo, StatementNo, Keyword, Index, &WhichChannel))
                    return (FALSE);
                switch (WhichChannel)
                {
                    case 'm' : if (CheckEnd (BasicLineNo, StatementNo, Index))            /* "m" requires an additional filename */
                        return (FALSE);
                        if (**Index == '\"')                                                       /* Look for a filename */
                        {
                            if (*(*Index + 1) == '\"' &&                                    /* Empty string (not allowed) ? */
                                *(*Index + 2) != '\"')                     /* Concatenation - first char is a " (allowed) ? */
                            {
                                fprintf (ErrStream, "ERROR in line %d, statement %d - Empty filename not allowed\n",
                                         BasicLineNo, StatementNo);
                                return (FALSE);
                            }
                            while (**Index == '\"')
                            {
                                while (*(++ (*Index)) != '\"')
                                    if (**Index == 0x0D)
                                    {
                                        fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected end of line\n",
                                                 BasicLineNo, StatementNo);
                                        return (FALSE);
                                    }
                                (*Index) ++;
                            }
                        }
                        else if (!HandleClass10 (BasicLineNo, StatementNo, Keyword, Index))
                            return (FALSE);
                        break;
                    case 't' :
                    case 'b' :
                    case 'n' :
                    case 'd' : break;                                       /* All these are okay and don't use extra parameters */
                    case 's' : if (MoveLoop == 0)                                               /* The "s" channel is write-only */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - You cannot MOVE from the \"s\" channel\n",
                                 BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                        break;
                    case 'k' : if (MoveLoop == 1)                                                /* The "k" channel is read-only */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - You cannot MOVE to the \"k\" channel\n",
                                 BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                        break;
                    default  : fprintf (ErrStream, "ERROR in line %d, statement %d - You cannot MOVE from/to the \"%s\" channel\n",
                                        BasicLineNo, StatementNo, TokenMap[WhichChannel].Token);
                        return (FALSE);
                }
            }
            if (MoveLoop == 0)
            {
                if (**Index != 0xCC)                                                                    /* Required token 'TO' */
                {
                    BADTOKEN ("\"TO\"", TokenMap[**Index].Token);
                    return (FALSE);
                }
                (*Index) ++;
            }
        }
            break;
        case 0xD2: if (**Index == '!')                                                                                     /* (ERASE) */
        {                                                                                               /* 128K RAM-bank ? */
            (*Index) ++;
            switch (Is48KProgram)                                                           /* Then the program must be 128K */
            {
                case -1 : Is48KProgram = 0; break;                                                             /* Set the flag */
                case  1 : fprintf (ErrStream, "ERROR - Line %d contains 128K file I/O, but the program\n"
                                   "also uses UDGs \'T\' and/or \'U\'\n", BasicLineNo);
                    return (FALSE);
                case  0 : break;
            }
        }
        else
        {
            if (!ScanChannel (BasicLineNo, StatementNo, Keyword, Index, &WhichChannel))
                return (FALSE);
            if (WhichChannel != 'm')
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - You can only ERASE from the ! or \"m\" channel\n",
                         BasicLineNo, StatementNo);
                return (FALSE);
            }
        }
            if (CheckEnd (BasicLineNo, StatementNo, Index))                                    /* Additional filename required */
                return (FALSE);
            if (**Index == '\"')                                                                        /* Look for a filename */
            {
                if (*(*Index + 1) == '\"' &&                                                     /* Empty string (not allowed) ? */
                    *(*Index + 2) != '\"')                                      /* Concatenation - first char is a " (allowed) ? */
                {
                    fprintf (ErrStream, "ERROR in line %d, statement %d - Empty filename not allowed\n",
                             BasicLineNo, StatementNo);
                    return (FALSE);
                }
                while (**Index == '\"')
                {
                    while (*(++ (*Index)) != '\"')
                        if (**Index == 0x0D)
                        {
                            fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected end of line\n",
                                     BasicLineNo, StatementNo);
                            return (FALSE);
                        }
                    (*Index) ++;
                }
            }
            else if (!HandleClass10 (BasicLineNo, StatementNo, Keyword, Index))
                return (FALSE);
            break;
        case 0xD3: if (!ScanStream (BasicLineNo, StatementNo, Keyword, Index))                                            /* (OPEN #) */
            return (FALSE);
            if (**Index != ';' && **Index != ',')                                                          /* (Required token) */
            {
                BADTOKEN ("\";\"", TokenMap[**Index].Token);
                return (FALSE);
            }
            (*Index) ++;
            if (!ScanChannel (BasicLineNo, StatementNo, Keyword, Index, &WhichChannel))
                return (FALSE);
            switch (WhichChannel)
        {
            case 'm' : if (CheckEnd (BasicLineNo, StatementNo, Index))                /* "m" requires an additional filename */
                return (FALSE);
                if (**Index == '\"')                                                           /* Look for a filename */
                {
                    if (*(*Index + 1) == '\"' &&                                        /* Empty string (not allowed) ? */
                        *(*Index + 2) != '\"')                         /* Concatenation - first char is a " (allowed) ? */
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - Empty filename not allowed\n",
                                 BasicLineNo, StatementNo);
                        return (FALSE);
                    }
                    while (**Index == '\"')
                    {
                        while (*(++ (*Index)) != '\"')
                            if (**Index == 0x0D)
                            {
                                fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected end of line\n",
                                         BasicLineNo, StatementNo);
                                return (FALSE);
                            }
                        (*Index) ++;
                    }
                }
                else if (!HandleClass10 (BasicLineNo, StatementNo, Keyword, Index))
                    return (FALSE);
                break;
            case 's' :
            case 'k' :
            case 'p' :
            case 't' :
            case 'b' :
            case 'n' :
            case 0xAF:
            case 0xCF:
            case '#' : break;                                           /* All these are okay and don't use extra parameters */
            default  : fprintf (ErrStream, "ERROR in line %d, statement %d - You cannot attach a stream to the \"%s\" "
                                "channel\n", BasicLineNo, StatementNo, TokenMap[WhichChannel].Token);
                return (FALSE);
        }
            if (**Index != ':' && **Index != 0x0D)                                       /* (Continue unless end of statement) */
            {
                if (**Index == 0xBF)                                                                                       /* IN */
                {
                    (*Index) ++;
                    if (!SignalInterface1 (BasicLineNo, StatementNo, 2))                                  /* This is Opus specific */
                        return (FALSE);
                }
                else if (**Index == 0xDF ||                                                                               /* OUT */
                         **Index == 0xB9)                                                                                 /* EXP */
                {
                    (*Index) ++;
                    if (!SignalInterface1 (BasicLineNo, StatementNo, 2))                                  /* This is Opus specific */
                        return (FALSE);
                    if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))                      /* Find numeric expression */
                        return (FALSE);
                }
                else if (**Index == 0xA5)                                                                                 /* RND */
                {
                    (*Index) ++;
                    if (!SignalInterface1 (BasicLineNo, StatementNo, 2))                                  /* This is Opus specific */
                        return (FALSE);
                    if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))                      /* Find numeric expression */
                        return (FALSE);
                    if (**Index == ',')                                                         /* RND may take a second parameter */
                    {
                        (*Index) ++;
                        if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, Index))
                            return (FALSE);
                    }
                }
            }
            break;
        case 0xD4: if (!ScanStream (BasicLineNo, StatementNo, Keyword, Index))                                           /* (CLOSE #) */
            return (FALSE);
            break;
    }
    return (TRUE);
}

bool HandleClass12 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 12 = One or more string expressions, separated by commas, must follow.                                                   */
/**********************************************************************************************************************************/

{
    bool Type;
    bool More = TRUE;
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 12, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    while (More)
    {
        if (!ScanExpression (BasicLineNo, StatementNo, Keyword, Index, &Type, 0))                               /* Find an expression */
            return (FALSE);
        if (Type)                                                                                                   /* Must be string */
        {
            fprintf (ErrStream, "ERROR in line %d, statement %d - \"%s\" requires string parameters\n",
                     BasicLineNo, StatementNo, TokenMap[Keyword].Token);
            return (FALSE);
        }
        if (**Index == ':' || **Index == 0x0D)                                                   /* End of statement or end of line ? */
            More = FALSE;
        else if (**Index == ',')                                                                                       /* Separator ? */
            (*Index) ++;
        else if (**Index != ')')
        {
            BADTOKEN ("\",\"", TokenMap[**Index].Token);
            return (FALSE);
        }
    }
    return (TRUE);
}

bool HandleClass13 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 13 = One or more expressions, separated by commas, must follow (DATA, DIM, FN)                                           */
/**********************************************************************************************************************************/

{
    bool Type;
    bool More = TRUE;
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 13, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    if (**Index == ')' && Keyword == 0xA8)                                                  /* FN requires zero or more expressions */
        return (TRUE);                               /* (The closing bracket is a required character and stepped over in CheckSyntax) */
    while (More)
    {
        if (!ScanExpression (BasicLineNo, StatementNo, Keyword, Index, &Type, 0))                               /* Find an expression */
            return (FALSE);                                                                              /* (Don't care about the type) */
        if (Keyword == 0xE9 && !Type)                                                              /* DIM requires numeric dimensions */
        {
            fprintf (ErrStream, "ERROR in line %d, statement %d - \"DIM\" requires numeric dimensions\n", BasicLineNo, StatementNo);
            return (FALSE);
        }
        if (Keyword == 0xE9 || Keyword == 0xA8)                                              /* FN and DIM end with a closing bracket */
        {
            if (CheckEnd (BasicLineNo, StatementNo, Index))
                return (FALSE);
            if (**Index == ')')
                More = FALSE;
        }
        if (**Index == ':' || **Index == 0x0D)                                                   /* End of statement or end of line ? */
            More = FALSE;
        else if (**Index == ',')                                                                                       /* Separator ? */
            (*Index) ++;
        else if (**Index != ')')
        {
            BADTOKEN ("\",\"", TokenMap[**Index].Token);
            return (FALSE);
        }
    }
    return (TRUE);
}

bool HandleClass14 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 14 = One or more variables, separated by commas, must follow (READ)                                                      */
/**********************************************************************************************************************************/

{
    bool Type;
    bool More = TRUE;
    int  VarNameLen;
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 14, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    while (More)
    {
        if (!ScanVariable (BasicLineNo, StatementNo, Keyword, Index, &Type, &VarNameLen, 2))                    /* We need a variable */
        {
            if (VarNameLen == 0)                                                                                    /* (Not a variable) */
                BADTOKEN ("variable", TokenMap[**Index].Token);
            return (FALSE);
        }
        if (**Index == ':' || **Index == 0x0D)                                                   /* End of statement or end of line ? */
            More = FALSE;
        else if (**Index == ',')                                                                                       /* Separator ? */
            (*Index) ++;
        else
        {
            BADTOKEN ("\",\"", TokenMap[**Index].Token);
            return (FALSE);
        }
    }
    return (TRUE);
}

bool HandleClass15 (int BasicLineNo, int StatementNo, int Keyword, byte **Index)

/**********************************************************************************************************************************/
/* Class 15 = DEF FN                                                                                                              */
/**********************************************************************************************************************************/

{
    bool Type;
    int  VarNameLen;
    
#ifdef __DEBUG__
    printf ("DEBUG - %sLine %d, statement %d, Enter Class 15, keyword \"%s\", next is \"%s\"\n",
            ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[**Index].Token);
#endif
    if (!ScanVariable (BasicLineNo, StatementNo, Keyword, Index, &Type, &VarNameLen, -1))
    {
        if (VarNameLen == 0)
            BADTOKEN ("variable", TokenMap[**Index].Token);
        return (FALSE);
    }
    if (VarNameLen != 1)                                                                                     /* Not single letter ? */
    {
        fprintf (ErrStream, "ERROR in line %d, statement %d - Wrong variable type; must be single character\n",
                 BasicLineNo, StatementNo);
        return (FALSE);
    }
    if (**Index == '(')                                                 /* Arguments to be passed to the expression while running ? */
    {
        (*Index) ++;
        if (CheckEnd (BasicLineNo, StatementNo, Index))
            return (FALSE);
        if (**Index == ')')
        {
            fprintf (ErrStream, "ERROR in line %d, statement %d - Empty parameter array not allowed\n", BasicLineNo, StatementNo);
            return (FALSE);
        }
        while (**Index != ')')
        {
            if (!ScanVariable (BasicLineNo, StatementNo, Keyword, Index, &Type, &VarNameLen, -1))
            {
                if (VarNameLen == 0)
                    BADTOKEN ("variable", TokenMap[**Index].Token);
                return (FALSE);
            }
            if (VarNameLen != 1)                                                                                 /* Not single letter ? */
            {
                fprintf (ErrStream, "ERROR in line %d, statement %d - Wrong variable type; must be single character\n",
                         BasicLineNo, StatementNo);
                return (FALSE);
            }
            if (**Index != 0x0E)                                                        /* A number (marker) must follow each parameter */
            {
                BADTOKEN ("number marker", TokenMap[**Index].Token);
                return (FALSE);
            }
            (*Index) ++;                                                                                              /* (Step past it) */
            if (CheckEnd (BasicLineNo, StatementNo, Index))
                return (FALSE);
            if (**Index != ')')
            {
                if (**Index == ',')
                    (*Index) ++;
                else
                {
                    BADTOKEN ("\",\"", TokenMap[**Index].Token);
                    return (FALSE);
                }
            }
        }
        (*Index) ++;
    }
    if (CheckEnd (BasicLineNo, StatementNo, Index))
        return (FALSE);
    if (**Index != '=')
    {
        BADTOKEN ("\"=\"", TokenMap[**Index].Token);
        return (FALSE);
    }
    (*Index) ++;
    if (CheckEnd (BasicLineNo, StatementNo, Index))
        return (FALSE);
    return (ScanExpression (BasicLineNo, StatementNo, Keyword, Index, &Type, 0));                             /* Find an expression */
}

bool CheckSyntax (int BasicLineNo, byte *Line)

/**********************************************************************************************************************************/
/* Pre   : `Line' points to the converted BASIC line. An initial syntax check has been done already -                             */
/*         - The line number makes sense;                                                                                         */
/*         - Keywords are at the beginning of each statement and not within a statement;                                          */
/*         - There are less than 128 statements in the line;                                                                      */
/*         - Brackets match on a per-line basis (but not necessarily on a per-statement basis!)                                   */
/*         - Quotes match;                                                                                                        */
/* Post  : The line has been checked against 'normal' Spectrum BASIC syntax. Extended devices that change the normal syntax       */
/*         (such as Interface 1 or disk interfaces) are not understood and will generate error messages.                          */
/* Import: None.                                                                                                                  */
/**********************************************************************************************************************************/

{
    byte  StrippedLine[MAXLINELENGTH + 1];
    byte *StrippedIndex;
    byte  Keyword;
    bool  AllOk       = TRUE;
    bool  VarType;
    int   StatementNo = 0;
    int   ClassIndex  = -1;
    
    StrippedIndex = &(StrippedLine[0]);
    while (*Line != 0x0D)                                          /* First clean up the line, dropping number expansions and trash */
    {
        switch (*Line)
        {
            //case  0 :
            //case  1 :
            //case  2 :
            //case  3 :
            //case  4 :
            case  5 : // ON ERROR is handled elsewhere
            case  6 :
            case  7 :
            case  8 :
            case  9 :
            case 10 :
            case 11 :
            case 12 :
            case 13 : break;
            case 14 : *(StrippedIndex ++) = *Line; Line += 5; break;                 /* EXCEPTION: keep the marker, but drop the number */
            case 15 : break;
            case 16 :
            case 17 :
            case 18 :
            case 19 :
            case 20 :
            case 21 : Line ++; break;
            case 22 :
            case 23 : Line += 2; break;
            case 24 :
            case 25 :
            case 26 :
            case 27 :
            case 28 :
            case 29 :
            case 30 :
            case 31 :
            case 32 : break;                                                                      /* (We don't care for spaces either!) */
            default : *(StrippedIndex ++) = *Line; break;                                                   /* Pass on only 'good' bits */
        }
        Line ++;
    }
    *(StrippedIndex ++) = 0x0D;
    *StrippedIndex = '\0';
    StrippedIndex = &(StrippedLine[0]);                                                                         /* Ok, here goes... */
    while (AllOk && *StrippedIndex != 0x0D)                                                                /* Handle each statement */
    {
        StatementNo ++;
        Keyword = *(StrippedIndex ++);
        if (Keyword == 0xEA)                                                                            /* 'REM' ? */
            return (TRUE);                                                                        /* Then we're done checking this line */
        if (TokenMap[Keyword].TokenType != 0 && TokenMap[Keyword].TokenType != 1 && TokenMap[Keyword].TokenType != 2)     /* (Sanity) */
        {
            if (Keyword == 0xA9)                                                             /* EXCEPTION: POINT may be used as command */
            {
                if (*StrippedIndex != '#')                                                /* It must be followed by a stream in that case */
                {
                    fprintf (ErrStream, "ERROR - Keyword (\"%s\") error in line %d, statement %d\n",
                             TokenMap[Keyword].Token, BasicLineNo, StatementNo);
                    return (FALSE);
                }
                StrippedIndex ++;
                if (!ScanStream (BasicLineNo, StatementNo, Keyword, &StrippedIndex))       /* (Also signals Interface1/Opus specificness) */
                    return (FALSE);
                if (*StrippedIndex != ';')
                {
                    BADTOKEN ("\";\"", TokenMap[*StrippedIndex].Token);
                    return (FALSE);
                }
                StrippedIndex ++;
                if (!HandleClass06 (BasicLineNo, StatementNo, Keyword, &StrippedIndex))
                    return (FALSE);
            }
            else
            {
                fprintf (ErrStream, "ERROR - Keyword (\"%s\") error in line %d, statement %d\n",
                         TokenMap[Keyword].Token, BasicLineNo, StatementNo);
                return (FALSE);
            }
        }
        else
        {
            ClassIndex = -1;
#ifdef __DEBUG__
            RecurseLevel = 0;
            ListSpaces[0] = '\0';
            printf ("DEBUG - Start Line %d, Statement %d, Keyword \"%s\"\n", BasicLineNo, StatementNo, TokenMap[Keyword].Token);
#endif
            if ((Keyword == 0xE1 || Keyword == 0xF0) && *StrippedIndex == '#')           /* EXCEPTION: LIST and LLIST may take a stream */
            {
                StrippedIndex ++;
                if (!ScanStream (BasicLineNo, StatementNo, Keyword, &StrippedIndex))       /* (Also signals Interface1/Opus specificness) */
                    return (FALSE);
                if (*StrippedIndex != ':' && *StrippedIndex != 0x0D)                                       /* Line number is not required */
                {
                    if (*StrippedIndex != ',')
                    {
                        BADTOKEN ("\",\"", TokenMap[*StrippedIndex].Token);
                        return (FALSE);
                    }
                    StrippedIndex ++;
                }
            }
            while (AllOk && TokenMap[Keyword].KeywordClass[++ ClassIndex])                               /* Handle all class parameters */
            {
                if (*StrippedIndex == 0x0D)
                {
                    if (TokenMap[Keyword].KeywordClass[ClassIndex] != 3 &&                        /* Class 5 and 3 need 0 or more arguments */
                        TokenMap[Keyword].KeywordClass[ClassIndex] != 5)
                    {
                        if ((Keyword == 0xEB && TokenMap[Keyword].KeywordClass[ClassIndex] == 0xCD) || /* 'FOR' doesn't need 'STEP' parameter */
                            (Keyword == 0xFC && TokenMap[Keyword].KeywordClass[ClassIndex] == ','))  /* 'DRAW' doesn't need a third parameter */
                            ClassIndex ++;
                        else
                        {
                            fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected end of line\n", BasicLineNo, StatementNo);
                            AllOk = FALSE;
                        }
                    }
                }
                else if (TokenMap[Keyword].KeywordClass[ClassIndex] >= 32)                                   /* Required token or class ? */
                {
                    if (*StrippedIndex != TokenMap[Keyword].KeywordClass[ClassIndex])                                   /* (Required token) */
                    {
                        if ((Keyword == 0xEB && TokenMap[Keyword].KeywordClass[ClassIndex] == 0xCD && *StrippedIndex == ':') ||
                            (Keyword == 0xFC && TokenMap[Keyword].KeywordClass[ClassIndex] == ',' && *StrippedIndex == ':'))
                            ClassIndex ++;                                            /* EXCEPTION: 'FOR' does not require the 'STEP' parameter */
                        /* EXCEPTION: 'DRAW' does not require the third parameter */
                        else
                        {                                                                                                /* (Token not there) */
                            fprintf (ErrStream, "ERROR in line %d, statement %d - Expected \"%s\", but got \"%s\"\n",
                                     BasicLineNo, StatementNo, TokenMap[TokenMap[Keyword].KeywordClass[ClassIndex]].Token,
                                     TokenMap[*StrippedIndex].Token);
                            AllOk = FALSE;
                        }
                    }
                    else
                        StrippedIndex ++;
                }
                else                                                                                                   /* (Command class) */
                    switch (TokenMap[Keyword].KeywordClass[ClassIndex])
                {
                    case  1 : AllOk = HandleClass01 (BasicLineNo, StatementNo, Keyword, &StrippedIndex, &VarType); break;
                    case  2 : AllOk = HandleClass02 (BasicLineNo, StatementNo, Keyword, &StrippedIndex, VarType); break;
                    case  3 : AllOk = HandleClass03 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                    case  4 : AllOk = HandleClass04 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                    case  5 : AllOk = HandleClass05 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                    case  6 : AllOk = HandleClass06 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                    case  7 : AllOk = HandleClass07 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                    case  8 : AllOk = HandleClass08 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                    case  9 : AllOk = HandleClass09 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                    case 10 : AllOk = HandleClass10 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                    case 11 : AllOk = HandleClass11 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                    case 13 : AllOk = HandleClass13 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                    case 14 : AllOk = HandleClass14 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                    case 15 : AllOk = HandleClass15 (BasicLineNo, StatementNo, Keyword, &StrippedIndex); break;
                }
            }
        }
        if (AllOk && Keyword != 0xFA)                                        /* Handling 'IF' and AllOk (i.e. just read the "THEN" ?) */
        {                                                                                        /* (Nope, go check end of statement) */
            if (*StrippedIndex != ':' && *StrippedIndex != 0x0D)
            {
                if (Keyword == 0xFB && *StrippedIndex == '#')                                            /* EXCEPTION: 'CLS #' is allowed */
                {
                    StrippedIndex ++;
                    if (!SignalInterface1 (BasicLineNo, StatementNo, 0))
                        return (FALSE);
                    if (*StrippedIndex != ':' && *StrippedIndex != 0x0D)
                    {
                        fprintf (ErrStream, "ERROR in line %d, statement %d - Expected end of statement, but got \"%s\"\n",
                                 BasicLineNo, StatementNo, TokenMap[*StrippedIndex].Token);
                        AllOk = FALSE;
                    }
                }
                else
                {
                    fprintf (ErrStream, "ERROR in line %d, statement %d - Expected end of statement, but got \"%s\"\n",
                             BasicLineNo, StatementNo, TokenMap[*StrippedIndex].Token);
                    AllOk = FALSE;
                }
            }
        }
        if (AllOk && *StrippedIndex == ':')               /* (Placing this check here allows weird (but legal) construction "THEN :") */
        {
            StrippedIndex ++;
            while (*StrippedIndex == ':')                                              /* (More consecutive ':' separators are allowed) */
            {
                StrippedIndex ++;
                StatementNo ++;
            }
        }
    }
    return (AllOk);
}

int main (int argc, char **argv)

/**********************************************************************************************************************************/
/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MAIN PROGRAM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
/* Import: MatchToken, HandleNumbers, ExpandSequences, PrepareLine, CheckSyntax.                                                  */
/**********************************************************************************************************************************/

{
    FILE *FpIn;
    FILE *FpOut;
    char  FileNameIn[256]  = "\0";
    char  FileNameOut[256] = "\0";
    char  LineIn[MAXLINELENGTH + 1];                                                           /* One line read from the ASCII file */
    char *BasicIndex;                                                        /* Current scan position in the (converted) ASCII line */
    byte *ResultIndex;                                                          /* Current write index in to the binary result line */
    byte  Token;
    int   LineCount        = 0;                                                                     /* Line count in the ASCII file */
    int   BasicLineNo;                                                                                 /* Current BASIC line number */
    int   SubLineCount;                                                                                 /* Current statement number */
    bool  ExpectKeyword;                                                       /* If TRUE, the next scanned token must be a keyword */
    bool  InString;                                                                                     /* TRUE while inside quotes */
    int   BracketCount     = 0;                                                               /* Match opening and closing brackets */
    int   AutoStart;                                                             /* Auto-start line as provided on the command line */
    int   ObjectLength;                                                                      /* Binary length of one converted line */
    int   BlockSize        = 0;                                                                      /* Total size of the TAP block */
    byte  Parity           = 0;                                                                             /* Overall block parity */
    bool  AllOk            = TRUE;
    bool  EndOfFile        = FALSE;
    bool  WriteError       = FALSE;                                                     /* Fingers crossed that this stays FALSE... */
    size_t Size;
    int   Cnt;
    
    ErrStream = stderr;
    Cnt = 1;
    for (Cnt = 1 ; Cnt < argc && AllOk; Cnt ++)                                                    /* Do all command line arguments */
    {
        if (argv[Cnt][0] == '-')
            switch (tolower (argv[Cnt][1]))
        {
            case 'c' : CaseIndependant = TRUE; break;
            case 'w' : NoWarnings = TRUE; break;
            case 'q' : Quiet = TRUE; break;
            case 'n' : DoCheckSyntax = FALSE; break;
            case 'e' : ErrStream = stdout; break;
            case 'a' : AutoStart = atoi (argv[Cnt] + 2);
                if (AutoStart < 0 || AutoStart >= 16384)
                {
                    fprintf (ErrStream, "Invalid auto-start line number %d\n", AutoStart);
                    exit (1);
                }
                TapeHeader.HStartLo = (byte)(AutoStart & 0xFF);
                TapeHeader.HStartHi = (byte)(AutoStart >> 8);
                break;
            case 's' : if (strlen (argv[Cnt] + 2) > 10)
            {
                fprintf (ErrStream, "Spectrum blockname too long \"%s\"\n", argv[Cnt] + 2);
                exit (1);
            }
                strncpy (TapeHeader.HName, argv[Cnt] + 2, strlen (argv[Cnt] + 2));
                break;
            default  : fprintf (ErrStream, "Unknown switch \'%c\'\n", argv[Cnt][1]);
        }
        else if (FileNameIn[0] == '\0')
            strcpy (FileNameIn, argv[Cnt]);
        else if (FileNameOut[0] == '\0')
            strcpy (FileNameOut, argv[Cnt]);
        else
            AllOk = FALSE;
    }
    if (FileNameIn[0] == '\0')                                                                         /* We do need an input file! */
        AllOk = FALSE;
    if (!Quiet || !AllOk)
        printf ("\nSE2TAP\n(Based on BAS2TAP v2.5 by Martijn van der Heide of ThunderWare Research Center)\n\n");
    if (!AllOk)
    {
        printf ("Usage: SE2TAP [-q] [-w] [-e] [-c] [-aX] [-sX] FileIn [FileOut]\n");
        printf ("       -q = quiet: no banner, no progress indication\n");
        printf ("       -w = suppress generation of warnings\n");
        printf ("       -e = write errors to stdout in stead of stderr channel\n");
        printf ("       -c = case independant tokens (be careful here!)\n");
        printf ("       -n = disable syntax checking\n");
        printf ("       -a = set auto-start line in BASIC header\n");
        printf ("       -s = set \"filename\" in BASIC header\n");
        exit (1);
    }
    if (FileNameOut[0] == '\0')
        strcpy (FileNameOut, FileNameIn);
    Size = strlen (FileNameOut);
    while (-- Size > 0 && FileNameOut[Size] != '.')
        ;
    if (Size == 0)                                                                                                /* No extension ? */
        strcat (FileNameOut, ".tap");
    else if (strcmp (FileNameOut + Size, ".tap") && strcmp (FileNameOut + Size, ".TAP"))
        strcpy (FileNameOut + Size, ".tap");
    if (!Quiet)
        printf ("Creating output file %s\n",FileNameOut);
    if ((FpIn = fopen (FileNameIn, "rt")) == NULL)
    {
        perror ("ERROR - Cannot open source file");
        exit (1);
    }
    if ((FpOut = fopen (FileNameOut, "wb")) == NULL)
    {
        perror ("ERROR - Cannot create output file");
        fclose (FpIn);
        exit (1);
    }
    Parity = TapeHeader.Flag2;
    if (fwrite (&TapeHeader, 1, sizeof (struct TapeHeader_s), FpOut) < sizeof (struct TapeHeader_s))
    { AllOk = FALSE; WriteError = TRUE; }                                                        /* Write dummy header to get space */
    while (AllOk && !EndOfFile)
    {
        if (fgets (LineIn, MAXLINELENGTH + 1, FpIn) != NULL)
        {
            LineCount ++;
            if (strlen (LineIn) >= MAXLINELENGTH)
            {                                                                                 /* We don't require an end-of-line marker */
                fprintf (ErrStream, "ERROR - Line %d too long\n", LineCount);
                AllOk = FALSE;
            }
            else if ((BasicLineNo = PrepareLine (LineIn, LineCount, &BasicIndex)) < 0)
            {
                if (BasicLineNo == -1)                                                                                         /* (Error) */
                    AllOk = FALSE;
                else                                                                                   /* (Line should simply be skipped) */
                    ;
            }
            else if (BasicLineNo >= 16384)
            {
                fprintf (ErrStream, "ERROR - Line number %d is larger than the maximum allowed\n", BasicLineNo);
                AllOk = FALSE;
            }
            else
            {
                if (!Quiet)
                {
                    printf ("\rConverting line %4d -> %4d\r", LineCount, BasicLineNo);
                    fflush (stdout);                                                      /* (Force line without end-of-line to be printed) */
                }
                InString = FALSE;
                ExpectKeyword = TRUE;
                SubLineCount = 1;
                ResultIndex = ResultingLine + 4;                                              /* Reserve space for line number and length */
                HandlingDEFFN = FALSE;
                while (*BasicIndex && AllOk)
                {
                    if (InString)
                    {
                        if (*BasicIndex == '\"')
                        {
                            InString = FALSE;
                            *(ResultIndex ++) = *(BasicIndex ++);
                            while (*BasicIndex == ' ')                                                                  /* Skip trailing spaces */
                                BasicIndex ++;
                        }
                        else
                            switch (ExpandSequences (BasicLineNo, &BasicIndex, &ResultIndex, FALSE))
                        {
                            case -1 : AllOk = FALSE; break;                                                     /* (Error - already reported) */
                            case  0 : *(ResultIndex ++) = *(BasicIndex ++); break;                                     /* (No expansion made) */
                            case  1 : break;
                        }
                    }
                    else if (*BasicIndex == '\"')
                    {
                        if (ExpectKeyword)
                        {
                            fprintf (ErrStream, "ERROR in line %d, statement %d - Expected keyword but got quote\n", BasicLineNo, SubLineCount);
                            AllOk = FALSE;
                        }
                        else
                        {
                            InString = TRUE;
                            *(ResultIndex ++) = *(BasicIndex ++);
                        }
                    }
                    else if (ExpectKeyword)
                    {
                        switch (MatchToken (BasicLineNo, TRUE, &BasicIndex, &Token))
                        {
                            case -2 : AllOk = FALSE; break;                                                       /* (Error - already reported) */
                            case -1 : fprintf (ErrStream, "ERROR in line %d, statement %d - Expected keyword but got token \"%s\"\n",
                                               BasicLineNo, SubLineCount, TokenMap[Token].Token);                              /* (Not keyword) */
                                AllOk = FALSE;
                                break;
                            case  0 : fprintf (ErrStream, "ERROR in line %d, statement %d - Expected keyword but got \"%s\"\n",   /* (No match) */
                                               BasicLineNo, SubLineCount, TokenMap[(byte)(*BasicIndex)].Token);
                                AllOk = FALSE;
                                break;
                            case  1 : *(ResultIndex ++) = Token;                                                             /* (Found keyword) */
                                if (Token != ':' && Token != 0x05)                                                   /* Special exception; empty statement */
                                    ExpectKeyword = FALSE;
                                if (Token == DEFFN)
                                {
                                    HandlingDEFFN = TRUE;
                                    InsideDEFFN = FALSE;
                                }
                                if (Token == 0xEA)                                             /* Special exception; REM */
                                    while (*BasicIndex)                                 /* Simply copy over the remaining part of the line, */
                                    /* disregarding token or number expansions */
                                    /* As brackets aren't tested for, the match counting stops here */
                                    /* (a closing bracket in a REM statement will not be seen by BASIC) */
                                        switch (ExpandSequences (BasicLineNo, &BasicIndex, &ResultIndex, FALSE))
                                    {
                                        case -1 : AllOk = FALSE; break;
                                        case  0 : *(ResultIndex ++) = *(BasicIndex ++); break;
                                        case  1 : break;
                                    }
                                break;
                        }
                    }
                    else if (*BasicIndex == '(')                                                                         /* Opening bracket */
                    {
                        BracketCount ++;
                        *(ResultIndex ++) = *(BasicIndex ++);
                        if (HandlingDEFFN && !InsideDEFFN)
#ifdef __DEBUG__
                        {
                            printf ("DEBUG - %sDEFFN, Going inside parameter list\n", ListSpaces);
                            InsideDEFFN = TRUE;                                                           /* Signal: require special treatment! */
                        }
#else
                        InsideDEFFN = TRUE;                                                           /* Signal: require special treatment! */
#endif
                    }
                    else if (*BasicIndex == ')')                                                                         /* Closing bracket */
                    {
                        if (HandlingDEFFN && InsideDEFFN)
                        {
#ifdef __DEBUG__
                            printf ("DEBUG - %sDEFFN, Done parameter list\n", ListSpaces);
                            InsideDEFFN = TRUE;                                                           /* Signal: require special treatment! */
#endif
                            *(ResultIndex ++) = 0x0E;                                          /* Insert room for the evaluator (call by value) */
                            *(ResultIndex ++) = 0x00;
                            *(ResultIndex ++) = 0x00;
                            *(ResultIndex ++) = 0x00;
                            *(ResultIndex ++) = 0x00;
                            *(ResultIndex ++) = 0x00;
                            InsideDEFFN = FALSE;                                                               /* Mark end of special treatment */
                            HandlingDEFFN = FALSE;                                             /* (The part after the '=' is just like eg. LET) */
                        }
                        if (-- BracketCount < 0)                                                        /* More closing than opening brackets */
                        {
                            fprintf (ErrStream, "ERROR in line %d, statement %d - Too many closing brackets\n", BasicLineNo, SubLineCount);
                            AllOk = FALSE;
                        }
                        else
                            *(ResultIndex ++) = *(BasicIndex ++);
                    }
                    else if (*BasicIndex == ',' && HandlingDEFFN && InsideDEFFN)
                    {
#ifdef __DEBUG__
                        printf ("DEBUG - %sDEFFN, Done parameter; another follows\n", ListSpaces);
#endif
                        *(ResultIndex ++) = 0x0E;                                            /* Insert room for the evaluator (call by value) */
                        *(ResultIndex ++) = 0x00;
                        *(ResultIndex ++) = 0x00;
                        *(ResultIndex ++) = 0x00;
                        *(ResultIndex ++) = 0x00;
                        *(ResultIndex ++) = 0x00;
                        *(ResultIndex ++) = *(BasicIndex ++);                                                          /* (Copy over the ',') */
                    }
                    else
                        switch (MatchToken (BasicLineNo, FALSE, &BasicIndex, &Token))
                    {
                        case -2 : AllOk = FALSE; break;                                                       /* (Error - already reported) */
                        case -1 : fprintf (ErrStream, "ERROR in line %d, statement %d - Unexpected keyword \"%s\"\n",/* (Match but keyword) */
                                           BasicLineNo, SubLineCount, TokenMap[Token].Token);
                            AllOk = FALSE;
                            break;
                        case  0 : switch (HandleNumbers (BasicLineNo, &BasicIndex, &ResultIndex))                             /* (No token) */
                        {
                            case 0 :  switch (ExpandSequences (BasicLineNo, &BasicIndex, &ResultIndex, TRUE))        /* (No number) */
                            {
                                case -1 : AllOk = FALSE; break;                               /* (Error - already reported) */
                                case  0 : if (isalpha (*BasicIndex))                                 /* (No expansion made) */
                                    while (isalnum (*BasicIndex))                    /* Skip full strings in one go */
                                        *(ResultIndex ++) = *(BasicIndex ++);
                                else
                                    *(ResultIndex ++) = *(BasicIndex ++);
                                    break;
                                case  1 : break;
                            }
                                break;
                            case -1 : AllOk = FALSE; break;
                        }
                            break;
                        case  1 : *(ResultIndex ++) = Token;                                                   /* (Found token, no keyword) */
                            if (Token == ':' || Token == 0xCB || Token == 0x05)
                            {
                                ExpectKeyword = TRUE;
                                HandlingDEFFN = FALSE;
                                if (BracketCount != 0)                                                          /* All brackets match ? */
                                {
                                    fprintf (ErrStream, "ERROR in line %d, statement %d - Too few closing brackets\n",
                                             BasicLineNo, SubLineCount);
                                    AllOk = FALSE;
                                }
                                if (++ SubLineCount > 127)
                                {
                                    fprintf (ErrStream, "ERROR - Line %d has too many statements\n", BasicLineNo);
                                    AllOk = FALSE;
                                }
                            }
                            else if (Token == 0xC4)                                                                            /* BIN */
                            {
                                if (HandleBIN (BasicLineNo, &BasicIndex, &ResultIndex) == -1)
                                    AllOk = FALSE;
                            }
                            break;
                    }
                }
                *(ResultIndex ++) = 0x0D;
                if (AllOk && BracketCount != 0)                                                                   /* All brackets match ? */
                {
                    fprintf (ErrStream, "ERROR in line %d, statement %d - Too few closing brackets\n", BasicLineNo, SubLineCount);
                    AllOk = FALSE;
                }
                if (AllOk && DoCheckSyntax)
                    AllOk = CheckSyntax (BasicLineNo, ResultingLine + 4);                           /* Check the syntax of the decoded line */
                if (AllOk)
                {
                    ObjectLength = (int)(ResultIndex - ResultingLine);
                    ResultingLine[0] = (byte)(BasicLineNo >> 8);                                             /* Line number is put reversed */
                    ResultingLine[1] = (byte)(BasicLineNo & 0xFF);
                    ResultingLine[2] = (byte)((ObjectLength - 4) & 0xFF);                                 /* Make sure this runs on any CPU */
                    ResultingLine[3] = (byte)((ObjectLength - 4) >> 8);
                    BlockSize += ObjectLength;
                    for (Cnt = 0 ; Cnt < ObjectLength ; Cnt ++)
                        Parity ^= ResultingLine[Cnt];
                    if (BlockSize > 41500)                                                       /* (= 65368-23755-<some work/stack space>) */
                    {
                        fprintf (ErrStream, "ERROR - Object file too large at line %d!\n", BasicLineNo);
                        AllOk = FALSE;
                    }
                    else
                        if (fwrite (ResultingLine, 1, ObjectLength, FpOut) != ObjectLength)
                        { AllOk = FALSE; WriteError = TRUE; }
                }
            }
        }
        else
            EndOfFile = TRUE;
    }
    if (!Quiet)
    {
        printf ("\r                                     \r");
        fflush (stdout);
    }
    if (!WriteError)                             /* Finish the TAP file no matter what went wrong, unless it was the writing itself */
    {
        ResultingLine[0] = Parity;                                               /* Now it's time to write the 'real' header in front */
        if (fwrite (ResultingLine, 1, 1, FpOut) < 1)
        {
            perror ("ERROR - Write error");
            fclose (FpIn);
            fclose (FpOut);
            exit (1);
        }
        TapeHeader.HLenLo = TapeHeader.HBasLenLo = (byte)(BlockSize & 0xFF);
        TapeHeader.HLenHi = TapeHeader.HBasLenHi = (byte)(BlockSize >> 8);
        TapeHeader.LenLo2 = (byte)((BlockSize + 2) & 0xFF);
        TapeHeader.LenHi2 = (byte)((BlockSize + 2) >> 8);
        Parity = 0;
        for (Cnt = 2 ; Cnt < 20 ; Cnt ++)
            Parity ^= *((byte *)&TapeHeader + Cnt);
        TapeHeader.Parity1 = Parity;
        fseek (FpOut, 0, SEEK_SET);
        if (fwrite (&TapeHeader, 1, sizeof (struct TapeHeader_s), FpOut) < sizeof (struct TapeHeader_s))
        {
            perror ("ERROR - Write error");
            exit (1);
        }
        if (!Quiet)
        {
            if (AllOk)
                printf ("Done! Listing contains %d %s.\n", LineCount, LineCount == 1 ? "line" : "lines");
            else
                printf ("Listing as far as done contains %d %s.\n", LineCount - 1, LineCount == 2 ? "line" : "lines");
            if (Is48KProgram >= 0)
                printf ("Note: this program can only be used in %dK mode\n", Is48KProgram ? 48 : 128);
            switch (UsesInterface1)
            {
                case -1 : break;                                                                                       /* Neither of them */
                case 0  : printf ("Note: this program requires Interface 1 or Opus Discovery\n"); break;
                case 1  : printf ("Note: this program requires Interface 1\n"); break;
                case 2  : printf ("Note: this program requires an Opus Discovery"); break;
            }
        }
    }
    else
        perror ("ERROR - Write error");
    fclose (FpIn);
    fclose (FpOut);
    return (0);                                                                                     /* (Keep weird compilers happy) */
}