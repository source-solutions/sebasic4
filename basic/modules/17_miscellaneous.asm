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

;	// --- MISCELLANEOUS ROUTINES ----------------------------------------------

;;
; <code>CALL</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#CODE" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_call:
	call syntax_z;						// checking syntax?
	jr nz, call_1;						// jump if not
	rst get_char;						// get character
	cp ',';								// test for comma
	ret nz;								// return if not

call_param:
	rst next_char;						// next character
	call scanning;						// next expression
	cp ',';								// comma?
	jr z, call_param;					// loop until all passed
	call check_end;						// return if checking syntax (always true)

call_1:
	call find_int2;						// get address
	ld l, c;							// address to
	ld h, b;							// HL
	call call_jump;						// call address
	exx;								// alternate register set
	ld hl, $2758;						// restore value of HL'
	exx;								// main register set
	ret;								// return to BASIC

;	// entered with PEN and PAPER on calculator stack
;;
; <code>COLOR</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#COLOR" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_color:
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

; 	// FIXME - delete should accept:    [X]       [X]x      [X]x,y    [X],y     [ ]x,   

;;
; <code>DELETE</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#DELETE" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_delete:
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
	jp reclaim_1;	

;  	rst get_char;						// get character
;  	cp ':';								// colon?
;  	jr z, delete_all;					// jump if so
;  	cp ctrl_cr;							// carraige return?
;  	jr z, delete_all;					// jump if so
;  	cp ',';								// comma?
;  	jr z, delete_zero;					// jump if so
;  	call expt_1num;						// get number
;  	jr delete_two_param;				// immediate jump

; delete_zero:
;  	call use_zero;						// default start at zero
;  	rst get_char;						// get character

; delete_two_param:
;  	cp ',';								// comma?
;  	jr nz, delete_one_param;			// jump if not
;  	rst next_char;						// next character
;  	call fetch_num;						// get number
;  	call check_end;						// check end of statement
;  	call find_line;						// also performs LD A, B
;  	or c;								// both zero?
;  	jr nz, delete_lines;				// jump if not
;  	ld hl, 16384;						// else HL = 16384

; delete_lines:
; 	call line_addr;						// get line address
; 	call next_one;						// find address
; 	push de;							// stack it
; 	call get_line;						// get next line number
; 	pop de;								// unstack address
; 	and a;								// clear carry flag
; 	sbc hl, de;							// check line range
; 	jp nc, report_bad_fn_call;			// error if not valid
; 	add hl, de;							// restore line number
; 	ex de, hl;							// swap pointers
; 	jp reclaim_1;						// delete lines

; delete_all:
;  	call check_end;						// check end of statement
; 	ld hl, (vars);						// end of BASIC to HL
; 	ld de, (prog);						// start of program to DE
; 	jp reclaim_1;						// reclaim BASIC program

; delete_one_param:
; 	call check_end;						// check end of statement
; 	call find_line;						// get value from calculator stack
; 	push hl;							// stack it
; 	call stack_bc;						// put it back on the calculator stack
; 	pop hl;								// restore it
; 	jr delete_lines;					// delete one line

get_line:
 	call find_line;						// get valid line
 	call line_addr;						// get line address
	ret;								// return

;;
; <code>EDIT</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#EDIT" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_edit:
	ld hl, (prog);						// prog contains pointer to program
	ld a, (hl);							// get value at address in HL
	cp $80;								// no program?
	ret z;								// return if so

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
	call chan_open;						// select channel
	pop hl;								// address of line
	dec hl;								// suppress cursor
	dec (iy + _e_ppc);					// FIXME - remove after autolist removed
	call out_line;						// print the line
	inc (iy + _e_ppc);					// FIXME - remove after autolist removed
	ld hl, (e_line);					// start of line to HL
	ld (k_cur), hl;						// set cursor position
	pop hl;								// unstack former channel address
	call chan_flag;						// restore flags
	ld sp, (err_sp);					// move stack
	pop af;								// drop address
	jp main_2;							// immediate jump

;;
; <code>ERROR</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#ERROR" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_error:
	call find_int1;						// get 8-bit integer
	ld l, a;							// error to A
	jp error_3;							// generate error message

;	// LOCATE command <row>,<column> (counts from 1)
;;
; <code>LOCATE</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#LOCATE" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_locate:
	fwait;								// enter calculator
	fxch;								// swap values
	fce;								// exit calculator

	ld a, 2;							// channel S (upper screen)
	call chan_open;						// select channel

	call stk_to_bc;						// column to C, row to B

	bit 1, (iy + _flags2);				// test for 40 column mode
	jr z, loc_80;						// jump if not

	ld a, c;							// get column
	or a;								// test for zero
	jr z, loc_err						// jump if so
	cp 41;								// in range?
	jr nc, loc_err;						// error if not
	ld a, b;							// get row
	or a;								// test for zero
	jr z, loc_err;						// jump if so
	cp 24;								// upper screen?
	jr nc, loc_err;						// jump if not
	ld a, 42;							// left most
	jr loc_40;							// immedaite jump

loc_80:
	ld a, c;							// get column
	or a;								// test for zero
	jr z, loc_err;						// jump if so
	cp 81;								// in range?
	jr nc, loc_err;						// error if not
	ld a, b;							// get row
	or a;								// test for zero
	jr z, loc_err;						// jump if so
	cp 24;								// upper screen?
	jr nc, loc_err;						// jump if not

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
	rst error;							// throw
	defb out_of_screen;					// error

;;
; <code>PALETTE</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#PALETTE" target="_blank" rel="noopener noreferrer">Language reference</a>
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

	jp set_color;						// set hi-res colors

set_pal:
	ld bc, $bf3b;						// address I/O register
	out (c), a;							// set it
	ld b, $ff;							// address I/O data
	out (c), e;							// write it
	ret;								// end of routine

;	// trace
;;
; <code>TRACE</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#TRACE" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_trace:
	rst get_char;						// get first character
	cp tk_on;							// ON token?
	jr z, trace_on;						// jump if so
	cp tk_off;							// OFF token?
	jr z, trace_off;					// jump if so
	rst error;							// else error
	defb syntax_error;					// FIXME: add ON n handler

trace_on:
	rst next_char;						// next character
	call check_end;						// expect end of line
	set 7, (iy + _flags2);				// switch trace on
	ret;								// end of routine

trace_off:
	rst next_char;						// next character
	call check_end;						// expect end of line
	res 7, (iy + _flags2);				// switch trace off
	ret;								// end of routine

;;
; <code>ON</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#ON" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_on:
	rst get_char;						// get first character
	cp tk_error;						// ERROR token?
	jr z, on_error;						// jump if so
	call expt_1num;						// get expression
	call syntax_z;						// checking syntax?
	call nz, find_int1;					// get number if not
	ld (membot), a;						// store entry in membot
	rst get_char;						// next character
	ld bc, $0100;						// set count to zero, flag to one
	cp tk_gosub;						// GOSUB token?
	jr z, on_number;					// jump if so
	inc b;								// GOSUB =1, GOTO =2
	cp tk_goto;							// GOTO token?
	jr z, on_number;					// jump if so
	rst error;							// else
	defb syntax_error;					// error

on_number:
	rst next_char;						// next character
	push bc;							// stack BC
	call expt_1num;						// get expression
	pop bc;								// unstack BC
	inc c;								// increment count
	ld a, (membot);						// get entry
	cp c;								// match?
	jr z, on_match;						// jump if so
	rst get_char;						// next character
	cp ',';								// comma
	jr z, on_number;					// check for another number if so
	call check_end;						// expect end of line
	ret;								// done

on_match:
	call unstack_z;						// exit if validating line
	dec b;								// GOSUB or GOTO?
	jp nz, c_goto;						// jump with GOTO
	jp c_gosub;							// jump with GOSUB

on_error:
	rst next_char;						// next character
	cp tk_goto;							// GOTO token?
	jr z, onerr_goto;					// jump if so
	cp tk_cont;							// CONTINUE token?
	jr z, onerr_cont;					// jump if so
	cp tk_stop;							// STOP token?
	jr z, onerr_stop;					// jump if so
	rst error;							// else
	defb syntax_error;					// error

onerr_goto:
	rst next_char;						// next character
	call expt_1num;						// expect number
	call check_end;						// expect end of line
	call find_line;						// get line number
	ld (onerr), bc;						// set on error address
	ret;								// end of routine

onerr_cont:
	rst next_char;						// next character
	call check_end;						// expect end of line
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

;;
; <code>SCREEN</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#SCREEN" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_screen:
	call test_0_or_1;					// get variable
	and a;								// test for zero
;	jr nz, screen_1;					// jump for 40 column

screen_0:
	res 1, (iy + _flags2);				// signal 80 columns
	ld a, %00110110;					// yellow on blue (with no ULAplus), hi-res mode
	out (scld), a;						// set it
	jp c_cls;							// exit via CLS 80

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

;;
; <code>WHILE</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#WHILE" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_while:
	fwait;								// enter calculator
	fdel;								// remove last item
	fce;								// exit calculator
	ex de, hl;							// swap pointers
	call test_zero;						// zero?
	jr c, skip_while;					// jump if so
	pop de;								// fetch return address
	ld h, (iy + _subppc);				// statement number
	ex (sp), hl;						// put on the stack, HL = error handler
	inc sp;								// but only 1 byte
	ld bc, (ppc);						// line number
	push bc;							// put on the stack
	push hl;							// stack error handler
	ld (err_sp), sp;					// update ERR_SP
	push de;							// stack return address
	jp test_20_bytes;					// continue like GO SUB

skip_while:
	ld bc, 0;							// nesting depth
	rst get_char;						// get character
	cp ':';								// colon?
	jr z, skip_while_1;					// jump if so

skip_while_0:
	inc hl;								// 
	ld a, (hl);							// 
	cp $40;								// WEND found?
	jr nc, report_missing_wend;			// jump if not
	ld d, a;							// 
	inc hl;								// 
	ld e, (hl);							// DE = line number
	ld (ppc), de;						// store line number
	ld (iy + _subppc), 0;				// store zero in subppc
	inc hl;								// 
	ld e, (hl);							// 
	inc hl;								// 
	ld d, (hl);							// DE = line length
	ex de, hl;							// HL = line length
	add hl, de;							// 
	inc hl;								// HL = next line pointer
	ld (nxtlin), hl;					// set next line
	ex hl, de;							// HL = pointer before the first character in the line
	ld (ch_add), hl;					// set character address

skip_while_1:
	inc (iy + _subppc);					// increase statement counter
	rst next_char;						// next character
	cp tk_while;						// WHILE token?
	jr nz, skip_while_2;				// jump if not
	inc bc;								// increase nesting depth

skip_while_2:
	cp tk_wend;							// WEND token?
	jr nz, skip_while_3;				// jump if not
	ld a, c;							// test for
	or b;								// zero
	jr nz, skip_wend;					// jump if not
	rst next_char;						// skip WEND token
	ret;								// continue with execution

skip_wend:
	dec bc;								// decrease nesting depth

skip_while_3:
	inc hl;								// 
	ld a, (hl);							// 
	call number;						// skip floating point representation
	cp ':';								// colon?
	jr z, skip_while_4;					// jump if so
	cp ctrl_cr;							// carraige return?
	jr z, skip_while_0;					// jump if so
	cp tk_then;							// THEN token?
	jr nz, skip_while_3;				// jump if not

skip_while_4:
	ld (ch_add), hl;					// set character address
	jr skip_while_1;					// immediate jump

report_missing_wend:
	rst error;							// throw
	defb while_without_wend;			// error

;;
; <code>WEND</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#WEND" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_wend:
	pop bc;								// stmt-ret address to BC
	pop hl;								// error address to HL
	pop de;								// last entry on gosub stack to DE
	ld a, d;							// D to A
	cp $3e;								// test for gosub end marker
	jp nz, c_return_wend;				// jump if not
	push de;							// stack end marker
	push hl;							// stack error address
	rst error;							// throw
	defb wend_without_while;			// error
