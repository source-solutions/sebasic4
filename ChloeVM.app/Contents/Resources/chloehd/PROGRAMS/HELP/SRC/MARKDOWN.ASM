;	// MARKDOWN - A file viewer for a subset of Markdown features
;	// Copyright (c) 2022 Source Solutions, Inc.

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
	bit 1, (ix);						// italic flag set (overrides bold)
	jr nz, pr_italic;					// jump if so
	bit 0, (ix);						// italic flag set (overrides bold)
	jr nz, pr_bold;						// jump if so

pr_roman:
	rst print_a;						// print A
	inc hl;								// next character
	jr loop;							// loop until done

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

	org $f000

buffer:
