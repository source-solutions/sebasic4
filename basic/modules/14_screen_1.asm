;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2023 Source Solutions, Inc.

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

	org $4500

v_s1_init:
	jp s1_init;							// initialize screen

v_s1_cls:
	jp s1_cls;							// CLS

v_s1_cls_lower:
	jp s1_cls_lower;					// CLS LOWER

v_s1_cl_all:
	jp s1_cl_all;						// CL ALL

v_s1_cl_set:
	jp s1_cl_set;						// CL SET

v_s1_cl_line:
	jp s1_cl_line;						// CL LINE

v_s1_print_out:
	jp s1_print_out;					// PRINT OUT

v_s1_arc:
	jp s1_arc;							// ARC command

v_s1_circle:
	jp s1_circle;						// CIRCLE command

v_s1_draw:
	jp s1_draw;							// DRAW command

v_s1_plot;
	jp s1_plot;							// PLOT command

v_s1_get_cols:
	jp s1_get_cols;						// GET COLS

v_s1_input_1:
	jp s1_input_1;						// INPUT 1

v_s1_locate:
	jp s1_locate;						// LOCATE

s1_table:
	defw s1_pos_0;
	defw s1_pos_1;
	defw s1_pos_2;
	defw s1_pos_3;

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

s1_pos_0:
	ld b, 8;							// 8 bytes to write

s1_pos_0a:
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s1_over_0;					// jump if so
	and %00000011;						// mask area used by new character

s1_over_0:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s1_inverse_0;					// jump if not
	xor %11111100;						// invert

s1_inverse_0:
	ld c, (hl);							// get character from font
	sla c;								// shift left one bit
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	set 5, d;							// DE now points to attributes
	ld a, (attr_p);						// get current attribute
	ld (de), a;							// write it
	res 5, d;							// restore pointer
	inc d;								// point to next screen location
	inc l;								// point to next font data
	djnz s1_pos_0a;						// loop 8 times
	jp s1_pr_all_f;						// immedaite jump

s1_pos_1:
	ld b, 8;							// 8 bytes to write

s1_pos_1a:
	dec e;								// previous screen address
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s1_over_1;					// jump if so
	and %11111100;						// mask area used by new character

s1_over_1:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s1_inverse_1;					// jump if not
	xor %00000011;						// invert

s1_inverse_1:
	ld c, (hl);							// get character from font
	srl c;								// shift left five bits
	srl c;								//
	srl c;								//
	srl c;								//
	srl c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	set 5, d;							// DE now points to attributes
	ld a, (attr_p);						// get current attribute
	ld (de), a;							// write it
	res 5, d;							// restore pointer
	inc e;								// next screen address
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s1_over_1a;					// jump if so
	and %00001111;						// mask area used by new character

s1_over_1a:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s1_inverse_1a;				// jump if not
	xor %11110000;						// invert

s1_inverse_1a:
	ld c, (hl);							// get character from font
	sla c;								// shift left three bits
	sla c;								//
	sla c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	set 5, d;							// DE now points to attributes
	ld a, (attr_p);						// get current attribute
	ld (de), a;							// write it
	res 5, d;							// restore pointer
	inc d;								// point to next screen location
	inc l;								// point to next font data
	djnz s1_pos_1a;						// loop 8 times
	jp s1_pr_all_f;						// immedaite jump

s1_pos_2:
	ld b, 8;							// 8 bytes to write

s1_pos_2a:
	dec e;								// reduce screen pointer
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s1_over_2;					// jump if so
	and %11110000;						// mask area used by new character

s1_over_2:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s1_inverse_2;					// jump if not
	xor %00001111;						// invert

s1_inverse_2:
	ld c, (hl);							// get character from font
	srl c;								// shift right three bits
	srl c;								//
	srl c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	set 5, d;							// DE now points to attributes
	ld a, (attr_p);						// get current attribute
	ld (de), a;							// write it
	res 5, d;							// restore pointer
	inc e;								// increase screen pointer
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s1_over_2a;					// jump if so
	and %00111111;						// mask area used by new character

s1_over_2a:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s1_inverse_2a;				// jump if not
	xor %11000000;						// invert

s1_inverse_2a:
	ld c, (hl);							// get character from font
	sla c;								// shift left five bits
	sla c;								//
	sla c;								//
	sla c;								//
	sla c;								//
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	set 5, d;							// DE now points to attributes
	ld a, (attr_p);						// get current attribute
	ld (de), a;							// write it
	res 5, d;							// restore pointer
	inc d;								// point to next screen location
	inc l;								// point to next font data
	djnz s1_pos_2a;						// loop 8 times
	jp s1_pr_all_f;						// immedaite jump

s1_pos_3:
	dec e;								// back one character
	ld b, 8;							// 8 bytes to write

s1_pos_3a:
	ld a, (de);							// read byte at destination
	bit 0, (iy + _p_flag);				// over?
	jr nz, s1_over_3;					// jump if so
	and %11000000;						// mask area used by new character

s1_over_3:
	bit 2, (iy + _p_flag);				// inverse?
	jr z, s1_inverse_3;					// jump if not
	xor %00111111;						// invert

s1_inverse_3:
	ld c, (hl);							// get character from font
	sra c;								// shift right one bit
	xor c;								// combine with character from font
	ld (de), a;							// write it back
	set 5, d;							// DE now points to attributes
	ld a, (attr_p);						// get current attribute
	ld (de), a;							// write it
	res 5, d;							// restore pointer
	inc d;								// point to next screen location
	inc l;								// point to next font data
	djnz s1_pos_3a;						// loop 8 times
	jp s1_pr_all_f;						// immediate jump

;---

s1_chr_str_1:
	set 5, (iy + _flags2);				// set force printable flag
	ret;								// done

s1_force_poable:
	res 5, (iy + _flags2);				// clear force printable flag
	jp s1_po_able;						//

s1_chr_str_2:
	set 6, (iy + _flags2);				// set composable flag
	ret;								// done

s1_po_compose:
	res 6, (iy + _flags2);				// clear composable flag
	push af;							// stack character
	call s1_po_left;					// move cursor left
	set 0, (iy + _p_flag);				// set over flag
	pop af;								// unstack character
	call s1_po_able;					// overprint character
	res 0, (iy + _p_flag);				// clear flag
	ret;								// done

;;
; print out
;;
s1_print_out:
;	call s1_po_fetch;					// current print position
	call po_fetch;						// current print position (screen 0 code)

	bit 5, (iy + _flags2);				// treat next character as printable?
	jr nz, s1_force_poable;				// jump if so

	bit 6, (iy + _flags2);				// is next character composable?
	jr nz, s1_po_compose;				// jump if so

	cp 1;								// CHR$ (1)?
	jr z, s1_chr_str_1;					// make next character printable

	cp 2;								// CHR$ (2)?
	jr z, s1_chr_str_2;					// make next character composable

	cp ' ';								// space or higher?
	jp nc, s1_po_able;					// jump if so
	cp 7;								// character in the range 0 - 6?
	jp c, s1_po_able;					// jump if so
	cp 14;								// character in the range 7 to 13?
	jr c, s1_po_ctrl;					// jump if so
	cp 28;								// characters in the range 14 to 27?
	jr c, s1_po_able;					// jump if so
	sub 14;								// reduce range

s1_po_ctrl:
	ld e, a;							// move character
	ld d, 0;							// to DE
	ld hl, s1_ctlchrtab - 7;			// base of control table
	add hl, de;							// index into table
	ld e, (hl);							// get offset
	add hl, de;							// add offset
	push hl;							// stack it
;	jp s1_po_fetch;						// indirect return
	jp po_fetch;						// indirect return (screen 0 code)

s1_ctlchrtab:
	defb s1_po_bel - $;					// 07, BEL
	defb s1_po_able - $;				// 08, BS
	defb s1_po_tab - $;					// 09, HT
	defb s1_po_cr - $;					// 10, LF
	defb s1_po_vt - $;					// 11, VT
	defb s1_po_clr - $;					// 12, FF
	defb s1_po_cr - $;					// 13, CR
	defb s1_po_right - $;				// 28, FS
	defb s1_po_left - $;				// 29, GS
	defb s1_po_up - $;					// 30, RS
	defb s1_po_down - $;				// 31, US

;	// sound bell subroutine
s1_po_bel:
	jp bell;							// immediate jump

;;
; print tab
;;
s1_po_tab:
	jp po_tab;							// screen 0 code
;	ld a, c;							// current column
;	dec a;								// move right
;	dec a;								// twice
;	and %00010000;						// test
;	call s1_po_fetch;					// current position
;	add a, c;							// add column
;	dec a;								// number of spaces
;	and %00000111;						// modulo 8 (gives 5/10 tabs in 40/80 column mode)
;	ret z;								// return if zero
;	set 0, (iy + _flags);				// no leading space
;	ld d, a;							// use 0 as counter
;
;s1_po_space:
;	call s1_po_sv_sp;					// space recursively
;	dec d;								// print
;	jr nz, s1_po_space;					// until
;	ret;								// end of subroutine

;;
; print home
;;
s1_po_vt:
	jp s1_cl_home;						// indirect return

;	// print clr subroutine
s1_po_clr:
	jp s1_cls;							// immediate jump

;;
; print carriage return
;;
s1_po_cr:
	ld c, 41;							// left column
	call s1_po_scr;						// scroll if required
	dec b;								// down a line

s1_jp_cl_set:
	jp s1_cl_set;						// indirect return

;;
; print cursor right
;;
s1_po_right:
;	ld hl, p_flag;						// point to sysvar
;	ld d, (hl);							// sysvar to D
;	ld (hl), 1;							// set printing to OVER
;	call s1_po_sv_sp;					// print a space with alt regs
;	call po_sv_sp;						// print a space with alt regs (screen 0 code)
;	ld (hl), d;							// restore sysvar
;	ret;								// end of subroutine
	jp po_right;						// screen 0 code

;;
; print cursor left
;;
s1_po_left:
	inc c;								// move column left
	ld a, 42;							// left side
	cp c;								// against left side?
	jr nz, s1_po_left_1;				// jump if so
	dec c;								// down one line
	ld a, 25;							// top line
	cp b;								// is it?
	jr nz, s1_po_left_1;				// jump if so
	ld c, 2;							// set column value
	inc b;								// up one line

s1_po_left_1:
	jr s1_jp_cl_set;					// indirect return

;;
; print cursor up
;;
s1_po_up:
	inc b;								// move one line up
	ld a, 25;							// screen has 24 lines
	cp b;								// top of screen reached?
	jr nz, s1_jp_cl_set;				// set position, if not
	dec b;								// do nothing
	ret;								// end of subroutine

;;
; print cursor down
;;
s1_po_down:
	ld a, c;							// column to A
	push af;							// stack it
	call s1_po_cr;						// down one row
	pop af;								// unstack A
	cp c;								// compare against current column
	ret z;								// return if nothing to do
	ld c, a;							// restore old column 

s1_cl_scrl:
	call s1_po_scr;						// test for scroll

s1_cl_set2:
	jr s1_jp_cl_set;					// indirect return

;;
; printable character codes
;;
s1_po_able:
	call s1_po_any;						// print character and continue
	jp po_store;						// screen 0 code

;;
; position store
;;
;s1_po_store:
;	bit 0, (iy + _vdu_flag);			// test for lower screen
;	jr nz, s1_po_st_e;					// jump if so
;	ld (s_posn), bc;					// store values for
;	ld (df_cc), hl;						// upper screen
;	ret;								// end of subroutine
;
;s1_po_st_e:
;	ld (df_ccl), hl;					// store values
;	ld (sposnl), bc;					// for lower
;	ld (echo_e), bc;					// screen
;	ret;								// end of subroutine

;;
; position fetch
;;
;s1_po_fetch:
;	ld hl, (df_cc);						// get main
;	ld bc, (s_posn);					// screen values
;	bit 0, (iy + _vdu_flag);			// main screen?
;	ret z;								// return if so
;	ld bc, (sposnl);					// get lower
;	ld hl, (df_ccl);					// screen values
;	ret;								// and return

;;
; print any character
;;
s1_po_any:
	push bc;							// stack current position

;	// write to character map
	push hl;							// stack print address
	ex af, af';							// save character
	ld a, 25;							// reverse row and add one
	sub b;								// range 1 to 24
	ld b, a;							// put it back in B
	ld a, 41;							// reverse column
	sub c;								// range 0 to 39
	ld c, a;							// put it back in C
	ex af, af';							// restore character
	ld hl, char_map;					// base address of character map
	ld de, 40;							// 40 characters per row
	dec b;								// reduce range (0 to 23)
	jr z, s1_add_columns;				// jump if row zero
	
s1_add_lines:
	add hl, de;							// add 80 characters for each row
	djnz s1_add_lines;					// B holds line count (zero on loop exit)

s1_add_columns:
	add hl, bc;							// Add offset in character map to HL
	bit 0, (iy + _vdu_flag);			// lower screen?
	jr z, s1_write_char;				// jump if not

	jr s1_no_write_char;				// BUG PATCH - lower screen was not updating character map correctly

;	ld b, (iy + _df_sz);				// number of rows in lower display
;	ld de, 40;							// 40 characters per row
;	ld hl, $df80 + 40;					// end of character map + 80 (line 0)

;sbc_lines:
;	sbc hl, de;							// subtract 80 characters for each row
;	djnz sbc_lines;						// B holds line count (zero on loop exit)
;	add hl, bc;							// add column offset
	
s1_write_char:
	ld bc, paging;						// paging address
	ld de, $181f;						// ROM 1, VRAM 1, D = HOME 0, E = HOME 7 
	di;									// interrupts off
	out (c), e;							// page framebuffer in
	ld (hl), a;							// write character to map
	out (c), d;							// page framebuffer out
	ei;									// interrupts on

s1_no_write_char:
	pop hl;								// restore screen address
;	// character map code ends

	ld bc, font;						// font stored in framebuffer at $f800

s1_po_char_2:
	ex de, hl;							// store print address in DE

s1_po_char_3:
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
s1_pr_all:
	ld a, c;							// get column number
	dec a;								// move it right one position
	ld a, 41;							// new column?
	jr nz, s1_pr_all_1;					// jump if not
	dec b;								// move down
	ld c, a;							// one line

s1_pr_all_1:
	cp c;								// new line?
	push de;							// stack DE
	call z, s1_po_scr;					// scrolling required?
	pop de;								// unstack DE
	push bc;							// stack position
	push hl;							// stack destination
	ld a, 41;							// 40 columns

s1_pr_all_common:
	sub c;								// get position
	ld b, a;							// save it

	and %00000011;						// mask off bit 0-2

	ld c, a;							// store number of routine to use
	ld a, b;							// retrieve it
	and $78;							// mask off bit 3-6
	rrca;								// shift three
	rrca;								// bits to
	rrca;								// the right
	and a;								// test for zero
	push de;							// save font address
	jr z, s1_pr_all_2;					// to next part if so
	ld e, a;							// put A in E
	ld d, 0;							// clear D
	add hl, de;							// add three times
	add hl, de;							// contents of a
	add hl, de;							// to hl

s1_pr_all_2:
	ex de, hl;							// put the result back in DE

;	// HL now points to the location of the first byte of char data in FONT_1
;	// DE points to the first screen byte in SCREEN_1
;	// C holds the offset to the routine

	ld b, 0;							// prepare to add
	rlc c;								// double the value in C
	ld hl, s1_table;					// base address of table
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

s1_pr_all_f:
	ld bc, paging;						// page out VRAM
	ld a, %00011000;					// ROM 1, VRAM 1, HOME 0
	di;									// interrupts off
	out (c), a;							// do paging
	ld sp, (oldsp);						// restore stack pointer
	ei;									// interrupts on
	pop hl;								// get original screen position
	pop bc;								// get original row/col
	dec c;								// move right

	ld a, c;							// column position to A
	and %00000111;						// mask bits 0 to 2
	cp %00000101;						// 37, 29, 21, 13 or 5?
	ret z;								// return if so
	cp %00000001;						// 33, 25, 17, 9 or 1?
	jr z, s1_backpos;					// jump if so
	inc hl;								// advance screen position
	ret;								// return using po_store

s1_backpos:
	dec hl;								// move screen posistion
	dec hl;								// back three
	dec hl;								// cells
	ret;								// end of subroutine

;	// message printing subroutine
;;
; print first message
;;
;s1_po_asciiz_0:
;	xor a;								// select first message
;	set 2, (iy + _flags2);				// signal do not print tokens (for example, scroll during LIST)
;	set 5, (iy + _vdu_flag);			// signal lower screen to be cleared

;	// message number in A, start of table in DE
;;
; message printing
;;
;s1_po_asciiz:
;	and a;								// message zero?
;	call nz, s1_po_srch_asciiz;			// if not, locate message
;	ld a, (de);							// get character
;
;s1_po_asciiz_chr:
;	cp 2;								// composable character pair?
;	jr z, s1_po_asciiz_composable;		// jump if so
;	call s1_po_save;					// print with alternate register set
;
;s1_po_asciiz_next:
;	inc de;								// next character
;	ld a, (de);							// get character
;	and a;								// null terminator?
;	jr nz, s1_po_asciiz_chr;			// loop until done
;	ret;								// end of subroutine
;
;s1_po_asciiz_composable:
;	ld hl, sposnl;						// cursor
;	inc (hl);							// left
;	inc de;								// next character
;	ld a, (de);							// get character
;	set 0, (iy + _p_flag);				// set over flag
;	call s1_po_save;					// print with alternate register set
;	res 0, (iy + _p_flag);				// clear flag
;	jr s1_po_asciiz_next;				// immediate jump
;
;s1_po_srch_asciiz:
;	ld b, a;							// count to B
;
;s1_po_stp_asciiz:
;	ld a, (de);							// contents in table pointer to A
;	inc de;								// point to next address
;	and a;								// terminator found?
;	jr nz, s1_po_stp_asciiz;			// loop until found
;	djnz s1_po_stp_asciiz;				// loop until correct entry found
;	ret;								// return with pointer to message in DE
;	// end of ASCIIZ printing

;	// token printing subroutine
;s1_po_token:
;	sub first_tk;						// modify token code
;
;s1_po_tokens:
;	ld de, token_table;					// address token table
;	push af;							// stack code
;;	call s1_po_search;					// locate required entry
;	call po_search;						// locate required entry
;	jr c, s1_po_each;					// print message or token
;	bit 0, (iy + _flags);				// print a space
;	call z, s1_po_sv_sp;				// if required
;
;s1_po_each:
;	ld a, (de);							// get code
;	and %01111111;						// cancel inverted bit
;	call s1_po_save;					// print the character
;	ld a, (de);							// get code again
;	inc de;								// increment pointer
;	add a, a;							// inverted bit to carry flag
;	jr nc, s1_po_each;					// loop until done
;	pop de;								// D = 0 to 127 for tokens, 0 for messages
;;	cp 72;								// last character a $?
;;	jr z, s1_po_tr_sp;					// jump if so
;	cp 130;								// last character less than A?
;	ret c;								// return if so
;
;s1_po_tr_sp:
;	ld a, d;							// offset to A
;	cp 1;								// FN?
;	jr z, s1_po_sv_sp;					// jump if so
;	cp 7;								// EOF #, INKEY$, LOC #, LOF#, PI, RND
;	ret c;								// return if so
;
;s1_po_sv_sp:
;	ld a, ' ';							// print trailing space
;
;;;
;; print save
;;;
;s1_po_save:
;	push de;							// stack DE
;	exx;								// preserve HL and BC
;	call out_ch_2;						// print one character with leading space suppression
;	exx;								// restore HL and BC
;	pop de;								// unstack DE
;	ret;								// end of subroutine

;;
; table search
;;
;s1_po_search:
;	ex de, hl;							// base address to HL
;	push af;							// stack entry number
;	inc a;								// increase range

;s1_po_step:
;	bit 7, (hl);						// last character?
;	inc hl;								// next character
;	jr z, s1_po_step;						// jump if not
;	dec a;								// reduce count
;	jr nz, s1_po_step;						// loop until entry found 
;	ex de, hl;							// DE points to initial character
;	pop af;								// unstack entry number
;	cp 31;								// one of the first 31 entries?
;	ret c;								// return with carry set if so
;	ld a, (de);							// get initial character
;	sub 'A';							// test against letter, leading space if so
;	ret;								// end of subroutine

;;
; test for scroll
;;
s1_po_scr:
	ld de, s1_cl_set;					// put sysvar
	push de;							// on the stack
	ld a, b;							// line number to B
	bit 0, (iy + _vdu_flag);			// INPUT or AT?
	jp nz, s1_po_scr_4;					// jump if so
	cp (iy + _df_sz);					// line number less than sysvar?
;	jr c, s1_report_oo_scr;				// jump if so
	jp c, report_oo_scr;				// error if not
	ret nz;								// return using s1_cl_set if greater
	bit 4, (iy + _vdu_flag);			// automatic listing?
	jr z, s1_po_scr_2;					// jump if not
	ld e, (iy + _breg);					// get line counter
	dec e;								// reduce it
	jr z, s1_po_scr_3;					// jump if listing scroll required
	xor a;								// LD A, 0; channel K
	call chan_open;						// select channel
	ld sp, (list_sp);					// restore stack pointer
	res 4, (iy + _vdu_flag);			// flag automatic listing finished
	ret;								// return using s1_cl_set

;s1_report_oo_scr:
;	rst error;							// throw
;	defb out_of_screen;					// error

s1_po_scr_2:
	dec (iy + _scr_ct);					// reduce scroll count
	jr nz, s1_po_scr_3;					// jump unless zero
	ld a, 24;							// reset
	sub b;								// counter
	ld (scr_ct), a;						// store scroll count
	ld a, 253;							// channel K
	call chan_open;						// select channel
	ld de, scrl_mssg;					// message address
;	call s1_po_asciiz_0;				// print it
	call po_asciiz_0;					// print it

s1_wait_msg_loop:
	ld hl, vdu_flag;					// address sysvar
	set 5, (hl);						// lower screen requires clearing
	res 3, (hl);						// no echo
	exx;								// alternate register set
	call input_ad;						// get a single key code
	exx;								// main resgister set
	jr nc, s1_wait_msg_loop				// loop, if no key has been pressed
	cp ' ';								// space?
;	jr z, s1_report_break;				// treat as BREAK and jump if so
	jp z, report_break;					// treat as BREAK and jump if so
	call chan_open_fe;					// open channel S

s1_po_scr_3:
	call s1_cl_sc_all;					// scroll whole display
	ld b, (iy + _df_sz);				// get line number
	inc b;								// for start of line
	ld c, 41;							// first column
	ret;								// end of subroutine

;s1_report_break:
;	jp report_break;					// FIXME

s1_po_scr_4:
	cp 2;								// lower part fits?
;	jr c, s1_report_oo_scr;				// error if not
	jp c, report_oo_scr;				// error if not
	add a, (iy + _df_sz);				// number of scrolls to A
	sub 25;								// scroll required?
	ret nc;								// return if not
	neg;								// make number positive
	push bc;							// stack line and column numbers

s1_po_scr_4a:
	push af;							// stack number
	ld hl, df_sz;						// address of sysvar
	ld a, (hl);							// df_sz to a
	ld b, a;							// df_sz to b
	inc a;								// increment df_sz
	ld (hl), a;							// store it
	ld l, lo(s_posn_h);					// address sysvar
	cp (hl);							// lower scrolling only required?
	jr c, s1_po_scr_4b;					// jump if so
	inc (hl);							// increment s-posn-h
	ld b, 23;							// scroll whole display

s1_po_scr_4b:
	call s1_cl_scroll;					// scroll number of lines in B
	pop af;								// unstack scroll number
	dec a;								// reduce it
	jr nz, s1_po_scr_4a;				// loop until done
	ld bc, (s_posn);					// get sysvar
	res 0, (iy + _vdu_flag);			// in case changed
	call s1_cl_set;						// give matching value to df_cc
	set 0, (iy + _vdu_flag);			// set lower screen in use
	pop bc;								// unstack line and column numbers
	ret;								// end of subroutine

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

s1_init:
	ld a, %00001111;					// light gray foreground, dark blue background
	ld (bordcr), a;						// set border color
	ld (attr_p), a;						// set permanent attribute

	ld c, $3b;							// palette port
	ld de, $ffbf;						// d = data, e = register

	ld a, 6;							// register to read
	call get_reg;						// get it
	ld l, 22;							// register to write
	call set_reg;						// set it

	ld a, 9;							// register to read
	call get_reg;						// get it
	ld l, 25;							// register to write
	call set_reg;						// set it

	ld a, 14;							// register to read
	call get_reg;						// get it
	ld l, 30;							// register to write
	call set_reg;						// set it

	set 1, (iy + _flags2);				// signal screen 1 (40 columns)
	ld a, %00000010;					// lo-res mode
	out (scld), a;						// set it and continue into CLS

; <code>CLS</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#CLS" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
s1_cls:
	set 0, (iy + _flags);				// suppress leading space
	call s1_cl_all;						// clear whole display

s1_cls_lower:
	ld hl, vdu_flag;					// address sysvar
	ld b, (iy + _df_sz);				// get address
;	set 0, (hl);						// signal lower part
	res 5, (hl);						// signal no lower screen clear after key
	call s1_cl_line;					// clear lower part of screen
	dec b;								// reduce counter
	ld (iy + _df_sz), 1;				// two lines

s1_cl_chan:
	ld a, 253;							// channel K
	call chan_open;						// select channel
	ld hl, (curchl);					// current channel address
	ld de, s1_print_out;				// output address
	and a;								// clear carry flag

s1_cl_chan_a:
	ld (hl), e;							// set
	inc hl;								// address
	ld (hl), d;							// and advance
	inc hl;								// pointer
	ld de, key_input;					// input address
	ccf;								// complement carry flag
	jr c, s1_cl_chan_a;					// loop until both addresses set
	ld bc, $1829;						// row 24, column 41
	jr s1_cl_set;						// immediate jump

;;
; clear whole display area
;;
s1_cl_all:
	res 0, (iy + _flags2);				// signal screen is clear
	call s1_cl_chan;					// house keeping tasks
	call chan_open_fe;					// open channel S
	ld b, 24;							// 24 lines
	call s1_cl_line;					// clear them
	ld hl, (curchl);					// current channel
	ld de, s1_print_out;				// output address
	ld (hl), e;							// set
	inc hl;								// output
	ld (hl), d;							// address

s1_cl_home:
	ld (iy + _scr_ct), 1;				// reset scroll count
	ld bc, $1829;						// row 24, column 41

;;
; clear set
;;
s1_cl_set:
	ld a, b;							// row to A
	bit 0, (iy + _vdu_flag);			// main display?
	jr z, s1_cl_set_1;					// jump if so
	add a, (iy + _df_sz);				// top row of lower display
	sub 24;								// convert to real line

s1_cl_set_1:
	push bc;							// stack row and column
	ld b, a;							// row to B
;	call s1_cl_addr;					// address for start of row to HL
	call cl_addr;						// address for start of row to HL (screen 0 code)
	pop bc;								// unstack row and column
;	jp s1_po_store;						// immediate jump
	jp po_store;						// immediate jump (screen 0 code)

;;
; scrolling
;;
s1_cl_sc_all:
	ld b, 23;							// entry point after scroll message

s1_cl_scroll:
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
;	call s1_cl_addr;					// get start address of row
	call cl_addr;						// get start address of row (screen 0 code)
	ld c, 8;							// eight pixels per row

s1_cl_scr_1:
	push bc;							// stack both
	push hl;							// counters
	ld a, b;							// B to A
	and %00000111;						// dealing with third of display?
	ld a, b;							// restore A
	jr nz, s1_cl_scr_3;					// jump if not

s1_cl_scr_2:
	ex de, hl;							// swap pointers
	ld hl, $f8e0;						// set DE to
	add hl, de;							// destination
	ex de, hl;							// swap pointers
	ld bc, 32;							// 32 bytes per half row
	dec a;								// reduce count
;	call s1_ldir2;						// clear half row
	call ldir2;							// clear half row (screen 0 code)

s1_cl_scr_3:
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
;	call s1_ldir2;						// scroll pixel line
	call ldir2;							// scroll pixel line (screen 0 code)
	ld b, 7;							// prepare to cross screen third boundary
	add hl, bc;							// increase HL by 1792
	and %11111000;						// more thirds to consider?
	jr nz, s1_cl_scr_2;					// jump if so
	pop hl;								// unstack original address
	inc h;								// address next pixel row
	pop bc;								// unstack counters
	dec c;								// reduce pixel row counter
	jr nz, s1_cl_scr_1;					// loop until done
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
s1_cl_line:
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
	ld de, 40;							// 40 characters per line

s1_total_chars:
	add hl, de;							// add 40 to count per line
	djnz s1_total_chars;				// loop until done

	dec hl;								// reduce count by one
	ld c, l;							// HL
	ld b, h;							// to BC

	ld hl, $df7f;						// end of character map
	ld de, $df7e;						// destination
	ld (hl), 0;							// clear last character
	lddr;								// clear lines from end

	pop bc;								// restore count

;	call s1_cl_addr;					// start address for row to HL
	call cl_addr;						// start address for row to HL (screen 0 code)
	ld c, 8;							// eight pixel rows

s1_cl_line_1:
	push bc;							// stack line row and pixel row counter
	push hl;							// stack address
	ld a, b;							// row number to A


s1_cl_line_2:
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
	set 5, h;							// alter address for attribute area
	call s1_cls_attr;					// clear attribute area
	call s1_set_border;					// set border
	pop bc;								// unstack address
	pop hl;								// unstack line row and pixel row
	call s1_cls_2nd;					// clear bitmap area
	ld de, $0701;						// increment HL by 1793 bytes
	add hl, de;							// for each screen third
	dec a;								// reduce row number
	and %11111000;						// discard extra rows
	ld b, a;							// screen third count to B
	jr nz, s1_cl_line_2;				// loop until done
	pop hl;								// unstack address for pixel row
	inc h;								// and increase pixel row
	pop bc;								// unstack counters
	dec c;								// decrease pixel row count
	jr nz, s1_cl_line_1;				// loop until done
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

;s1_ldir2:
;	push hl;							// stack source
;	push de;							// stack destination
;	push bc;							// stack byte count
;	set 5, h;							// add 8192 byte offset to source
;	set 5, d;							// add 8192 byte offset to destination
;	ldir;								// clear odd columns
;	pop bc;								// unstack original source
;	pop de;								// unstack original destination
;	pop hl;								// unstack original byte count
;	ldir;								// clear even columns
;	ret;								// end of subroutine

s1_set_border;
	ex af, af';							// use alternate register set
	ld a, (bordcr);						// get border color
	ld b, 192;							// total lines to set
	ld hl, $e000;						// start of attibutes
	ld de, 31;							// jump to next attribute

s1_border_loop:
	ld (hl), a;							// cell 0
	add hl, de;;						// increment 31 cells
	ld (hl), a;							// cell 31
	inc hl;								// next row
	djnz, s1_border_loop;				// loop until done

	and %00111000;						// discard unwanted bits
	rrca;								// rotate
	rrca;								// into
	rrca;								// place
	out (ula), a;						// set border

	ex af, af';							// restore register set
	ret;								// end of subroutine

s1_cls_attr:
	ex af, af';							// use alternate register set
	ld a, (attr_p);						// get permanent attribute
	jr s1_cls_all;						// clear screen

s1_cls_2nd:
	ex af, af';							// use alternate register set
	xor a ;								// LD A, 0

s1_cls_all:
	ld d, h;							// copy HL
	ld e, l;							// to DE
	ld (hl), a;							// zero byte addressed by HL
	inc de;								// DE points to next byte
	ldir;								// wipe bytes
	ex af, af';							// restore original register set
	ret;								// end of subroutine

;;
; clear address
;;
;s1_cl_addr:
;	ld a, 24;							// reverse line
;	sub b;								// number
;	ld d, a;							// result to D
;	rrca;								// A
;	rrca;								// mod
;	rrca;								// 8
;	and %11100000;						// first line
;	ld l, a;							// least significant byte to L
;	ld a, d;							// get real line number
;	and %00011000;						// 64 + 8 * INT (A / 8)
;	or $c0;								// top 16K of RAM
;	ld h, a;							// most significant byte to H
;	call cl_addr;						// call screen 0 code
;	inc hl;								// (not needed in 80 column mode) skip first 16 pixels
;	ret;								// end of subroutine
;	jp cl_addr;

;	// entered with PEN and PAPER on calculator stack
;;
; <code>COLOR</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#COLOR" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
s1_color:
	rst get_char;						// get character
	cp ',';								// comma?
	jr z, s1_cr_3_prms;					// includes border value
	call check_end;						// check end of statement
	jr s1_set_attrs;					// set attributes

s1_cr_3_prms:
	rst next_char;						// get next character
	call expt_1num;						// expect one number
	call check_end;						// check end of statement
	call find_int1;						// get number
	cp 16;								// higher than 15?
	jp nc, report_bad_fn_call;			// error if out of range
	and %00000111;						// take value mod 8 (0 to 7)
	ld b, a;							// store value in B
	rlca;								// move value 
	rlca;								// into 
	rlca;								// paper attribute
	add a, b;							// set pen attribute to match
	ld (bordcr), a;						// set border color system variable
	ld bc, paging;						// page in VRAM
	ld a, %00011111;					// ROM 1, VRAM 1, HOME 7
	di;									// interrupts off
	out (c), a;							// do paging

	ld a, (bordcr)						// restore border color
	ld b, 192;							// total lines to set
	ld hl, $e000;						// start of attibutes
	ld de, 31;							// jump to next attribute

s1_cr_3_prms_loop:
	ld (hl), a;							// cell 0
	add hl, de;;						// increment 31 cells
	ld (hl), a;							// cell 31
	inc hl;								// next row
	djnz, s1_cr_3_prms_loop;			// loop until done

	and %00111000;						// discard unwanted bits
	rrca;								// rotate
	rrca;								// into
	rrca;								// place
	out (ula), a;						// set border

	ld bc, paging;						// page in VRAM
	ld a, %00011000;					// ROM 1, VRAM 1, HOME 0
	out (c), a;							// do paging
	ei;									// enable interrupts

s1_set_attrs:
	call fp_to_a;						// background color to A
	cp 16;								// higher than 15?
	jr nc, s1_color_err;				// jump if out of range
	push af;							// stack background
	call fp_to_a;						// foreground color to A
	pop bc;								// unstack background
	cp 16;								// higher than 15?

s1_color_err:
	jp nc, report_bad_fn_call;			// jump if out of range
	rlca;								// move low
	rlca;								// nibble
	rlca;								// to high
	rlca;								// nibble
	add a, b;							// background to low nibble
	ld e, a;							// offset
	ld d, 0; 							// to DE
	ld hl, attributes;					// base address
	add hl, de;							// index to attribute
	ld a, (hl);							// get value
	ld (attr_p), a;						// store it
	ret;								// end of subroutine

s1_get_cols:
	ld b, 40;							// 40 columns
	ret;								// end of subroutine

s1_input_1:
	ld c, 41;							// leftmost position
	ret;								// end of subroutine

s1_locate:
	cp 41;								// in range?
	jr nc, s1_loc_err;					// error if not
	ld a, b;							// get row
	or a;								// test for zero
	jr z, s1_loc_err;					// jump if so
	cp 24;								// upper screen?
	jr nc, s1_loc_err;					// jump if not
	ld a, 42;							// leftmost
	sub c;								// calculate column
	jr c, s1_loc_err;					// jump if error
	ld c, a;							// else store it
	ld a, 25;							// bottom row
	sub b;								// calculate row
	jr c, s1_loc_err;					// jump if error
	ld b, a;							// else store it
	push bc;							// save values
	ld c, 41;							// leftmost position
	call cl_set;						// store it
	pop bc;								// restore value of C
	ld a, 41;							// column 0
	sub c;								// get number to advance
	and a;								// test for zero
	ret z;								// return if so
	ld d, a;							// set counter
	ld hl, p_flag;						// point to sysvar
	ld e, (hl);							// sysvar to D
	ld (hl), 1;							// set printing to OVER
;	call s1_po_space;					// print a space with alt regs
	call po_space;						// print a space with alt regs (screen 0 code)
	ld (hl), e;							// restore sysvar
	ret;								// end of subroutine

stk_pos_to_bc:
	call stk_to_bc;						// contents of stack to BC
	ld a, e;							// get sign
	or d;								// or with other sign
	inc a;								// increment A
	ret nz;								// return if both positive 

s1_loc_err:
	rst error;							// throw
	defb out_of_screen;					// error

;;
; <code>PLOT</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#PLOT" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
s1_plot:
	call stk_pos_to_bc;					// reject negative co-ords, else stack to BC

plot_sub:
	ld (coords), bc;					// set system variable
	call pixel_add;						// pixel address to HL
	inc a;								// increase A
	ld e, %00011111;					// ROM 1, VID 1, RAM 7
	ld bc, $7ffd;						// 128 paging
	di;									// interrupts off
	out (c), e;							// set page
	ld b, a;							// set loop count
	ld a, %11111110;					// place zero

plot_loop:
	rrca;								// shift right
	djnz plot_loop;						// loop until done
	ld b, a;							// result to B
	ld a, (hl);							// pixel byte to A
	ld c, (iy + _p_flag);				// p_flag to C
	bit 0, c;							// OVER 1?
	jr nz, pl_tst_in;					// jump if so
	and b;								// zero pixel

pl_tst_in:
	bit 2, c;							// INVERSE 1?
	jr nz, plot_end;					// jump if so
	xor b;								// else
	cpl;								// INVERSE 0

plot_end:
	ld (hl), a;							// write pixel byte
	set 5, h;							// HL now points to attributes
	ld a, (attr_p);						// get current attribute
	ld (hl), a;							// write it
	ld bc, $7ffd;						// 128 paging
	ld a, %00011000;					// ROM 1, VID 1, RAM 0
	out (c), a;							// set page
	ei;									// interrupts on
	ret;								// end of subroutine


;	// pixel address subroutine
pixel_add:
	ld a, 239;							// x co-ordinate
	sub c;								// in range?
	jp c, loc_err;						// error if not
	ld a, 191;							// y co-ordinate
	sub b;								// in range?
	jp c, loc_err;						// error if not
	ld b, a;							// 191 - y
	rra;								// shift right and clear bit 7
	scf;								// set carry flag
	rra;								// shift right and set bit 7
	scf;								// set carry flag
	rra;								// shift right and clear bit 7
	xor b;								// xor 191 - y
	and %11111000;						// preserve high five bits
	xor b;								// xor 191 - y
	ld h, a;							// high byte of pixel address to H
	ld a, c;							// x to A
	rlca;								// shift
	rlca;								// left
	rlca;								// three times
	xor b;								// xor 191 - y
	and %11000111;						// discard bits 3 to 5
	xor b;								// xor 191 - y
	rlca;								// shift left
	rlca;								// twice
	ld l, a;							// low byte of pixel address to L
	ld a, c;							// x to A
	and %00000111;						// x mod 8
	inc l;								// offset by one byte to skip first column
	ret;								// end of subroutine

;;
; <code>CIRCLE</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#CIRCLE" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
s1_circle:
	fwait;								// enter calculator
	fabs;								// x, y, z
	frstk;								// z to full floating point for
	fce;								// exit calculator
	ld a, (hl);							// get exponent
	cp 129;								// radius less than one
	jr nc, c_r_gre_1;					// jump if not
	fwait;								// enter calculator
	fdel;								// remove last item
	fce;								// exit calculator
	jp s1_plot;							// immediate jump

c_r_gre_1:
	call stk_to_a;						// get y from calculator stack
	push af;							// stack it
	call stk_to_bc;						// get x from calcualtor stack
	pop af;								// restore y

circle_int:
	ld l, 0;							// A to
	ld h, a;							// HL
	rra;								// shift A right with carry

circle_l3:
	ld de, $00fc;						// 252d

circle_l1:
	push af;							// stack AF

circle_l2:
	push hl;							// stack HL
	push bc;							// stack BC
	ld a, b;							// B to A
	add h;								// A = A + H
	ld b, a;							// A to B
	ld a, c;							// C to A
	add l;								// A = A + L
	ld c, a;							// A to C
	push de;							// stack DE
	call plot_sub;						// plot a pixel
	pop de;								// unstack DE
	pop bc;								// unstack BC
	pop hl;								// unstack HL
	ld a, $fb;							// 251d
	cp e;								// is E 251?
	ld a, l;							// L to A
	jr z, circle_m;						// jump if so
	neg;								// negate

circle_m:
	ld l, h;							// H to L
	ld h, a;							// A to H
	inc e;								// increment E
	jr nz, circle_l2;					// jump if not zero
	dec d;								// D = D - 1
	jr nz, circle_n;					// jump if not zero
	neg;								// negate
	ld h, a;							// A to H

circle_n:
	pop af;								// unstack AF
	inc l;								// increment L
	sub a, l;							// A = A - L
	jr nc, circle_nc;					// jump if no carry
	add a, h;							// else A = A + H
	dec h;								// H = H - 1

circle_nc:
	ld e, a;							// A to E
	ld a, l;							// L to A
	cp h;								// compare with H
	ld a, e;							// E to A
	jr z, circle_l3;					// jump if so
	ld de, $01f8;						// 510d
	jr c, circle_l1;					// jump with carry
	ret;								// else done

;;
; <code>DRAW</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#DRAW" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
s1_draw:
	call stk_to_bc;						// B: abs y, C: abs x, D: sgn y, E: sgn x
	ld a, c;							// abs x
	cp b;								// >= abs y?
	jr nc, dl_x_ge_y;					// jump if so
	ld l, c;							// vertical step (±1)
	push de;							// abs x to L
	xor a;								// stack diagonal step (±1, ±1)
	ld e, a;							// vertical step to DE
	jr dl_larger;						// immediate jump

dl_x_ge_y:
	or c;								// abs x and abs y both zero?
	ret z;								// return if so
	ld l, b;							// abs y to L
	ld b, c;							// abs x to B
	push de;							// stack diagonal step (±1, ±1)
	ld d, 0;							// horizontal step to DE (±1)

dl_larger:
	ld h, b;							// larger of abs x or abs y to H
	ld a, b;							// and to A
	rra;								// int (h/2)

d_l_loop:
	add a, l;							// diagonal step?
	jr c, d_l_diag;						// jump if so
	cp h;								// horizontal or vertical step?
	jr c, d_l_hr_vt;					// jump if so

d_l_diag:
	sub h;								// reduce A by H
	ld c, a;							// store result in C
	exx;								// alternate register set
	pop bc;								// diagonal step to BC'
	push bc;							// put it back on the stack
	jr d_l_step;						// immediate jump

d_l_hr_vt:
	ld c, a;							// store A in C
	push de;							// stack step
	exx;								// alternate register set
	pop bc;								// horizontal or vertical step to BC'

d_l_step:
	ld hl, (coords);					// coords to HL'
	ld a, b;							// y step from B' to A
	add a, h;							// add H'
	ld b, a;							// result to B'
	ld a, c;							// x step from C' to A
	inc a;								// in
	add a, l;							// range?
	jr c, d_l_range;					// jump if so
	jr z, d_error;						// else error

d_l_plot:
	dec a;								// restore correct value
	ld c, a;							// copy A to C'
	call plot_sub;						// plot step
	exx;								// main register set
	ld a, c;							// copy C to A
	djnz d_l_loop;						// loop eight times
	pop de;								// clear stack
	ret;								// end of subroutine

d_l_range:
	jr z, d_l_plot;						// jump if x position in range

d_error:
	rst error;							// throw
	defb out_of_screen;					// error

s1_arc:
	jp no_draw;							// FIX ME
