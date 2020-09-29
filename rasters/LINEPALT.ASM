;	// per-line palettes (alternate approach)
;	// Copyright (c) 2020 Source Solutions, Inc.
;	// a software video mode that changes palette every scan line

	org 32868

set_bmp:
	ld hl, $c000;						// start of screen in top of RAM
	ld de, $c001;						// destination
	ld bc, 6143;						// bytes to write
	ld (hl), %11110000;					// set each cell to foreground first
	ldir;								// block copy

set_attrs:
	ld hl, attrs;						// attribute data
	ld de, $e000;						// offset to attributes
	ld bc, 32;							// do first screen line
	ldir;								// block copy;
	ld hl, $e000;						// start of attributes in top of RAM, DE = HL + 32
	ld bc, 6112;						// remaining bytes to write
	ldir;								// block copy
	ret;								// done

attrs:
	defb %00000000, %00001001, %00010010, %00011011, %00100100, %00101101, %00110110, %00111111
	defb %01000000, %01001001, %01010010, %01011011, %01100100, %01101101, %01110110, %01111111
	defb %10000000, %10001001, %10010010, %10011011, %10100100, %10101101, %10110110, %10111111
	defb %11000000, %11001001, %11010010, %11011011, %11100100, %11101101, %11110110, %11111111



;   // display code
im2_enter:
    push af;                            // stack registers
    push bc;
    push de;
    push hl;

lineaddr:
    ld hl, pal;               	        // start of palette data
	ld de, $bf00;		                // D = register select, E = data port (+1 due to OUTI)
	ld c, $3b;			                // C = ZXI base port

	xor a;                              // first CLUT entry is zero
im2_clut_0:
	ld b, d;                            // register port
	out (c), a;                         // set CLUT
	ld b, e;                            // data port
	outi;                               // set color
    add a, 8;                           // next paper CLUT entry

	ld b, d;                            // register port
	out (c), a;                         // set CLUT
	ld b, e;                            // data port
	outi;                               // set color
    sub 7;                              // next pen CLUT entry
    cp 8;                               // end reached?
    jr nz, im2_clut_0;                  // loop until done

    ld a, 16
im2_clut_1:
	ld b, d;                            // register port
	out (c), a;                         // set CLUT
	ld b, e;                            // data port
	outi;                               // set color
    add a, 8;                           // next paper CLUT entry

	ld b, d;                            // register port
	out (c), a;                         // set CLUT
	ld b, e;                            // data port
	outi;                               // set color
    sub 7;                              // next pen CLUT entry
    cp 16;                              // end reached?
    jr nz, im2_clut_1;                  // loop until done

    ld a, 32
im2_clut_2:
	ld b, d;                            // register port
	out (c), a;                         // set CLUT
	ld b, e;                            // data port
	outi;                               // set color
    add a, 8;                           // next paper CLUT entry

	ld b, d;                            // register port
	out (c), a;                         // set CLUT
	ld b, e;                            // data port
	outi;                               // set color
    sub 7;                              // next pen CLUT entry
    cp 32;                              // end reached?
    jr nz, im2_clut_2;                  // loop until done

    ld a, 48
im2_clut_3:
	ld b, d;                            // register port
	out (c), a;                         // set CLUT
	ld b, e;                            // data port
	outi;                               // set color
    add a, 8;                           // next paper CLUT entry

	ld b, d;                            // register port
	out (c), a;                         // set CLUT
	ld b, e;                            // data port
	outi;                               // set color
    sub 7;                              // next pen CLUT entry
    cp 48;                              // end reached?
    jr nz, im2_clut_3;                  // loop until done

    ld (lineaddr + 1), hl;              // update pointer to next data

	ld bc, $fc3b;						// register select
	ld a, 12;							// rasterline
	out (c), a;							// select it
	inc b;								// unodat
	in a, (c);							// get current raster line
	inc a;								// next line
	out (c), a;							// set raster line

    cp 192;                             // line 192
    jr nz, im2_exit;                    // jump if not

    xor a;                              // set next interrupt to line 0
	out (c), a;							// set raster line

    ld hl, image;                       // point to start of image
    ld (lineaddr + 1), hl;              // update pointer to next data

	call $0038; 						// call the keyboard routine