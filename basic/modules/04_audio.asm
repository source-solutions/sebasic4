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

beeper:
	di;									// interrupts off
	ld a, l;							// store L
	srl l;								// shift right logical
	srl l;								// to produce int (l/4)
	cpl;								// restore L
	and %00000011;						// get remainder
	ld b, 0;							// offset
	ld c, a;							// to BC
	ld ix, be_ix_plus_3;				// base loop
	add ix, bc;							// update loop length
	ld a, (bordcr);						// get border color
	and %00111000;						// discard unwanted bits
	rrca;								// rotate
	rrca;								// into
	rrca;								// place
	or %00001000;						// MIC off

be_ix_plus_3:
	nop;								// 12 t-state delay
	nop;								// 8 t-state delay
	nop;								// 4 t-state delay
	inc c;								// values in BC
	inc b;								// derived from HL

be_h_and_l_lp:
	dec c;								// timing loop
	jr nz, be_h_and_l_lp;				// 12 or 7 t-state jump
	dec b;								// reduce B
	ld c, 63;							// timing constant
	jp nz, be_h_and_l_lp;				// 10 t-state jump
	xor %00010000;						// toggle bit 4
	out (ula), a;						// write port
	ld c, a;							// store byte written
	ld b, h;							// reset B
	bit 4, a;							// half-cycle point?
	jr nz, be_again;					// jump if so
	ld a, e;							// test for
	or d;								// final pass
	jr z, be_end;						// jump if so
	dec de;								// decrease pass counter
	ld a, c;							// restore byte written
	ld c, l;							// reset C
	jp (ix);							// back to loop offset

be_again:
	ld c, l;							// reset C
	inc c;								// add 16 t-states
	jp (ix);							// jump back

be_end:
	ei;									// restore interrupts
	ret;								// end of beeper subroutine

;	// SOUND <pitch integer>, <duration in seconds>
sound:
	fwait();							// enter calc with pitch and duration on stack
	fxch();								// d, p
	fmove();							// d, p, p
	fint();								// d, p, i (i = INT p)
	fst(0);								// i to mem_0
	fsub();								// d, p (p = fractional part of p)
	fstk();								// stack k
	defb $ec;							// exponent (112)
	defb $6c, $98, $1f, $f5;			// mantissa (0.0577622606)
	fmul();								// d, pk
	fstk1();							// d, pk, 1
	fadd();								// d, pk + 1
	fce();								// exit calc
	ld hl, membot;						// mem_0 1st
	ld a, (hl);							// get exponent
	and a;								// error if not in 
	jr nz, report_overflow_0;			// short form
	inc hl;								// next location
	ld c, (hl);							// sign byte to C
	inc hl;								// next location
	ld b, (hl);							// low byte to B
	ld a, b;							// low byte to A
	rla;								// rotate left accumulator
	sbc a, a;							// subtract with carry
	cp c;								// -128 <= i <= +127
	jr nz, report_overflow_0;			// error if test failed
	inc hl;								// increment HL
	cp (hl);							// test against (HL)
	jr nz, report_overflow_0;			// error if not
	ld a, 60;							// set range
	add a, b;							// test low byte
	jp p, be_i_ok;						// jump if -60 <= i <=67
	jp po, report_overflow_0;			// error if -128 to -61

be_i_ok:
	ld b, 250;							// 6 octaves below middle C

be_octave:
	sub 12;								// reduce i to find
	inc b;								// correct octave
	jr nc, be_octave;					// loop until found
	ld hl, semi_tone;					// base of table
	push bc;							// stack octave
	add a, 12;							// pass back last subtraction
	call loc_mem;						// consider table and pass value
	call stack_num;						// at (A) to calculator stack
	fwait();							// d, pk + 1, C
	fmul();								// d, C(pk + 1)
	fce();								// exit calc
	pop af;								// unstack octave
	add a, (hl);						// multiply last value by 2^A
	ld (hl), a;							// d, f
	fwait();							// store frequency
	fst(0);								// in mem_0
	fdel();								// delete
	fmove();							// d, d
	fce();								// exit calc
	call find_int1;						// value 'INT d' must be
	cp 11;								// 0 to 11
	jr nc, report_overflow_0;			// jump if not
	fwait();							// d
	fgt(0);								// d, f
	fmul();								// f * d
	fgt(0);								// f * d, f
	fstk();								// stack 3.5 x 10^6 / 8
	defb $80;							// four bytes
	defb $43;							// mantissa
	defb $55, $9f, $80;					// exponent
	fxch();								// f * d, 437500, f
	fdiv();								// f * d, 437500 / f
	fstk();								// stack it
	defb $35;							// exponent
	defb $6c;							// mantissa
	fsub();								// subtract
	fce();								// exit calc
	call find_int2;						// timing loop compressed into BC
	push bc;							// stack loop
	call find_int2;						// f*d value compressed into BC
	pop hl;								// unstack loop into HL
	ld e, c;							// move f*d value
	ld d, b;							// to
	ld a, e;							// DE
	or d;								// no cycles required?
	ret z;								// return if so
	dec de;								// reduce cycle count
	jp beeper;							// exit via beeper subroutine

report_overflow_0:
	rst error;
	defb overflow;

bell:
	ld de, (rasp);						// pitch
	ld hl, 2148;						// duration
	call beeper;						// sound rasp
	ld (iy + _err_nr), 255;				// clear error
	ret;								// end of subroutine

mute_psg:
	ld hl, $fe07;						// H = AY-0, L = Volume register (7)
	ld de, $bfff;						// D = data port, E = register port / mute
	ld c, $fd;							// low byte of AY port
	call mute_ay;						// mute AY-0
	inc h;								// AY-1

mute_ay:
	ld b, e;							// AY register port
	out (c), h;							// select AY (255/254)
	out (c), l;							// select register
	ld b, d;							// AY data port
	out (c), e;							// AY off;
	ret;								// end of subroutine


