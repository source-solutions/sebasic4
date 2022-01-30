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

	org $5000;

;;
; <code>RUN</code> command with <i>string</i> parameter
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#RUN" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
run_app:
	call unstack_z;						// return if checking syntax
	call get_dest;						// app name to second buffer
	ld hl, basepath;					// base path
	ld de, $5800;						// point to first buffer
	ld bc, 10;							// byte count
	ldir;								// copy basepath

	ld hl, $5700;						// source
	ld bc, 11;							// maximum name length

copy11:
	ld a, (hl);							// get character
	cp ' ';								// is it a space?
	jr nz, not_space;					// jump if not
	ld a, '_';							// substitute underline
	ld (hl), a;							// write it back

not_space:
	ldi;								// write contents of HL to DE, decrement BC
	ld a, (hl);							// next character
	and a;								// test for zero
	jr z, endcp11;						// jump if end of filename reached
	ld a, c;							// test count
	or b;								// for zero
	jr nz, copy11;						// loop until done

endcp11:
	ld hl, prgpath;						// complete path
	ld bc, 6;							// byte count
	ldir;								// copy it

	ld a, '*';							// use current drive
	ld ix, $5800;						// pointer to path
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder
	call chk_path_error;				// test for error

	ld (oldsp), sp;						// save old SP
	ld sp, $6000;						// lower stack

; get shortname
	ld hl, $5700 - 1;					// start of filename - 1
	ld b, 9;							// maximum name length + 1

skip8:
	inc hl;								// next character
	ld a, (hl);							// get character
	and a;								// test for zero
	jr z, endskp8;						// jump if end of filename reached
	djnz skip8;							// loop until done

endskp8:
	ex de, hl;							// destination to DE
	ld hl, appname;						// tail end of short name
	ld bc, 5;							// five bytes to copy
	ldir;								// copy it
; end of get shortname

	ld ix, $5700;						// default program name
	call open_r_exists;					// open file for reading if it exists

	jr c, app_not_found;				// jump if error
	ld (handle), a;						// store handle

	ld ix, f_stats;						// buffer for file stats
	rst divmmc;							// issue a hookcode
	defb f_fstat;						// get file stats
	jr c, app_not_found;				// jump if error

	ld a, (handle);						// restore handle
	ld bc, (f_size);					// get length
	ld ix, $6000;						// get address

	rst divmmc;							// issue a hookcode
	defb f_read;						// 
	jr c, app_not_found;				// jump if error
	ld a, (handle);						// 
	rst divmmc;							// issue a hookcode
	defb f_close;						// 
	jr c, app_not_found;				// jump if error

	ld a, '*';							// use current drive
	ld ix, resources;					// path to resource fork
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder

	jp $6000;							// run app

app_not_found:
	ld sp, (oldsp);						// restore stack pointer
	jp report_file_not_found;			// and error

open_w_create:
	ld b, fa_write | fa_open_al;		// create or open for writing if file exists
	jr open_f_common;					// immediate jump

open_r_exists:
	ld b, fa_read | fa_open_ex;			// open for reading if file exists

open_f_common:
   	ld a, '*';							// use current drive
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
    ret;                                // done

;	// file subroutines (IX must point to an ASCIIZ path on entry)

f_open_read_ex:
	call open_r_exists;					// open file for reading if it exists
	jr open_f_ret;						// immediate jump

f_open_write_al:
	call open_w_create;					// open file for writing if it exists

open_f_ret:
	jr c, report_file_not_found;		// jump if error
	ld (handle), a;						// store handle in sysvar
	ret;								// end of subroutine

f_write_out:
	rst divmmc;							// issue a hookcode
	defb f_write;						// change folder
	jr c, report_file_not_found;		// jump if error
	ld a, (handle);						// restore handle from sysvar
	rst divmmc;							// issue a hookcode
	defb f_close;						// change folder
	jr c, report_file_not_found;		// jump if error
	or a;								// clear flags
	ret;								// done

f_read_in:
	rst divmmc;							// issue a hookcode
	defb f_read;						// 
	jp c, report_file_not_found;		// jump if error
	ld a, (handle);						// 
	rst divmmc;							// issue a hookcode
	defb f_close;						// 
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

get_path:
	call stk_fetch;						// start to DE, length to BC
	ld a, c;							// test for
	or b;								// empty string
	jp z, report_bad_fn_call;			// error if so
	ex de, hl;							// start to HL
	ld de, $5800;						// destination - FIXME use workspace
	call ldir_space;					// copy it (converting spaces to underscores)
	ex de, hl;							// end to HL
	ld (hl), 0;							// set end marker
	ret;								// done

get_dest:
	call stk_fetch;						// start to DE, length to BC
	ld a, c;							// test for
	or b;								// empty string
	jp z, report_bad_fn_call;			// error if so
	ex de, hl;							// start to HL
	ld de, $5700;						// destination - FIXME use workspace
	call ldir_space;					// copy it (converting spaces to underscores)
	ex de, hl;							// end to HL
	ld (hl), 0;							// set end marker
	ret;								// done


;	// file commands

;run_auto:
;	call load;							// load BASIC program
;	call use_zero;						// use line zero
;	jp run;								// run

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

bload_2:
	call f_open_read_ex;				// open file for reading
	call f_get_stats;					// get binary length

;	// load binary
	ld a, (handle);						// restore handle
	ld bc, (f_size);					// get length
	ld ix, (f_addr);					// get address

	jp f_read_in;						// load binary

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

;	// get binary length
	ld ix, (f_addr);					// start to IX
	ld bc, (f_size);					// length to BC

	jp f_write_out;						// save binary

;;
; <code>COPY</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#COPY" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_copy:
	call unstack_z;						// return if checking syntax
	call get_dest;						// path to buffer (dest)
	call get_path;						// path to buffer (source)
	ld ix, $5800;						// pointer to path
	call f_open_read_ex;				// open file for reading
	call f_get_stats;					// get file length
	ld ix, $5700;						// pointer to path

	call open_w_create;					// open file for writing if it exists

	jp c, report_file_not_found;		// jump if error
	ld (handle_1), a;					// store handle in sysvar

;	// read a byte
copy_bytes:
	ld hl, (f_size);					// byte count
	ld a, h;							// high byte to A
	and a;								// test for zero
	jr z, lt_256;						// jump if less than 256 bytes to copy
	dec h;								// reduce count by 256
	ld (f_size), hl;					// write it back
	ld bc, 256;							// one chunk to copy
	call read_chunk;					// read it
	ld bc, 256;							// one chunk to copy
	call write_chunk;					// write it
	jr copy_bytes;						// loop until done

lt_256:
	ld a, l;							// low byte to A
	and a;								// test for zero
	jr z, copy_close;					// jump if no more bytes to copy
	ld b, 0;							// bytes to copy
	ld c, l;							// to BC
	push bc;							// store amount to copy
	call read_chunk;					// read it
	pop bc;								// restore amount to copy
	call write_chunk;					// write it

copy_close:
;	// close source
	ld a, (handle);						// restore handle from sysvar
	rst divmmc;							// issue a hookcode
	defb f_close;						// change folder
	jp c, report_file_not_found;		// jump if error

;	// close destination
	ld a, (handle_1);					// restore handle from sysvar
	rst divmmc;							// issue a hookcode
	defb f_close;						// change folder
	jp c, report_file_not_found;		// jump if error

 ;	// return to BASIC
	or a;								// clear flags
	ret;								// done

;	// call with bytes to copy in C
read_chunk:
	ld a, (handle);						// get file handle to source
	ld ix, $5700;						// 256 byte buffer
	rst divmmc;							// issue a hookcode
	defb f_read;						// read a byte
	jp c, report_file_not_found;		// jump if error
	ret;								// else done

write_chunk:
	ld a, (handle_1);					// get file handle to destination
	ld ix, $5700;						// 256 byte buffer
	rst divmmc;							// issue a hookcode
	defb f_write;						// write a byte
	jp c, report_file_not_found;		// jump if error
	ret;								// else done

;;
; <code>OLD</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#OLD" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_old:
ifdef no_fs
	ret;
endif
	call unstack_z;						// return if checking syntax
	ld ix, old_bas_path;				// pointer to path
	call f_open_read_ex;				// open file for reading
	call f_get_stats;					// get program length

;	// remove garbage
	ld de, (prog);						// PROG to DE
	call var_end_hl;					// varaibles end marker location to HL
	call reclaim_1;						// reclaim varibales area

;	// make space
	ld bc, (f_size);					// length of data to BC
	push hl;							// save PROG
	push bc;							// save length
	call make_room;						// make space for data

;	// load data
	ld a, (handle);						// restore handle
	pop bc;								// restore length
	pop ix;								// restore PROG

	call f_read_in;						// load data

;	// stabilize BASIC
	call var_end_hl;					// varaibles end marker location to HL
	ld (vars), hl;						// set up varaibles
	dec hl;								// 
	ld (datadd), hl;					// set up data add pointer
	or a;								// clear flags
	ret;								// done	

;;
; <code>NAME</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#NAME" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_name:
	call unstack_z;						// return if checking syntax
;	call paths_to_de_ix;				// destination and source paths to buffer
	call path_to_de;					// path to buffer (dest)
	push de;							// stack destination
	call path_to_ix;					// path to buffer (source)
	pop de;								// unstack destination
	rst divmmc;							// issue a hookcode
	defb f_rename;						// change folder
	jp c, report_file_not_found;		// jump if error
	or a;								// clear flags
	ret;								// done

f_save_old:
ifdef no_fs
	ret;
endif
	call unstack_z;						// return if checking syntax

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
	call f_open_write_al;				// open file for writing

;	// get program length
	ld hl, (vars);						// end of BASIC to HL
	ld de, (prog);						// start of BASIC to DE
	sbc hl, de;							// get program length
	ld ixh, d;							// start of BASIC to
	ld ixl, e;							// IX
	ld c, l;							// length of BASIC to
	ld b, h;							// BC
	jp f_write_out;						// save program

;	// print a folder listing to the main screen
;;
; <code>FILES</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#FILES" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_files:
	rst get_char;						// get character
	cp ctrl_cr;							// carriage return?
	jr z, use_cwd;						// jump if so
	cp ':';								// test for next statement
	jr z, use_cwd;						// jump if so
	call expt_exp;						// expect string expression
	call check_end;						// no further operands
	call get_path;						// path to buffer
	jr open_folder;						// immedaite jump

use_cwd:
	call unstack_z;						// return if checking syntax
	ld a, '*';							// use current drive
	ld ix, $5800;						// folder path buffer
	rst divmmc;							// issue a hookcode
	defb f_getcwd;						// get current working folder
	jp c, report_path_not_found;		// jump if error

open_folder:
;	rst divmmc;							// issue a hookcode
;	defb f_umount;						// unmount drive
;	rst divmmc;							// issue a hookcode
;	defb f_mount;						// remount drive
	ld a, 2;							// select main screen
	call chan_open;						// open channel
	ld b, 0;							// folder access mode (read only?)
	ld a, '*';							// use current drive
	ld ix, $5800;						// folder path buffer
	rst divmmc;							// issue a hookcode
	defb f_opendir;						// open folder
	jp c, report_file_not_found;		// jump if error
	ld (handle), a;						// store folder handle
	ld hl, $5800;						// point to file path

pr_asciiz_uc:
	ld a, (hl);							// get character
	or a;								// null terminator?
	jr z, pr_asciiz_uc_end;				// jump if so
	cp '_';								// underscore?
	ld a, ' ';							// substitute space
	jr z, pr_asciiz_any;				// jump if so
	ld a, (hl);							// restore character

	call alpha;							// test alpha
	jr nc, pr_asciiz_any;				// jump if non-alpha
	res 5,a;							// make upper case

pr_asciiz_any:
	rst print_a;						// else print it
	inc hl;								// next location
	jr pr_asciiz_uc;					// loop until done

pr_asciiz_uc_end:
	ld a, ctrl_cr;						// carriage return
	rst print_a;						// print it

read_folders:
	ld ix, $5700;						// folder buffer
	ld a, (handle);						// get folder handle
	rst divmmc;							// issue a hookcode
	defb f_readdir;						// read a folder entry
	jp c, report_file_not_found;		// jump if read failed
	or a;								// last entry?
	jr z, read_files;					// jump if so
	ld hl, $5700;						// folder buffer
	ld a, (hl);							// attibutes to A
	and %00010000;						// folder?
	jr z, read_folders;					// skip files

;	and %00000010;						// hidden folder?
;	jr nz, read_folders;				// skip hidden folders

	inc hl;								// next location
	ld b, 12;							// count (12 characters)

pr_foldername:
	ld a, (hl);							// get character
	or a;								// null terminator?
	jr nz, printable_chr;				// jump if not
	ld a, ' ';							// else print a space
	jr pr_fn_chr;						// immediate jump

ignore_dot:
	ld a, b;							// test count
	cp 4;								// at the separator?
	ld a, '.';							// restore dot just in case
	jr nz, pr_fn_chr;					// jump if not at the separator
	ld a, (hl);							// get next character

printable_chr:
	call alpha;							// test alpha
	jr nc, pr_ch_na;					// jump if non-alpha
	res 5,a;							// make upper case

pr_ch_na:
	inc hl;								// next location
	cp '.';								// dot?
	jr z, ignore_dot;					// ignore it if so
	cp ' ';								// printable character?
	jr nc, pr_fn_chr;					// jump if so
	ld a, '?';							// else substitute a question mark

pr_fn_chr:
	call print_f;						// print character substituting ' ' for '_'
	djnz pr_foldername;					// loop until all 12 are done
	ld hl, dir_msg;						// else point to "<DIR>   " message

pr_asciiz:
	ld a, (hl);							// get character
	or a;								// null terminator?
	jr z, read_folders;					// jump to do next entry if so
	rst print_a;						// else print it
	inc hl;								// next location
	jr pr_asciiz;						// loop until done

read_files:
	ld a, (handle);						// get folder handle
	rst divmmc;							// issue a hookcode
	defb f_close;						// close it
	ld b, 0;							// folder access mode (read only?)
	ld a, '*';							// use current drive
	ld ix, $5800;						// folder path buffer
	rst divmmc;							// issue a hookcode
	defb f_opendir;						// open folder
	jp c, report_file_not_found;		// jump if error
	ld (handle), a;						// store folder handle

read_files_2:
	ld ix, $5700;						// folder buffer
	ld a, (handle);						// get folder handle
	rst divmmc;							// issue a hookcode
	defb f_readdir;						// read a folder entry
	jp c, report_file_not_found;		// jump if read failed
	or a;								// last entry?
	jr z, last_entry;					// jump if so
	ld hl, $5700;						// folder buffer
	ld a, (hl);							// attibutes to A
	and %00010000;						// folder?
	jr nz, read_files_2;				// skip folders

;	and %00000010;						// hidden file?
;	jr nz, read_files_2;				// skip hidden files

	inc hl;								// next location
	ld b, 12;							// count (12 characters)

;	ld a, (hl);							// get first character
;	cp '_';								// UNIX system file?
;	jr z, read_files_2;					// skip system files

pr_filename:
	ld a, (hl);							// get character
	or a;								// null terminator?
	jr nz, printable_chr_2;				// jump if not
	ld a, ' ';							// else print a space
	jr pr_fn_chr_2;						// immediate jump

printable_chr_2:
	call alpha;							// test alpha
	jr nc, pr_ch_na2;					// jump if non-alpha
	res 5,a;							// make upper case

pr_ch_na2:
	inc hl;								// next location
	cp ' ';								// printable character?
	jr nc, pr_fn_chr_2;					// jump if so
	ld a, '?';							// else substitute a question mark

pr_fn_chr_2:
	call print_f;						// print character substituting ' ' for '_'
	djnz pr_filename;					// loop until all 12 are done
	ld b, 8;							// count

pr_spaces:
	ld a, ' ';							// space
	rst print_a;						// print it
	djnz pr_spaces;						// loop until done
	jr read_files_2;					// do next entry

last_entry:
	ld a, ctrl_cr;						// carriage return
	rst print_a;						// print it
	ld a, (handle);						// get folder handle

do_f_close:
	rst divmmc;							// issue a hookcode
	defb f_close;						// close it
	ret;								// end of subroutine

print_f:
	cp '_';								// test for underscore
	jr nz, no_;							// jump if not
	ld a, ' ';							// substitute space

no_:
	rst print_a;						// print it
	ret;								// return

;	// updates disk commands

;	// delete a file
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

;	// folder commands
init_path:
ifndef no_fs
	ld a, '*';							// use current drive
	ld ix, rootpath;					// default path
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder
	or a;								// clear flags
endif
	ret;								// done

;;
; <code>CHDIR</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#CHDIR" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws Path not found.
;;
c_chdir:
	call unstack_z;						// return if checking syntax
	call path_to_ix;					// path to buffer
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder
	jr chk_path_error;					// test for error

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
; <code>RMDIR</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#RMDIR" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws Path not found.
;;
c_rmdir:
	call unstack_z;						// return if checking syntax
	call path_to_ix;					// path to buffer
	rst divmmc;							// issue a hookcode
	defb f_rmdir;						// change folder

chk_path_error:
	jr c, report_path_not_found;		// jump if error
	or a;								// clear flags
	ret;								// done

report_path_not_found:
	rst error;							// 
	defb path_not_found;				// 

;	// copy path to workspace
;paths_to_de_ix:
;	call path_to_de;					// destination to DE
;	push de;							// stack it
;	call path_to_ix;					// source to IX
;	pop de;								// restore destination
;	ret;								// done

path_to_ix:
	ld hl, (ch_add);					// get current value of ch-add
	push hl;							// stack it
	call stk_fetch;						// get parameters
	push de;							// stack start address
	inc bc;								// increase length by one
	rst bc_spaces;						// make space
	pop hl;								// unstack start address
	ld (ch_add), de;					// pointer to ch_add
	push de;							// stack it
	call ldir_space;					// copy the string to the workspace (converting spaces to underscores)
	ex de, hl;							// swap pointers
	dec hl;								// last byte of string
	ld (hl), 0;							// replace with zero
	pop ix;								// pointer to ch_add
	pop hl;								// get last value
	ld (ch_add), hl;					// and restore ch_add
	ld a, '*';							// use current drive
	ret;								// done

path_to_de:
	ld hl, (ch_add);					// get current value of ch-add
	push hl;							// stack it
	call stk_fetch;						// get parameters
	push de;							// stack start address
	inc bc;								// increase length by one
	rst bc_spaces;						// make space
	pop hl;								// unstack start address
	ld (ch_add), de;					// pointer to ch_add
	push de;							// stack it
	call ldir_space;					// copy the string to the workspace (converting spaces to underscores)
	ex de, hl;							// swap pointers
	dec hl;								// last byte of string
	ld (hl), 0;							// replace with zero
	pop de;								// pointer to ch_add
	pop hl;								// get last value
	ld (ch_add), hl;					// and restore ch_add
	ret;								// done

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
	ret;

;	// file channels
get_handle:
	ld ix, (curchl);					// get current channel
	ld a, (ix + 5);						// get file handle
	ld bc, 1;							// one byte to transfer
	ret;								// done

file_in:
	call get_handle;					// get the file descriptor in A
	ld ix, membot;						// store character in membot
	rst divmmc;							// issue a hookcode
	defb f_read;						// read a byte
	jr c, report_bad_io_dev2;			// jump if error
	dec c;								// decrement C (bytes read: should now be zero)
	ld a, (membot);						// character to A
	scf;								// set carry flag
	ret z;								// return if zero flag set
	and a;								// clear carry flag
	ret;								// done

file_out:
	ld (membot), a;						// store character to write in membot
	call get_handle;					// get the file descriptor in A
	ld ix, membot;						// get character from membot
	rst divmmc;							// issue a hookcode
	defb f_write;						// write a byte
	jr c, report_bad_io_dev2;			// jump if error
;	or a;								// clear flags
	ret;								// done

file_sr:
	defw	file_out;					// 
	defw	file_in;					// 
	defb	'F';						// 

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
	dec de;								// 
	ld hl, file_sr + 4;					// HL = service routines' end
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

report_bad_io_dev2:
	rst error;							// 
	defb bad_io_device;					// report error

f_length:
	ld ix, f_stats;						// buffer for file stats
	rst divmmc;							// issue a hookcode
	defb f_fstat;						// get file stats
	ret;								// done

seek_f:
	rst divmmc;							// issue a hookcode
	defb f_seek;						// seek to position in BCDE
	ret;								// done

;;
; <code>MERGE</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#MERGE" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_merge:
	call unstack_z;						// 
	call open_load_merge;				// 
	jr nextln;							// 

;;
; <code>LOAD</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#LOAD" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_load:
	call unstack_z;						// 
	call open_load_merge;				// 

	ld de, (prog);						// 
	ld hl, (vars);						// 
	call reclaim_1;						// reclaim BASIC program

nextln:
	call set_min;						// 
	ld a, $ff;							// 
	call chan_open;						// 

copyln:
	call f_getc;						// 
	jr nz, aload_end;					// 
	cp $0a;								// 
	jr z, readyln;						// 
	cp $0d;								// 
	jr z, readyln;						// 
	rst print_a;						// 
	jr copyln;							// 

open_load_merge:
	call path_to_ix;					// 
	ld b, fa_read;						// 
	rst divmmc;							// 
	defb f_open;						// 

report_bad_io_dev3:
	jr c, report_bad_io_dev2;			// 
	ld (membot + 1), a;					// 
	ret;								// 

readyln:
	ld hl, (membot);					// 
	push hl;							// 
	call tokenizer_0;					// 
	ld hl, (err_sp);					// 
	push hl;							// 
	ld hl, scan_err;					// 
	push hl;							// 
	ld (err_sp), sp;					// 
	call line_scan;						// 
	pop hl;								// 

scan_err:
	pop hl;								// 
	ld (err_sp), hl;					// 
	ld hl, (e_line);					// 
	ld (ch_add), hl;					// 
	call e_line_no;						// 
	ld a, c;							// 
	or b;								// 
	call nz, add_line;					// 
	pop hl;								// 
	ld (membot), hl;					// 
	jr nextln;							// 

aload_end:
	ld a, (membot + 1);					// 
	rst divmmc;							// 
	defb f_close;						// 
	jr c, report_bad_io_dev3;			// 
	rst error;							// 
	defb ok;							// 

f_getc:
	ld a, (membot + 1);					// 
	ld ix, membot;						// 
	ld bc, 1;							// 
	rst divmmc;							// 
	defb f_read;						// 

f_getc_err:
	jr c, report_bad_io_dev3;			// 
	dec bc;								// 
	ld a, c;							// 
	or b;								// 
	ret nz;								// 
	ld a, (membot);						// 
	ret;								// 

;;
; <code>SAVE</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#SAVE" target="_blank" rel="noopener noreferrer">Language reference</a>
; @deprecated To be replaced with non-tokenized version.
; @throws File not found; Path not found.
;;
c_save:
	call unstack_z;						// return if checking syntax
	call path_to_ix;					// 
	ld b, fa_write | fa_open_al;		// 
	call open_file;						// 
	ld hl, (chans);						// 
	add hl, de;							// 
	dec hl;								// 
	ld (curchl), hl;					// 
	call list_10;						// 
	ld ix,(curchl);						// 
	call close_file;					// it is, in fact, a jump, as the return address will be popped
