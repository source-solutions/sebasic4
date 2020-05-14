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

;	// FIXME - futher optimization is possible (see: indexer_0)
;	//         BIN$, OCT$ and HEX$ are not yet implemented

	org $24f0;
scanning:
	rst get_char;						// get current character
	ld b, 0;							// priority marker
	push bc;							// stack it

s_loop_1:
	ld hl, scan_func;					// index
	ld c, a;							// table code to C
	call indexer;						// find offset from table
	ld a, c;							// code to A
	jp nc, s_alphnum;					// jump if code not in table
	ld c, (hl);							// code
	ld b, 0;							// to BC
	add hl, bc;							// address to HL
	jp (hl);							// immediate jump

s_quote_s:
	call ch_add_plus_1;					// next character
	inc bc;								// increase count
	cp ctrl_enter;						// carriage return?
	jp z, report_syntax_err;			// error if so?
	cp '"';";							// quote?
	jr nz, s_quote_s;					// jump if not
	call ch_add_plus_1;					// next character
	cp '"';";							// quote?
	ret;								// set flag if so and return

s_2_coord:
	rst next_char;						// next character
	cp '(';								// opening parenthesis?
	jr nz, s_rport_c;					// error if not
	call next_2num;						// co-ords to calculator stack
	cp ')';								// closing parenthesis?

s_rport_c:
	jp nz, report_syntax_err;			// error if not

;	// UnoDOS 3 entry point
	org $2530;
syntax_z:
	bit 7, (iy + _flags);				// checking syntax?
	ret;								// end of subroutine

scan_func:
	defb '"', s_quote - 1 - $;";		// "
	defb '(', s_bracket - 1 - $;		// (
	defb '.', s_decimal - 1 - $;		// ,
	defb '+', s_u_plus - 1 - $;			// +
	defb tk_fn, s_fn - 1 - $;			// FN
	defb tk_rnd, s_rnd - 1 - $;			// RND
	defb tk_pi, s_pi - 1 - $;			// PI
	defb tk_inkey_str, s_inkey_str - 1 - $; // INKEY$
	defb op_bin, s_decimal - 1 - $;		// %
	defb op_oct, s_decimal - 1 - $;		// @
	defb op_hex, s_decimal - 1 - $;		// $
	defb tk_bin_str, s_bin_str - 1 - $; // BIN$
	defb tk_oct_str, s_oct_str - 1 - $;	// OCT$
	defb tk_hex_str, s_hex_str - 1 - $;	// HEX$
	defb 0;								// null terminator

s_u_plus:
	rst next_char;						// next character
	jp s_loop_1;						// jump back

s_quote:
	rst get_char;						// get current character
	inc hl;								// stat of string
	push hl;							// stack address
	ld bc, 0;							// length zero
	call s_quote_s;						// check for matching quotes
	jr nz, s_q_prms;					// jump if no more

s_q_again:
	call s_quote_s;						// check for
	jr z, s_q_again;					// additional quotes
	call syntax_z;						// checking syntax?
	jr z, s_q_prms;						// jump if so
	rst bc_spaces;						// make space
	pop hl;								// unstack pointer
	push de;							// stack start of string

s_q_copy:
	ld a, (hl);							// get character from string
	inc hl;								// next character
	ld (de), a;							// last character to workspace
	inc de;								// next space
	cp '"';";							// quote?
	jr nz, s_q_copy;					// jump if not
	ld a, (hl);							// skip
	inc hl;								// next one
	cp '"';";							// quote?
	jr z, s_q_copy;						// jump if so

s_q_prms:
	dec bc;								// real length
	pop de;								// unstack start of string

s_string:
	ld hl, flags;						// string is stacked
	res 6, (hl);						// reset bit 6
	bit 7, (hl);						// line execution?
	call nz, stk_sto_str;				// call if so
	jp s_cont_2;						// immediate jump

s_bracket:
	rst next_char;						// get character
	call scanning;						// scan it
	cp ')';								// closing parenthesis?
	jp nz, report_syntax_err;			// error if missing
	rst next_char;						// next character
	jp s_cont_2;						// immediate jump

s_fn:
	jp s_fn_sbrn;						// immediate jump

s_rnd:
	call syntax_z;						// checking syntax?
	jr z, s_rnd_end;					// jump if not
	ld bc, (seed);						// get current value of seed
	call stack_bc;						// stack it
	fwait();							// x
	fstk1();							// x, 1
	fadd();								// x + 1
	fstk();								// x + 1, 75
	defb $37;							// exponent
	defb $16;							// mantissa
	fmul();								// (x + 1) * 75
	fstk();								// (x + 1) * 75, 65537
	defb $80;							// exponent
	defb $41, $00, $00, $80;			// mantissa
	fmod();								// r, (x + 1) * 75/65537
	fdel();								// r
	fstk1();							// r, 1
	fsub();								// r - 1
	fmove();							// r - 1, r - 1
	fce();								// exit calculator
	call fp_to_bc;						// calculator stack to BC
	ld (seed), bc;						// store in seed
	ld a, (hl);							// get exponen
	and a;								// zero?
	jr z, s_rnd_end;					// jump if so
	sub 16;								// divide last value by 65536
	ld (hl), a;							// store value

s_rnd_end:
	jr s_pi_end;						// immediate jump

s_pi:
	call syntax_z;						// checking syntax?
	jr z, s_pi_end;						// jump if so
	fwait();							// enter calculator
	fstkhalfpi();						// pi / 2
	fce();								// exit calculator
	inc (hl);							// increment exponent

s_pi_end:
	rst next_char;						// next character
	jp s_numeric;						// immediate jump

s_inkey_str:
	ld bc, $105a;						// priority $10, code $5a (read_in)
	rst next_char;						// get next character
	cp '#';								// channel specified?
	jp z, s_push_po;					// jump if so
	ld hl, flags;						// address flags
	res 6, (hl);						// reset for string
	bit 7, (hl);						// checking syntax?
	jr z, s_ink_str_en;					// jump if so
	call key_scan;						// key value to DE
	ld c, 0;							// empty string
	jr nz, s_ik_str_stk;				// stack it if so
	call k_test;						// key value?
	jr nc, s_ik_str_stk;				// stack empty string if not valid
	dec d;								// LD D, $ff (lower case)
	call k_decode_1;					// decode key value
	call bc_1_space;					// make one space
	ld (de), a;							// store ASCII value

s_ik_str_stk:
	ld b, 0;							// LD BC, 1
	call stk_sto_str;					// stack string

s_ink_str_en:
	jp s_cont_2;						// immediate jump

s_bin_str:
s_oct_str:
s_hex_str:
	rst next_char;						// character after token
	jr s_decimal;						// placeholder for code

s_alphnum:
	call alphanum;						// alphanumeric character?
	jr nc, s_negate;					// jump if not
	cp 'A';								// letter?
	jr nc, s_letter;					// jump if so

s_decimal:
	call syntax_z;						// checking syntax?
	jr nz, s_stk_dec;					// jump if not
	call dec_to_fp;						// convert to floating point
	rst get_char;						// HL to last digit plus one
	ld bc, 6;							// six locations
	call make_room;						// make room
	inc hl;								// point to first free space
	ld (hl), ctrl_number;				// store hidden number marker
	inc hl;								// next location
	ex de, hl;							// pointer to DE
	ld hl, (stkend);					// get old stack end
	ld c, 5;							// five bytes to more
	and a;								// prepare for subtraction (clear carry)
	sbc hl, bc;							// new stkend is one less than old stkend
	ld (stkend), hl;					// fp number from stack to line
	ldir;								// copy it
	ex de, hl;							// pointer to HL
	dec hl;								// last byte added
	call temp_ptr1;						// set ch_add
	jr s_numeric;						// immediate jump

s_stk_dec:
	rst get_char;						// get current character

s_sd_skip:
	inc hl;								// next character
	ld a, (hl);							// get it
	cp ctrl_number;						// test for hidden number marker
	jr nz, s_sd_skip;					// loop until found
	inc hl;								// first byte of number
	call stack_num;						// move floating point number
	ld (ch_add), hl;					// set sysvar

s_numeric:
	set 6, (iy + _flags);				// set number marker flag
	jr s_cont_2;						// immediate jump

s_letter:
	call look_vars;						// check for matching entry
	jp c, report_undef_var;				// error if not
	call z, stk_var;					// stack parameters
	ld a, (flags);						// get flags
	cp %11000000;						// test bit 6 and 7
	jr c, s_cont_2;						// jump if either are reset
	inc hl;								// numeric to stack
	call stack_num;						// stack it
	jr s_cont_2;						// immediate jump

s_negate:
	ld bc, $09db;						// priority $09, op-code $d8
	cp '-';								// minus?
	jr z, s_push_po;					// jump if unary minus
	ld bc, $1018;						// priority $10, op-code $18
	cp tk_val_str;						// VAL$?
	jr z, s_push_po;					// jump if so
	sub tk_asc;							// ASC to NOT?
	jp c, report_syntax_err;			// error if not
	ld bc, $04f0;						// priority $04, op-code $f0
	cp 20;								// NOT?
	jr z, s_push_po;					// jump if so
	jp nc, report_syntax_err;			// error if out of range
	add a, 220;							// get op-code ($dc to $ef)
	ld c, a;							// op-code to C
	ld b, $10;							// priority $10
	cp 223;								// ASC, VAL, or LEN?
	jr nc, s_no_to_str;					// jump if so
	res 6, c;							// clear bit 6 of C

s_no_to_str:
	cp 238;								// STR$ or CHR$
	jr c, s_push_po;					// jump if so
	res 7, c;							// clear bit 7 of C

s_push_po:
	push bc;							// stack priority and op-code
	rst next_char;						// next character
	jp s_loop_1;						// immediate jump

s_cont_2:
	rst get_char;						// get current character

s_cont_3:
	cp '(';								// opening parenthesis?
	jr nz, s_opertr ;					// jump if not
	bit 6, (iy + _flags);				// test numeric
	jr nz, s_loop;						// jump if so
	call slicing;						// change parameters
	rst next_char;						// next character
	jr s_cont_3;						// immediate jump

s_opertr:
	ld hl, tbl_of_ops;					// table address
	ld c, a;							// code to
	ld b, 0;							// BC
	call indexer;						// index into table
	jr nc, s_loop;						// jump if no op found
	ld c, (hl);							// get code
	ld hl, tbl_priors - 195;			// table address
	add hl, bc;							// index into table
	ld b, (hl);							// get priority

s_loop:
	pop de;								// get last op-code and priority
	ld a, d;							// priority to A
	cp b;								// test last against present
	jr c, s_tighter;					// jump to get argument
	and a;								// both zero?
	jp z, jp_get_char;					// jump to get current character if so
	push bc;							// stack present values
	ld hl, flags;						// address sysvar
	ld a, e;							// last op-code to A
	cp 237;								// USR?
	jr nz, s_stk_lst;					// jump if not
	bit 6, (hl);						// USR number?
	jr nz, s_stk_lst;					// jump if so
	ld e, 153;							// modify last op-code

s_stk_lst:
	push de;							// stack last values
	call syntax_z;						// checking syntax?
	jr z, s_syntest;					// jump if so
	ld a, e;							// last op-code to A
	and %00111111;						// clear bits 6 and 7
	ld b, a;							// store in B
	fwait();							// perform
	fsgl();								// calculator
	fce();								// operation
	jr s_runtest;						// immediate jump

s_syntest:
	ld a, e;							// last op-code to A
	xor (iy + _flags);					// correct
	and %01000000;						// syntax?

s_rport_c2:
	jp nz, report_syntax_err;			// jump if not

s_runtest:
	pop de;								// unstack last op-code
	ld hl, flags;						// address flags
	set 6, (hl);						// assume numeric
	bit 7, e;							// is it?
	jr nz, s_loopend;					// jump if so
	res 6, (hl);						// make it string

s_loopend:
	pop bc;								// unstack present values
	jr s_loop;							// loop until done

s_tighter:
	push de;							// stack last values
	ld a, c;							// get present op-code
	bit 6, (iy + _flags);				// numeric?
	jr nz, s_next;						// jump if so
	and %00111111;						// clear bits 6 and 7
	add a, 8;							// increase code by eight
	ld c, a;							// code to C
	cp 16;								// AND?
	jr nz, s_not_and;					// jump if not
	set 6, c;							// assume numeric
	jr s_next;							// immediate jump

s_not_and:
	jr c, s_rport_c2;					// error if operation not plus
	cp 23;								// '+'?
	jr z, s_next;						// jump if so
	set 7, c;							// assume numeric

s_next:
	push bc;							// stack present values
	rst next_char;						// next character
	jp s_loop_1;						// loop until done

s_fn_sbrn:
	call syntax_z;						// checking syntax?
	jr nz, sf_run;						// jump if not
	rst next_char;						// first character of name
	call alpha;							// letter?
	jp nc, report_syntax_err;			// error if not
	rst next_char;						// next character
	cp '$';								// string?
	push af;							// stack zero flag
	jr nz, sf_brkt_1;					// jump if not
	rst next_char;						// next character

sf_brkt_1:
	cp '(';								// opening parenthesis?
	jr nz, sf_rprt_c;					// error if not
	rst next_char;						// next character
	cp ')';								// closing parenthesis?
	jr z, sf_flag_6;					// jump if no arguments

sf_argmts:
	call scanning;						// get arguments
	cp ',';								// comma?
	jr nz, sf_brkt_2;					// jump if not
	rst next_char;						// next character
	jr sf_argmts;						// loop until done

sf_brkt_2:
	cp ')';								// closing parenthesis?

sf_rprt_c:
	jp nz, report_syntax_err;			// error if not

sf_flag_6:
	rst next_char;						// next character in line
	ld hl, flags;						// address flags
	res 6, (hl);						// clear bit 6
	pop af;								// unstack zero flag
	jr z, sf_syn_en;					// jump with string
	set 6, (hl);						// set bit 6

sf_syn_en:
	jp s_cont_2;						// jump back to continue scanning

sf_run:
	rst next_char;						// first character of name
	and %11011111;						// make upper case
	ld b, a;							// copy to B
	rst next_char;						// next character
	sub '$';							// test for string fuction
	ld c, a;							// store result in C
	jr nz, sf_argmt1;					// jump if not
	rst next_char;						// get opening parenthesis

sf_argmt1:
	rst next_char;						// get first character of first argument
	push hl;							// stack pointer
	ld hl, (prog);						// point to program
	dec hl;								// step back

sf_fnd_df:
	ld de, $00ce;						// search for DEF FN
	push bc;							// stack name and string status
	call look_prog;						// search program
	pop bc;								// unstack name and status
	jr nc, sf_cp_def;					// jump if DEF FN found
	rst error;							// else
	defb undefined_user_function;		// error

sf_cp_def:
	push hl;							// stack pointer to DEF FN character
	call fn_skpovr;						// get function name
	and %11011111;						// make upper case
	cp b;								// matches FN name?
	jr nz, sf_not_fd;					// jump if not
	call fn_skpovr;						// get next character
	sub '$';							// string function?
	cp c;								// matches FN?
	jr z, sf_values;					// jump with match

sf_not_fd:
	pop hl;								// unstack pointer to DEF FN
	dec hl;								// step back
	ld de, $0200;						// count = 2, character = 0
	push bc;							// stack name and status
	call each_stmt;						// find end of statement
	pop bc;								// unstack name and status
	jr sf_fnd_df;						// loop

sf_values:
	and a;								// HL points to $?
	call z, fn_skpovr;					// jump if so
	pop de;								// discard pointer to DEF FN
	pop de;								// unstack pointer to first argument
	ld (ch_add), de;					// store it in sysvar
	call fn_skpovr;						// skip first parenthesis
	push hl;							// stack pointer
	cp ')';								// closing parenthesis?
	jr z, sf_r_br_2;					// jump if no arguments

sf_arg_lp:
	inc hl;								// point to next code
	ld a, (hl);							// put it in A
	cp ctrl_number;						// hidden number marker
	ld d, 64;							// set bit 6 of D
	jr z, sf_arg_vl;					// jump if numerical argument
	dec hl;								// point to string character
	call fn_skpovr;						// skip it
	ld d, 0;							// reset bit 6 of D
	inc hl;								// point to hidden number marker

sf_arg_vl:
	inc hl;								// point to first byte of DEF FN
	push hl;							// stack pointer
	push de;							// stack string status
	call scanning;						// evaluate argument
	pop af;								// unstack number / string flag
	xor (iy + _flags);					// test bit 6
	and %01000000;						// against result
	jr nz, report_type_mismatch;		// error if no match
	pop de;								// unstack pointer
	ld hl, (stkend);					// stack end to HL
	ld bc, 5;							// five bytes
	sbc hl, bc;							// decrease stack end by five
	ld (stkend), hl;					// store it effectively deleting last value
	ldir;								// copy five bytes
	ex de, hl;							// pointer to HL
	dec hl;								// skip to end of five bytes
	call fn_skpovr;						// next argument to HL
	cp ')';								// closing parenthesis?
	jr z, sf_r_br_2;					// jump if so
	push hl;							// stack pointer to comma
	rst get_char;						// get current character
	cp ',';								// comma?
	jr nz, report_type_mismatch;		// jump if not
	rst next_char;						// ch_add to next argument of FN
	pop hl;								// unstack comma pointer
	call fn_skpovr;						// next argument to HL
	jr sf_arg_lp;						// jump back

sf_r_br_2:
	push hl;							// stack pointer to closing parenthesis
	rst get_char;						// get character after last argument
	cp ')';								// closing parenthesis?
	jr z, sf_value;						// jump if so

report_type_mismatch:
	rst error;							// else
	defb type_mismatch;					// error

sf_value:
	pop de;								// unstack pointer to closing parenthesis
	ex de, hl;							// pointer to HL
	ld (ch_add), hl;					// store it in sysvar
	ld hl, (defadd);					// old value of defadd to HL
	ex (sp), hl;						// stack it and get start address of DEF FN
	ld (defadd), hl;					// store it in sysvar
	push de;							// stack address of closing parenthesis
	rst next_char;						// move past closing parenthesis
	rst next_char;						// and equals signS
	call scanning;						// evaluate function
	pop hl;								// unstack address of closing parenthesis
	ld (ch_add), hl;					// store it in sysvar
	pop hl;								// unstack original value of defadd
	ld (defadd), hl;					// store it
	rst next_char;						// next character
	jp s_cont_2;						// jump back

fn_skpovr:
	inc hl;								// next code

fn_skpovr_1:
	ld a, (hl);							// code to A
;	cp ' ' + 1;							// > space?
;	jr c, fn_skpovr;					// jump if so
	cp ' ';
	jr z, fn_skpovr;
	ret;								// end of subroutine

look_vars:
	set 6, (iy + _flags);				// assume numeric
	rst get_char;						// first character to A
	call alpha;							// letter?
	jp nc, report_syntax_err;			// error if not
	push hl;							// stack pointer to character
	and %00011111;						// preserve bits 0 to 4
	ld c, a;							// copy to C
	rst next_char;						// get second character in A
	push hl;							// stack pointer to second character
	cp '(';								// opening parenthesis?
	jr z, v_run_syn;					// jump if so
	set 6, c;							// set bit 6
	cp '$';								// string?
	jr z, v_str_var;					// jump if so
	set 5, c;							// set bit 5
	call alphanum;						// one letter?
	jr nc, v_test_fn;					// jump if so

v_char:
	call alphanum;						// letter?
	jr nc, v_run_syn;					// jump if name found
	res 6, c;							// clear bit 6
	rst next_char;						// next character
	jr v_char;							// loop until done

v_str_var:
	rst next_char;						// skip the string symbol
	res 6, (iy + _flags);				// clear bit 6 for a string

v_test_fn:
	ld a, (defadd_h);					// get the high byte
	and a;								// zero?
	jr z, v_run_syn;					// jump if so
	call syntax_z;						// checking syntax?
	jp nz, stk_f_arg;					// jump if not

v_run_syn:
	ld b, c;							// flags to B
	call syntax_z;						// checking syntax?
	jr nz, v_run;						// jump if not
	ld a, c;							// flags to A
	and %11100000;						// drop character code
	set 7, a;							// set bit 7
	ld c, a;							// flags to C
	jr v_syntax;						// immediate jump

v_run:
	ld hl, (vars);						// pointer to variables

v_each:
	ld a, (hl);							// first letter of existing variable
	and %01111111;						// match bits 0 to 6
	jr z, v_80_byte;					// jump when the marker is reached
	cp c;								// compare
	jr nz, v_next;						// jump if no match
	rla;								// rotate left and
	add a, a;							// double to test bits 5 and 6
	jp p, v_found_2;					// jump with strings and array variables
	jr c, v_found_2;					// jump with simple numeric and FOR-NEXT
	pop de;								// duplicate pointer
	push de;							// to second character
	push hl;							// stack pointer to first letter

v_matches:
	inc hl;								// next character

v_spaces:
	ld a, (de);							// each in turn
	inc de;								// next character
	cp ' ';								// space?
	jr z, v_spaces;						// jump if so
	or %00100000;						// test bit 5
	cp (hl);							// match?
	jr z, v_matches;					// jump if not
	or %10000000;						// test bit 7
	cp (hl);							// match?
	jr nz, v_get_ptr;					// jump if not
	ld a, (de);							// character to A
	call alphanum;						// letter?
	jr nc, v_found_1;					// jump if end found

v_get_ptr:
	pop hl;								// unstack pointer

v_next:
	push bc;							// stack BC
	call next_one;						// next variable pointer to DE
	ex de, hl;							// switch pointers
	pop bc;								// unstack BC
	jr v_each;							// jump back

v_80_byte:
	set 7, b;							// signal no variable

v_syntax:
	pop de;								// discard pointer to second character
	rst get_char;						// get current character
	cp '(';								// opening parenthesis?
	jr z, v_end;						// jump if so
	set 5, b;							// signal not an array
	jr v_end;							// immediate jump

v_found_1:
	pop de;								// discard saved variable pointer

v_found_2:
	pop de;								// discard second character pointer
	pop de;								// discard first letter pointer
	push hl;							// stack last letter pointer
	rst get_char;						// get current character

v_end:
	pop hl;								// point to single letter or last character
	rl b;								// rotate register
	bit 6, b;							// test bit 6
	ret;								// end of subroutine

stk_f_arg:
	ld hl, (defadd);					// point to first character
	ld a, (hl);							// store it in A
	cp ')';								// closing parenthesis?
	jp z, v_run_syn;					// jump if so to search variables

sfa_loop:
	ld a, (hl);							// next argument
	or %01100000;						// set bits 5 and 6
	inc hl;								// next code
	ld b, a;							// variable to B
	ld a, (hl);							// code to A
	cp ctrl_number;						// hidden number marker?
	jr z, sfa_cp_vr;					// jump if so
	dec hl;								// point to character
	call fn_skpovr;						// skip spaces
	res 5, b;							// clear bit 5
	inc hl;								// point to number marker

sfa_cp_vr:
	ld a, b;							// variable name to A
	cp c;								// match?
	jr z, sfa_match;					// jump if so
	inc hl;								// skip
	inc hl;								// five
	inc hl;								// byte
	inc hl;								// floating point
	inc hl;								// number
	call fn_skpovr;						// skip spaces
	cp ')';								// closing parenthesis?
	jp z, v_run_syn;					// jump if so
	call fn_skpovr;						// skip spaces
	jr sfa_loop;						// jump back

sfa_match:
	bit 5, c;							// test for numeric variable
	jr nz, sfa_end;						// jump if so
	inc hl;								// point to first byte
	ld de, (stkend);					// stack end to DE
	call move_fp;						// stack five bytes
	ex de, hl;							// new position to HL
	ld (stkend), hl;					// set stack end

sfa_end:
	pop de;								// discard look_vars
	pop de;								// pointers
	xor a;								// clear zero
	inc a;								// and carry flags
	ret;								// end of subroutine

stk_var:
	xor a;								// LD A, 0
	ld b, a;							// LD B, 0
	bit 7, c;							// checking syntax?
	jr nz, sv_count;					// jump if so
	bit 7, (hl);						// array variable?
	jr nz, sv_arrays;					// jump if so
	inc a;								// signal simple string

sv_simple_str:
	inc hl;								// advance pointer
	ld c, (hl);							// get low length pointer
	inc hl;								// advance pointer
	ld b, (hl);							// get high length pointer
	inc hl;								// advance pointer
	ex de, hl;							// pointer to string to DE
	call stk_sto_str;					// store on calculator stack
	rst get_char;						// get current character
	jp sv_slice_query;					// immediate jump

sv_arrays:
	inc hl;								// step past
	inc hl;								// length
	inc hl;								// bytes
	ld b, (hl);							// number of dimensions in B
	bit 6, c;							// number array?
	jr z, sv_ptr;						// jump if so
	dec b;								// reduce dimensions
	jr z, sv_simple_str;				// jump if one dimension
	ex de, hl;							// store pointer in DE
	rst get_char;						// get current character
	cp '(';								// opening parenthesis?
	jr nz, report_sscrpt_oo_rng;		// error if not
	ex de, hl;							// restore pointer to HL

sv_ptr:
	ex de, hl;							// pointer to DE
	jr sv_count;						// immediate jump

sv_comma:
	push hl;							// stack counter
	rst get_char;						// get current character
	pop hl;								// unstack counter
	cp ',';								// comma?
	jr z, sv_loop;						// jump if so
	bit 7, c;							// checking syntax?
	jr z, report_sscrpt_oo_rng;			// jump if so
	bit 6, c;							// string array?
	jr nz, sv_close;					// jump if so
	cp ')';								// closing parenthesis?
	jr nz, sv_rpt_c;					// jump if not
	rst next_char;						// increment ch_add
	ret;								// end of subroutine

sv_close:
	cp ')';								// closing parenthesis?
	jr z, sv_dim;						// jump if so
	cp tk_to;							// TO?
	jr nz, sv_rpt_c;					// jump if not

sv_ch_add:
	rst get_char;						// get current character
	dec hl;								// point to previous character
	ld (ch_add), hl;					// set sysvar
	jr sv_slice;						// immediate jump

sv_count:
	ld hl, 0;							// clear counter

sv_loop:
	push hl;							// stack counter
	rst next_char;						// increment ch_add
	pop hl ;							// unstack counter
	ld a, c;							// discriminator byte to A
	cp %11000000;						// checking syntax for string array?
	jr nz, sv_mult;						// jump if not
	rst get_char;						// get current character
	cp ')';								// closing parenthesis?
	jr z, sv_dim;						// jump if so
	cp tk_to;							// TO?
	jr z, sv_ch_add;					// jump back if slicing

sv_mult:
	push bc;							// stack dimension count
	push hl;							// stack element count
	call de_plus_1_to_de;				// dimension size to DE
	ex (sp), hl;						// counter to HL, stack variable pointer
	ex de, hl;							// counter to DE, size to HL
	call int_exp1;						// next subscript
	jr c, report_sscrpt_oo_rng;			// jump if out of range
	dec bc;								// reduce result
	call get_hl_x_de;					// counter * dimension size
	add hl, bc;							// add result of int_exp1
	pop de;								// unstack variable pointer
	pop bc;								// unstack number and discriminator byte
	djnz sv_comma;						// loop until done
	bit 7, c;							// checking syntax?

sv_rpt_c:
	jr nz, sl_rpt_c;					// error if so
	push hl;							// stack counter
	bit 6, c;							// array of strings?
	jr nz, sv_elem_str;					// jump if so
	ld c, e;							// variable pointer
	ld b, d;							// to BC
	rst get_char;						// get current character
	cp ')';								// closing parenthesis?
	jr z, sv_number;					// jump if so

report_sscrpt_oo_rng:
	rst error;							// else
	defb subscript_out_of_range;		// error

sv_number:
	rst next_char;						// increment ch_add
	pop hl;								// unstack counter
	ld de, 5;							// five bytes per element
	call get_hl_x_de;					// calculate number of bytes
	add hl, bc;							// point to next element
	ret;								// end of subroutine

sv_elem_str:
	call de_plus_1_to_de;				// last dimension size
	ex (sp), hl;						// stack variable pointer, counter to HL
	call get_hl_x_de;					// counter * dimension size
	pop bc;								// unstack variable pointer
	add hl, bc;							// location before string to HL
	inc hl;								// point to string
	ld c, e;							// last dimension size
	ld b, d;							// to BC
	ex de, hl;							// start to DE
	call stk_st_0;						// stack with leading zero
	rst get_char;						// get current character
	cp ')';								// closing parenthesis?
	jr z, sv_dim;						// jump if so
	cp ',';								// comma?
	jr nz, report_sscrpt_oo_rng;		// error if not

sv_slice:
	call slicing;						// modify parameters

sv_dim:
	rst next_char;						// get next character

sv_slice_query:
	cp '(';								// opening parenthesis?
	jr z, sv_slice;						// jump back with slice
	res 6, (iy + _flags);				// signal string
	ret;								// end of subroutine

slicing:
	call syntax_z;						// checking syntax?
	call nz, stk_fetch;					// get parameters if not
	rst next_char;						// get next character
	cp ')';								// closing parenthesis?
	jr z, sl_store;						// jump if so
	push de;							// stack pointer to start
	xor a;								// LD A, 0
	push af;							// stack A
	push bc;							// stack length
	ld de, 1;							// default to one if no parameter given
	rst get_char;						// get current character
	pop hl;								// unstack length
	cp tk_to;							// TO?
	jr z, sl_second;					// jump if so
	pop af;								// unstack A
	call int_exp2;						// first parameter to BC
	push af;							// stack error register
	ld e, c;							// first parameter
	ld d, b;							// to DE
	push hl;							// stack length
	rst get_char;						// get current character
	pop hl;								// unstack length
	cp tk_to;							// TO?
	jr z, sl_second;					// jump if so
	cp ')';								// closing parenthesis?

sl_rpt_c:
	jp nz, report_syntax_err;			// jump if not
	ld l, e;							// last character
	ld h, d;							// to HL
	jr sl_define;						// immediate jump

sl_second:
	push hl;							// stack length
	rst next_char;						// get next character
	pop hl;								// unstack length
	cp ')';								// closing parenthesis?
	jr z, sl_define;					// jump if so
	pop af;								// unstack error register
	call int_exp2;						// second parameter to BC
	push af;							// stack error register
	rst get_char;						// get current character
	ld l, c;							// result
	ld h, b;							// to HL
	cp ')';								// closing parenthesis?
	jr nz, sl_rpt_c;					// jump if not

sl_define:
	pop af;								// unstack error register
	ex (sp), hl;						// stack second parameter, start to HL
	add hl, de;							// add first parameter to start
	dec hl;								// move back
	ex (sp), hl;						// stack new start, second parameter to HL
	and a;								// prepare for subtraction
	sbc hl, de;							// get length of slice
	ld bc, $0000;						// clear new length
	jr c, sl_over;						// treat negative slice as null string
	inc hl;								// allow for inclusive byte
	and a;								// test error register
	jp m, report_sscrpt_oo_rng;			// jump if error
	ld c, l;							// new length
	ld b, h;							// to BC

sl_over:
	pop de;								// unstack new start
	res 6, (iy + _flags);				// signal string

sl_store:
	call unstack_z;						// return if checking syntax

stk_st_0:
	xor a;								// signal array string or sliced string

stk_sto_str:
	res 6, (iy + _flags);				// set flag for string result

stk_store:
	push bc;							// stack BC
	call test_5_sp;						// room for five bytes?
	pop bc;								// unstack BC
	ld hl, (stkend);					// address of first location to HL
	ld (hl), a;							// write first byte
	inc hl;								// next location
	ld (hl), e;							// write second byte
	inc hl;								// next location
	ld (hl), d;							// write third byte
	inc hl;								// next location
	ld (hl), c;							// write fourth byte
	inc hl;								// next location
	ld (hl), b;							// write fifth byte
	inc hl;								// next location
	ld (stkend), hl;					// set stack end
	ret;								// end of subroutine

int_exp1:
	xor a;								// clear the error register

int_exp2:
	push de;							// stack DE
	push hl;							// stack HL
	push af;							// stack the error register
	call expt_1num;						// get next expression on calculator stack
	pop af;								// unstack error register
	call syntax_z;						// checking syntax?
	jr z, i_restore;					// jump if so
	push af;							// stack error register
	call find_int2;						// last value to BC
	pop de;								// error register to D
	ld a, c;							// test 
	or b;								// for zero
	scf;								// set carry flag
	jr z, i_carry;						// jump if zero
	pop hl;								// limit value
	push hl;							// to HL
	and a;								// prepare for subtraction
	sbc hl, bc;							// test against limit

i_carry:
	ld a, d;							// old error value
	sbc a, 0;							// new error value

i_restore:
	pop hl;								// unstack HL
	pop de;								// unstack DE
	ret;								// end of subroutine

de_plus_1_to_de:
	ex de, hl;							// use HL
	inc hl;								// point to DE + 1
	ld e, (hl);							// LD E, (DE + 1)
	inc hl;								// point to DE + 2
	ld d, (hl);							// LD D, (DE + 2)
	ret ;								// end of subroutine

get_hl_x_de:
	call syntax_z;						// checking syntax? return if so
	ret z;								// (unstack_z would corrupt HL)
	call hl_hl_x_de;					// multiplication
	jp c, report_oo_mem;				// error if out of memory
	ret;								// end ofS subroutine

let:
	ld hl, (dest);						// current address of dest
	bit 1, (iy + _flagx);				// existing variable?
	jr z, l_exists;						// jump if so
	ld bc, $0005;						// assume five byte numeric variable

l_each_ch:
	inc bc;								// add one for each character in name

l_no_sp:
	inc hl;								// next position in variable name
	ld a, (hl);							// get character
	cp ' ';								// space?
	jr z, l_no_sp;						// jump to skip if so
	jr nc, l_test_ch;					// jump with code 33 to 255
	cp 16;								// code 0 to 15?
	jr c, l_spaces;						// jump if so
	cp 22;								// code 22 to 31?
	jr nc, l_spaces;					// jump if so
	inc hl;								// skip control code
	jr l_no_sp;							// jump back

l_test_ch:
	call alphanum;						// alphanumeric?
	jr c, l_each_ch;					// jump with long name
	cp '$';								// string?
	jp z, l_new_str;					// jump with simple string

l_spaces:
	ld a, c;							// length to A
	call var_end_hl;					// varaibles end marker location to HL
	call make_room;						// make BC spaces
	ex de, hl;							// first new byte to HL
	inc de;								// second new byte
	inc de;								// to DE
 	push de;							// stack pointer
	ld hl, (dest);						// pointer to start of name to HL
	dec de;								// pointer to first new byte to DE
	sub 6;								// number of extra letters
	ld b, a;							// store it in A
	jr z, l_single;						// jump with short name

l_char:
	inc hl;								// point to each extra code
	ld a, (hl);							// get it
	cp ' ' + 1;							// accept codes above space
	jr c, l_char;						// ignore codes below space
	inc de;								// next location
	or %00100000;						// SET 5, A, change case
	ld (de), a;							// store code
	djnz l_char;						// loop until done
	or %10000000;						// SET 7, A, mark code
	ld (de), a;							// replace last code
	ld a, %11000000;					// prepare long name mark

l_single:
	ld hl, (dest);						// get pointer to the letter
	xor (hl);							// A is 0 for short or 192 for long
	or %00100000;						// SET 5, A, change case
	pop hl;								// discard pointer
	call l_first;						// enter letter and set HL to end marker

l_numeric:
	push hl;							// stack destination pointer
	fwait();							// enter calculator
	fdel();								// reduce stack end by five
	fce();								// exit calculator
	pop hl;								// unstack destination pointer
	ld bc, 5;							// five bytes
	and a;								// prepare for subtraction
	sbc hl, bc;							// HL points to first of five locations
	jr l_enter;							// immediate jump

l_exists:
	bit 6, (iy + _flags);				// string?
	jr z, l_delete_str;					// jump if so
	ld de, 6;							// five bytes plus an additional byte
	add hl, de;							// final byte pointer to HL
	jr l_numeric;						// jump back

l_delete_str:
	ld bc, (strlen);					// get length
	bit 0, (iy + _flagx);				// simple string?
	jr nz, l_add_str;					// jump if so
	ld a, c;							// test for
	or b;								// null string
	ret z;								// return if so
	push hl;							// stack start (dest)
	rst bc_spaces;						// make space
	push de;							// stack pointer to first location
	push bc;							// stack length
	ld e, l;							// last location
	ld d, h;							// to DE
	inc hl;								// HL to one past new locations
	ld (hl), ' ';						// store a space
	lddr;								// write space in new locations
	push hl;							// stack pointer
	call stk_fetch;						// get new parameters
	pop hl;								// unstack pointer
	ex (sp), hl;						// length to HL
	and a;								// prepare for subtraction
	sbc hl, bc;							// compare lengths
	add hl, bc;							// test for fit
	jr nc, l_length;					// jump if so
	ld c, l;							// else
	ld b, h;							// trim

l_length:
	ex (sp), hl;						// new length to stack
	ex de, hl;							// start of new string to HL
	ld a, c;							// test for
	or b;								// null string
	jr z, l_in_w_s;						// jump if so
	ldir;								// else copy to workspace

l_in_w_s:
	pop bc;								// unstack new area length
	pop de;								// unstack new area pointer
	pop hl;								// unstack pointer to start

l_enter:
	ex de, hl;							// swap pointers
	ld a, c;							// test
	or b;								// for zero
	ret z;								// return if so
	push de;							// stack destination pointer
	ldir;								// move number or string
	pop hl;								// unstack destination pointer
	ret;								// end of subroutine

l_add_str:
	dec hl;								// point to
	dec hl;								// variable
	dec hl;								// letter
	ld a, (hl);							// get it in A
	push hl;							// stack pointer to existing
	push bc;							// stack length of existing
	call l_string;						// add new string to variables area
	pop bc;								// unstack length
	pop hl;								// unstack pointer
	inc bc;								// one byte for letter
	inc bc;								// two for
	inc bc;								// length
	jp reclaim_2;						// reclaim existing

l_new_str:
	ld a, %11011111;					// prepare to mark letter
	ld hl, (dest);						// pointer to letter
	and (hl);							// add mask

l_string:
	push af;							// stack letter
	call stk_fetch;						// get start and length
	ex de, hl;							// start to HL
	add hl, bc;							// end of string plus one to HL
	dec hl;								// end of string
	ld (dest), hl;						// store pointer
	push bc;							// stack length
	inc bc;								// one byte for letter
	inc bc;								// two for
	inc bc;								// length
	call var_end_hl;					// varaibles end marker location to HL
	call make_room;						// insert spaces
	ld hl, (dest);						// restore pointer
	pop bc;								// length
	push bc;							// to BC
	inc bc;								// increment length
	lddr;								// copy string plus one byte
	ex de, hl;							// point to high length byte
	pop bc;								// unstack length
	ld (hl), c;							// write low length byte
	inc hl;								// next address
	ld (hl), b;							// write high length byte
	dec hl;								// restore address
	pop af;								// unstack letter

l_first:
	dec hl;								// point to old end marker
	ld (hl), a;							// write new letter
	call var_end_hl;					// varaibles end marker location to HL
	ret;								// end of subroutine

;	// UnoDOS 3 entry point
	org $2bf1
stk_fetch:
	ld hl, (stkend);					// get stack end
	dec hl;								// step back
	ld b, (hl);							// fifth value to B
	dec hl;								// step back
	ld c, (hl);							// fourth value to C
	dec hl;								// step back
	ld d, (hl);							// third value to D
	dec hl;								// step back
	ld e, (hl);							// second value to E
	dec hl;								// step back
	ld a, (hl);							// first value to A
	ld (stkend), hl;					// set new stack end
	ret;								// end of subroutine

dim:
	call look_vars;						// search variables

d_rport_c:
	jp nz, report_syntax_err;			// jump if error
	call syntax_z;						// checking syntax?
	jr nz, d_run;						// jump if not
	res 6, c;							// signal handle strings as numeric
	call stk_var;						// valid syntax in parenthesis?
	call check_end;						// next statement

d_run:
	jr c, d_letter;						// jump if no existing array
	push bc;							// stack discriminator byte
	call next_one;						// start of next variable
	call reclaim_2;						// reclaim existing array
	pop bc;								// unstack discriminator byte

d_letter:
	set 7, c;							// discriminator byte
	ld b, 0;							// dimension counter
	push bc;							// stack both
	ld hl, $0001;						// default to one element
	bit 6, c;							// string
	jr nz, d_size;						// jump if so
	ld l, 5;							// else five for a numeric array

d_size:
	ex de, hl;							// size to DE

d_no_loop:
	rst next_char;						// get next character
	ld h, 255;							// limit value
	call int_exp1;						// get parameter
	jp c, report_sscrpt_oo_rng;			// jump if out of range
	pop hl;								// unstack counter and discriminator byte
	push bc;							// stack parameter
	inc h;								// increment counter
	push hl;							// re-stack counter and discriminator byte
	ld l, c;							// parameter
	ld h, b;							// to HL
	call get_hl_x_de;					// multiply to get total
	ex de, hl;							// result to DE
	rst get_char;						// get current character
	cp ',';								// comma?
	jr z, d_no_loop;					// jump if so
	cp ')';								// closing parenthesis?
	jr nz, d_rport_c;					// jump if not
	rst next_char;						// get next character
	pop bc;								// unstack counter
	ld a, c;							// discriminator byte to A
	ld l, b;							// counter to
	ld h, 0;							// HL
	inc hl;								// increment
	inc hl;								// twice
	add hl, hl;							// and double
	add hl, de;							// add element to total
	jp c, report_oo_mem;				// error if out of memory
	push de;							// stack element byte total
	push bc;							// stack counter
	push hl;							// stack length
	ld c, l;							// length
	ld b, h;							// to BC
	call var_end_hl;					// varaibles end marker location to HL
	call make_room;						// insert space
	inc hl;								// point to first new location
	ld (hl), a;							// store letter
	pop bc;								// unstack length
	dec bc;								// decrease
	dec bc;								// by
	dec bc;								// three
	inc hl;								// next position
	ld (hl), c;							// write low length byte
	inc hl;								// next position
	ld (hl), b;							// write high length byte
	pop bc;								// unstack counter
	ld a, b;							// counter to A
	inc hl;								// last position
	ld (hl), a ;						// write count
	ld l, e;							// last position
	ld h, d;							// minus one
	dec de;								// to DE
	ld (hl), 0;							// zero last location
	bit 6, c;							// string?
	jr z, dim_clear;					// jump if not
	ld (hl), ' ';						// else write space to last location

dim_clear:
	pop bc;								// unstack element byte total
	lddr;								// clear array plus one byte

dim_sizes:
	pop bc;								// unstack size
	ld (hl), b;							// write high byte
	dec hl;								// back
	ld (hl), c;							// write low byte
	dec hl;								// back
	dec a;								// reduce count
	jr nz, dim_sizes;					// loop until done
	ret;								// end of subroutine

alphanum:
	call numeric;						// digit?
	ccf;								// complement carry flag
	ret c;								// return with digit

alpha:
	cp 'A';								// A?
	ccf;								// complement carry flag
	ret nc;								// return if not valid
	cp 'Z' + 1;							// > Z? 
	ret c;								// return if upper case
	cp 'a';								// a?
	ccf;								// complement carry flag
	ret nc;								// return if not valid
	cp 'z' + 1;							// > z?
	ret;								// end of subroutine

dec_to_fp:
	ld de, 0;							// clear DE
	cp op_bin;							// %
	jr z, bin_digit;					// jump if so
	cp op_oct;							// @
	jr z, oct_digit;					// jump if so
	cp op_hex;							// $
	jr z, hex_digit;					// jump if so
	jr not_bin;							// immedaite jump

bin_digit:
	rst next_char;						// get next character
	sub '1';							// subtract ASCII '1'
	adc a, 0;							// carry set for 0, cleared for 1
	jr nz, bin_end;						// jump with other character
	ex de, hl;							// result to HL
	ccf;								// complement carry flag
	adc hl, hl;							// shift result left, carry to bit 0
	jr c, report_overflow_1;			// error if > 65535
	ex de, hl;							// result to DE
	jr bin_digit;						// loop until done

bin_end:
	ld c, e;							// result
	ld b, d;							// to BC
	jp stack_bc;						// immediate jump

oct_digit:
	rst next_char;						// get next character
	sub '0';							// convert ASCII to real value
	cp 8;								// greater than 7?
	jr nc, bin_end;						// jump if so
	ex de, hl;							// swap pointers
	add hl, hl;							// HL * 2
	jr c, oct_end;						// jump with overflow
	add hl, hl;							// HL * 4
	jr c, oct_end;						// jump with overflow
	add hl, hl;							// next octal place

oct_end:
	jr c, report_overflow_1;			// jump with overflow
	ld e, a;							// digit
	ld d, 0;							// to DE
	add hl, de;							// add to previous octal value 
	ex de, hl;							// swap pointers
	jp oct_digit;						// immediate jump

hex_digit:
	rst next_char;						// get next character
	call alphanum;						// alphanumeric?
	jr nc, bin_end;						// jump if not
	cp 'A';								// less than 10?
	jp c, hex_end;						// jump if so
	or %00100000;						// make lowercase
	cp 'g';								// greater than 15?
	jr nc, bin_end;						// jump if so
	sub 39;								// reduce range (: to ?)

hex_end:
	and %00001111;						// discard high nibble
	ld c, a;							// store in C
	ld a, d;							// D to A
	and %11110000;						// discard low nibble
	jr nz, report_overflow_1;			// jump if error
	ld a, c;							// low nibble to A
	ex de, hl;							// swap pointers
	add hl, hl;							// multiply
	add hl, hl;							// HL
	add hl, hl;							// by
	add hl, hl;							// 16
	or l;								// prepare for addition
	ld l, a;							// form low byte
	ex de, hl;							// swap pointers
	jr hex_digit;						// loop until done

not_bin:
	cp '.';								// decimal?
	jr z, decimal;						// jump if so
	call int_to_fp;						// else integer to last value
	cp '.';								// decimal?
	jr nz, e_format;					// jump if not
	rst next_char;						// get next character
	call numeric;						// digit?
	jr c, e_format;						// jump if not
	jr dec_sto_1;						// immediate jump

report_overflow_1:
	rst error;
	defb overflow;

decimal:
	rst next_char;						// get next character
	call numeric;						// digit?

dec_rpt_c:
	jp c, report_syntax_err;			// error if not
	fwait();							// enter calculator
	fstk0();							// stack zero
	fce();								// exit calculator

dec_sto_1:
	fwait();							// enter calculator
	fstk1();							// stack one in full floating point form
	fst(0);								// store in mem_0
	fdel();								// remove from calculator stack
	fce();								// exit calculator

nxt_dgt_1:
	rst get_char;						// get current character
	call stk_digit;						// stack digit
	jr c, e_format;						// jump if not digit
	fwait();							// enter calculator
	fgt(0);								// get from mem_0
	fstk10();							// x, 10
	fmul();								// x * 10
	fst(0);								// store in mem_0
	fdiv();								// divide by saved number
	fadd();								// add to last value
	fce();								// exit calculator
	rst next_char;						// get next character
	jr nxt_dgt_1;						// loop until done

e_format:
	cp 'E';								// E?
	jr z, sign_flag;					// jump if so
	cp 'e';								// e?
	ret nz;								// return if not

sign_flag:
	ld b, 255;							// signal positive
	rst next_char;						// get next character
	cp '+';								// plus?
	jr z, sign_done;					// jump if so
	cp '-';								// minus?
	jr nz, st_e_part;					// jump if not
	inc b;								// signal negative

sign_done:
	rst next_char;						// get next character

st_e_part:
	call numeric;						// digit?
	jr c, dec_rpt_c;					// jump if not
	push bc;							// stack sign
	call int_to_fp;						// stack ABS (exponent)
	call fp_to_a;						// transfer to A
	pop bc;								// unstack sign
	jr c, report_overflow_1;			// jump if
	and a;								// greater than
	jp m, report_overflow_1;			// 127
	inc b;								// test sign
	jr z, e_fp_jump;					// jump if positive
	neg;								// else negate

e_fp_jump:
	jp fp_e_to_fp;						// immediate jump

numeric:
	cp '0';								// zero character?
	ret c;								// return if lower value
	cp '9' + 1;							// > nine character?
	ccf;								// set carry if higher value
	ret;								// 

stk_digit:
	call numeric;						// digit?
	ret c;								// return if not
	sub '0';							// convert code to real number

stack_a:
	ld c, a;							// value to
	ld b, 0;							// BC

stack_bc:
	xor a;								// LD A, 0
	ld e, a;							// LD E, 0
	ld d, c;							// least significant byte to D
	ld c, b;							// most significant byte to C
	ld b, e;							// LD B, 0
	call stk_store;						// stack it in floating point form
	and a;								// clear carry flag
	jp stk_pntrs;						// immediate jump

int_to_fp:
	push af;							// stack first digit
	fwait();							// enter calculator
	fstk0();							// stack zero
	fce();								// exit calculator
	pop af;								// unstack first digit

nxt_dgt_2:
	call stk_digit;						// stack floating point form
	ret c;								// return if not a digit
	fwait();							// enter calculator
	fxch();								// swap with previous last value
	fstk10();							// stack 10
	fmul();								// multiply previous last value by 10
	fadd();								// add to digit
	fce();								// exit calculator
	call ch_add_plus_1;					// next code to A
	jr nxt_dgt_2;						// jump back
