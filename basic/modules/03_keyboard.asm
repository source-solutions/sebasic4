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

;	// keyboard routines are called during maskable interrupt and avoid
;	// use of IY because the maskable interrupt routine does not stack it

; 	// control codes
;	//
;	// dec	hex		ascii	key press	print action
;	// ----------------------------------------------------
;	// 006	$06		ACK		caps lock	tab
;	// 007	$07		BEL		tab			?
;	// 008	$08		BS		left		cursor left
;	// 009	$09		HT		right		cursor right
;	// 010	$0a		LF		down		cursor down
;	// 011	$0b		VT		up			cursor up
;	// 012	$0c		FF		backspace	CLS
;	// 013	$0d		CR		enter		carriage return
;	// 014	$0e		SO		alternate	
;	// 015	$0f		SI		control		
;	// 016	$10		DLE		home		 
;	// 017	$11		DC1		end
;	// 018	$12		DC2		pg-up
;	// 019	$13		DC3		pg-dn
;	// 020	$14		DC4		insert
;	// 021	$15		NAK		help		
;	// 022	$16		SYN		clr			
;	// 127	$7f		DEL		delete		

; 	// new control codes
;	//
;	// dec	hex		ascii	key press	print action
;	// ----------------------------------------------------
;	// 000	$00		NUL		insert		
;	// 001	$01		SOH		clr			
;	// 002	$02		STX		home
;	// 003	$03		ETX		end
;	// 004	$04		EOT		pg-up
;	// 005	$05		ENQ		pg-dn
;	// 006	$06		ACK		caps lock	tab
;	// 007	$07		BEL		tab			?
;	// 008	$08		BS		left		cursor left
;	// 009	$09		HT		right		cursor right
;	// 010	$0a		LF		down		cursor down
;	// 011	$0b		VT		up			cursor up
;	// 012	$0c		FF		backspace	CLS
;	// 013	$0d		CR		enter		carriage return
;	// 014	$0e		SO		alternate	
;	// 015	$0f		SI		control		
;	// 016	$10		DLE		help			
;	// 017	$11		DC1		F1			
;	// 018	$12		DC2		F2			
;	// 019	$13		DC3		F3			
;	// 020	$14		DC4		F4			
;	// 021	$15		NAK		F5			
;	// 022	$16		SYN		F6			
;	// 023	$17		ETB		F7			
;	// 024	$18		CAN		F8			
;	// 025	$19		EM		F9			
;	// 026	$1a		SUB		F10			
;	// 027	$1b		ESC		F11			
;	// 028	$1c		FS		F12			
;	// 029	$1d		GS		F13			
;	// 030	$1e		RS		F14			
;	// 031	$1f		US		F15			
;	// 127	$7f		DEL		delete		

;	// --- KEYBOARD ROUTINES ---------------------------------------------------

;	// keyboard scanning subroutine
key_scan:
	ld bc, $fefe;						// B = counter, C = port
	ld de, $ffff;						// set DE to no key
	ld l, 47;							// initial key value

key_line:
	in a, (c);							// read ULA
	cpl;								// complement A
	and %00011111;						// test for key press
	jr z, key_done;						// jump if not
	ld h, a;							// key bits to H
	ld a, l;							// initial value to L

key_3keys:
	inc d;								// check for three keys pressed
	ret nz;								// return if so

key_bits:
	sub 8;								// subtract 8
	srl h;								// from key value
	jr nc, key_bits;					// until bit found
	ld d, e;							// existing key value to D
	ld e, a;							// new key value to E
	jr nz, key_3keys;					// jump if three keys

key_done:
	dec l;								// reduce key value 
	rlc b;								// shift counter
	jr c, key_line;						// jump for remaining key lines
	ld a, d;							// check for single key
	inc a;								// or no key
	ret z;								// return if so
	cp 40;								// check for shift + alphanum
	ret z;								// return if so
	cp 25;								// check for symbol + alphanum
	ret z;								// return if so
	ld a, e;							// new key value to A
	ld e, d;							// existing key value to E
	ld d, a;							// new key value to D
	cp 24;								// check for shift + symbol
	ret;								// end of subroutine

;	// additional keys scanning subroutine
f_key_scan:
	ld bc, $fc3b;						// Uno register port
	ld a, 4;							// PS/2 scancode port
	out (c), a;							// select port
	inc b;								// Uno data port
	in a, (c);							// read last scancode
	cp $0d;								// less than $0D
	jr c, f_key_found;					// possible F key found

no_f_key:
	cp $83;								// was it F7?
	ret nz;								// return if not
	ld a, 2;							// alter from $83 to 2

f_key_found:
;	cp 0;								// value on port should never be zero
;	jr z, no_f_key;						// so this routine should not be needed
;	cp 2;								// value on port should never be 2
;	jr z, no_f_key;						// so this routine should not be needed
;	cp 8;								// value on port should never be 8
;	jr z, no_f_key;						// so this routine should not be needed

	add a, 39;							// original matrix has 40 keys. 
	ld e, a;							// key value to E
	cp a;								// set zero flag;
	ret;								// return;

;	// keyboard subroutine
keyboard:
	call key_scan;						// get key pair in DE
	call nz, f_key_scan;				// if no main keys pressed, test F-keys
	ret nz;								// return if no key
	ld hl, kstate;						// kstate_0 to HL

k_st_loop:
	bit 7, (hl);						// is set free?
	jr nz, k_ch_set;					// jump if so
	inc hl;								// else
	dec (hl);							// decrease
	dec hl;								// 5 call
	jr nz, k_ch_set;					// counter
	ld (hl), 255;						// then make set free

k_ch_set:
	ld a, l;							// low address to A
	ld l, low kstate_4;					// has second set
	cp l;								// been considered?
	jr nz, k_st_loop;					// jump if not
	call k_test;						// change key to main code
	ret nc;								// return if no key or shift
	ld hl, kstate;						// kstate_0 to HL
	cp (hl);							// jump if match
	jr z, k_repeat;						// including repeat
	ld l, low kstate_4;					// kstate_4 to HL
	cp (hl);							// jump if match
	jr z, k_repeat;						// including repeat
	bit 7, (hl);						// test second set
	jr nz, k_new;						// jump if free
	ld l,  low kstate;					// kstate_0 to HL
	bit 7, (hl);						// test first set
	ret z;								// return if not free

k_new:
	ld e, a;							// code to kstate
	ld (hl), a;							// code to E
	inc hl;								// 5 call counter
	ld (hl), 5;							// reset to 5
	ld a, (repdel);						// repeat delay to A
	inc hl;								// kstate 2/6 to HL
	ld (hl), a;							// store A
	inc hl;								// kstate 3/7 to HL
	push hl;							// stack pointer
	ld l, low flags;					// HL points to flags
	ld d, (hl);							// flags to D
	ld l, low mode;						// HL points to mode
	ld c, (hl);							// mode to C
	call k_meta;						// decode with test for meta and control
	pop hl;								// unstack pointer
	ld (hl), a;							// code to kstate 3/7

k_end:
	ld hl, k_head;						// get address of head pointer
	ld l, (hl);							// to HL
	ld (hl), a;							// code to keyboard buffer
	inc l;								// HL contains next addres in buffer
	ld a, l;							// low byte to A
	and %00111111;						// 32 bytes in circular buffer
	ld (iy - _k_head), a;				// new head pointer to sysvar
	ret;								// end of subroutine

;	// repeating key subroutine
k_repeat:
	inc hl;								// set 5 call counter
	ld (hl), 5;							// to 5
	inc hl;								// point to repdel value
	dec (hl);							// reduce it
	ret nz;								// return if delay not finished
	ld a, (repper);						// repeat period to A
	ld (hl), a;							// store it
	inc hl;								// point to kstate 3/7
	ld a, (hl);							// get code
	jr k_end;							// immediate jump

;	// key test subroutine
k_test:
	ld b, d;							// copy shift byte
	ld a, e;							// move key number
	ld d, 0;							// clear D register
	cp 39;								// shift or no-key?

	ret z;								// return with shift
	cp 54;								// no-key?

	ret nc;								// return if so
	cp 24;								// test for alternate
	jr nz, k_main;						// jump if not
	bit 7, b;							// test for alternate and key
	ret nz;								// return with alternate only

k_main:
	ld hl, kt_main;						// base of table
	add hl, de;							// get offset
	scf;								// signal valid keystroke
	ld a, (hl);							// get code
	ret;								// end of subroutine

k_meta:
	call k_decode;						// get the key in A
	ld hl, mode;						// addres sysvar
	ld c, (hl);							// get mode
	ld (hl), 0;							// set normal mode
	dec c;								// test for meta
	ret m;								// return if normal
	jr z, k_set_7;						// jump if meta mode
	and %10011111;						// clear bit 5 and 6 if control mode

k_set_7:
	or %10000000;						// set high bit
	ret;								// end of subroutine

;	// keyboard decoding subroutine
k_decode:
	ld a, e;							// copy main code

k_decode_1:
	cp 13;								// test for enter;
	jr z, k_enter;						// if so, check for symbol
	cp ' ';								// test for enter;
	jr z, k_space;						// if so, check for symbol
	cp ':';								// jump if digit, return, shift
	jr c, k_digit;						// or alternate
	ld hl, kt_alpha_sym - 'A';			// point to alpha symbol table
	bit 0, b;							// test for alternate
	jr z, k_look_up;					// jump if so
	ld hl, flags2;						// address sysvar
	bit 3, (hl);						// test for caps lock						
	jr z, k_caps;						// jump if not
	xor %00100000;						// toggle bit 6

k_caps:
	inc b;								// test for shift
	ret nz;								// return if not
	xor %00100000;						// toggle bit 6
	ret;								// end of subroutine

k_enter:
	inc b;								// shift or alternate?
	ret z;								// return if not
	bit 5, b;							// shift?
	ret nz;								// return if so
	ld a, ctrl_clr;						// make it CLR key
	ret;								// done

k_space:
	inc b;								// shift or alternate?
	ret z;								// return if not
	bit 5, b;							// shift?
	ret nz;								// return if so
	ld a, ctrl_help;					// make it HELP key
	ret;								// done

k_digit:
	cp '0';								// digit, return, space, shift, alt?
	ret c;								// return if not
	inc b;								// shift or alternate?
	ret z;								// return if not
	bit 5, b;							// shift?
	ld hl, kt_dig_shft - '0';			// set control table
	jr nz, k_look_up;					// jump if shift
	ld hl, kt_dig_sym - '0';			// else use symbol table

k_look_up:
	ld	d, 0;							// clear D
	add	hl, de;							// index table
	ld	a, (hl);						// get character
	ret;								// end of subroutine

;	// flush keyboard buffer subroutine
flush_kb:
	ld hl, k_head;						// point to sysvar;
	ld a, (hl);							// pointer to A
	inc l;								// point to k_tail
	ld (hl), a;							// signal no key
	ret;								// end of subroutine
