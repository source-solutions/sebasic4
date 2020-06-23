;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2020 Source Solutions, Inc.

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

;	// --- MISCELLANEOUS ROUTINES ----------------------------------------------

;	// PC must not hit $04c6 (load trap) or $0562 (save trap)

;	org $04c6;
;load_trap:
;	ret;								// must never call this address

;	org $0562;
;save_trap:
;	ret;								// must never call this address

;	// VECTOR table of addresses
	org $04c4;

;	// UnoDOS 3 entry points (these addresses should never change)
;	// FIXME: as these are fixed addresses they can be replaced later on
;	// but provide a useful check that these points have not moved
	jp print_a_2;						// RST $10 - print character in A ($04c6 must never be called)
	jp jp_get_char;						// RST $18 - get character 
	jp $0020;							// RST $20 - next character
	jp reentry;							// IF1 reentry point
	jp cls_lower;						// clear lower screen
	jp add_char;						// add character
	jp remove_fp;						// remove floating point from line
	jp chan_open;						// open a channel
	jp set_min;							// set up workspace
	jp set_work;						// clear workspace
	jp line_addr;						// get line address
	jp each_stmt;						// find each statement
	jp e_line_no;						// get edit line
	jp expt_exp;						// expect string expression
	jp pr_st_end;						// test for carriage return or colon
	jp syntax_z;						// checking syntax test 
	jp stk_fetch;						// stack fetch

	jp $ffff;							//
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							//
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							//
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							//
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $c900;							// ($0562 must never be called)

;	// permits extension of vector table if required
;	org $0590

;;	// CALL command
c_call:
	call find_int2;						// get address
	ld l, c;							// address
	ld h, b;							// to HL
	call call_jump;						// call address
	exx;								// alternate register set
	ld hl, $2758;						// restore value of HL'
	exx;								// main register set
	ret;								// return to BASIC

;	// COLOR command
;	// entered with PEN and PAPER on calculator stack
color:
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
	ld a, 25;							// background (blue if no ULAplus)
	ld bc, $bf3b;						// register select
	out (c),a;							// set it
	ld a, (attr_p);						// get attributes
	and %00001111;						// background only
	call col_lookup;					// get background
	ld a, 22;							// bright ink 6 (Uno implementation)
	ld bc, $bf3b;						// register select
	out (c),a;							// set it
	ld a, (attr_p);						// get attributes
	and %11110000;						// foreground only
	rrca;								// move high
	rrca;								// nibble
	rrca;								// to low
	rrca;								// nibble
	call col_lookup;					// get background

	ld bc, $ff3b;						// data select
	in a, (c);							// get foreground color
	ex af, af';							// store it
	ld b, $bf;							// register select
	ld a, 30;							// foreground (yellow if no ULAplus)
	out (c), a;							// set it
	ld b, $ff;							// data select
	ex af, af';							// restore palette value
	out (c), a;							// set foreground color for Uno
	ret;								// end of subroutine

col_lookup:
	ld h, $df;							// start of CLUT3 (all 15 colors in order)
	add a, $e0;							// add offset (0-15)
	ld l, a;							// $dfe0 + offset
	ld bc, paging;						// get ready to page
	ld a, %0011111;						// ROM1, VRAM1, HOME7
	di;									// interrupts off while stack unavaiable
	out (c), a;							// set paging
	ld bc, $ff3b;						// data select
	ld a, (hl);							// get GRB color value (0-15)
	out (c), a;							// set color
	ld bc, paging;						// get ready to page
	ld a, %0011000;						// ROM1, VRAM1, HOME0
	out (c), a;							// set paging
	ei;									// interrupts back on
	ret;								// end of subroutine

; 	// FIXME - delete should accept:    x   x,y   ,y   x,   

;	// DELETE command
delete:
	call get_line;						// get a valid line number
	call next_one;						// find address
	push de;							// stack it
	call get_line;						// get next line number
	pop de;								// unstack address
	and a;								// clear carry flag
	sbc hl, de;							// check line range
	jp nc, report_bad_fn_call;			// error if not valid
	add hl, de;							// restore line number
	ex de, hl;							// swap pointers
	jp reclaim_1;						// delete lines

get_line:
	call find_line;						// get valid line
	call line_addr;						// get line address
	ret;								// end of subroutine

;	// EDIT command FIXME: ED. should do nothing if there is no program
edit:
	call get_line;						// get a valid line number
	ld a, c;							// test
	or b;								// for zero
	jr z, edit_1;						// use current line if so
	ld (e_ppc), bc;						// else make it the current line

edit_1:
	res	5, (iy + _flagx);				// signal line editing mode
	ld hl, (e_ppc);						// line number to HL
	call line_addr;						// get line address
	call line_no;						// get line number
	push hl;							// stack address of line
	inc hl;								// address line length
	ld c, (hl);							// transfer
	inc hl;								// to to
	ld b, (hl);							// BC
	ld hl, 10;							// add ten
	add hl, bc;							// to it
	ld c, l;							// transfer
	ld b, h;							// to BC
	call test_room;						// check for space
	call clear_sp;						// clear editing area
	ld hl, (curchl);					// get current channel
	ex (sp), hl;						// swap with address of line
	push hl;							// stack it
	ld a, $ff;							// channel W
	call chan_open;						// open it
	pop hl;								// address of line
	dec hl;								// suppress cursor
	dec (iy + _e_ppc);					// FIXME - remove after autolist removed
	call out_line;						// print the line
	inc (iy + _e_ppc);					// FIXME - remove after autolist removed
	ld hl, (e_line);					// start of line to HL
	ld (k_cur), hl;						// store it in k_kur
	pop hl;								// unstack former channel address
	call chan_flag;						// set flags
	ld sp, (err_sp);					// move stack
	pop af;								// drop address
	jp main_2;							// immediate jump

;	// ERROR command
c_error:
	call find_int1;						// get 8-bit integer
	ld l, a;							// error to A
	jp error_3;							// generate error message

;	// LOCATE command <row>,<column> (counts from 1)
locate:
	fwait;								// enter calculator
	fxch;								// swap values
	fce;								// exit calculator

	ld a, 2;							// select upper screen
	call chan_open;						// open channel

	call stk_to_bc;						// column to C, row to B

	bit 1, (iy + _flags2);				// test for 40 column mode
	jr z, loc_80;						// jump if not

	ld a, c;							// get column
	cp 41;								// in range?
	jr z, loc_err;						// error if not
	ld a, b;							// get row
	cp 23;								// upper screen?
	jr z, loc_err;						// jump if not
	ld a, 42;							// left most
	jr loc_40;							// immedaite jump

loc_80:
	ld a, c;							// get column
	cp 81;								// in range?
	jr z, loc_err;						// error if not
	ld a, b;							// get row
	cp 23;								// upper screen?
	jr z, loc_err;						// jump if not

	ld a, 82;							// left most

loc_40:
	sub c;								// calculate column
	jr c, loc_err;						// jump if error
	ld c, a;							// else store it

	ld a, 25;							// bottom row
	sub b;								// calculate row
	jr c, loc_err;						// jump if error
	ld b, a;							// else store it
	jp cl_set;							// exit via cl_set

loc_err:
	rst error;
	defb out_of_screen;

; 	// PALETTE command
palette:
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

	jp set_color;						// set hi-res colors

set_pal:
	ld bc, $bf3b;						// address I/O register
	out (c), a;							// set it
	ld b, $ff;							// address I/O data
	out (c), e;							// write it
	ret;								//

;	// TRON command (trace on)
tron:
	set 7, (iy + _flags2);				// switch trace on
	ret;								// end of routine

;	// TROFF command (trace off)
troff:
	res 7, (iy + _flags2);				// switch trace off
	ret;								// end of routine

;	// ON command
c_on:
	rst get_char;						// first character
	cp tk_error;						// ERROR token?
	jr z, on_error;						// jump if so
	rst error;							// else error
	defb syntax_error;					// FIXME: add ON n handler

on_error:
	rst next_char;						// first character
	cp tk_goto;							// GOTO?
	jr z, onerr_goto;					// jump if so
	cp tk_cont;							// CONTINUE?
	jr z, onerr_cont;					// jump if so
	cp tk_stop;							// STOP?
	jr z, onerr_stop;					// jump if so
	rst error;							// else
	defb syntax_error;					// error

onerr_goto:
	rst next_char;						// next character
	call expt_1num;						// expect number
	call check_end;						// expect end of line
	call find_line;						// get line number
	call unstack_z;						// return if checking syntax
	ld (onerr), bc;						// set on error address
	ret;								// done

onerr_cont:
	rst next_char;						// next character
	call check_end;						// expect end of line
	call unstack_z;						// return if checking syntax
	ld a, $fe;							// signal on err continue

onerr_exit:
	ld (onerr_h), a;					// set on err flag
	ret;								// end of subroutine

onerr_stop:
	call onerr_cont;					// expect end of line
	ret z;								// return if checking syntax
	inc a;								// signal on err stop
	jr onerr_exit;						// immediate jump

;	// ON ERROR handler
onerr_test:
	cp ok;								// no error?
	ret z;								// return if so
	cp msg_break;						// BREAK?
	ret z;								// return if so
	ld hl, (onerr);						// get flag or line number
	ld a, h;							// flag to H
	cp $ff;								// on error stop?
	ret	z;								// return if so
	cp $fe;								// on error continue?
	jr z, onerr_test_1;					// jump if so
	ld (newppc), hl;					// store line to jump to in newppc
	ld (iy + _nsppc), 0;				// clear statement number

onerr_test_1:
	ld (iy + _err_nr), ok;				// signal no error
	pop	hl;								// discard return address
	ld hl, main_4;						// make main-4
	push hl;							// new return address
	jp stmt_r_1;						// immediate jump

;	// SCREEN command
screen:
	call test_0_or_1;					// get variable
	and a;								// test for zero
;	jr nz, screen_1;					// jump for 40 column

screen_0:
	res 1, (iy + _flags2);				// signal 80 columns
	ld a, %00110110;					// yellow on blue (with no ULAplus), hi-res mode
	out (scld), a;						// set it
	jp cls;								// exit via CLS 80

screen_1:
	set 1, (iy + _flags2);				// signal 40 columns
;	ld a, %00000010;					// lo-res mode
;	out (scld), a;						// set it
;	jp s40_cls;							// exit via CLS 40

; 	// TEST 0 OR 1 subroutine
test_0_or_1:
	call find_int1;						// get variable
	cp 2;								// 0 or 1?
	ret c;								// return if so
	pop af;								// else drop return address
	rst error;							// and call
	defb illegal_function_call;			// error handler

;	// pause after printing a message (prevents messages being cleared after NEW or BREAK)
msg_pause:
	ld bc, 0;							// set delaty to 65536 

msg_loop:
	dec bc;								// reduce count
	ld a, c;							// test against zero
	or b;								// prevents keypress immediately erasing BREAK message
	ret z;								// return when done
	jr msg_loop;						// loop until done

;	// AUTO command
auto:
	ret

;	// WHILE command
c_while:
	ret

;	// WEND command
c_wend:
	ret
