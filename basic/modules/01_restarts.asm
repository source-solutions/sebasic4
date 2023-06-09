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

;	// asmdoc comments should be added before the label as follows:

;;
; Short description.
; @author Name of contributing author.
; @deprecated Version deprecated in and replacement module.
; @param HL - Register contents.
; @return Result in register, such as <code>HL</code>.
; @see <a href="www.example.com">External reference</a>.
; @since Version in which module was introduced.
; @throws Error number and description handled by RST 8 routine.
; @version Version in which the module was last udpated. 
;;

;;
;	// --- RESTART ROUTINES ----------------------------------------------------
;;
:

	org $0000;
rst_00:
	di;									// interrupts off
	xor a;								// LD A, 0
	ld bc, paging;						// HOME bank paging (already set by UnoDOS 3)
	out (c), a;							// ROM 0, RAM 0, VIDEO 0, paging enabled

;	org $0005;							// BDOS
;cpm:
;	jp bdos;							// immediate jump

	org $0008;
;;
; error
;;
rst_08:
	ld hl, (ch_add);					// address of current character
	ld (x_ptr), hl;						// to error pointer
	jr error_2;							// then jump


	org $0010;
;;
; print a character
; @see: UnoDOS 3 entry points
;;
rst_10:
	jp print_a_2;						// immediate jump

;	// this is the point where ROM 0 hands control back to ROM 1
	org $0013;
from_rom0:
	nop;								// chance for ROM to settle
	xor a;								// LD A, 0
	jp start_new;						// deal with a cold start


	org $0018;
;;
; collect character
; @see: UnoDOS 3 entry points
;;
rst_18:
jp_get_char:
	ld hl, (ch_add);					// put address of current character
	ld a, (hl);							// in A

	org $001c;
test_char:
	call skip_over;						// check for printable character
	ret nc;								// return if so

	org $0020;
;;
; collect next character
; @see: UnoDOS 3 entry points
;;
rst_20:
	call ch_add_plus_1;					// increment current character address
	jr test_char;						// then jump

	org $0025;
ver_num:
	defb "420";							// version number (example: 4.2.0)

	org $0028;
;;
; calculator
;;
rst_28:
	jp calculate;						// immediate jump

	org $002b;
ident:
	defb "SE";							// SE Basic identifier (here for historical reasons, it doens't stand for anything)

	org $002d;
;;
; make one space
;;
bc_1_space:
	ld bc, 1;							// create one free location in workspace

	org $0030;
;;
; make spaces
; @param BC - number of spaces
;;
rst_30:
	push bc;							// store number of spaces to create
	ld hl, (worksp);					// get address of workspace
	push hl; 							// and store it
	jp reserve;							// then jump

	org $0038;
;;
; maskable interrupt
;;
rst_38:
	push af;							// stack AF (intercepted by divMMC hardware)
	push hl;							// stack HL (return from divMMC ROM)
	ld hl, (maskadd);					// put value of maskadd in HL
	ld a, l;							// test for
	or h;								// zero
	call nz, call_jump;					// call routine if not
	ld hl, frame;						// get current frame
	inc (hl);							// increment it
	ld a, 60;							// has one second elapsed? (change to 50 for 50Hz machines)
	cp (hl);							// test it
	jr nz, key_int;						// jump if no rollover
	ld (hl), 0;							// restart frame counter
	call rollover;						// update first byte of time_t
	jp mask_int_1;						// immedaite jump

;	// error routine
	org $0053;
;;
; error-2
;;
error_2:
	pop hl;								// return location holds error number
	ld l, (hl);							// store in L

	org $0055;
error_3:
	ld (iy + _err_nr), l;				// then copy to err_nr
	ld sp, (err_sp);					// put value of err_sp in SP
	jr error_4;							// then jump

;	// increment counter subroutine
	org $005f;
rollover:
	inc l;								// address next byte of time_t
	inc (hl);							// increment first byte
	ret z;								// return with rollover
	pop af;								// drop return address
	jp key_int;							// immedaite jump

	org $0066;
;;
; non-maskable interrupt
;;
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

;;
; increment CH-ADD
;;
ch_add_plus_1:
	ld hl, (ch_add);					// get current character address

temp_ptr1:
	inc hl;								// increment it

temp_ptr2:
	ld (ch_add), hl;					// set character address

reentry:
	ld a, (hl);							// copy character at current address to A
	ret;								// end of subroutine

;	// error routine continued
error_4:
	ld hl, (x_ptr);						// get error pointer
	ld (k_cur), hl;						// set cursor position
	jp set_stk;							// then jump

;;
; skip over
;;
skip_over:
	cp ' ';								// test for space or higher
	scf;								// set carry flag
	ret z;								// and return if so
	cp 16;								// test for characters 16-31
	ret nc;								// and return if so with carry cleared
	cp ctrl_cr;							// carraige return?
	ret z;								// and return if so
	cp 6;								// test for characters 0-5 (tokens)
	ccf;								// complement carry flag
	ret nc;								// and return if so
	inc hl;								// advance a character

skips:
	scf;								// set carry flag
	ld (ch_add), hl;					// put new character address in CH-ADD
	ret;								// end of subroutine

;	// continuation of maskable interrupt routine
mask_int_1:
	call rollover;						// update second byte of time_t
	call rollover;						// update third byte of time_t
	inc l;								// update fourth byte of time_t
	inc (hl);							// increment fourth byte

key_int:
	push de;							// stack DE
	push bc;							// stack BC
	call keyboard;						// read keypress
	call joystick;						// read joystick
	call mouse;							// read mouse
	pop bc;								// unstack BC
	pop de;								// unstack DC
	pop hl;								// unstack HL
	pop af;								// unstack AF
	ei;									// switch on interrupts
	ret;								// end of subroutine

joystick:
	in a, (stick);						// read joystick
	ld (jstate), a;						// store in system variable
	ret;								// end of subroutine

mouse:
	ld hl, mstate;						// mouse state
	ld bc, mouse_b;						// mouse button
	in a, (c);							// read it
	ld (hl), a;							// store it
	inc l;								// mstate + 1
	inc b;								// mouse x position
	in a, (c);							// read it
	ld (hl), a;							// store it
	inc l;								// mstate + 2
	ld b, $ff;							// mouse y position
	in a, (c);							// read it
	ld (hl), a;							// store it
	ret;								// end of subroutine

;;
; <code>ERROR</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#ERROR" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_error:
	call find_int1;						// get 8-bit integer
	ld l, a;							// error to A
	jr error_3;							// generate error message

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

	// 25 unused bytes
	defs 25, $ff;						// RESERVED for future service calls

	org $00ff
im2:
	defw $0038;							// if IM2 is enabled with I set to 0 it will behave as IM1 (prevents a crash if enabled accidentally)
