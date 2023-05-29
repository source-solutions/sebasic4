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

;	// addresses $3d00 to $3fff are trapped by the divIDE / divMMC hardware
;	// these addresses must not contain code or when the PC is in this range, paging will take place.

;;
;	// --- MESSAGES ------------------------------------------------------------
;;
:

;	// A total of 608 bytes are allocated for localized messages

    org $58a0

;	// used in 06_screen_80
scrl_mssg:
	defb "Scroll?", 0;

;	// padding for translation
	org scrl_mssg + 12

sp_in_sp:
	defb " in ", 0;

ready:
	defb "Ready", 0;

;	// padding for localization
	org ready + 13

;	// used in 08_executive
rpt_mesgs:
	ok equ $ff;
	defb "Ok", 0;						// code 255
	msg_break equ $00;
	defb "Break", 0;					// code 0
	next_without_for equ $01;
	defb "NEXT without FOR", 0;			// code 1
	syntax_error equ $02;
	defb "Syntax error", 0;				// code 2
	return_without_gosub equ $03;
	defb "RETURN without GOSUB", 0;		// code 3
	out_of_data equ $04;
	defb "Out of DATA", 0;				// code 4
	illegal_function_call equ $05;
	defb "Illegal function call", 0;	// code 5
	overflow equ $06;
	defb "Overflow", 0;+				// code 6
	out_of_memory equ $07;
	defb "Out of memory", 0;			// code 7
	undefined_line_number equ $08;
	defb "Undefined line number", 0;	// code 8
	subscript_out_of_range equ $09;
	defb "Subscript out of range", 0;	// code 9
	undefined_variable equ $0a;
	defb "Undefined variable", 0;		// no equivalent
	address_out_of_range equ $0b;
	defb "Address out of range", 0;		// FIXME - NOT USED
	statement_missing equ $0c;
	defb "Statement missing", 0;		// no equivalent
	type_mismatch equ $0d;
	defb "Type mismatch", 0;			// code 13
	out_of_screen equ $0e;
	defb "Out of screen", 0;			// no equivalent
	bad_io_device equ $0f;
	defb "Bad I/O device", 0;			// no equivalent
	undefined_stream equ $10;
	defb "Undefined stream", 0;			// no equivalent
	undefined_channel equ $11;
	defb "Undefined channel", 0;		// no equivalent
	undefined_user_function equ $12;
	defb "Undefined user function", 0;	// code 18
	line_buffer_overflow equ $13;
	defb "Line buffer overflow", 0;		// code 23
	for_without_next equ $14;
	defb "FOR without NEXT", 0;			// code 26
	while_without_wend equ $15;
	defb "WHILE without WEND", 0;		// code 29
	wend_without_while equ $16;
	defb "WEND without WHILE", 0;		// code 30
	file_not_found equ $17;
	defb "File not found", 0;			// code 53
	input_past_end equ $18;
	defb "Input past end", 0;			// code 62
	path_not_found equ $19;
	defb "Path not found", 0;			// code 76
