;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2024 Source Solutions, Inc.

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
;	// --- PRE-PROCESSOR -------------------------------------------------------
;;
:

;	org $4600;

;	// pre-processor check for a matching token
match_token:
	ex de, hl;							// swap pointers

match_loop:
	ld a, (de);							// next character to A
	call alpha;							// alpha?
	jr nc, match_non_alpha;				// jump if not
;	res 5, a;							// make upper case
	and %11011111;						// make upper case

match_non_alpha:
	bit 7, (hl);						// final character of a token?
	jr nz, match_last;					// jump if so
	cp (hl);							// compare with token
	jr nz, match_exit;					// jump if no match
	inc de;								// next character (in edit line)
	inc hl;								// next character (in token)
	jr match_loop;						// loop until done

match_last:
;	set 7, a;							// set bit 7
	or %10000000;						// set bit 7
	cp (hl);							// set zero flag if matched

match_exit:
	ex de, hl;							// restore pointers
	ret;								// return

;	// skip spaces
skip_space:
	inc hl;								// next character
	ld a, (hl);							// get it in A
	cp ' ';								// is it space?
	jr z, skip_space;					// jump if so
	ret;								// return with first non-space character

;	// make room and insert a comma
make_room_2_comma:
	ld bc, 2;							// two spaces
	jr make_room_any_comma;				// immediate jump

make_room_3_comma:
	ld bc, 3;							// three spaces

make_room_any_comma:
	call make_room_inc_hl;				// make room and incremet HL
	ld (hl), ',';						// insert comma
	inc hl;								// next character
	ret;								// done

;	// make one space the increment HL
make_1_inc_hl:
	ld bc, 1;							// one character

make_room_inc_hl:
	call make_room;						// make space
	inc hl;								// next character
	ret;								// done

;	// remove characters
remove_three:
	call ed_backspace;					// remove a character

remove_two:
	call ed_backspace;					// remove a character
	jp ed_backspace;					// remove a character and exit

;	// substitute STR
sbst_str:
	ld hl, (mem_5_1);					// restore position
	ld (hl), 'S';						// replace
	inc hl;								// three
	ld (hl), 'T';						// characters
	inc hl;								// with
	ld (hl), 'R';						// STR
	ret;								// and return

;	// check for closing parenthesis
close_paren:
	inc hl;								// next character
	ld a, (hl);							// get it to A
	cp ctrl_cr;							// missing close parenthesis
	jr z, pop_hl_exit_pp;				// drop return address and exit
	cp ')';								// close parenthesis
	jr nz, close_paren;					// jump until
	ret;								// found

;	// check for opening parenthesis
open_paren:
	inc hl;								// next character
	ld a, (hl);							// get it in A
	cp '(';								// is it open parenthesis?
	ret z;								// return if so

pop_hl_exit_pp:
	pop hl;								// else drop return addres

;	// restore character and exit
exit_pp:
	ld hl, (mem_5_1);					// restore position
	ld a, (hl);							// restore character
	ret;								// done

;	// check for ELSE without leading colon
colon_else:
	cp ' ';								// is it space?
	ret nz;								// return if not
	dec hl;								// previous character
	ld a, (hl);							// get it
	cp ':';								// colon?
	inc hl;								// current character
	ld a, (hl);							// restore current character
	ret z;								// return if there is already a colon
	ld (mem_5_1), hl;					// store position
	inc hl;								// next character
	push de;							// stack DE
	ld de, tk_ptr_else;					// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	ld hl, (mem_5_1);					// restore position
	ld a, (hl);							// restore character
	ret nz;								// return if no match
	ld (hl), ':';						// insert colon
	ret;								// done

colour:
	push de;							// stack DE
	ld de, tk_ptr_colour;				// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	call z, ed_backspace;				// remove 'U' if match found
	jr exit_pp;							// done

;	// check for FN without trailing space
fn_alpha:
	push de;							// stack DE
	ld de, tk_ptr_fn;					// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jr nz, exit_pp;						// jump if not
	inc hl;								// next character
	ld a, (hl);							// get it in A
	call alpha;							// alpha?
	jp nc, exit_pp;						// jump if not
	call open_paren;					// check for '('
	dec hl;								// back 	
	dec hl;								// two
	ld (hl), tk_fn;						// replace the N with the FN token
	jp ed_backspace;					// remove the F and exit

;	// check for HEX$()
hex_str:
	push de;							// stack DE
	ld de, tk_ptr_hex_str;				// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jr nz, exit_pp;						// jump if not
	call sbst_str;						// substitute STR$
	call close_paren;					// find closing parenthesis
	call make_room_3_comma;				// make three spaces and insert a comma
	ld (hl), '1';						// set
	inc hl;								// base
	ld (hl), '6';						// 16
	jr exit_pp;							// done

;	// check for OCT$()
oct_str:
	push de;							// stack DE
	ld de, tk_ptr_oct_str;				// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jr nz, exit_pp;						// jump if not
	call sbst_str;						// substitute STR$
	call close_paren;					// find closing parenthesis
	call make_room_2_comma;				// make two spaces and insert a comma
	ld (hl), '8';						// base 8
	jr exit_pp;							// done

;	// check for RND with trailing parameter
rnd_param:
	push de;							// stack DE
	ld de, tk_ptr_rnd;					// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jp nz, exit_pp;						// jump if not
	call open_paren;					// check for '('
	inc hl;								// point to number (0 or 1)
	inc hl;								// point to close parenthesis
	inc hl;								// point to next character
	jp remove_three;					// remove the (n))

;	// check for SPACE$(n)
space_str:
	push de;							// stack DE
	ld de, tk_ptr_space_str;			// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jp nz, exit_pp;						// jump if not
	call close_paren;					// find closing parenthesis
	call make_room_3_comma;				// make three spaces and insert a comma
	ld (hl), '3';						// insert decimal '3'
	inc hl;								// next character
	ld (hl), '2';						// innsert decimal '2'
	ld hl, (mem_5_1);					// restore position
	ld (hl), tk_string_str;				// sunbstitute STR$
	inc hl;								// next character
	inc hl;								// skip 'P'
	inc hl;								// skip 'A'
	inc hl;								// skip 'C'
	inc hl;								// skip 'E'
	inc hl;								// skip '$''
	call remove_three;					// remove
	jp remove_two;						// five

;	// check for THEN followed by a number
then_number:
	ld (mem_5_1), hl;					// store position
	push de;							// stack DE
	ld de, tk_ptr_then;					// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jp nz, exit_pp;						// jump if not
	call skip_space;					// skip any trailing spaces
	call numeric;						// digit?
	jp c, exit_pp;						// jump if not
	call make_1_inc_hl;					// make one space
	ld (hl), tk_goto;					// insert a quote mark
	ret;								// done

;	// check for TROFF
troff:
	push de;							// stack DE
	ld de, tk_ptr_troff;				// point to token

try_tron:
	call match_token;					// check for match
	pop de;								// restore DE
	jp nz, exit_pp;						// jump if not

found_trace:
 	ld hl, (mem_5_1);					// restore position
	inc hl;								// point to R
	call ed_backspace;					// delete T
	ld (hl), tk_trace;					// replace it with TRACE
	ret;								// exit to tokenize ON or OFF

;	// check for TRON
tron:
	push de;							// stack DE
	ld de, tk_ptr_tron;					// point to token
	jr try_tron;						// immedaite jump

;	// check for ><
sbst_ne:
	push de;							// stack DE
	ld de, tk_ptr_ne;					// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jp nz, exit_pp;						// jump if not
	ld (hl), tk_ne;						// replace with token
	jp ed_backspace;					// remove previous character and exit

;	// check for =<
sbst_le:
	push de;							// stack DE
	ld de, tk_ptr_le;					// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jp nz, exit_pp;						// jump if not
	ld (hl), tk_le;						// replace with token
	jp ed_backspace;					// remove previous character and exit

;	// check for =>
sbst_ge:
	push de;							// stack DE
	ld de, tk_ptr_ge;					// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jp nz, exit_pp;						// jump if not
	ld (hl), tk_ge;						// replace with token
	jp ed_backspace;					// remove previous character and exit

;	// check for &H
hex:
	push de;							// stack DE
	ld de, tk_ptr_hex;					// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jp nz, exit_pp;						// jump if not
	ld (hl), '$';						// replace with '$'
	jp ed_backspace;					// remove previous character and exit

;	// check for &O
oct:
	push de;							// stack DE
	ld de, tk_ptr_oct;					// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jp nz, exit_pp;						// jump if not
	ld (hl), '@';						// replace with '@'
	jp ed_backspace;					// remove previous character and exit

;	// check for ATN()
atn:
	push de;							// stack DE
	ld de, tk_ptr_atn;					// point to token
	call match_token;					// check for match
	pop de;								// restore DE
	jp nz, exit_pp;						// jump if not
	dec hl;								// back one place						
	call make_1_inc_hl;					// make one space
	ld (hl), 'A';						// insert 'A'
	jp exit_pp;							// done
