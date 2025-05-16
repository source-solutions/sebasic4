;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2024 Source Solutions, Inc.

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

;;
;	// --- DATA TABLES ---------------------------------------------------------
;;
:

	org $3c17

;	// Executable code cannot be stored between $3d00 and $3fff because the
;	// divMMC hardware traps these locations
;	//
;	// Data stored from $4000 is located in RAM and can be modified by the boot
;	// ROM or the user

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

;	// used in 16_audio

;   // calculated coarse / fine values for a 1.75Mhz clock
notes:
	defw (28 * 256) +  14;				// Cb0 - 15.434 Hz
	defw (26 * 256) + 123;				// C0  - 16.352 Hz
	defw (24 * 256) + 254;				// C#0 - 17.324 Hz
	defw (23 * 256) + 151;				// D0  - 18.354 Hz
	defw (22 * 256) +  68;				// D#0 - 19.445 Hz
	defw (21 * 256) +   4;				// E0  - 20.602 Hz
	defw (19 * 256) + 214;				// F0  - 21.827 Hz
	defw (18 * 256) + 185;				// F#0 - 23.125 Hz
	defw (17 * 256) + 172;				// G0  - 24.500 Hz
	defw (16 * 256) + 174;				// G#0 - 25.957 Hz
	defw (15 * 256) + 191;				// A0  - 27.500 Hz
	defw (14 * 256) + 220;				// A#0 - 29.135 Hz
	defw (14 * 256) +   7;				// B0  - 30.868 Hz
	defw (13 * 256) +  61;				// C1  - 32.703 Hz

;	// +1 offset in case note is flattened
semitones::
	defb 10, 12, 1, 3, 5, 6, 8;			// A, B, C, D, E, F, G

;   // multiply by 150 for BPM with 60 Hz frame counter
durations:
	defb 3;								// thirty-second note / demisemiquaver FIXME: not used
	defb 6;								// sixteenth note / semiquaver
	defb 9;								// dotted sixteenth note / dotted semiquaver
	defb 12;							// eighth note / quaver
	defb 18;							// dotted eighth note / dotted quaver
	defb 24;							// quarter note / crotchet
	defb 36;							// dotted quarter note / dotted crotchet
	defb 48;							// half note / minim
	defb 72;							// dotted quarter note / dotted minim
	defb 96;							// whole note / semibreve
	defb 4;								// twenty-fourth note / triple semiquaver
	defb 8;								// twelfth note / triple quaver
	defb 16;							// sixth note / triple crotchet

;	// 24 unused bytes
	defs 24, $ff;						// RESERVED

	org $3d00;

;	// used in 14_screen_1
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

;	// used in 16_audio

play_ttab:
;	defb "<>XZHMSVNT][LO'";				// 15 characters
	defb "<>XZHMSVT][LO'";				// 14 characters
	ttab_chars equ 14;					// used by lookup

play_tab:
	defw play_other;					// 
	defw play_comment;					// '
	defw play_octave;					// O
	defw play_scan;						// L
	defw play_rep;						// [
	defw play_rep_end;					// ]
	defw play_tempo;					// T
	defw play_volume;					// V
	defw play_envelope;					// S
	defw play_envdur;					// M
	defw play_midi_chan;				// H
	defw play_z;						// Z
	defw play_ret;						// X
	defw play_oct_inc;					// >
	defw play_oct_dec;					// <

;	// used in 10_expression
tbl_ops_priors:
	defb '+', op_fadd + %11000000, 8;	// +
	defb '-', op_fsub + %11000000, 8;	// -
	defb '*', op_fmul + %11000000, 11;	// *
	defb '/', op_fdiv + %11000000, 11;	// /
	defb '^', op_ftop + %11000000, 12;	// ^
	defb '=', $0e + %11000000, 7;		// =  fcp(eq)
	defb '>', $0c + %11000000, 7;		// >  fcp(gt)
	defb '<', $0d + %11000000, 7;		// <  fcp(lt)
	defb tk_le, $09 + %11000000, 7;		// <= fcp(le)
	defb tk_ge, $0a + %11000000, 7;		// >= fcp(ge)
	defb tk_ne, $0b + %11000000, 7;		// <> fcp(ne)
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

tab_func:
	defw s_left;
	defw s_mid;
	defw s_right;
	defw s_str;
	defw s_string_str;
	defw s_instr;

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

;	// pseudo tokens
tk_ptr_atn:
	str "ATN("
tk_ptr_colour:
	str "COLOUR"
tk_ptr_hex_str:
	str "HEX$("
tk_ptr_oct_str:
	str "OCT$("
tk_ptr_space_str:
	str "SPACE$("
tk_ptr_tron:
	str "TRON"
tk_ptr_troff:
	str "TROFF"
tk_ptr_ne:
	str "><"
tk_ptr_le:
	str "=<"
tk_ptr_ge:
	str "=>"
tk_ptr_hex:
	str "&H"
tk_ptr_oct:
	str "&O"

;	// FIXME, add shortcut for disk command CD (and perhaps others)

;	// substitute characters
sbst_chr_tbl:
	defb '[', '(';						// (
	defb ']', ')';						// )
	defb '?', tk_print;					// PRINT
	defb '&', tk_and;					// AND
	defb '~', tk_not;					// NOT
	defb '|', tk_or;					// OR
	defb 0;								// null end marker

;	// 2 unused bytes
	defs 2, $ff;						// reserved to modify copyright message

;	// copyright message
ifndef slam
copyright:
	defb "CHLOE 280SE Personal Color Computer", ctrl_cr;
	defb "Copyright (C) 1999 Chloe Corp.", ctrl_cr;
endif

ifdef slam
	defs 10, $ff;						// reserved to modify copyright message
copyright:
	defb "ZX Spectrum 128", ctrl_cr;
	defb "Copyright (C) 1985 Sinclair Research Ltd", ctrl_cr;
endif

	defb ctrl_cr;
	defb "SE BASIC 4.2.0 (GPL-3.0 License)", ctrl_cr;
	defb "Copyright (C) 2024 Source Solutions Inc.", ctrl_cr;
;	timestamp 'YY-MM-DD h:m';			// RASM directive
	defb ctrl_cr, 0;

bytes_free:
	defb " bytes free", ctrl_cr;
	defb ctrl_cr, 0;

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

	org $3ff1
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

	org $4000
;	// macro definitions
;	// each definition is 16 bytes. The last byte is always zero.
s_f1:
	defb "LIST "
	defs 11, 0;							// LIST

s_f2:
	defb "RUN", ctrl_cr;
	defs 12, 0;							// RUN <RETURN> (overridden by tab in ZX core but still works)

s_f3:
	defb "LOAD",'"', ".BAS", '"', ctrl_bs, ctrl_bs, ctrl_bs, ctrl_bs, ctrl_bs;
	defs 1, 0;							// LOAD"[].BAS"

s_f4:
	defb "SAVE",'"', ".BAS", '"', ctrl_bs, ctrl_bs, ctrl_bs, ctrl_bs, ctrl_bs;
	defs 1, 0;							// SAVE"[].BAS"

s_f5:
	defb "CONT", ctrl_cr;
	defs 11, 0;							// CONT (overriden by NMI in ZX core)

s_f6:
	defb "TRACE ";
	defs 10, 0;							// TRACE O[n|ff]

s_f7:
	defb "BLOAD ",'"', '"', ",", ctrl_bs, ctrl_bs, 0;";
	defs 4, 0;							// BLOAD "[]"

s_f8:
	defb "BSAVE ",'"', '"', ",,", ctrl_bs, ctrl_bs, ctrl_bs, 0;";
	defs 2, 0;							// BSAVE "[]"

s_f9:
	defb "KEY ", 0;
	defs 11, 0;							// KEY [n,a$|LIST]

s_f10:
	defb "SCREEN ", 0;
	defs 8, 0;							// SCREEN n

s_f11:
	defb "FILES",  ctrl_cr, 0;";
	defs 9, 0;							// FILES <RETURN>

s_f12:
	defb "CHDIR ",'"', '"', ctrl_bs, 0;";
	defs 6, 0;							// CHDIR "[]"

s_f13:
	defb "FI.", '"', "/PROGRAMS", '"', ctrl_cr, 0;";
;										// FILES "/PROGRAMS" <RETURN> (overriden but works with SHIFT held)

s_f14:
	defb "COLOR 7,1,1", ctrl_cr, 0;
	defs 3, 0;							// COLOR 7,1,1 <RETURN>

s_f15:
	defb "KEY LIST", ctrl_cr, 0;
	defs 6, 0;							// KEY LIST <RETURN> (overriden by ZX core but can be composed with F9 + F1 + <RETURN>)

;	// used in 15_files

file_chan:
	defw file_out, file_in;				// file channel
	defb 'F';							// service routine

dir_msg:
	defb "<DIR>   ", 0;

;	// the following data cannot be moved to the ROM area
basepath:
	defb "/PROGRAMS";					// "/programs/" (continues into progpath)

prgpath:
	defb "/PRG";						// "/prg/", 0 (continues into rootpath)
	
rootpath:
	defb '/', 0;						// root	

;cur_path:
;	defb '.', 0;						// current path

appname:
	defb ".PRG", 0;						// application extension

resources:
	defb "../RSC", 0;					// resource folder

old_bas_path:
	defb "/SYSTEM/TEMPORAR.Y/OLD.BAS",0;// path to OLD.BAS

sys_folder:
	defb "SYSTEM", 0;					// system folder name

tmp_folder:
	defb "TEMPORAR.Y", 0;				// temporary folder name

tmp_file:
	defb "TMP.$$$",0;					// path to temporary file

autoexec_bas:
	defb "AUTOEXEC.BAS", 0;				// filepath for AUTOEXEC.BAS

auto_run:
	defb tk_run, ctrl_cr, 0;			// inserted into keyboard buffer

help:
	defb "!HELP", ctrl_cr, 0;			// invoke HELP app

;	// this section contains tokens and commands
;	// there are currently 12 undefined tokens
;	// but the plan is to use $ff for double--byte tokens for user defined commands

;	// used in 02_tokenizer and 06_screen_80
token_table:
	defb end_marker;

;	// exceptional functions (no arguments, and so on)
	first_tk		equ $80
	tk_eof			equ $80;
	str "EOF #";
	tk_fn			equ $81;
tk_ptr_fn:
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
tk_ptr_rnd:
	str "RND";

;	// multi-argument functions
	tk_instr		equ $87;
	str "INSTR";
	tk_left_str		equ $88
	str "LEFT$";
	tk_mid_str		equ $89;
	str "MID$";
	tk_right_str	equ $8a;
	str "RIGHT$";
	tk_str_str		equ $8b;
	str "STR$";
	tk_string_str	equ $8c;
	str "STRING$";


;	// PRINT arguments
	tk_spc			equ $8d;
	str "SPC";
	tk_tab			equ $8e;
	str "TAB";
	tk_using		equ $8f
	str "USING";

;	// prefix operators (single-argument functions)
	tk_abs			equ $90;
	str "ABS";
	tk_acos			equ $91;
	str "ACOS";
	tk_asc			equ $92;
	str "ASC";
	tk_asin			equ $93;
	str "ASIN";
	tk_atan			equ $94;
	str "ATAN";
	tk_chr_str		equ $95;
	str "CHR$";
	tk_cos			equ $96;
	str "COS";
	tk_deek			equ $97;
	str "DEEK";
	tk_exp			equ $98;
	str "EXP";
	tk_fix			equ $99;
	str "FIX";
	tk_inp			equ $9a;
	str "INP";
	tk_int			equ $9b;
	str "INT";
	tk_len			equ $9c;
	str "LEN";
	tk_log			equ $9d;
	str "LOG";
	tk_not			equ $9e;
	str "NOT";
	tk_peek			equ $9f;
	str "PEEK";
	tk_sin			equ $a0;
	str "SIN";
	tk_sgn			equ $a1;
	str "SGN";
	tk_sqr			equ $a2;
	str "SQR";
	tk_tan			equ $a3;
	str "TAN";
	tk_usr			equ $a4;
	str "USR";
	tk_val			equ $a5;
	str "VAL";
	tk_val_str		equ $a6;
	str "VAL$";

;	// infix operators
	tk_mod			equ $a7;
	str "MOD";
	tk_ne			equ $a8;
	str "<>";
	tk_le			equ $a9;
	str "<=";
	tk_ge			equ $aa;
	str ">=";
	tk_and			equ $ab;
	str "AND";
	tk_or			equ $ac;
	str "OR";
	tk_xor			equ $ad;
	str "XOR";

;	// other keywords
	tk_line			equ $ae;
	str "LINE";
	tk_off			equ $af;
tk_ptr_off:
	str "OFF";
	tk_step			equ $b0;
	str "STEP";
	tk_then			equ $b1;
tk_ptr_then:
	str "THEN";
	tk_to			equ $b2;
	str "TO";

;	// unassigned tokens
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

;	// commands
	first_cmd		equ $bf;
	tk_beep			equ $bf;
	str "BEEP";
	tk_bload		equ $c0;
	str "BLOAD";
	tk_bsave		equ $c1;
	str "BSAVE";
	tk_call			equ $c2;
	str "CALL";
	tk_chdir		equ $c3;
	str "CHDIR";
	tk_circle		equ $c4;
	str "CIRCLE";
	tk_clear		equ $c5;
	str "CLEAR";
	tk_close		equ $c6;
	str "CLOSE";
	tk_cls			equ $c7;
	str "CLS";
	tk_color		equ $c8;
	str "COLOR";
	tk_cont			equ $c9;
	str "CONT";
	tk_copy			equ $ca;
	str "COPY";
	tk_data			equ $cb;
	str "DATA";
	tk_def			equ $cc;
	str "DEF FN";
	tk_delete		equ $cd;
	str "DELETE";
	tk_dim			equ $ce;
	str "DIM";
	tk_doke			equ $cf;
	str "DOKE";
	tk_draw			equ $d0;
	str "DRAW";
	tk_edit			equ $d1;
	str "EDIT";
	tk_else			equ $d2;
tk_ptr_else:
	str "ELSE";
	tk_end			equ $d3;
	str "END";
	tk_error		equ $d4;
	str "ERROR";
	tk_files		equ $d5;
	str "FILES";
	tk_for			equ $d6;
	str "FOR";
	tk_gosub		equ $d7;
	str "GOSUB";
	tk_goto			equ $d8;
	str "GOTO";
	tk_if			equ $d9;
	str "IF";
	tk_input		equ $da;
	str "INPUT";
	tk_key			equ $db;
	str "KEY";
	tk_kill			equ $dc;
	str "KILL";
	tk_let			equ $dd;
	str "LET";
	tk_list			equ $de;
	str "LIST";
	tk_load			equ $df;
	str "LOAD";
	tk_locate		equ $e0;
	str "LOCATE";
	tk_merge		equ $e1;
	str "MERGE";
	tk_mkdir		equ $e2;
	str "MKDIR";
	tk_name			equ $e3;
	str "NAME";
	tk_next			equ $e4;
	str "NEXT";
	tk_new			equ $e5;
	str "NEW";
	tk_old			equ $e6;
	str "OLD";
	tk_on			equ $e7;
	str "ON";
	tk_open			equ $e8;
	str "OPEN #";
	tk_out			equ $e9;
	str "OUT";
	tk_palette		equ $ea;
	str "PALETTE";
	tk_play			equ $eb;
	str "PLAY";
	tk_plot			equ $ec;
	str "PLOT";
	tk_poke			equ $ed;
	str "POKE";
	tk_print		equ $ee;
	str "PRINT";
	tk_randomize	equ $ef;
	str "RANDOMIZE";
	tk_read			equ $f0;
	str "READ";
	tk_rem			equ $f1;
tk_ptr_rem:
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
	tk_seek			equ $f9
	str "SEEK #";
	tk_sound		equ $fa;
	str "SOUND";
	tk_stop			equ $fb;
	str "STOP";
	tk_trace		equ $fc;
	str "TRACE";
	tk_wait			equ $fd;
	str "WAIT";
	tk_wend			equ $fe;
	str "WEND";
	tk_while		equ $ff;
tk_ptr_last:
	str "WHILE";

;	// used in 09_command
offst_tbl:
	defw p_beep;
	defw p_bload;
	defw p_bsave;
	defw p_call;
	defw p_chdir;
	defw p_circle;
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
	defw p_draw;
	defw p_edit;
	defw p_else;
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
	defw p_play;
	defw p_plot;
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
	defw p_seek;
	defw p_sound;
	defw p_stop;
	defw p_trace;
	defw p_wait;
	defw p_wend;
	defw p_while;

;	// parameter table
p_beep:
	defb no_f_ops;
	defw c_beep;

p_bload:
	defb str_exp, ',', num_exp_no_f_ops;
	defw c_bload;

p_bsave:
	defb str_exp, ',', two_c_s_num_no_f_ops;
	defw c_bsave;

p_call:
	defb num_exp, var_syn;
	defw c_call;

p_chdir:
	defb str_exp_no_f_ops;
	defw c_chdir;

p_circle:
	defb two_c_s_num, ',', num_exp_no_f_ops;
	defw c_circle;

p_clear:
	defb num_exp_0;
	defw c_clear;

p_close:
	defb var_syn;
	defw c_close;

p_cls:
	defb no_f_ops;
	defw c_cls;

p_color:
	defb two_c_s_num, var_syn;
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
;	defb var_syn;
	defb two_c_s_num_no_f_ops;
	defw c_delete;

p_dim:
	defb var_syn;
	defw c_dim;

p_doke:
	defb two_c_s_num_no_f_ops;
	defw c_doke;

p_draw:
	defb two_c_s_num_no_f_ops;
	defw c_draw;

p_edit:
	defb num_exp_0;
	defw c_edit;

p_else:
	defb var_syn;
	defw c_else;

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
	defb str_exp, var_syn;
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

p_play:
	defb var_syn;
	defw c_std_play;

p_plot:
	defb two_c_s_num_no_f_ops;
	defw c_plot;

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
	defb str_exp, var_syn;
	defw c_save;

p_screen:
	defb num_exp_no_f_ops;
	defw c_screen;

p_seek:
	defb two_c_s_num_no_f_ops;
	defw c_seek;

p_sound:
	defb two_c_s_num_no_f_ops;
	defw c_sound;

p_stop:
	defb no_f_ops;
	defw c_stop;

p_trace:
	defb var_syn;
	defw c_trace;

p_wait:
	defb num_exp_no_f_ops;
	defw c_wait;

p_wend:
	defb no_f_ops;
	defw c_wend;

p_while:
	defb num_exp_no_f_ops;
	defw c_while;

;	// 66 unused bytes
	defs 66, $ff;						// RESERVED
