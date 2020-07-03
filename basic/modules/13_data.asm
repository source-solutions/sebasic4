;	// SE Basic IV 4.2 Cordelia
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

;	// addresses $3d00 to $3fff are trapped by the divIDE / divMMC hardware
;	// these addresses must not contain code or when the PC is in this range, paging will take place.

;	// --- DATA TABLES ---------------------------------------------------------

	org $3d00
copyright:
	defb "CHLOE 280SE 512K Personal Color Computer", ctrl_cr;
	defb "Copyright (C)1999 Chloe Corporation", ctrl_cr;
	defb ctrl_cr;
	defb "SE BASIC IV 4.2 Cordelia", ctrl_cr;
	defb "Copyright (C)2020 Source Solutions, Inc.", ctrl_cr;
	defb ctrl_cr;
;	defb "Release 200715", ctrl_cr;	// Morton
;	defb "YY-MM-DD HH:MM", ctrl_cr;
	defb "20-07-03 12:00", ctrl_cr;
	defb ctrl_cr, 0;

bytes_free:
	defb " BASIC bytes free", ctrl_cr;
	defb ctrl_cr, 0;

;	// used in 04_audio
semi_tone:
	defb $89, $02, $d0, $12, $86;		// C  - 261.625565300599 Hz
	defb $89, $0a, $97, $60, $74;		// C# - 277.182630976872 Hz
	defb $89, $12, $d5, $17, $1d;		// D  - 293.664767917408 Hz
	defb $89, $1b, $90, $41, $01;		// D# - 311.126983722081 Hz
	defb $89, $24, $d0, $53, $c9;		// E  - 329.627556912870 Hz
	defb $89, $2e, $9d, $36, $b0;		// F  - 349.228231433004 Hz
	defb $89, $38, $ff, $49, $3e;		// F# - 369.994422711634 Hz
	defb $89, $43, $ff, $6a, $72;		// G  - 391.995435981749 Hz
	defb $89, $4f, $a7, $00, $55;		// G# - 415.304697579945 Hz
	defb $89, $5c, $00, $00, $00;		// A  - 440.000000000000 Hz
	defb $89, $69, $14, $f6, $23;		// A# - 466.163761518090 Hz
	defb $89, $76, $f1, $10, $04;		// B  - 493.883301256124 Hz

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
	defw print_out, report_bad_io_dev;	// screen
	defb 'S';							// channel
	defw detokenizer, report_bad_io_dev;// workspace
	defb 'W';							// channel
	defb end_marker;					// no more channels

;	// used in 10_expression
tbl_ops_priors:
	defb '+', $cf, 6;					// +	%11000000 + fadd
	defb '-', $c3, 6;					// -	%11000000 + fsub
	defb '*', $c4, 8;					// *	%11000000 + fmul
	defb '/', $c5, 8;					// /	%11000000 + fdiv
	defb '^', $c6, 10;					// ^	%11000000 + fexp
	defb '=', $ce, 5;					// =	%11000000 + fcp(_eq)
	defb '>', $cc, 5;					// >	%11000000 + fcp(_gt)
	defb '<', $cd, 5;					// <	%11000000 + fcp(_lt)
	defb tk_l_eql, $c9, 5;				// <=	%11000000 + fcp(_le)
	defb tk_gr_eq, $ca, 5;				// >=	%11000000 + fcp(_ge)
	defb tk_neql, $cb, 5;				// <>	%11000000 + fcp(ne)
	defb tk_or, $c7, 2;					// OR	%11000000 + fbor
	defb tk_and, $c8, 3;				// AND	%11000000 + fband
	defb 0;								// null terminator

;	// used in 12_calculator
constants:
	defb $00, $00, $00, $00, $00;		// 0
	defb $00, $00, $01, $00, $00;		// 1
	defb $80, $00, $00, $00, $00;		// 0.5
	defb $81, $49, $0f, $da, $a2;		// pi / 2 (pi = 3.14159265358979)
	defb $00, $00, $0a, $00, $00;		// 10

tbl_addrs:
	defw fp_jump_true;
	defw fp_exchange;
	defw fp_delete;
	defw fp_subtract;
	defw fp_multiply;
	defw fp_division;
	defw fp_to_power;
	defw fp_or;
	defw fp_no_and_no;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_addition;
	defw fp_str_and_no;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_comparison;
	defw fp_strs_add;
	defw fp_val_str;
	defw fp_usr_str;
	defw fp_read_in;
	defw fp_negate;
	defw fp_asc;
	defw fp_val;
	defw fp_len;
	defw fp_sin;
	defw fp_cos;
	defw fp_tan;
	defw fp_asin;
	defw fp_acos;
	defw fp_atan;
	defw fp_log;
	defw fp_exp;
	defw fp_int;
	defw fp_sqr;
	defw fp_sgn;
	defw fp_abs;
	defw fp_peek;
	defw fp_inp;
	defw fp_usr_no;
	defw fp_str_str;
	defw fp_chr_str;
	defw fp_not;
	defw fp_duplicate;
	defw fp_n_mod_m;
	defw fp_jump;
	defw fp_stk_data;
	defw fp_dec_jr_nz;
	defw fp_less_0;
	defw fp_greater_0;
	defw fp_end_calc;
	defw fp_get_argt;
	defw fp_truncate;
	defw fp_calc_2;
	defw fp_hex_str;
	defw fp_re_stack;
	defw fp_new_fn_1;
	defw fp_new_fn_2;

tbl_offs equ $ - tbl_addrs
	defw fp_series_xx;
	defw fp_stk_const_xx;
	defw fp_st_mem_xx;
	defw fp_get_mem_xx;

;	// used in 15_files
dir_msg:
	defb "<DIR>   ", 0;

;	// used in 14_screen_40
;	// attributes are stored internally with the foreground in the high nibble and the background in the low nibble
;	// this table converts an attribute to its 64-color equivalent in the default palette.
	org $3f00
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

;	// the remaining part of BASIC exists in RAM and can therefore be modified by the user

	org $4000

;	// used in 06_screen_80
scrl_mssg:
	defb "Scroll?", 0;

;	// padding for translation
	org scrl_mssg + 12

sp_in_sp:
	defb " in ", 0;

ready:
	defb "Ready", 0;

;	// padding for translation
	org ready + 13

;	// used in 08_executive
rpt_mesgs:
	defb "Ok", 0;						// code 255
	defb "Break", 0;					// code 0
	defb "NEXT without FOR", 0;			// code 1
	defb "Syntax error", 0;				// code 2
	defb "RETURN without GOSUB", 0;		// code 3
	defb "Out of DATA", 0;				// code 4
	defb "Illegal function call", 0;	// code 5
	defb "Overflow", 0;+				// code 6
	defb "Out of memory", 0;			// code 7
	defb "Undefined line number", 0;	// code 8
	defb "Subscript out of range", 0;	// code 9
	defb "Undefined variable", 0;		// no equivalent
	defb "Address out of range", 0;		// no equivalent
	defb "Statement missing", 0;		// no equivalent
	defb "Type mismatch", 0;			// code 13
	defb "Out of screen", 0;			// no equivalent
	defb "Bad I/O device", 0;			// no equivalent
	defb "Undefined stream", 0;			// no equivalent
	defb "Undefined channel", 0;		// no equivalent
	defb "Undefined user function", 0;	// code 18
	defb "Line buffer overflow", 0;		// code 23
	defb "FOR without NEXT", 0;			// code 26
	defb "File not found", 0;			// code 53
	defb "Input past end", 0;			// code 62
	defb "Path not found", 0;			// code 76

;	// A total of 576 bytes are allocated for translated error messages

	org $4300

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

s_f1:
	defb "LIST", 0

s_f2:
	defb "RUN", ctrl_cr, 0;

s_f3:
	defb "LOAD",'"', 0;";

s_f4:
	defb "SAVE",'"', 0;";

s_f5:
	defb "CONT", ctrl_cr, 0;

s_f6:
	defb "COLOR 7,1", ctrl_cr, 0;

s_f7:
	defb "TRON", ctrl_cr, 0;

s_f8:
	defb "TROFF", ctrl_cr, 0;

s_f9:
	defb "EDIT", 0;

s_f10:
	defb "SCREEN", 0;

s_f11:
	defb "BLOAD",'"', 0;";

s_f12:
	defb "BSAVE",'"', 0;";

s_f13:
	defb "AUTO", 0;

s_f14:
	defb "GOTO", 0;

s_f15:
	defb "KEY", 0;

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

;	// functions
	str "RND", "INKEY$", "PI", "FN";
	str "BIN$", "OCT$", "HEX$", "SPC";
	str "TAB", "VAL$", "ASC", "VAL";
	str "LEN", "SIN", "COS", "TAN";
	str "ASIN", "ACOS", "ATAN", "LOG";
	str "EXP", "INT", "SQR", "SGN";
	str "ABS", "PEEK", "INP", "USR";
	str "STR$", "CHR$", "NOT", "MOD";
	str "OR", "AND", "<=", ">=";
	str "<>", "LINE", "THEN", "TO";
	str "STEP";

;	// commands
	str "DEF FN", "BLOAD", "BSAVE", "CHDIR";
	str "COPY", "OPEN #", "CLOSE #", "WHILE";
	str "WEND", "SOUND", "FILES", "KILL";
	str "LOAD", "MKDIR", "NAME", "RMDIR";
	str "SAVE", "OUT", "LOCATE", "END";
	str "STOP", "READ", "DATA", "RESTORE";
	str "NEW", "ERROR", "CONT", "DIM";

tk_ptr_rem:
	str "REM", "FOR", "GOTO", "GOSUB";
	str "INPUT", "PALETTE", "LIST", "LET";
	str "WAIT", "NEXT", "POKE", "PRINT"
	str "DELETE", "RUN", "EDIT", "RANDOMIZE";
	str "IF", "CLS", "CALL", "CLEAR"
	str "RETURN", "COLOR", "TRON", "TROFF"
	str "ON", "RENUM", "AUTO", "SCREEN";
	str "XOR", "_E2", "_E3", "_E4"
	str "_E5", "_E6", "_E7", "_E8";
	str "_E9", "_EA", "_EB", "_EC";
	str "_ED", "_EE", "_EF", "_F0";
	str "_F1", "_F2", "_F3", "_F4";
	str "_F5", "_F6", "_F7", "_F8";
	str "_F9", "_FA", "_FB", "_FC";
	str "_FD", "_FE";
	
tk_ptr_last:
	str "_FF";

;	// used in 09_command
offst_tbl:
	defw p_def_fn;						// 97 (DEF)
	defw p_bload;						// cf
	defw p_bsave;						// d0
	defw p_chdir;						// fe97 (BASICA)
	defw p_copy;						// d6
	defw p_open;						// b0
	defw p_close;						// b4
	defw p_while;						// 
	defw p_wend;						// 
	defw p_sound;						// c4
	defw p_files;						// b7
	defw p_kill;						// d4
	defw p_load;						// b5
	defw p_mkdir;						// fe98 (BASICA)
	defw p_name;						// d3
	defw p_rmdir;						// fe99 (BASICA)
	defw p_save;						// ba
	defw p_out;							// 9c
	defw p_locate;						// d8
	defw p_end;							// 81
	defw p_stop;						// 90
	defw p_read;						// 87
	defw p_data;						// 84
	defw p_restore;						// 8c
	defw p_new;							// 94
	defw p_error;						// aa
	defw p_cont;						// 99
	defw p_dim;							// 86
	defw p_rem;							// 8f
	defw p_for;							// 82
	defw p_goto;						// 89
	defw p_gosub;						// 8d
	defw p_input;						// 85
	defw p_palette;						// fe9f (BASICA)
	defw p_list;						// 93
	defw p_let;							// 88
	defw p_wait;						// 96
	defw p_next;						// 83
	defw p_poke;						// 98
	defw p_print;						// 91
	defw p_delete;						// a8
	defw p_run;							// 8a
	defw p_edit;						// a6 (BASICA)
	defw p_randomize;					// af (guess)
	defw p_if;							// 8b
	defw p_cls;							// 9f
	defw p_call;						// a8
	defw p_clear;						// 92
	defw p_return;						// 8e
	defw p_color;						// bd
	defw p_tron;						// a2
	defw p_troff;						// a3
	defw p_on;							// 95
	defw p_renum;						// aa
	defw p_auto;						// a9
	defw p_screen;						// c5
	defw p__e1;							// 
	defw p__e2;							// 
	defw p__e3;							// 
	defw p__e4;							// 
	defw p__e5;							// 
	defw p__e6;							// 
	defw p__e7;							// 
	defw p__e8;							// 
	defw p__e9;							// 
	defw p__ea;							// 
	defw p__eb;							// 
	defw p__ec;							// 
	defw p__ed;							// 
	defw p__ee;							// 
	defw p__ef;							// 
	defw p__f0;							// 
	defw p__f1;							// 
	defw p__f2;							// 
	defw p__f3;							// 
	defw p__f4;							// 
	defw p__f5;							// 
	defw p__f6;							// 
	defw p__f7;							// 
	defw p__f8;							// 
	defw p__f9;							// 
	defw p__fa;							// 
	defw p__fb;							// 
	defw p__fc;							// 
	defw p__fd;							// 
	defw p__fe;							// 
	defw p__ff;							// 

p_def_fn:
	defb var_syn;
	defw def_fn;

p_bload:
	defb str_exp, ',', num_exp_no_f_ops;
	defw bload;

p_bsave:
	defb str_exp, ',', num_exp, ',', num_exp_no_f_ops;
	defw bsave;

p_chdir:
	defb str_exp_no_f_ops;
	defw chdir;

p_copy:
	defb str_exp, tk_to, str_exp_no_f_ops;
	defw copy;

p_open:
	defb num_exp, ',', str_exp, var_syn;
	defw open;

p_close:
	defb num_exp_no_f_ops;
	defw close;

p_while:
	defb var_syn;
	defw c_while;

p_wend:
	defb no_f_ops;
	defw c_wend;

p_sound:
	defb two_c_s_num_no_f_ops;
	defw sound;

p_files:
	defb var_syn;
	defw files;

p_kill:
	defb str_exp_no_f_ops;
	defw kill;

p_load:
	defb str_exp_no_f_ops;
	defw load;

p_mkdir:
	defb str_exp_no_f_ops;
	defw mkdir;

p_name:
	defb str_exp, tk_to, str_exp_no_f_ops;
	defw name;

p_rmdir:
	defb str_exp_no_f_ops;
	defw rmdir;

p_save:
	defb str_exp_no_f_ops;
	defw c_save;

p_out:
	defb two_c_s_num_no_f_ops;
	defw c_out;

p_locate:
	defb two_c_s_num_no_f_ops;
	defw locate;

p_end:
	defb no_f_ops;
	defw c_end;

p_stop:
	defb no_f_ops;
	defw c_stop;

p_read:
	defb var_syn;
	defw c_read;

p_data:
	defb var_syn;
	defw data;

p_restore:
	defb num_exp_0;
	defw restore;

p_new:
	defb no_f_ops;
	defw new;

p_error:
	defb num_exp_no_f_ops;
	defw c_error;

p_cont:
	defb no_f_ops;
	defw cont;

p_dim:
	defb var_syn;
	defw dim;

p_rem:
	defb var_syn;
	defw rem;

p_for:
	defb chr_var, "=", num_exp, tk_to, num_exp, var_syn;
	defw c_for;

p_goto:
	defb num_exp_no_f_ops;
	defw goto;

p_gosub:
	defb num_exp_no_f_ops;
	defw gosub;

p_input:
	defb var_syn;
	defw input;

p_palette:
	defb two_c_s_num_no_f_ops;
	defw palette;

p_list:
	defb var_syn;
	defw c_list;

p_let:
	defb var_rqd, '=', expr_num_str;

p_wait:
	defb num_exp_no_f_ops;
	defw wait;

p_next:
	defb chr_var, no_f_ops;
	defw c_next;

p_poke:
	defb two_c_s_num_no_f_ops;
	defw poke;

p_print:
	defb var_syn;
	defw c_print;

p_delete:
	defb num_exp, ',', num_exp_no_f_ops;
	defw delete;

p_run:
	defb var_syn;
	defw c_run;

p_edit:
	defb num_exp_0;
	defw edit;

p_randomize:
	defb num_exp_0;
	defw randomize;

p_if:
	defb num_exp, tk_then, var_syn;
	defw c_if;

p_cls:
	defb no_f_ops;
	defw cls;

p_call:
	defb num_exp_no_f_ops;
	defw c_call;

p_clear:
	defb num_exp_0;
	defw clear;

p_return:
	defb no_f_ops;
	defw return;

p_color:
	defb two_c_s_num_no_f_ops;
	defw color;

p_tron:
	defb no_f_ops;
	defw tron;

p_troff:
	defb no_f_ops;
	defw troff;

p_on:
	defb var_syn;
	defw c_on;

p_renum:
	defb var_syn;
	defw renum;

p_auto:
	defb no_f_ops;
	defw auto;

p_screen:
	defb num_exp_no_f_ops;
	defw screen;

p__e1:
	defb no_f_ops;
	defw rem;

p__e2:
	defb no_f_ops;
	defw rem;

p__e3:
	defb no_f_ops;
	defw rem;

p__e4:
	defb no_f_ops;
	defw rem;

p__e5:
	defb no_f_ops;
	defw rem;

p__e6:
	defb no_f_ops;
	defw rem;

p__e7:
	defb no_f_ops;
	defw rem;

p__e8:
	defb no_f_ops;
	defw rem;

p__e9:
	defb no_f_ops;
	defw rem;

p__ea:
	defb no_f_ops;
	defw rem;

p__eb:
	defb no_f_ops;
	defw rem;

p__ec:
	defb no_f_ops;
	defw rem;

p__ed:
	defb no_f_ops;
	defw rem;

p__ee:
	defb no_f_ops;
	defw rem;

p__ef:
	defb no_f_ops;
	defw rem;

p__f0:
	defb no_f_ops;
	defw rem;

p__f1:
	defb no_f_ops;
	defw rem;

p__f2:
	defb no_f_ops;
	defw rem;

p__f3:
	defb no_f_ops;
	defw rem;

p__f4:
	defb no_f_ops;
	defw rem;

p__f5:
	defb no_f_ops;
	defw rem;

p__f6:
	defb no_f_ops;
	defw rem;

p__f7:
	defb no_f_ops;
	defw rem;

p__f8:
	defb no_f_ops;
	defw rem;

p__f9:
	defb no_f_ops;
	defw rem;

p__fa:
	defb no_f_ops;
	defw rem;

p__fb:
	defb no_f_ops;
	defw rem;

p__fc:
	defb no_f_ops;
	defw rem;

p__fd:
	defb no_f_ops;
	defw rem;

p__fe:
	defb no_f_ops;
	defw rem;

p__ff:
	defb no_f_ops;
	defw rem;
