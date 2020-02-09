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

	org $1ae0

line_scan:
	res 7, (iy + _flags);				// signal checking syntax
	call e_line_no;						// point to first code after a line number
	xor a;								// LD A, 0
	ld (subppc), a;						// zero subppc
	dec a;								// LD A, 0xFF
	ld (err_nr), a;						// set err_nr to OK
	jr stmt_l_1;						// immediate jump

stmt_loop:
	rst next_char;						// get next character

stmt_l_1:
	call set_work;						// handle trace and clear workspace
	inc (iy + _subppc);					// increase subppc each time around
	jp m, report_syntax_err;			// error if more than 127 statements
	rst get_char;						// get current character
	ld b, 0;							// clear B
	cp ctrl_enter;						// carriage return?
	jp z, line_end;						// jump if so
	cp ':';								// colon?
	jr z, stmt_loop;					// loop if so
	ld hl, stmt_ret;					// stack new
	push hl;							// return address
	ld c, a;							// store command in C
	rst next_char;						// advance character address
	ld a, c;							// restore command to A
	sub tk_def_fn;						// reduce range
	jr nc, stmt_l_2;					// jump with valid commands
	ld hl, (ch_add);					// get character address
	dec hl;								// previous character
	ld (ch_add), hl;					// set it
	ld a, (hl);							// get first character again
	cp "'";								// is it a single quote?
	ld a, tk_rem - tk_def_fn;			// make the token REM
	jr z, stmt_l_2;						// and jump if so
	ld a, tk_let - tk_def_fn;			// else make the token LET

stmt_l_2:
	rlca;								// double the command
	ld l, a;							// store in L
	ld bc, offst_tbl;					// start of table
	ld h, 0;							// ready to index
	add hl, bc;							// hl points to table entry
	ld c, (hl);							// low byte to C
	inc hl;								// next byte
	ld h, (hl);							// high byte to H;
	ld l, c;							// low byte to L
	jr get_param;						// immediate jump

scan_loop:
	ld hl, (t_addr);					// temporary pointer to parameter table

get_param:
	ld a, (hl);							// get each entry
	inc hl;								// increase pointer
	ld (t_addr), hl;					// store it in sysvar
	ld hl, scan_loop;					// stack new
	push hl;							// return address
	ld c, a;							// entry to C
	cp ' ';								// separator?
	jr nc, separator;					// jump if so
	ld hl, class_tbl;					// address table
	ld b, 0;							// clear B
	add hl, bc;							// index into table
	ld c, (hl);							// offset to C
	add hl, bc;							// base address to HL
	push hl;							// use as new return address
	rst get_char;						// get current character
	dec b;								// LD B, 255
	ret;								// indirect jump

separator:
	rst get_char;						// get current character
	cp c;								// compare with entry
	jp nz, report_syntax_err;			// error if no match
	rst next_char;						// get next character
	ret;								// end of subroutine

stmt_ret:
	call break_key;						// break?
	jr c, stmt_r_1;						// jump if not
	rst error;							// else
	defb break;							// error

stmt_r_1:
	bit 7, (iy + _nsppc);				// statement jump required?
	jr nz, stmt_next;					// jump if not
	ld hl, (newppc);					// get new line number
	bit 7, h;							// statement in editing area?
	jr z, line_new;						// jump if not

line_run:
	ld hl, -2;							// line in editing area
	ld (ppc), hl;						// store in sysvar
	ld hl, (worksp);					// sysvar to HL
	dec hl;								// HL points to end of editing area
	ld de, (e_line);					// sysvar to DE
	dec de;								// DE points to location before editing area
	ld a, (nsppc);						// number of next statement to A
	jr next_line;						// immediate jump

line_new:
	call line_addr;						// get starting address
	ld a, (nsppc);						// statement number to A
	jr z, line_use;						// jump if line found
	and a;								// valid statement number?
	jr nz, report_stmt_msng;			// error if not
	ld a, (hl);							// is first line after
	and %11000000;						// end of program?
	jr z, line_use;						// jump if not

c_end:
	ld bc, -2;							// line zero
	ld (ppc), bc;						// set line number
	ld l, ok;							// error to A
	jp error_3;							// generate error message

rem:
	pop af;								// discard statement return address

line_end:
	call unstack_z;						// return if checking syntax
	ld hl, (nxtlin);					// get address
	ld a, 192;							// address after
	and (hl);							// end of program?
	ret nz;								// return if so
	xor a;								// signal statement zero

line_use:
	cp 1;								// signal
	adc a, 0;							// statement one
	ld d, (hl);							// line
	inc hl;								// number
	ld e, (hl);							// to DE
	inc hl;								// point to length
	ld (ppc), de;						// store line number
	ld e, (hl);							// length
	inc hl;								// to
	ld d, (hl);							// DE
	ex de, hl;							// location before next line's
	add hl, de;							// first character to DE
	inc hl;								// start of line after to HL

next_line:
	ld (nxtlin), hl;					// set next line
	ex de, hl;							// swap pointers
	ld (ch_add), hl;					// sysvar to location before first character
	ld e, 0;							// clear in case of each_stmt
	ld d, a;							// statement number to D
	ld (iy + _nsppc), 255;				// signal no jump
	dec d;								// reduce statement number
	ld (iy + _subppc), d;				// store in subppc
	jp z, stmt_loop;					// consider first statement
	inc d;								// increment D
	call each_stmt;						// find start address
	jr z, stmt_next;					// jump if statement exists

report_stmt_msng:
	rst error;							// else
	defb statement_missing;				// error

check_end:
	call syntax_z;						// checking syntax?
	ret nz;								// return if not
	pop bc;								// discard scan_loop and
	pop bc;								// stmt_ret return addresses

stmt_next:
	rst get_char;						// get current character
	cp ctrl_enter;						// carriage return
	jr z, line_end;						// jump if so
	cp ':';								// colon?
	jp z, stmt_loop;					// jump if so
	rst error;							// else
	defb syntax_error;					// error

class_tbl:
	defb class_00 - $;					// no operands
	defb class_01 - $;					// a variable must follow
	defb class_02 - $;					// LET
	defb class_03 - $;					// a number may follow
	defb class_04 - $;					// FOR or NEXT
	defb class_05 - $;					// a set of items may follow
	defb class_06 - $;					// a number must follow
	defb class_07 - $;					// class_06 with no furhter operands
	defb class_08 - $;					// two comma-separated numbers must follow
	defb class_09 - $;					// class_08 with no furhter operands
	defb class_0a - $;					// an expression must follow
	defb class_0b - $;					// class_0a with no furhter operands

class_07:
	call class_06;						// a number must follow
	jr class_00;						// no futher operands

class_09:
	call class_08;						// two comma-separated numbers must follow
	jr class_00;						// no futher operands

class_0b:
	call class_0a;						// an expression must follow
	jr class_00;						// no futher operands

class_03:
	call fetch_num;						// get number, default to zero

class_00:
	cp a;								// set zero flag

class_05:
	pop bc;								// discard scan-loop return address
	call z, check_end;					// next statement if checking syntax
	ex de, hl;							// swap pointers
	ld hl, (t_addr);					// pointer to parameter table entry
	ld c, (hl);							// get
	inc hl;								// entry
	ld b, (hl);							// in BC
	ex de, hl;							// swap pointers
	push bc;							// stack entry
	ret;								// end of subroutine

class_01:
	call look_vars;						// variable exists?

var_a_1:
	ld (iy + _flagx), 0;				// clear flagx
	jr nc, var_a_2;						// jump if variable exists
	set 1, (iy + _flagx);				// signal new variable
	jr nz, var_a_3;						// jump unless undimensioned array

report_undef_var:
	rst error;							// else
	defb undefined_variable;			// error

var_a_2:
	call z, stk_var;					// parameters and variables to calculator
	bit 6, (iy + _flags);				// numeric variable?
	jr nz, var_a_3;						// jump if so
	xor a;								// LD A, 0
	call syntax_z;						// checking syntax?
	call nz, stk_fetch;					// get paramaters of string if not
	ld hl, flagx;						// address system variable
	or (hl);							// set bit 0 for simple strings
	ld (hl), a;							// update flagx
	ex de, hl;							// HL points to string or element

var_a_3:
	ld (strlen), bc;					// HL points to string or element
	ld (dest), hl;						// and destination
	ret;								// end of subroutine

class_02:
	pop bc;								// discard scan_loop return address
	call val_fet_1;						// make assignment
	call check_end;						// next statement if checking syntax
	ret;								// indirect jump to stmt-ret in runtime

val_fet_1:
	ld a, (flags);						// address system variable

val_fet_2:
	push af;							// stack system variable
	call scanning;						// evaluate expression
	pop af;								// unstack system variable
	ld d, (iy + _flags);				// get new flags
	xor d;								// test for
	and %01000000;						// numeric or string
	jr nz, report_syntax_err;			// error if no match
	bit 7, d;							// checking syntax?
	jp nz, let;							// jump if not
	ret;								// else return

class_04:
	call look_vars;						// find variable
	push af;							// stack AF
	ld a, c;							// test
	or %10011111;						// discriminator byte
	inc a;								// for FOR-NEXT
	jr nz, report_syntax_err;			// error if not
	pop af;								// unstack AF
	jr var_a_1;							// immediate jump

next_2num:
	rst next_char;						// advance ch_add

class_08:
expt_2num:
	call expt_1num;						// get expression
	cp ',';								// comma?
	jr nz, report_syntax_err;			// error if not

expt_num:
	rst next_char;						// advance ch_add

class_06:
expt_1num:
	call scanning;						// evaluate expression
	bit 6, (iy + _flags);				// numeric result
	ret nz;								// return if so

report_syntax_err:
	rst error;							// ekse
	defb syntax_error;					// error

;	// UnoDOS 3 entry point
	org $1c8c
class_0a:
expt_exp:
	call scanning;						// evaluate expression
	bit 6, (iy + _flags);				// string result?
	ret z;								// return if so
	jr report_syntax_err;				// else error

fetch_num:
	cp ctrl_enter;						// carriage return?
	jr z, use_zero;						// jump if so
	cp ':';								// colon?
	jr nz, expt_1num;					// jump if not

use_zero:
	call unstack_z;						// return if checking syntax
	fwait();							// enter calculator
	fstk0();							// stack zero
	fce();								// exit calculator
	ret;								// end of subroutine

c_if:
	pop bc;								// discard stmt-ret return address
	call syntax_z;						// checking syntax
	jr z, if_1;							// jump if so
	fwait();							// enter calculator
	fdel() ;							// remove last item
	fce();								// exit calculator
	ex de, hl;							// swap pointers
	call test_zero;						// zero?
	jp c, line_end;						// jump if not

if_1:
	jp stmt_l_1;						// next statement

c_for:
	cp tk_step;							// step token?
	jr nz, f_use_1;						// jump if not
	rst next_char;						// advance ch_add
	call expt_1num;						// get step
	call check_end;						// next statement if checking syntax
	jr f_reorder;						// immediate jump

f_use_1:
	call check_end;						// next statement if checking syntax
	fwait();							// enter calculator
	fstk1();							// stack one
	fce();								// exit calculator

f_reorder:
	fwait();							// enter calculator
	fst(0);								// store step in mem-0
	fdel();								// remove last item
	fxch();								// l, v
	fgt(0);								// l, v, s
	fxch();								// l, s, v
	fce();								// exit calculator
	call let;							// find or create variable
	ld (mem), hl;						// contents of mem to HL
	dec hl;								// point to single character name
	ld a, (hl);							// store it in A
	set 7, (hl);						// set bit 7
	ld bc, 6;							// make six locations
	add hl, bc;							// point to following location
	rlca;								// for variable
	jr c, f_l_s;						// jump if so
	ld c, 13;							// else 13 more bytes required
	call make_room;						// make space
	inc hl;								// point to limit position

f_l_s:
	push hl;							// stack pointer
	fwait();							// l, x
	fdel();								// l
	fdel();								// empty calculator stack
	fce();								// exit calculator
	pop hl;								// unstack pointer
	ex de, hl;							// swap pointers
	ld c, 10;							// ten bytes of limit
	ldir;								// copy bytes
	ld hl, (ppc);						// current line number to HL
	ex de, hl;							// swap pointers
	ld (hl), e;							// line number
	inc hl;								// to for control
	ld (hl), d;							// variables
	ld d, (iy + _subppc);				// next statement to D
	inc hl;								// increase variable pointer
	inc d;								// increase statement
	ld (hl), d;							// store control variable
	call next_loop;						// pass possible?
	ret nc;								// return if so
	ld a, (subppc);						// statement to A
	neg;								// negate statement
	ld b, (iy + _strlen);				// character name to B
	ld hl, (ppc);						// current line number
	ld (newppc), hl;					// to newppc using HL
	ld hl, (ch_add);					// current value of sysvar
	ld e, tk_next;						// next token
	ld d, a;							// statement to D 

f_loop:
	push bc;							// stack variable name
	ld bc, (nxtlin);					// current value of nxtlin
	call look_prog;						// search program area
	ld (nxtlin), bc;					// store new value of nxtlin
	pop bc;								// unstack variable name
	jr c, report_for_wo_next;			// error with missing next
	rst next_char;						// skip next token
	or %00100000;						// ignore letter case
	cp b;								// variable found?
	jr z, f_found;						// jump if so
	rst next_char;						// advance ch_add
	jr f_loop;							// loop until done

f_found:
	rst next_char;						// advance ch_add
	ld a, 1;							// subtract statement
	sub d;								// counter from one
	ld (nsppc), a;						// store result
	ret;								// indirect jump to stmt_ret

report_for_wo_next:
	rst error;
	defb for_without_next;

look_prog:
	ld a, (hl);							// current character
	cp ':';								// colon?
	jr z, look_p_2;						// jump if so

look_p_1:
	inc hl;								// most significant byte of line number
	ld a, (hl);							// copy to A
	and %11000000;						// end of program?
	scf;								// set carry flag
	ret nz;								// return if no more lines
	ld b, (hl);							// line
	inc hl;								// number
	ld c, (hl);							// to BC
	ld (newppc), bc;					// store in newppc
	inc hl;								// get
	ld c, (hl);							// length
	inc hl;								// in
	ld b, (hl);							// BC
	push hl;							// stack pointer
	add hl, bc;							// calculate end of line address
	ld c, l;							// result
	ld b, h;							// to BC
	pop hl;								// unstack pointer
	ld d, 0;							// zero statement counter

look_p_2:
	push bc;							// stack end of line pointer
	call each_stmt;						// examine statements
	pop bc;								// unstack end of line pointer
	ret nc;								// return with occurence
	jr look_p_1;						// immediate jump

c_next:
	bit 1, (iy + _flagx);				// variable found
	jp nz, report_undef_var;			// jump if not
	ld hl, (dest);						// address to HL
	bit 7, (hl);						// valid name?
	jr z, report_next_wo_for;			// jump if not
	inc hl;								// skip name
	ld (mem), hl;						// variable address to temporary memory area
	fwait();							// enter calculator
	fgt(0);								// v
	fgt(2);								// v, s
	fadd();								// v + s
	fst(0);								// v + s to mem_0
	fdel();								// remove last item
	fce();								// exit calculator
	call next_loop;						// test value against limit
	ret c;								// return if for-next loop done
	ld hl, (mem);						// address least significant byte
	ld de, 15;							// of looping
	add hl, de;							// line number
	ld e, (hl);							// line
	inc hl;								// number
	ld d, (hl);							// to DE
	inc hl;								// statement
	ld h, (hl);							// number to H
	ex de, hl;							// swap pointers
	jp goto_2;							// immediate jump

report_next_wo_for:
	rst error;
	defb next_without_for;

next_loop:
	fwait();							// enter calculator
	fgt(1);								// l
	fgt(0);								// l, v
	fgt(2);								// l, v, s
	fcp(_lz);							// less than zero?
	fjpt(next_1);						// jump if so
	fxch();								// v, l

next_1:
	fsub();								// v - l or l - v
	fcp(_gz);							// greater than zero?
	fjpt(next_2);						// jump if so
	fce();								// exit calculator
	and a;								// clear carry flag
	ret;								// end of subroutine

next_2:
	fce();								// exit calculator
	scf;								// set carry flag
	ret;								// end of subroutine

read_3:
	rst next_char;						// next character

read:
	call class_01;						// get entry for existing variable
	call syntax_z;						// checking syntax?
	jr z, read_2;						// jump if so
	rst get_char;						// get current character
	ld (x_ptr), hl;						// ch_add to x_ptr
	ld hl, (datadd);					// data address pointer to HL
	ld a, (hl);							// first value to A
	cp ',';								// comma?
	jr z, read_1;						// jump if not
	ld e, tk_data;						// data token?
	call look_prog;						// search for token
	jr nc, read_1;						// jump if found
	rst error;							// else
	defb out_of_data;					// error

read_1:
	call temp_ptr1;						// advance DATA pointer and set ch_add
	call val_fet_1;						// get value and assign to variable
	rst get_char;						// get ch_add
	ld (datadd), hl;					// store it in sysvar
	ld hl, (x_ptr);						// pointer to read statement to HL
	ld (iy + _x_ptr_h), 0;				// clear x_ptr
	call temp_ptr2;						// point ch_add to read statement

read_2:
	rst get_char;						// get current character
	cp ',';								// comma?
	jr z, read_3;						// jump if so
	call check_end;						// ext statement if checking syntax
	ret;								// end of routine

data:
	call syntax_z;						// checking syntax?
	jr nz, data_2;						// jump if so

data_1:
	call scanning;						// next expression
	cp ',';								// comma?
	call nz, check_end;					// next statement if checking syntax
	rst next_char;						// advance ch_add
	jr data_1;							// loop until done

data_2:
	ld a, tk_data;						// data

pass_by:
	ld b, a;							// token to B
	cpdr;								// back to find token
	ld de, $0200;						// find following statement (D - 1)
	jp each_stmt;						// immediate jump

restore:
	call find_line;						// valid line number to HL and BC

rest_run:
	ld l, c;							// result
	ld h, b;							// to HL
	call line_addr;						// get address of line or next line
	dec hl;								// point to location before
	ld (datadd), hl;					// and store in dat_add
	ret;								// end of routine

randomize:
	call find_int2;						// get operand
	ld a, c;							// is it
	or b;								// zero?
	jr nz, rand_1;						// jump if not
	ld bc, (time_t);					// get low 16-bits of time_t

rand_1:
	ld (seed), bc;						// result to seed
	ret;								// end of routine

cont:
	ld hl, (oldppc);					// line number to HL
	ld d, (iy + _osppc);				// statement number to D
	jr goto_2;							// immediate jump

find_line:
	call find_int2;						// line number to BC
	ld l, c;							// resault
	ld h, b;							// to HL
	ld a, b;							// high byte to A
	cp $40;								// less than 16384?
	ret c;								// return if so	

report_undef_ln_no:
	rst error;							// else
	defb undefined_line_number;			// error

goto:
	call find_line;						// valid line number to HL and BC
	ld d, 0;							// zero statement

goto_2:
	ld (newppc), hl;					// store line number
	ld (iy + $0a), d;					// store statement number
	ret;								// end of routine

fn_out:
	call two_param;						// get operands
	out (c), a;							// perform out
	ret;								// end of routine

poke:
	call two_param;						// get operands
	ld (bc), a;							// store A in address BC
	ret;								// end of routine

two_param:
	call fp_to_a;						// first parameter
	jr c, report_overflow;				// error if out of range
	jr z, two_p_1;						// jump with positive number
	neg;								// else negate

two_p_1:
	push af;							// stack first parameter
	call find_int2;						// get second parameter in BC
	pop af;								// unstack first parameter
	ret;								// end of subroutine

find_int1:
	call fp_to_a;						// value on calculator stack to A
	jr find_i_1;						// immediate jump

find_int2:
	call fp_to_bc;						// value on calculator stack to BC

find_i_1:
	jr c, report_overflow;				// error if overflow
	ret z;								// return with positive numbers

report_overflow:
	rst error;							// else
	defb overflow;						// error

run:
	rst get_char;						// get character
	cp ctrl_enter;						// test for carriage return
	jr z, run_zero;						// jump if so
	cp ':';								// test for next statement
	jr z, run_zero;						// jump if so
	call scanning;						// evaluate expression
	bit 6, (iy + _flags);				// string or numeric?
	call nz, unstack_z;					// return now if checking syntax
	jp z, run_app;						// jump if string

c_run:
	call goto;							// set newppc
	ld bc, 0;							// restore value
	call rest_run;						// perform restore
	jr clear_run;						// immediate jump

run_zero:
	call check_end;						// return if checking syntax
	call use_zero;						// use line zero
	jr c_run;							// run

var_end_hl:
	ld hl, (e_line);					// variables end marker
	dec hl;								// to HL
	ret;								// end of subroutine

clear:
	call find_int2;						// get operand

clear_run:
	ld a, c;							// test
	or b;								// for zero
	jr nz, clear_1;						// jump if not
	ld bc, (ramtop);					// else use existing ramtop

clear_1:
	push bc;							// stack value
	ld de, (vars);						// start of variables to DE
	call var_end_hl;					// varaibles end marker location to HL
	call reclaim_1;						// reclaim all bytes of current variables area
	call rest_run;						// data restore
	call cls;							// clear display
	ld de, 50;							// add 
	ld hl, (stkend);					// fifty
	add hl, de;							// to stasck end
	pop de;								// unstack value in DE
	sbc hl, de;							// subtract it from ramptop
	jr nc, report_addr_oo_range;		// jump if ramtop too low
	and a;								// prepare for subtraction
	ld hl, (p_ramt);					// upper value to HL
	sbc hl, de;							// subtract from upper value
	jr nc, clear_2;						// jump if valid

report_addr_oo_range:
	rst error;							// else
	defb address_out_of_range;			// error

clear_2:
	ex de, hl;							// value to HL
	ld (ramtop), hl;					// store it
	pop de;								// stmt_ret address to DE
	pop bc;								// error address to BC
	ld (hl), $3e;						// gosub stack marker
	dec hl;								// skip one location
	ld sp, hl;							// SP to empty gosub stack
	push bc;							// stack error address
	ld (err_sp), sp;					// store in sysvar
	ex de, hl;							// stmt_ret address to HL
	jp (hl);							// immediate jump

gosub:
	pop de;								// stmt_ret address to DE
	ld h, (iy + _subppc);				// get statement number
	inc h;								// increment it
	ex (sp), hl;						// swap with error address
	inc sp;								// reclaim one location
	ld bc, (ppc);						// get current line number
	push bc;							// stack it
	push hl;							// stack error address
	ld (err_sp), sp;					// point sysvar to it
	push de;							// stack stmt_ret address
	call goto;							// set newppc and nsppc
	ld bc, 20;							// 20 bytes required

test_room:
	ld hl, (stkend);					// stack end to HL
	add hl, bc;							// add value in BC
	jr c, report_oo_mem;				// error if greater than 65535
	ex de, hl;							// swap pointers
	ld hl, 80;							// allow for additional 80 bytes
	add hl, de;							// try again
	jr c, report_oo_mem;				// jump with error 
	sbc hl, sp;							// subtract stack
	ret c;								// return if room

report_oo_mem:
	ld l, 3;							// else
	jp error_3;							// error

;free_mem:
;	ld bc, $0000;
;	call test_room;
;	ld c, l;
;	ld b, h;
;	ret;

return:
	pop bc;								// stmt-ret address to BC
	pop hl;								// error address to HL
	pop de;								// last entry on gosub stack to DE
	ld a, d;							// D to A
	cp $3e;								// test for gosub end marker
	jr z, report_ret_wo_gosub;			// error if so
	dec sp;								// three locations required
	ex (sp), hl;						// swap statement number and error address
	ex de, hl;							// statement number to DE
	ld (err_sp), sp;					// set error pointer
	push bc;							// stack stmt_ret address
	jp goto_2;							// immediate jump

report_ret_wo_gosub:
	push de;							// stack end marker
	push hl;							// stack error address
	rst error;							// then
	defb return_without_gosub;			// error

wait:
	call flush_kb;						// signal no key
	call find_int2;						// jump here from entry point to get operand

wait_1:
	halt;								// wait for maskable interrupt
	dec bc;								// reduce counter
	ld a, c;							// test
	or b;								// for zero
	jr z, wait_end;						// jump if so
	ld a, c;							// it is
	and b;								// was it
	inc a;								// originally zero?
	jr nz, wait_2;						// jump if not
	inc bc;								// LD BC, 0

wait_2:
	ld a, (k_head);						// pointer to head of buffer to A
	ld l, a;							// to L
	ld a, (k_tail);						// pointer to tail of buffer to A
	cp l;								// compare pointers
	jr z, wait_1;						// loop if no key

wait_end:
	call flush_kb;						// signal no key
	ret;								// end of routine

break_key:
	ld a, $7f;							// high byte of I/O address
	in a, (ula);						// read byte
	rra;								// set carry if space pressed
	ret c;								// return if not
	ld a, $fe;							// high byte of I/O address
	in a, (ula);						// read byte
	rra;								// set carry if shift pressed
	ret;								// end of subroutine

def_fn:
	call syntax_z;						// checking syntax?
	jr z, def_fn_1;						// jump if not
	ld a, tk_def_fn;					// DEF FN?
	jp pass_by;							// immediate jump

def_fn_1:
	set 6, (iy + _flags);				// signal numeric variable
	call alpha;							// letter?
	jr nc, def_fn_4;					// jump if not
	rst next_char;						// next character
	cp '$';								// string?
	jr nz, def_fn_2;					// jump if not
	res 6, (iy + _flags);				// signal string variable
	rst next_char;						// next character

def_fn_2:
	cp '(';								// opening parenthesis?
	jr nz, def_fn_7;					// jump if not
	rst next_char;						// next character
	cp ')';								// closing parenthesis?
	jr z, def_fn_6;						// jump if so

def_fn_3:
	call alpha;							// letter?

def_fn_4:
	jp nc, report_syntax_err;			// jump if not
	ex de, hl;							// swap pointers
	rst next_char;						// next character
	cp '$';								// string?
	jr nz, def_fn_5;					// jump if not
	ex de, hl;							// swap pointers
	rst next_char;						// next character

def_fn_5:
	ex de, hl;							// swap pointer
	ld bc, 6;							// six locations required
	call make_room;						// make space
	inc hl;								// point to first new location
	inc hl;								// new location
	ld (hl), ctrl_number;				// store number marker
	cp ',';								// comma in A?
	jr nz, def_fn_6;					// jump if so
	rst next_char;						// next character
	jr def_fn_3;						// immediate jump

def_fn_6:
	cp ')';								// closing parenthesis?
	jr nz, def_fn_7;					// jump if not
	rst next_char;						// next character
	cp '=';								// equals?
	jr nz, def_fn_7;					// jump if not
	rst next_char;						// next character
	ld a, (flags);						// variable type to A
	push af;							// stack it
	call scanning;						// evaluate expression
	pop af;								// unstack type
	xor (iy + _flags);					// matching
	and %01000000;						// type?

def_fn_7:
	jp nz, report_syntax_err;			// jump if not
	call check_end;						// next statement if checking syntax

unstack_z:
	call syntax_z;						// checking syntax
	pop hl;								// return address to HL
	ret z;								// return if not in runtime
	jp (hl);							// else immediate jump

print:
	ld a, 2;							// channel S

print_1:
	call syntax_z;						// checking syntax
	call nz, chan_open;					// open channel if not
	call print_2;						// print control
	call check_end;						// next statement if checking syntax
	ret;								// end of routine

print_2:
	rst get_char;						// get current character
	call pr_end_z;						// end of item list?
	jr z, print_4;						// jump if so

print_3:
	call pr_posn_1 ;					// position controls?
	jr z, print_3;						// loop if so
	call pr_item_1;						// single print item
	call pr_posn_1;						// more position controls?
	jr z, print_3;						// loop if so

print_4:
	cp ')';								// closing parenthesis?
	ret z;								// return if so

print_cr:
	call unstack_z;						// return if checking syntax
	ld a, ctrl_enter;					// carriage return
	rst print_a;						// print it
	ret;								// end of subroutine

pr_item_1:
	rst get_char;						// get current character
;	cp tk_using;
;	jr nz, pr_item_2;
;	call next_2num;
;	call unstack_z;
;	call stk_to_bc;
;	ld a, ctrl_at;
;	jr pr_at_tab;
;
;pr_item_2:
;	cp tk_tab;
;	jr nz, pr_item_3;
;	rst next_char;
;	call expt_1num;
;	call unstack_z;
;	call find_int2;
;	ld a, ctrl_tab;
;
;pr_at_tab:
;	rst print_a;
;	ld a, c;
;	rst print_a;
;	ld a, b;
;	rst print_a;
;	ret;

pr_item_3:
	call str_alter;						// stream change?
	ret nc;								// return if so
	call scanning;						// evaluate expression
	call unstack_z;						// return if checking syntax
	bit 6, (iy + _flags);				// test type
	call z, stk_fetch;					// call if string
	jp nz, print_fp;					// immediate jump if numeric

pr_string:
	ld a, c;							// no remaining
	or b;								// characters?
	dec bc;								// reduce count
	ret z;								// return if done
	ld a, (de);							// code to A
	inc de;								// increase pointer
	rst print_a;						// print it
	jr pr_string;						// loop until done

pr_end_z:
	cp ')';								// closing parenthesis
	ret z;								// return if so

;	// UnoDOS 3 entry point
	org $2048;
pr_st_end:
	cp ctrl_enter;						// carriage return?
	ret z;								// return if so
	cp ':';								// colon?
	ret;								// end of subroutine

pr_posn_1:
	rst get_char;						// get current character
	cp ';';								// semi-colon?
	jr z, pr_posn_3;					// jump if so
	cp ',';								// comma?
	jr nz, pr_posn_2;					// jump if not
	call syntax_z;						// checking syntax?
	jr z, pr_posn_3;					// jump if so
	ld a, ctrl_comma;					// comma control character
	rst print_a;						// print it
	jr pr_posn_3;						// immediate jump

pr_posn_2:
	cp "\\";							// backslash (\)
	ret nz;								// return if not
	call print_cr;						// print carriage return

pr_posn_3:
	rst next_char;						// next character
	call pr_end_z;						// end of print statement?
	jr nz, pr_posn_4;					// jump if not
	pop bc;								// unstack BC

pr_posn_4:
	cp a;								// clear zero flag
	ret;								// end of subroutine

str_alter:
	cp '#';								// number sign?
	scf;								// set carry flag
	ret nz;								// and return if not
	rst next_char;						// next character
	call expt_1num;						// get parameter
	and a;								// clear carry flag
	call unstack_z;						// return if checking syntax

str_alter_1:
	call find_int1;						// parameter to A
	cp 16;								// in range (0 to 15)?
	jp nc, report_undef_strm;			// error if not
	call chan_open;						// open channel
	and a;								// clear carry flag
	ret;								// end of subroutine

input:
	call syntax_z;						// checking syntax?
	jr z, input_1;						// jump if so
	ld a, 1;							// channel K
	call chan_open;						// open channel
	call cls_lower;						// clear lower display

input_1:
	ld (iy + _vdu_flag), $01;			// signal lower screen
	call in_item_1;						// deal with input items
	call check_end;						// next statement if checking syntax
	ld bc, (s_posn);					// print position to bc
	ld a, (df_sz);						// sysvar to A
	cp b;								// current position above lower screen?
	jr c, input_2;						// jump if so
	ld c, 81;							// leftmost position
	ld b, a;							// set print position to top of lower screen

input_2:
	ld (s_posn), bc;					// set print position
	ld a, 25;							// 24 rows
	sub b;								// subtract to get real count
	ld (scr_ct), a;						// set scroll count
	res 0, (iy + _vdu_flag);			// signal main screen
	call cl_set;						// set sysvars
	jp cls_lower;						// immediate jump

in_item_1:
	call pr_posn_1;						// position controls?
	jr z, in_item_1;					// jump if so
	cp '(';								// opening parenthesis?
	jr nz, in_item_2;					// jump if not
	rst next_char;						// next character
	call print_2;						// print items in parentheses
	rst get_char;						// get current character
	cp ')';								// closing parenthesis?
	jp nz, report_syntax_err;			// error if not
	rst next_char;						// next character
	jp in_next_2;						// immediate jump

in_item_2:
	cp tk_line;							// line token?
	jr nz, in_item_3;					// jump if not
	rst next_char;						// jump if not
	call class_01;						// get value
	set 7, (iy + _flagx);				// signal input line
	bit 6, (iy + _flags);				// string variable?
	jp nz, report_syntax_err;			// error if not
	jr in_prompt;						// immediate jump

in_item_3:
	call alpha;							// letter
	jp nc, in_next_1;					// jump if not
	call class_01;						// get variable address
	res 7, (iy + _flagx);				// signal not input line

in_prompt:
	call syntax_z;						// checking syntax?
	jp z, in_next_2;					// jump if so
	call set_work;						// clear workspace	
	ld hl, flagx;						// point to flagx
	res 6, (hl);						// signal string result
	set 5, (hl);						// signal input mode 
	ld bc, 1;							// one location for prompt
	bit 7, (hl);						// line?
	jr nz, in_pr_2;						// jump if so
	ld a, (flags);						// flags to A
	and %01000000;						// numeric?
	jr nz, in_pr_1;						// jump if so
	ld c, 3;							// three locations required

in_pr_1:
	or (hl);							// set bit 6 of
	ld (hl), a;							// flagx if numeric

in_pr_2:
	rst bc_spaces;						// make space
	ld (hl), ctrl_enter;				// set last location to carriage return
	ld a, c
	rrca
	rrca
	jr nc, in_pr_3;						// jump if so
	ld a, '"';";						// store double quote
	ld (de), a;							// in second location
	dec hl;								// next location
	ld (hl), a;							// store in first location

in_pr_3:
	ld (k_cur), hl;						// set cursor position
	bit 7, (iy + _flagx);				// input line?
	jr nz, in_var_3;					// jump if so
	ld hl, (ch_add);					// get sysvar
	push hl;							// stack it
	ld hl, (err_sp);					// get sysvar
	push hl;							// stack it

in_var_1:
	ld hl, in_var_1;					// stack
	push hl;							// return address
	bit 4, (iy + _flags2);				// channel K?
	jr z, in_var_2;						// jump if not
	ld (err_sp), sp;					// else update error stack pointer

in_var_2:
	ld hl, (worksp);					// HL to start of input line
	call remove_fp;						// deal with floating point forms
	ld (iy + _err_nr), 255;				// signal no error
	call editor;						// get the INPUT
	res 7, (iy + _flags);				// signal syntax checking
	call in_assign;						// validate input
	jr in_var_4;						// immediate jump

in_var_3:
	call editor;						// get line

in_var_4:
	ld (iy + _k_cur_h), 0;				// clear cursor address
	call in_chan_k;						// channel K?
	jr nz, in_var_5;					// jump if not
	call ed_copy;						// copy input to display
	ld bc, (echo_e);					// current position to BC
	call cl_set;						// make it current lower screen position

in_var_5:
	ld hl, flagx;						// address flagx
	res 5, (hl);						// signal edit mode
	bit 7, (hl);						// test for input line
	res 7, (hl);						// clear bit 7
	jr nz, in_var_6;					// jump with input line
	pop hl;								// discard in_var_1 address
	pop hl;								// unstack err_sp address
	ld (err_sp), hl;					// restore err_sp address
	pop hl;								// unstack original ch_add pointer
	ld (x_ptr), hl;						// store it in x_ptr
	set 7, (iy + _flags);				// signal runtime
	call in_assign;						// make assignment
	ld hl, (x_ptr);						// original ch_add to HL
	ld (iy + _x_ptr_h), 0;				// clear most significant byte of x_ptr
	ld (ch_add), hl;					// restore HL
	jr in_next_2;						// immediate jump

in_var_6:
	ld hl, (stkbot);					// end of line to HL
	ld de, (worksp);					// start of workspace to DE
	scf;								// prepare for subtraction
	sbc hl, de;							// length to HL
	ld c, l;							// HL
	ld b, h;							// to BC
	call stk_sto_str;					// stack parameters
	call let;							// make assignment
	jr in_next_2;						// immediate jump

in_next_1:
	call pr_item_1;						// print items

in_next_2:
	call pr_posn_1;						// position controls
	jp z, in_item_1;					// loop until done
	ret;								// end of subroutine

in_assign:
	ld hl, (worksp);					// first location of workspace
	ld (ch_add), hl;					// set ch_add to point to it
	rst get_char;						// get current character
	cp tk_stop;							// stop token?
	jr z, in_stop;						// jump if so
	ld a, (flagx);						// sysvar to A
	call val_fet_2;						// get value
	rst get_char;						// get current character
	cp ctrl_enter;						// carriage return?
	ret z;								// return if so
	rst error;							// else
	defb syntax_error;					// error

in_stop:
	call unstack_z;						// return if checking syntax

stop:
	rst error;							// then
	defb break;							// error

in_chan_k:
	ld hl, (curchl);					// base address of current channel
	inc hl;								// high byte of output routine
	inc hl;								// low byte of input routine
	inc hl;								// high byte of input routine
	inc hl;								// channel type
	ld a, (hl);							// get channel type
	cp 'K';								// K?
	ret;								// end of subroutine

stk_to_bc:
	call stk_to_a;						// first number to A
	ld b, a;							// store in B
	push bc;							// stack it
	call stk_to_a;						// second number to A
	ld e, c;							// sign to E
	pop bc;								// unstack first number
	ld d, c;							// sign to D
	ld c, a;							// second number to C
	ret;								// end of subroutine

stk_to_a:
	call fp_to_a;						// last value to A
	jp c, report_overflow;				// error if out of range
	ld c, 1;							// positive sign to C
	ret z;								// return if positive
	ld c, 255;							// negative sign to C
	ret;								// end of subroutine
