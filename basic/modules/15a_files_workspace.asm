;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2022 Source Solutions, Inc.

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
;	// --- FILE HANDLING ROUTINES ----------------------------------------------
;;

; 	// MS-DOS records file dates and times as packed 16-bit values.
;	// An MS-DOS date has the following format:

;	// Bits		Contents
;	// 0–4		Day of the month (1–31).
;	// 5–8		Month (1 = January, 2 = February, and so on).
;	// 9–15		Year offset from 1980 (add 1980 to get the actual year).
 
;	// An MS-DOS time has the following format.

;	// Bits		Contents
;	// 0–4		Second divided by 2.
;	// 5–10		Minute (0–59).
;	// 11–15	Hour (0– 23 on a 24-hour clock).


;	// File commands page out the BASIC ROM.
;	// They must be stored at $4000 or later.

	include "../../boot/os.inc";		// label definitions
	include "../../boot/uno.inc";		// label definitions

;	// service routines

;	// get destination and source path and set pointer in DE and IX
paths_to_de_ix:
	call path_to_ix;					// destination to IX
	push ix;							// stack it
	call path_to_ix;					// source to IX
	pop de;								// restore destination
	ret;								// end of service routine

;	// get path and set pointer in IX
path_to_ix:
	ld hl, (ch_add);					// get current value of CH-ADD
	push hl;							// stack it
	call stk_fetch;						// get parameters
	push de;							// stack start address
	inc bc;								// increase length by one
	rst bc_spaces;						// make space
	pop hl;								// unstack start address
	ld (ch_add), de;					// pointer to CH-ADD
	push de;							// stack it
	call ldir_space;					// copy the string to the workspace (converting spaces to underscores)
	ex de, hl;							// swap pointers
	dec hl;								// last byte of string
	ld (hl), 0;							// replace with zero
	pop ix;								// pointer to CH-ADD
	pop hl;								// get last value
	ld (ch_add), hl;					// and restore CH-ADD

;	// the next two instructions may not be necessary
	ld a, '*';							// use current drive
	and a;								// signal no error (clear carry flag)

	ret;								// end of service routine


;	// block copy converting spaces to underscores
ldir_space:
	ld a, (hl);							// get character
	ldi;								// copy bytes
	cp ' ';								// is it space?
	jr nz, no_space;					// jump if not
	ld a, '_';							// underscore
	dec de;								// back one place
	ld (de), a;							// replace space
	inc de;								// forward one place

no_space:
	ld a, c;							// test count
	or b;								// for zero
	jr nz, ldir_space;					// loop until done
	ret;								// end of service routine


;	// file commands

;;
; <code>NAME</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#NAME" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_name:
	call unstack_z;						// return if checking syntax
	call paths_to_de_ix;				// destination and source paths to buffer
	rst divmmc;							// issue a hookcode
	defb f_rename;						// change folder
	jp c, report_file_not_found;		// jump if error
	or a;								// clear flags
	ret;								// end of command
