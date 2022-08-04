;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2022 Source Solutions, Inc.

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

;	// SCREEN 1 selects the user defined video mode. By default this is a low
;	// resolution 40 column mode. However, because it resides in RAM, it can be
;	// redefined during run time. A flag determines which set of routines to use
;	// and the user defined routines are called using a vector table.

;;
;	// --- USER DEFINED SCREEN HANDLING ROUTINE VECTORS ------------------------
;;
:

	org $4800;

UDV_c_cls:
	jp s40_c_cls;						// CLS

UDV_print_out:
	jp s40_print_out;					// PRINT OUT

UDV_get_cols:
	jp s40_get_cols;					// GET COLS

UDV_input_1:
	jp s40_input_1;						// INPUT 1

UDV_locate:
	jp s40_locate:						// LOCATE

s40_get_cols:
	ld b, 40;							// 40 columns
	ret;								// end of subroutine

s40_input_1:
	ld c, 41;							// leftmost position
	ret;								// end of subroutine

s40_locate:
	ld a, c;							// get column
	or a;								// test for zero
	jp z, loc_err						// jump if so
	cp 41;								// in range?
	jp nc, loc_err;						// error if not
	ld a, b;							// get row
	or a;								// test for zero
	jp z, loc_err;						// jump if so
	cp 24;								// upper screen?
	jp nc, loc_err;						// jump if not
	ld a, 42;							// left most
	jp loc_40;							// immedaite jump

;;
;	// --- 40 COLUMN SCREEN HANDLING ROUTINES ----------------------------------
;;
:

;	// FRAME BUFFER
;	//
;	// $FFFF +---------------+ 65535
;	//       | font          |
;	// $F800 +---------------+ 63488
;	//       | attributes    |
;	// $E000 +---------------+ 57344
;	//       | palette       |
;	// $DFC0 +---------------+ 57280
;	//       | temp stack    |
;	// $DF80 +---------------+ 57216
;	//       | character map |
;	// $D800 +---------------+ 55296
;	//       | bitmap        |
;	// $C000 +---------------+ 49152

;	// WRITE A CHARACTER TO THE SCREEN
;	// There are eight separate routines called based on the first three bits of
;	// the column value.

;	// HL points to the first byte of a character in FONT_1
;	// DE points to the first byte of the block of screen addresses

s40_pos_4:
	inc de;								// DE now points to SCREEN_2 +1
	set 5, d;							// routine continues into s40_pos_0

s40_pos_0:
	ld b, 8;							// 8 bytes to write

s40_pos_0a:
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s40_over_0;						// jump if so
	and %00000011;						// mask area used by new character

s40_over_0:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s40_inverse_0;					// jump if not
	xor %11111100;						// invert

s40_inverse_0:
	ld c, (hl);							// get character from font
	sla c;								// shift left one bit
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	inc d;								// point to next screen location
	inc l;								// point to next font data
	djnz s40_pos_0a;						// loop 8 times
	jp s40_pr_all_f;						// immedaite jump

s40_pos_1:
	ld b, 8;							// 8 bytes to write

s40_pos_1a:
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s40_over_1;						// jump if so
	and %11111100;						// mask area used by new character

s40_over_1:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s40_inverse_1;					// jump if not
	xor %00000011;						// invert

s40_inverse_1:
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
	jr nz, s40_over_1a;						// jump if so
	and %00001111;						// mask area used by new character

s40_over_1a:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s40_inverse_1a;					// jump if not
	xor %11110000;						// invert

s40_inverse_1a:
	ld c, (hl);							// get character from font
	sla c;								// shift left three bits
	sla c;								//
	sla c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	res 5, d;							// restore pointer to SCREEN_1
	inc d;								// point to next screen location
	inc l;								// point to next font data
	djnz s40_pos_1a;						// loop 8 times
	jp s40_pr_all_f;						// immedaite jump

s40_pos_2:
	ld b, 8;							// 8 bytes to write

s40_pos_2a:
	set 5, d;							// DE now points to SCREEN_2
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s40_over_2;						// jump if so
	and %11110000;						// mask area used by new character

s40_over_2:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s40_inverse_2;					// jump if not
	xor %00001111;						// invert

s40_inverse_2:
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
	jr nz, s40_over_2a;						// jump if so
	and %00111111;						// mask area used by new character

s40_over_2a:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s40_inverse_2a;					// jump if not
	xor %11000000;						// invert

s40_inverse_2a:
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
	djnz s40_pos_2a;						// loop 8 times
	jp s40_pr_all_f;						// immedaite jump

s40_pos_7:
	inc de;								// DE now points to SCREEN_2 + 1
	set 5, d;							// routine continues into s40_pos_3

s40_pos_3:
	inc de;								// next column
	ld b, 8;							// 8 bytes to write

s40_pos_3a:
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s40_over_3;						// jump if so
	and %11000000;						// mask area used by new character

s40_over_3:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s40_inverse_3;					// jump if not
	xor %00111111;						// invert

s40_inverse_3:
	ld c, (hl);							// get character from font
	sra c;								// shift right one bit
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	inc d;								// point to next screen location
	inc l;								// point to next font data
	djnz s40_pos_3a;						// loop 8 times
	jp s40_pr_all_f;						// immediate jump

s40_pos_5:
	inc de;								// next column
	ld b, 8;							// 8 bytes to write

s40_pos_5a:
	set 5, d;							// DE now points to SCREEN_2
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s40_over_5;						// jump if so
	and %11111100;						// mask area used by new character

s40_over_5:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s40_inverse_5;					// jump if not
	xor %00000011;						// invert

s40_inverse_5:
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
	jr nz, s40_over_5a;						// jump if so
	and %00001111;						// mask area used by new character

s40_over_5a:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s40_inverse_5a;					// jump if not
	xor %11110000;						// invert

s40_inverse_5a:
	ld c, (hl);							// get character from font
	sla c;								// shift left three bits
	sla c;								//
	sla c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	inc d;								// point to next screen location
	inc l;								// point to next font data
	dec de;								// adjust screen pointer
	djnz s40_pos_5a;						// loop 8 times
	jp s40_pr_all_f;						// immedaite jump

s40_pos_6:
	inc de;								// next column
	inc de;								// next column
	ld b, 8;							// 8 bytes to write

s40_pos_6a:
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s40_over_6;						// jump if so
	and %11110000;						// mask area used by new character

s40_over_6:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s40_inverse_6;					// jump if not
	xor %00001111;						// invert

s40_inverse_6:
	ld c, (hl);							// get character from font
	srl c;								// shift right three bits
	srl c;								//
	srl c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	set 5, d;							// DE now points to SCREEN_2
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s40_over_6a;						// jump if so
	and %00111111;						// mask area used by new character

s40_over_6a:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s40_inverse_6a;					// jump if not
	xor %11000000;						// invert

s40_inverse_6a:
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
	djnz s40_pos_6a;						// loop 8 times
	jp s40_pr_all_f;						// immedaite jump

s40_chr_str_1:
	set 5, (iy + _flags2);				// set force printable flag
	ret;								// done

s40_force_poable:
	res 5, (iy + _flags2);				// clear force printable flag
	jp s40_po_able;							//

s40_chr_str_2:
	set 6, (iy + _flags2);				// set composable flag
	ret;								// done

s40_po_compose:
	res 6, (iy + _flags2);				// clear composable flag
	push af;							// stack character
	call s40_po_left;						// move cursor left
	set 0, (iy + _p_flag);				// set over flag
	pop af;								// unstack character
	call s40_po_able;						// overprint character
	res 0, (iy + _p_flag);				// clear flag
	ret;								// done

;;
; print out
;;
s40_print_out:
	call s40_po_fetch;						// current print position

	bit 5, (iy + _flags2);				// treat next character as printable?
	jr nz, s40_force_poable;				// jump if so

	bit 6, (iy + _flags2);				// is next character composable?
	jr nz, s40_po_compose;					// jump if so

	cp 1;								// CHR$ (1)?
	jr z, s40_chr_str_1;					// make next character printable

	cp 2;								// CHR$ (2)?
	jr z, s40_chr_str_2;					// make next character composable

	cp ' ';								// space or higher?
	jp nc, s40_po_able;						// jump if so
	cp 7;								// character in the range 0 - 6?
	jp c, s40_po_able;						// jump if so
	cp 14;								// character in the range 7 to 13?
	jr c, s40_po_ctrl;						// jump if so
	cp 28;								// characters in the range 14 to 27?
	jr c, s40_po_able;						// jump if so
	sub 14;								// reduce range

s40_po_ctrl:
	ld e, a;							// move character
	ld d, 0;							// to DE
	ld hl, s40_ctlchrtab - 7;				// base of control table
	add hl, de;							// index into table
	ld e, (hl);							// get offset
	add hl, de;							// add offset
	push hl;							// stack it
	jp s40_po_fetch;						// indirect return

s40_ctlchrtab:
	defb s40_po_bel - $;					// 07, BEL
	defb s40_po_able - $;					// 08, BS
	defb s40_po_tab - $;					// 09, HT
	defb s40_po_cr - $;				 		// 10, LF
	defb s40_po_vt - $;						// 11, VT
	defb s40_po_clr - $;					// 12, FF
	defb s40_po_cr - $;						// 13, CR
	defb s40_po_right - $;					// 28, FS
	defb s40_po_left - $;					// 29, GS
	defb s40_po_up - $;						// 30, RS
	defb s40_po_down - $;					// 31, US

;	// sound bell subroutine
s40_po_bel:
	jp bell;							// immediate jump

;;
; print tab
;;
s40_po_tab:
	ld a, c;							// current column
	dec a;								// move right
	dec a;								// twice
	and %00010000;						// test
	call s40_po_fetch;						// current position
	add a, c;							// add column
	dec a;								// number of spaces
	and %00000111;						// modulo 8 (gives 5/10 tabs in 40/80 column mode)
	ret z;								// return if zero
	set 0, (iy + _flags);				// no leading space
	ld d, a;							// use 0 as counter

s40_po_space:
	call s40_po_sv_sp;						// space recursively
	dec d;								// print
	jr nz, s40_po_space;					// until
	ret;								// end of subroutine

;;
; print home
;;
s40_po_vt:
	jp s40_cl_home;							// indirect return

;	// print clr subroutine
s40_po_clr:
	jp s40_c_cls;							// immediate jump

;;
; print carriage return
;
s40_po_cr:
	ld c, 81;							// left column
;	ld c, 41;							// left column
	call s40_po_scr;						// scroll if required
	dec b;								// down a line

s40_jp_s40_cl_set:
	jp s40_cl_set;							// indirect return

;;
; print cursor right
;;
s40_po_right:
	ld hl, p_flag;						// point to sysvar
	ld d, (hl);							// sysvar to D
	ld (hl), 1;							// set printing to OVER
	call s40_po_sv_sp;						// print a space with alt regs
	ld (hl), d;							// restore sysvar
	ret;								// end of subroutine

;;
; print cursor left
;;
s40_po_left:
	inc c;								// move column left
	ld a, 82;							// left side
	cp c;								// against left side?
	jr nz, s40_po_left_1;					// jump if so
	dec c;								// down one line
	ld a, 25;							// top line
	cp b;								// is it?
	jr nz, s40_po_left_1;					// jump if so
	ld c, 2;							// set column value
	inc b;								// up one line

s40_po_left_1:
	jr s40_jp_s40_cl_set;						// indirect return

;;
; print cursor up
;;
s40_po_up:
	inc b;								// move one line up
	ld a, 25;							// screen has 24 lines
	cp b;								// top of screen reached?
	jr nz, s40_jp_s40_cl_set;					// set position, if not
	dec b;								// do nothing
	ret;								// end of subroutine

;;
; print cursor down
;;
s40_po_down:
	ld a, c;							// column to A
	push af;							// stack it
	call s40_po_cr;							// down one row
	pop af;								// unstack A
	cp c;								// compare against current column
	ret z;								// return if nothing to do
	ld c, a;							// restore old column 

s40_cl_scrl:
	call s40_po_scr;						// test for scroll

s40_cl_set2:
	jr s40_jp_s40_cl_set;						// indirect return

;;
; printable character codes
;;
s40_po_able:
	call s40_po_any;						// print character and continue

;;
; position store
;;
s40_po_store:
	bit 0, (iy + _vdu_flag);			// test for lower screen
	jr nz, s40_po_st_e;						// jump if so
	ld (s_posn), bc;					// store values for
	ld (df_cc), hl;						// upper screen
	ret;								// end of subroutine

s40_po_st_e:
	ld (df_ccl), hl;					// store values
	ld (sposnl), bc;					// for lower
	ld (echo_e), bc;					// screen
	ret;								// end of subroutine

;;
; position fetch
;;
s40_po_fetch:
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
s40_po_any:
	push bc;							// stack current position

;	// write to character map
	push hl;							// stack print address
	ex af, af';							// save character
	ld a, 25;							// reverse row and add one
	sub b;								// range 1 to 24
	ld b, a;							// put it back in B
	ld a, 81;							// reverse column
;	ld a, 41;							// reverse column
	sub c;								// range 0 to 39
	ld c, a;							// put it back in C
	ex af, af';							// restore character
	ld hl, char_map;					// base address of character map
	ld de, 80;							// 80 characters per row
;	ld de, 40;							// 40 characters per row
	dec b;								// reduce range (0 to 23)
	jr z, s40_add_columns;					// jump if row zero
	
s40_add_lines:
	add hl, de;							// add 80 characters for each row
	djnz s40_add_lines;						// B holds line count (zero on loop exit)

s40_add_columns:
	add hl, bc;							// Add offset in character map to HL
	bit 0, (iy + _vdu_flag);			// lower screen?
	jr z, s40_write_char;					// jump if not

	jr s40_no_write_char;					// BUG PATCH - lower screen was not updating character map correctly

;	ld b, (iy + _df_sz);				// number of rows in lower display
;	ld de, 80;							// 80 characters per row
;	ld hl, $df80 + 80;					// end of character map + 80 (line 0)

;sbc_lines:
;	sbc hl, de;							// subtract 80 characters for each row
;	djnz sbc_lines;						// B holds line count (zero on loop exit)
;	add hl, bc;							// add column offset
	
s40_write_char:
	ld bc, paging;						// paging address
	ld de, $181f;						// ROM 1, VRAM 1, D = HOME 0, E = HOME 7 
	di;									// interrupts off
	out (c), e;							// page framebuffer in
	ld (hl), a;							// write character to map
	out (c), d;							// page framebuffer out
	ei;									// interrupts on

s40_no_write_char:
	pop hl;								// restore screen address
;	// character map code ends

	ld bc, font;						// font stored in framebuffer at $f800

s40_po_char_2:
	ex de, hl;							// store print address in DE

s40_po_char_3:
	ld l, a;							// character code
	ld h, 0;							// to HL
	add hl, hl;							// multiply
	add hl, hl;							// character
	add hl, hl;							// code
	add hl, bc;							// by eight
	ex de, hl;							// base address to DE
	pop bc;								// unstack current position

;;
; print all characters
;;
s40_pr_all:
	ld a, c;							// get column number
	dec a;								// move it right one position
	ld a, 81;							// new column?
;	ld a, 41;							// new column?
	jr nz, s40_pr_all_1;					// jump if not
	dec b;								// move down
	ld c, a;							// one line

s40_pr_all_1:
	cp c;								// new line?
	push de;							// stack DE
	call z, s40_po_scr;						// scrolling required?
	pop de;								// unstack DE
	push bc;							// stack position
	push hl;							// stack destination
	ld a, 81;							// 80 columns
;	ld a, 41;							// 40 columns
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
	jr z, s40_pr_all_2;						// to next part if so
	ld e, a;							// put A in E
	ld d, 0;							// clear D
	add hl, de;							// add three times
	add hl, de;							// contents of a
	add hl, de;							// to hl

s40_pr_all_2:
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

s40_pr_all_f:
	ld bc, paging;						// page out VRAM
	ld a, %00011000;					// ROM 1, VRAM 1, HOME 0
	di;									// interrupts off
	out (c), a;							// do paging
	ld sp, (oldsp);						// restore stack pointer
	ei;									// interrupts on
	pop hl;								// get original screen position
	pop bc;								// get original row/col
	dec c;								// move right
	ret;								// return via s40_po_store

;	// message printing subroutine
;;
; print first message
;;
s40_po_asciiz_0:
	xor a;								// select first message
	set 2, (iy + _flags2);				// signal do not print tokens (for example, scroll during LIST)
	set 5, (iy + _vdu_flag);			// signal lower screen to be cleared

;	// message number in A, start of table in DE
;;
; message printing
;;
s40_po_asciiz:
	and a;								// message zero?
	call nz, s40_po_srch_asciiz;			// if not, locate message
	ld a, (de);							// get character

s40_po_asciiz_chr:
	cp 2;								// composable character pair?
	jr z, s40_po_asciiz_composable;			// jump if so
	call s40_po_save;						// print with alternate register set

s40_po_asciiz_next:
	inc de;								// next character
	ld a, (de);							// get character
	and a;								// null terminator?
	jr nz, s40_po_asciiz_chr;				// loop until done
	ret;								// end of subroutine

s40_po_asciiz_composable:
	ld hl, sposnl;						// cursor
	inc (hl);							// left
	inc de;								// next character
	ld a, (de);							// get character
	set 0, (iy + _p_flag);				// set over flag
	call s40_po_save;						// print with alternate register set
	res 0, (iy + _p_flag);				// clear flag
	jr s40_po_asciiz_next;					// immediate jump

s40_po_srch_asciiz:
	ld b, a;							// count to B

s40_po_stp_asciiz:
	ld a, (de);							// contents in table pointer to A
	inc de;								// point to next address
	and a;								// terminator found?
	jr nz, s40_po_stp_asciiz;				// loop until found
	djnz s40_po_stp_asciiz;					// loop until correct entry found
	ret;								// return with pointer to message in DE
;	// end of ASCIIZ printing

;	// SpectraNet entry point
;	org $c0a;
;s40_po_msg:
;	push hl;							// stack last entry
;	ld h, 0;							// zero high byte
;	ex (sp), hl;						// to suppress trailing spaces
;	jr s40_po_table;						// immediate jump

;	// token printing subroutine
s40_po_token:
	sub first_tk;						// modify token code

s40_po_tokens:
	ld de, token_table;					// address token table
	push af;							// stack code
	call s40_po_search;						// locate required entry
	jr c, s40_po_each;						// print message or token
	bit 0, (iy + _flags);				// print a space
	call z, s40_po_sv_sp;					// if required

s40_po_each:
	ld a, (de);							// get code
	and %01111111;						// cancel inverted bit
	call s40_po_save;						// print the character
	ld a, (de);							// get code again
	inc de;								// increment pointer
	add a, a;							// inverted bit to carry flag
	jr nc, s40_po_each;						// loop until done
	pop de;								// D = 0 to 127 for tokens, 0 for messages
;	cp 72;								// last character a $?
;	jr z, s40_po_tr_sp;						// jump if so
	cp 130;								// last character less than A?
	ret c;								// return if so

s40_po_tr_sp:
	ld a, d;							// offset to A
	cp 1;								// FN?
	jr z, s40_po_sv_sp;						// jump if so
	cp 7;								// EOF #, INKEY$, LOC #, LOF#, PI, RND
	ret c;								// return if so

s40_po_sv_sp:
	ld a, ' ';							// print trailing space

;;
; print save
;;
s40_po_save:
	push de;							// stack DE
	exx;								// preserve HL and BC
	call out_ch_2;						// print one character with leading space suppression
	exx;								// restore HL and BC
	pop de;								// unstack DE
	ret;								// end of subroutine

;;
; table search
;;
s40_po_search:
	ex de, hl;							// base address to HL
	push af;							// stack entry number
	inc a;								// increase range

s40_po_step:
	bit 7, (hl);						// last character?
	inc hl;								// next character
	jr z, s40_po_step;						// jump if not
	dec a;								// reduce count
	jr nz, s40_po_step;						// loop until entry found 
	ex de, hl;							// DE points to initial character
	pop af;								// unstack entry number
	cp 31;								// one of the first 31 entries?
	ret c;								// return with carry set if so
	ld a, (de);							// get initial character
	sub 'A';							// test against letter, leading space if so
	ret;								// end of subroutine

;;
; test for scroll
;;
s40_po_scr:
	ld de, s40_cl_set;						// put sysvar
	push de;							// on the stack
	ld a, b;							// line number to B
	bit 0, (iy + _vdu_flag);			// INPUT or AT?
	jp nz, s40_po_scr_4;					// jump if so
	cp (iy + _df_sz);					// line number less than sysvar?
	jr c, s40_report_oo_scr;				// jump if so
	ret nz;								// return via s40_cl_set if greater
	bit 4, (iy + _vdu_flag);			// automatic listing?
	jr z, s40_po_scr_2;						// jump if not
	ld e, (iy + _breg);					// get line counter
	dec e;								// reduce it
	jr z, s40_po_scr_3;						// jump if listing scroll required
	xor a;								// LD A, 0; channel K
	call chan_open;						// select channel
	ld sp, (list_sp);					// restore stack pointer
	res 4, (iy + _vdu_flag);			// flag automatic listing finished
	ret;								// return via s40_cl_set

s40_report_oo_scr:
	rst error;							// throw
	defb out_of_screen;					// error

s40_po_scr_2:
	dec (iy + _scr_ct);					// reduce scroll count
	jr nz, s40_po_scr_3;					// jump unless zero
	ld a, 24;							// reset
	sub b;								// counter
	ld (scr_ct), a;						// store scroll count
	ld a, 253;							// channel K
	call chan_open;						// select channel
	ld de, scrl_mssg;					// message address
	call s40_po_asciiz_0;					// print it

s40_wait_msg_loop:
	ld hl, vdu_flag;					// address sysvar
	set 5, (hl);						// lower screen requires clearing
	res 3, (hl);						// no echo
	exx;								// alternate register set
	call input_ad;						// get a single key code
	exx;								// main resgister set
	jr nc, s40_wait_msg_loop				// loop, if no key has been pressed
	cp ' ';								// space?
	jr z, s40_report_break;					// treat as BREAK and jump if so
	call chan_open_fe;					// open channel S

s40_po_scr_3:
	call s40_cl_sc_all;						// scroll whole display
	ld b, (iy + _df_sz);				// get line number
	inc b;								// for start of line
	ld c, 81;							// first column
;	ld c, 41;							// first column
	ret;								// end of subroutine

s40_report_break:
	call flush_kb;						// clear keyboard buffer

	rst error;							// throw
	defb msg_break;						// error

s40_po_scr_4:
	cp 2;								// lower part fits?
	jr c, s40_report_oo_scr;				// error if not
	add a, (iy + _df_sz);				// number of scrolls to A
	sub 25;								// scroll required?
	ret nc;								// return if not
	neg;								// make number positive
	push bc;							// stack line and column numbers

s40_po_scr_4a:
	push af;							// stack number
	ld hl, df_sz;						// address of sysvar
	ld a, (hl);							// df_sz to a
	ld b, a;							// df_sz to b
	inc a;								// increment df_sz
	ld (hl), a;							// store it
	ld l, lo(s_posn_h);					// address sysvar
	cp (hl);							// lower scrolling only required?
	jr c, s40_po_scr_4b;					// jump if so
	inc (hl);							// increment s-posn-h
	ld b, 23;							// scroll whole display

s40_po_scr_4b:
	call s40_cl_scroll;						// scroll number of lines in B
	pop af;								// unstack scroll number
	dec a;								// reduce it
	jr nz, s40_po_scr_4a;					// loop until done
	ld bc, (s_posn);					// get sysvar
	res 0, (iy + _vdu_flag);			// in case changed
	call s40_cl_set;						// give matching value to df_cc
	set 0, (iy + _vdu_flag);			// set lower screen in use
	pop bc;								// unstack line and column numbers
	ret;								// end of subroutine

;;
; <code>CLS</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#CLS" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
s40_c_cls:
	set 0, (iy + _flags);				// suppress leading space
	call s40_cl_all;						// clear whole display

s40_cls_lower:
	ld hl, vdu_flag;					// address sysvar
	ld b, (iy + _df_sz);				// get address
;	set 0, (hl);						// signal lower part
	res 5, (hl);						// signal no lower screen clear after key
	call s40_cl_line;						// clear lower part of screen
	dec b;								// reduce counter
	ld (iy + _df_sz), 1;				// two lines

s40_cl_chan:
	ld a, 253;							// channel K
	call chan_open;						// select channel
	ld hl, (curchl);					// current channel address
	ld de, s40_print_out;					// output address
	and a;								// clear carry flag

s40_cl_chan_a:
	ld (hl), e;							// set
	inc hl;								// address
	ld (hl), d;							// and advance
	inc hl;								// pointer
	ld de, key_input;					// input address
	ccf;								// complement carry flag
	jr c, s40_cl_chan_a;					// loop until both addresses set
	ld bc, $1851;						// row 24, column 81
;	ld bc, $1829;						// row 24, column 41
	jr s40_cl_set;							// immediate jump

;;
; clear whole display area
;;
s40_cl_all:
	res 0, (iy + _flags2);				// signal screen is clear
	call s40_cl_chan;						// house keeping tasks
	call chan_open_fe;					// open channel S
	ld b, 24;							// 24 lines
	call s40_cl_line;						// clear them
	ld hl, (curchl);					// current channel
	ld de, s40_print_out;					// output address
	ld (hl), e;							// set
	inc hl;								// output
	ld (hl), d;							// address

s40_cl_home:
	ld (iy + _scr_ct), 1;				// reset scroll count
	ld bc, $1851;						// row 24, column 81
;	ld bc, $1829;						// row 24, column 41

;;
; clear set
;;
s40_cl_set:
	ld a, b;							// row to A
	bit 0, (iy + _vdu_flag);			// main display?
	jr z, s40_cl_set_1;						// jump if so
	add a, (iy + _df_sz);				// top row of lower display
	sub 24;								// convert to real line

s40_cl_set_1:
	push bc;							// stack row and column
	ld b, a;							// row to B
	call s40_cl_addr;						// address for start of row to HL
	pop bc;								// unstack row and column
	jp s40_po_store;						// immediate jump

;;
; scrolling
;;
s40_cl_sc_all:
	ld b, 23;							// entry point after scroll message

s40_cl_scroll:
	ld (oldsp), bc;						// temporarily store the counter
	ld bc, paging;						// page in VRAM
	ld a, %00011111;					// ROM 0, VRAM 1, HOME 7
	di;									// interrupts off
	out (c), a;							// do paging
	ld bc, (oldsp);						// restore counter
	ld (oldsp), sp;						// store SP
	ld sp, tstack;						// point to temporary stack

	push bc;							// stack both
	push hl;							// counters
;	ld hl, char_map + 80;				// character map + one line
	ld hl, char_map + 40;				// character map + one line
	ld de, char_map;					// start of character map
	ld bc, 1840;						// 80 x 23 characters
	ldir;								// scroll character map
	pop hl;								// unstack both
	pop bc;								// counters

	ei;									// interrupts on
	call s40_cl_addr;						// get start address of row
	ld c, 8;							// eight pixels per row

s40_cl_scr_1:
	push bc;							// stack both
	push hl;							// counters
	ld a, b;							// B to A
	and %00000111;						// dealing with third of display?
	ld a, b;							// restore A
	jr nz, s40_cl_scr_3;					// jump if not

s40_cl_scr_2:
	ex de, hl;							// swap pointers
	ld hl, $f8e0;						// set DE to
	add hl, de;							// destination
	ex de, hl;							// swap pointers
	ld bc, 32;							// 32 bytes per half row
	dec a;								// reduce count
	call s40_ldir2;							// clear half row

s40_cl_scr_3:
	ex de, hl;							// swap pointers
	ld hl, $ffe0;						// set DE to
	add hl, de;							// destination
	ex de, hl;							// swap pointers
	ld b, a;							// row to B
	and %00000111;						// number
	rrca;								// of characters
	rrca;								// in remaining
	rrca;								// third
	ld c, a;							// total to C
	ld a, b;							// row to A
	ld b, 0;							// BC holds total
	call s40_ldir2;							// scroll pixel line
	ld b, 7;							// prepare to cross screen third boundary
	add hl, bc;							// increase HL by 1792
	and %11111000;						// more thirds to consider?
	jr nz, s40_cl_scr_2;					// jump if so
	pop hl;								// unstack original address
	inc h;								// address next pixel row
	pop bc;								// unstack counters
	dec c;								// reduce pixel row counter
	jr nz, s40_cl_scr_1;					// loop until done
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
s40_cl_line:
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
;	ld de, 40;							// 40 characters per line

s40_total_chars:
	add hl, de;							// add 40 to count per line
	djnz s40_total_chars;					// loop until done

	dec hl;								// reduce count by one
	ld c, l;							// HL
	ld b, h;							// to BC

	ld hl, $df7f;						// end of character map
	ld de, $df7e;						// destination
	ld (hl), 0;							// clear last character
	lddr;								// clear lines from end

	pop bc;								// restore count

	call s40_cl_addr;						// start address for row to HL
	ld c, 8;							// eight pixel rows

s40_cl_line_1:
	push bc;							// stack line row and pixel row counter
	push hl;							// stack address
	ld a, b;							// row number to A


s40_cl_line_2:
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
	call s40_cls_2nd;						// clear second bitmap area
	pop bc;								// unstack address
	pop hl;								// unstack line row and pixel row
	call s40_cls_2nd;						// clear first bitmap area
	ld de, $0701;						// increment HL by 1793 bytes
	add hl, de;							// for each screen third
	dec a;								// reduce row number
	and %11111000;						// discard extra rows
	ld b, a;							// screen third count to B
	jr nz, s40_cl_line_2;					// loop until done
	pop hl;								// unstack address for pixel row
	inc h;								// and increase pixel row
	pop bc;								// unstack counters
	dec c;								// decrease pixel row count
	jr nz, s40_cl_line_1;					// loop until done
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

s40_ldir2:
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

s40_cls_2nd:
	ld d, h;							// copy HL
	ld e, l;							// to DE
	ld (hl), 0;							// zero byte addressed by HL
	inc de;								// DE points to next byte
	ldir;								// wipe bytes
	ret;								// end of subroutine

;;
; clear address
;;
s40_cl_addr:
	ld a, 24;							// reverse line
	sub b;								// number
	ld d, a;							// result to D
	rrca;								// A
	rrca;								// mod
	rrca;								// 8
	and %11100000;						// first line
	ld l, a;							// least significant byte to L
	ld a, d;							// get real line number
	and %00011000;						// 64 + 8 * INT (A / 8)
	or $c0;								// top 16K of RAM
	ld h, a;							// most significant byte to H
;	inc hl;								// (not needed in 80 column mode) skip first 16 pixels
	ret;								// end of subroutine
