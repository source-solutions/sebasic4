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

	org $0000;
;start
	di;									// interrupts off
	xor a;								// LD A, 0
	ld bc, paging;						// HOME bank paging
	out (c), a;							// ROM 0, RAM 0, VIDEO 0, paging enabled
	nop;								// enter ROM 0 beofer hitting RST 8 trap

	org $0008;
;error
	ld hl, (ch_add);					// address of current character
	ld (x_ptr), hl;						// to error pointer
	jr error_2;							// then jump

;	// UnoDOS 3 entry point
	org $0010;
;print_a
	jp print_a_2;						// immediate jump

;	// this is the point where ROM 0 hands control back to ROM 1
	org $0013;
from_rom0:
	nop;								// chance for ROM to settle
	xor a;								// LD A, 0
	jp start_new;						// deal with a cold start

;	// UnoDOS 3 entry point
	org $0018;
;get_char
jp_get_char:
	ld hl, (ch_add);					// put address of current character
	ld a, (hl);							// in A

	org $001c;
test_char:
	call skip_over;						// check for printable character
	ret nc;								// return if so

;	// UnoDOS 3 entry point
	org $0020;
;next_char
	call ch_add_plus_1;					// increment current character address
	jr test_char;						// then jump

	org $0025;
ver_num:
	defb "420";							// version number (example: 4.2.0)

	org $0028;
;calc
	jp calculate;						// immediate jump

	org $002b;
ident:
	defb "SE";							// SE Basic identifier (here for historical reasons, it doens't stand for anything)

	org $002d;
bc_1_space:
	ld bc, 1;							// create one free location in workspace

	org $0030;
;bc_spaces
	push bc;							// store number of spaces to create
	ld hl, (worksp);					// get address of workspace
	push hl; 							// and store it
	jp reserve;							// then jump

	org $0038;
;mask_int;	
	push af;							// stack AF (intercepted by divMMC hardware)
	push hl;							// stack HL (return from divMMC ROM)
	ld hl, frame;						// get current frame
	inc (hl);							// increment it
	ld a, 60;							// has one second elapsed? (change to 50 for 50Hz machines)
	cp (hl);							// test it
	jr nz, user_im1;					// jump if no rollover
	ld (hl), 0;							// restart frame counter
	call rollover;						// update first byte of time_t
	call rollover;						// update second byte of time_t
	call rollover;						// update third byte of time_t
	inc l;								// update fourth byte of time_t
	inc (hl);							// increment fourth byte
	jp user_im1;						// test for user IM1 routine

	org $0053;
error_2:
	pop hl;								// return location holds error number
	ld l, (hl);							// store in L

	org $0055;
error_3:
	ld (iy + _err_nr), l;				// then copy to err_nr
	ld sp, (err_sp);					// put value of err_sp in SP
	jp set_stk;							// then jump

	org $005f;
rollover:
	inc l;								// address next byte of time_t
	inc (hl);							// increment first byte
	ret z;								// return with rollover
	pop af;								// drop return address
	jp user_im1;						// immedaite jump

	org $0066;
nmi:
	push hl;							// stack HL 
	push af;							// stack AF
	ld hl, (nmiadd);					// put value of nmiadd in HL
	ld a, l;							// test for
	or h;								// zero
	jr z, no_nmi;						// return if so

call_jump:
	jp (hl);							// jump to address in HL

no_nmi:
	pop af;								// unstack AF
	pop hl;								// unstack HL
	retn;								// end of nmi

ch_add_plus_1:
	ld hl, (ch_add);					// get current character address

temp_ptr1:
	inc hl;								// increment it

temp_ptr2:
	ld (ch_add), hl;					// store it
	ld a, (hl);							// copy character at current address to A
	ret;								// end of ch_add_plus_1

skip_over:
	cp ' ';								// test for space or higher
	scf;								// set carry flag
	ret z;								// and return if so
	cp 16;								// test for characters 16-31
	ret nc;								// and return if so with carry cleared
	cp ctrl_enter;						// test for enter
	ret z;								// and return if so
	cp 6;								// test for characters 0-5 (tokens)
	ccf;								// complement carry flag
	ret nc;								// and return if so
	inc hl;								// advance a character

skips:
	scf;								// set carry flag
	ld (ch_add), hl;					// put new character address in ch_add
	ret;								// end of skip_over

user_im1:
	ld hl, (maskadd);					// put value of maskadd in HL
	ld a, l;							// test for
	or h;								// zero
	call nz, call_jump;					// call routine if not

key_int:
	push de;							// stack DE
	push bc;							// stack BC
	call keyboard;						// read keypress
	pop bc;								// unstack BC
	pop de;								// unstack DC
	pop hl;								// unstack HL
	pop af;								// unstack AF
	ei;									// switch on interrupts
	ret;								// end of maskamask_int
