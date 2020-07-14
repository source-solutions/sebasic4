;	// raster line background
;	// Copyright (c) 2020 Source Solutions, Inc.
;	// an example of how to set a different background color on each scan line

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
	ld a, $be;							// interrupt vector
	ld i, a;							// set it
	im 2;								// set interrupt mode 2
	ret;								// back to BASIC

;	// interrupt routine
interrupt_routine:
	push af;							// stack registers
	push hl;
	push bc;

	ld bc, $bf3b;						// palette register select
	ld a, 22;							// foreground (uno)
	out (c), a;							// select it

	ld bc, unoreg;						// register select
	ld a, 12;							// rasterline
	out (c), a;							// select it
	inc b;								// unodat
	in a, (c);							// get current raster line
	inc a;								// next line
	out (c), a;							// set raster line

	ld bc, $ff3b;						// palette data select
	out (c), a;							// set foreground color

	and a;								// current line is 255 (A - 1)?
	call z, $0038;						// call the keyboard routine if so

	pop bc;								// unstack registers
	pop hl;
	pop af;

	ei;									// interrupts on
	ret;								// return
