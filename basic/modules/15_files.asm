;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2019 Source Solutions, Inc.

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

	include "../os/unodos3.inc";		// label definitions

	org $4600;

;	// file subroutines (IX must point to an ASCIIZ path on entry)

f_open_read_ex:
	ld a, '*';							// use current drive
	ld b, fa_read | fa_open_ex;			// open for reading if file exists
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
	jr c, report_file_not_found;		// jump if error
	ld (handle), a;						// store handle
	ret;								// end of subroutine

f_open_write_al:
	ld a, '*';							// use current drive
	ld b, fa_write | fa_open_al;		// open for writing
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
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
	ld de, $5a00;						// destination - FIXME use workspace
	ldir;								// copy it
	ex de, hl;							// end to HL
	ld (hl), 0;							// set end marker
	ret;								// done

get_dest:
	call stk_fetch;						// start to DE, length to BC
	ld a, c;							// test for
	or b;								// empty string
	jp z, report_bad_fn_call;			// error if so
	ex de, hl;							// start to HL
	ld de, $5900;						// destination - FIXME use workspace
	ldir;								// copy it
	ex de, hl;							// end to HL
	ld (hl), 0;							// set end marker
	ret;								// done

;	// file commands

run_app:
	call load;							// load BASIC program
	call use_zero;						// use line zero
	jp run;								// run

bload:
	call unstack_z;						// return if checking syntax
	call find_int2;						// get address
	ld (f_addr), bc;					// store it
	call get_path;						// path to buffer
	ld ix, $5a00;						// pointer to path
	call f_open_read_ex;				// open file for reading
	call f_get_stats;					// get binary length

;	// load binary
	ld a, (handle);						// restore handle
	ld bc, (f_size);					// get length
	ld ix, (f_addr);					// get address

	jp f_read_in;						// load binary

bsave:
	call unstack_z;						// return if checking syntax
	call find_int2;						// get length
	ld (f_size), bc;					// store it
	call find_int2;						// get address
	ld (f_addr), bc;					// store it
	call get_path;						// path to buffer
	ld ix, $5a00;						// pointer to path
	call f_open_write_al;				// open file for writing

;	// get binary length
	ld ix, (f_addr);					// start to IX
	ld bc, (f_size);					// length to BC

	jp f_write_out;						// save binary

copy:
	call unstack_z;						// return if checking syntax
	call get_dest;						// path to buffer (dest)
	call get_path;						// path to buffer (source)
	ld ix, $5a00;						// pointer to path
	call f_open_read_ex;				// open file for reading
	call f_get_stats;					// get file length
	ld ix, $5900;						// pointer to path

;	// open file for writing with alternate handle
	ld a, '*';							// use current drive
	ld b, fa_write | fa_open_al;		// open for writing
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
	jp c, report_file_not_found;					// jump if error
	ld (handle_1), a;					// store handle in sysvar

;	// read a byte
copy_byte:
	ld a, (handle);						// get file handle to source
	ld ix, f_attr;						// use file attributes sys var as buffer
	ld bc, 1;							// one byte
	rst divmmc;							// issue a hookcode
	defb f_read;						// read a byte
	jp c, report_file_not_found;					// jump if error

	ld a, (handle_1);					// get file handle to destination
	ld ix, f_attr;						// use file attributes sys var as buffer
	ld bc, 1;							// one byte
	rst divmmc;							// issue a hookcode
	defb f_write;						// write a byte
	jp c, report_file_not_found;					// jump if error

	ld hl, (f_size);					// byte count
	dec hl;								// reduce count
	ld (f_size), hl;					// write it back
	ld a, l;							// test for
	or h;								// zero
	jr nz, copy_byte;					// loop until done

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

dload:
	call unstack_z;						// return if checking syntax
	call get_path;						// path to buffer
	ld ix, $5a00;						// pointer to path

	call f_open_read_ex;				// open file for reading
	call f_get_stats;					// get program length

;	// remove garbage
	ld de, (vars);						// VARS to DE
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

	jp f_read_in;						// load data

dsave:
	call unstack_z;						// return if checking syntax
	call get_path;						// path to buffer
	ld ix, $5a00;						// pointer to path
	call f_open_write_al;				// open file for writing

;	// get data length
 	ld hl, (e_line);					// end of variables to HL
 	ld de, (vars);						// start of variables to DE
 	sbc hl, de;							// get program length
	ld ixh, d;							// start of variables to
	ld ixl, e;							// IX
	ld c, l;							// length of variables to
	ld b, h;							// BC

	jp f_write_out;						// save data

kill:
	call unstack_z;						// return if checking syntax
	call get_path;						// path to buffer
	ld a, '*';							// use current drive
	ld ix, $5a00;						// pointer to path
	rst divmmc;							// issue a hookcode
	defb f_unlink;						// release file
	jp c, report_file_not_found;		// jump if error
	or a;								// clear flags
	ret;								// done

load:
	call unstack_z;						// return if checking syntax
	call get_path;						// path to buffer
	ld ix, $5a00;						// pointer to path
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

name:
	call unstack_z;						// return if checking syntax
	call get_dest;						// path to buffer (dest)
	call get_path;						// path to buffer (source)
	ld a, '*';							// use current drive
	ld ix, $5a00;						// pointer to source
	ld de, $5900;						// pointer to dest
	rst divmmc;							// issue a hookcode
	defb f_rename;						// change folder
	jp c, report_file_not_found;					// jump if error
	or a;								// clear flags
	ret;		

save:
	call unstack_z;						// return if checking syntax
	call get_path;						// path to buffer
	ld ix, $5a00;						// pointer to path
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

;	// folder commands

init_path:
	ld a, '*';							// use current drive
	ld ix, os_path;						// default path
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder
	or a;
	ret;

os_path:
	defb '/', 0;						// root	

chdir:
	call unstack_z;						// return if checking syntax
	call get_path;						// path to buffer
	ld a, '*';							// use current drive
	ld ix, $5a00;						// pointer to path
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder
	jr chk_path_error;					// test for error

mkdir:
	call unstack_z;						// return if checking syntax
	call get_path;						// path to buffer
	ld a, '*';							// use current drive
	ld ix, $5a00;						// pointer to path
	rst divmmc;							// issue a hookcode
	defb f_mkdir;						// change folder
	jr chk_path_error;					// test for error

rmdir:
	call unstack_z;						// return if checking syntax
	call get_path;						// path to buffer
	ld a, '*';							// use current drive
	ld ix, $5a00;						// pointer to path
	rst divmmc;							// issue a hookcode
	defb f_rmdir;						// change folder

chk_path_error:
	jr c, report_path_not_found;		// jump if error
	or a;								// clear flags
	ret;								// done

report_path_not_found:
	rst error;
	defb path_not_found;

files:
	call unstack_z;						// return if checking syntax
	ld a, 2;							// select main screen
	call chan_open;						// open channel
	jr files2;							// immediate jump

files1:
	ld a, l;							// 
	or h;								// 
	jr z, files2;						// 
	ld bc, $50;							// 
	ld de, folder_path_buffer;			// 
	call files18;						// 
	jr nz, files3;						// 

files2:
	ld a, '*';							// use current drive
	ld ix, folder_path_buffer;			// 
	rst divmmc;							// issue a hookcode
	defb f_getcwd;						// 
	jp c, report_file_not_found;		// jump if error
	jr files8;

files3:
	ld b, 1;							// 
	ld a, '*';							// use current drive
	ld ix, folder_path_buffer;			//
	rst divmmc;							// issue a hookcode
	defb f_open;						//
	jr c, files8;						// 
	ld ix, f_stats;						// 
	ld (handle), a;						// 
	rst divmmc;							// issue a hookcode
	defb f_fstat;						// 
	ld a, (handle);						// 
	rst divmmc;							// issue a hookcode
	defb f_close;						// 
	ld b, $0c;							// 
	ld hl, folder_path_buffer;			// 

files4:
	ld a, (hl);							// 
	or a;								// 
	jr nz, files5;						// 
	ld a, ' ';							// 
	jr files6;							// 

files5:
	inc hl;								// 
	cp ' ';								// 
	jr nc, files6;						// 
	ld a, '?';							// 

files6:
	cp 'a';								// 
	jr c, files7;						// 
	cp '{';								// 
	jr nc, files7;						// 
	sub ' ';							// 

files7:
	rst print_a;						// 
	djnz files4;						// 
	ld a, ' ';							// 
	rst print_a;						// 
	ld hl, f_size;						// 
	call files38;						// 
	ld a, ' ';							// 
	rst print_a;						// 
	ld hl, (f_date);					// 
	call files27;						// 
	ld a, $0d;							// 
	rst print_a;						// 
	xor a;								// 
	ret;								// 

files8:
	ld b, 0;							// 
	ld a, '*';							// 
	ld ix, folder_path_buffer;			// 
	rst divmmc;							// issue a hookcode
	defb f_opendir;						//
	jp c, report_file_not_found;		// jump if error
	ld (handle), a;						//

files9:
	ld ix, folder_path_buffer;			// 
	ld a, (handle);						// 
	rst divmmc;							// issue a hookcode
	defb f_readdir;						// 
	jr c, files15;						// 
	or a;								// 
	jr z, files15;						// 
	ld hl, folder_path_buffer;			// 
	ld c, (hl);							// 
	inc hl;								// 
	ld b, $0c;							// 

files10:
	ld a, (hl);							// 
	or a;								// 
	jr nz, files11;						// 
	ld a, ' ';							// 
	jr files12;							// 

files11:
	inc hl;								// 
	cp ' ';								// 
	jr nc, files12;						// 
	ld a, '?';							// 

files12:
	rst print_a;						// 
	djnz files10;						// 
	ld a, ' ';							// 
	inc hl;								// 
	rst print_a;						// 
	ld e, (hl);							// 
	inc hl;								// 
	ld d, (hl);							// 
	inc hl;								// 
	ld (f_time), de;					// 
	ld e, (hl);							// 
	inc hl;								// 
	ld d, (hl);							// 
	inc hl;								// 
	ld a, c;							// 
	ld (f_date), de;					// 
	and $10;							// 
	jr z, files13;						// 
	ld hl, dir_msg;						// 
	call files24;						// 
	jr files14;							// 

files13:
	call files38;						// 

files14:
	ld a, ' ';							// 
	rst print_a;						// 
	ld hl, (f_date);					// 
	call files27;						// 
	ld a, $0d;							// 
	rst print_a;						// 
	jr files9;							// 

files15:
	ld a, $0d;							// 
	rst print_a;						// 
	ld a, (handle);						// 
	rst divmmc;							// issue a hookcode
	defb f_close;						// 
	ret;								// 

files16:
	ld a, (hl);							// 
	or a;								// 
	ret z;								// 
	cp $0d;								// 
	ret z;								// 
	cp ':';								// 
	ret;								// 

files17:
	call files16;						// 
	ret z;								// 
	cp ' ';								// 
	ret nz;								// 
	inc hl;								// 
	jr files17;							// 

files18:
	ld a, c;							// 
	or b;								// 
	ret z;								// 
	call files17;						// 
	jr nz, files19;						// 
	xor a;								// 
	ld (de), a;							// 
	ret;								// 

files19:
	push de;							// 

files20:
	call files16;						// 
	jr z, files21;						// 
	cp ' ';								// 
	jr z, files21;						// 
	dec bc;								// 
	ld (de), a;							// 
	ld a, c;							// 
	or b;								// 
	jr z, files21;						// 
	inc hl;								// 
	inc de;								// 
	jr files20;							// 

files21:
	xor a;								// 
	ld (de), a;							// 
	pop de;								// 
	inc a;								// 
	ret;								// 

files22:
	call files16;						// 
	ret z;								// 
	sub '0';							// 
	ret c;								// 
	cp $0a;								// 
	ccf; 								// 
	ret c;								// 
	push hl;							// 
	ld l, e;							// 
	ld h, d;							// 
	add hl, hl;							// 
	jr c, files23;						// 
	add hl, hl;							// 
	jr c, files23;						// 
	add hl, de;							// 
	jr c, files23;						// 
	add hl, hl;							// 
	jr c, files23;						// 
	ld e, a;							// 
	ld d, 0;							// 
	add hl, de;							// 
	jr c, files23;						// 
	ex de, hl;							// 
	pop hl;								// 
	inc hl;								// 
	jr files22;							// 

files23:
	pop hl;								// 
	ret;								// 

files24:
	ld a, (hl);							// 
	or a;								// 
	ret z;								// 
	rst print_a;						// 
	inc hl;								// 
	jr files24;							// 

files25:
	ld a, c;							// 
	or b;								// 
	ret z;								// 
	ld a, (hl);							// 
	rst print_a;						// 
	dec bc;								// 
	inc hl;								// 
	jr files25;							// 
	ld b, a;							// 
	and $f0;							// 
	rrca;								// 
	rrca;								// 
	rrca;								// 
	rrca;								// 
	call files26;						// 
	rst print_a;						// 
	ld a, b;							// 
	and $0f;							// 
	call files26;						// 
	rst print_a;						// 
	ld a, ' ';							// 
	rst print_a;						// 
	ret;								// 

files26:
	add a, '0';							// 
	cp ':';								// 
	ret c;								// 
	add a, 7;							// 
	ret;								// 

files27:
	ld a, l;							// 
	and $1f;							// 
	call files28;						// 
	ld a, '.';							// 
	rst print_a;						// 
	ld a, l;							// 
	srl h;								// 
	rla;								// 
	rla;								// 
	rla;								// 
	rla;								// 
	and $0f;							// 
	call files28;						// 
	ld a, '.';							// 
	rst print_a;						// 
	ld l, h;							// 
	ld h, 0;							// 
	ld de, $07bc;						// 
	add hl, de;							// 
	call files31;						// 
	ret;								// 

files28:
	ld b, 0;							// 

files29:
	sub $0a;							// 
	jr c, files30;						// 
	inc b;								// 
	jr files29;							// 

files30:
	ld c, a;							// 
	ld a, b;							// 
	add a, '0';							// 
	rst print_a;						// 
	ld a, c;							// 
	add a, ':';							// 
	rst print_a;						// 
	ret;								// 

files31:
	ld de, $64;							// 
	xor a;								// 

files32:
	sbc hl, de;							// 
	jr c, files33;						// 
	inc a;								// 
	jr files32;							// 

files33:
	add hl, de;							// 
	call files28;						// 
	ld a, l;							// 
	call files28;						// 
	ret;								// 

files34:
	push hl;							// 
	push de;							// 
	ld b, 4;							// 
	ex de, hl;							// 
	or a;								// 

files35:
	ld a, (de);							// 
	adc a, (hl);						// 
	ld (de), a;							// 
	inc de;								// 
	inc hl;								// 
	djnz files35;						// 
	pop de;								// 
	pop hl;								// 
	ret;								// 

files36:
	ld b, 4;							// 
	push hl;							// 
	push de;							// 
	ex de, hl;							// 
	or a;								// 

files37:
	ld a, (de);							// 
	sbc a, (hl);						// 
	ld (de), a;							// 
	inc de;								// 
	inc hl;								// 
	djnz files37;						// 
	pop de;								// 
	pop hl;								// 
	ret;								// 

files38:
	ld b, 0;							// 
	ld de, fdata1;						// 
	call files40;						// 
	ld de, fdata2;						// 
	call files40;						// 
	ld de, fdata3;						// 
	ld a, b;							// 
	or a;								// 
	jr nz, files39;						// 
	inc b;								// 

files39:
	call files40;						// 
	ld de, fdata4;						// 
	call files40;						// 
	ld de, fdata5;						// 
	call files40;						// 
	ld de, fdata6;						// 
	call files40;						// 
	ld de, fdata7;						// 
	call files40;						// 
	ld de, fdata8;						// 
	call files40;						// 
	ld de, fdata9;						// 
	call files40;						// 
	ld b, 2;							// 
	ld de, fdata10;						// 

files40:
	ld c, '/';							// 
	push bc;							// 

files41:
	inc c;								// 
	call files36;						// 
	jr nc, files41;						// 
	call files34;						// 
	ld a, c;							// 
	pop bc;								// 
	ld c, a;							// 
	ld a, b;							// 
	or a;								// 
	jr z, files44;						// 
	dec a;								// 
	jr z, files46;						// 

files42:
	ld a, c;							// 

files43:
	rst print_a;						// 
	ret;								// 

files44:
	ld a, c;							// 
	cp '0';								// 
	ret z;								// 

files45:
	ld b, 2;
	jr files42;							// 

files46:
	ld a, c;							// 
	cp '0';								// 
	jr nz, files45;						// 
	ld a, ' ';							// 
	jr files43;							// 

fdata1:
	defb $00, $ca, $9a, $3b;			// 

fdata2:
	defb $00, $e1, $f5, $05;			// 

fdata3:
	defb $80, $96, $98, $00;			// 

fdata4:
	defb $40, $42, $0f, $00;			// 

fdata5:
	defb $a0, $86, $01, $00;			// 

fdata6:
	defb $10, $27, $00, $00;			// 

fdata7:
	defb $e8, $03, $00, $00;			// 

fdata8:
	defb $64, $00, $00, $00;			// 

fdata9:
	defb $0a, $00, $00, $00;			// 

fdata10:
	defb $01, $00, $00, $00;			// 

rh_msg:
	defb "RH";							// 

dir_msg:
	defb "<DIR>", 0;					// 

folder_path_buffer:
	defb 0, 0, 0;						// 

;	// last byte
org $5bb9;
	defb $A0;							// end marker
