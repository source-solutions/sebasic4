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
	ldir;								// copy base path

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
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_fstat;						// get file stats
	jr c, app_not_found;				// jump if error

	ld a, (handle);						// restore handle
	ld bc, (f_size);					// get length
	ld ix, $6000;						// get address

	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_read;						// read a byte
	jr c, app_not_found;				// jump if error
	ld a, (handle);						// 
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
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
	and a;								// signal no error (clear carry flag)
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
	jp c, report_file_not_found;		// jump if error
	ld a, (handle);						// 
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
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
	jp c, report_file_not_found;		// jump if error

;	// close destination
	ld a, (handle_1);					// restore handle from sysvar
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
	jp c, report_file_not_found;		// jump if error

 ;	// return to BASIC
	or a;								// clear flags
	ret;								// done

;	// call with bytes to copy in C
read_chunk:
	ld a, (handle);						// get file handle to source
	ld ix, $5700;						// 256 byte buffer
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_read;						// read a byte
	jp c, report_file_not_found;		// jump if error
	ret;								// else done

write_chunk:
	ld a, (handle_1);					// get file handle to destination
	ld ix, $5700;						// 256 byte buffer
	and a;								// signal no error (clear carry flag)
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
	call unstack_z;						// return if checking syntax
	ld ix, old_bas_path;				// pointer to path

;c_load:
;	call unstack_z;						// return if checking syntax
;	call path_to_ix;					// path to buffer


	call f_open_read_ex;				// open file for reading
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
	rst error;							// clear error
	defb ok;							// done

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
	call f_open_write_al;				// open file for writing

;	// get program length
	ld hl, (vars);						// end of BASIC to HL
	ld de, (prog);						// start of program to DE
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
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_getcwd;						// get current working folder
	jp c, report_path_not_found;		// jump if error

open_folder:
;	rst divmmc;							// issue a hookcode
;	defb f_umount;						// unmount drive
;	rst divmmc;							// issue a hookcode
;	defb f_mount;						// remount drive
	ld a, 2;							// channel S (upper screen)
	call chan_open;						// select channel
	ld b, 0;							// folder access mode (read only?)
	ld a, '*';							// use current drive
	ld ix, $5800;						// folder path buffer
	and a;								// signal no error (clear carry flag)
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
;	res 5,a;							// make upper case
	and %11011111;						// make upper case

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
	and a;								// signal no error (clear carry flag)
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
;	res 5,a;							// make upper case
	and %11011111;						// make upper case

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
	defb f_close;						// close file
	ld b, 0;							// folder access mode (read only?)
	ld a, '*';							// use current drive
	ld ix, $5800;						// folder path buffer
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_opendir;						// open folder
	jp c, report_file_not_found;		// jump if error
	ld (handle), a;						// store folder handle

read_files_2:
	ld ix, $5700;						// folder buffer
	ld a, (handle);						// get folder handle
	and a;								// signal no error (clear carry flag)
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
;	res 5,a;							// make upper case
	and %11011111;						// make upper case

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
	defb f_close;						// close file
	ret;								// end of subroutine

print_f:
	cp '_';								// test for underscore
	jr nz, no_;							// jump if not
	ld a, ' ';							// substitute space

no_:
	rst print_a;						// print it
	ret;								// return

f_length:
	ld ix, f_stats;						// buffer for file stats
	rst divmmc;							// issue a hookcode
	defb f_fstat;						// get file stats
	ret;								// done

seek_f:
	rst divmmc;							// issue a hookcode
	defb f_seek;						// seek to position in BCDE
	ret;								// done

;	// handle AUTOEXEC.BAS ($543D)
autoexec:
	ld ix, autoexec_bas;				// path to AUTOEXEC.BAS
	call open_r_exists;					// 
	ret c;								// return if file not found
	ld (membot + 1), a;					// store file handle in membot
	ld hl, auto_run;					// pointer to macro 'RUN <RETURN>'
	call loop_f_keys;					// insert it
	jr load_4;							// do LOAD "AUTOEXEC.BAS","R"

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
; <code>LOAD</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#LOAD" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_load:
	rst get_char;						// get character
	cp ',';								// test for comma
	jr nz, load_1;						// end of syntax checking if not
	rst next_char;						// next character
	call expt_exp;						// expect string expression
	call check_end;						// end of syntax checking
	call unstack_z;						// checking syntax?
	call stk_fetch;						// get parameters
	ld a, c;							// letter
	or b;								// provided?
	jr nz, load_2;						// jump if so

load_error:
	rst error;							// else
	defb syntax_error;					// error

load_2:
	dec bc;								// reduce length
	ld a, c;							// single
	or b;								// character?
	jr nz, load_error;					// error if not
	ld a, (de);							// get first character
	and %11011111;						// make upper case
	cp 'R';								// test for 'R'
	jr nz, load_error;					// jump if not
	call check_end;						// end of syntax checking
	call unstack_z;						// checking syntax?
	ld hl, auto_run;					// pointer to macro 'RUN <RETURN>'
	call loop_f_keys;					// insert it
	jr load_3;							// immediate jump

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
	jr nz, aload_end;					// jump if not
	cp ctrl_lf;							// line feed
	jr z, readyln;						// jump if so
	cp ctrl_cr;							// carraige return?
	jr z, readyln;						// jump if so
	rst print_a;						// print character
	jr copyln;							// immedaite jump

open_load_merge:
	call path_to_ix;					// get path in IX
	ld b, fa_read;						// B = open mode
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file

report_bad_io_dev3:
	jp c, report_bad_io_dev;			// jump with error
	ld (membot + 1), a;					// store file handle in membot
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

aload_end:
	ld a, (membot + 1);					// get file handle
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
	jr c, report_bad_io_dev3;			// jump with error
	rst error;							// else
	defb ok;							// clear error

f_getc:
	ld a, (membot + 1);					// get file handle
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
; <code>SAVE</code> command
; @see <a href="https://github.com/cheveron/sebasic4/wiki/Language-reference#SAVE" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws File not found; Path not found.
;;
c_save:
	rst get_char;						// get character
	cp ',';								// test for comma
	jr nz, save_1;						// end of syntax checking if not
	rst error;							// FIXME - make save as ASCII optional
	defb syntax_error;					// 

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

;	// FIXME - SEEK takes a stream number and a floating point value to set the pointer in a currently open file
c_seek:
	ret;