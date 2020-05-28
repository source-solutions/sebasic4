;	// SE Basic IV 4.2 Cordelia - A classic BASIC interpreter for the Z80 architecture.
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

;	// X80 maths co-processor instruction set (requires macro support)

;	// never called directly:
;	//
;	// ftop
;	// fbor
;	// fband
;	// fbands
;	// fcps (6 opcodes)
;	// fvals
;	// fusrs
;	// fread
;	// fasc
;	// fval
;	// flen
;	// ftan
;	// facos
;	// fexp
;	// fsgn
;	// fpeek
;	// fin
;	// fusr
;	// fstrs
;	// fchrs
;	// fetof


;	// parameter definitions

	_le equ 0;							// less than or equal
	_ge equ 1;							// greater or equal
	_ne equ 2;							// not equal
	_gt equ 3;							// greater than
	_lt equ 4;							// less than
	_eq equ 5;							// equal
	_lz equ $2d;						// less than zero
	_gz equ $2e;						// greater than zero


;	// instruction macros

fwait macro();							// stop the Z80
	rst $28
	mend

fjpt macro(dest);						// jump if true
	defb 0, dest - $ - 1
	mend

fxch macro();							// exchange
	defb 1
	mend

fdel macro();							// delete
	defb 2
	mend

fsub macro();							// subtract
	defb 3
	mend

fmul macro();							// multiply
	defb 4
	mend

fdiv macro();							// divide
	defb 5
	mend

ftop macro();							// to power
	defb 6
	mend

fbor macro();							// binary or
	defb 7
	mend

fband macro();							// binary and
	defb 8
	mend

fcp macro(n);							// compare (_le to _gz)
	defb 9 + n
	mend

fadd macro();							// add
	defb $0f
	mend

fbands macro();							// binary and string
	defb $10
	mend

fcps macro(n);							// compare string (_le to _eq)
	defb $11 + n
	mend

fcat macro();							// concatenate string
	defb $17
	mend

fvals macro();							// value string
	defb $18
	mend

fusrs macro();							// user string
	defb $19
	mend

fread macro();							// read in
	defb $1a
	mend

fneg macro();							// negate
	defb $1b
	mend

fasc macro();							// character to ASCII
	defb $1c
	mend

fval macro();							// value
	defb $1d
	mend

flen macro();							// length of string
	defb $1e
	mend

fsin macro();							// sine
	defb $1f
	mend

fcos macro();							// cosine
	defb $20
	mend

ftan macro();							// tangent
	defb $21
	mend

fasin macro();							// arcsine
	defb $22
	mend

facos macro();							// arc-cosine
	defb $23
	mend

fatan macro();							// arctangent
	defb $24
	mend

flogn macro();							// natural logarithm
	defb $25
	mend

fexp macro();							// exponential
	defb $26
	mend

fint macro();							// integer (rounded down)
	defb $27
	mend

fsqrt macro();							// square root
	defb $28
	mend

fsgn macro();							// signum
	defb $29
	mend

fabs macro();							// absolute value
	defb $2a
	mend

fpeek macro();							// PEEK
	defb $2b
	mend

fin macro();							// IN
	defb $2c
	mend

fusr macro();							// user address
	defb $2d
	mend

fstrs macro();							// string
	defb $2e
	mend

fchrs macro();							// character
	defb $2f
	mend

fnot macro();							// not
	defb $30
	mend

fmove macro();							// move
	defb $31
	mend

fmod macro();							// modulus
	defb $32
	mend

fjp macro(dest);						// jump
	defb $33, dest - $ - 1
	mend

fstk macro();							// stack data
	defb $34
	mend

fdjnz macro(dest)						// djnz
	defb $35, dest - $ - 1
	mend

fce macro();							// chip enable
	defb $38
	mend

fget macro();							// get
	defb $39
	mend

ftrn macro();							// truncate
	defb $3a
	mend

fsgl macro();							// single operation
	defb $3b
	mend

fetof macro();							// e to floating-point
	defb $3c
	mend

frstk macro();							// restack
	defb $3d
	mend

fstk0 macro();							// stack 0
	defb $a0
	mend

fstk1 macro();							// stack 1
	defb $a1
	mend

fstkhalf macro();						// stack half
	defb $a2
	mend

fstkhalfpi macro();						// stack pi/2
	defb $a3
	mend

fstk10 macro();							// stack 10
	defb $a4
	mend

fst macro(n);							// store (mem 0-5)
	defb $c0 + n
	mend

fgt macro(n);							// get (mem 0-5)
	defb $e0 + n
	mend


;	// miscellaneous

	end_marker		equ $80;
	k_buff			equ $5b00;

;	// colors

	black			equ 0;
	blue			equ 1;
	green			equ 2;
	cyan			equ 3;
	red				equ 4;
	magenta			equ 5;
	yellow			equ 6;
	white			equ 7;


;	// control characters

	ctrl_caps		equ $06;
	ctrl_comma		equ $06;
	ctrl_tab		equ $07;
	ctrl_left		equ $08;
	ctrl_right		equ $09;
	ctrl_down		equ $0a;
	ctrl_up			equ $0b;
	ctrl_backspace	equ $0c;
	ctrl_enter		equ $0d;
	ctrl_symbol		equ $0e;
	ctrl_number		equ $0e;
	ctrl_graphics	equ $0f;
	ctrl_home		equ $10;
	ctrl_end		equ $11;
	ctrl_pg_up		equ $12;
	ctrl_pg_dn		equ $13;
	ctrl_ins		equ $14;
	ctrl_help		equ $15;
	ctrl_clr		equ $16;
	ctrl_delete		equ $7f;

;	// function keys

	k_f1			equ $11
	k_f2			equ $12
	k_f3			equ $13
	k_f4			equ $14
	k_f5			equ $15
	k_f6			equ $16
	k_f7			equ $17
	k_f8			equ $18
	k_f9			equ $19
	k_f10			equ $1a
	k_f11			equ $1b
	k_f12			equ $1c
	k_f13			equ $1d
	k_f14			equ $1e
	k_f15			equ $1f

;	// printable characters

	pchr_copyright	equ $00
	pchr_euro		equ $ff


;	// operators
	op_and			equ '&';
	op_bin			equ '%';
	op_comp			equ '~';
	op_hex			equ '$';
	op_mod			equ tk_mod;
	op_oct			equ '@';
	op_or			equ '|';
	op_xor			equ tk_xor;


;	// tokens
	tk_rnd			equ $80;
	tk_inkey_str	equ $81;
	tk_pi			equ $82;
	tk_fn			equ $83;
	tk_bin_str		equ $84;
	tk_oct_str		equ $85;
	tk_hex_str		equ $86;
	tk_spc			equ $87;
	tk_tab			equ $88;
	tk_val_str		equ $89;
	tk_asc			equ $8a;
	tk_val			equ $8b;
	tk_len			equ $8c;
	tk_sin			equ $8d;
	tk_cos			equ $8e;
	tk_tan			equ $8f;
	tk_asin			equ $90;
	tk_acos			equ $91;
	tk_atan			equ $92;
	tk_log			equ $93;
	tk_exp			equ $94;
	tk_int			equ $95;
	tk_sqr			equ $96;
	tk_sgn			equ $97;
	tk_abs			equ $98;
	tk_peek			equ $99;
	tk_in			equ $9a;
	tk_usr			equ $9b;
	tk_str_str		equ $9c;
	tk_chr_str		equ $9d;
	tk_not			equ $9e;
	tk_mod			equ $9f;
	tk_or			equ $a0;
	tk_and			equ $a1;
	tk_l_eql		equ $a2;
	tk_gr_eq		equ $a3;
	tk_neql			equ $a4;
	tk_line			equ $a5;
	tk_then			equ $a6;
	tk_to			equ $a7;
	tk_step			equ $a8;
	tk_def_fn		equ $a9;
	tk_bload		equ $aa;
	tk_bsave		equ $ab;
	tk_chdir		equ $ac;
	tk_copy			equ $ad;
	tk_open			equ $ae;
	tk_close		equ $af;
	tk_while		equ $b0;
	tk_wend			equ $b1;
	tk_sound		equ $b2;
	tk_files		equ $b3;
	tk_kill			equ $b4;
	tk_load			equ $b5;
	tk_mkdir		equ $b6;
	tk_name			equ $b7;
	tk_rmdir		equ $b8;
	tk_save			equ $b9;
	tk_out			equ $ba;
	tk_locate		equ $bb;
	tk_end			equ $bc;
	tk_stop			equ $bd;
	tk_read			equ $be;
	tk_data			equ $bf;
	tk_restore		equ $c0;
	tk_new			equ $c1;
	tk_error		equ $c2;
	tk_cont			equ $c3;
	tk_dim			equ $c4;
	tk_rem			equ $c5;
	tk_for			equ $c6;
	tk_goto			equ $c7;
	tk_gosub		equ $c8;
	tk_input		equ $c9;
	tk_palette		equ $ca;
	tk_list			equ $cb;
	tk_let			equ $cc;
	tk_wait			equ $cd;
	tk_next			equ $ce;
	tk_poke			equ $cf;
	tk_print		equ $d0;
	tk_delete		equ $d1;
	tk_run			equ $d2;
	tk_edit			equ $d3;
	tk_randomize	equ $d4;
	tk_if			equ $d5;
	tk_cls			equ $d6;
	tk_call			equ $d7;
	tk_clear		equ $d8;
	tk_return		equ $d9;
	tk_color		equ $da;
	tk_tron			equ $db;
	tk_troff		equ $dc;
	tk_on			equ $dd;
	tk_renum		equ $de;
	tk_auto			equ $df;
	tk_screen		equ $e0;
	tk_xor			equ $e1;
	tk__e2			equ $e2;
	tk__e3			equ $e3;
	tk__e4			equ $e4;
	tk__e5			equ $e5;
	tk__e6			equ $e6;
	tk__e7			equ $e7;
	tk__e8			equ $e8;
	tk__e9			equ $e9;
	tk__ea			equ $ea;
	tk__eb			equ $eb;
	tk__ec			equ $ec;
	tk__ed			equ $ed;
	tk__ee			equ $ee;
	tk__ef			equ $ef;
	tk__f0			equ $f0;
	tk__f1			equ $f1;
	tk__f2			equ $f2;
	tk__f3			equ $f3;
	tk__f4			equ $f4;
	tk__f5			equ $f5;
	tk__f6			equ $f6;
	tk__f7			equ $f7;
	tk__f8			equ $f8;
	tk__f9			equ $f9;
	tk__fa			equ $fa;
	tk__fb			equ $fb;
	tk__fc			equ $fc;
	tk__fd			equ $fd;
	tk__fe			equ $fe;
	tk__ff			equ $ff;

;	// i/o ports

	mmu				equ	$f4
	ula				equ	$fe
	scld			equ	$ff
	ay_reg			equ	$c0f5
	ay_tmxdat		equ	$00f6
	paging			equ	$7ffd
	ay_128dat		equ	$bffd
	ulaplus_reg		equ	$bf3b
	ulaplus_dat		equ	$ff3b


;	// restarts

	start		equ $00;
	error		equ $08;
	divmmc		equ $08;
	print_a		equ $10;
	get_char	equ $18;
	next_char	equ $20;
	;calc		equ $28;
	bc_spaces	equ $30;
	mask_int	equ $38;


;	// command classes

	no_f_ops				equ $00;
	var_rqd					equ $01;
	expr_num_str			equ $02;
	num_exp_0				equ $03;
	chr_var					equ $04;
	var_syn					equ $05;
	num_exp					equ $06;
	num_exp_no_f_ops		equ $07;
	two_c_s_num				equ $08;
	two_c_s_num_no_f_ops	equ $09;
	str_exp					equ $0a;
	str_exp_no_f_ops		equ $0b;


;	// errors

	ok						equ $ff;
	break					equ $00;
	next_without_for		equ $01;
	syntax_error			equ $02;
	return_without_gosub	equ $03;
	out_of_data				equ $04;
	illegal_function_call	equ $05;
	overflow				equ $06;
	out_of_memory			equ $07;
	undefined_line_number	equ $08;
	subscript_out_of_range	equ $09;
	undefined_variable		equ $0a;
	address_out_of_range	equ $0b;
	statement_missing		equ $0c;
	type_mismatch			equ $0d;
	out_of_screen			equ $0e;
	bad_io_device			equ $0f;
	undefined_stream		equ $10;
	undefined_channel		equ $11;
	undefined_user_function	equ $12;
	line_buffer_overflow	equ $13;
	for_without_next		equ $14;
	file_not_found			equ $15;
	input_past_end			equ $16;
	path_not_found			equ $17;


;	// frame buffer

	bit_map		equ $c000
	char_map	equ $d800
	tstack		equ $dfc0
	pal_map		equ $dfc0
	attr_map	equ $e000
	font		equ	$f800		

;	// system variables

	oldsp		equ $5bba;			// (iy - $80)
	handle		equ oldsp + 2;		// (iy - $7e)
	f_stats		equ handle + 1;		// (iy - $7d)
	drive		equ f_stats;		// (iy - $7d)
	device		equ drive + 1;		// (iy - $7c)
	f_attr		equ device + 1;		// (iy - $7b)
	f_time		equ f_attr + 1;		// (iy - $7a)
	f_date		equ f_time + 2;		// (iy - $78)
	f_size		equ f_date + 2;		// (iy - $76)
	f_addr		equ f_size + 4;		// (iy - $72)
	handle_1	equ f_addr + 2;		// (iy - $70)

	k_head		equ k_tail - 1;		// (iy - $3c)	pointer to head of keyboard buffer
	k_tail		equ kstate - 1;		// (iy - $3b)	pointer to tail of keyboard buffer
	kstate		equ $5c00;			// (iy - $3a)	key state 0 to 3
	kstate_4	equ	kstate + 4;		// (iy - $36)	key state 4 to 7
	repdel		equ	kstate + 8;		// (iy - $32)	time in seconds (50th PAL / 60th NTSC) before key repeats
	repper		equ	repdel + 1;		// (iy - $31)	delay in seconds (50th PAL / 60th NTSC) between key repeats
	defadd		equ	repper + 1;		// (iy - $30)	address of arguments during user defined funciton evaluation 
	defadd_h	equ	defadd + 1;		// (iy - $2f)	high byte of defadd
	onerr		equ defadd + 2;		// (iy - $2e)	line to jump to on error
	onerr_h		equ onerr + 1;		// (iy - $2d)	high byte of onerr
	maskadd		equ	onerr + 2;		// (iy - $2c)	address of custom IM1 rotuine
	strms		equ	maskadd + 2;	// (iy - $2a)	address of channels attached to streams
	strms_fe	equ	strms + 2;		// (iy - $28)
	strms_ff	equ	strms + 4;		// (iy - $26)
	strms_00	equ	strms + 6;		// (iy - $24)
	strms_01	equ	strms + 8;		// (iy - $22)
	strms_02	equ	strms + 10;		// (iy - $20)
	strms_03	equ	strms + 12;		// (iy - $1e)
	strms_04	equ	strms + 14;		// (iy - $1c)
	strms_05	equ	strms + 16;		// (iy - $1a)
	strms_06	equ	strms + 18;		// (iy - $18)
	strms_07	equ	strms + 20;		// (iy - $16)
	strms_08	equ	strms + 22;		// (iy - $14)
	strms_09	equ	strms + 24;		// (iy - $12)
	strms_10	equ	strms + 26;		// (iy - $10)
	strms_11	equ	strms + 28;		// (iy - $0e)
	strms_12	equ	strms + 30;		// (iy - $0c)
	strms_13	equ	strms + 32;		// (iy - $0a)
	strms_14	equ	strms + 34;		// (iy - $08)
	strms_15	equ	strms + 36;		// (iy - $06)
	seg			equ	strms + 38;		// (iy - $04)	RESERVED (word)
	rasp		equ	seg + 2;		// (iy - $02)
	pip			equ	rasp + 1;		// (iy - $01)
	err_nr		equ	pip + 1;		// (iy + $00)	error number

	flags		equ	err_nr + 1;		// (iy + $01)
;	// 0: Set to suppress a leading space
;	// 1: RESERVED (set if ZX Printer is in use)
;	// 2: RESERVED (1='L' mode, 0='K' mode. temporary value)
;	// 3: RESERVED (1='L' mode, 0='K' mode)
;	// 4: RESERVED (1=128 BASIC, 0=48 BASIC)
;	// 5: RESERVED (set if a new key has been pressed)
;	// 6: Set if scanning result is numeric
;	// 7: Reset if checking syntax

	vdu_flag	equ	flags + 1;		// (iy + $02)
;	// 0: Set if lower screen in use.
;	// 1: RESERVED
;	// 2: RESERVED
;	// 3: Set if edit key has been pressed
;	// 4: Set if an automatic listing
;	// 5: Set if lower screen to be cleared
;	// 6: RESERVED
;	// 7: RESERVED

	err_sp		equ	vdu_flag + 1;	// (iy + $03)
	list_sp		equ	err_sp + 2;		// (iy + $05)
	mode		equ	list_sp + 2;	// (iy + $07)
	newppc		equ	mode + 1;		// (iy + $08)
	nsppc		equ	newppc + 2;		// (iy + $0a)
	ppc			equ	nsppc + 1;		// (iy + $0b)
	subppc		equ	ppc + 2;		// (iy + $0d)
	bordcr		equ	subppc + 1;		// (iy + $0e)
	e_ppc		equ	bordcr + 1;		// (iy + $0f)
	e_ppc_h		equ	e_ppc + 1;		// (iy + $10)
	vars		equ	e_ppc + 2;		// (iy + $11)
	dest		equ	vars + 2;		// (iy + $13)
	chans		equ	dest + 2;		// (iy + $15)
	curchl		equ	chans + 2;		// (iy + $17)
	prog		equ	curchl + 2;		// (iy + $19)
	nxtlin		equ	prog + 2;		// (iy + $1b)
	datadd		equ	nxtlin + 2;		// (iy + $1d)
	e_line		equ	datadd + 2;		// (iy + $1f)
	k_cur		equ	e_line	+2;		// (iy + $21)
	ch_add		equ	k_cur + 2;		// (iy + $23)
	x_ptr		equ	ch_add + 2;		// (iy + $25)
	worksp		equ	x_ptr + 2;		// (iy + $27)
	stkbot		equ	worksp + 2;		// (iy + $29)
	stkend		equ	stkbot + 2;		// (iy + $2b)
	stkend_h	equ	stkend + 1;		// (iy + $2c)
	breg		equ	stkend + 2;		// (iy + $2d)
	mem			equ	breg + 1;		// (iy + $2e)

	flags2		equ	mem + 2;		// (iy + $30)
;	// 0: Set if main screen to be cleared
;	// 1: Set if 40 column mode in use (State of ZX printer buffer)
;	// 2: Set if a ':' is within quotes
;	// 3: Set if caps lock on
;	// 4: Set if 'K' channel is use
;	// 5: NOT USED
;	// 6: NOT USED
;	// 7: Set if trace enabled

	df_sz		equ	flags2 + 1;		// (iy + $31)
	s_top		equ	df_sz + 1;		// (iy + $32)
	oldppc		equ	s_top + 2;		// (iy + $34)
	osppc		equ	oldppc + 2;		// (iy + $36)

	flagx		equ	osppc + 1;		// (iy + $37)
;	// 0: Set if handling a simple string
;	// 1: Set if handling a new variable
;	// 2: NOT USED
;	// 3: NOT USED
;	// 4: NOT USED
;	// 5: Set if in input mode
;	// 6: NOT USED
;	// 7: Set if handling INPUT LINE

	strlen		equ	flagx + 1;		// (iy + $38)	length of string type destination in assignment
	t_addr		equ	strlen + 2;		// (iy + $3a)	address of next item in syntax table
	seed		equ	t_addr + 2;		// (iy + $3c)	seed for RND (set by RANDOMIZE)
	frame		equ	seed + 2;		// (iy + $3e)	cuurent frame (0-49 PAL / 0-59 NTSC)
	time_t		equ	frame + 1;		// (iy + $3f)	POSIX time (unsigned)
	coord_y		equ	time_t + 4;		// (iy + $43)	y pixel co-ordinate (0-255)
	coord_x		equ	coord_y + 1;	// (iy + $44)	x pixel co-ordinate (0-65535)
	nmiadd		equ	coord_x + 2;	// (iy + $46)	address to jump to on NMI
	echo_e		equ	nmiadd + 2;		// (iy + $48)
	df_cc		equ	echo_e + 2;		// (iy + $4a)
	df_ccl		equ	df_cc + 2;		// (iy + $4c)
	s_posn		equ	df_ccl + 2;		// (iy + $4e)
	s_posn_h	equ	s_posn + 1;		// (iy + $4f)
	sposnl		equ	s_posn + 2;		// (iy + $50)
	sposnl_h	equ	sposnl + 1;		// (iy + $51)
	scr_ct		equ	sposnl + 2;		// (iy + $52)
	attr_p		equ	scr_ct + 1;		// (iy + $53)
	mask_p		equ	attr_p + 1;		// (iy + $54)
	attr_t		equ	mask_p + 1;		// (iy + $55)
	mask_t		equ	attr_t + 1;		// (iy + $56)
	p_flag		equ	mask_t + 1;		// (iy + $57)
	membot		equ	p_flag + 1;		// (iy + $58)
	mem_0_1		equ	membot + 1;		// (iy + $59)
	mem_0_2		equ	membot + 2;		// (iy + $5a)
	mem_0_3		equ	membot + 3;		// (iy + $5b)
	mem_0_4		equ	membot + 4;		// (iy + $5c)
	mem_1		equ	membot + 5;		// (iy + $5d)
	mem_1_1		equ	membot + 6;		// (iy + $5e)
	mem_1_2		equ	membot + 7;		// (iy + $5f)
	mem_1_3		equ	membot + 8;		// (iy + $60)
	mem_1_4		equ	membot + 9;		// (iy + $61)
	mem_2		equ	membot + 10;	// (iy + $62)
	mem_2_1		equ	membot + 11;	// (iy + $63)
	mem_2_2		equ	membot + 12;	// (iy + $64)
	mem_2_3		equ	membot + 13;	// (iy + $65)
	mem_2_4		equ	membot + 14;	// (iy + $66)
	mem_3		equ	membot + 15;	// (iy + $67)
	mem_3_1		equ	membot + 15;	// (iy + $68)
	mem_3_2		equ	membot + 17;	// (iy + $69)
	mem_3_3		equ	membot + 18;	// (iy + $6a)
	mem_3_4		equ	membot + 19;	// (iy + $6b)
	mem_4		equ	membot + 20;	// (iy + $6c)
	mem_4_1		equ	membot + 21;	// (iy + $6d)
	mem_4_2		equ	membot + 22;	// (iy + $6e)
	mem_4_3		equ	membot + 23;	// (iy + $6f)
	mem_4_4		equ	membot + 24;	// (iy + $70)
	mem_5		equ	membot + 25;	// (iy + $71)
	mem_5_1		equ	membot + 26;	// (iy + $72)
	mem_5_2		equ	membot + 27;	// (iy + $73)
	mem_5_3		equ	membot + 28;	// (iy + $74)
	mem_5_4		equ	membot + 29;	// (iy + $75)
	dosvar		equ	membot + 30;	// (iy + $76)
	ramtop		equ	dosvar + 2;		// (iy + $78)
	p_ramt		equ	ramtop + 2;		// (iy + $7a)
	channels	equ	p_ramt + 2;		// (iy + $7c)


;	// system variable IY offsets

;	// negative
	_oldsp		equ $80;

	_k_head		equ $3c;
	_k_tail		equ $3b;
	_kstate		equ $3a;
	_kstate_4	equ $36;
	_repdel		equ $32;
	_repper		equ $31;
	_defadd		equ $30;
	_defadd_h	equ $2f;
	_onerr		equ $2e;
	_onerr_h	equ $2d;
	_maskadd	equ $2c;
	_strms		equ $2a;
	_strms_fe	equ $28;
	_strms_ff	equ $26;
	_strms_00	equ $24;
	_strms_01	equ $22;
	_strms_02	equ $20;
	_strms_03	equ $1e;
	_strms_04	equ $1c;
	_strms_05	equ $1a;
	_strms_06	equ $18;
	_strms_07	equ $16;
	_strms_08	equ $14;
	_strms_09	equ $12;
	_strms_10	equ $10;
	_strms_11	equ $0e;
	_strms_12	equ $0c;
	_strms_13	equ $0a;
	_strms_14	equ $08;
	_strms_15	equ $06;
	_seg		equ $04;
	_rasp		equ $02;
	_pip		equ $01;

;	// positive

	_err_nr		equ $00;
	_flags		equ $01;
	_vdu_flag	equ $02;
	_err_sp		equ $03;
	_list_sp	equ $05;
	_mode		equ $07;
	_newppc		equ $08;
	_nsppc		equ $0a;
	_ppc		equ $0b;
	_subppc		equ $0d;
	_bordcr		equ $0e;
	_e_ppc		equ $0f;
	_e_ppc_h	equ $10;
	_vars		equ $11;
	_dest		equ $13;
	_chans		equ $15;
	_curchl		equ $17;
	_prog		equ $19;
	_nxtlin		equ $1b;
	_datadd		equ $1d;
	_e_line		equ $1f;
	_k_cur		equ $21;
	_k_cur_h	equ $22;
	_ch_add		equ $23;
	_x_ptr		equ $25;
	_x_ptr_h	equ $26;
	_worksp		equ $27;
	_stkbot		equ $29;
	_stkend		equ $2b;
	_stkend_h	equ $2c;
	_breg		equ $2d;
	_mem		equ $2e;
	_flags2		equ $30;
	_df_sz		equ $31;
	_s_top		equ $32;
	_oldppc		equ $34;
	_osppc		equ $36;
	_flagx		equ $37;
	_strlen		equ $38;
	_t_addr		equ $3a;
	_seed		equ $3c;
	_frame		equ $3e;
	_time_t		equ $3f;
	_coord_y	equ $43;
	_coord_x	equ $44;
	_nmiadd		equ $46;
	_echo_e		equ $48;
	_df_cc		equ $4a;
	_df_ccl		equ $4c;
	_s_posn		equ $4e;
	_s_posn_h	equ $4f;
	_sposnl		equ $50;
	_sposnl_h	equ $51;
	_scr_ct		equ $52;
	_attr_p		equ $53;
	_mask_p		equ $54;
	_attr_t		equ $55;
	_mask_t		equ $56;
	_p_flag		equ $57;
	_membot		equ $58;
	_mem_0_1	equ $59;
	_mem_0_2	equ $5a;
	_mem_0_3	equ $5b;
	_mem_0_4	equ $5c;
	_mem_1		equ $5d;
	_mem_1_1	equ $5e;
	_mem_1_2	equ $5f;
	_mem_1_3	equ $60;
	_mem_1_4	equ $61;
	_mem_2		equ $62;
	_mem_2_1	equ $63;
	_mem_2_2	equ $64;
	_mem_2_3	equ $65;
	_mem_2_4	equ $66;
	_mem_3		equ $67;
	_mem_3_1	equ $68;
	_mem_3_2	equ $69;
	_mem_3_3	equ $6a;
	_mem_3_4	equ $6b;
	_mem_4		equ $6c;
	_mem_4_1	equ $6d;
	_mem_4_2	equ $6e;
	_mem_4_3	equ $6f;
	_mem_4_4	equ $70;
	_mem_5		equ $71;
	_mem_5_1	equ $72;
	_mem_5_2	equ $73;
	_mem_5_3	equ $74;
	_mem_5_4	equ $75;
	_dosvar		equ $76;
	_ramtop		equ $78;
	_p_ramt		equ $7a;
	_channels	equ $7c;
