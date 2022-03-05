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

;	// file channels

get_handle:
	ld ix, (curchl);					// get current channel
	ld a, (ix + 5);						// get file handle
	ld bc, 1;							// one byte to transfer
	ret;								// done

file_out:
	ld (membot), a;						// store character to write in membot
	call get_handle;					// get the file descriptor in A
	ld ix, membot;						// get character from membot
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_write;						// write a byte
	jr c, report_bad_io_dev;			// jump if error
;	or a;								// clear flags
	ret;								// done

file_in:
	call get_handle;					// get the file descriptor in A
	ld ix, membot;						// store character in membot
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_read;						// read a byte
	jr c, report_bad_io_dev;			// jump if error
	dec c;								// decrement C (bytes read: should now be zero)
	ld a, (membot);						// character to A
	scf;								// set carry flag
	ret z;								// return if zero flag set
	and a;								// clear carry flag
	ret;								// done


;	// service routines

;	// open a file and attach it to a channel
open_file:
	push bc;							// stack mode
	ld hl, (prog);						// HL = start of BASIC program
	dec hl;								// HL = end of channel descriptor area
	ld bc, 6							// file channel descriptor length
	add ix, bc;							// the filename will get moved by 6 bytes
	call make_room;						// reserve channel descriptor
	pop bc;								// BC = mode
	push de;							// stack end of channel descriptor
   	ld a, '*';							// use current drive
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
	jr c, open_file_err;				// jump if error
	pop de;								// unstack end of channel descriptor
	ld (de), a;							// file descriptor
	dec de;								// decrement DE
	ld hl, file_chan + 4;				// HL = service routines' end
	ld bc, 5;							// copy 5 bytes
	lddr;								// do the copying
	ld hl,(chans);						// HL = channel descriptor area
	ex de, hl;							// DE = chan. desc. area. HL = channel desc. beginning - 1
	sbc hl, de;							// HL = offset - 2
	inc hl;								// HL = offset - 1
	inc hl;								// HL = offset
	ex de, hl;							// DE = offset
	ret;								// done

open_file_err:
	pop de;								// unstack end of channel descriptor
	inc de;								// DE = one past end of channel desc.
	ld hl, -6;							// reclaim 6 bytes
	add hl, de;							// HL = beginning of channel desc.
	ex de, hl;							// HL = one past end, DE = beginning
	call reclaim_1;						// free up the unsuccessful channel descriptor

report_bad_io_dev:
	rst error;							// throw
	defb bad_io_device;					// error

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

;	// the next two instructions may be unnecessary, but putting them here reduces duplication
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

;	// set path to root
init_path:
	ld a, '*';							// use current drive
	ld ix, rootpath;					// default path
	jr c_chdir_1;						// immediate jump

;	// file commands

;;
; <code>CHDIR</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#CHDIR" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws Path not found.
;;
c_chdir:
	call unstack_z;						// return if checking syntax
	call path_to_ix;					// path to buffer

c_chdir_1:
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder

;	// common service routine inlined
chk_path_error:
	jr c, report_path_not_found;		// jump if error
	or a;								// clear flags
	ret;								// done

report_path_not_found:
	rst error;							// throw
	defb path_not_found;				// error

;;
; <code>KILL</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#KILL" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_kill:
	call unstack_z;						// return if checking syntax
	call path_to_ix;					// path to buffer
	rst divmmc;							// issue a hookcode
	defb f_unlink;						// release file
	jp c, report_file_not_found;		// jump if error
	or a;								// clear flags
	ret;								// done

;;
; <code>MKDIR</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#MKDIR" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws Path not found.
;;
c_mkdir:
	call unstack_z;						// return if checking syntax
	call path_to_ix;					// path to buffer
	rst divmmc;							// issue a hookcode
	defb f_mkdir;						// create folder
	jr chk_path_error;					// test for error

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

;;
; <code>RMDIR</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#RMDIR" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws Path not found.
;;
c_rmdir:
	call unstack_z;						// return if checking syntax
	call path_to_ix;					// path to buffer
	rst divmmc;							// issue a hookcode
	defb f_rmdir;						// change folder
	jr chk_path_error;					// test for error
