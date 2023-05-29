;	// SE Basic IV 4.2 Cordelia - A classic BASIC interpreter for the Z80 architecture.
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

;;
;	// X80 maths co-processor instruction set (requires macro support)
;;
:

;	// never called directly:
;	//
;	// ftop
;	// fbor
;	// fband
;	// fbands
;	// fcps (6 opcodes)
;	// fvals
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
;	// fetof

;	// parameter definitions

;;
; X80 parameter: less than or equal
;;
	le equ 0;

;;
; X80 parameter: greater or equal
;;
	ge equ 1;

;;
; X80 parameter: not equal
;;
	ne equ 2;

;;
; X80 parameter: greater than
;;
	gt equ 3;

;;
; X80 parameter: less than
;;
	lt equ 4;

;;
; X80 parameter: equal
;;
	eq equ 5;

;;
; X80 parameter: less than zero
;;
	lz equ $2d;

;;
; X80 parameter: greater than zero
;;
	gz equ $2e;


;	// instruction macros

;;
; X80 op-code: CPU wait
;;
MACRO fwait;
	rst $28;
ENDM

;;
; X80 op-code: jump if true
;;
MACRO fjpt n;
	defb op_fjpt, {n} - $ - 1;
ENDM

;;
; X80 op-code: exchange
;;
MACRO fxch;
	defb op_fxch;
ENDM

;;
; X80 op-code: delete
;;
MACRO fdel;
	defb op_fdel;
ENDM

;;
; X80 op-code: subtract
;;
MACRO fsub;
	defb op_fsub;
ENDM

;;
; X80 op-code: multiply
;;
MACRO fmul;
	defb op_fmul;
ENDM

;;
; X80 op-code: divide
;;
MACRO fdiv;
	defb op_fdiv;
ENDM

;;
; X80 op-code: to power
;;
MACRO ftop;
	defb op_ftop;
ENDM

;;
; X80 op-code: binary OR
;;
MACRO fbor;
	defb op_fbor;
ENDM

;;
; X80 op-code: binary AND
;;
MACRO fband;
	defb op_fband;
ENDM

;;
; X80 op-code: compare
; @param eq, <code>ge</code>, <code>gt</code>, <code>gz</code>, <code>lt</code>, <code>lz</code>, <code>ne</code>
;;
MACRO fcp n;
	defb op_fcp + {n}
ENDM

;;
; X80 op-code: add
;;
MACRO fadd;
	defb op_fadd;
ENDM

;;
; X80 op-code: binary and string
;;
MACRO fbands;
	defb op_bands;
ENDM

;;
; X80 op-code: compare string
; @param eq, <code>ge</code>, <code>gt</code>, <code>gz</code>, <code>lt</code>, <code>lz</code>, <code>ne</code>
;;
MACRO fcps n;
	defb op_fcps + {n};
ENDM

;;
; X80 op-code: concatenate string
;;
MACRO fcat;
	defb op_fcat;
ENDM

;;
; X80 op-code: value string
;;
MACRO fvals;
	defb op_fvals;
ENDM

;;
; X80 op-code: string by number multiplication
;;
MACRO fmuls;
	defb op_fmuls;
ENDM

;;
; X80 op-code: read in
;;
MACRO fread;
	defb op_fread;
ENDM

;;
; X80 op-code: negate
;;
MACRO fneg;
	defb op_fneg;
ENDM

;;
; X80 op-code: character to ASCII
;;
MACRO fasc;
	defb op_fasc;
ENDM

;;
; X80 op-code: value
;;
MACRO fval;
	defb op_fval;
ENDM

;;
; X80 op-code: length of string
;;
MACRO flen;
	defb op_flen;
ENDM

;;
; X80 op-code: sine
;;
MACRO fsin;
	defb op_fsin;
ENDM

;;
; X80 op-code: cosine
;;
MACRO fcos;
	defb op_fcos;
ENDM

;;
; X80 op-code: tangent
;;
MACRO ftan;
	defb op_ftan;
ENDM

;;
; X80 op-code: arcsine
;;
MACRO fasin;
	defb op_fasin;
ENDM

;;
; X80 op-code: arc-cosine
;;
MACRO facos;
	defb op_facos;
ENDM

;;
; X80 op-code: arctangent
;;
MACRO fatan;
	defb op_fatan;
ENDM

;;
; X80 op-code: natural logarithm
;;
MACRO flogn;
	defb op_flogn;
ENDM

;;
; X80 op-code: exponential
;;
MACRO fexp;
	defb op_fexp;
ENDM

;;
; X80 op-code: integer (rounded down)
;;
MACRO fint;
	defb op_fint;
ENDM

;;
; X80 op-code: square root
;;
MACRO fsqrt;
	defb op_fsqrt;
ENDM

;;
; X80 op-code: signum
;;
MACRO fsgn;
	defb op_fsgn;
ENDM

;;
; X80 op-code: absolute value
;;
MACRO fabs;
	defb op_fabs;
ENDM

;;
; X80 op-code: PEEK
;;
MACRO fpeek;
	defb op_fpeek;
ENDM

;;
; X80 op-code: IN
;;
MACRO finp;
	defb op_finp;
ENDM

;;
; X80 op-code: user address
;;
MACRO fusr;
	defb op_fusr;
ENDM

;;
; X80 op-code: string
;;
MACRO fstrs;
	defb op_fstrs;
ENDM

;;
; X80 op-code: character
;;
MACRO fchrs;
	defb op_fchrs;
ENDM

;;
; X80 op-code: NOT
;;
MACRO fnot;
	defb op_fnot;
ENDM

;;
; X80 op-code: move
;;
MACRO fmove;
	defb op_fmove;
ENDM

;;
; X80 op-code: modulus
;;
MACRO fmod;
	defb op_fmod;
ENDM

;;
; X80 op-code: jump
; @param address to jump to
;;
MACRO fjp n;
	defb op_fjp, {n} - $ - 1;
ENDM

;;
; X80 op-code: stack data
;;
MACRO fstk;
	defb op_fstk;
ENDM

;;
; X80 op-code: decrement and jump if not zero
; @param address to jump to
;;
MACRO fdjnz n;							// djnz
	defb op_fdjnz, {n} - $ - 1;
ENDM

;;
; X80 op-code: less than zero
;;
MACRO fltz;
	defb op_fltz;
ENDM

;;
; X80 op-code: greater than zero
;;
MACRO fgtz;
	defb op_fgtz;
ENDM

;;
; X80 op-code: CPU enable
;;
MACRO fce;
	defb op_fce;
ENDM

;;
; X80 op-code: get
;;
MACRO fget;
	defb op_fget;
ENDM

;;
; X80 op-code: truncate
;;
MACRO ftrn;
	defb op_ftrn;
ENDM

;;
; X80 op-code: single operation
;;
MACRO fsgl;
	defb op_fsgl;
ENDM

;;
; X80 op-code: DEEK
;;
MACRO fdeek;
	defb op_fdeek;
ENDM

;;
; X80 op-code: restack
;;
MACRO frstk;
	defb op_frstk;
ENDM

;;
; X80 op-code: exclusive or
;;
MACRO fxor;
	defb op_fxor;
ENDM

;;
; X80 op-code: integer quotient
;;
MACRO fquot;
	defb op_fquot;
ENDM

;;
; X80 op-code: stack 0
;;
MACRO fstk0;
	defb $a0;
ENDM

;;
; X80 op-code: stack 1
;;
MACRO fstk1;
	defb $a1
ENDM

;;
; X80 op-code: stack half
;;
MACRO fstkhalf;
	defb $a2
ENDM

;;
; X80 op-code: stack pi / 2
;;
MACRO fstkhalfpi;
	defb $a3
ENDM

;;
; X80 op-code: stack 10
;;
MACRO fstk10;
	defb $a4
ENDM

;;
; X80 op-code: store (mem 0 to 5)
;;
MACRO fst n;
	defb $c0 + {n};
ENDM

;;
; X80 op-code: get (mem 0 to 5)
;;
MACRO fgt n;
	defb $e0 + {n};
ENDM


;	// miscellaneous

	end_marker		equ $80;


;	// colors

	black			equ 0;
	blue			equ 1;
	green			equ 2;
	cyan			equ 3;
	red				equ 4;
	magenta			equ 5;
	yellow			equ 6;
	white			equ 7;


;	// control keys

	key_ins			equ $00;
	key_clr			equ $01;
	key_home		equ $02;
	key_end			equ $03;
	key_pg_up		equ $04;
	key_pg_dn		equ $05;
	key_caps		equ $06;
	key_tab			equ $07;
	key_left		equ $08;
	key_right		equ $09;
	key_down		equ $0a;
	key_up			equ $0b;
	key_backspace	equ $0c;
	key_return		equ $0d;
	key_koru		equ $0e;
	key_control		equ $0f;
	key_help		equ $10;
	key_delete		equ $7f;


;	// function keys

	key_f1			equ $11
	key_f2			equ $12
	key_f3			equ $13
	key_f4			equ $14
	key_f5			equ $15
	key_f6			equ $16
	key_f7			equ $17
	key_f8			equ $18
	key_f9			equ $19
	key_f10			equ $1a
	key_f11			equ $1b
	key_f12			equ $1c
	key_f13			equ $1d
	key_f14			equ $1e
	key_f15			equ $1f


;	// control characters

	ctrl_bel		equ $07;
	ctrl_bs			equ $08;
	ctrl_ht			equ $09;
	ctrl_lf			equ $0a;
	ctrl_vt			equ $0b;
	ctrl_ff			equ $0c;
	ctrl_cr			equ $0d;
	ctrl_fs			equ $1c;
	ctrl_gs			equ $1d;
	ctrl_rs			equ $1e;
	ctrl_us			equ $1f;


;	// hidden number marker

	number_mark		equ $0e;


;	// printable characters

	pchr_copyright	equ $00
	pchr_euro		equ $ff


;	// operators

	op_bin			equ '%';
	op_hex			equ '$';
	op_oct			equ '@';


;	// substitutes

	sb_and			equ '&'
	sb_not			equ '~'
	sb_or			equ '|'
	sb_print		equ '?'


;	// i/o ports

	stick			equ   $1f
	mmu				equ	  $f4
	ay_tmxdat		equ	  $f6
	ula				equ	  $fe
	scld			equ	  $ff
	ulaplus_reg		equ	$bf3b
	ulaplus_dat		equ	$ff3b
	mouse_b			equ $fadf
	mouse_x			equ $fbdf
	mouse_y			equ $ffdf
	ay_reg			equ	$c0f5
	paging			equ	$7ffd
	ay_128reg		equ $fffd
	ay_128dat		equ	$bffd


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


;	// frame buffer

	bit_map		equ $c000
	char_map	equ $d800
	tstack		equ $dfc0
	pal_map		equ $dfc0
	attr_map	equ $e000
	font		equ	$f800		


;	// keyboard buffer

	k_buff		equ $5b00;
	k_buff_sz	equ %01111111;		// 128 bytes


;	// system variables

	oldsp		equ $5bba;			// (iy - $80)	old stack pointer

	open_x		equ mstate - 2;		// (iy - $42)	address of custom OPEN routine
	mstate		equ jstate - 4;		// (iy - $40)	mouse state
	jstate		equ k_head - 1;		// (iy - $3d)	joystick state
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
	rasp		equ	seg + 2;		// (iy - $02)	length of error sound in 60ths of a second; normally 60
	pip			equ	rasp + 1;		// (iy - $01)	length of keyboard click (normally zero)
	err_nr		equ	pip + 1;		// (iy + $00)	error number

	flags		equ	err_nr + 1;		// (iy + $01)	first flags byte
	flg_space	equ 0;				// set to suppress a leading space
;									// 1: RESERVED (set if ZX Printer is in use)
;									// 2: RESERVED (1='L' mode, 0='K' mode. temporary value)
;									// 3: RESERVED (1='L' mode, 0='K' mode)
;									// 4: RESERVED (1=128 BASIC, 0=48 BASIC)
	flg_macro	equ 5;				// set unless macros enabled
	flg_num		equ 6;				// set if scanning result is numeric
	flg_syntax	equ 7;				// set unless checking syntax

	vdu_flag	equ	flags + 1;		// (iy + $02)	display flags
	flg_lower	equ 0;				// set if lower screen in use
;									// 1: RESERVED
;									// 2: RESERVED
	flg_edit	equ 3;				// set if editing a line
	flg_auto	equ 4;				// set if automatic listing required
	flg_cl_low	equ 5;				// set if lower screen to be cleared
;									// 6: RESERVED
;									// 7: RESERVED

	err_sp		equ	vdu_flag + 1;	// (iy + $03)	SP value to use when an error occurs
	list_sp		equ	err_sp + 2;		// (iy + $05)	SP value to use when an automatic list fills the screen
	mode		equ	list_sp + 2;	// (iy + $07)	cursor mode; lower, caps, alternate or control
	newppc		equ	mode + 1;		// (iy + $08)	new line to jump to
	nsppc		equ	newppc + 2;		// (iy + $0a)	new statement to jump to, or $ff
	ppc			equ	nsppc + 1;		// (iy + $0b)	current line number during program execution
	subppc		equ	ppc + 2;		// (iy + $0d)	current statement number
	bordcr		equ	subppc + 1;		// (iy + $0e)	border color in screen 1
	e_ppc		equ	bordcr + 1;		// (iy + $0f)	number of line with > cursor
	e_ppc_h		equ	e_ppc + 1;		// (iy + $10)	
	vars		equ	e_ppc + 2;		// (iy + $11)	address of variables
	dest		equ	vars + 2;		// (iy + $13)	used in variable assignments
	chans		equ	dest + 2;		// (iy + $15)	start of channels area
	curchl		equ	chans + 2;		// (iy + $17)	start of current channel
	prog		equ	curchl + 2;		// (iy + $19)	program start (address of line number of first line)
	nxtlin		equ	prog + 2;		// (iy + $1b)	address of next line in BASIC program
	datadd		equ	nxtlin + 2;		// (iy + $1d)	data address used by READ command
	e_line		equ	datadd + 2;		// (iy + $1f)	edit line start
	k_cur		equ	e_line	+2;		// (iy + $21)	address of cursor in the edit line
	ch_add		equ	k_cur + 2;		// (iy + $23)	current character address
	x_ptr		equ	ch_add + 2;		// (iy + $25)	address in the edit line of a syntax error
	worksp		equ	x_ptr + 2;		// (iy + $27)	workspace start
	stkbot		equ	worksp + 2;		// (iy + $29)	address of bottom of calculator stack
	stkend		equ	stkbot + 2;		// (iy + $2b)	end of floating point calculator stack
	stkend_h	equ	stkend + 1;		// (iy + $2c)	
	breg		equ	stkend + 2;		// (iy + $2d)	calculator’s B register
	mem			equ	breg + 1;		// (iy + $2e)	start of calculator’s memory area

	flags2		equ	mem + 2;		// (iy + $30)	second flag byte
	flg_main	equ 0;				// set if main screen to be cleared
	flg_screen	equ 1;				// set if screen 1 in use
	flg_colon	equ 2;				// set if a ':' is within quotes
	flg_caps	equ 3;				// set if caps lock on
	flg_kchan	equ 4;				// set if 'K' channel is use
;									// 5: NOT USED
;									// 6: NOT USED
	flg_trace	equ 7;				// set if trace enabled

	df_sz		equ	flags2 + 1;		// (iy + $31)	number of lines (including one blank line) in the lower part of the screen
	s_top		equ	df_sz + 1;		// (iy + $32)	line number of top line in an automatic listing
	oldppc		equ	s_top + 2;		// (iy + $34)	line number that CONT goes to
	osppc		equ	oldppc + 2;		// (iy + $36)	tatement number that CONT goes to

	flagx		equ	osppc + 1;		// (iy + $37)	flags for INPUT command and editor
	flg_str		equ 0;				// set if handling a simple string
	flg_var		equ 1;				// set if handling a new variable
;									// 2: NOT USED
;									// 3: NOT USED
;									// 4: NOT USED
	flg_inp		equ 5;				// set if in input mode
;									// 6: NOT USED
	flg_line	equ 7;				// set if handling INPUT LINE

	strlen		equ	flagx + 1;		// (iy + $38)	length of string type destination in assignment
	t_addr		equ	strlen + 2;		// (iy + $3a)	address of next item in syntax table
	seed		equ	t_addr + 2;		// (iy + $3c)	seed for RND (set by RANDOMIZE)
	frame		equ	seed + 2;		// (iy + $3e)	cuurent frame (0-49 PAL / 0-59 NTSC)
	time_t		equ	frame + 1;		// (iy + $3f)	POSIX time (unsigned)
	coords		equ	time_t + 4;		// (iy + $43)	pixel co-ordinates
	coord_y		equ	time_t + 4;		// (iy + $43)	y pixel co-ordinate (0-255)
	coord_x		equ	coord_y + 1;	// (iy + $44)	x pixel co-ordinate (0-65535)
	nmiadd		equ	coord_x + 2;	// (iy + $46)	address to jump to on NMI
	echo_e		equ	nmiadd + 2;		// (iy + $48)	column number and line number (in lower half) of end of input buffer
	df_cc		equ	echo_e + 2;		// (iy + $4a)	address in display file of upper window PRINT position
	df_ccl		equ	df_cc + 2;		// (iy + $4c)	address in display file of lower window PRINT position
	s_posn		equ	df_ccl + 2;		// (iy + $4e)	upper window position as column/row
	s_posn_h	equ	s_posn + 1;		// (iy + $4f)	
	sposnl		equ	s_posn + 2;		// (iy + $50)	lower window position as column/row
	sposnl_h	equ	sposnl + 1;		// (iy + $51)	
	scr_ct		equ	sposnl + 2;		// (iy + $52)	counter used to give “Scroll?” prompt
	attr_p		equ	scr_ct + 1;		// (iy + $53)	attributes (foregorund and background in screen 0 or attribute byte in screen 1)
	mask_p		equ	attr_p + 1;		// (iy + $54)	NOT USED
	attr_t		equ	mask_p + 1;		// (iy + $55)	NOT USED
	mask_t		equ	attr_t + 1;		// (iy + $56)	NOT USED

	p_flag		equ	mask_t + 1;		// (iy + $57)	print flag
	flg_over	equ 0;				// set if OVER in use
;									// 1: NOT USED
	flg_inv		equ 2;				// set if INVERSE in use
;									// 3: NOT USED
;									// 4: NOT USED
;									// 5: NOT USED
;									// 6: NOT USED
;									// 7: NOT USED

	membot		equ	p_flag + 1;		// (iy + $58)	calculator’s memory area
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
	dosvar		equ	membot + 30;	// (iy + $76)	used by the operating system
	ramtop		equ	dosvar + 2;		// (iy + $78)	address of last byte of BASIC system area
	p_ramt		equ	ramtop + 2;		// (iy + $7a)	address of last byte of physical RAM
	channels	equ	p_ramt + 2;		// (iy + $7c)	start of channels data


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
