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

	org $3d00
copyright:
	defb "CHLOE 280SE 512K Microcomputer", ctrl_enter;
	defb "Copyright (C)1999 Chloe Corporation.", ctrl_enter;
	defb ctrl_enter;
	defb "SE BASIC IV 4.2 Cordelia", ctrl_enter;
	defb "Copyright (C)2017 Source Solutions, Inc.", ctrl_enter;
	defb ctrl_enter;
	defb "Release 200214", ctrl_enter;
;	defb "Build: ", TIMESTR, ctrl_enter;
	defb ctrl_enter, 0;

bytes_free:
	defb " BASIC bytes free", ctrl_enter;
	defb ctrl_enter, 0;

;	// used in 04_audio
semi_tone:
	df 261.625565300599;				// C
	df 277.182630976872;				// C#
	df 293.664767917408;				// D
	df 311.126983722081;				// D#
	df 329.627556912870;				// E
	df 349.228231433004;				// F
	df 369.994422711634;				// F#
	df 391.995435981749;				// G
	df 415.304697579945;				// G#
	df 440.000000000000;				// A
	df 466.163761518090;				// A#
	df 493.883301256124;				// B

;	defb $89, $02, $d0, $12, $86;		// C
;	defb $89, $0a, $97, $60, $73;		// C#
;	defb $89, $12, $d5, $17, $1d;		// D
;	defb $89, $1b, $90, $41, $00;		// D#
;	defb $89, $24, $d0, $53, $c8;		// E
;	defb $89, $2e, $9d, $36, $b0;		// F
;	defb $89, $38, $ff, $49, $3e;		// F#
;	defb $89, $43, $ff, $6a, $72;		// G
;	defb $89, $4f, $a7, $00, $54;		// G#
;	defb $89, $5c, $00, $00, $00;		// A
;	defb $89, $69, $14, $f6, $23;		// A#
;	defb $89, $76, $f1, $10, $03;		// B

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
	defb $0b, $00;						// stream $ff, channel R
	defb $01, $00;						// stream $00, channel K
	defb $01, $00;						// stream $01, channel K
	defb $06, $00;						// stream $02, channel S

init_chan:
	defw print_out, key_input;			// keyboard
	defb 'K';							// channel
	defw print_out, report_bad_io_dev;	// screen
	defb 'S';							// channel
	defw add_char, report_bad_io_dev;	// workspace
	defb 'R';							// channel
	defb end_marker;					// no more channels

;	// used in 10_expression
tbl_of_ops:
	defb '+', $cf;						// +
	defb '-', $c3;						// -
	defb '*', $c4;						// *
	defb '/', $c5;						// /
	defb '^', $c6;						// ^
	defb '=', $ce;						// =
	defb '>', $cc;						// >
	defb '<', $cd;						// <
	defb tk_l_eql, $c9;					// <=
	defb tk_gr_eq, $ca;					// >=
	defb tk_neql, $cb;					// <>
	defb tk_or, $c7;					// OR
	defb tk_and, $c8;					// AND
	defb 0;								// null terminator

tbl_priors:
	defb $06;							// -
	defb $08;							// *
	defb $08;							// /
	defb $0a;							// ^
	defb $02;							// OR
	defb $03;							// AND
	defb $05;							// <=
	defb $05;							// >=
	defb $05;							// <>
	defb $05;							// >
	defb $05;							// <
	defb $05;							// =
	defb $06;							// +

;	// used in 12_calculator
constants:
	pi equ 3.14159265358979
	df 0;								// int
	df 1;								// int
	df 0.5;								// float
	df pi / 2;							// float
	df 10;								// int

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
	defw fp_e_to_fp;
	defw fp_re_stack;
	defw fp_series_xx;
	defw fp_stk_const_xx;
	defw fp_st_mem_xx;
	defw fp_get_mem_xx;

;	// used in 15_files
dir_msg:
	defb "<DIR>   ", 0;

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
	defb 0;								// one byte padding for translation

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

	org $4240

;	// used in 03_keyboard
;kt_main:
;	defb "BHY65TGVNJU74RFCMKI83EDX", ctrl_symbol;
;	defb "LO92WSZ ", ctrl_enter, "P01QA";
;
;kt_dig_shft:
;	defb ")!@#$%^&*(";
;
;kt_alpha_sym:
;	defb ctrl_left, ",>", ctrl_right, "_:", '"', "|};'\\/.[]~+", ctrl_down, "-{?", ctrl_up, "<=`"
;
;kt_dig_sym:
;	defb ctrl_backspace, ctrl_tab, ctrl_caps, ctrl_ins, ctrl_clr_home;
;	defb ctrl_pg_up, ctrl_delete, ctrl_end, ctrl_pg_dn, ctrl_graphics;

kt_main:
	defb "BHY65TGVNJU74RFCMKI83EDX", ctrl_symbol;
	defb "LO92WSZ ", ctrl_enter, "P01QA";

kt_dig_shft:
	defb ctrl_backspace, ctrl_tab, ctrl_caps, ctrl_pg_up, ctrl_pg_dn;
	defb ctrl_left, ctrl_down, ctrl_up, ctrl_right, ctrl_graphics;

kt_alpha_sym:
	defb "~*?\\", ctrl_end, "{}^", ctrl_ins, "-+=.,;", '"', ctrl_clr_home, "<|>]/", ctrl_delete, "`[:";"

kt_dig_sym:
	defb "_!@#$%&'()";

;	// used in 02_tokenizer and 06_screen_80
token_table:
	defb end_marker;

;	// functions
	dbtb "RND", "INKEY$", "PI", "FN";
	dbtb "BIN$", "OCT$", "HEX$", "USING";
	dbtb "TAB", "VAL$", "ASC", "VAL";
	dbtb "LEN", "SIN", "COS", "TAN";
	dbtb "ASIN", "ACOS", "ATAN", "LOG";
	dbtb "EXP", "INT", "SQR", "SGN";
	dbtb "ABS", "PEEK", "INP", "USR";
	dbtb "STR$", "CHR$", "NOT", "MOD";
	dbtb "OR", "AND", "<=", ">=";
	dbtb "<>", "LINE", "THEN", "TO";
	dbtb "STEP";

;	// commands
	dbtb "DEF FN", "BLOAD", "BSAVE", "CHDIR";
	dbtb "COPY", "OPEN #", "CLOSE #", "DLOAD";
	dbtb "DSAVE", "SOUND", "FILES", "KILL";
	dbtb "LOAD", "MKDIR", "NAME", "RMDIR";
	dbtb "SAVE", "OUT", "LOCATE", "END";
	dbtb "STOP", "READ", "DATA", "RESTORE";
	dbtb "NEW", "ERROR", "CONT", "DIM";

tk_ptr_rem:
	dbtb "REM", "FOR", "GOTO", "GOSUB";
	dbtb "INPUT", "PALETTE", "LIST", "LET";
	dbtb "WAIT", "NEXT", "POKE", "PRINT"
	dbtb "DELETE", "RUN", "EDIT", "RANDOMIZE";
	dbtb "IF", "CLS", "CALL", "CLEAR"
	dbtb "RETURN", "COLOR", "TRON", "TROFF"
	dbtb "ON", "RENUM", "AUTO", "_E0";
	dbtb "_E1", "_E2", "_E3", "_E4"
	dbtb "_E5", "_E6", "_E7", "_E8";
	dbtb "_E9", "_EA", "_EB", "_EC";
	dbtb "_ED", "_EE", "_EF", "_F0";
	dbtb "_F1", "_F2", "_F3", "_F4";
	dbtb "_F5", "_F6", "_F7", "_F8";
	dbtb "_F9", "_FA", "_FB", "_FC";
	dbtb "_FD", "_FE";
	
tk_ptr_last:
	dbtb "_FF";

;	// used in 09_command
offst_tbl:
	defw p_def_fn;						// 97 (DEF)
	defw p_bload;						// cf
	defw p_bsave;						// d0
	defw p_chdir;						// fe97 (BASICA)
	defw p_copy;						// d6
	defw p_open;						// b0
	defw p_close;						// b4
	defw p_dload;						// 9b (CLOAD)
	defw p_dsave;						// 9a (CSAVE)
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
	defw p__e0;							// 
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
	defb num_exp, ',', str_exp_no_f_ops;
	defw open;

p_close:
	defb num_exp_no_f_ops;
	defw close;

p_dload:
	defb str_exp_no_f_ops;
	defw dload;

p_dsave:
	defb str_exp_no_f_ops;
	defw dsave;

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
	defw save;

p_out:
	defb two_c_s_num_no_f_ops;
	defw fn_out;

p_locate:
	defb two_c_s_num_no_f_ops;
	defw locate;

p_end:
	defb no_f_ops;
	defw c_end;

p_stop:
	defb no_f_ops;
	defw stop;

p_read:
	defb var_syn;
	defw read;

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
	defb chr_var, '=', num_exp, tk_to, num_exp, var_syn;
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
	defw print;

p_delete:
	defb num_exp, tk_to, num_exp_no_f_ops;
	defw delete;

p_run:
	defb var_syn;
	defw run;

p_edit:
	defb num_exp_no_f_ops;
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
	defb no_f_ops;
	defw c_on;

p_renum:
	defb no_f_ops;
	defw renum;

p_auto:
	defb no_f_ops;
	defw auto;

p__e0:
	defb no_f_ops;
	defw rem;

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
