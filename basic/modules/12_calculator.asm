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

;	// --- FLOATING POINT CALCULATOR -------------------------------------------

;	// Microsoft Binary Format (MBF) extended-precision (40 bits)
;	//
;	// MBF numbers consist of an 8-bit base-2 exponent with a bias of 128, so
;	// that exponents −127 to −1 are represented by x = 1 to 127 ($01 to $7F),
;	// exponents 0 to 127 are represented by x = 128 to 255 ($80 to $FF), with a
;	// special case for x = 0 ($00) representing the whole number being zero, a
;	// sign bit (positive mantissa: s = 0; negative mantissa: s = 1) and a
;	// 31-bit (extended precision) mantissa of the significand. There is always
;	// a 1-bit implied to the left of the explicit mantissa, and the radix point
;	// is located before this assumed bit.
;	//
;	// Exponent  | Sign   | Significand
;	// ----------+--------+--------------------------------
;	// 8 bits,   | 1 bit, | 31 bits,
;	// bit 39-32 | bit 31 | bit 30-0
;	// ----------+--------+--------------------------------
;	// xxxxxxxx  | s      | mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm

;;
;
;;

;;
; calculator
;;
calculate:
	call stk_pntrs;						// HL to last value on calculator stack

gen_ent_1:
	ld a, b;							// offset or parameter
	ld (breg),a;						// to breg

gen_ent_2:
	exx;								// store subroutine
	ex (sp), hl;						// return address
	exx;								// in HL'

re_entry:
	ld (stkend), de;					// set to stack end
	exx;								// use alternate register set
	ld a, (hl);							// get literal
	inc hl;								// HL' points to next literal

scan_ent:
	push hl;							// stack it
	and a;								// test A
	jp p, first_3f;						// jump with 0 to 61
	ld d, a;							// literal to D
	and %01100000;						// preserve bit 5 and 6
	rrca;								// shift
	rrca;								// right
	rrca;								// into
	rrca;								// bit 1 and 2
	add a, tbl_offs;					// offsets 64 to 68
	ld l, a;							// L holds doubled offset
	ld a, d;							// get parameter
	and %00011111;						// from bits 0 to 4
	jr ent_table;						// address routine

first_3f:
	cp 24;								// unary operation?
	jr nc, double_a;					// jump if so
	exx;								// main register set
	call stk_pntrs_2;					// get pointers to operands
	exx;								// alternate register set

double_a:
	rlca;								// two bytes per entry
	ld l, a;							// so double offset

ent_table:
	ld de, tbl_addrs;					// base address
	ld h, 0;							// offset now in HL
	add hl, de;							// calculate address
	ld e, (hl);							// get address
	inc hl;								// of routine
	ld d, (hl);							// in DE
	ld hl, re_entry;					// stack re_entry
	ex (sp), hl;						// address
	push de;							// stack routine address
	exx;								// main register set
	ld bc, (stkend_h);					// breg to B

;;
; delete
;;
fp_delete:
	ret;								// end of subroutineindirect jump to subroutine

;;
; single operation
;;
fp_calc_2:
	pop af;								// drop re-entry address
	ld a, (breg);						// offset to A
	exx;								// alternate register set
	jr scan_ent;						// immediate jump

;;
; test five spaces
;;
test_5_sp:
	push de;							// stack DE
	push hl;							// stack HL
	ld bc, 5;							// 5 bytes
	call test_room;						// test for space
	pop hl;								// unstack HL
	pop de;								// unstack DE
	ret;								// end of subroutine

;;
; stack number
;;
stack_num:
	ld de, (stkend);					// get destination address
	call move_fp;						// move number
	ld (stkend), de;					// reset stack end
	ret;								// end of subroutine

;;
; move a floating point number
;;
move_fp:
fp_duplicate:
	call test_5_sp;						// test for space
	ldir;								// copy five bytes
	ret;								// end of subroutine

;;
; stack literals
;;
fp_stk_data:
	ld l, e;							// DE to
	ld h, d;							// HL

stk_const:
	call test_5_sp;						// test for space
	exx;								// alternate register set
	push hl;							// stack pointer to next literal
	exx;								// main register set
	ex (sp), hl;						// swap result and next literal pointers
	ld a, (hl);							// first literal to A
	and %11000000;						// divide by 64
	rlca;								// to give values
	rlca;								// 0 to 3
	ld c, a;							// value to C
	inc c;								// incremented (1 to 4)
	ld a, (hl);							// get literal again
	and %00111111;						// modulo 64
	jr nz, form_exp;					// jump if remainder not zero
	inc hl;								// else get next literal
	ld a, (hl);							// and leave unreduced

form_exp:
	add a, 80;							// add 80 to get exponent
	ld (de), a;							// put it on calculator stack
	ld a, 5;							// get number
	sub c;								// of literals
	inc hl;								// next literal
	inc de;								// next position in calculator stack
	ldir;								// copy literals
	ex (sp), hl;						// restore result and next literal pointers
	exx;								// alternate register set
	pop hl;								// unstack next literal to HL'
	exx;								// main register set
	ld b, a;							// zero bytes to B
	xor a;								// LD A, 0

stk_zeros:
	dec b;								// reduce count
	ret z;								// return if done
	ld (de), a;							// stack a zero
	inc de;								// next position in calculator stack
	jr stk_zeros;						// loop until done

;;
; memory location
;;
loc_mem:
	ld c, a;							// parameter to C
	rlca;								// multiply
	rlca;								// by
	add a, c;							// five
	ld c, a;							// result
	ld b, 0;							// to BC
	add hl, bc;							// get base address
	ret;								// end of subroutine

;;
; get from memory area
;;
fp_get_mem_xx:
	ld hl, (mem);						// get pointer to memory area

fp_get_mem_xx_2:
	push de;							// stack result pointer
	call loc_mem;						// get base address
	call move_fp;						// move five bytes
	pop hl;								// unstack result pointer
	ret;								// end of subroutine

;;
; stack a constant
;;
fp_stk_const_xx:
	ld hl, constants;					// address of table of constants
	jr fp_get_mem_xx_2;					// indirect exit to stack constant

;;
; store in memoyr area
;;
fp_st_mem_xx:
	push hl;							// stack result pointer
	ex de, hl;							// source to DE
	ld hl, (mem);						// pointer to memory area to HL
	call loc_mem;						// get base address
	ex de, hl;							// exchange pointers
	ld c, 5;							// five bytes
	ldir;								// copy
	ex de, hl;							// exchange pointers
	pop hl;								// unstack result pointer
	ret;								// end of subroutine

;;
; exchange
;;
fp_exchange:
	ld b, 5;							// five bytes

swap_byte:
	ld a, (de);							// get each byte of second
	ld c, a;							//
	ld a, (hl);							// and first
	ld (de), a;							// first number to (DE)
	ld (hl), c;							// second number to (HL)
	inc hl;								// consider next
	inc de;								// pair of bytes
	djnz swap_byte;						// exchange five bytes
	ret;								// end of subroutine

;;
; series generator
;;
fp_series_xx:
	ld b, a;							// parameter to B
	call gen_ent_1;						// enter calc and set counter
	fmove;								// z, z
	fadd;								// 2 * z
	fst 0;								// 2 * z			mem-0 holds 2 * z
	fdel;								// -
	fstk0;								// 0
	fst 2;								// 0				mem-2 holds 0

g_loop:
	fmove;								// b(r), b(r)
	fgt 0;								// b(r), b(r), 2 * z
	fmul;								// b(r), 2 * b(r) * z
	fgt 2;								// b(r), 2 * b(r) * z, b(r - 1)
	fst 1;								//					mem-1 holds b(r - 1) 
	fsub;								// b(r), 2 * b(r) * z - b(r - 1)
	fce;								// exit calculator
	call fp_stk_data;					// b(r), 2 * b(r) * z - b(r - 1), a(r + 1)
	call gen_ent_2;						// re-enter calc without disturbing breg
	fadd;								// b(r), 2 * b(r) * z - b(r - 1) + a(r + 1)
	fxch;								// 2 * b(r) * z - b(r - 1) + a(r + 1), b(r)
	fst 2;								//  				mem-2 holds b(r)
	fdel;								// 2 * b(r) * z - b(r - 1) + a(r + 1) =
	fdjnz g_loop;						// b(r + 1)
	fgt 1;								// b(n), b(n - 2)
	fsub;								// b(n) - b(n - 2)
	fce;								// exit calculator
	ret;								// end of subroutine

;;
; absolute magnitude
;;
fp_abs:
	ld b, $ff;							// B to 255
	jr neg_test;						// immediate jump

;;
; unary minus
;;
fp_negate:
	call test_zero;						// zero?
	ret c;								// return if so
fp_negate2:
	ld b, 0;							// signal negate

neg_test:
	ld a, (hl);							// get first byte
	and a;								// zero?
	jr z, int_case;						// jump if so
	inc hl;								// next byte
	ld a, b;							// $ff = abs, $00 = negate
	and %10000000;						// $80 = abs, $00 = negate
	or (hl);							// set bit 7 if abs
	rla;								// reset
	ccf;								// bit 7 of second byte
	rra;								// for abs
	ld (hl), a;							// store second byte
	dec hl;								// point to first byte
	ret;								// end of subroutine

int_case:
	push de;							// stack stack end
	push hl;							// stack pointer to number
	call int_fetch;						// get sign in C and number in DE
	pop hl;								// unstack pointer to number
	ld a, c;							// $ff = abs, $00 = negate
	or b;								// $80 = abs, $00 = negate
	cpl;								// $00 = abs, ? = negate
	jr fp_sgn_2;						// indirect exit

;;
; signmum
;;
fp_sgn:
	call test_zero;						// zero?
	ret c;								// return if so
	push de;							// stack stkend
	ld de, 1;							// one
	inc hl;								// point to second byte of x
	rl (hl);							// bit 7 to carry flag
	dec hl;								// point to destination
	sbc a, a;							// zero for positive, 255 for negative

fp_sgn_2:
	ld c, a;							// store it in C
	call int_store;						// store result on stack
	pop de;								// unstack stkend
	ret;								// end of subroutine

;;
; INP function
;;
fp_inp:
	call find_int2;						// last value to BC
	in a, (c);							// get signal
	jr in_pk_stk;						// stack result

;	// FIXME - test for segment
;;
; PEEK function
;;
fp_peek:
	call find_int2;						// get address in BC
	ld a, (bc);							// get byte

in_pk_stk:
	jp stack_a;							// indirect exit

;	// FIXME - (should restore IY to err-nr on return)
;;
; USR (number) function
;;
fp_usr_no:
	call find_int2;						// get address in BC
	ld hl, stack_bc;					// stack
	push hl;							// routine address
	push bc;							// stack address
	ret;								// end of subroutine

;;
; multiplication of string by a number
;;
fp_mul_str:
	inc hl;								// (HL) = mantissa MSB
	bit 7, (hl);						// check sign bit
	dec hl;								// restore HL
	push af;							// ZF clear, if negative
	call nz, fp_negate2;				// absolute value
	dec hl;								// (HL) = string length MSB
	ld b, (hl);							// B = string length MSB
	dec hl;								// (HL) = length LSB
	ld c, (hl);							// BC = string length
	push bc;							// stack string length (machine)
	call stack_bc;						// stack string length (calculator)
	fwait;								// arg2, length
	fmul;								// arg2 * length
	fce;								// 
	call find_int2;						// BC = new string length
	pop hl;								// HL = old string length
	sbc hl, bc;							// HL = length difference
	ex de, hl;							// HL = calculator stack pointer
	dec hl;								// (HL) = string length MSB
	ld (hl), b;							// update string length MSB
	dec hl;								// (HL) = string length LSB
	ld (hl), c;							// update string length
	dec hl;								// (HL) = string address MSB
	jr c, d_slong;						// jump, if new length > old length
	ld d, (hl);							// D = string address MSB
	dec hl;								// (HL) = string address LSB
	ld e, (hl);							// DE = string address
	pop af;								// restore sign in ZF
	jr z,fp_mul_str_e;					// return, if no flipping is necessary
	push de;							// stack string address
	rst bc_spaces;						// allocate space for mirrored string
	pop hl;								// HL = string address
	push de;							// 
	push bc;							// 
	ldir;								// 
	pop bc;								// 
	pop hl;								// 
	push hl;							// 
	call mirror;						// 
	pop de;								// 
	ld hl, (stkend);					// 
	dec hl;								// 
	dec hl;								// 
	dec hl;								// 
	ld (hl), d;							// 
	dec hl;								// 
	ld (hl), e;							// 

fp_mul_str_e:
	ld de, (stkend);					// 
	ret;								// 

d_slong:
	push hl;							// address pointer
	push de;							// excess length
	rst bc_spaces;						// allocate space for longer string
	pop hl;								// HL = excess length
	ld (membot + 28), hl;				// save excess length
	add hl, bc;							// HL = old length
	ex (sp), hl;						// retrieve address pointer
	add hl, bc;							// stack has moved
	ld b, (hl);							// 
	ld (hl), d;							// 
	dec hl;								// 
	ld c, (hl);							// 
	ld (hl), e;							// 
	ld l, c;							// 
	ld h, b;							// 
	pop bc;								// 
	push de;							// 
	ldir;								// 
	pop hl;								// 
	ld a, (membot + 28);				// 
	cpl;								// 
	ld c, a;							// 
	ld a, (membot + 29);				// 
	cpl;								// 
	ld b, a;							// 
	inc bc;								// 
	ldir;								// 
	pop af;								// 
	jr z, fp_mul_str_e;					// 
	call str_fetch;						// 
	ex de, hl;							// 
	call mirror;						// 
	jr fp_mul_str_e;					// 

;;
; Mirror a memory area
; HL = start, BC = length
;;
mirror:
	ld d, (hl);							// 
	dec bc;								// 
	ld a, c;							// 
	or b;								// 
	ret z;								// 
	add hl, bc;							// 
	ld e, (hl);							// 
	ld (hl), d;							// 
	sbc hl, bc;							// 
	ld (hl), e;							// 
	inc hl;								// 
	dec bc;								// 
	ld a, c;							// 
	or b;								// 
	jr nz, mirror;						// 
	ret;								// 

;;
; Like stk_fetch, but fetches only BC and DE and leaves STKEND alone.
;;
str_fetch:
	ld hl, (stkend);					// 
	dec hl;								// 
	ld b, (hl);							// 
	dec hl;								// 
	ld c, (hl);							// 
	dec hl;								// 
	ld d, (hl);							// 
	dec hl;								// 
	ld e, (hl);							// 
	ret;								// 

report_bad_fn_call:
	rst error;							// in this case
	defb illegal_function_call;			// an empty string

;;
; test zero
;;
test_zero:
	push bc;							// stack BC
	push hl;							// stack HL
	ld b, a;							// store value in c
	ld a, (hl);							// get first byte
	inc hl;								// point to second byte
	or (hl);							// OR with first
	inc hl;								// point to third byte
	or (hl);							// OR with third
	inc hl;								// point to fourth byte
	or (hl);							// OR with fourth
	ld a, b;							// restore A
	pop hl;								// unstack HL
	pop bc;								// unstack BC
	ret nz;								// carry reset if sum not zero
	scf;								// set carry for zero
	ret;								// end of subroutine

;;
; greater than zero operation
;;
fp_greater_0:
	call test_zero;						// zero?
	ret c;								// return if so
	ld a, $ff;							// sign byte
	jr sign_to_c;						// immediate jump

;;
; NOT function
;;
fp_not:
	fwait;							// x
	fneg;							// -x
	fstk1;							// -x, 1
	fsub;							// -x - 1
	fce;							// end calculation
	ret							// return

;	call test_zero;						// zero?
;	jr fp_0_div_1;						// immediate jump

;;
; less than zero operation
;;
fp_less_0:
	xor a;								// LD A, 0

sign_to_c:
	inc hl;								// point to sign
	xor (hl);							// carry reset if positive, set if negative
	dec hl;								// restore result pointer
	rlca;								// opposite effect from fp_greater_0

;;
; zero or minus one
;;
fp_0_div_1:
	push hl;							// stack result pointer
	sbc a, a;							// CF to all bits of A
	ld (hl), 0;							// zero first byte
	inc hl;								// point to next byte
	ld (hl), a;							// set second byte
	inc hl;								// point to next byte
	ld (hl), a;							// set third byte
	inc hl;								// point to next byte
	ld (hl), a;							// set fourth byte
	inc hl;								// point to next byte
	ld (hl), 0;							// zero fifth byte
	pop hl;								// unstack result pointer
	ret;								// end of subroutine


fp_get_int:
	ld a, (hl);
	or a;
	jr z, fp_get_int1;
	fwait;
	fstkhalf;
	fadd;
	fint;
	fce;
fp_get_int1:
	fwait;
	fdel;
	fce;
	push de;
	ex de, hl;
	xor a;
	cp (hl);
	jp nz, report_overflow;
	inc hl;
	inc hl;
	ld c, (hl);
	inc hl;
	ld b, (hl);
	ex de, hl;
	pop de;
	ret

fp_logic:
	call fp_get_int;
report_overflow_c:
	push bc;
	call fp_get_int;
	pop hl;
	ld a, c;
	ret

;;
; OR operation
;;
fp_or:
	call fp_logic;
	or l;
	ld d, a;
	ld a, b;
	or h;
fp_logic_end:
	ld c, a;
	add a, a;
	sbc a, a;
	ld e, a;
	xor a;
	call stk_store_nocheck;
	ex de, hl;
	ret;

;;
; XOR operation
;;
fp_xor:
	call fp_logic;
	xor l
	ld d, a;
	ld a, b;
	xor h;
	jr fp_logic_end;

;;
; number AND number operation
;;
fp_no_and_no:
	call fp_logic;
	and l
	ld d, a;
	ld a, b;
	and h;
	jr fp_logic_end;

;;
; string AND number operation
;;
fp_str_and_no:
	ex de, hl;							// HL = number, DE = $
	call test_zero;						// zero?
	ex de, hl;							// restore pointers
	ret nc;								// return if not zero
	dec de;								// point to fifth string byte
	xor a;								// LD A, 0
	ld (de), a;							// zero high byte of length
	dec de;								// point to fourth string byte
	ld (de), a;							// zero low byte of length
	inc de;								// restore
	inc de;								// pointer
	ret;								// end of subroutine

;;
; comparison operation
;;
fp_comparison:
	ld a, b;							// offset to A
	bit 2, a;							// >= 4?
	jr nz, ex_or_not;					// jump if not
	dec a;								// reduce range

ex_or_not:
	rrca;								// set carry for >= and <
	jr nc, nu_or_str;					// jump if carry flag not set
	push af;							// stack AF
	push hl;							// stack HL
	call fp_exchange;					// exchange
	pop de;								// unstack DE
	ex de, hl;							// swap HL with DE
	pop af;								// unstack AF

nu_or_str:
	rrca;								// update carry flag
	push af;							// stack it
	bit 2, a;							// string comparison?
	jr nz, strings;						// jump if so
	call fp_subtract;					// subtraction
	jr end_tests;						// end of subroutine

strings:
	call stk_fetch;						// length and start address of second string
	push de;							// stack
	push bc;							// them
	call stk_fetch;						// first string
	pop hl;								// unstack second string length

byte_comp:
	ld a, l;							// is second
	or h;								// string null?
	ex (sp), hl;						// swap HL with (SP)
	ld a, b;							// 
	jr nz, sec_plus;					// jump if not null
	or c;								// both null?

secnd_low:
	pop bc;								// unstack BC
	jr z, both_null;					// jump if so
	pop af;								// restore carry flag
	ccf;								// and complement
	jr str_test;						// immediate jump

both_null:
	pop af;								// restore carry flag
	jr str_test;						// immediate jump

sec_plus:
	or c;								// first less?
	jr z, frst_less;					// jump if so
	ld a, (de);							// compare
	sub (hl);							// next byte
	jr c, frst_less;					// jump if first byte less
	jr nz, secnd_low;					// jump if second byte less
	dec bc;								// bytes equal
	inc de;								// reduce
	inc hl;								// lengths
	ex (sp), hl;						// and jump
	dec hl;								// to compare
	jr byte_comp;						// next byte

frst_less:
	pop bc;								// unstack BC
	pop af;								// unstack AF
	and a;								// clear carry flag

str_test:
	push af;							// stack carry flag
	fwait;								// x
	fstk0;								// x, 0
	fce;								// exit calculator

end_tests:
	pop af;								// unstack carry flag
	push af;							// restack carry flag
	call c, fp_not;						// jump if set
	pop af;								// unstack carry flag
	push af;							// restack carry flag
	call nc, fp_greater_0;				// jump if not set
	pop af;								// unstack carry flag
	rrca;								// rotate into carry
	call nc, fp_not;					// jump if not set
	ret;								// end of subroutine

;;
; string concatenation operation
;;
fp_strs_add:
	call stk_fetch;						// get parameters of
	push de;							// second string
	push bc;							// and stack them
	call stk_fetch;						// get parameters of fisrt string
	pop hl;								// unstack length to HL
	push hl;							// and restack
	push de;							// stack paramters
	push bc;							// of fisrt string
	add hl, bc;							// find total length
	ld c, l;							// and store
	ld b, h;							// in BC
	rst bc_spaces;						// make space
	call stk_sto_str;					// parameters to calculator stack
	pop bc;								// unstack first
	pop hl;								// string parameters
	ld a, c;							// test for
	or b;								// null
	jr z, other_str;					// jump if so
	ldir;								// else copy to workspace

other_str:
	pop bc;								// unstack second
	pop hl;								// string parameters
	ld a, c;							// test for
	or b;								// null
	jr z, stk_pntrs;					// jump if so
	ldir;								// else copy to workspace

;;
; stack pointers
;;
stk_pntrs:
	ld hl, (stkend);					// stack end to HL

stk_pntrs_2:
	ld e, l	;							// DE points to second
	ld d, h;							// operand
	dec hl;								// make
	dec hl;								// HL
	dec hl;								// point
	dec hl;								// to first
	dec hl;								// operand
	ret;								// end of subroutine

;;
; CHR$ function
;;
fp_chr_str:
	call fp_to_a;						// last value to A
	jp c, report_overflow;				// error if greater than 255
	jp nz, report_overflow;				// or negative
	call bc_1_space;					// make one space
	ld (de), a;							// value to workspace
	jr fp_str_str_1;					// exit

;;
; VAL function
;;
fp_val:

;;
; VAL$ function
;;
fp_val_str:
	rst get_char;						// get current value of ch-add
	push hl;							// stack it
	ld a, b;							// offset to A
	add a, 227;							// carry set for VAL, reset for VAL$
	sbc a, a;							// bit 6 set for VAL, reset for VAL$
	push af;							// stack flag
	call stk_fetch;						// get parameters
	push de;							// stack start address
	inc bc;								// increase length by one
	rst bc_spaces;						// make space
	pop hl;								// unstack start address
	ld (ch_add), de;					// pointer to ch_add
	push de;							// stack it
	ldir;								// copy the string to the workspace
	ex de, hl;							// swap pointers
	dec hl;								// last byte of string
	ld (hl), ctrl_cr;					// replace with carriage return
	res 7, (iy + _flags);				// reset syntax flag
	call scanning;						// check syntax
	cp ctrl_cr;							// end of expression?
	jr nz, v_rport_c;					// error if not
	pop hl;								// unstack start address
	pop af;								// unstack flag
	xor (iy + _flags);					// test bit 6
	and %01000000;						// against syntax scan

v_rport_c:
	jp nz, report_syntax_err;			// error if no match
	ld (ch_add), hl;					// start address to ch_add
	set 7, (iy + _flags);				// set line execution flag
	call scanning;						// use string as next expression
	pop hl;								// get last value
	ld (ch_add), hl;					// and restore ch_add
	jr stk_pntrs;						// exit and reset pointers

;;
; STR$ function
;;
fp_str_str:
	call bc_1_space;					// make one space
	ld (k_cur), hl;						// set cursor address
	push hl;							// stack it
	ld hl, (curchl);					// get current channel
	push hl;							// stack it
	ld a, $ff;							// channel W
	call chan_open;						// open it
	call print_fp;						// print last value
	pop hl;								// unstack current channel
	call chan_flag;						// restore flags
	pop de;								// unstack start of string
	ld hl, (k_cur);						// get cursor address
	and a;								// calculate
	sbc hl, de;							// length
	ld c, l;							// store in 
	ld b, h;							// BC

fp_str_str_1:
	call stk_sto_str;					// parameters to calculator stack
	ex de, hl;							// reset pointers
	ret;								// end of subroutine

;;
; read in
;;
fp_read_in:
	ld hl, (curchl);					// get current channel
	push hl;							// stack it
	call str_alter_1;					// open new channel if valid
	call in_chan_k;						// keyboard?
	jr fp_read_in_1;					// jump if not
	halt;								// read keyboard

fp_read_in_1:
	call input_ad;						// accept input
	ld bc, 0;							// default length zero
	jr nc, r_i_store;					// jump if no signal
	inc c;								// increase length
	rst bc_spaces;						// make one space
	ld (de), a;							// put string in space

r_i_store:
	call stk_sto_str;					// get parameters to calculator stack
	pop hl;								// restore curchl
	call chan_flag;						// restore flags
	jp stk_pntrs;						// exit and set pointers

;;
; ASC function
;;
fp_asc:
	call stk_fetch;						// get string parameters
	ld a, c;							// test for
	or b;								// zero
	jr z, stk_asc;						// jump with null string
	ld a, (de);							// code of first character to A

stk_asc:
	jp stack_a;							// exit and return value

;;
; LEN function
;;
fp_len:
	call stk_fetch;						// get string parameters
	jp stack_bc;						// exit and return length

;;
; decrease counter
;;
fp_dec_jr_nz:
	exx;								// alternate register set
	push hl;							// stack literal pointer
	ld hl, breg;						// get breg (counter)
	dec (hl);							// reduce it
	pop hl;								// unstack literal pointer
	jr nz, jump_2;						// jump if not zero
	inc hl;								// next literal
	exx;								// main register set
	ret;								// end of subroutine

;;
; jump
;;
fp_jump:
	exx;								// alternate register set

jump_2:
	ld e, (hl);							// size of relative jump
	ld a, e;							// copy to E
	rla;								// set carry with negative
	sbc a, a;							// A to zero, or 255 for negative or
	ld d, a;							// copy to D
	add hl, de;							// new next literal pointer
	exx;								// main register set
	ret;								// end of subroutine

;;
; jump on true
;;
fp_jump_true:
	inc de;								// point to
	inc de;								// third byte
	ld a, (de);							// copy to A
	dec de;								// point to
	dec de;								// first byte
	and a;								// zero?
	jr nz, fp_jump;						// jump if not
	exx;								// alternate register set
	inc hl;								// skip jump length
	exx;								// main register set
	ret;								// end of subroutine

;;
; end calculator
;;
fp_end_calc:
	pop af;								// drop return address
	exx;								// alternate register set
	ex (sp), hl;						// stack address in HL'
	exx;								// main register set
	ret;								// exit using HL'

;;
; modulus
;;
fp_n_mod_m:
	fwait;								// n
	fst 1;								// n, m					mem_1 = m
	fdel;								// n
	fmove;								// n, n
	fgt 1;								// n, n, m
	fdiv;								// n, n / m
	fint;								// n, int (n / m)
	fgt 1;								// n, int (n / m), m
	fxch;								// n, m, int (n / m)
	fmul;								// n, m * int (n / m)
	fsub;								// n - m * int (n / m)
	fce;								// exit calculator
	ret;								// end of subroutine

;;
; INT function
;;
fp_int:
	fwait;								// x
	fmove;								// x, x
	fcp lz;								// x, (1 / 0)
	fjpt x_neg;							// x
	ftrn;								// i (x)
	fce;								// exit calculator
	ret;								// end of subroutine

x_neg:
	fmove;								// x, x
	ftrn;								// x, i (x)
	fst 0;								// x, i (x)			mem_0 = i (x
	fsub;								// x - i (x)
	fgt 0;								// x - i (x), i (x)
	fxch;								// i (x), (1 / 0)
	fnot;								// i (x)
	fjpt exit;							// i (x)
	fstk1;								// i (x), 1
	fsub;								// i (x) - 1

exit:
	fce;								// exit calculator
	ret;								// end of subroutine

;;
; exponential function
;;
fp_exp:
	fwait;								// x
	fstk;								// x, 1 / log 2
	defb $f1;							// exponent
	defb $38, $aa, $3b, $29;			// mantissa
	fmul;								// x / log 2 = y
	fmove;								// y, y
	fint;								// y, int y = n
	fst 3;								// y, n				mem-3 = n
	fsub;								// y - n = w
	fmove;								// w, w
	fadd;								// 2 * w
	fstk1;								// 2 * w, 1
	fsub;								// 2 * w - 1 = z
	defb $88;							// series generator
	defb $13;							// exponent
	defb $36;							// mantissa
	defb $58;							// exponent
	defb $65, $66;						// mantissa
	defb $9d;							// exponent
	defb $78, $65, $40;					// mantissa
	defb $a2;							// exponent
	defb $60, $32, $c9;					// mantissa
	defb $e7;							// exponent
	defb $21, $f7, $af, $24;			// mantissa
	defb $eb;							// exponent
	defb $2f, $b0, $b0, $14;			// mantissa
	defb $ee;							// exponent
	defb $7e, $bb, $94, $58;			// mantissa
	defb $f1;							// exponent
	defb $3a, $7e, $f8, $cf;			// mantissa
	fgt 3;								// 2 * w, n
	fce;								// exit calculator
	call fp_to_a;						// abs(n) mod 256 to A
	jr nz, n_negtv;						// jump if n negative
	jr c, report_overflow_3;			// error if abs(n) > 255
	add a, (hl);						// add abs(n) to exponent
	jr nc, result_ok;					// jump if e not > 255

report_overflow_3:
	rst error;							// else
	defb overflow;						// error

n_negtv:
	jr c, rslt_zero;					// zero if n < -255
	sub (hl);							// subtract abs(n)
	jr nc, rslt_zero;					// zero if e < zero
	neg;								// -e to +e

result_ok:
	ld (hl), a;							// store exponent
	ret;								// exit

rslt_zero:
	fwait;								// make
	fdel;								// last value
	fstk0;								// zero
	fce;								// exit calculator
	ret;								// end of subroutine

;;
; natural logarithm function
;;
fp_log:
	fwait;								// x
	frstk;								// full floating point form
	fmove;								// x, x
	fcp gz;								// x, (1 / 0)
	fjpt valid;							// x (jump if valid)
	fce;								// else exit calculator
	rst error;							// then
	defb illegal_function_call;			// error

valid:
	fce;								// exit calculator
	ld a, (hl);							// exponent to A
	ld (hl), $80;						// x to x'
	call stack_a;						// x', e
	fwait;								// x', e
	fstk;								// x', e, 128
	defb $38;							// exponent
	defb $00;							// mantissa
	fsub;								// x', e'
	fxch;								// e', x'
	fmove;								// e, x', x'
	fstk;								// e', x', x', 0.8
	defb $f0;							// exponent
	defb $4c, $cc, $cc, $cd;			// mantissa
	fsub;								// e', x', x' - 0.8
	fcp gz;								// e', x', (1 / 0)
	fjpt gre_8;							// e', x'
	fxch;								// x', e'
	fstk1;								// x, e', 1
	fsub;								// x, e' - 1
	fxch;								// e' - 1, x
	fce;								// exit calculator
	inc (hl);							// 2 * x'
	fwait;								// e' - 1, 2 * x'

gre_8:
	fxch;								// 2 * x', e' - 1
	fstk;								// x', e', log 2
	defb $f0;							// exponent
	defb $31, $72, $17, $f8;			// mantissa
	fmul;								// x', e' * log 2 = y1
;										// 2 * x', (e' -1 ) * log 2 = y2
	fxch;								// y1, x'		x' large
;										// y2, 2 * x'	x' small
	fstkhalf;							// y1, x', 0.5
;										// y2, 2 * x', 0.5
	fsub;								// y1, x' - 0.5
;										// y2, 2 * x' - 0.5 
	fstkhalf;							// y1, x' - 0.5, 0.5 
;										// y2, 2 * x' - 0.5, 0.5
	fsub;								// y1, x' - 1
;										// y2, 2 * x' - 1
	fmove;								// y, x' - 1, x' - 1
;										// y2, 2 * x' - 1, 2 * x' - 1
	fstk;								// y1, x' - 1, x' - 1, 2.5
;										// y2, 2 * x' - 1, 2 * x' - 1, 2.5
	defb $32;							// exponent
	defb $20;							// mantissa
	fmul;								// y1, x' - 1, 2.5 * x' - 2.5
;										// y2, 2 * x' - 1, 5 * x' - 2.5
	fstkhalf;							// y1, x' - 1, 2.5 * x' - 2.5, 0.5
;										// y2, 2 * x' - 1, 5 * x' - 2.5, 0.5
	fsub;								// y1, x' - 1, 2.5 * x' - 3 = z
;										// y2, 2 * x' - 1, 5 * x' - 3 = z
	defb $8c;							// series generator
	defb $11;							// exponent
	defb $ac;							// mantissa
	defb $14;							// exponent
	defb $09;							// mantissa
	defb $56;							// exponent
	defb $da, $a5;						// mantissa
	defb $59;							// exponent
	defb $30, $c5;						// mantissa
	defb $5c;							// exponent
	defb $90, $aa;						// mantissa
	defb $9e;							// exponent
	defb $70, $6f, $61;					// mantissa
	defb $a1;							// exponent
	defb $cb, $da, $96;					// mantissa
	defb $a4;							// exponent
	defb $31, $9f, $b4;					// mantissa
	defb $e7;							// exponent
	defb $a0, $fe, $5c, $fc;			// mantissa
	defb $ea;							// exponent
	defb $1b, $43, $ca, $36;			// mantissa
	defb $ed;							// exponent
	defb $a7, $9c, $7e, $5e;			// mantissa
	defb $f0;							// exponent
	defb $6e, $23, $80, $93;			// mantissa
	fmul;								// y1 = log (2** e'), log x'
;										// y2 = log (2** (e' - 1)), log (2 * x')
	fadd;								// log (2** e') * x')			= log x
;										// log (2** (e' - 1) * 2 * x')	= log x
	fce;								// exit calculator
	ret;								// log x

;;
; reduce argument
;;
fp_get_argt:
	fwait;								// x
	fstk;								// x, 1 / (2 * pi)
	defb $ee;							// exponent
	defb $22, $f9, $83, $6e;			// mantissa
	fmul;								// x / (2 * pi)
	fmove;								// x / (2 * pi), x / (2 * pi) 
	fstkhalf;							// x / (2 * pi), x / (2 * pi), 0.5
	fadd;								// x / (2 * pi), x / (2 * pi) + 0.5
	fint;								// x / (2 * pi), int (x / (2 * pi) + 0.5)
	fsub;								// x / (2 * pi) - int (x / (2 * pi) + 0.5) = y 
	fmove;								// y, y
	fadd;								// 2 * y
	fmove;								// 2 * y, 2 * y
	fadd;								//  4 * y
	fmove;								// 4 * y, 4 * y
	fabs;								// 4 * y, abs (4 * y)
	fstk1;								// 4 * y, abs (4 * y), 1
	fsub;								// 4 * y, abs(4 * y) - 1 = z
	fmove;								// 4 * y, z, z
	fcp gz;								// 4 * y, z, (1 / 0)
	fst 0;								// mem_0 = test result
	fjpt zplus;							// 4 * y, z
	fdel;								// 4 * y
	fce;								// 4 * y = v (case 1)
	ret;								// end of subroutine

zplus:
	fstk1;								// 4 * y, z, 1
	fsub;								// 4 * y, z - 1
	fxch;								// z - 1, 4 * y
	fcp lz;								// z - 1, (1 / 0)
	fjpt yneg;							// z - 1
	fneg;								// 1 - z

yneg:
	fce;								// exit calculator
	ret;								// end of subroutine

;;
; cosine function
;;
fp_cos:
	fwait;								// x
	fget;								// v
	fabs;								// abs v
	fstk1;								// abs v, 1
	fsub;								// abs v - 1
	fgt 0;								// abs v - 1, (1/0)
	fjpt c_ent;							// abs v - 1 = w
	fneg;								// 1 - abs v
	fjp c_ent;							// 1 - abs v = w

;;
; sine function
;;
fp_sin:
	fwait;								// x
	fget;								// w

c_ent:
	fmove;								// w, w
	fmove;								// w, w, w
	fmul;								// w, w, w * w
	fmove;								// w, 2 * w * w, 1
	fadd;								// w, 2 * w * w
	fstk1;								// w, 2 * w * w, 1
	fsub;								// w, 2 * w * w - 1 = z
	defb $86;							// series-06
	defb $14;							// exponent
	defb $e6;							// mantissa
	defb $5c;							// exponent
	defb $1f, $0b;						// mantissa
	defb $a3;							// exponent
	defb $8f, $38, $ee;					// mantissa
	defb $e9;							// exponent
	defb $15, $63, $bb, $23;			// mantissa
	defb $ee;							// exponent
	defb $92, $0d, $cd, $ed;			// mantissa
	defb $f1;							// exponent
	defb $23, $5d, $1b, $ea;			// mantissa
	fmul;								// in (pi * w / 2) = sin x (or = cos x)
	fce;								// sin x (or cos x)
	ret;								// end of subroutine

;;
; tangent function
;;
fp_tan:
	fwait;								// x
	fmove;								// x, x
	fsin;								// x, sin x
	fxch;								// sin x, cos x
	fcos;								// sin x / cos x = tan x
	fdiv;								// test for overflow
	fce;								// exit calculator
	ret;								// end of subroutine

;;
; arctangent function
;;
fp_atan:
	call fp_re_stack;					// get floating point form of x
	ld a, (hl);							// get exponent
	cp $81;								// y = x?
	jr c, small;						// jump if so
	fwait;								// x
	fstk1;								// x, 1
	fneg;								// x, -1
	fxch;								// -1, x
	fdiv;								// -1 / x
	fmove;								// -1 / x, -1 / x
	fcp lz;								// -1 / x, (1 / 0)
	fstkhalfpi;							// -1 / x, pi / 2, (1 / 0) 
	fxch;								// -1 / x, pi / 2
	fjpt cases;							// jump if y = -1 / x, w = pi / 2
	fneg;								// -1 / 2, =pi / 2
	fjp cases;							// jump if y = -1 / x, w = -pi / 2

small:
	fwait;								// y
	fstk0;								// y, 0

cases:
	fxch;								// w, y
	fmove;								// w, y, y
	fmove;								// w, y, y, y
	fmul;								// w, y, y * y
	fmove;								// w, y, y * y, y * y
	fadd;								// w, y, 2 * y * y
	fstk1;								// w, y, 2 * y * y, 1
	fsub;								// w, y, 2 * y * y - 1 = z
	defb $8c;							// series-0c
	defb $10;							// exponent
	defb $b2;							// mantissa
	defb $13;							// exponent
	defb $0e;							// mantissa
	defb $55;							// exponent
	defb $e4, $8d;						// mantissa
	defb $58;							// exponent
	defb $39, $bc;						// mantissa
	defb $5b;							// exponent
	defb $98, $fd;						// mantissa
	defb $9e;							// exponent
	defb $00, $36, $75;					// mantissa
	defb $a0;							// exponent
	defb $db, $e8, $b4;					// mantissa
	defb $63;							// exponent
	defb $42, $c4;						// mantissa
	defb $e6;							// exponent
	defb $b5, $09, $36, $be;			// mantissa
	defb $e9;							// exponent
	defb $36, $73, $1b, $5d;			// mantissa
	defb $ec;							// exponent
	defb $d8, $de, $63, $be;			// mantissa
	defb $f0;							// exponent
	defb $61, $a1, $b3, $0c;			// mantissa
	fmul;								// w, atn x			case 1
;										// w, atn (-1/x) 	case 2 and 3
	fadd;								// atn x
	fce;								// exit calculator
	ret;								// end of subroutine

;;
; arcsine function
;;
fp_asin:
	fwait;								// x
	fmove;								// x, x
	fmove;								// x, x, x
	fmul;								// x, x * x
	fstk1;								// x, x * x, 1
	fsub;								// x, x * x - 1
	fneg;								// x, 1 - x * x
	fsqrt;								// x, sqr(1 - x * x)
	fstk1;								// x, sqr(1 - x * x), 1
	fadd;								// x, 1 + sqr(1 - x * x)
	fdiv;								// x / (1 + sqr(1 - x * x)) = tan
	fatan;								// y / 2
	fmove;								// y / 2, y / 2
	fadd;								// y = asn x
	fce;								// exit calculator
	ret;								// end of subroutine

;;
; arccosine function
;;
fp_acos:
	fwait;								// x
	fasin;								// asn x
	fstkhalfpi;							// asn x, pi / 2
	fsub;								// asn x - pi / 2
	fneg;								// pi / 2 - asn x = acs x
	fce;								// exit calculator
	ret;								// end of subroutine

;;
; square root function
;;
fp_sqr:
	fwait;								// x
	frstk;								// full floating point form
	fst 0;								// store in mem-0
	fce;								// exit calculator
	ld a, (hl);							// value to A
	and a;								// test against zero
	ret z;								// return if so
	add a, 128;							// set carry if greater or equal to 128
	rra;								// divide by two
	ld (hl), a;							// replace value
	inc hl;								// next location
	ld a, (hl);							// get sign bit
	rla;								// rotate left
	jp c, report_bad_fn_call;			// error with negative number
	ld (hl), 127;						// mantissa starts at about one
	ld b, 5;							// set counter

fp_sqr_1:
	fwait;								// x
	fmove;								// x, x
	fgt 0;								// x, x, n
	fxch;								// x, n, x
	fdiv;								// x, n / x
	fadd;								// x + n / x
	fce;								// exit calculator
	dec (hl);							// halve value
	djnz fp_sqr_1;						// loop until found
	ret;								// end of subroutine

;;
; exponentiation operation
;;
fp_to_power:
	ld a, (de);							//
	or a;								//
	jr nz, topwr1;						//
	call fp_to_bc_delete;				//
	push bc;							//
	jr z, topwrp;						//
	fwait;								// x

topwrn:
	fstk1;								// x, 1
	fxch;								// 1, x
	fdiv;								// 1/x
	fce;								// exit calculator

topwrp:
	pop hl;								//
	ld a, l;							//
	or h;								//
	jr z, stkone;						//
	ld b, $10;							//
	dec a;								//
	jr nz, topwsh;						//
	ld a, h;							//
	or a;								//
	ret z;								//

topwsh:
	dec b;								//
	add hl, hl;							//
	jr nc, topwsh;						//
	push hl;							//
	fwait;								// x
	fst 0;								// store in mem-0

topwrl:
	fmove;								// x, x
	fmul;								// x, x * x
	fce;								// exit calculator
	pop hl;								//
	add hl, hl;							//
	push hl;							//
	ld a, (breg);						//
	ld b, a;							//
	jr nc, topwre;						//
	fwait;								// x
	fgt 0;								// x, x
	fmul;								// x, x * x
	fjp topwro;							//

topwre:
	fwait;								// x

topwro:
	fdjnz topwrl;						//
	fce;								// exit calculator
	pop hl;								//
	ret;								//

topwr1:
	fwait;								// x
	fxch;								// y, x
	fmove;								// y, x, x
	fnot;								// y, x, (1 / 0)
	fjpt xis0;							// y, x
	flogn;								// y, log x
	fmul;								// y * log x
	fce;								// exit calculator
	jp fp_exp;							// form exp(y * log x)

xis0:
	fxch;								// 0, y
	fcp gz;								// 0, (1 / 0)
	fjpt last;							// 0
	fjp topwrn;							// 1/x (reciprocal already available)

stkone:
	fwait;								// x

one:
	fdel;								// -
	fstk1;								// 1

last:
	fce;								// exit calculator
	ret;								// end of subroutine

;	// new function 1
fp_new_fn_1:
	ret;								// 

;	// new function 2
fp_new_fn_2:
	ret;								// 
