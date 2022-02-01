;	// TC48 - A Timex Computer 2048 emulator
;	// Copyright (c) 2019 Source Solutions, Inc.
;	// Copyright (c) 1984 Timex Group B.V.
;	// Copyright (c) 1982 Sky In-Home Service Ltd.

;	// OS hook codes
	include "UNODOS3.INC"

	uno_reg equ $fc3b
	uno_dat equ $fd3b
 
	uno_conf equ 0
	uno_mapper equ 1
	flash_spi equ 2
	flash_cs equ 3
	scan_code equ 4
	key_stat equ 5
	joy_conf equ 6
	key_map equ 7
	nmi_event equ 8
	mouse_data equ 9
	mouse_status equ 10
	scandbl_ctrl equ 11
	raster_line equ 12
	raster_ctrl equ 13
	dev_control equ 14
	dev_ctrl2 equ 15

	ad724 equ $fb;						// AD724 video encoder 

	print_a equ $10;					// print a character
	chan_open equ $1601;				// channel open

	org $6000

;	// print intro text

pr_text:
	ld a, 12;							// FF
	rst print_a;						// clear screen
	ld a, 2;							// select main screen
	call chan_open;						// select channel
	ld hl, text;						// point to text

pr_loop:
	ld a, (hl);							// get character
	and a;								// terminating byte?
	jr z, pr_lower;						// jump if so;
	rst print_a;						// print character
	inc hl;								// point to next character
	jr pr_loop;							// loop until done

pr_lower
	inc hl;								// next position
	push hl;							// stack pointer
	ld a, 1;							// select lower screen
	call chan_open;						// select channel
	pop hl;								// unstack pointer

pr_l_loop:
	ld a, (hl);							// get character
	and a;								// terminating byte?
	jr z, pr_key;						// jump if so;
	rst print_a;						// print character
	inc hl;								// point to next character
	jr pr_l_loop;						// loop until done

pr_key:
	ld a, $7f;							// high byte of I/O address
	in a, ($fe);						// read byte
	rra;								// set carry if space pressed
	jp c, pr_key;						// loop until space pressed

;	// load ROM file
	ld ix, filename;					// /rsc/48.rom
	ld a, '*';							// use current drive
	ld b, fa_read | fa_open_ex;			// open for reading if file exists
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
	ld (handle), a;						// store file handle
	ld bc, 16384;						// file size
	ld ix, $8000;						// load in fast RAM.
	rst divmmc;							// issue a hookcode
	defb f_read;						// read file
	ld a, (handle);						// restore handle
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file

;	// initial setup
	di;									// interrupts off
	ld bc, $bf3b;						// register select
	ld de, 0;							// destination address
	ld a, $40;							// register 64
	out (c), a;							// select it
	ld b, $ff;							// data port
	out (c), e;							// switch off ULAplus
	ld c, b;							// LD C, $FF
	out (c), e;							// Spectrum screen mode, DOCK
	ld bc, $7ffd;						// 128 paging
	out (c), e;							// ROM-0, VRAM-0, HOME-0
	ld c, e;							// byte count
	ld b, a;							// to 16384
	ld a, %00111111;					// lower 48K to be shadow RAM
	out ($f4), a;						// set it
	ld hl, $8000;						// source
	ldir;								// copy ROM

;	// patch ROM to prevent it overwriting itself
	ld a, $17;							// po_scr_4a
	ld hl, $0d2c;						// used to overwrite
	ld (hl), a;							// the font
	xor a;								// skip_ret
	ld hl, $33fb;						// used to overwrite
	ld (hl), a;							// restart 0

;	// set speed for Prism
	ld bc, $8e3b;						// Prism port
	ld a, %00000000;					// 3.5 MHz
	out (c), a;							// set it

;	// configure hardware
	ld bc, uno_reg;						// Uno register port
	xor a;								// master config
	out (c), a;							// set register
	inc b;								// Uno data port
	ld a, %00000010;					// bit 0 - 0: don't use boot mode (cannot access all RAM)
;										//     1 - 1: enable divMMC
;										//     2 - 0: enable divMMC NMI
;										//     3 - 0: Port #FE behaves as issue 3
;										//     4 - 0: 312 scanlines per frame (PAL)
;										//     5 - 0: Enable video contention
;										//     6 - 0: 312 scanlines per frame (PAL)
;										//     7 - 0: unlock SPI (necessary to switch to boot mode)
	out (c), a;							// write data

;	// set speed
;	ld bc, uno_reg;						// Uno register select
	dec b;								// Uno register select
	ld a, scandbl_ctrl;					// scan double and control register
	out (c),a;							// select it
	inc b;								// LD BC, uno_dat
	in a, (c);							// get current value
	and %00000011;						// 3.5 MHz | TC sync | 50Hz | user scanlines | user scandouble
	out (c),a;							// set it

;	// set PAL output
;	ld bc, uno_reg;						// Uno register select
	dec b;
	ld a, ad724;						// video register
	out (c),a;							// select it
	inc b;								// LD BC, uno_dat
	in a, (c);							// get value;
	and %11111110;						// set PAL
	out (c), a;							// set it

;	// device setup
;	ld bc, uno_reg;						// Uno register select
	dec b;								// Uno register select
	ld a, dev_control;					// device control register
	out (c),a;							// select it
	inc b;								// LD BC, uno_dat
	ld a, %01101000;					// SPI enabled     | MMU enabled     | $1FFD b2 mask 1 | $7FFD b4 mask 0
;										// $1FFD disabled  | $7FFD enabled   | YM2 enabled     | YM1 enabled
	out (c), a;							// set it

;	ld bc, uno_reg;						// Uno register select
	dec b;
	ld a, dev_ctrl2;					// device control register 2
	out (c),a;							// select it
	inc b;								// LD BC, uno_dat
;	ld a, %00000000;					// 00000 | Radastan video enabled | Timex video enabled | ULAplus enabled 
	xor a;
	out (c), a;							// set it

;	ld bc, unoreg;						// register select
	dec b;								// unoreg
	ld a, raster_ctrl;					// rasterctrl
	out (c), a;							// select it
;	ld bc, unodat;						// data select
	inc b;								// unodat
;	ld a, %00000000;					// ULA interrupt on / raster interrupt off
	xor a;
	out (c), a;							// select it

;	// set pan
	ld a, %10011111;					// ACB stereo
	out ($f7), a;						// set it

;	// change to `SNAPS` folder
	ld a, '*';							// use current drive
	ld ix, path;						// pointer to path
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder
	jp shadow_ram;						// switch off shadow RAM

filename:
	defb "tc2048.rom", 0;				// ROM file in resource folder

handle:
	defb 0

path:
	defb "/PROGRAMS/TC2048/RSC/SNAPS/", 0;

;	// skip middle 32K of shadow RAM that will be paged out
	org $c000
shadow_ram:
	ld a, %00000011;					// lower 16K to be shadow RAM
	out ($f4), a;						// set it

;	// start the emulator
	jp 1;								// skip over divMMC trap

text:
	defb "Timex Computer 2048 Emulator (Version 1.3)", 13;
 	defb "Copyright (C) 1982 Comcast Corporation, (C) 1984 Timex Group B.V.", 13;
	defb 13;
	defb "Comcast Corpoartion and Timex Group have kindly given their permission for the", 13;
	defb "redistribution of thier copyrighted material but retains that copyright.", 13;
	defb 13;
	defb "|BLUE  |RED   |MAGEN.|GREEN |CYAN  |YELLOW|WHITE |      |      |BLACK |", 13;
	defb "|EDIT  |CAPS L|TRUE V|INV. V|<     |\\/    |/\\    |>     |GRAPH.|DELETE|", 13;
	defb "|1    !|2    @|3    #|4    $|5    %|6    &|7    '|8    (|9    )|0    _|", 13;
	defb "|DEF FN|FN    |LINE  |OPEN# |CLOSE#|MOVE  |ERASE |POINT |CAT   |FORMAT|", 13;
	defb "   |SIN   |COS   |TAN   |INT   |RND   |STR$  |CHR$  |CODE  |PEEK  |TAB   |", 13;
	defb "   |Q   <=|W   <>|E   >=|R     |T     |Y     |U     |I     |O     |P     |", 13;
	defb "   |  PLOT|  DRAW|   REM|   RUN|RANDO.|RETURN|    IF| INPUT|  POKE| PRINT|", 13;
	defb "   |ASN   |ACS   |ATN   |VERIFY|MERGE |[     |]     |IN    |OUT   |(C)   |", 13;
	defb "     |READ  |RESTO.|DATA  |SGN   |ABS   |SQR   |VAL   |LEN   |USR   |       |", 13;
	defb "     |A     |S     |D     |F     |G     |H     |J     |K     |L     | ENTER |", 13;
	defb "     |   NEW|  SAVE|   DIM|   FOR|  GOTO| GOSUB|  LOAD|  LIST|   LET|       |", 13;
	defb "     |~     ||     |\\     |{     |}     |CIRCLE|VAL$  |SCREE.|ATTR  |       |", 13;
	defb "|       |LN    |EXP   |LPRINT|LLIST |BIN   |INKEY$|PI    |      |          |", 13;
	defb "| CAPS  |Z    :|X    `|C    ?|V    /|B    *|N    ,|M    .|SYMBOL|   BREAK  |", 13;
	defb "| SHIFT |  COPY| CLEAR| CONT.|   CLS|BORDER|  NEXT| PAUSE| SHIFT|   SPACE  |", 13;
	defb "|       |BEEP  |INK   |PAPER |FLASH |BRIGHT|OVER  |INVER.|      |          |", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE EMULATOR", 0;
