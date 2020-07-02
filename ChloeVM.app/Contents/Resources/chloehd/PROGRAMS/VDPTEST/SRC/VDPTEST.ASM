;	// VDPTEST - An example of how to read data directly from files
;	// Copyright (c) 2019 Source Solutions, Inc.

;	// Bits 0-2: Screen mode. 000=screen 0, 001=screen 1, 010=hi-colour, 110=hi-res
;	// Bits 3-5: Sets the screen colour in hi-res mode.
;	//           	000 - Black on White     100 - Green on Magenta
;	//              001 - Blue on Yellow     101 - Cyan on Red
;	//              010 - Red on Cyan        110 - Yellow on Blue
;	//              011 - Magenta on Green   111 - White on Black
;	// Bit 6:    If set disables the generation of the timer interrupt.
;	// Bit 7:    Selects which bank the horizontal MMU should use. 0=DOCK, 1=EX-ROM.

;	// OS hook codes
	include "UNODOS3.INC"

;	// SCLD control
	scld equ $ff;
	ula equ $fe;

	lo_0 equ %000
	lo_1 equ %001
	med equ %010
	hi equ %110
	
	blk_wht equ %000000
	blu_yel equ %001000
	red_cyn equ %010000
	mgn_grn equ %011000
	grn_mgn equ %100000
	cyn_red equ %101000
	yel_blu equ %110000
	wht_blk equ %111000

	dock equ %00000000
	exr equ %10000000

;	// MMU control (sideways RAM)
	mmu equ $f4

	sw_0 equ %00000001
	sw_1 equ %00000010
	sw_2 equ %00000100
	sw_3 equ %00001000
	sw_4 equ %00010000
	sw_5 equ %00100000
	sw_6 equ %01000000
	sw_7 equ %10000000


;	// paging (home bank)
	paging equ $7ffd;

	ram_0 equ %00000;
	ram_1 equ %00001;
	ram_2 equ %00010;
	ram_3 equ %00011;
	ram_4 equ %00100;
	ram_5 equ %00101;
	ram_6 equ %00110;
	ram_7 equ %00111;

	vid_0 equ %00000;
	vid_1 equ %01000;

	rom_0 equ %00000;
	rom_1 equ %10000;


;	// program
	org $6000
	xor a;								// LD A, 0
	out (ula), a;						// border 0

	ei;									// interrupts on

;	// set palette
	ld c, $3b;							// ULAplus port
	ld de, $00bf;						// d = data + 1, e = register
	xor a;								// LD A, 0-2

pal_1st:
	ld hl, ega_pal;						// start of data
	jr pal_loop;

pal_2nd:
	ld hl, ega_pal + 8;					// offset to bright colors

pal_loop:
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port + 10
	outi;								// DEC B
;										// OUT BC, (HL)
;										// DEC HL
	inc a;								// next register

	cp 8;
	jr z, pal_1st;						// jump if so
	
	cp 24;
	jr z, pal_1st;						// jump if so

	cp 32;
	jr z, pal_1st;						// jump if so

	cp 48;
	jr z, pal_2nd;						// jump if so
	
	cp 56;
	jr z, pal_2nd;						// jump if so

	cp 65;
	jr nz, pal_loop;					// loop until done

	jp lo_res_1;						// skip past frame buffer area when no shadow RAM exists

ega_pal:
;										// #	name			G R B
	defb %00000000;						// 00 	black			0 0 0  
;	defb %00000010;						// 01	blue			0 0 2
;	defb %10100000;						// 02	green			5 0 0
;	defb %10100010;						// 03	cyan			5 0 2
;	defb %00010100;						// 04	red				0 5 0
;	defb %00010110;						// 05	magenta			0 5 2
;	defb %01110100;						// 06	brown			3 5 0
;	defb %10110110;						// 07	light gray		5 5 2
;	defb %01101101;						// 08	dark gray		3 3 1
	defb %01101111;						// 09	bright blue		3 3 3
	defb %11101101;						// 10	bright green	7 3 1
	defb %11101111;						// 11	bright cyan		7 3 3
	defb %01111101;						// 12	bright red		3 7 1
	defb %01111111;						// 13	bright magenta	3 7 3
	defb %11111101;						// 14	bright yellow	7 7 1
	defb %11111111;						// 15	bright white	7 7 3

	defb %00000000;						// 00 	black			0 0 0  
	defb %01101111;						// 09	bright blue		3 3 3
	defb %11101101;						// 10	bright green	7 3 1
	defb %11101111;						// 11	bright cyan		7 3 3
	defb %01111101;						// 12	bright red		3 7 1
	defb %01111111;						// 13	bright magenta	3 7 3
	defb %11111101;						// 14	bright yellow	7 7 1
	defb %11111111;						// 15	bright white	7 7 3

pal_end:
	defb 1;								// enable ULAplus

;	// skip in case no shadow RAM
	org $8000
handle:
	defb 0;

ram_5_vid_0:
	ld a, rom_1 + ram_5 + vid_0;		// set ROM, RAM and video pages
	jr ram_paging;						// immediate jump

ram_5_vid_1:
	ld a, rom_1 + ram_5 + vid_1;		// set ROM, RAM and video pages
	jr ram_paging;						// immediate jump

ram_7_vid_0:
	ld a, rom_1 + ram_7 + vid_0;		// set ROM, RAM and video pages
	jr ram_paging;						// immediate jump

ram_7_vid_1:
	ld a, rom_1 + ram_7 + vid_1;		// set ROM, RAM and video pages

ram_paging:
	ld bc, paging;						// memory I/O
	out (c), a;							// out (bc), a
	ret;								// end ouf subroutine

;	// lo-res 1
lo_res_1:
	call ram_5_vid_1;					// ROM 1

	ld ix, fn_l1;						// lo res screen 1
	call open;							// open it
	ld ix, $c000;						// offset 0 in frame buffer
	call one_part;						// load the file

	ld bc, $bf3b;						// palette register port
	ld a, 64;							// register
	out (c), a;							// write it
	ld b, $ff;							// palette data port
	ld a, 1;							// palette on
	out (c), a;							// write it

	ld a, lo_0;							// LD A, 0
	out (scld), a;						// 8x8, offset 0

	call ram_5_vid_0;					// ROM 1
	call space;							// wait for keypress

;	// lo-res 2
	ld ix, fn_l2;						// lo res screen 2
	call open;							// open it
	ld ix, $e000;						// offset 0 in frame buffer
	call one_part;						// load the file

	ld a, lo_1;							// LD A, 1
	out (scld), a;						// 8x8, offset 1
	call space;							// wait for keypress

;	// lo-res 3
	call ram_7_vid_0;					// ROM 1

	ld ix, fn_l3;						// lo res screen 3
	call open;							// open it
	ld ix, $c000;						// offset 0 in frame buffer
	call one_part;						// load the file

	ld a, lo_0;							// LD A, 0
	out (scld), a;						// 8x8, offset 0
	call ram_7_vid_1;					// ROM 1
	call space;							// wait for keypress

;	// lo-res 4
	ld ix, fn_l4;						// lo res screen 4
	call open;							// open it
	ld ix, $e000;						// offset 0 in frame buffer
	call one_part;						// load the file

	ld a, lo_1;							// LD A, 1
	out (scld), a;						// 8x8, offset 1
	call space;							// wait for keypress

;	// me-res 1
	call ram_5_vid_1;					// ROM 1

	ld ix, fn_m1;						// lo res screen 1
	call two_part;						// load two parts of file

	ld a, med;							// LD A, 0
	out (scld), a;						// 8x8, offset 0

	call ram_7_vid_0;					// ROM 1
	call space;							// wait for keypress

;	// me-res 2
	ld ix, fn_m2;						// lo res screen 1
	call two_part;						// load two parts of file

	ld a, med;							// LD A, 0
	out (scld), a;						// 8x8, offset 0

	call ram_5_vid_1;					// ROM 1
	call space;							// wait for keypress

;	// hi-res 1
	ld ix, fn_h1;						// lo res screen 1
	call two_part;						// load two parts of file

	ld bc, $bf3b;						// palette register port
	ld a, 64;							// register
	out (c), a;							// write it
	ld b, $ff;							// palette data port
	xor a;								// palette off
	out (c), a;							// write it

	ld a, hi + wht_blk;					// LD A, 62 
	out (scld), a;						// 8x8, offset 0

	call ram_7_vid_0;					// ROM 1
	call space;							// wait for keypress

;	// hi-res 2
	ld ix, fn_h2;						// lo res screen 1
	call two_part;						// load two parts of file

	call ram_5_vid_1;					// ROM 1
	call space;							// wait for keypress

	jp lo_res_1;						// loop

;	// subroutines
open:
	ld a, '*';							// use current drive
	ld b, fa_read | fa_open_ex;			// open for reading if file exists
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
	ld (handle), a;						// store handle
	ret;								// end of subroutine

load:
	ld a, (handle);						// file handle
	rst divmmc;							// issue a hookcode
	defb f_read;						// read bytes
	ret;								// end of subroutine

one_part:
	ld bc, 6912;						// byte count
	jr one_part_a;						// immediate jump

two_part:
	call open;							// open it
	ld ix, $c000;						// offset 0 in frame buffer
	ld bc, 6144;						// byte count
	call load;							// load the 1st half of file
	ld ix, $e000;						// offset 1 in frame buffer
	ld bc, 6144;						// byte count

one_part_a:
	call load;							// load the 2nd half of the file

close:
	ld a, (handle);						// file handle
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
	ret;								// end of subroutine

	frame equ 23672;					// returns to zero every second

wait:
	ld a, (frame);						// get current frame value
	ld c, a;							// store it

wait2:
	ld a, (frame);						// get frame again
	cp c;								// has it changed?
	jr nz, wait2;						// loop until one frame passed
	halt;								// wait one more frame
	ret;								// return

space:
	ld b, 180;							// frames to wait

space2:
	ld a, $7f;							// high byte of I/O address
	in a, ($fe);						// read byte
	rra;								// set carry if space pressed
	jr c, space3;						// jump if not
	ld b, 2;							// change count

space3;
	call wait;							// wait 2 frames
	djnz space2;
	ret;								// done

;	// data
fn_l1:
    defb "LO-RES_1.SCR", 0

fn_l2:
    defb "LO-RES_2.SCR", 0

fn_l3:
    defb "LO-RES_3.SCR", 0

fn_l4:
    defb "LO-RES_4.SCR", 0

fn_m1:
    defb "ME-RES_1.SCR", 0

fn_m2:
    defb "ME-RES_2.SCR", 0

fn_h1:
    defb "HI-RES_1.SCR", 0

fn_h2:
    defb "HI-RES_2.SCR", 0

