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


;	// file system variables

	handle		equ mem_0_1;			// (iy - $59)
	f_stats		equ handle + 1;			// (iy - $5a)
	drive		equ f_stats;			// (iy - $5a)
	device		equ drive + 1;			// (iy - $5b)
	f_attr		equ device + 1;			// (iy - $5c)
	f_time		equ f_attr + 1;			// (iy - $5d)
	f_date		equ f_time + 2;			// (iy - $5f)
	f_size		equ f_date + 2;			// (iy - $61)
	f_addr		equ f_size + 4;			// (iy - $65)
	handle_1	equ f_addr + 2;			// (iy - $67)


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
	or a;								// clear flags
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


;	// file service routines

;	// handle AUTOEXEC.BAS
autoexec:
	ld ix, autoexec_bas;				// path to AUTOEXEC.BAS
	call f_open_r_exists;				// open file if it exists
	ret c;								// return if file not found
	ld (handle), a;						// store file handle in membot + 1
	ld hl, auto_run;					// pointer to macro 'RUN <RETURN>'
	call loop_f_keys;					// insert it
	jp load_t2;							// do LOAD "AUTOEXEC.BAS","T":RUN

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
	call f_open_common;					// open file
	jr c, open_file_err;				// jump if error
	pop de;								// unstack end of channel descriptor
	ld (de), a;							// file descriptor
	ld (membot + 1), a;					// store a copy of the file handle for pseudo-append
	dec de;								// decrement DE
	ld hl, file_chan + 4;				// HL = service routines' end
	ld bc, 5;							// copy 5 bytes
	lddr;								// do the copying
	ld hl, (chans);						// HL = channel descriptor area
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
	jp c_chdir_1;						// immediate jump


;	// file open subroutines (IX must point to an ASCIIZ path on entry)
f_open_w_create:
	ld b, fa_write | fa_open_al;		// create or open for writing if file exists
	jr f_open_common;					// immediate jump

f_open_r_exists:
	ld b, fa_read | fa_open_ex;			// open for reading if file exists

f_open_common:
;	// the next two instructions may be unnecessary, but putting them here avoids duplication
  	ld a, '*';							// use current drive
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
    ret;                                // done

f_open_read_ex:
	call f_open_r_exists;				// open file for reading if it exists
	jr f_open_ret;						// immediate jump

f_open_write_al:
	call f_open_w_create;				// open file for writing if it exists else create it

f_open_ret:
	jr c, report_file_not_found;		// jump if error
	ld (handle), a;						// store handle in sysvar
	ret;								// end of subroutine

;	// file read / write subroutines (IX must point to an ASCIIZ path, BC is file size on entry)

;	// open a file for appending (path in IX)
;	// append is not supported at the OS level - this is a workaround
f_append:
	push ix;							// save file path for later
	ld de, tmp_file;					// path to temporary file
	rst divmmc;							// issue a hookcode
	defb f_rename;						// rename original file to TMP.$$
	jr c, report_file_not_found;		// jump if source file not found
	pop ix;								// retrieve file path
	ld b, fa_write | fa_open_al;		// create replcement file for writing
	call open_file;						// open the file
	ld ix, tmp_file;					// open temporary file
	call f_open_r_exists;				// open it for reading
	ld (handle_1), a;					// store handle
	call append_loop;					// copy original contents
	ld a, (handle_1);					// get handle
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
	ld ix, tmp_file;					// path to temporary file
	rst divmmc;							// issue a hookcode
	defb f_unlink;						// delete temporary file
	pop hl;								// equivalent of open_end
	ret;								// done

append_loop:
	ld a, (handle_1);					// get handle
	ld ix, membot;						// write byte to membot
	ld bc, 1;							// read one byte
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_read;						// read a byte
	ld a, c;							// test for
	or b;								// zero
	ret z;								// return if no more bytes read
	ld a, (membot + 1);					// get file handle
	ld ix, membot;						// character is in membot
	ld bc, 1;							// one byte to write
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_write;						// write a byte
	jr append_loop;						// loop until done

f_write_out:
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_write;						// change folder
	jr c, report_file_not_found;		// jump if error
	ld a, (handle);						// restore handle from sysvar
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
	jr c, report_file_not_found;		// jump if error
	or a;								// clear flags
	ret;								// done

f_read_in:
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_read;						// read a byte
	jr c, report_file_not_found;		// jump if error
	ld a, (handle);						// restore handle (membot + 1)
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
	jr c, report_file_not_found;		// jump if error
  	or a;								// else return
 	ret;								// to BASIC

f_get_stats:
	ld ix, f_stats;						// buffer for file stats
	rst divmmc;							// issue a hookcode
	defb f_fstat;						// get file stats
	ret nc;								// return if no error

report_file_not_found:
	rst error;							// else
	defb file_not_found;				// error


;	// file commands

;;
; <code>BLOAD</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#BLOAD" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_bload:
	call unstack_z;						// return if checking syntax
	call find_int2;						// get address
	ld (f_addr), bc;					// store it
	call path_to_ix;					// path to buffer
	call f_open_read_ex;				// open file for reading
	call f_get_stats;					// get binary length
	ld a, (handle);						// restore handle (membot + 1)
	ld bc, (f_size);					// get length
	ld ix, (f_addr);					// get address
	jr f_read_in;						// load binary

;;
; <code>BSAVE</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#BSAVE" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_bsave:
	call unstack_z;						// return if checking syntax
	call find_int2;						// get length
	ld (f_size), bc;					// store it
	call find_int2;						// get address
	ld (f_addr), bc;					// store it
	call path_to_ix;					// path to buffer
	call f_open_write_al;				// open file for writing
	ld ix, (f_addr);					// start to IX
	ld bc, (f_size);					// length to BC
	jr f_write_out;						// save binary

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
	jr c, report_file_not_found;		// jump if error
	or a;								// clear flags
	ret;								// done

;;
; <code>LOAD</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#LOAD" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_load:
	rst get_char;						// get character
	cp ',';								// test for comma
	jr nz, load_1;						// end of syntax checking if not
	call prog_mode;						// get program mode
	cp 'T';								// test for 'T' (tokenized)
	jr z, load_t;						// jump if so
	cp 'R';								// test for 'R' (RUN)
	call nz, mode_error;				// jump if not
	call check_end;						// end of syntax checking
	call unstack_z;						// checking syntax?
	ld hl, auto_run;					// pointer to macro 'RUN <RETURN>'
	call loop_f_keys;					// insert it
	jr load_3;							// immediate jump

prog_mode:
	rst next_char;						// next character
	call expt_exp;						// expect string expression
	call check_end;						// end of syntax checking
	call unstack_z;						// checking syntax?
	call stk_fetch;						// get parameters
	ld a, c;							// letter
	or b;								// provided?
	jr nz, prog_mode_1;					// jump if so

mode_error:
	pop hl;								// drop return address (FIXME - is this actually necessary?)
	rst error;							// else
	defb syntax_error;					// error

prog_mode_1:
	dec bc;								// reduce length
	ld a, c;							// single
	or b;								// character?
	jr nz, mode_error;					// error if not
	ld a, (de);							// get first character
	and %11011111;						// make upper case
	ret;								// end of subroutine

load_t:
	call check_end;						// end of syntax checking
	call unstack_z;						// return if checking syntax
	call path_to_ix;					// path to buffer

load_t1:
	call f_open_read_ex;				// open file for reading

load_t2:
	call f_get_stats;					// get program length

;	// remove garbage
	ld de, (prog);						// start of program to DE
	call var_end_hl;					// varaibles end marker location to HL
	call reclaim_1;						// reclaim varibales area

;	// make space
	ld bc, (f_size);					// length of data to BC
	push hl;							// save PROG
	push bc;							// save length
	call make_room;						// make space for data

;	// load program
	ld a, (handle);						// restore handle
	pop bc;								// restore length
	pop ix;								// restore PROG

	call f_read_in;						// load program

;	// stabilize BASIC
	call var_end_hl;					// varaibles end marker location to HL
	ld (vars), hl;						// set up varaibles
	dec hl;								// 
	ld (datadd), hl;					// set up data add pointer
	rst error;							// clear error
	defb ok;							// done

load_1:
	call check_end;						// end of syntax checking
	call unstack_z;						// checking syntax?

load_3:
	call open_load_merge;				// call common code

load_4:
	ld hl, (vars);						// end of BASIC to HL
	ld de, (prog);						// start of program to DE
	call reclaim_1;						// reclaim BASIC program

nextln:
	call set_min;						// clear all work areas and calculator stack
	ld a, $ff;							// channel W
	call chan_open;						// select channel

copyln:
	call f_getc;						// 
	jr nz, load_end;					// jump if not
	cp ctrl_lf;							// line feed
	jr z, readyln;						// jump if so
	cp ctrl_cr;							// carraige return?
	jr z, readyln;						// jump if so
	rst print_a;						// print character
	jr copyln;							// immedaite jump

open_load_merge:
	call path_to_ix;					// get path in IX
	call f_open_r_exists;				// open file

report_bad_io_dev3:
	jp c, report_bad_io_dev;			// jump with error
	ld (handle), a;						// store file handle in membot + 1
	ret;								// done

readyln:
	ld hl, (membot);					// address of membot to HL
	push hl;							// stack HL
	call tokenizer_0;					// tokenize line
	ld hl, (err_sp);					// error stack pointer to HL
	push hl;							// stack HL
	ld hl, scan_err;					// scan error pointer to HL
	push hl;							// stack HL
	ld (err_sp), sp;					// stack pointer to error stack
	call line_scan;						// scan line
	pop hl;								// unstack HL

scan_err:
	pop hl;								// unstack HL
	ld (err_sp), hl;					// scan error to error stack
	ld hl, (e_line);					// edit line to HL
	ld (ch_add), hl;					// set character address
	call e_line_no;						// convert line number
	ld a, c;							// test for
	or b;								// zero
	call nz, add_line;					// add line if not
	pop hl;								// unstack HL
	ld (membot), hl;					// restore MEMBOT
	jr nextln;							// immedaite jump

load_end:
	ld a, (handle);						// get file handle (membot + 1)
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
	jr c, report_bad_io_dev3;			// jump with error
	rst error;							// else
	defb ok;							// clear error

f_getc:
	ld a, (handle);						// get file handle (membot + 1)
	ld ix, membot;						// MEMBOT to IX
	ld bc, 1;							// one byte
	rst divmmc;							// issue a hookcode
	defb f_read;						// read a byte

f_getc_err:
	jr c, report_bad_io_dev3;			// jump with error
	dec bc;								// reduce count
	ld a, c;							// test for
	or b;								// zero
	ret nz;								// return if not
	ld a, (membot);						// store value in MEMBOT
	ret;								// done

;;
; <code>MERGE</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#MERGE" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_merge:
	call unstack_z;						// checking syntax?
	call open_load_merge;				// call common code
	jr nextln;							// immedaite jump

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
	jp chk_path_error;					// test for error

;;
; <code>NAME</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#NAME" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_name:
	call unstack_z;						// return if checking syntax
	call paths_to_de_ix;				// destination and source paths to buffer
	rst divmmc;							// issue a hookcode
	defb f_rename;						// change filename
	jp c, report_file_not_found;		// jump if error
	or a;								// clear flags
	ret;								// end of command

;;
; <code>OLD</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#OLD" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_old:
	call unstack_z;						// return if checking syntax
	ld ix, old_bas_path;				// pointer to path
	jp load_t1;							// immedaite jump

f_save_old:
	ld ix, old_bas_path;				// path to old.bas
	ld a, '*';							// use current drive
	rst divmmc;							// issue a hookcode
	defb f_unlink;						// delete file if it exists

	ld ix, rootpath;					// go to root
	ld a, '*';							// use current drive
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder

	ld ix, sys_folder;					// ASCIIZ system
	ld a, '*';							// use current drive
	rst divmmc;							// issue a hookcode
	defb f_mkdir;						// create folder

	ld ix, sys_folder;					// ASCIIZ system
	ld a, '*';							// use current drive
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder

	ld ix, tmp_folder;					// ASCIIZ temp
	ld a, '*';							// use current drive
	rst divmmc;							// issue a hookcode
	defb f_mkdir;						// create folder

	ld ix, rootpath;					// go to root
	ld a, '*';							// use current drive
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder

	ld ix, old_bas_path;				// pointer to path
	jp save_t1;							// immediate jump

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
	jp chk_path_error;					// test for error

;;
; <code>SAVE</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#SAVE" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_save:
	rst get_char;						// get character
	cp ',';								// test for comma
	jr nz, save_1;						// end of syntax checking if not
	call prog_mode;						// get program mode
	cp 'T';								// test for 'T' (tokenized)
	call nz, mode_error;				// jump if not

save_t:
	call unstack_z;						// return if checking syntax
	call path_to_ix;					// get path in IX

save_t1:
	call f_open_write_al;				// open file for writing
	ld hl, (vars);						// end of BASIC to HL
	ld de, (prog);						// start of program to DE
	sbc hl, de;							// get program length
	ld ixh, d;							// start of BASIC to
	ld ixl, e;							// IX
	ld c, l;							// length of BASIC to
	ld b, h;							// BC
	jp f_write_out;						// save program

save_1:
	call unstack_z;						// return if checking syntax
	call path_to_ix;					// get path in IX
	ld b, fa_write | fa_open_al;		// B = mode
	call open_file;						// open the file
	ld hl, (chans);						// base address of channel to HL
	add hl, de;							// new channel address
	dec hl;								// last byte of channel
	ld (curchl), hl;					// make it the current channel
	call list_10;						// LIST program to file
	ld ix, (curchl);					// current channel to IX
	call close_file;					// it is, in fact, a jump, as the return address will be popped
