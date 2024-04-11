;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2024 Source Solutions, Inc.

;	// SE Basic IV is free software: you can redistribute it and/or modify
;	// it under the terms of the GNU General Public License as published by
;	// the Free Software Foundation, either version 3 of the License, or
;	// (at your option) any later version.
;	// 
;	// SE Basic IV is distributed in the hope that it will be useful,
;	// but WITHOUT ANY WARRANTY; without even the implied warranty o;
;	// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;	// GNU General Public License for more details.
;	// 
;	// You should have received a copy of the GNU General Public License
;	// along with SE Basic IV. If not, see <http://www.gnu.org/licenses/>.

;;
;	// --- 80 COLUMN SCREEN HANDLING ROUTINES ----------------------------------
;;
:

;	// FRAME BUFFER
;	//
;	// $FFFF +---------------+ 65535
;	//       | font          |
;	// $F800 +---------------+ 63488
;	//       | odd columns   |
;	// $E000 +---------------+ 57344
;	//       | palette       |
;	// $DFC0 +---------------+ 57280
;	//       | temp stack    |
;	// $DF80 +---------------+ 57216
;	//       | character map |
;	// $D800 +---------------+ 55296
;	//       | even columns  |
;	// $C000 +---------------+ 49152

	org $0800

;	// reserved to extend screen 0 code
	defs 26, $ff;						// RESERVED

v_pr_str_lo:
	push af;							// stack AF
	ld a, 1;							// set lower screen
	jr v_pr_any;						// immedaite jump

v_pr_str
	push af;							// stack AF
	ld a, 2;							// set upper screen

v_pr_any:
	push bc;							// stack BC
	push de;							// stack DE
	push hl;							// stack HL
	call chan_open;						// open the channel
	ld e, ixl;							// IX
	ld d, ixh;							// to DE
	call po_asciiz_0;					// print string
	jr s0_API_return;					// unstack and exit

;	// write 64 palette entries at IX to registers 
v_write_pal:
	push af;							// stack AF
	push bc;							// stack BC
	push de;							// stack DE
	push hl;							// stack HL
	push ix;							// IX points to palette data
	pop hl;								// no LD HL, IX instruction
	ld bc, 63;							// offeset to last entry
	add hl, bc;							// HL points to entry
	ld c, $3b;							// palette port
	ld de, $00bf;						// d = data, e = register
	ld a, 64;							// becomes 63
	halt;								// wait for vblank

write_pal:
	dec a;								// next register
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	outd;								// dec b; out bc, (hl); dec hl
	and a;								// was that the last register?
	jr nz, write_pal;					// set all 64 entries (API exit when done)

s0_API_return:
	pop hl;								// unstack HL
	pop de;								// usntack DE
	pop bc;								// unstack BC
	pop af;								// unstack AF
	ret;								// end of subroutine

	org $0853

get_reg:
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	in a, (c)							// read register value
	ret;								// end of subroutine

set_reg:
	ld b, e;							// register port
	out (c), l;							// select register
	ld b, d;							// data port
	out (c), a;							// select register
	ret;								// end of subroutine

;	// LOCATE command <row>,<column> (counts from 1)
;;
; <code>LOCATE</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#LOCATE" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_locate:
	fwait;								// enter calculator
	fxch;								// swap values
	fce;								// exit calculator

	ld a, 2;							// channel S (upper screen)
	call chan_open;						// select channel

	call stk_to_bc;						// column to C, row to B
	ld a, c;							// get column
	or a;								// test for zero
	jr z, loc_err;						// jump if so

	bit 1, (iy + _flags2);				// test for user-defined video mode
	jp nz, v_s1_locate;					// jump if so

	cp 81;								// in range?
	jr nc, loc_err;						// error if not
	ld a, b;							// get row
	or a;								// test for zero
	jr z, loc_err;						// jump if so
	cp 24;								// upper screen?
	jr nc, loc_err;						// jump if not

	ld a, 82;							// leftmost

loc_s1
	sub c;								// calculate column
	jr c, loc_err;						// jump if error
	ld c, a;							// else store it

	ld a, 25;							// bottom row
	sub b;								// calculate row
	jr c, loc_err;						// jump if error
	ld b, a;							// else store it
	jp cl_set;							// exit via cl_set

loc_err:
	rst error;							// throw
	defb out_of_screen;					// error

;	// WRITE A CHARACTER TO THE SCREEN
;	// There are eight separate routines called based on the first three bits of
;	// the column value.

;	// HL points to the first byte of a character in FONT_1
;	// DE points to the first byte of the block of screen addresses

pos_4:
	inc de;								// DE now points to SCREEN_2 +1
	set 5, d;							// routine continues into pos_0

pos_0:
	ld b, 8;							// 8 bytes to write

pos_0a:
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, over_0;						// jump if so
	and %00000011;						// mask area used by new character

over_0:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, inverse_0;					// jump if not
	xor %11111100;						// invert

inverse_0:
	ld c, (hl);							// get character from font
	sla c;								// shift left one bit
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	inc d;								// point to next screen location
	inc l;								// point to next font data
	djnz pos_0a;						// loop 8 times
	jp pr_all_f;						// immedaite jump

pos_1:
	ld b, 8;							// 8 bytes to write

pos_1a:
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, over_1;						// jump if so
	and %11111100;						// mask area used by new character

over_1:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, inverse_1;					// jump if not
	xor %00000011;						// invert

inverse_1:
	ld c, (hl);							// get character from font
	srl c;								// shift left five bits
	srl c;								//
	srl c;								//
	srl c;								//
	srl c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	set 5, d;							// DE now points to SCREEN_2
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, over_1a;						// jump if so
	and %00001111;						// mask area used by new character

over_1a:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, inverse_1a;					// jump if not
	xor %11110000;						// invert

inverse_1a:
	ld c, (hl);							// get character from font
	sla c;								// shift left three bits
	sla c;								//
	sla c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	res 5, d;							// restore pointer to SCREEN_1
	inc d;								// point to next screen location
	inc l;								// point to next font data
	djnz pos_1a;						// loop 8 times
	jp pr_all_f;						// immedaite jump

pos_2:
	ld b, 8;							// 8 bytes to write

pos_2a:
	set 5, d;							// DE now points to SCREEN_2
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, over_2;						// jump if so
	and %11110000;						// mask area used by new character

over_2:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, inverse_2;					// jump if not
	xor %00001111;						// invert

inverse_2:
	ld c, (hl);							// get character from font
	srl c;								// shift right three bits
	srl c;								//
	srl c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	res 5, d;							// restore pointer to SCREEN_1
	inc de;								//
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, over_2a;						// jump if so
	and %00111111;						// mask area used by new character

over_2a:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, inverse_2a;					// jump if not
	xor %11000000;						// invert

inverse_2a:
	ld c, (hl);							// get character from font
	sla c;								// shift left five bits
	sla c;								//
	sla c;								//
	sla c;								//
	sla c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	inc d;								// point to next screen location
	inc l;								// point to next font data
	dec de;								// adjust screen pointer
	djnz pos_2a;						// loop 8 times
	jp pr_all_f;						// immedaite jump

pos_7:
	inc de;								// DE now points to SCREEN_2 + 1
	set 5, d;							// routine continues into pos_3

pos_3:
	inc de;								// next column
	ld b, 8;							// 8 bytes to write

pos_3a:
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, over_3;						// jump if so
	and %11000000;						// mask area used by new character

over_3:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, inverse_3;					// jump if not
	xor %00111111;						// invert

inverse_3:
	ld c, (hl);							// get character from font
	sra c;								// shift right one bit
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	inc d;								// point to next screen location
	inc l;								// point to next font data
	djnz pos_3a;						// loop 8 times
	jp pr_all_f;						// immediate jump

pos_5:
	inc de;								// next column
	ld b, 8;							// 8 bytes to write

pos_5a:
	set 5, d;							// DE now points to SCREEN_2
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, over_5;						// jump if so
	and %11111100;						// mask area used by new character

over_5:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, inverse_5;					// jump if not
	xor %00000011;						// invert

inverse_5:
	ld c, (hl);							// get character from font
	sra c;								// shift right five bits
	sra c;								//
	sra c;								//
	sra c;								//
	sra c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	res 5, d;							// restore pointer to SCREEN_1
	inc de;								//
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, over_5a;						// jump if so
	and %00001111;						// mask area used by new character

over_5a:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, inverse_5a;					// jump if not
	xor %11110000;						// invert

inverse_5a:
	ld c, (hl);							// get character from font
	sla c;								// shift left three bits
	sla c;								//
	sla c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	inc d;								// point to next screen location
	inc l;								// point to next font data
	dec de;								// adjust screen pointer
	djnz pos_5a;						// loop 8 times
	jp pr_all_f;						// immedaite jump

pos_6:
	inc de;								// next column
	inc de;								// next column
	ld b, 8;							// 8 bytes to write

pos_6a:
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, over_6;						// jump if so
	and %11110000;						// mask area used by new character

over_6:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, inverse_6;					// jump if not
	xor %00001111;						// invert

inverse_6:
	ld c, (hl);							// get character from font
	srl c;								// shift right three bits
	srl c;								//
	srl c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	set 5, d;							// DE now points to SCREEN_2
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, over_6a;						// jump if so
	and %00111111;						// mask area used by new character

over_6a:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, inverse_6a;					// jump if not
	xor %11000000;						// invert

inverse_6a:
	ld c, (hl);							// get character from font
	sla c;								// shift left five bits
	sla c;								//
	sla c;								//
	sla c;								//
	sla c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	res 5, d;							// restore pointer to SCREEN_1
	inc d;								// point to next screen location
	inc l;								// point to next font data
	djnz pos_6a;						// loop 8 times
	jp pr_all_f;						// immedaite jump

;	// don't print anything when booting esxDOS (prevents paging during boot)
	org $09f4;
	ret;								// immediate return

chr_str_1:
	set 5, (iy + _flags2);				// set force printable flag
	ret;								// done

force_poable:
	res 5, (iy + _flags2);				// clear force printable flag
	jp po_able;							//

chr_str_2:
	set 6, (iy + _flags2);				// set composable flag
	ret;								// done

po_compose:
	res 6, (iy + _flags2);				// clear composable flag
	push af;							// stack character
	call po_left;						// move cursor left
	set 0, (iy + _p_flag);				// set over flag
	pop af;								// unstack character
	call po_able;						// overprint character
	res 0, (iy + _p_flag);				// clear flag
	ret;								// done

;;
; print out
;;
print_out:
	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
	jp nz, v_s1_print_out;				// jump if so
	call po_fetch;						// current print position

	bit 5, (iy + _flags2);				// treat next character as printable?
	jr nz, force_poable;				// jump if so

	bit 6, (iy + _flags2);				// is next character composable?
	jr nz, po_compose;					// jump if so

	cp 1;								// CHR$ (1)?
	jr z, chr_str_1;					// make next character printable

	cp 2;								// CHR$ (2)?
	jr z, chr_str_2;					// make next character composable

	cp ' ';								// space or higher?
	jp nc, po_able;						// jump if so
	cp 7;								// character in the range 0 - 6?
	jp c, po_able;						// jump if so
	cp 14;								// character in the range 7 to 13?
	jr c, po_ctrl;						// jump if so
	cp 28;								// characters in the range 14 to 27?
	jr c, po_able;						// jump if so
	sub 14;								// reduce range

po_ctrl:
	ld e, a;							// move character
	ld d, 0;							// to DE
	ld hl, ctlchrtab - 7;				// base of control table
	add hl, de;							// index into table
	ld e, (hl);							// get offset
	add hl, de;							// add offset
	push hl;							// stack it
	jp po_fetch;						// indirect return

ctlchrtab:
	defb po_bel - $;					// 07, BEL
	defb po_able - $;					// 08, BS
	defb po_tab - $;					// 09, HT
	defb po_cr - $;				 		// 10, LF
	defb po_vt - $;						// 11, VT
	defb po_clr - $;					// 12, FF
	defb po_cr - $;						// 13, CR
	defb po_right - $;					// 28, FS
	defb po_left - $;					// 29, GS
	defb po_up - $;						// 30, RS
	defb po_down - $;					// 31, US

;	// sound bell subroutine
po_bel:
	jp bell;							// immediate jump

;;
; print tab
;;
po_tab:
	ld a, c;							// current column
	dec a;								// move right
	dec a;								// twice
	and %00010000;						// test
	call po_fetch;						// current position
	add a, c;							// add column
	dec a;								// number of spaces
	and %00000111;						// modulo 8 (gives 5/10 tabs in 40/80 column mode)
	ret z;								// return if zero
	set 0, (iy + _flags);				// no leading space
	ld d, a;							// use 0 as counter

po_space:
;	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
;	jp nz, v_s1_po_space;	    		// jump if so
	call po_sv_sp;						// space recursively
	dec d;								// print
	jr nz, po_space;					// until
	ret;								// end of subroutine

;;
; print home
;;
po_vt:
	jp cl_home;							// indirect return

;	// print clr subroutine
po_clr:
	jp s0_cls;							// immediate jump

;;
; print carriage return
;
po_cr:
	ld c, 81;							// left column
	call po_scr;						// scroll if required
	dec b;								// down a line

jp_cl_set:
	jp cl_set;							// indirect return

;;
; print cursor right
;;
po_right:
	ld hl, p_flag;						// point to sysvar
	ld d, (hl);							// sysvar to D
	ld (hl), 1;							// set printing to OVER
	call po_sv_sp;						// print a space with alt regs
	ld (hl), d;							// restore sysvar
	ret;								// end of subroutine

;;
; print cursor left
;;
po_left:
	inc c;								// move column left
	ld a, 82;							// left side
	cp c;								// against left side?
	jr nz, po_left_1;					// jump if so
	dec c;								// down one line
	ld a, 25;							// top line
	cp b;								// is it?
	jr nz, po_left_1;					// jump if so
	ld c, 2;							// set column value
	inc b;								// up one line

po_left_1:
	jr jp_cl_set;						// indirect return

;;
; print cursor up
;;
po_up:
	inc b;								// move one line up
	ld a, 25;							// screen has 24 lines
	cp b;								// top of screen reached?
	jr nz, jp_cl_set;					// set position, if not
	dec b;								// do nothing
	ret;								// end of subroutine

;;
; print cursor down
;;
po_down:
	ld a, c;							// column to A
	push af;							// stack it
	call po_cr;							// down one row
	pop af;								// unstack A
	cp c;								// compare against current column
	ret z;								// return if nothing to do
	ld c, a;							// restore old column 

cl_scrl:
	call po_scr;						// test for scroll

cl_set2:
	jr jp_cl_set;						// indirect return

;;
; printable character codes
;;
po_able:
	call po_any;						// print character and continue

;;
; position store
;;
po_store:
	bit 0, (iy + _vdu_flag);			// test for lower screen
	jr nz, po_st_e;						// jump if so
	ld (s_posn), bc;					// store values for
	ld (df_cc), hl;						// upper screen
	ret;								// end of subroutine

po_st_e:
	ld (df_ccl), hl;					// store values
	ld (sposnl), bc;					// for lower
	ld (echo_e), bc;					// screen
	ret;								// end of subroutine

;;
; position fetch
;;
po_fetch:
;	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
;	jp nz, v_s1_po_fetch;	    		// jump if so
	ld hl, (df_cc);						// get main
	ld bc, (s_posn);					// screen values
	bit 0, (iy + _vdu_flag);			// main screen?
	ret z;								// return if so
	ld bc, (sposnl);					// get lower
	ld hl, (df_ccl);					// screen values
	ret;								// and return

;;
; print any character
;;
po_any:
	push bc;							// stack current position

;	// write to character map
	push hl;							// stack print address
	ex af, af';							// save character
	ld a, 25;							// reverse row and add one
	sub b;								// range 1 to 24
	ld b, a;							// put it back in B
	ld a, 81;							// reverse column
	sub c;								// range 0 to 79
	ld c, a;							// put it back in C
	ex af, af';							// restore character
	ld hl, char_map;					// base address of character map
	ld de, 80;							// 80 characters per row
	dec b;								// reduce range (0 to 23)
	jr z, add_columns;					// jump if row zero
	
add_lines:
	add hl, de;							// add 80 characters for each row
	djnz add_lines;						// B holds line count (zero on loop exit)

add_columns:
	add hl, bc;							// Add offset in character map to HL
	bit 0, (iy + _vdu_flag);			// lower screen?
	jr z, write_char;					// jump if not

	jr no_write_char;					// BUG PATCH - lower screen was not updating character map correctly

;	ld b, (iy + _df_sz);				// number of rows in lower display
;	ld de, 80;							// 80 characters per row
;	ld hl, $df80 + 80;					// end of character map + 80 (line 0)

;sbc_lines:
;	sbc hl, de;							// subtract 80 characters for each row
;	djnz sbc_lines;						// B holds line count (zero on loop exit)
;	add hl, bc;							// add column offset
	
write_char:
	ld bc, paging;						// paging address
	ld de, $181f;						// ROM 1, VRAM 1, D = HOME 0, E = HOME 7 
	di;									// interrupts off
	out (c), e;							// page framebuffer in
	ld (hl), a;							// write character to map
	out (c), d;							// page framebuffer out
	ei;									// interrupts on

no_write_char:
	pop hl;								// restore screen address
;	// character map code ends

	ld bc, font;						// font stored in framebuffer at $f800

po_char_2:
	ex de, hl;							// store print address in DE

po_char_3:
	ld l, a;							// character code
	xor a;								// to
	ld h, a;							// HL
	add hl, hl;							// multiply
	add hl, hl;							// character
	add hl, hl;							// code
	add hl, bc;							// by eight
	ex de, hl;							// base address to DE
	pop bc;								// unstack current position

;;
; print all characters
;;
pr_all:
	ld a, c;							// get column number
	dec a;								// move it right one position
	ld a, 81;							// new column?
	jr nz, pr_all_1;					// jump if not
	dec b;								// move down
	ld c, a;							// one line

pr_all_1:
	cp c;								// new line?
	push de;							// stack DE
	call z, po_scr;						// scrolling required?
	pop de;								// unstack DE
	push bc;							// stack position
	push hl;							// stack destination
	ld a, 81;							// 80 columns

pr_all_common:
	sub c;								// get position
	ld b, a;							// save it
	and $07;							// mask off bit 0-2
	ld c, a;							// store number of routine to use
	ld a, b;							// retrieve it
	and $78;							// mask off bit 3-6
	rrca;								// shift three
	rrca;								// bits to
	rrca;								// the right
	and a;								// test for zero
	push de;							// save font address
	jr z, pr_all_2;						// to next part if so
	ld e, a;							// put A in E
	ld d, 0;							// clear D
	add hl, de;							// add three times
	add hl, de;							// contents of a
	add hl, de;							// to hl

pr_all_2:
	ex de, hl;							// put the result back in DE

;	// HL now points to the location of the first byte of char data in FONT_1
;	// DE points to the first screen byte in SCREEN_1
;	// C holds the offset to the routine

	ld b, 0;							// prepare to add
	rlc c;								// double the value in C
	ld hl, rtable;						// base address of table
	add hl, bc;							// add C
	ld c, (hl);							// fetch low byte of routine
	inc hl;								// increment HL
	ld b, (hl);							// fetch high byte of routine
	pop hl;								// restore font address
	ld (oldsp), bc;						// save the address to jump to in sysvar
	ld bc, paging;						// page in VRAM
	ld a, %00011111;					// ROM 1, VRAM 1, HOME 7
	di;									// interrupts off
	out (c), a;							// do paging
	ld bc, (oldsp);						// restore BC
	ld (oldsp), sp;						// store SP
	ld sp, tstack;						// point to temporary stack
	ei;									// interrupts on
	push bc;							// push the address on machine stack
	ret;								// make an indirect jump forward to routine

pr_all_f:
	ld bc, paging;						// page out VRAM
	ld a, %00011000;					// ROM 1, VRAM 1, HOME 0
	di;									// interrupts off
	out (c), a;							// do paging
	ld sp, (oldsp);						// restore stack pointer
	ei;									// interrupts on
	pop hl;								// get original screen position
	pop bc;								// get original row/col
	dec c;								// move right
	ret;								// return via po_store

;	// message printing subroutine
;;
; print first message
;;
po_asciiz_0:
;	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
;	jp nz, v_s1_po_asciiz_0;    		// jump if so
	xor a;								// select first message
	set 2, (iy + _flags2);				// signal do not print tokens (for example, scroll during LIST)
	set 5, (iy + _vdu_flag);			// signal lower screen to be cleared

;	// message number in A, start of table in DE
;;
; message printing
;;
po_asciiz:
;	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
;	jp nz, v_s1_po_asciiz;    			// jump if so
	and a;								// message zero?
	call nz, po_srch_asciiz;			// if not, locate message
	ld a, (de);							// get character

po_asciiz_chr:
	cp 2;								// composable character pair?
	jr z, po_asciiz_composable;			// jump if so
	call po_save;						// print with alternate register set

po_asciiz_next:
	inc de;								// next character
	ld a, (de);							// get character
	and a;								// null terminator?
	jr nz, po_asciiz_chr;				// loop until done
	ret;								// end of subroutine

po_asciiz_composable:
	ld hl, sposnl;						// cursor
	inc (hl);							// left
	inc de;								// next character
	ld a, (de);							// get character
	set 0, (iy + _p_flag);				// set over flag
	call po_save;						// print with alternate register set
	res 0, (iy + _p_flag);				// clear flag
	jr po_asciiz_next;					// immediate jump

po_srch_asciiz:
	ld b, a;							// count to B

po_stp_asciiz:
	ld a, (de);							// contents in table pointer to A
	inc de;								// point to next address
	and a;								// terminator found?
	jr nz, po_stp_asciiz;				// loop until found
	djnz po_stp_asciiz;					// loop until correct entry found
	ret;								// return with pointer to message in DE
;	// end of ASCIIZ printing

;	// SpectraNet entry point
;	org $c0a;
;po_msg:
;	push hl;							// stack last entry
;	ld h, 0;							// zero high byte
;	ex (sp), hl;						// to suppress trailing spaces
;	jr po_table;						// immediate jump

;	// token printing subroutine
po_token:
;	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
;	jp nz, v_s1_po_token;	    		// jump if so
	sub first_tk;						// modify token code

po_tokens:
	ld de, token_table;					// address token table
	push af;							// stack code
	call po_search;						// locate required entry
	jr c, po_each;						// print message or token
	bit 0, (iy + _flags);				// print a space
	call z, po_sv_sp;					// if required

po_each:
	ld a, (de);							// get code
	and %01111111;						// cancel inverted bit
	call po_save;						// print the character
	ld a, (de);							// get code again
	inc de;								// increment pointer
	add a, a;							// inverted bit to carry flag
	jr nc, po_each;						// loop until done
	pop de;								// D = 0 to 127 for tokens, 0 for messages
;	cp 72;								// last character a $?
;	jr z, po_tr_sp;						// jump if so
	cp 130;								// last character less than A?
	ret c;								// return if so

po_tr_sp:
	ld a, d;							// offset to A
	cp 1;								// FN?
	jr z, po_sv_sp;						// jump if so
	cp 7;								// EOF #, INKEY$, LOC #, LOF#, PI, RND
	ret c;								// return if so

po_sv_sp:
	ld a, ' ';							// print trailing space

;;
; print save
;;
po_save:
	push de;							// stack DE
	exx;								// preserve HL and BC
	call out_ch_2;						// print one character with leading space suppression
	exx;								// restore HL and BC
	pop de;								// unstack DE
	ret;								// end of subroutine

;;
; table search
;;
po_search:
	ex de, hl;							// base address to HL
	push af;							// stack entry number
	inc a;								// increase range

po_step:
	bit 7, (hl);						// last character?
	inc hl;								// next character
	jr z, po_step;						// jump if not
	dec a;								// reduce count
	jr nz, po_step;						// loop until entry found 
	pop af;								// unstack entry number
	ex de, hl;							// DE points to initial character
	cp 31;								// one of the first 31 entries?
	ret c;								// return with carry set if so
	ld a, (de);							// get initial character
	sub 'A';							// test against letter, leading space if so
	ret;								// end of subroutine

;;
; test for scroll
;;
po_scr:
	ld de, cl_set;						// put sysvar
	push de;							// on the stack
	ld a, b;							// line number to B
	bit 0, (iy + _vdu_flag);			// INPUT or AT?
	jp nz, po_scr_4;					// jump if so
	cp (iy + _df_sz);					// line number less than sysvar?
	jr c, report_oo_scr;				// jump if so
	ret nz;								// return via cl_set if greater
	bit 4, (iy + _vdu_flag);			// automatic listing?
	jr z, po_scr_2;						// jump if not
	ld e, (iy + _breg);					// get line counter
	dec e;								// reduce it
	jr z, po_scr_3;						// jump if listing scroll required
	xor a;								// LD A, 0; channel K
	call chan_open;						// select channel
	ld sp, (list_sp);					// restore stack pointer
	res 4, (iy + _vdu_flag);			// flag automatic listing finished
	ret;								// return via cl_set

report_oo_scr:
	rst error;							// throw
	defb out_of_screen;					// error

po_scr_2:
	dec (iy + _scr_ct);					// reduce scroll count
	jr nz, po_scr_3;					// jump unless zero
	ld a, 24;							// reset
	sub b;								// counter
	ld (scr_ct), a;						// store scroll count
	ld a, 253;							// channel K
	call chan_open;						// select channel
	ld de, scrl_mssg;					// message address
	call po_asciiz_0;					// print it

wait_msg_loop:
	ld hl, vdu_flag;					// address sysvar
	set 5, (hl);						// lower screen requires clearing
	res 3, (hl);						// no echo
	exx;								// alternate register set
	call input_ad;						// get a single key code
	exx;								// main resgister set
	jr nc, wait_msg_loop				// loop, if no key has been pressed
	cp ' ';								// space?
	jr z, report_break;					// treat as BREAK and jump if so
	call chan_open_fe;					// open channel S

po_scr_3:
	call cl_sc_all;						// scroll whole display
	ld b, (iy + _df_sz);				// get line number
	inc b;								// for start of line
	ld c, 81;							// first column
	ret;								// end of subroutine

report_break:
	call flush_kb;						// clear keyboard buffer

	rst error;							// throw
	defb msg_break;						// error

po_scr_4:
	cp 2;								// lower part fits?
	jr c, report_oo_scr;				// error if not
	add a, (iy + _df_sz);				// number of scrolls to A
	sub 25;								// scroll required?
	ret nc;								// return if not
	neg;								// make number positive
	push bc;							// stack line and column numbers

po_scr_4a:
	push af;							// stack number
	ld hl, df_sz;						// address of sysvar
	ld a, (hl);							// df_sz to a
	ld b, a;							// df_sz to b
	inc a;								// increment df_sz
	ld (hl), a;							// store it
	ld l, lo(s_posn_h);					// address sysvar
	cp (hl);							// lower scrolling only required?
	jr c, po_scr_4b;					// jump if so
	inc (hl);							// increment s-posn-h
	ld b, 23;							// scroll whole display

po_scr_4b:
	call cl_scroll;						// scroll number of lines in B
	pop af;								// unstack scroll number
	dec a;								// reduce it
	jr nz, po_scr_4a;					// loop until done
	ld bc, (s_posn);					// get sysvar
	res 0, (iy + _vdu_flag);			// in case changed
	call cl_set;						// give matching value to df_cc
	set 0, (iy + _vdu_flag);			// set lower screen in use
	pop bc;								// unstack line and column numbers
	ret;								// end of subroutine

;;
; <code>PALETTE</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#PALETTE" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_palette:
	call two_param;						// get parameters
	rlca;								// BGR value
	rlca;								// to GRB
	ld e, a;							// data to E
	ld a, b;							// was BC less
	and a;								// than 256?
	jp nz, report_bad_fn_call;			// error if not
	ld a, c;							// color to A
	cp 16;								// valid color (0 to 15)?
	jp nc, report_bad_fn_call;			// error if not
	cp 8;								// color 0 to 7?
	jr nc, col_upper;					// upper entry if not
	call set_pal;						// 1st entry
	add a, 8;							// next
	call set_pal;						// 2nd entry
	add a, 16;							// next
	call set_pal;						// 3rd entry
	add a, 8;							// next
	call set_pal;						// 4th entry
	jr pal_buf;							// immediate jump

col_upper:
	and %00000111;						// keep only lowest three bits_zero
	add a, 16;							// adjust start value
	call set_pal;						// 1st entry
	add a, 24;							// next
	call set_pal;						// 1st entry
	add a, 8;							// next
	call set_pal;						// 3rd entry
	add a, 8;							// next
	call set_pal;						// 4th entry

pal_buf:
	ld a, %00011111;					// ROM 1, VID 1, RAM 7
	ld bc, paging;						// HOME bank paging
	di;									// interrupts off
	out (c), a;							// set it

;	// read palette back into buffer in HOME 7
	ld c, $3b;							// ULAplus port
	ld de, $ffbf;						// d = data, e = register
	ld hl, $dfff;						// last byte of palette map
	ld a, 64;							// becomes 63	

read_pal:
	dec a;								// next register
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	ind;								// in (hl), bc; dec b; dec hl
	and a;								// was that the last register?
	jr nz, read_pal;					// set all 64 entries

	ld a, %00011000;					// ROM 1, VID 1, RAM 0
	ld bc, paging;						// HOME bank paging
	out (c), a;							// set it
	ei;									// interrupts on

	bit 1, (iy + _flags2);				// test for screen 1 (40 column mode)
	ret nz;								// return if so

	jp set_color;						// set color in 80 column mode

set_pal:
	ld bc, $bf3b;						// address I/O register
	out (c), a;							// set it
	ld b, $ff;							// address I/O data
	out (c), e;							// write it
	ret;								// end of routine

;;	// stubs for line drawning commands (not supported in text mode)

c_circle:
	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
	jp nz, v_s1_circle;					// jump if so
	jr no_draw;							// immediate jump

c_draw:
	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
	jp nz, v_s1_draw;					// jump if so
	jr no_draw;							// immediate jump

c_plot:
	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
	jp nz, v_s1_plot;					// jump if so

no_draw:
	call unstack_z;						// return if checking syntax
	rst error;							// else
	defb syntax_error;					// error

;	// 2 spare bytes
;	defs 2, $ff;						// room to add additional stubs

;;
; <code>SCREEN</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#SCREEN" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_screen:
	call test_0_or_1;					// get variable

v_scr_mode:
	and a;								// test for zero
	jp nz, v_s1_init;					// jump if not to initialize screen 1

screen_0:
	res 1, (iy + _flags2);				// signal 80 columns
	ld a, %00110110;					// yellow on blue (with no ULAplus), hi-res mode
	out (scld), a;						// set it
	ld a, %01110001;					// light gray foreground (7), dark blue background (1)
	ld (attr_p), a;						// set permanent attribute
	call set_color;						// set colors
	jp c_cls;							// exit via CLS 80

;	// reserved to extend screen 0 code
	defs 11, $ff;						// RESERVED

	org $0d60;
;;
; <code>CLS</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#CLS" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
v_cls:
c_cls:
	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
	jp nz, v_s1_cls;	    			// jump if so

s0_cls:
	set 0, (iy + _flags);				// suppress leading space

;	// old CLS entry point
	org $0d6b;
	call cl_all;						// clear whole display

;	// UnoDOS 3 entry point
 	org $0d6e;
cls_lower:
	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
	jp nz, v_s1_cls_lower;				// jump if so
	ld hl, vdu_flag;					// address sysvar
	ld b, (iy + _df_sz);				// get address
;	set 0, (hl);						// signal lower part
	res 5, (hl);						// signal no lower screen clear after key
	call cl_line;						// clear lower part of screen
	dec b;								// reduce counter
	ld (iy + _df_sz), 1;				// two lines

cl_chan:
	ld a, 253;							// channel K
	call chan_open;						// select channel
	ld hl, (curchl);					// current channel address
	ld de, print_out;					// output address
	and a;								// clear carry flag

cl_chan_a:
	ld (hl), e;							// set
	inc hl;								// address
	ld (hl), d;							// and advance
	inc hl;								// pointer
	ld de, key_input;					// input address
	ccf;								// complement carry flag
	jr c, cl_chan_a;					// loop until both addresses set
	ld bc, $1851;						// row 24, column 81
	jr cl_set;							// immediate jump

;;
; clear whole display area
;;
cl_all:
	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
	jp nz, v_s1_cl_all; 				// jump if so
	res 0, (iy + _flags2);				// signal screen is clear
	call cl_chan;						// house keeping tasks
	call chan_open_fe;					// open channel S
	ld b, 24;							// 24 lines
	call cl_line;						// clear them
	ld hl, (curchl);					// current channel
	ld de, print_out;					// output address
	ld (hl), e;							// set
	inc hl;								// output
	ld (hl), d;							// address

cl_home:
	ld (iy + _scr_ct), 1;				// reset scroll count
	ld bc, $1851;						// row 24, column 81

;;
; clear set
;;
cl_set:
	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
	jp nz, v_s1_cl_set;         		// jump if so
	ld a, b;							// row to A
	bit 0, (iy + _vdu_flag);			// main display?
	jr z, cl_set_1;						// jump if so
	add a, (iy + _df_sz);				// top row of lower display
	sub 24;								// convert to real line

cl_set_1:
	push bc;							// stack row and column
	ld b, a;							// row to B
	call cl_addr;						// address for start of row to HL
	pop bc;								// unstack row and column
	jp po_store;						// immediate jump

;;
; scrolling
;;
cl_sc_all:
	ld b, 23;							// entry point after scroll message

cl_scroll:
	ld (oldsp), bc;						// temporarily store the counter
	ld bc, paging;						// page in VRAM
	ld a, %00011111;					// ROM 1, VRAM 1, HOME 7
	di;									// interrupts off
	out (c), a;							// do paging
	ld bc, (oldsp);						// restore counter
	ld (oldsp), sp;						// store SP
	ld sp, tstack;						// point to temporary stack

	push bc;							// stack both
	push hl;							// counters
	ld hl, char_map + 80;				// character map + one line
	ld de, char_map;					// start of character map
	ld bc, 1840;						// 80 x 23 characters
	ldir;								// scroll character map
	pop hl;								// unstack both
	pop bc;								// counters

	ei;									// interrupts on
	call cl_addr;						// get start address of row
	ld c, 8;							// eight pixels per row

cl_scr_1:
	push bc;							// stack both
	push hl;							// counters
	ld a, %00000111;					// dealing with
	and b;								// third of display?
	ld a, b;							// restore A
	jr nz, cl_scr_3;					// jump if not

cl_scr_2:
	ld de, $f8e0;						// set destination
	ex de, hl;							// swap pointers
	add hl, de;							// add
	ex de, hl;							// swap pointers
	ld bc, 31;							// 31 bytes per half row
	dec a;								// reduce count
	call ldir2;							// clear half row

cl_scr_3:
	ld de, $ffe0;						// set destination
	ex de, hl;							// swap pointers
	add hl, de;							// add
	ex de, hl;							// swap pointers
	ld b, a;							// row to B
	and %00000111;						// number
	rrca;								// of characters
	rrca;								// in remaining
	rrca;								// third
	ld c, a;							// total to C
	ld a, b;							// row to A
	ld b, 0;							// BC holds total
	call ldir2;							// scroll pixel line
	ld b, 7;							// prepare to cross screen third boundary
	add hl, bc;							// increase HL by 1792
	and %11111000;						// more thirds to consider?
	jr nz, cl_scr_2;					// jump if so
	pop hl;								// unstack original address
	inc h;								// address next pixel row
	pop bc;								// unstack counters
	dec c;								// reduce pixel row counter
	jr nz, cl_scr_1;					// loop until done
	ld b, 1;							// one line

	ld a, %00011000;					// ROM 1, VRAM 1, HOME 0
	di;									// interrupts off
	ld sp, (oldsp);						// restore original stack
	ld (oldsp), bc;						// temporarily store BC
	ld bc, paging;						// page out VRAM
	out (c), a;							// do paging
	ei;									// interrupts on
	ld bc, (oldsp);						// restore BC

;;
; clear lines
;;
cl_line:
	bit 1, (iy + _flags2);				// test for screen 1 (user defined video mode)
	jp nz, v_s1_cl_line;         		// jump if so
	push bc;
	ld (oldsp), bc;						// temporarily store BC
	ld bc, paging;						// page in VRAM
	ld a, %00011111;					// ROM 1, VRAM 1, HOME 7
	di;									// interrupts off
	out (c), a;							// do paging
	ld bc, (oldsp);						// restore BC
	ld (oldsp), sp;						// store SP
	ld sp, tstack;						// point to temporary stack
	ei;									// interrupts on

	push bc;							// store line count
	ld hl, 0;							// zero character count
	ld de, 80;							// 80 characters per line

total_chars:
	add hl, de;							// add 80 to count per line
	djnz total_chars;					// loop until done

	dec hl;								// reduce count by one
	ld c, l;							// HL
	ld b, h;							// to BC

	ld hl, $df7f;						// end of character map
	ld de, $df7e;						// destination
	ld (hl), 0;							// clear last character
	lddr;								// clear lines from end

	pop bc;								// restore count

	call cl_addr;						// start address for row to HL
	ld c, 8;							// eight pixel rows

cl_line_1:
	push bc;							// stack line row and pixel row counter
	push hl;							// stack address
	ld a, b;							// row number to A


cl_line_2:
	and %00000111;						// number of characters
	rrca;								// there are
	rrca;								// B mod 8
	rrca;								// rows
	ld c, a;							// result to C
	ld a, b;							// row number to A
	ld b, 0;							// clear B
	dec c;								// BC to number of characters less one
	push hl;							// stack address
	push bc;							// stack line row and pixel row counter
	set 5, h;							// alter address for second bitmap area
	call cls_2nd;						// clear second bitmap area
	pop bc;								// unstack address

	ld hl, $e000;						// dirty hack to get rid of
	ld (hl), b;							// a screen artefact

	pop hl;								// unstack line row and pixel row
	call cls_2nd;						// clear first bitmap area
	ld de, $0701;						// increment HL by 1793 bytes
	add hl, de;							// for each screen third
	dec a;								// reduce row number
	and %11111000;						// discard extra rows
	ld b, a;							// screen third count to B
	jr nz, cl_line_2;					// loop until done
	pop hl;								// unstack address for pixel row
	inc h;								// and increase pixel row
	pop bc;								// unstack counters
	dec c;								// decrease pixel row count
	jr nz, cl_line_1;					// loop until done
	ld l, e;							// HL to
	ld h, d;							// DE
	inc de;								// increment DE
	ld bc, paging;						// page out VRAM
	ld a, %00011000;					// ROM 1, VRAM 1, HOME 0
	di;									// interrupts off
	out (c), a;							// set it
	ld sp, (oldsp);						// restore stack pointer
	ei;									// interrupts on
	pop bc;								// unstack BC
	ret;								// end of subroutine

ldir2:
	push hl;							// stack source
	push de;							// stack destination
	push bc;							// stack byte count
	set 5, h;							// add 8192 byte offset to source
	set 5, d;							// add 8192 byte offset to destination
	ldir;								// clear odd columns
	pop bc;								// unstack original source
	pop de;								// unstack original destination
	pop hl;								// unstack original byte count
	ldir;								// clear even columns
	ret;								// end of subroutine

cls_2nd:
	ld d, h;							// copy HL
	ld e, l;							// to DE
	ld (hl), 0;							// zero byte addressed by HL
	inc de;								// DE points to next byte
	ldir;								// wipe bytes
	ret;								// end of subroutine

;;
; clear address
;;
cl_addr:
	ld a, 24;							// reverse line
	sub b;								// number
	ld d, a;							// result to D
	rrca;								// A
	rrca;								// mod
	rrca;								// 8
	and %11100000;						// first line
	ld l, a;							// least significant byte to L
	ld a, %00011000;					// get real line number
	and d;								// 64 + 8 * INT (A / 8)
	or $c0;								// top 16K of RAM
	ld h, a;							// most significant byte to H
	inc hl;								// skip first 16 pixels
	ret;								// end of subroutine

;	// entered with PEN and PAPER on calculator stack
;;
; <code>COLOR</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#COLOR" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_color:
	bit 1, (iy + _flags2);				// test for screen 1 (user-defined video mode)
	jp nz, s1_color;					// jump if so

	rst get_char;						// get character
	cp ',';								// comma?
	jr z, cr_3_prms;					// includes border value
	call check_end;						// check end of statement
	jr set_attrs;						// set attributes

cr_3_prms:
	rst next_char;						// get next character
	call expt_1num;						// expect one number
	call check_end;						// check end of statement
	call fp_to_a;						// remove number from stack (ignore it)

set_attrs:
	call fp_to_a;						// background color to A
	cp 16;								// higher than 15?
	jr nc, bad_color;					// jump if out of range
	push af;							// stack background
	call fp_to_a;						// foreground color to A
	pop bc;								// unstack background
	cp 16;								// higher than 15?

bad_color:
	jp nc, report_bad_fn_call;			// jump if out of range

	rlca;								// move low
	rlca;								// nibble
	rlca;								// to high
	rlca;								// nibble
	add a, b;							// restore A
	ld (attr_p), a;						// set permanent attribute

set_color:
	ld c, $3b;							// palette port
	ld de, $ffbf;						// d = data, e = register

	ld a, (attr_p);						// get foreground
	and %11110000;						// mask off foreground
	rrca;								// move high
	rrca;								// nibble
	rrca;								// to low
	rrca;								// nibble
	add a, 32;							// add register offset

	call get_reg;						// get it
	ld l, 22;							// register to write
	call set_reg;						// set it
	ld l, 30;							// register to write
	call set_reg;						// set it

	ld a, (attr_p);						// get background
	and %00001111;						// mask off foreground
	add a, 32;							// add register offset

	call get_reg;						// get it
	ld l, 25;							// register to write
	call set_reg;						// set it

	ret;								// end of subroutine

;	// 4 unused bytes
;	defs 4, $ff;


