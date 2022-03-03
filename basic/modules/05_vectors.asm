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

;	// --- VECTOR TABLE ---------------------------------------------------------

;	// PC must not hit $04c6 (load trap) or $0562 (save trap)

;	org $04c6;
;load_trap:
;	ret;								// must never call this address

;	org $0562;
;save_trap:
;	ret;								// must never call this address

;	// VECTOR table of addresses
	org $04c4;

;	// UnoDOS 3 entry points (these addresses should never change)
;	// FIXME: as these are fixed addresses they can be replaced later on
;	// but provide a useful check that these points have not moved
	jp print_a_2;						// RST $10 - print character in A ($04c6 must never be called)
	jp jp_get_char;						// RST $18 - get character 
	jp $0020;							// RST $20 - next character
	jp reentry;							// IF1 reentry point
	jp cls_lower;						// clear lower screen
	jp add_char;						// add character
	jp remove_fp;						// remove floating point from line
	jp chan_open;						// open a channel
	jp set_min;							// set up workspace
	jp set_work;						// clear workspace
	jp line_addr;						// get line address
	jp each_stmt;						// find each statement
	jp e_line_no;						// get edit line
	jp expt_exp;						// expect string expression
	jp pr_st_end;						// test for carriage return or colon
	jp syntax_z;						// checking syntax test 
	jp stk_fetch;						// stack fetch

	jp $ffff;							//
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							//
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							//
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							//
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $ffff;							// 
	jp $c900;							// ($0562 must never be called)

;	// permits extension of vector table if required
