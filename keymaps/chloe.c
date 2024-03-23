/*
SE Basic IV 4.2 Cordelia - A classic BASIC interpreter for the Z80 architecture.
Copyright (c) 1999-2024 Source Solutions, Inc.

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
                    for (i=0;i<(4096/1);i++)              \
                      rom[i] = 0;                                             \
                 }
#define SAVEMAP1HEX(name) {                                                   \
                           FILE *f;                                           \
                           int i;                                             \
                           f=fopen(name,"w");                                 \
                           for(i=0;i<(4096/1);i+=2)       \
                             fprintf(f,"%.2X\n",rom[i]);                      \
                           fclose(f);                                         \
                         }

#define SAVEMAP2HEX(name) {                                                   \
                           FILE *f;                                           \
                           int i;                                             \
                           f=fopen(name,"w");                                 \
                           for(i=1;i<(4096/1);i+=2)       \
                               fprintf(f,"%.2X\n",rom[i]);                    \
                           fclose(f);                                         \
                         }

#define SAVEMAPBIN(name) {                                                      \
                           FILE *f;                                             \
                           f=fopen(name,"wb");                                  \
                           fwrite (rom, 1, 4096, f);                     \
                           fclose(f);                                           \
                         }


int main()
{
    BYTE rom[4096 * 100];

    CLEANMAP;
puts("1");
    MAPANY(PC_LCTRL,SE_GRAPH);   // MD2 is CTRL
puts("2");
    MAPANY(PC_RCTRL,SE_GRAPH); // MD2 is CTRL
puts("3");
    MAPANY(PC_LALT,SE_EXTEND);    // MD3 is ALT. Also is FIRE for keyboard joystick
puts("4");
    MAPANY(PC_RALT,SE_EXTEND);    // MD3 is ALT. Also is FIRE for keyboard joystick
puts("5");
    
    MAPANY(PC_LWIN,SE_SYMBOL);          // SYMBOL SHIFT
puts("6");
    MAPANY(PC_RWIN,SE_SYMBOL);          // SYMBOL SHIFT  
puts("7");
    MAPANY(PC_APPS,SE_COMPOSE);          //  
puts("8");

    // Basic mapping: each key from PC is mapped to a key in the Chloe
    MAP(PC_1,SE_1); puts("9");
    MAP(PC_2,SE_2); puts("10");
    MAP(PC_3,SE_3); puts("11");
    MAP(PC_4,SE_4); puts("12");
    MAP(PC_5,SE_5); puts("13");
    MAP(PC_6,SE_6); puts("14");
    MAP(PC_7,SE_7); puts("15");
    MAP(PC_8,SE_8); puts("16");
    MAP(PC_9,SE_9); puts("17");
    MAP(PC_0,SE_0); puts("18");

    MAP(PC_Q,SE_Q); puts("19");
    MAP(PC_W,SE_W); puts("20");
    MAP(PC_E,SE_E); puts("21");
    MAP(PC_R,SE_R); puts("22");
    MAP(PC_T,SE_T); puts("23");
    MAP(PC_Y,SE_Y); puts("24");
    MAP(PC_U,SE_U); puts("25");
    MAP(PC_I,SE_I); puts("26");
    MAP(PC_O,SE_O); puts("27");
    MAP(PC_P,SE_P); puts("28");
    MAP(PC_A,SE_A); puts("29");
    MAP(PC_S,SE_S); puts("30");
    MAP(PC_D,SE_D); puts("31");
    MAP(PC_F,SE_F); puts("32");
    MAP(PC_G,SE_G); puts("33");
    MAP(PC_H,SE_H); puts("34");
    MAP(PC_J,SE_J); puts("35");
    MAP(PC_K,SE_K); puts("36");
    MAP(PC_L,SE_L); puts("37");
    MAP(PC_Z,SE_Z); puts("38");
    MAP(PC_X,SE_X); puts("39");
    MAP(PC_C,SE_C); puts("40");
    MAP(PC_V,SE_V); puts("41");
    MAP(PC_B,SE_B); puts("42");
    MAP(PC_N,SE_N); puts("43");
    MAP(PC_M,SE_M); puts("44");

    MAP(PC_GRAVEAC,SE_POUND); puts("45");
    MAP(MD_SHIFT|PC_GRAVEAC,SE_TILDE); puts("46");

    MAP(MD_SHIFT|PC_Q,SE_CAPS<<8|SE_Q); puts("47");
    MAP(MD_SHIFT|PC_W,SE_CAPS<<8|SE_W); puts("48");
    MAP(MD_SHIFT|PC_E,SE_CAPS<<8|SE_E); puts("49");
    MAP(MD_SHIFT|PC_R,SE_CAPS<<8|SE_R); puts("50");
    MAP(MD_SHIFT|PC_T,SE_CAPS<<8|SE_T); puts("51");
    MAP(MD_SHIFT|PC_Y,SE_CAPS<<8|SE_Y); puts("52");
    MAP(MD_SHIFT|PC_U,SE_CAPS<<8|SE_U); puts("53");
    MAP(MD_SHIFT|PC_I,SE_CAPS<<8|SE_I); puts("54");
    MAP(MD_SHIFT|PC_O,SE_CAPS<<8|SE_O); puts("55");
    MAP(MD_SHIFT|PC_P,SE_CAPS<<8|SE_P); puts("56");
    MAP(MD_SHIFT|PC_A,SE_CAPS<<8|SE_A); puts("57");
    MAP(MD_SHIFT|PC_S,SE_CAPS<<8|SE_S); puts("58");
    MAP(MD_SHIFT|PC_D,SE_CAPS<<8|SE_D); puts("59");
    MAP(MD_SHIFT|PC_F,SE_CAPS<<8|SE_F); puts("60");
    MAP(MD_SHIFT|PC_G,SE_CAPS<<8|SE_G); puts("61");
    MAP(MD_SHIFT|PC_H,SE_CAPS<<8|SE_H); puts("62");
    MAP(MD_SHIFT|PC_J,SE_CAPS<<8|SE_J); puts("63");
    MAP(MD_SHIFT|PC_K,SE_CAPS<<8|SE_K); puts("64");
    MAP(MD_SHIFT|PC_L,SE_CAPS<<8|SE_L); puts("65");
    MAP(MD_SHIFT|PC_Z,SE_CAPS<<8|SE_Z); puts("66");
    MAP(MD_SHIFT|PC_X,SE_CAPS<<8|SE_X); puts("67");
    MAP(MD_SHIFT|PC_C,SE_CAPS<<8|SE_C); puts("68");
    MAP(MD_SHIFT|PC_V,SE_CAPS<<8|SE_V); puts("69");
    MAP(MD_SHIFT|PC_B,SE_CAPS<<8|SE_B); puts("70");
    MAP(MD_SHIFT|PC_N,SE_CAPS<<8|SE_N); puts("71");
    MAP(MD_SHIFT|PC_M,SE_CAPS<<8|SE_M); puts("72");

    MAPANY(PC_SPACE,SE_SPACE); puts("73");
    MAPANY(PC_ENTER,SE_ENTER); puts("74");

    //Complex mapping. This is for the US keyboard although many
    //combos can be used with any other PC keyboard
    MAPANY(PC_ESC,SE_BREAK); puts("75");
    MAPANY(PC_CPSLOCK,SE_CPSLOCK); puts("76");
    MAPANY(PC_TAB,SE_EXTEND); puts("77");
    MAP(PC_BKSPACE,SE_DELETE); puts("78");
    MAPANY(PC_UP,SE_UP); puts("79");
    MAPANY(PC_DOWN,SE_DOWN); puts("80");
    MAPANY(PC_LEFT,SE_LEFT); puts("81");
    MAPANY(PC_RIGHT,SE_RIGHT); puts("82");


    //keypad
    MAPANY(PC_KP_DIVIS,SE_SLASH); puts("83");
    MAPANY(PC_KP_MULT,SE_STAR); puts("84");
    MAPANY(PC_KP_MINUS,SE_MINUS); puts("85");
    MAPANY(PC_KP_PLUS,SE_PLUS); puts("86");
    MAPANY(PC_KP_ENTER,SE_ENTER); puts("87");
    MAPANY(PC_KP_DOT,SE_DOT);  puts("88");

    MAPANY(PC_KP_7,SE_7); puts("89");
    MAPANY(PC_KP_8,SE_8); puts("90");
    MAPANY(PC_KP_9,SE_9); puts("91");
    MAPANY(PC_KP_4,SE_4); puts("92");
    MAPANY(PC_KP_5,SE_5); puts("93");
    MAPANY(PC_KP_6,SE_6); puts("94");
    MAPANY(PC_KP_1,SE_1); puts("95");
    MAPANY(PC_KP_2,SE_2); puts("96");
    MAPANY(PC_KP_3,SE_3); puts("97");

    //Some keys and shift+key mappings for the US keyboard
    MAP(MD_SHIFT|PC_1,SE_BANG); puts("98");
    MAP(MD_SHIFT|PC_2,SE_AT); puts("99");
    MAP(MD_SHIFT|PC_3,SE_HASH); puts("100");
    MAP(MD_SHIFT|PC_4,SE_DOLLAR); puts("101");
    MAP(MD_SHIFT|PC_5,SE_PERCEN); puts("102");
    MAP(MD_SHIFT|PC_6,SE_CARET); puts("103");
    MAP(MD_SHIFT|PC_7,SE_AMP); puts("104");
    MAP(MD_SHIFT|PC_8,SE_STAR); puts("105");
    MAP(MD_SHIFT|PC_9,SE_PAROPEN); puts("106");
    MAP(MD_SHIFT|PC_0,SE_PARCLOS); puts("107");
    MAP(PC_MINUS,SE_MINUS); puts("108");
    MAP(MD_SHIFT|PC_MINUS,SE_UNDERSC); puts("109");
    MAP(PC_EQUAL,SE_EQUAL); puts("110");
    MAP(MD_SHIFT|PC_EQUAL,SE_PLUS); puts("111");
    MAP(PC_BRAOPEN,SE_BRAOPEN); puts("112");
    MAP(MD_SHIFT|PC_BRAOPEN,SE_CUROPEN); puts("113");
    MAP(PC_BRACLOS,SE_BRACLOS); puts("114");
    MAP(MD_SHIFT|PC_BRACLOS,SE_CURCLOS); puts("115");
    MAP(PC_BACKSLA,SE_BACKSLA); puts("116");
    MAP(MD_SHIFT|PC_BACKSLA,SE_PIPE); puts("117");
    MAP(PC_APOSTRO,SE_APOSTRO); puts("118");
    MAP(MD_SHIFT|PC_APOSTRO,SE_QUOTE); puts("119");
    MAP(PC_COMMA,SE_COMMA); puts("120");
    MAP(MD_SHIFT|PC_COMMA,SE_LESS); puts("121");
    MAP(PC_DOT,SE_DOT); puts("122");
    MAP(MD_SHIFT|PC_DOT,SE_GREATER); puts("123");
    MAP(PC_SLASH,SE_SLASH); puts("124");
    MAP(MD_SHIFT|PC_SLASH,SE_QUEST); puts("125");
    MAP(PC_SEMICOL,SE_SEMICOL); puts("126");
    MAP(MD_SHIFT|PC_SEMICOL,SE_COLON); puts("127");

// editing cluster
	MAP(PC_INSERT,SE_INSERT); puts("128");
	MAP(MD_SHIFT|PC_INSERT,SE_HELP); puts("129");
	MAPANY(PC_DELETE,SE_DEL); puts("130");
	MAP(PC_HOME,SE_HOME); puts("131");
	MAP(MD_SHIFT|PC_HOME,SE_CLR); puts("132");
	MAPANY(PC_END,SE_END); puts("133");
	MAPANY(PC_PGUP,SE_TRUE); puts("134");
	MAPANY(PC_PGDOWN,SE_INVERSE); puts("135");

    // End of mapping. Save .HEX file for Verilog
    //SAVEMAP1HEX("keyb1_us_hex.txt");
    //SAVEMAP2HEX("keyb2_us_hex.txt");
    // And map file for loading from ESXDOS

    SAVEMAPBIN("../chloehd/SYSTEM/KEYBOARD.S/CHLOE.KB"); puts("136");
//    SAVEMAPBIN("../chloehd/SYSTEM/KEYBOARD.S/US.KB");
	
	return 0;
}