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

;	// --- EDITOR ROUTINES -----------------------------------------------------

;	// line editor
	org $0f60;
editor:
	ld hl, (err_sp);					// get current error pointer
	push hl;							// and stack it

ed_again:
	ld hl, ed_error;					// stack return
	push hl;							// address
	ld (err_sp), sp;					// set sysvar to stack pointer

ed_loop:
	call wait_key;						// get a key
	ld hl, ed_loop;						// stack
	push hl;							// return address
	cp key_delete;						// delete?
	jr z, ed_delete;					// jump with delete
	cp ' ';								// printable character?
	jr c, ed_keys;						// jump with control keys

;	// add character subroutine
;	// UnoDOS 3 entry point
	org $0f81
add_char:
	ld hl, (k_cur);						// cursor position to HL
	ld bc, 1;							// one space required
	call make_room;						// make a space

add_ch_1:
	ld (de), a;							// store code in the space
	inc de;								// next
	ld (k_cur), de;						// store new cursor position
	ret;								// end of subroutine

ed_delete:
	ld hl, (k_cur);						// get current cursor
	call ed_right;						// move it right
	ret z;								// return if no character
	jp ed_backspace;					// delete it

ed_f_keys;
	sub $11;							// reduce range (0 to 14)
	ld e, a;							// code
	ld d, 0;							// to DE
	ld hl, ed_f_keys_t;					// offset to table
	add hl, de;							// get entry
	ld e, (hl);							// store in E
	add hl, de;							// address of first character in string

loop_f_keys:
	ld a, (hl);							// get character
	and a;								// test for zero
	ret z;								// return if end of string reached
	inc hl;								// next character
	push hl;							// stack next character address
	call k_end;							// insert character into keyboard buffer
	pop hl;								// unstack next character address
	jr loop_f_keys;						// loop until done

ed_keys:
	cp key_f1;							// function key?
	jr nc, ed_f_keys;					// jump if so
	ld e, a;							// code
	ld d, 0;							// to DE
	ld hl, ed_keys_t;					// offset to table
	add hl, de;							// get entry
	ld e, (hl);							// store in E
	add hl, de;							// address of handling routine
	push hl;							// stack it
	ld hl, (k_cur);						// sysvar to HL
	ret;								// indirect Jump

;	// editing keys table
ed_keys_t:
	defb ed_ins - $;					// $00
	defb ed_clr - $;					// $01
	defb ed_home - $;					// $02
	defb ed_end - $;					// $03
	defb ed_pg_up - $;					// $04
	defb ed_pg_dn - $;					// $05
	defb ed_enter - $;					// $06
	defb ed_tab - $;					// $07
	defb ed_left - $;					// $08
	defb ed_right - $;					// $09
	defb ed_down - $;					// $0a
	defb ed_up - $;						// $0b
	defb ed_backspace - $;				// $0c
	defb ed_enter - $;					// $0d
	defb ed_symbol - $;					// $0e
	defb ed_graph - $;					// $0f
	defb ed_help - $;					// $10

;	// tab editing subroutine
ed_tab:
	ld a, ctrl_ht;						// tab stop

ed_add_char:
	jp add_char;						// immedaite jump

;	// cursor left editing subroutine
ed_left:
	call ed_edge;						// move cursor

ed_cur:
	ld (k_cur), hl;						// set sysvar
	ret;								// end of subroutine

;	// cursor right editing subroutine
ed_right:
	ld a, (hl);							// get current character
	cp ctrl_cr;							// test for carriage return
	ret z;								// return if so
	inc hl;								// advance cursor position
	jr ed_cur;							// immediate jump

;	// cursor down editing subroutine
ed_down:
	call get_cols;						// column width to B

ed_down_1:
	call ed_right;						// move cursr right
	djnz ed_down_1;						// by column width
	ret;								// end of subroutine

;	// cursor up editing subroutine
ed_up:
	ld hl, (e_line);					// sysvar to HL
	ld de, (k_cur);						// sysvar to DE
	and a;								// prepare for subtraction
	sbc hl, de;							// subtract
	call get_cols;						// column width to B
	ld hl, (e_ppc);						// sysvar to HL
	ex de, hl;							// swap pointers

ed_up_1:
	push bc;							// stack count
	call ed_left;						// cursor left
	pop bc;								// unstack count
	djnz ed_up_1;						// loop until done
	ret;								// end of subroutine

;	// backspace editing subroutine
ed_backspace:
	call ed_edge;						// cursor left
	ld bc, 1;							// one character
	jp reclaim_2;						// immediate jump

;	// ignore editing subroutine
ed_ignore:
	call wait_key;						// ignore one key

;	// enter editing subroutine
ed_enter:
	pop hl;								// discard ed_loop
	pop hl;								// and ed_error return addresses

ed_done:
	pop hl;								// unstack old err_sp
	ld (err_sp), hl;					// restore it
	bit 7, (iy + _err_nr);				// any errors?
	ret nz;								// return if not
	ld sp, hl;							// swap pointers
	ret;								// indirect jump

;	// symbol editing subroutine
ed_symbol:
	bit 7, (iy + _flagx);				// input line?
	jr z, ed_enter;						// jump if not

ed_graph:
	jp add_char;						// immediate jump

;	// home editing subroutine
ed_home:
	ld hl, (e_ppc);						// line number to HL
	bit 5, (iy + _flagx);				// test mode
	jr nz, ed_up;						// jump with input
	ld hl, (e_line);					// start of line to HL
	ld (k_cur), hl;						// store it in k_kur
	ret;								// end of subroutine

;	// end editing subroutine
ed_end:
	call ed_right;						// move cursor right
	ret z;								// return if end reached?
	jr ed_end;							// move again

;	// page up editing subroutine
ed_pg_up:
	bit 5, (iy + _flagx);				// input mode?
	ret nz;								// return if so
	ld hl, (e_ppc);						// get current line number
	call line_addr;						// and address
	ex de, hl;							// previous line to DE
	call line_no;						// get it
	ld hl, e_ppc_h;						// sysvar to HL
	call ln_store;						// store line number
	jr ed_list;							// immediate jump

;	// page down editing subroutine
ed_pg_dn:
	bit 5, (iy + _flagx);				// input mode?
	ret nz;								// return if so
	ld hl, e_ppc;						// get current line
	call ln_fetch;						// get number of next line

ed_list:
	call auto_list;						// do listing
	xor a;								// LD A, 0
	jp chan_open;						// open channel K

;	// insert editing subroutine
ed_ins:
	ret;								// FIXME - stub for INSERT key

;	// help editing subrotuine
ed_help:
	ret;								// FIXME - stub for INSERT key

;	// clr editing subroutine
ed_clr:
	ld hl, (e_ppc);						// line number to HL

;	// clear SP subroutine
clear_sp:
	push hl;							// stack pointer to space
	call set_hl;						// DE to first character, HL to last
	dec hl;								// adjust amount
	call reclaim_1;						// reclaim
	ld (k_cur), hl;						// set k_cur
	ld (iy + _mode), 0;					// signal 'K' mode
	pop hl;								// unstack pointer
	ret;								// end of subroutine

;	// edge editing subroutine
ed_edge:
	scf;								// set carry flag
	call set_de;						// DE points to e_line or worksp
	sbc hl, de;							// set carry flag
	add hl, de;							// if cursor is at start of line
	inc hl;								// correct for subtraction
	pop bc;								// discard return address
	ret c;								// return via ed-loop if carry set
	push bc;							// restore return address
	ld c, l;							// cursor address
	ld b, h;							// to BC

ed_edge_1:
	ld l, e;							// next character
	ld h, d;							// address to DE
	inc hl;								// next address
	ld a, (de);							// code to A
	and a;								// prepare for subtraction
	sbc hl, bc;							// clear carry flag when
	add hl, bc;							// updated pointer reaches k_cur
	ex de, hl;							// swap pointers
	jr c, ed_edge_1;					// use updated pointer on next loop
	ret;								// end of subroutine

;	// error editing subroutine
ed_error:
	bit 4, (iy + _flags2);				// channel K?
	jp z, ed_done;						// jump if not
	call bell;							// sound rasp
	jp ed_again;						// immediate jump

;	// keyboard input subroutine
key_input:
	bit 3, (iy + _vdu_flag);			// screen mode changed?
	call nz, ed_copy;					// copy line if so
	and a;								// clear flags
	ld a, (k_head);						// pointer to head of buffer to A
	ld l, a;							// to L
	ld a, (k_tail);						// pointer to tail of buffer to A
	cp l;								// compare pointers
	ret z;								// return with match (no key)

key_input_1:
	ld hl, k_tail;						// get address of tail pointer
	ld l, (hl);							// to HL
	ld a, (hl);							// code to A
	push af;							// stack code
	inc l;								// HL contains next addres in buffer
	ld a, l;							// low byte to A
	and %00111111;						// 32 bytes in circular buffer
	ld (iy - _k_tail), a;				// new tail pointer to sysvar
	bit 5, (iy + _vdu_flag);			// lower display requires clearing?
	call nz, cls_lower;					// if so do it
	pop af;								// unstack code
	cp 16;								// printable character?
	jr nc, key_done2;					// jump if so
	cp 6;								// mode codes and caps lock?
	jr nz, key_mode;					// jump with mode codes
	ld hl, flags2;						// address sysvar
	ld a, %00001000;					// toggle
	xor (hl);							// bit 3
	ld (hl), a;							// of flags
	jr key_flag;						// immediate jump

key_mode:
	cp key_koru;						// lower limit?
	ret c;								// return if so
	sub 13;								// reduce range
	ld hl, mode;						// address system variable
	cp (hl);							// changed?
	ld (hl), a;							// store new mode
	jr nz, key_flag;					// jump if changed
	ld (hl), 0;							// else 'L' mode

key_flag:
	set 3, (iy + _vdu_flag);			// signal possible mode change
	cp a;								// clear carry and set zero flag
	ret;								// and return

key_done2:
	scf;								// set carry flag
	ret;								// end of subroutine

;	// lower screen copying subroutine
ed_copy:
	res 3, (iy + _vdu_flag);			// signal mode not changed
	res 5, (iy + _vdu_flag);			// signal lower screen clearing not required
	ld hl, (sposnl);					// sponsl to HL
	push hl;							// stack it
	ld hl, (err_sp);					// err_sp to HL
	push hl;							// stack it
	ld hl, ed_full;						// address ed_full
	push hl;							// stack it
	ld (err_sp), sp;					// make err_sp point to ed_full
	ld hl, (echo_e);					// echo_e to HL
	push hl;							// stack it
	scf;								// set carry flag
	call set_de;						// HL to start and DE to end
	ex de, hl;							// swap pointers
	call out_line2;						// print line
	ex de, hl;							// swap pointers
	call out_curs;						// print cursor
	ld hl, (sposnl);					// sposnl to HL
	ex (sp), hl;						// swap with echo-e
	ex de, hl;							// swap pointers

ed_blank:
	ld a, (sposnl_h);					// current line number to A
	sub d;								// subtract old line number
	jr c, ed_c_done;					// jump if no blanking required
	jr nz, ed_spaces;					// jump if not on same line
	ld a, e;							// old column number to A
	sub (iy + _sposnl);					// subtract new column number
	jr nc, ed_c_done;					// jump if no spaces required

ed_spaces:
	ld a, ' ';							// space
	push de;							// stack old values
	call print_out;						// print it
	pop de;								// unstack old values
	jr ed_blank;						// immediate jump

ed_full:
	call bell;							// sound rasp
	ld de, (sposnl);					// sposnl to DE
	jr ed_c_end;						// immediate jump

ed_c_done:
	pop de;								// unstack new position value
	pop hl;								// unstack error address

ed_c_end:
	pop hl;								// unstack old err_sp
	ld (err_sp), hl;					// store it
	pop bc;								// unstack old sposnl
	push de;							// unstack new position values
	call cl_set;						// set sysvars
	pop hl;								// unstack old sposnl
	ld (echo_e), hl;					// store it in echo_e
	ld (iy + _x_ptr_h), 0;				// clear x_ptr
	ret;								// end of subroutine

;	// set HL subroutine
set_hl:
	ld hl, (worksp);					// HL to last location
	dec hl;								// of editing area
	and a;								// clear carry flag

;	// set DE subroutine
set_de:
	ld de, (e_line);					// start of editing area to DE
	bit 5, (iy + _flagx);				// edit mode?
	ret z;								// return if so
	ld de, (worksp);					// worksp to DE
	ret c;								// return if intended
	ld hl, (stkbot);					// stkbot to HL
	ret;								// end of subroutine

get_cols:
	ld b, 80;							// assume 80 columns
	bit 1, (iy + _flags2);				// test for 40 column mode
	ret z;								// return if not
	ld b, 40;							// 40 columns
	ret;								// done

;	// remove floating point subroutine
;	// UnoDOS 3 entry point
	org $11a7
remove_fp:
	ld a, (hl);							// get character
	cp number_mark;						// hidden number marker
	ld bc, 6;							// six locations 
	call z, reclaim_2;					// recliam if so
	ld a, (hl);							// get character
	inc hl;								// next
	cp ctrl_cr;							// carriage return?
	jr nz, remove_fp;					// jump if not
	ret;								// end of subroutine

