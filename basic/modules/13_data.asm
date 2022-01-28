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

;	// addresses $3d00 to $3fff are trapped by the divIDE / divMMC hardware
;	// these addresses must not contain code or when the PC is in this range, paging will take place.

;	// --- DATA TABLES ---------------------------------------------------------

;	// Executable code cannot be stored between $3d00 and $3fff because the
;	// divMMC hardware traps these locations

;	// Data stored from $4000 is located in RAM and can be modified by the boot
;	// ROM or the user

	org $3d00;

;	// used in 14_screen_40
;	// attributes are stored internally with the foreground in the high nibble and the background in the low nibble
;	// this table converts an attribute to its 64-color equivalent in the default palette.
;	// must be stored on an edge so that $hh + attibute byte will give the correct converted attribute value

attributes:
	defb $00, $08, $10, $18, $20, $28, $30, $38, $80, $88, $90, $98, $a0, $a8, $b0, $b8; background 0-15, foreground 0
	defb $01, $09, $11, $19, $21, $29, $31, $39, $81, $89, $91, $99, $a1, $a9, $b1, $b9; background 0-15, foreground 1
	defb $02, $0a, $12, $1a, $22, $2a, $32, $3a, $82, $8a, $92, $9a, $a2, $aa, $b2, $ba; background 0-15, foreground 2
	defb $03, $0b, $13, $1b, $23, $2b, $33, $3b, $83, $8b, $93, $9b, $a3, $ab, $b3, $bb; background 0-15, foreground 3
	defb $04, $0c, $14, $1c, $24, $2c, $34, $3c, $84, $8c, $94, $9c, $a4, $ac, $b4, $bc; background 0-15, foreground 4
	defb $05, $0d, $15, $1d, $25, $2d, $35, $3d, $85, $8d, $95, $9d, $a5, $ad, $b5, $bd; background 0-15, foreground 5
	defb $06, $0e, $16, $1e, $26, $2e, $36, $3e, $86, $8e, $96, $9e, $a6, $ae, $b6, $be; background 0-15, foreground 6
	defb $07, $0f, $17, $1f, $27, $2f, $37, $3f, $87, $8f, $97, $9f, $a7, $af, $b7, $bf; background 0-15, foreground 7
	defb $40, $48, $50, $58, $60, $68, $70, $78, $c0, $c8, $d0, $d8, $e0, $e8, $f0, $f8; background 0-15, foreground 8
	defb $41, $49, $51, $59, $61, $69, $71, $79, $c1, $c9, $d1, $d9, $e1, $e9, $f1, $f9; background 0-15, foreground 9
	defb $42, $4a, $52, $5a, $62, $6a, $72, $7a, $c2, $ca, $d2, $da, $e2, $ea, $f2, $fa; background 0-15, foreground 10
	defb $43, $4b, $53, $5b, $63, $6b, $73, $7b, $c3, $cb, $d3, $db, $e3, $eb, $f3, $fb; background 0-15, foreground 11
	defb $44, $4c, $54, $5c, $64, $6c, $74, $7c, $c4, $cc, $d4, $dc, $e4, $ec, $f4, $fc; background 0-15, foreground 12
	defb $45, $4d, $55, $5d, $65, $6d, $75, $7d, $c5, $cd, $d5, $dd, $e5, $ed, $f5, $fd; background 0-15, foreground 13
	defb $46, $4e, $56, $5e, $66, $6e, $76, $7e, $c6, $ce, $d6, $de, $e6, $ee, $f6, $fe; background 0-15, foreground 14
	defb $47, $4f, $57, $5f, $67, $6f, $77, $7f, $c7, $cf, $d7, $df, $e7, $ef, $f7, $ff; background 0-15, foreground 15

copyright:

ifndef slam
	defb "CHLOE 280SE 512K Personal Color Computer", ctrl_cr;
	defb "Copyright (C)1999 Chloe Corporation", ctrl_cr;
endif

ifdef slam
	defb "ZX Spectrum 128 Personal Computer", ctrl_cr;
	defb "Copyright (C)1985 Sinclair Research Ltd.", ctrl_cr;
endif

	defb ctrl_cr;
	defb "SE BASIC IV 4.2 Cordelia", ctrl_cr;
	defb "Copyright (C)2022 Source Solutions, Inc.", ctrl_cr;
	defb ctrl_cr;
	timestamp 'YY-MM-DD h:m';			// RASM directive
;	defb "Release YYMMDD";				// 
	defb ctrl_cr, ctrl_cr, 0;

bytes_free:
	defb " BASIC bytes free", ctrl_cr;
	defb ctrl_cr, 0;

;	// used in 02_tokenizer

sbst_chr_tbl:
	defb '[', '(';						// (
	defb ']', ')';						// )
	defb '?', tk_print;					// PRINT
	defb '&', tk_and;					// AND
	defb '~', tk_not;					// NOT
	defb '|', tk_or;					// OR
	defb 0;								// null end marker

;	// used in 04_audio
semi_tone:
	deff 261.625565300599;				// C
	deff 277.182630976872;				// C#
	deff 293.664767917408;				// D
	deff 311.126983722081;				// D#
	deff 329.627556912870;				// E
	deff 349.228231433004;				// F
	deff 369.994422711634;				// F#
	deff 391.995435981749;				// G
	deff 415.304697579945;				// G#
	deff 440.000000000000;				// A
	deff 466.163761518090;				// A#
	deff 493.883301256124;				// B

;	// used in 05_miscellaneous
renum_tbl:
	defb tk_restore;
	defb tk_goto;
	defb tk_gosub;
	defb tk_list;
	defb tk_run;

;	// used in 06_screen_80
;	// deals with virtual columns that cross real columns and display files
rtable:
	defw pos_0;
	defw pos_1;
	defw pos_2;
	defw pos_3;
	defw pos_4;
	defw pos_5;
	defw pos_6;
	defw pos_7;

;	// used in 08_executive
init_strm:
	defb $01, $00;						// stream $fd, channel K
	defb $06, $00;						// stream $fe, channel S
	defb $0b, $00;						// stream $ff, channel W
	defb $01, $00;						// stream $00, channel K
	defb $01, $00;						// stream $01, channel K
	defb $06, $00;						// stream $02, channel S

init_chan:
	defw print_out, key_input;			// keyboard
	defb 'K';							// channel
	defw print_out, file_in;			// screen
	defb 'S';							// channel
	defw add_char, report_bad_io_dev;	// workspace
	defb 'W';							// channel
	defb end_marker;					// no more channels

file_chan:
	defw file_out, file_in;				// file
	defb 'F';							// channel
	defw 8;								// length of channel

;	// used in 10_expression
tbl_ops_priors:
	defb '+', op_fadd + %11000000, 8;	// +
	defb '-', op_fsub + %11000000, 8;	// -
	defb '*', op_fmul + %11000000, 11;	// *
	defb '/', op_fdiv + %11000000, 11;	// /
	defb '^', op_fexp + %11000000, 12;	// ^
	defb '=', $0e + %11000000, 7;		// =  fcp(_eq)
	defb '>', $0c + %11000000, 7;		// >  fcp(_gt)
	defb '<', $0d + %11000000, 7;		// <  fcp(_lt)
	defb tk_l_eql, $09 + %11000000, 7;	// <= fcp(_le)
	defb tk_gr_eq, $0a + %11000000, 7;	// >= fcp(_ge)
	defb tk_neql, $0b + %11000000, 7;	// <> fcp(ne)
	defb tk_or, op_fbor + %11000000, 4;	// OR
	defb tk_and, op_fband + $c0, 5;		// AND
	defb tk_xor, op_fxor + %11000000, 3;// XOR
	defb tk_mod, op_fmod + %11000000, 9;// MOD
	defb '\\', op_fquot + %11000000, 10;// \
	defb 0;								// null terminator

;	// note priority is always $10 except for NOT which is $06
;	// bit 6 = input, bit 7 = output; 0 = string, 1 = number

tbl_prefix_ops:
	defb op_fabs	+ %11000000;		// ABS
	defb op_facos	+ %11000000;		// ACOS
	defb op_fasc	+ %10000000;		// ASC
	defb op_fasin	+ %11000000;		// ASIN
	defb op_fatan	+ %11000000;		// ATAN
	defb op_fchrs	+ %01000000;		// CHR$
	defb op_fcos	+ %11000000;		// COS
	defb op_fdeek	+ %11000000;		// DEEK
	defb op_fexp	+ %11000000;		// EXP
	defb op_ftrn	+ %11000000;		// FIX
	defb op_finp	+ %11000000;		// INP
	defb op_fint	+ %11000000;		// INT
	defb op_flen	+ %10000000;		// LEN
	defb op_flogn	+ %11000000;		// LOG
	defb op_fnot	+ %11000000;		// NOT
	defb op_fpeek	+ %11000000;		// PEEK
	defb op_fsin	+ %11000000;		// SIN
	defb op_fsgn	+ %11000000;		// SGN
	defb op_fsqrt	+ %11000000;		// SQR
	defb op_ftan	+ %11000000;		// TAN
	defb op_fusr	+ %11000000;		// USR
	defb op_fval	+ %10000000;		// VAL
	defb op_fvals	+ %00000000;		// VAL$

;	// used in 12_calculator
constants:
	defb $00, $00, $00, $00, $00;		// 0
	defb $00, $00, $01, $00, $00;		// 1
	defb $80, $00, $00, $00, $00;		// 0.5
	defb $81, $49, $0f, $da, $a2;		// pi / 2 (pi = 3.14159265358979)
	defb $00, $00, $0a, $00, $00;		// 10

tbl_addrs:
	op_fjpt equ $00;
	defw fp_jump_true;
	op_fxch equ $01;
	defw fp_exchange;
	op_fdel equ $02;
	defw fp_delete;
	op_fsub equ $03;
	defw fp_subtract;
	op_fmul equ $04;
	defw fp_multiply;
	op_fdiv equ $05;
	defw fp_division;
	op_ftop equ $06;
	defw fp_to_power;
	op_fbor equ $07;
	defw fp_or;
	op_fband equ $08;
	defw fp_no_and_no;
	op_fcp equ $09;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	op_fadd equ $0f;
	defw fp_addition;
	op_bands equ $10;
	defw fp_str_and_no;
	op_fcps equ $11;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	op_fcat equ $17;
	defw fp_strs_add;
	op_fvals equ $18;
	defw fp_val_str;
	op_fmuls equ $19;
	defw fp_mul_str;
	op_fread equ $1a;
	defw fp_read_in;
	op_fneg equ $1b;
	defw fp_negate;
	op_fasc equ $1c;
	defw fp_asc;
	op_fval equ $1d;
	defw fp_val;
	op_flen equ $1e;
	defw fp_len;
	op_fsin equ $1f;
	defw fp_sin;
	op_fcos equ $20;
	defw fp_cos;
	op_ftan equ $21;
	defw fp_tan;
	op_fasin equ $22;
	defw fp_asin;
	op_facos equ $23;
	defw fp_acos;
	op_fatan equ $24;
	defw fp_atan;
	op_flogn equ $25;
	defw fp_log;
	op_fexp equ $26;
	defw fp_exp;
	op_fint equ $27;
	defw fp_int;
	op_fsqrt equ $28;
	defw fp_sqr;
	op_fsgn equ $29;
	defw fp_sgn;
	op_fabs equ $2a;
	defw fp_abs;
	op_fpeek equ $2b;
	defw fp_peek;
	op_finp equ $2c;
	defw fp_inp;
	op_fusr equ $2d;
	defw fp_usr_no;
	op_fstrs equ $2e;
	defw fp_str_str;
	op_fchrs equ $2f;
	defw fp_chr_str;
	op_fnot equ $30;
	defw fp_not;
	op_fmove equ $31;
	defw fp_duplicate;
	op_fmod equ $32;
	defw fp_n_mod_m;
	op_fjp equ $33;
	defw fp_jump;
	op_fstk equ $34;
	defw fp_stk_data;
	op_fdjnz equ $35;
	defw fp_dec_jr_nz;
	op_fltz equ $36;
	defw fp_less_0;
	op_fgtz equ $37;
	defw fp_greater_0;
	op_fce equ $38;
	defw fp_end_calc;
	op_fget equ $39;
	defw fp_get_argt;
	op_ftrn equ $3a;
	defw fp_truncate;
	op_fsgl equ $3b;
	defw fp_calc_2;
	op_fdeek equ $3c;
	defw fp_deek;
	op_frstk equ $3d;
	defw fp_re_stack;
	op_fxor equ $3e;
	defw fp_xor;
	op_fquot equ $3f;
	defw fp_quot;

tbl_offs equ $ - tbl_addrs
	defw fp_series_xx;
	defw fp_stk_const_xx;
	defw fp_st_mem_xx;
	defw fp_get_mem_xx;

;	// used in 07_editor
ed_f_keys_t:
	defb s_f1 - $;						// $11
	defb s_f2 - $;						// $12
	defb s_f3 - $;						// $13
	defb s_f4 - $;						// $14
	defb s_f5 - $;						// $15
	defb s_f6 - $;						// $16
	defb s_f7 - $;						// $17
	defb s_f8 - $;						// $18
	defb s_f9 - $;						// $19
	defb s_f10 - $;						// $1a
	defb s_f11 - $;						// $1b
	defb s_f12 - $;						// $1c
	defb s_f13 - $;						// $1d
	defb s_f14 - $;						// $1e
	defb s_f15 - $;						// $1f

;	// macro definitions
;	// each definition is 16 bytes. The last byte is always zero.
s_f1:
	defb "LIST", 0
	defs 11, 0

s_f2:
	defb "RUN", ctrl_cr, 0;
	defs 11, 0

s_f3:
	defb "LOAD ",'"', 0;";
	defs 9, 0

s_f4:
	defb "SAVE ",'"', 0;";
	defs 9, 0

s_f5:
	defb "CONT", ctrl_cr, 0;
	defs 10, 0

s_f6:
	defb "COLOR 7,1", ctrl_cr, 0;
	defs 5, 0

s_f7:
	defb "TRON", ctrl_cr, 0;
	defs 10, 0

s_f8:
	defb "TROFF", ctrl_cr, 0;
	defs 9, 0

s_f9:
	defb "EDIT ", 0;
	defs 10, 0

s_f10:
	defb "SCREEN ", 0;
	defs 8, 0

s_f11:
	defb "BLOAD ",'"', 0;";
	defs 8, 0

s_f12:
	defb "BSAVE ",'"', 0;";
	defs 8, 0

s_f13:
	defb "GOSUB ", 0;
	defs 9, 0

s_f14:
	defb "GOTO ", 0;
	defs 10, 0

s_f15:
	defb "KEY ", 0;
	defs 11, 0

;	// used in 03_keyboard
kt_main:
	defb "BHY65TGVNJU74RFCMKI83EDX", key_koru;
	defb "LO92WSZ ", key_return, "P01QA",0;

kt_ctrl:
	defb key_f9
	defb key_f7;										// substitution
	defb key_f5, key_f3, key_f1, key_f2, key_f12
	defb key_f11;										// substitution
	defb key_f10;
	defb key_f8, key_f6, key_f4;
	defb key_f13, key_f14, key_f15;						// substitution

kt_dig_shft:
	defb key_backspace, key_tab, key_caps, key_pg_up, key_pg_dn;
	defb key_left, key_down, key_up, key_right, key_control;

kt_alpha_sym:
	defb "~*?\\", key_end, "{}^", key_ins, "-+=.,;", '"', key_home, "<|>]/", key_delete, "`[:";"

kt_dig_sym:
	defb "_!@#$%&'()";

;	// used in 02_tokenizer and 06_screen_80
token_table:
	defb end_marker;

;	// exceptional functions (no arguments, and so on)
	first_tk		equ $80
	tk_eof			equ $80;
	str "EOF #";
	tk_fn			equ $81;
	str "FN";
	tk_inkey_str	equ $82;
	str "INKEY$";
	tk_loc			equ $83;
	str "LOC #";
	tk_lof			equ $84;
	str "LOF #";
	tk_pi			equ $85;
	str "PI";
	tk_rnd			equ $86;
	str "RND";

;	// multi-argument functions
	tk_left_str		equ $87
	str "LEFT$";
	tk_mid_str		equ $88
	str "MID$";
	tk_right_str	equ $89
	str "RIGHT$";
	tk_str_str		equ $8a;
	str "STR$";
	tk_string_str	equ $8b;
	str "STRING$";

;	// PRINT arguments
	tk_spc			equ $8c;
	str "SPC";
	tk_tab			equ $8d;
	str "TAB";

;	// prefix operators (single-argument functions)
	tk_abs			equ $8e;
	str "ABS";
	tk_acos			equ $8f;
	str "ACOS";
	tk_asc			equ $90;
	str "ASC";
	tk_asin			equ $91;
	str "ASIN";
	tk_atan			equ $92;
	str "ATAN";
	tk_chr_str		equ $93;
	str "CHR$";
	tk_cos			equ $94;
	str "COS";
	tk_deek			equ $95;
	str "DEEK";
	tk_exp			equ $96;
	str "EXP";
	tk_fix			equ $97;
	str "FIX";
	tk_inp			equ $98;
	str "INP";
	tk_int			equ $99;
	str "INT";
	tk_len			equ $9a;
	str "LEN";
	tk_log			equ $9b;
	str "LOG";
	tk_not			equ $9c;
	str "NOT";
	tk_peek			equ $9d;
	str "PEEK";
	tk_sin			equ $9e;
	str "SIN";
	tk_sgn			equ $9f;
	str "SGN";
	tk_sqr			equ $a0;
	str "SQR";
	tk_tan			equ $a1;
	str "TAN";
	tk_usr			equ $a2;
	str "USR";
	tk_val			equ $a3;
	str "VAL";
	tk_val_str		equ $a4;
	str "VAL$";

;	// infix operators
	tk_mod			equ $a5;
	str "MOD";
	tk_neql			equ $a6;
	str "<>";
	tk_l_eql		equ $a7;
	str "<=";
	tk_gr_eq		equ $a8;
	str ">=";
	tk_and			equ $a9;
	str "AND";
	tk_or			equ $aa;
	str "OR";
	tk_xor			equ $ab;
	str "XOR";

;	// other keywords
	tk_line			equ $ac;
	str "LINE";
	tk_step			equ $ad;
	str "STEP";
	tk_then			equ $ae;
	str "THEN";
	tk_to			equ $af;
	str "TO";

;	// unassigned tokens
	tk__b0			equ $b0;
	str "_B0";
	tk__b1			equ $b1;
	str "_B1";
	tk__b2			equ $b2;
	str "_B2";
	tk__b3			equ $b3;
	str "_B3";
	tk__b4			equ $b4;
	str "_B4";
	tk__b5			equ $b5;
	str "_B5";
	tk__b6			equ $b6;
	str "_B6";
	tk__b7			equ $b7;
	str "_B7";
	tk__b8			equ $b8;
	str "_B8";
	tk__b9			equ $b9;
	str "_B9";
	tk__ba			equ $ba;
	str "_BA";
	tk__bb			equ $bb;
	str "_BB";
	tk__bc			equ $bc;
	str "_BC";
	tk__bd			equ $bd;
	str "_BD";
	tk__be			equ $be;
	str "_BE";
	tk__bf			equ $bf;
	str "_BF";
	tk__c0			equ $c0;
	str "_C0";
	tk__c1			equ $c1;
	str "_C1";
	tk__c2			equ $c2;
	str "_C2";
	tk__c3			equ $c3;
	str "_C3";

;	// commands
	first_cmd		equ $c4;
	tk_else			equ $c4;
	str "ELSE";
	tk_bload		equ $c5;
	str "BLOAD";
	tk_bsave		equ $c6;
	str "BSAVE";
	tk_call			equ $c7;
	str "CALL";
	tk_chdir		equ $c8;
	str "CHDIR";
	tk_clear		equ $c9;
	str "CLEAR";
	tk_close		equ $ca;
	str "CLOSE #";
	tk_cls			equ $cb;
	str "CLS";
	tk_color		equ $cc;
	str "COLOR";
	tk_cont			equ $cd;
	str "CONT";
	tk_copy			equ $ce;
	str "COPY";
	tk_data			equ $cf;
	str "DATA";
	tk_def			equ $d0;
	str "DEF FN";
	tk_delete		equ $d1;
	str "DELETE";
	tk_dim			equ $d2;
	str "DIM";
	tk_doke			equ $d3;
	str "DOKE";
	tk_edit			equ $d4;
	str "EDIT";
	tk_end			equ $d5;
	str "END";
	tk_error		equ $d6;
	str "ERROR";
	tk_files		equ $d7;
	str "FILES";
	tk_for			equ $d8;
	str "FOR";
	tk_gosub		equ $d9;
	str "GOSUB";
	tk_goto			equ $da;
	str "GOTO";
	tk_if			equ $db;
	str "IF";
	tk_input		equ $dc;
	str "INPUT";
	tk_key			equ $dd;
	str "KEY";
	tk_kill			equ $de;
	str "KILL";
	tk_let			equ $df;
	str "LET";
	tk_list			equ $e0;
	str "LIST";
	tk_load			equ $e1;
	str "LOAD";
	tk_locate		equ $e2;
	str "LOCATE";
	tk_merge		equ $e3;
	str "MERGE";
	tk_mkdir		equ $e4;
	str "MKDIR";
	tk_name			equ $e5;
	str "NAME";
	tk_next			equ $e6;
	str "NEXT";
	tk_new			equ $e7;
	str "NEW";
	tk_old			equ $e8;
	str "OLD";
	tk_on			equ $e9;
	str "ON";
	tk_open			equ $ea;
	str "OPEN #";
	tk_out			equ $eb;
	str "OUT";
	tk_palette		equ $ec;
	str "PALETTE";
	tk_poke			equ $ed;
	str "POKE";
	tk_print		equ $ee;
	str "PRINT";
	tk_randomize	equ $ef;
	str "RANDOMIZE";
	tk_read			equ $f0;
	str "READ";

tk_ptr_rem:
	tk_rem			equ $f1;
	str "REM";
	tk_renum		equ $f2;
	str "RENUM";
	tk_restore		equ $f3;
	str "RESTORE";
	tk_return		equ $f4;
	str "RETURN";
	tk_rmdir		equ $f5;
	str "RMDIR";
	tk_run			equ $f6;
	str "RUN";
	tk_save			equ $f7;
	str "SAVE";
	tk_screen		equ $f8;
	str "SCREEN";
	tk_sound		equ $f9;
	str "SOUND";
	tk_stop			equ $fa;
	str "STOP";
	tk_troff		equ $fb;
	str "TROFF";
	tk_tron			equ $fc;
	str "TRON";
	tk_wait			equ $fd;
	str "WAIT";
	tk_wend			equ $fe;
	str "WEND";
	
tk_ptr_last:
	tk_while		equ $ff;
	str "WHILE";

;	// used in 09_command
offst_tbl:
	defw p_else;
	defw p_bload;
	defw p_bsave;
	defw p_call;
	defw p_chdir;
	defw p_clear;
	defw p_close;
	defw p_cls;
	defw p_color;
	defw p_cont;
	defw p_copy;
	defw p_data;
	defw p_def;
	defw p_delete;
	defw p_dim;
	defw p_doke;
	defw p_edit;
	defw p_end;
	defw p_error;
	defw p_files;
	defw p_for;
	defw p_gosub;
	defw p_goto;
	defw p_if;
	defw p_input;
	defw p_key
	defw p_kill;
	defw p_let;
	defw p_list;
	defw p_load;
	defw p_locate;
	defw p_merge;
	defw p_mkdir;
	defw p_name;
	defw p_next;
	defw p_new;
	defw p_old;
	defw p_on;
	defw p_open;
	defw p_out;
	defw p_palette;
	defw p_poke;
	defw p_print;
	defw p_randomize;
	defw p_read;
	defw p_rem;
	defw p_renum;
	defw p_restore;
	defw p_return;
	defw p_rmdir;
	defw p_run
	defw p_save;
	defw p_screen;
	defw p_sound;
	defw p_stop;
	defw p_troff;
	defw p_tron;
	defw p_wait;
	defw p_wend;
	defw p_while;

;	// parameter table
p_else:
	defb var_syn;
	defw c_else;

p_bload:
	defb str_exp, ',', num_exp_no_f_ops;
	defw c_bload;

p_bsave:
	defb str_exp, ',', num_exp, ',', num_exp_no_f_ops;
	defw c_bsave;

p_call:
	defb num_exp_no_f_ops;
	defw c_call;

p_chdir:
	defb str_exp_no_f_ops;
	defw c_chdir;

p_clear:
	defb num_exp_0;
	defw c_clear;

p_close:
	defb num_exp_no_f_ops;
	defw c_close;

p_cls:
	defb no_f_ops;
	defw c_cls;

p_color:
	defb two_c_s_num_no_f_ops;
	defw c_color;

p_cont:
	defb no_f_ops;
	defw c_cont;

p_copy:
	defb str_exp, tk_to, str_exp_no_f_ops;
	defw c_copy;

p_data:
	defb var_syn;
	defw c_data;

p_def:
	defb var_syn;
	defw c_def;

p_delete:
	defb num_exp, ',', num_exp_no_f_ops;
	defw c_delete;

p_dim:
	defb var_syn;
	defw c_dim;

p_doke:
	defb two_c_s_num_no_f_ops;
	defw c_doke;

p_edit:
	defb num_exp_0;
	defw c_edit;

p_end:
	defb no_f_ops;
	defw c_end;

p_error:
	defb num_exp_no_f_ops;
	defw c_error;

p_files:
	defb var_syn;
	defw c_files;

p_for:
	defb chr_var, "=", num_exp, tk_to, num_exp, var_syn;
	defw c_for;

p_gosub:
	defb num_exp_no_f_ops;
	defw c_gosub;

p_goto:
	defb num_exp_no_f_ops;
	defw c_goto;

p_if:
	defb num_exp, tk_then, var_syn;
	defw c_if;

p_input:
	defb var_syn;
	defw c_input;

p_key:
	defb var_syn;
	defw c_key;

p_kill:
	defb str_exp_no_f_ops;
	defw c_kill;

p_let:
	defb var_rqd, '=', expr_num_str;

p_list:
	defb var_syn;
	defw c_list;

p_load:
	defb str_exp_no_f_ops;
	defw c_load;

p_locate:
	defb two_c_s_num_no_f_ops;
	defw c_locate;

p_merge:
	defb str_exp_no_f_ops;
	defw c_merge;

p_mkdir:
	defb str_exp_no_f_ops;
	defw c_mkdir;

p_name:
	defb str_exp, tk_to, str_exp_no_f_ops;
	defw c_name;

p_next:
	defb chr_var, no_f_ops;
	defw c_next;

p_new:
	defb no_f_ops;
	defw c_new;

p_old:
	defb no_f_ops;
	defw c_old;

p_on:
	defb var_syn;
	defw c_on;

p_open:
	defb num_exp, ',', str_exp, var_syn;
	defw c_open;

p_out:
	defb two_c_s_num_no_f_ops;
	defw c_out;

p_palette:
	defb two_c_s_num_no_f_ops;
	defw c_palette;

p_poke:
	defb two_c_s_num_no_f_ops;
	defw c_poke;

p_print:
	defb var_syn;
	defw c_print;

p_randomize:
	defb num_exp_0;
	defw c_randomize;

p_read:
	defb var_syn;
	defw c_read;

p_rem:
	defb var_syn;
	defw c_rem;

p_renum:
	defb var_syn;
	defw c_renum;

p_restore:
	defb num_exp_0;
	defw c_restore;

p_return:
	defb no_f_ops;
	defw c_return;

p_rmdir:
	defb str_exp_no_f_ops;
	defw c_rmdir;

p_run:
	defb var_syn;
	defw c_run;

p_save:
	defb str_exp_no_f_ops;
	defw c_save;

p_screen:
	defb num_exp_no_f_ops;
	defw c_screen;

p_sound:
	defb two_c_s_num_no_f_ops;
	defw c_sound;

p_stop:
	defb no_f_ops;
	defw c_stop;

p_troff:
	defb no_f_ops;
	defw c_troff;

p_tron:
	defb no_f_ops;
	defw c_tron;

p_wait:
	defb num_exp_no_f_ops;
	defw c_wait;

p_wend:
	defb no_f_ops;
	defw c_wend;

p_while:
	defb var_syn;
	defw c_while;

;	// used in 15_files
dir_msg:
	defb "<DIR>   ", 0;

;	// the following data cannot be moved to the ROM area
basepath:
	defb "/programs";					// "/programs/" (continues into progpath)

prgpath:
	defb "/prg";						// "/prg/", 0 (continues into rootpath)
	
rootpath:
	defb '/', 0;						// root	

appname:
	defb ".prg", 0;						// application extension

resources:
	defb "../rsc", 0;					// resource folder

old_bas_path:
	defb "/system/temporar.y/old.bas", 0;	// path to OLD.BAS

sys_folder:
	defb "system", 0;					// system folder name

tmp_folder:
	defb "temporar.y", 0;				// temporary folder name
