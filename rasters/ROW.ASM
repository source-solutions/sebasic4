;	// raster line by row
;	// Copyright (c) 2020 Source Solutions, Inc.
;	// an example of how to set a different color pair on each row

;	// 10 CLEAR $BEFC
;	// 20 BLOAD "BACKGRND.BIN", $BEFD
;	// 30 CALL $BEFD
;	// 40 CLEAR $BEFE

;	// after NEW, restart with CALL $BF01

	unoreg equ $fc3b
	unodat equ $fd3b

;	// initialization
	org $befd
	jr setup

;	// interrupt vector
	org $beff
	defw interrupt_routine;				// address of interrupt routine

;	// setup
setup:
	ld bc, unoreg;						// register select
	ld a, 12;							// rasterline
	di;									// normal interrupt changes selected register
	out (c), a;							// select it
	inc b;								// unodat
	xor a;								// LD A, 0
	out (c), a;							// set raster line to 0
	ei;									// enable interrupts

	ld a, $be;							// interrupt vector
	ld i, a;							// set it
	im 2;								// set interrupt mode 2
	ret;								// back to BASIC

;	// interrupt routine
interrupt_routine:
	push af;							// stack registers
	push hl;
	push bc;
	push de;

	ld b, 12
pause:
	nop;								// wait until start of next line
	djnz pause;							// loop until done

	ld bc, unoreg;						// register select
	ld a, 12;							// rasterline
	out (c), a;							// select it
	inc b;								// unodat
	in a, (c);							// get current raster line

	ld h, 0;							// clear H
	ld l, a;							// current to L
	srl l;								// divide
	srl l;								// by 4

	add a, 8;							// next row
	out (c), a;							// set raster line

	push af;							// stack result

	ld de, table;						// offset
	add hl, de;							// address

	ld bc, $bf3b;						// palette register select
	ld a, 22;							// foreground (uno)
	out (c), a;							// select it
	ld bc, $ff3b;						// palette data select
	ld a, (hl);							// get foreground from table
	out (c), a;							// set it

	inc hl;								// address background

	ld bc, $bf3b;						// palette register select
	ld a, 25;							// background
	out (c), a;							// select it
	ld bc, $ff3b;						// palette data select
	ld a, (hl);							// get foreground from table
	out (c), a;							// set it

	pop af;								// unstack result
	and a;								// next interrupt on line zero?
	call z, $0038;						// call the keyboard routine if so

	pop de;								// unstack registers
	pop bc;
	pop hl;
	pop af;

	ei;									// interrupts on
	ret;								// return

table;
	defb   0, 253;
	defb  11, 242;
	defb  22, 231;
	defb  33, 220;
	defb  44, 209;
	defb  55, 198;
	defb  66, 187;
	defb  77, 176;
	defb  88, 165;
	defb  99, 154;
	defb 110, 143;
	defb 121, 132;
	defb 132, 121;
	defb 143, 110;
	defb 154, 99;
	defb 165, 88;
	defb 176, 77;
	defb 187, 66;
	defb 198, 55;
	defb 209, 44;
	defb 220, 33;
	defb 231, 22;
	defb 242, 11;
	defb 253, 0;
