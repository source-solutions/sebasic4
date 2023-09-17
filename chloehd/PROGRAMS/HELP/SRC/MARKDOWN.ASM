;	// MARKDOWN - A file viewer for a subset of Markdown features
;	// Copyright (c) 2022-2023 Source Solutions, Inc.

;	// constants
	print_a equ $10;					// print a character
	chan_open equ $1601;				// channel open

    org 40000;

	jr start;							// print contents of buffer
	
	org 40002;							// flush buffer

flush:
	ld hl, buffer;						// point to buffer
	ld (hl), 0;							// clear first byte
	ld de, buffer + 1;					// point to second byte
	ld bc, 4095;						// 4K to clear
	ldir;								// clear it
	ret;								// return

exit:
	pop ix;								// unstack registers
	pop de;								// 
	pop hl;								// 
	ret;								// 

start:
	push hl;							// stack registers
	push de;							// 
	push ix;							// 

	ld a, 12;							// FF
	rst print_a;						// clear screen
	ld a, 2;							// select main screen
	call chan_open;						// select channel
	ld hl, buffer;						// point to buffer
	ld ix, flags;						// point to flags
	ld (ix), 0;							// clear flags

loop:
	ld a, (hl);							// get character
	and a;								// test for zero (terminating byte)
	jr z, exit;							// return if so

;test_link_open:
;	cp '[';								// open square bracket?
;	call z, link_open;					// call if so

;test_link_close:
;	cp ']';								// close square bracket?
;	call z, link_close;					// call if so

test_esc:
	cp 92;								// test for escape character ( \ )
	jr nz, test_lf;						// jump if not
	inc hl;								// next character
	ld a, (hl);							// get character
	jp pr_any;							// print next character

test_lf:
	cp $0a;								// form feed?
	jr nz, test_backtick;				// jump if not
	ld (ix), 0;							// else clear italic/bold
	jp pr_roman;						// and print it

;test_codeblock:
;	ld de, md_codeblock;				// point to token
;	call match_token;					// check for match
;	jp z, pr_codeblock;					// jump if so

test_backtick:
	cp '`';								// backtick?
	jr nz, test_head;					// jump if not
	ld a, 1;							// bold
	xor (ix);							// toggle bold bit
	ld (ix), a;							// set it
	inc hl;								// next character
	jr loop;							// parse it

test_head:
	cp '#';								// is it a '#'
	jp z, pr_head;						// jump if so

;	// horizontal rule
	ld de, md_hr;						// point to token
	call match_token;					// check for match
	jp z, pr_hr;						// jump if so

;	// bullet point
	ld de, md_bullet;					// point to token
	call match_token;					// check for match
	jp z, pr_bullet;					// jump if so

;	// hyperlink
	ld de, md_url;						// point to token
	call match_token;					// check for match
	jp z, pr_url;						// jump if so

;	// <code>
	ld de, md_code_o;					// point to token
	call match_token;					// check for match
	jp z, set_bold;						// jump if so

;	// </code>
	ld de, md_code_c;					// point to token
	call match_token;					// check for match
	jp z, clr_bold;						// jump if so

;	// <b>
	ld de, md_bold_o;					// point to token
	call match_token;					// check for match
	jp z, set_bold;						// jump if so

;	// </b>
	ld de, md_bold_c;					// point to token
	call match_token;					// check for match
	jp z, clr_bold;						// jump if so

;	// <samp>
	ld de, md_samp_o;					// point to token
	call match_token;					// check for match
	jp z, set_bold;						// jump if so

;	// </samp>
	ld de, md_samp_c;					// point to token
	call match_token;					// check for match
	jp z, clr_bold;						// jump if so

;	// <kbd>
	ld de, md_kbd_o;					// point to token
	call match_token;					// check for match
	jp z, set_bold;						// jump if so

;	// </kbd
	ld de, md_kbd_c;					// point to token
	call match_token;					// check for match
	jp z, clr_bold;						// jump if so

;	// <var>
	ld de, md_var_o;					// point to token
	call match_token;					// check for match
	jp z, set_italic;						// jump if so

;	// </var>
	ld de, md_var_c;					// point to token
	call match_token;					// check for match
	jp z, clr_italic;					// jump if so

pr_any:
	bit 1, (ix);						// italic flag set (overrides bold)
	jr nz, pr_italic;					// jump if so
	bit 0, (ix);						// italic flag set (overrides bold)
	jr nz, pr_bold;						// jump if so

pr_roman:
	rst print_a;						// print A
	inc hl;								// next character
	jp loop;							// loop until done

pr_italic:
	cp '0';								// zero character?
	jr c, pr_roman;						// jump if lower
	cp ':';								// colon character?
	jr c, nm_italic;					// jump if lower
    cp 'A';								// 'A'?
	jr c, pr_roman;						// jump if lower
	cp '[';								// square bracket?
	jr c, alpha_italic;					// jump if lower
	cp 'a';								// 'a'?
	jr c, pr_roman;						// jump if lower
	cp '{';								// curly bracket?
	jr c, alpha_italic;					// jump if lower
	jr pr_roman;						// immediate jump

alpha_italic:
	and %00111111;						// convert $41 ... to

alpha_bold:
	or %10000000;						// $81 ...
	jr pr_roman;						// and print it

nm_italic:
	push hl;							// stack pointer
	ld hl, italic;						// table base

nm_lookup:
	sub $30;							// reduce range
	ld e, a;							// copy to
	ld d, 0;							// DE
	add hl, de;							// offset
	ld a, (hl);							// new character value
	pop hl;								// unstack pointer
	jr pr_roman;						// and print it

pr_bold:
	cp '0';								// zero character?
	jr c, pr_roman;						// jump if lower
	cp ':';								// colon character?
	jr c, nm_bold;						// jump if lower
    cp 'A';								// 'A'?
	jr c, pr_roman;						// jump if lower
	cp '[';								// square bracket?
	jr c, alpha_bold;					// jump if lower
	cp 'a';								// 'a'?
	jr c, pr_roman;						// jump if lower
	cp '{';								// curly bracket?
	jr c, alpha_bold;					// jump if lower
	jr pr_roman;						// immediate jump

nm_bold:
	push hl;							// stack pointer
	ld hl, bold;						// table base
	jr nm_lookup;						// immediate jump

;	// deal with links
;link_open:
;	ld (ix), 1;							// set bold
;	ret;								// return

;link_close:
;	ld (ix), 0;							// set roman
;	ret;

;	// apply conversions

pr_head:
	inc hl;								// next character
	ld a, (hl);							// get character

	cp ' ';								is it a space?
	jr z, sp_found;						// jump if so

	cp '#';								// is it another '#'
	dec hl;								// current character
	ld a, (hl);							// restore character
	jp nz, pr_roman;					// jump if not

pr_head_loop:
	inc hl;								// next character
	ld a, (hl);							// get character
	cp ' ';								// is it a space?
	jr nz, pr_head_loop;				// jump until found

sp_found:
	ld (ix), 1;							// set bold
	inc hl;								// next character
	ld a, (hl);							// get it
	jp pr_bold;							// immediate jump

pr_hr:
	ld b, 80;							// counter

hr_loop:
	ld a, "_";							// create horizontal rule
	rst print_a;						// output character
	djnz hr_loop;						// loop until done
	ld a, 13;							// carriage return
	rst print_a;						// output character
	ld a, 13;							// carriage return
	rst print_a;						// output character
	jp loop;							// next character

pr_bullet:
	ld a, $e0;							// bullet character
	rst print_a;						// output character
	ld a, ' ';							// space
	rst print_a;						// output character
	jp loop;							// next character

pr_url:
	ld a, ']';							// closing square bracket
	rst print_a;						// output character

hide_url_loop:
	ld a, (hl);							// get character
	inc hl;								// next character
	cp ')';								// closing bracket
	jr nz, hide_url_loop;				// jump until 
	jp loop;							// immediate jump

;pr_codeblock:
;	call match_token;					// check for match
;	jp z, loop;							// jump if so
;	ld a, (hl);							// get character
;	cp '0';								// zero character?
;	jr c, pr_code_roman;				// jump if lower
;	cp ':';								// colon character?
;	jr c, pr_code_nm_bold;				// jump if lower
;    cp 'A';								// 'A'?
;	jr c, pr_code_roman;				// jump if lower
;	cp '[';								// square bracket?
;	jr c, pr_code_alpha_bold;			// jump if lower
;	cp 'a';								// 'a'?
;	jr c, pr_code_roman;				// jump if lower
;	cp '{';								// curly bracket?
;	jr c, pr_code_alpha_bold;			// jump if lower

;pr_code_roman:
;	rst print_a;						// print it
;	inc hl;								// next character
;	jr pr_codeblock;					// loop

;pr_code_nm_bold:
;	push hl;							// stack pointer
;	ld hl, bold;						// table base
;	sub $30;							// reduce range
;	ld e, a;							// copy to
;	ld d, 0;							// DE
;	add hl, de;							// offset
;	ld a, (hl);							// new character value
;	pop hl;								// unstack pointer
;	jr pr_code_roman;					// and print it

;pr_code_alpha_bold:
;	or %10000000;						// $81 ...
;	jr pr_code_roman;					// and print it	

set_bold:
	set 0, (ix);						// set bold
	jp loop;							// immediate jump

clr_bold:
	res 0, (ix);						// clear bold
	jp loop;							// immediate jump

set_italic:
	set 1, (ix);						// set bold
	jp loop;							// immediate jump

clr_italic:
	res 1, (ix);						// clear bold
	jp loop;							// immediate jump

;	// pre-processor check for a matching token
match_token:
	ld (pointer), hl;					// save pointer
	ex de, hl;							// swap pointers

match_loop:
	ld a, (de);							// next character to A
	bit 7, (hl);						// final character of a token?
	jr nz, match_last;					// jump if so
	cp (hl);							// compare with token
	jr nz, no_match_exit;				// jump if no match
	inc de;								// next character (in edit line)
	inc hl;								// next character (in token)
	jr match_loop;						// loop until done

match_last:
	or %10000000;						// set bit 7
	cp (hl);							// set zero flag if matched

match_exit:
	ex de, hl;							// restore pointers
	inc hl;								// next character
	ret z;								// return with match

no_match_exit:
	ld hl, (pointer);					// restore pointer
	ld a, (hl);							// restore character
	ret;								// return

;	// markdown and HTML
md_bold_o:
	defb "<b", '>' + $80;				// bold open tag

md_bold_c:
	defb "</b", '>' + $80;				// bold clos tag

md_bullet:
	defb '*', ' ' + $80;				// bullet

md_code_o:
	defb "<code", '>' + $80;			// code open tag

md_code_c:
	defb "</code", '>' + $80;			// code close tag

;md_codeblock:
;	defb "```", $8a;					// code block

md_kbd_o:
	defb "<kbd", '>' + $80;				// kbd open tag

md_kbd_c:
	defb "</kbd", '>' + $80;			// kbd clos tag

md_hr:
	defb "***", $8a;					// horizontal rule

md_samp_o:
	defb "<samp", '>' + $80;			// samp open tag

md_samp_c:
	defb "</samp", '>' + $80;			// samp clos tag

md_url:
	defb ']', '(' + $80;				// url open tag

md_var_o:
	defb "<var", '>' + $80;				// var open tag

md_var_c:
	defb "</var", '>' + $80;			// var close tag

;	// number offsets
italic:
	defb $9b;							// 0
	defb $9c;							// 1
	defb $9d;							// 2
	defb $9e;							// 3
	defb $9f;							// 4
	defb $bb;							// 5
	defb $bc;							// 6
	defb $bd;							// 7
	defb $be;							// 8
	defb $bf;							// 9

bold:
	defb $db;							// 0
	defb $dc;							// 1
	defb $dd;							// 2
	defb $de;							// 3
	defb $df;							// 4
	defb $fb;							// 5
	defb $fc;							// 6
	defb $fd;							// 7
	defb $fe;							// 8
	defb $ff;							// 9

flags:
	defb %11;							// italic + bold

pointer:
	defw 0;								// location in markdown file

	org $f000

buffer:
