; raster demo

	unoreg equ $fc3b
	unodat equ $fd3b

	org $bd00
	ld bc, unoreg;						// register select
	ld a, $0c;							// rasterline
	di;									// prevent maskable interrupt changing select register
	out (c), a;							// select it
	inc b;								// unodat
	xor a;								// LD A, 0
	out (c), a;							// set raster line to 0
	ei;									// reenable interrupts
	ld a, $be;							// interrupt vector
	ld i, a;							// set it
	im 2;								// set interrupt mode 2
	ret;								// back to BASIC

;	// -------------------------------------------------------------------------

;	// even rows
line_000:
line_016:
line_032:
line_048:
line_064:
line_080:
line_096:
line_112:
line_128:
line_144:
line_160:
line_174:
;	ld hl, $ffbf;						// d=data, e=reg
;	ld a, 30;							// foreground (ULAplus)
;	ld bc, $bf3b;						// register select
;	out (c), a;							// select it
;	ld b, h;							// data select
;	ld a, %10110110;					// light gray
;	out (c),a;							// set it
;
;	ld a, 22;							// foreground (Uno)
;	ld b, l;							// register select
;	out (c), a;							// select it
;	ld b, h;							// data select
;	ld a, %10110110;					// light gray
;	out (c),a;							// set it
;
;	pop bc;								// unstack
;	pop hl;								// used
;	push af;							// registers
;	ei;									// enable interrupts
;	ret;								// done

;	// odd rows
line_008:
line_024:
line_040:
line_056:
line_072:
line_088:
line_104:
line_120:
line_136:
line_152:
line_168:
line_184:
;	ld hl, $ffbf;						// d=data, e=reg
;	ld a, 30;							// foreground (ULAplus)
;	ld bc, $bf3b;						// register select
;	out (c), a;							// select it
;	ld b, h;							// data select
;	ld a, %11111111;					// white
;	out (c),a;							// set it
;
;	ld a, 22;							// foreground (Uno)
;	ld b, l;							// register select
;	out (c), a;							// select it
;	ld b, h;							// data select
;	ld a, %11111111;					// white
;	out (c),a;							// set it
;
	pop bc;								// unstack
	pop hl;								// used
	push af;							// registers
	ei;									// enable interrupts
	ret;								// done

;	// -------------------------------------------------------------------------

;	// raster line 0
	org $be00
	ld a, 8;							// line 8
	out (c), a;							// set raster interrupt
	jp line_000;						// immedaite jump

;	// raster line 8
	org $be08
	ld a, 16;							// line 16
	out (c), a;							// set raster interrupt
	jp line_008;						// immedaite jump

;	// raster line 16
	org $be10
	ld a, 24;							// line 24
	out (c), a;							// set raster interrupt
	jp line_016;						// immedaite jump

;	// raster line 24
	org $be18
	ld a, 32;							// line 32
	out (c), a;							// set raster interrupt
	jp line_024;						// immedaite jump

;	// raster line 32
	org $be20
	ld a, 40;							// line 40
	out (c), a;							// set raster interrupt
	jp line_032;						// immedaite jump

;	// raster line 40
	org $be28
	ld a, 48;							// line 48
	out (c), a;							// set raster interrupt
	jp line_040;						// immedaite jump

;	// raster line 48
	org $be30
	ld a, 56;							// line 56
	out (c), a;							// set raster interrupt
	jp line_048;						// immedaite jump

;	// raster line 56
	org $be38
	ld a, 64;							// line 64
	out (c), a;							// set raster interrupt
	jp line_056;						// immedaite jump

;	// raster line 64
	org $be40
	ld a, 72;							// line 72
	out (c), a;							// set raster interrupt
	jp line_064;						// immedaite jump

;	// raster line 72
	org $be48
	ld a, 80;							// line 80
	out (c), a;							// set raster interrupt
	jp line_072;						// immedaite jump

;	// raster line 80
	org $be50
	ld a, 88;							// line 88
	out (c), a;							// set raster interrupt
	jp line_080;						// immedaite jump

;	// raster line 88
	org $be58
	ld a, 96;							// line 96
	out (c), a;							// set raster interrupt
	jp line_088;						// immedaite jump

;	// raster line 96
	org $be60
	ld a, 104;							// line 104
	out (c), a;							// set raster interrupt
	jp line_096;						// immedaite jump

;	// raster line 104
	org $be68
	ld a, 112;							// line 112
	out (c), a;							// set raster interrupt
	jp line_104;						// immedaite jump

;	// raster line 112
	org $be70
	ld a, 120;							// line 120
	out (c), a;							// set raster interrupt
	jp line_112;						// immedaite jump

;	// raster line 120
	org $be78
	ld a, 128;							// line 128
	out (c), a;							// set raster interrupt
	jp line_120;						// immedaite jump

;	// raster line 128
	org $be80
	ld a, 136;							// line 136
	out (c), a;							// set raster interrupt
	jp line_128;						// immedaite jump

;	// raster line 136
	org $be88
	ld a, 144;							// line 144
	out (c), a;							// set raster interrupt
	jp line_136;						// immedaite jump

;	// raster line 144
	org $be90
	ld a, 152;							// line 152
	out (c), a;							// set raster interrupt
	jp line_144;						// immedaite jump

;	// raster line 152
	org $be98
	ld a, 160;							// line 160
	out (c), a;							// set raster interrupt
	jp line_152;						// immedaite jump

;	// raster line 160
	org $bea0
	ld a, 168;							// line 168
	out (c), a;							// set raster interrupt
	jp line_160;						// immedaite jump

;	// raster line 168
	org $bea8
	ld a, 176;							// line 176
	out (c), a;							// set raster interrupt
	jp line_168;						// immedaite jump

;	// raster line 176
	org $beb0
	ld a, 184;							// line 184
	out (c), a;							// set raster interrupt
	jp line_174;						// immedaite jump

;	// raster line 184
	org $beb8
	ld a, 192;							// line 192
	out (c), a;							// set raster interrupt
	jp line_184;						// immedaite jump

;	// raster line 192
	org $bec0
	ld a, 0;							// line 0
	out (c), a;							// set raster interrupt
	pop bc;								// unstack BC only
	jp $003a;							// jump into maskable interrupt routine without invoking divMMC

;	// -------------------------------------------------------------------------

;	// interrupt routine
	org $bee0
im2_routine:
	push af;							// stack
	push hl;							// registers
	push bc;							// used
	ld bc, unoreg;						// register select
	ld a, $0c;							// rasterline
	out (c), a;							// select it
	inc b;								// unodat
	in a, (c);							// get value of rasterline
	ld h, $be;							// high byte of address
	ld l, a;							// low byte of address;
	jp (hl);							// jump to routine

;	// interupt vector
	org $beff
	defw im2_routine;					// address to jump to
