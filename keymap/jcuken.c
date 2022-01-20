/*
SE Basic IV 4.2 Cordelia - A classic BASIC interpreter for the Z80 architecture.
Copyright (c) 1999-2020 Source Solutions, Inc.

SE Basic IV is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

SE Basic IV is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty o;
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SE Basic IV. If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>

typedef unsigned char BYTE;
/*
    8        8   
AAADDDDD AAADDDDD

AAA      = semi-key of the keyboard to be modified               | this information is
DDDDD    = data (AND denied with what there is) of that semifila | repeated for two keys

For example: in the memory address corresponding to the code of the ESC key,
that would correspond to the simultaneous press of CAPS SHIFT + SPACE, we would put:
00000001 11100001
This is: semifilas 0 and 7 are activated, and in each, bit 0 is activated

128 codes + E0 = 256 codes
SHIFT, CTRL, ALT = 8 combinations

256 * 8 = 2048 addresses x 16 bits = 32768 bits
In the core it will be available as a memory of 4096 x 8 bits

Each key will occupy two consecutive addresses.
D + 0: key1 (or 0 if there is none)
D + 1: key2 (or 0 if there is none)
*/

// You shouldn't have to touch these defs unless you modify SE Basic IV.
#define SE_1       0x61
#define SE_2       0x62
#define SE_3       0x64
#define SE_4       0x68
#define SE_5       0x70

#define SE_0       0x81
#define SE_9       0x82
#define SE_8       0x84
#define SE_7       0x88
#define SE_6       0x90

#define SE_Q       0x41
#define SE_W       0x42
#define SE_E       0x44
#define SE_R       0x48
#define SE_T       0x50

#define SE_P       0xA1
#define SE_O       0xA2
#define SE_I       0xA4
#define SE_U       0xA8
#define SE_Y       0xB0

#define SE_A       0x21
#define SE_S       0x22
#define SE_D       0x24
#define SE_F       0x28
#define SE_G       0x30

#define SE_ENTER   0xC1
#define SE_L       0xC2
#define SE_K       0xC4
#define SE_J       0xC8
#define SE_H       0xD0

#define SE_CAPS    0x01
#define SE_Z       0x02
#define SE_X       0x04
#define SE_C       0x08
#define SE_V       0x10

#define SE_SPACE   0xE1
#define SE_SYMBOL  0xE2
#define SE_M       0xE4
#define SE_N       0xE8
#define SE_B       0xF0

#define SE_BANG    (SE_SYMBOL<<8) | SE_1
#define SE_AT      (SE_SYMBOL<<8) | SE_2
#define SE_HASH    (SE_SYMBOL<<8) | SE_3
#define SE_DOLLAR  (SE_SYMBOL<<8) | SE_4
#define SE_PERCEN  (SE_SYMBOL<<8) | SE_5
#define SE_AMP     (SE_SYMBOL<<8) | SE_6
#define SE_APOSTRO (SE_SYMBOL<<8) | SE_7
#define SE_PAROPEN (SE_SYMBOL<<8) | SE_8
#define SE_PARCLOS (SE_SYMBOL<<8) | SE_9
#define SE_UNDERSC (SE_SYMBOL<<8) | SE_0
#define SE_LESS    (SE_SYMBOL<<8) | SE_R
#define SE_LESSEQ  (SE_SYMBOL<<8) | SE_Q
#define SE_GREATER (SE_SYMBOL<<8) | SE_T
#define SE_GREATEQ (SE_SYMBOL<<8) | SE_E
#define SE_NOTEQ   (SE_SYMBOL<<8) | SE_W
#define SE_BRAOPEN (SE_SYMBOL<<8) | SE_Y
#define SE_BRACLOS (SE_SYMBOL<<8) | SE_U
#define SE_SEMICOL (SE_SYMBOL<<8) | SE_O
#define SE_QUOTE   (SE_SYMBOL<<8) | SE_P
#define SE_TILDE   (SE_SYMBOL<<8) | SE_A
#define SE_PIPE    (SE_SYMBOL<<8) | SE_S
#define SE_BACKSLA (SE_SYMBOL<<8) | SE_D
#define SE_CUROPEN (SE_SYMBOL<<8) | SE_F
#define SE_CURCLOS (SE_SYMBOL<<8) | SE_G
#define SE_CARET   (SE_SYMBOL<<8) | SE_H
#define SE_MINUS   (SE_SYMBOL<<8) | SE_J
#define SE_PLUS    (SE_SYMBOL<<8) | SE_K
#define SE_EQUAL   (SE_SYMBOL<<8) | SE_L
#define SE_COLON   (SE_SYMBOL<<8) | SE_Z
#define SE_POUND   (SE_SYMBOL<<8) | SE_X
#define SE_QUEST   (SE_SYMBOL<<8) | SE_C
#define SE_SLASH   (SE_SYMBOL<<8) | SE_V
#define SE_STAR    (SE_SYMBOL<<8) | SE_B
#define SE_COMMA   (SE_SYMBOL<<8) | SE_N
#define SE_DOT     (SE_SYMBOL<<8) | SE_M

#define SE_EXTEND  (SE_CAPS<<8) | SE_SYMBOL
#define SE_EDIT    (SE_CAPS<<8) | SE_1
#define SE_CPSLOCK (SE_CAPS<<8) | SE_2
#define SE_TRUE    (SE_CAPS<<8) | SE_3
#define SE_INVERSE (SE_CAPS<<8) | SE_4
#define SE_LEFT    (SE_CAPS<<8) | SE_5
#define SE_DOWN    (SE_CAPS<<8) | SE_6
#define SE_UP      (SE_CAPS<<8) | SE_7
#define SE_RIGHT   (SE_CAPS<<8) | SE_8
#define SE_GRAPH   (SE_CAPS<<8) | SE_9
#define SE_DELETE  (SE_CAPS<<8) | SE_0
#define SE_BREAK   (SE_CAPS<<8) | SE_SPACE

#define SE_HELP		(SE_SYMBOL<<8) | SE_SPACE
#define SE_INSERT	(SE_SYMBOL<<8) | SE_I
#define SE_CLR		(SE_SYMBOL<<8) | SE_ENTER
#define SE_HOME		(SE_SYMBOL<<8) | SE_Q
#define SE_DEL		(SE_SYMBOL<<8) | SE_W
#define SE_END		(SE_SYMBOL<<8) | SE_E
#define SE_COMPOSE	(SE_CAPS<<8) | SE_ENTER

// END of matrix keys definitions


// A key can be pressed with up to three key modifiers
// which generates 8 combinations for each key
#define EXT        0x080
#define MD_SHIFT   0x100
#define MD_CTRL    0x200
#define MD_ALT     0x400

// Scan code 2 list. First, non localized keys

// chloe layout
#define PC_ESC		0x0e        // key to left of '1'
#define PC_CPSLOCK  0x14		// LCTRL on PC
#define PC_LCTRL    0x58		// CAPS LOCK on PC
#define PC_GRAVEAC  0x61        // also ~
#define PC_F0		0x76		// key to left of 'F1'

// us layout
//#define PC_GRAVEAC  0x0e        // key to left of '1'
//#define PC_LCTRL    0x14		//
//#define PC_CPSLOCK  0x58		//
//#define PC_F0		0x61		// non-US keyboards will not generate this code
//#define PC_ESC		0x76        // key to left of 'F1'

#define PC_A       0x1C
#define PC_B       0x32
#define PC_C       0x21
#define PC_D       0x23
#define PC_E       0x24
#define PC_F       0x2B
#define PC_G       0x34
#define PC_H       0x33
#define PC_I       0x43
#define PC_J       0x3B
#define PC_K       0x42
#define PC_L       0x4B
#define PC_M       0x3A
#define PC_N       0x31
#define PC_O       0x44
#define PC_P       0x4D
#define PC_Q       0x15
#define PC_R       0x2D
#define PC_S       0x1B
#define PC_T       0x2C
#define PC_U       0x3C
#define PC_V       0x2A
#define PC_W       0x1D
#define PC_X       0x22
#define PC_Y       0x35
#define PC_Z       0x1A

#define PC_0       0x45  // also )
#define PC_1       0x16  // also !
#define PC_2       0x1E  // also @
#define PC_3       0x26  // also #
#define PC_4       0x25  // also $
#define PC_5       0x2E  // also %
#define PC_6       0x36  // also ^
#define PC_7       0x3D  // also &
#define PC_8       0x3E  // also *
#define PC_9       0x46  // also (

#define PC_F1      0x05
#define PC_F2      0x06
#define PC_F3      0x04
#define PC_F4      0x0C
#define PC_F5      0x03
#define PC_F6      0x0B
//#define PC_F7      0x83  // not used. scan code>7F
#define PC_F8      0x0A
#define PC_F9      0x01
#define PC_F10     0x09
#define PC_F11     0x78
#define PC_F12     0x07
#define PC_F13      0x7C | EXT	// PR SCR
#define PC_F14		0x7E		// SCR LK
#define PC_F15      0x77 | EXT	// PAUSE

#define PC_SPACE   0x29
#define PC_RCTRL   0x14 | EXT
#define PC_LSHIFT  0x12
#define PC_RSHIFT  0x59
#define PC_LALT    0x11
#define PC_RALT    0x11 | EXT
#define PC_LWIN    0x1F | EXT
#define PC_RWIN    0x27 | EXT
#define PC_APPS    0x2F | EXT

#define PC_TAB     0x0D
#define PC_SCRLOCK 0x7E

#define PC_INSERT  0x70 | EXT
#define PC_DELETE  0x71 | EXT
#define PC_HOME    0x6C | EXT
#define PC_END     0x69 | EXT
#define PC_PGUP    0x7D | EXT
#define PC_PGDOWN  0x7A | EXT
#define PC_BKSPACE 0x66
#define PC_ENTER   0x5A
#define PC_UP      0x75 | EXT
#define PC_DOWN    0x72 | EXT
#define PC_LEFT    0x6B | EXT
#define PC_RIGHT   0x74 | EXT

#define PC_NUMLOCK  0x77
#define PC_KP_DIVIS 0x4A | EXT
#define PC_KP_MULT  0x7C
#define PC_KP_MINUS 0x7B
#define PC_KP_PLUS  0x79
#define PC_KP_ENTER 0x5A | EXT
#define PC_KP_DOT   0x71
#define PC_KP_0     0x70
#define PC_KP_1     0x69
#define PC_KP_2     0x72
#define PC_KP_3     0x7A
#define PC_KP_4     0x6B
#define PC_KP_5     0x73
#define PC_KP_6     0x74
#define PC_KP_7     0x6C
#define PC_KP_8     0x75
#define PC_KP_9     0x7D

// Localized keyboards start to differenciate from here

// Localized keyboard US
#define PC_MINUS   0x4E   // also _
#define PC_EQUAL   0x55   // also +
#define PC_BRAOPEN 0x54   // also {
#define PC_BRACLOS 0x5B   // also }
#define PC_BACKSLA 0x5D   // also |
#define PC_SEMICOL 0x4C   // also :
#define PC_APOSTRO 0x52   // also "
#define PC_COMMA   0x41   // also <
#define PC_DOT     0x49   // also >
#define PC_SLASH   0x4A   // also ?

#define MAP(pc,sp) {                                                          \
                           rom[(pc)*2] = (((sp)>>8)&0xFF);                    \
                           rom[(pc)*2+1] = (((sp))&0xFF);                     \
                         }
                         
#define MAPANY(pc,sp)   {                                                     \
                               MAP((pc),(sp));                                \
                               MAP(MD_SHIFT|(pc),(sp));                       \
                               MAP(MD_CTRL|(pc),(sp));                        \
                               MAP(MD_ALT|(pc),(sp));                         \
                               MAP(MD_SHIFT|MD_CTRL|(pc),(sp));               \
                               MAP(MD_SHIFT|MD_ALT|(pc),(sp));                \
                               MAP(MD_CTRL|MD_ALT|(pc),(sp));                 \
                               MAP(MD_SHIFT|MD_CTRL|MD_ALT|(pc),(sp));        \
                            }
                         
#define CLEANMAP {                                                            \
                    int i;                                                    \
                    for (i=0;i<(sizeof(rom)/sizeof(rom[0]));i++)              \
                      rom[i] = 0;                                             \
                 }
#define SAVEMAP1HEX(name) {                                                   \
                           FILE *f;                                           \
                           int i;                                             \
                           f=fopen(name,"w");                                 \
                           for(i=0;i<(sizeof(rom)/sizeof(rom[0]));i+=2)       \
                             fprintf(f,"%.2X\n",rom[i]);                      \
                           fclose(f);                                         \
                         }

#define SAVEMAP2HEX(name) {                                                   \
                           FILE *f;                                           \
                           int i;                                             \
                           f=fopen(name,"w");                                 \
                           for(i=1;i<(sizeof(rom)/sizeof(rom[0]));i+=2)       \
                               fprintf(f,"%.2X\n",rom[i]);                    \
                           fclose(f);                                         \
                         }

#define SAVEMAPBIN(name) {                                                      \
                           FILE *f;                                             \
                           f=fopen(name,"wb");                                  \
                           fwrite (rom, 1, sizeof(rom), f);                     \
                           fclose(f);                                           \
                         }


int main()
{
    BYTE rom[4096];

    CLEANMAP;

    MAPANY(PC_LCTRL,SE_GRAPH);   // MD2 is CTRL
    MAPANY(PC_RCTRL,SE_GRAPH); // MD2 is CTRL
    MAPANY(PC_LALT,SE_EXTEND);    // MD3 is ALT. Also is FIRE for keyboard joystick
    MAPANY(PC_RALT,SE_EXTEND);    // MD3 is ALT. Also is FIRE for keyboard joystick
    
    MAPANY(PC_LWIN,SE_SYMBOL);          // SYMBOL SHIFT
    MAPANY(PC_RWIN,SE_SYMBOL);          // SYMBOL SHIFT  
	MAPANY(PC_APPS,SE_COMPOSE);          //  

    // Basic mapping: each key from PC is mapped to a key in the Chloe
	// row 1
    MAP(PC_1,SE_1);
    MAP(PC_2,SE_2);
    MAP(PC_3,SE_3);
    MAP(PC_4,SE_4);
    MAP(PC_5,SE_5);
    MAP(PC_6,SE_6);
    MAP(PC_7,SE_7);
    MAP(PC_8,SE_8);
    MAP(PC_9,SE_9);
    MAP(PC_0,SE_0);
    MAP(MD_SHIFT|PC_1,SE_BANG);
    MAP(MD_SHIFT|PC_2,SE_QUOTE);
    MAP(MD_SHIFT|PC_3,SE_HASH);
    MAP(MD_SHIFT|PC_4,SE_DOLLAR);
    MAP(MD_SHIFT|PC_5,SE_PERCEN);
    MAP(MD_SHIFT|PC_6,SE_COLON);
    MAP(MD_SHIFT|PC_7,SE_AMP);
    MAP(MD_SHIFT|PC_8,SE_STAR);
    MAP(MD_SHIFT|PC_9,SE_PAROPEN);
    MAP(MD_SHIFT|PC_0,SE_PARCLOS);
    MAP(PC_MINUS,SE_MINUS);
    MAP(MD_SHIFT|PC_MINUS,SE_SEMICOL);
    MAP(PC_EQUAL,SE_EQUAL);
    MAP(MD_SHIFT|PC_EQUAL,SE_PLUS);

	// row 2
    MAP(PC_Q,SE_J);
    MAP(PC_W,SE_C);
    MAP(PC_E,SE_U);
    MAP(PC_R,SE_K);
    MAP(PC_T,SE_E);
    MAP(PC_Y,SE_N);
    MAP(PC_U,SE_G);
    MAP(PC_I,SE_BRAOPEN);
    MAP(PC_O,SE_BRACLOS);
    MAP(PC_P,SE_Z);
    MAP(PC_BRAOPEN,SE_H);
    MAP(PC_BRACLOS,SE_UNDERSC);
    MAP(MD_SHIFT|PC_Q,SE_CAPS<<8|SE_J);
    MAP(MD_SHIFT|PC_W,SE_CAPS<<8|SE_C);
    MAP(MD_SHIFT|PC_E,SE_CAPS<<8|SE_U);
    MAP(MD_SHIFT|PC_R,SE_CAPS<<8|SE_K);
    MAP(MD_SHIFT|PC_T,SE_CAPS<<8|SE_E);
    MAP(MD_SHIFT|PC_Y,SE_CAPS<<8|SE_N);
    MAP(MD_SHIFT|PC_U,SE_CAPS<<8|SE_G);
    MAP(MD_SHIFT|PC_I,SE_CUROPEN);
    MAP(MD_SHIFT|PC_O,SE_CURCLOS);
    MAP(MD_SHIFT|PC_P,SE_CAPS<<8|SE_Z);
    MAP(MD_SHIFT|PC_BRAOPEN,SE_CAPS<<8|SE_H);
    MAP(MD_SHIFT|PC_BRACLOS,SE_APOSTRO);
 
	// row 3
    MAP(PC_A,SE_F);
    MAP(PC_S,SE_Y);
    MAP(PC_D,SE_W);
    MAP(PC_F,SE_A);
    MAP(PC_G,SE_P);
    MAP(PC_H,SE_R);
    MAP(PC_J,SE_O);
    MAP(PC_K,SE_L);
    MAP(PC_L,SE_D);
    MAP(PC_SEMICOL,SE_V);
    MAP(PC_APOSTRO,SE_BACKSLA);
    MAP(PC_BACKSLA,SE_DOT);
    MAP(MD_SHIFT|PC_A,SE_CAPS<<8|SE_A);
    MAP(MD_SHIFT|PC_S,SE_CAPS<<8|SE_S);
    MAP(MD_SHIFT|PC_D,SE_CAPS<<8|SE_D);
    MAP(MD_SHIFT|PC_F,SE_CAPS<<8|SE_F);
    MAP(MD_SHIFT|PC_G,SE_CAPS<<8|SE_G);
    MAP(MD_SHIFT|PC_H,SE_CAPS<<8|SE_H);
    MAP(MD_SHIFT|PC_J,SE_CAPS<<8|SE_J);
    MAP(MD_SHIFT|PC_K,SE_CAPS<<8|SE_K);
    MAP(MD_SHIFT|PC_L,SE_CAPS<<8|SE_L);
    MAP(MD_SHIFT|PC_SEMICOL,SE_CAPS<<8|SE_V);
    MAP(MD_SHIFT|PC_APOSTRO,SE_PIPE);
    MAP(MD_SHIFT|PC_BACKSLA,SE_COMMA);

	// row 4
    MAP(PC_GRAVEAC,SE_LESS);
    MAP(MD_SHIFT|PC_GRAVEAC,SE_GREATER);
    MAP(PC_Z,SE_Q);
    MAP(PC_X,SE_CARET);
    MAP(PC_C,SE_S);
    MAP(PC_V,SE_M);
    MAP(PC_B,SE_I);
    MAP(PC_N,SE_T);
    MAP(PC_M,SE_X);
    MAP(PC_COMMA,SE_B);
    MAP(PC_DOT,SE_POUND);
    MAP(PC_SLASH,SE_SLASH);
    MAP(MD_SHIFT|PC_Z,SE_CAPS<<8|SE_Q);
    MAP(MD_SHIFT|PC_X,SE_TILDE);
    MAP(MD_SHIFT|PC_C,SE_CAPS<<8|SE_S);
    MAP(MD_SHIFT|PC_V,SE_CAPS<<8|SE_M);
    MAP(MD_SHIFT|PC_B,SE_CAPS<<8|SE_I);
    MAP(MD_SHIFT|PC_N,SE_CAPS<<8|SE_T);
    MAP(MD_SHIFT|PC_M,SE_CAPS<<8|SE_X);
    MAP(MD_SHIFT|PC_COMMA,SE_CAPS<<8|SE_B);
    MAP(MD_SHIFT|PC_DOT,SE_AT);
    MAP(MD_SHIFT|PC_SLASH,SE_QUEST);

    // complex mapping
    MAPANY(PC_SPACE,SE_SPACE);
    MAPANY(PC_ENTER,SE_ENTER);
    MAPANY(PC_ESC,SE_BREAK);
    MAPANY(PC_CPSLOCK,SE_CPSLOCK);
    MAPANY(PC_TAB,SE_EXTEND);
    MAP(PC_BKSPACE,SE_DELETE);
    MAPANY(PC_UP,SE_UP);
    MAPANY(PC_DOWN,SE_DOWN);
    MAPANY(PC_LEFT,SE_LEFT);
    MAPANY(PC_RIGHT,SE_RIGHT);

	// keypad
    MAPANY(PC_KP_DIVIS,SE_SLASH);
    MAPANY(PC_KP_MULT,SE_STAR);
    MAPANY(PC_KP_MINUS,SE_MINUS);
    MAPANY(PC_KP_PLUS,SE_PLUS);
    MAPANY(PC_KP_ENTER,SE_ENTER);    
    MAPANY(PC_KP_DOT,SE_DOT); 

    MAPANY(PC_KP_7,SE_7);
    MAPANY(PC_KP_8,SE_8);
    MAPANY(PC_KP_9,SE_9);
    MAPANY(PC_KP_4,SE_4);
    MAPANY(PC_KP_5,SE_5);
    MAPANY(PC_KP_6,SE_6);
    MAPANY(PC_KP_1,SE_1);
    MAPANY(PC_KP_2,SE_2);
    MAPANY(PC_KP_3,SE_3);


	// editing cluster
	MAP(PC_INSERT,SE_INSERT);
	MAP(MD_SHIFT|PC_INSERT,SE_HELP);
	MAPANY(PC_DELETE,SE_DEL);
	MAP(PC_HOME,SE_HOME);
	MAP(MD_SHIFT|PC_HOME,SE_CLR);
	MAPANY(PC_END,SE_END);
	MAPANY(PC_PGUP,SE_TRUE);
	MAPANY(PC_PGDOWN,SE_INVERSE);

    // End of mapping. Save .HEX file for Verilog
    //SAVEMAP1HEX("keyb1_us_hex.txt");
    //SAVEMAP2HEX("keyb2_us_hex.txt");
    // And map file for loading from ESXDOS

    SAVEMAPBIN("../ChloeVM.app/Contents/Resources/chloehd/SYSTEM/KEYBOARD.S/JCUKEN.KB");
	
	return 0;
}