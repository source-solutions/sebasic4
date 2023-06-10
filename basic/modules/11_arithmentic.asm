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

;;
;	// --- ARITHMETIC ROUTINES -------------------------------------------------
;;
:

;;
; E-format to floating point
;;
fp_e_to_fp:
	rlca;								// copy bit
	rrca;								// 7 to carry
	jr nc, e_save;						// jump if positive
	cpl;								// negate but
	inc a;								// preserve carry

e_save:
	push af;							// stack m
	ld hl, membot;						// address sysvar
	call fp_0_div_1;					// stack sign
	fwait;								// x
	fstk10;								// x, 10
	fce;								// exit calcualtor
	pop af;								// unstack m

e_loop:
	srl a;								// get next bit
	jr nc, e_tst_end;					// jump if carry cleared
	push af;							// stack flags
	fwait;								// x', 10^(2^n)
	fst 1;								// store in mem-1
	fgt 0;								// x', 10^(2^n), (1/0)
	fjpt e_divsn;						// x', 10^(2^n)
	fmul;								// x', 10^(2^n) = x''
	fjp e_fetch;						// x''

e_divsn:
	fdiv;								// x/10^(2^n) = x''

e_fetch:
	fgt 1;								// x'', 10^(2^n)
	fce;								// exit calculator
	pop af;								// unstack flags

e_tst_end:
	jr z, e_end;						// jump if zero
	push af;							// stack m
	fwait;								// x'', 10^(2^n)
	fmove;								// x'', 10^(2^n), 10^(2^n)
	fmul;								// x'', 10^(2^(n + 1))
	fce;								// exit calculator
	pop af;								// unstack m
	jr e_loop;							// loop for all bits

e_end:
	fwait;								// enter calculator
	fdel;								// delete final ^10
	fce;								// x * 10^m
	ret;								// end of subroutine

;;
; integer fetch
;;
int_fetch:
	inc hl;								// point to sign byte
	ld c, (hl);							// copy to C
	inc hl;								// point to low byte
	ld a, (hl);							// copy to A
	xor c;								// ones complement if negative
	sub c;								// add one if negative, set carry unless zero
	ld e, a;							// low byte to E
	inc hl;								// point to high byte
	ld a, (hl);							// high byte to A
	adc a, c;							// twos complement for negative
	xor c;								// carry always reset
	ld d, a;							// high byte to D
	ret;								// end of subroutine

;;
; integer store
;;
int_store:
	push hl;							// stack pointer to first byte
	inc hl;								// point to next byte
	ld (hl), c;							// C to second byte
	inc hl;								// point to next byte
	ld a, e;							// low byte to A
	xor c;								// twos complement
	sub c;								// if negative
	ld (hl), a;							// A to third byte
	inc hl;								// point to next byte
	ld a, d;							// high byte to A
	adc a, c;							// twos complement
	xor c;								// if negative
	ld (hl), a;							// A to fourth byte
	inc hl;								// point to next byte
	xor a;								// LD A, 0
	ld (hl), a;							// A to fifth byte
	pop hl;								// unstack pointer to first byte
	ld (hl), a;							// A to first byte
	ret;								// end of subroutine

;;
; floating point to A (8-bit integer)
;
fp_to_a:
	call fp_to_bc;						// last value on calc stack to BC
	ret c;								// return if out of range
	push af;							// stack result and flags
	dec b;								// is B
	inc b;								// zero?
	jr z, fp_a_end;						// jump if not
	pop af;								// unstack result and flags
	scf;								// signal out of range
	ret;								// end of subroutine

fp_a_end:
	pop af;								// unstack result and flags
	ret;								// end of subroutine

;;
; floating point to BC (16-bit integer)
;;
fp_to_bc:
	fwait;								// stkend_5 
	fce;								// to HL
	ld a, (hl);							// exponent to A
	and a;								// zero?
	jr z, fp_to_bc_delete;				// jump if so
	fwait;								// round to
	fstkhalf;							// nearest integer
	fadd;								// and convert
	fint;								// to small integer
	fce;								// form

fp_to_bc_delete:
	fwait;								// remove from 
	fdel;								// calculator
	fce;								// stack
	push de;							// stack both
	push hl;							// pointers
	ex de, hl;							// HL points to number
	ld b, (hl);							// first byte to B
	call int_fetch;						// C=2nd, E=3rd, D=4th byte
	xor a;								// LD A, 0
	sub b;								// set carry unless B is zero
	bit 7, c;							// set zero flag for a positive number
	ld a, e;							// low byte to A
	ld c, a;							// low byte to C
	ld b, d;							// high byte to B
	pop hl;								// unstack both
	pop de;								// pointers
	ret;								// end of subroutine

;;
; floating point to BCDE (32-bit integer) FIXME: numbers above 2^32 − 1 are not trapped
;;
fp_to_bcde:
	fwait;								// calculate timing loop counter
	fmove;								// copy last number
	fstk;								// stack a value
	defb $00, $41, $00;					// 65536
	fst 0;								// store it in mem_0
	fdiv;								// high 16 bits
	fint;								// to integer
	fxch;								// swap with float
	fgt 0;								// get value	
	fmod;								// modulo 65536 
	fce;								// exit calculator
	call fp_to_bc;						// get low word to BC
	push bc;							// stack it
	call fp_to_bc;						// get high word to BC
	pop de;								// low word to DE;
	ret;								// end of subroutine

;;
; log (2^A)
;;
log_2_a:
	ld d, a;							// store integer
	rla;								// in five byte form
	sbc a, a;							// with sign
	ld e, a;							// in
	ld c, a;							// A, E, D, C, B
	xor a;								// and
	ld b, a;							// then
	call stk_store;						// put on calculator stack
	fwait;								// enter calculator
	fstk;								// stack 
	defb $ef;							// x
	defb $1a, $20, $9a, $85;			// 
	fmul;								// x * log 2
	fint;								// int log (2^x)
	fce;								// exit calculator

;;
; print a floating-point number
;;
print_fp:
	fwait;								// enter calculator
	fmove;								// x, x
	fcp lz;								// x, (1/0)
	fjpt pf_negtve;						// x
	fmove;								// x, x
	fcp gz;								// x, (1/0)
	fjpt pf_postve;						// x
	fdel;								// remove last item
	fce;								// exit calculator
	ld a, '0';							// ASCII zero
	rst print_a;						// print it
	ret;								// end of subroutine

pf_negtve:
	fabs;								// x' = abs x
	fce;								// x'
	ld a, '-';							// minus sign
	rst print_a;						// print it
	fwait;								// enter calculator

pf_postve:
	fstk0;								// stack zero
	fst 3;								// store it in mem_3
	fst 4;								// mem_4
	fst 5;								// and mem_5
	fdel;								// remove it
	fce;								// exit calculator
	exx;								// alternate register set
	push hl;							// stack HL'
	exx;								// main register set

pf_loop:
	fwait;								// enter calculator
	fmove;								// x', x'
	fint;								// x', int (x') = i
	fst 2;								// i to mem_2
	fsub;								// x' - i = f
	fgt 2;								// f, i
	fxch;								// i, f
	fst 2;								// f to mem_2
	fdel;								// i
	fce;								// exit calculator
	ld a, (hl);							// small
	and a;								// integer?
	jr nz, pf_large;					// jump if not
	call int_fetch;						// i to DE
	ld b, 16;							// count
	ld a, d;							// D to A
	and a;								// zero?
	jr nz, pf_save;						// jump if not
	or e;								// zero?
	jr z, pf_small;						// jump if so
	ld b, 8;							// count
	ld d, e;							// D to E

pf_save:
	push de;							// copy
	exx;								// DE
	pop de;								// to
	exx;								// DE'
	jr pf_bits;							// immediate jump

pf_small:
	fwait;								// enter calculator
	fdel;								// i = 0 
	fgt 2;								// i, f
	fce;								// exit calculator
	ld a, (hl);							// exponent to A
	sub 126;							// e - 126
	call log_2_a;						// log (2^A), A=n
	ld d, a;							// n to D
	ld a, (mem_5_1);					// get count
	sub d;								// subtract it
	ld (mem_5_1), a;					// store count
	ld a, d;							// n to A
	call fp_e_to_fp;					// stack f*10^n
	fwait;								// i, u
	fmove;								// i, y, y
	fint;								// i, y, (int (y)) = i2
	fst 1;								// store i2 in mem-1
	fsub;								// i, y - i2
	fgt 1;								// i, y - i2, i2
	fce;								// i, f2, i2 (f2 = y - i2)
	call fp_to_a;						// i2 to A
	push hl;							// stack pointer to f2
	ld (mem_3), a;						// i2 to mem-3
	dec a;								// if A <> 0
	rla;								// then
	sbc a, a;							// let
	inc a;								// A = 1
	ld hl, mem_5;						// address mem_5
	ld (hl), a;							// store A
	inc hl;								// next location
	add a, (hl);						// add to A
	ld (hl), a;							// and store
	pop hl;								// unstack pointer to f2
	jr pf_fractn;						// immediate jump

pf_large:
	sub 128;							// e - 128 = e'
	cp 28;								// less than 28?
	jr c, pf_medium;					// jump if so
	call log_2_a;						// A = n 
	sub 7;								// n - 7
	ld b, a;							// second byte of mem-5
	ld hl, mem_5_1;						// store A in B
	add a, (hl);						// add contents of mem_5_1
	ld (hl), a;							// write back to mem_5_1
	ld a, b;							// restore A
	neg;								// negate it
	call fp_e_to_fp;					// i * 10^(-n + 7)
	jr pf_loop;							// immediate jump with medium sized number

pf_medium:
	ex de, hl;							// f to HL
	call fetch_two;						// mantissa to DE and DE'
	exx;								// alternate register set
	set 7, d;							// exponent of i to A
	ld a, l;							// set bit 7 of D'
	exx;								// main register set
	sub 128;							// e' = e - 128 to A
	ld b, a;							// count to B

pf_bits:
	sla e;								// rotate all
	rl d;								// bytes ...
	exx;								// alternate register set
	rl e;								// ... of i
	rl d;								// left
	exx;								// main register set
	ld hl, mem_4_4;						//  store in mem_4_4
	ld c, 5;							// count to five

pf_bytes:
	ld a, (hl);							// get byte in mem-4
	adc a, a;							// shift left including new bit
	daa;								// decimal adjust A
	ld (hl), a;							// store in mem_4
	dec hl;								// point to next byte of mem_4
	dec c;								// reduce byte count
	jr nz, pf_bytes;					// loop until mem_4 done
	djnz pf_bits;						// loop until all bits of int (x) done 
	ld de, mem_3;						// destination mem_3
	ld hl, mem_4;						// source mem_4
	ld b, 9;							// nine digits
	xor a;								// LD A, 0
	rld;								// discard high nibble of mem_4
	ld c, 255;							// signal leading zero

pf_digits:
	rld;								// high nibble to A, low nibble to high
	jr nz, pf_insert;					// jump if not zero
	dec c;								// leading
	inc c;								// zero?
	jr nz, pf_test_2;					// jump if so

pf_insert:
	ld (de), a;							// insert digit
	inc de;								// signal non-leading zero
	inc (iy + _mem_5);					// one digit before decimal
	inc (iy + _mem_5_1);				// one more for printing
	ld c, 0;							// next destination

pf_test_2:
	bit 0, b;							// even pass through loop?
	jr z, pf_all_9;						// jump if not
	inc hl;								// increment source pointer

pf_all_9:
	djnz pf_digits;						// loop for all nine digits
	ld a, (mem_5);						// get counter
	sub 9;								// nine digits excluding leading zeros?
	jr c, pf_more;						// jump if not
	dec (iy + _mem_5);					// reduce count for rounding
	ld a, 4;							// compare four
	cp (iy + _mem_4_3);					// with ninth digit
	jr pf_round;						// immediate jump

pf_more:
	fwait;								// enter calculator
	fdel;								// remove last item
	fgt 2;								// f
	fce;								// exit calculator

pf_fractn:
	ex de, hl;							// DE points to f
	call fetch_two;						// mantissa to DE and DE'
	exx;								// alternate register set
	ld a, 128;							// shift f by
	sub l;								// subtracting e
	ld l, 0;							// true numerical to bit 7 of D'
	set 7, d;							// LD L', 0
	exx;								// main register set
	call shift_fp;						// shift bits

pf_frn_lp:
	ld a, (iy + _mem_5);				// get count
	cp 8;								// eight digits?
	jr c, pf_fr_dgt;					// jump if not
	exx;								// alternate register set
	rl d;								// rotate D' to set carry
	exx;								// main register set
	jr pf_round;						// immediate jump

pf_fr_dgt:
	ld bc, $0200;						// clear C, count of 2

pf_fr_exx:
	ld a, e;							// multiply mantissa by 10
	call ca_10a_plus_c;					// first DE
	ld e, a;							// byte
	ld a, d;							// by byte
	call ca_10a_plus_c;					// then DE'
	ld d, a;							// result in C
	push bc;							// stack count and result (C or C')
	exx;								// switch register set
	pop bc;								// unstack count and result
	djnz pf_fr_exx;						// loop back once
	ld hl, mem_3;						// first byte of mem_3
	ld a, c;							// result to A
	ld c, (iy + _mem_5);				// count to C
	add hl, bc;							// address first empty byte
	ld (hl), a;							// store next digit
	inc (iy + _mem_5);					// increment count
	jr pf_frn_lp;						// loop until eight digits 

pf_round:
	push af;							// stack carry flag
	ld b, 0;							// offset
	ld c, (iy + _mem_5);				// to BC
	ld hl, mem_3;						// base address of number
	add hl, bc;							// last byte of number to HL
	ld b, c;							// counter to B
	pop af;								// unstack carry flag

pf_rnd_lp:
	dec hl;								// last byte of number
	ld a, (hl);							// get it in A
	adc a, 0;							// round up
	ld (hl), a;							// store in buffer
	and a;								// zero?
	jr z, pf_r_back;					// jump if so
	cp 10;								// ten?
	ccf;								// complement carry for valid digit
	jr nc, pf_count;					// jump if carry clear

pf_r_back:
	djnz pf_rnd_lp;						// loop until rounding done
	ld (hl), 1;							// extra digit before decimal
	inc b;								// extra one needed
	inc (iy + _mem_5_1);				// overflow to the left

pf_count:
	ld (iy + _mem_5), b;				// number of digits to print to B
	fwait;								// enter calculator
	fdel;								// remove last item
	fce;								// exit calculator
	exx;								// alternate register set
	pop hl;								// unstack offset to HL'
	exx;								// main register set
	ld bc, (mem_5);						// set counter
	ld hl, mem_3;						// start of digits
	ld a, b;							// B to A
	cp 9;								// more than nine digits?
	jr c, pf_not_e;						// jump if not
	cp 252;								// more than four leading zeros after decimal?
	jr c, pf_e_frmt;					// jump if so

pf_not_e:
	and a;								// no digits before decimal?
	call z, out_code;					// print initial zero if so

pf_e_sbrn:
	xor a;								// LD A, 0
	sub b;								// subtract B
	jp m, pf_out_lp;					// jump if digits before decimal
	ld b, a;							// use A as counter
	jr pf_dc_out;						// immediate jump

pf_out_lp:
	ld a, c;							// number of digits to print to A
	and a;								// still zeros to print?
	jr z, pf_out_dt;					// jump if so
	ld a, (hl);							// get digit from buffer
	inc hl;								// next digit
	dec c;								// reduce count

pf_out_dt:
	call out_code;						// print digit
	djnz pf_out_lp;						// loop until done

pf_dc_out:
	ld a, c;							// count to A
	and a;								// zero?
	ret z;								// return if so
	inc b;								// decimal
	ld a, '.';							// include decimal point

pf_dec_0s:
	rst print_a;						// print decimal
	ld a, '0';							// ASCII zero
	djnz pf_dec_0s;						// loop until zeros printer
	ld b, c;							// count to B for remaining digits
	jr pf_out_lp;						// immediate jump

pf_e_frmt:
	ld d, b;							// count to D
	ld b, 1;							// a digit before decimal in exponent format
	dec d;								// get exponent
	call pf_e_sbrn;						// print mantissa
	ld a, 'E';							// 'E'
	rst print_a;						// print it
	ld c, d;							// exponent to C
	ld a, d;							// and A
	and a;								// test sign
	jp p, pf_e_pos;						// jump if positive
	neg;								// else negate
	ld c, a;							// store in C
	ld a, '-';							// minus
	jr pf_e_sign;						// immediate jump

pf_e_pos:
	ld a, '+';							// plus sign

pf_e_sign:
	rst print_a;						// print sign
	ld b, 0;							// exponent to BC
	jp out_num_1;						// immediate jump

;;
; CA = 10 * A + C
;;
ca_10a_plus_c:
	ld l, a;							// A
	ld h, 0;							// to HL
	push de;							// stack DE
	ld e, a;							// HL
	ld d, h;							// to DE
	add hl, hl;							// * 2
	add hl, hl;							// * 4
	add hl, de;							// * 5
	add hl, hl;							// * 10
	ld e, c;							// C to DE
	add hl, de;							// HL = 10 * A + C
	pop de;								// unstack DE
	ld a, l;							// L to A
	ld c, h;							// H to C
	ret;								// end of subroutine

;;
; prepare to add
;;
prep_add:
	ld a, (hl);							// exponent to A
	and a;								// zero?
	ret z;								// return if so
	ld (hl), 0;							// make zero for positive
	inc hl;								// address sign byte
	bit 7, (hl);						// set zero flag for positive
	set 7, (hl);						// restore true numeric bit
	dec hl;								// step back
	ret z;								// return with positive
	push bc;							// stack exponent
	ld bc, 5;							// five bytes
	add hl, bc;							// address byte after last byte
	ld b, c;							// count to B
	ld c, a;							// exponent to C
	scf;								// set carry flag for negative

neg_byte:
	dec hl;								// each byte in turn
	ld a, (hl);							// get it
	cpl;								// one's complement
	adc a, 0;							// add in carry for negation
	ld (hl), a;							// store it
	djnz neg_byte;						// loop until done
	ld a, c;							// exponent to A
	pop bc;								// unstack exponent
	ret;								// end of subroutine

;;
; fetch two numbers
;;
fetch_two:
	push hl;							// stack HL
	push af;							// and AF
	ld c, (hl);							// m1 to C
	inc hl;								// next
	ld b, (hl);							// m2 to B
	ld (hl), a;							// sign tp HL
	inc hl;								// next
	ld a, c;							// m1 to A
	ld c, (hl);							// m3 to C
	push bc;							// stack m2 and m3
	inc hl;								// next
	ld c, (hl);							// m4 to C
	inc hl;								// next
	ld b, (hl);							// m5 to B
	ex de, hl;							// HL points to n1
	ld e, (hl);							// n1 to E
	ld d, a;							// m1 to D
	push de;							// stacl m1 and n1
	inc hl;								// next
	ld d, (hl);							// n2 to D
	inc hl;								// next
	ld e, (hl);							// n3 to E
	push de;							// stack n2 and n3
	exx;								// alternate register set
	pop de;								// n2 and n3 to DE'
	pop hl;								// m1 and n1 to HL'
	pop bc;								// m2 and m3 to BC'
	exx;								// main register set
	inc hl;								// next
	ld d, (hl);							// n4 to D
	inc hl;								// next
	ld e, (hl);							// n5 to E
	pop af;								// unstack AF
	pop hl;								// and HL
	ret;								// end of subroutine

;;
; shift addend
;;
shift_fp:
	and a;								// no exponent difference?
	ret z;								// return if so
	cp 33;								// greater than 32?
	jr nc, addend_0;					// jump if so
	push bc;							// stack BC
	ld b, a;							// exponent difference to B

one_shift:
	exx;								// alternate register set
	sra l;								// shift right arithmetic L'
	rr d;								// rotate right
	rr e;								// with carry DE'
	exx;								// main register set
	rr d;								// rotate right
	rr e;								// with carry DE
	djnz one_shift;						// shift all five bytes right until done
	pop bc;								// unstack BC
	ret nc;								// return if no carry
	call add_back;						// get carry
	ret nz;								// return if nothing to add

addend_0:
	exx;								// alternate register set
	xor a;								// LD A, 0

zeros_4_5:
	ld l, 0;							// clear L'
	ld e, l;							// clear
	ld d, a;							// DE'
	exx;								// main register set
	ld de, 0;							// clear DE
	ret;								// end of subroutine

;;
; add back
;;
add_back:
	inc e;								// add carry to rightmost byte
	ret nz;								// return if no overflow
	inc d;								// next
	ret nz;								// return if no overflow
	exx;								// alternate register set
	inc e;								// next
	jr nz, all_added;					// jump if no overflow
	inc d;								// next

all_added:
	exx;								// main register set
	ret;								// end of subroutine

;;
; subtraction
;;
fp_subtract:
	ex de, hl;							// swap pointers
	call fp_negate;						// negate number to be subtracted
	ex de, hl;							// swap pointers

;;
; addition
;;
fp_addition:
	ld a, (de);							// first byte of
	or (hl);							// both numbers zero?
	jr nz, full_addn;					// jump if not
	push de;							// stack pointer to second number
	inc hl;								// point to second byte of first number
	push hl;							// stack it
	inc hl;								// point to least significant byte
	ld e, (hl);							// store it in E
	inc hl;								// point to most significant byte
	ld d, (hl);							// store it in D
	inc hl;								// point to second
	inc hl;								// byte of
	inc hl;								// second number
	ld a, (hl);							// store it in A
	inc hl;								// point to least significant byte
	ld c, (hl);							// store it in C
	inc hl;								// point to most significant byte
	ld b, (hl);							// store it in B
	pop hl;								// unstack pointer to sign in HL
	ex de, hl;							// second number to HL
	add hl, bc;							// add first number
	ex de, hl;							// result to DE
	adc a, (hl);						// add sign byte and carry
	rrca;								// rotate
	adc a, 0;							// non zero indicates overflow
	jr nz, addn_oflw;					// jump if full addition required
	sbc a, a;							// set sign
	ld c, a;							// store sign in C
	inc a;								// 255 to 0
	or e;								// test A, D and E
	or d;								// for zero
	ld a, c;							// restore sign
	jr nz, addn_store;					// jump if not zero
	dec hl;								// point to first byte
	ld (hl), 145;						// store exponent
	inc hl;								// point to next byte
	and %10000000;						// set sign

addn_store:
	ld (hl), a;							// store sign
	inc hl;								// next location
	ld (hl), e;							// store low byte
	inc hl;								// next location
	ld (hl), d;							// store high byte
	dec hl;								// address
	dec hl;								// first byte
	dec hl;								// of result
	pop de;								// stack end to DE
	ret;								// end of subroutine

addn_oflw:
	dec hl;								// point to first number
	pop de;								// restore pointer to second number

full_addn:
	call re_st_two;						// convert both numbers to floating point
	exx;								// alternate register set
	push hl;							// stack next literal address
	exx;								// main register set
	push de;							// stack pointer to addend
	push hl;							// and pointer to augend
	call prep_add;						// prepare augend
	ld b, a;							// exponent to B
	ex de, hl;							// swap pointers
	call prep_add;						// prepare addend
	ld c, a;							// exponent to C
	cp b;								// first exponent smaller?
	jr nc, shift_len;					// jump if so
	ld a, b;							// swap
	ld b, c;							// exponents
	ex de, hl;							// swap pointers

shift_len:
	push af;							// stack larger exponent
	sub b;								// get difference in B
	call fetch_two;						// get two numbers from calculator stack
	call shift_fp;						// shift addend right
	pop af;								// unstack larger exponent
	pop hl;								// unstack pointer to result
	ld (hl), a;							// store exponent
	push hl;							// stack pointer to result
	ld l, b;							// m4 and m5
	ld h, c;							// to HL
	add hl, de;							// add two right bytes
	exx;								// alternate register set
	ex de, hl;							// n2 and n3 to HL'
	adc hl, bc;							// add left bytes with carry
	ex de, hl;							// result to DE'
	ld a, h;							// add H'
	adc a, l;							// add L'
	ld l, a;							// result to L'
	rra;								// test for
	xor l;								// left overflow
	exx;								// main register set
	ex de, hl;							// result in DE and DE'
	pop hl;								// unstack pointer to exponent
	rra;								// test for shift
	jr nc, test_neg;					// jump if no carry
	ld a, 1;							// single right shift
	call shift_fp;						// do it
	inc (hl);							// exponent plus one
	jr z, add_rep_6;					// jump with overflow

test_neg:
	exx;								// swap register set
	ld a, l;							// sign bit to A
	and %10000000;						// set sign
	exx;								// alternate register set
	inc hl;								// point to second byte
	ld (hl), a;							// store sign
	dec hl;								// point to first byte
	jr z, go_nc_mlt;					// ump with zero else twos complement
	ld a, e;							// first byte to A
	neg;								// negate it
	ccf;								// complement carry flag
	ld e, a;							// store in E
	ld a, d;							// next byte to A
	cpl;								// one's complement
	adc a, 0;							// add carry
	ld d, a;							// store in D
	exx;								// swap register set
	ld a, e;							// next byte to A
	cpl;								// one's complement
	adc a, 0;							// add carry
	ld e, a;							// store in E
	ld a, d;							// next byte
	cpl;								// one's complement
	adc a, 0;							// add carry
	jr nc, end_compl;					// jump if no carry
	rra;								// lse 0.5 to mantissa, e = e + 1
	exx;								// alternate register set
	inc (hl);							// increase (HL)

add_rep_6:
	jp z, report_overflow_2;			// jump if overflow
	exx;								// swap register set

end_compl:
	ld d, a;							// last byte to D
	exx;								// swap register set

go_nc_mlt:
	xor a;								// LD A, 0
	jp test_norm;						// immediate jump

;;
; HL = HL * DE
;;
hl_hl_x_de:
	push bc;							// stack BC
	ld b, 16;							// 16-bit multiplication
	ld a, h;							// most significant byte to A
	ld c, l;							// least significant byte to C
	ld hl, $0000;						// clear HL

hl_loop:
	add hl, hl;							// * 2
	jr c, hl_end;						// jump if overflow
	rl c;								// bit 7 to carry
	rla;								// carry to bit 0, bit 7 to carry
	jr nc, hl_again;					// jump if flag cleared
	add hl, de;							// else add DE
	jr c, hl_end;						// jump if overflow

hl_again:
	djnz hl_loop;						// loop until done

hl_end:
	pop bc;								// unstack BC
	ret;								// end of subroutine

;;
; prepare to multiply or divide
;;
prep_m_d:
	call test_zero;						// zero?
	ret c;								// return if so with carry set
	inc hl;								// point to sign byte
	xor (hl);							// sign to A
	set 7, (hl);						// set true numeric bit
	dec hl;								// point to exponen
	ret;								// end of subroutine

;;
; multiplication
;;
fp_multiply:
	ld a, (de);							// first bytes of
	or (hl);							// both numbers zero?
	jr nz, mult_long;					// jump if not
	push de;							// stack pointers to second
	push hl;							// and first numbers
	push de;							// stack pointer to second number
	call int_fetch;						// irst sign to C, number to DE
	ex de, hl;							// number to HL
	ex (sp), hl;						// number to stack, pointer to second to HL
	ld b, c;							// sign to B
	call int_fetch;						// second sign to C, number to DE
	ld a, c;							// resulting sign to A
	xor b;								// zero for positive, 255 for negative
	ld c, a;							// sign to C
	pop hl;								// first number to HL
	call hl_hl_x_de;					// HL * DE to HL 
	pop de;								// pointer to first number to DE
	ex de, hl;							// result to DE, pointer to HL
	jr c, mult_oflw;					// jump with overflow
	ld a, e;							// test DE
	or d;								// for zero
	jr nz, mult_rslt;					// jump if not
	ld c, a;							// make sign positive

mult_rslt:
	call int_store;						// result to calculator stack
	pop de;								// stack end to DE
	ret;								// end of subroutine

mult_oflw:
	pop de;								// pointer to second number to DE

mult_long:
	call re_st_two;						// both numbers to full floating point form
	xor a;								// LD A, 0
	call prep_m_d;						// prepare first number for multiplication
	ret c;								// return if zero
	exx;								// alternate register set
	push hl;							// stack next literal address
	exx;								// main register set
	push de;							// stack pointer to number to be multiplied
	ex de, hl;							// swap pointers
	call prep_m_d;						// prepare second number for multiplication
	ex de, hl;							// swap pointers
	jr c, zero_rslt;					// jump if second number is zero
	push hl;							// stack pointer to result
	call fetch_two;						// get two numbers from calculator stack
	ld a, b;							// m5 to A
	and a;								// prepare for subtraction
	sbc hl, hl;							// LD HL, 0
	exx;								// alternate register set
	push hl;							// stack m1 and n1
	sbc hl, hl;							// LD HL', 0
	exx;								// main register set
	ld b, 33;							// shift count
	jr strt_mlt;						// immediate jump

mlt_loop:
	jr nc, no_add;						// jump if no carry
	add hl, de;							// add number in DE to result
	exx;								// alternate register set
	adc hl, de;							// add number in DE' to result
	exx;								// main register set

no_add:
	exx;								// alternate register set
	rr h;								// shift HL'
	rr l;								// right
	exx;								// main register set
	rr h;								// shift HL
	rr l;								// right

strt_mlt:
	exx;								// alternate register set
	rr b;								// shift BC'
	rr c;								// right
	exx;								// main register set
	rr c;								// shift C right
	rra;								// shift A right with carry
	djnz mlt_loop;						// loop until done
	ex de, hl;							// HL to DE
	exx;								// alternate register set
	ex de, hl;							// HL' to DE'
	exx;								// main register set
	pop bc;								// unstack exponents
	pop hl;								// unstack pointer to exponent byte
	ld a, b;							// sum of exponents
	add a, c;							// to A
	jr nz, make_expt;					// jump if not zero
	and a;								// else clear carry flag

make_expt:
	dec a;								// prepare to increase
	ccf;								// exponent by 128

divn_expt:
	rla;								// rotate left with carry
	ccf;								// complement carry flag
	rra;								// rotate right with carry
	jp p, oflw1_clr;					// jump if sign flag cleared
	jr nc, report_overflow_2;			// jump if overflow
	and a;								// clear carry flag

oflw1_clr:
	inc a;								// increase A
	jr nz, oflw2_clr;					// jump if not zero
	jr c, oflw2_clr;					// jump if carry set
	exx;								// alternate register set
	bit 7, d;							// test bit 7 of D'
	exx;								// main register set
	jr nz, report_overflow_2;			// jump if overflow

oflw2_clr:
	ld (hl), a;							// set exponent byte
	exx;								// alternate register set
	ld a, b;							// LD A, B'
	exx;								// main register set

test_norm:
	jr nc, normalize;					// jump if no carry
	ld a, (hl);							// result to A
	and a;								// test for zero

near_zero:
	ld a, 128;							// or near zero
	jr z, skip_zero;					// jump with zero

zero_rslt:
	xor a;								// LD A, 0

skip_zero:
	exx;								// alternate register set
	and d;								// 2** - 128 if normal, else zero
	call zeros_4_5;						// set exponent to one
	rlca;								// unless zero
	ld (hl), a;							// restore exponent byte
	jr c, oflow_clr;					// jump if 2** - 128
	inc hl;								// second byte of result
	ld (hl), a;							// store zero
	dec hl;								// first byte of result
	jr oflow_clr;						// immediate jump

normalize:
	ld b, 32;							// left shift count

shift_one:
	exx;								// alternate register set
	bit 7, d;							// test bit 7 of D'
	exx;								// main register set
	jr nz, norml_now;					// jump if already normalized
	rlca;								// fifth byte to A
	rl e;								// rotate DE
	rl d;								// left
	exx;								// alternate register set
	rl e;								// rotate DE'
	rl d;								// left
	exx;								// main register set
	dec (hl);							// reduce exponent
	jr z, near_zero;					// jump if zero
	djnz shift_one;						// loop until done
	jr zero_rslt;						// immediate jump

norml_now:
	rla;								// rotate A left
	jr nc, oflow_clr;					// jump if no carry
	call add_back;						// else add back
	jr nz, oflow_clr;					// jump if no overflow
	exx;								// alternate register set
	ld d, 128;							// mantissa to 0.5
	exx;								// main register set
	inc (hl);							// increase result
	jr z, report_overflow_2;			// jump with overflow

oflow_clr:
	push hl;							// stack pointer
	inc hl;								// point to sign byte
	exx;								// alternate register set
	push de;							// stack DE'
	exx;								// main register set
	pop bc;								// DE' to BC
	ld a, b;							// sign to A
	rla;								// store sign
	rl (hl);							// in bit 7
	rra;								// of
	ld (hl), a;							// store first byte
	inc hl;								// next
	ld (hl), c;							// store second byte
	inc hl;								// next
	ld (hl), d;							// store third byte
	inc hl;								// next
	ld (hl), e;							// store fourth byte
	pop hl;								// unstack pointer to result
	pop de;								// unstack pointer to second number
	exx;								// alternate register set
	pop hl;								// next literal address to HL'
	exx;								// main register set
	ret;								// end of subroutine

report_overflow_2:
	rst error;							// throw
	defb overflow;						// error

;;
; division
;;
fp_division:
	call re_st_two;						// convert to full floating point form
	ex de, hl;							// swap pointers
	xor a;								// LD A, 0
	call prep_m_d;						// prepare number to divide by
	jr c, report_overflow_2;			// error if divide by zero
	ex de, hl;							// swap pointers
	call prep_m_d;						// prepare number to be divided
	ret c;								// return if already zero
	exx;								// alternate register set
	push hl;							// stack next literal address
	exx;								// main register set
	push de;							// stack pointer to number to divide by
	push hl;							// stack pointer to number to be divided
	call fetch_two;						// get two numbers from calculator stack
	exx;								// alternate register set
	push hl;							// stack m1 and n1
	ld l, c;							// to BC'
	ld h, b;							// number to be divided
	exx;								// main register set
	ld l, b;							// and
	ld h, c;							// BC
	xor a;								// LD A, 0
	ld b, $df;							// set count
	jr div_start;						// immediate jump

div_loop:
	rla;								// perform 32-bit shift into BC'CA taking
	rl c;								// one from carry, if set, at each shift
	exx;								// alternate register set
	rl c;								// rotate BC'
	rl b;								// left
	exx;								// main register set

div_34th:
	add hl, hl;							// move remains of dividend in HL'HL 
	exx;								// alternate register set
	adc hl, hl;							// and retrieve lost bit
	exx;								// main register set
	jr c, subn_only;					// jump if carry set

div_start:
	sbc hl, de;							// subtract divisor from dividend
	exx;								// alternate register set
	sbc hl, de;							// (32-bit arithmetic
	exx;								// main register set
	jr nc, no_rstore;					// jump if no carry
	add hl, de;							// restore HL
	exx;								// alternate register set
	adc hl, de;							// restore HL'
	exx;								// main register set
	and a;								// clear carry flag
	jr count_one;						// immediate jump

subn_only:
	and a;								// prepare for subtraction
	sbc hl, de;							// subtract divisor from dividend
	exx;								// alternate register set
	sbc hl, de;							// (32-bit arithmetic)
	exx;								// main register set

no_rstore:
	scf;								// set carry flag

count_one:
	inc b;								// increase count
	jp m, div_loop;						// loop until done
	push af;							// stack carry flag (33rd bit)
	jr z, div_34th;						// trial subtract for 34th bit if required
	ld e, a;							// transfer
	ld d, c;							// mantissa of result ...
	exx;								// alternate register set
	ld e, c;							// ... from BC'CA
	ld d, b;							// to DE'DE
	pop af;								// 34th bit
	rr b;								// to B'
	pop af;								// 33rd bit
	rr b;								// to B'
	exx;								// main register set
	pop bc;								// unstack exponent bytes
	pop hl;								// unstack pointer to result
	ld a, b;							// difference
	sub c;								// to A
	jp divn_expt;						// immediate jump

;;
; integer truncation towards zero
;;
fp_truncate:
	ld a, (hl);							// exponent to A
	and a;								// zero
	ret z;								// return if so
	cp 129;								// greater than 128?
	jr nc, t_gr_zero;					// jump if so
	ld (hl), 0;							// zero exponent
	ld a, 32;							// count
	jr nil_bytes;						// immediate jump

t_gr_zero:
	cp 145;								// 145?
	jr nc, x_large;						// jump if not
	push de;							// stack stack end
	cpl;								// adjust
	add a, 145;							// range
	inc hl;								// point to second byte
	ld d, (hl);							// second byte to D
	inc hl;								// next
	ld e, (hl);							// third byte to E
	dec hl;								// point to
	dec hl;								// first byte
	ld c, 0;							// assume negative number
	bit 7, d;							// test for negative
	jr z, t_numeric;					// jump if so
	dec c;								// else make positive

t_numeric:
	set 7, d;							// true numeric bit
	ld b, 8;							// test
	sub b;								// A >= 8
	add a, b;							// restore A
	jr c, t_test;						// jump if not
	ld e, d;							// byte to E
	ld d, 0;							// clear D
	sub b;								// test count

t_test:
	jr z, t_store;						// jump if zero
	ld b, a;							// count to B

t_shift:
	srl d;								// shift DE
	rr e;								// right
	djnz t_shift;						// loop until done

t_store:
	call int_store;						// result to calculator stack
	pop de;								// stack end to DE
	ret;								// end of subroutine

x_large:
	sub 160;							// subtract 160 from exponent
	ret p;								// return if positive
	neg;								// else negate

nil_bytes:
	push de;							// stack stack end
	ex de, hl;							// HL points to byte after fifth byte
	dec hl;								// point to fifth byte
	ld b, a;							// number of bits to zero to B
	srl b;								// divide by B
	srl b;								// to get
	srl b;								// byte count 
	jr z, bits_zero;					// jump if zero

byte_zero:
	ld (hl), 0;							// zero byte
	dec hl;								// next location
	djnz byte_zero;						// loop until done

bits_zero:
	and %00000111;						// A mod 8 = number of bits to zero
	jr z, ix_end;						// jump if zero
	ld b, a;							// count to B
	ld a, 255;							// set mask

less_mask:
	sla a;								// shift left and insert zero in bit 0
	djnz less_mask;						// loop until done
	and (hl);							// discard unwanted bits
	ld (hl), a;							// store value in (HL)

ix_end:
	ex de, hl;							// swap pointers
	pop de;								// stack end to DE
	ret;								// end of subroutine

;;
; restack two
;;
re_st_two:
	call restk_sub;						// perform re-stack twice

restk_sub:
	ex de, hl;							// swap pointers

;;
; restack
;;
fp_re_stack:
	ld a, (hl);							// first byte to A
	and a;								// large integer?
	ret nz;								// return if so
	push de;							// stack other pointer
	call int_fetch;						// sign to C, number to DE
	xor a;								// LD A, 0
	inc hl;								// point to fifth byte
	ld (hl), a;							// zero it
	dec hl;								// fourth byte
	ld (hl), a;							// zero it
	ld b, 145;							// set exponent (up to 16 bits)
	ld a, d;							// test D
	and a;								// for zero
	jr nz, rs_nrmlse;					// jump if not
	ld b, d;							// LD B, 0
	or e;								// test E for zero
	jr z, rs_store;						// jump if so
	ld d, e;							// E to D
	ld e, b;							// LD E, 0
	ld b, 137;							// set exponent (up to 8 bits)

rs_nrmlse:
	ex de, hl;							// swap pointers

rstk_loop:
	dec b;								// reduce exponent
	add hl, hl;							// shift number left
	jr nc, rstk_loop;					// loop until carry cleared
	rrc c;								// sign bit to carry flag
	rr h;								// shift number right
	rr l;								// and insert sign bit
	ex de, hl;							// swap pointers

rs_store:
	dec hl;								// HL points to third byte
	ld (hl), e;							// store it
	dec hl;								// second byte
	ld (hl), d;							// store it
	dec hl;								// first byte
	ld (hl), b;							// store exponent
	pop de;								// unstack other pointer
	ret;								// end of subroutine
