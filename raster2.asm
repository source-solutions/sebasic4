; raster demo

	unoreg equ $fc3b;
	unodat equ $fd3b;
	raster_line equ 12;
	raster_ctrl equ 13;

	org $8000
	ei;									// interrupts on
	ld bc, unoreg;						// register select
	ld a, raster_line;					// rasterline
	out (c), a;							// select it
;	ld bc, unodat;						// data select
	inc b;								// unodat
	xor a;								// LD A, 0
	out (c), a;							// set raster line to 0

;	ld bc, unoreg;						// register select
	dec b;								// unoreg
	ld a, raster_ctrl;					// rasterctrl
	out (c), a;							// select it
;	ld bc, unodat;						// data select
	inc b;								// unodat
	ld a, %00000110;					// enable raster interrupt
	out (c), a;							// select it

	ld a, $80;							// interrupt vector
	ld i, a;							// set it
	im 2;								// set interrupt mode 2
	ret;								// back to BASIC

;	// interupt vector
	org $80ff
	push bc;
	push af;
	push hl;

	ld bc, unoreg;						// register select
	ld a, raster_line;					// rasterline
	out (c), a;							// select it
;	ld bc, unodat;						// data select
	inc b;								// unodat
	in a, (c);							// get value of rasterline

	inc a;								// next line
	out (c), a;							// set interrupt to next line
	out ($fe), a;						// set border
	pop bc;								// unstack BC
	and a;								// test for zero (in which case current line is 255)
	jp z, $003a;						// jump into IM 1 routine if so to read keyboard

	pop hl;								// else restore
	pop af;								// AF and HL
	ei;									// re-enable interrupts
	ret;								// and done
