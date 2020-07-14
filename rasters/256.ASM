;	// 64 x 192 x 256 software video mode
;	// Copyright (c) 2020 Source Solutions, Inc.
;	// in the event that the CPU isn't fast enough to write all 64 attributes per line
;   // reduce the screen width

    org $8000

;   // init
    push af;
    push bc;
    push de;
    push hl;
    di;

    ld hl, $5800;                       // low res attirbute area

    xor a;                              // CLUT 0, paper 0, pen 0
    ld b, 8;                            // count

clut0:
    ld (hl), a;                         // set attribute
    inc hl;                             // next attribute
    add a, %00001001;                   // increment paper and pen
    djnz clut0;                         // loop until done

    ld a, %01000000;                    // CLUT 1, paper 0, pen 0
    ld b, 8;                            // count

clut1:
    ld (hl), a;                         // set attribute
    inc hl;                             // next attribute
    add a, %00001001;                   // increment paper and pen
    djnz clut1;                         // loop until done

    ld a, %10000000;                    // CLUT 2, paper 0, pen 0
    ld b, 8;                            // count

clut2:
    ld (hl), a;                         // set attribute
    inc hl;                             // next attribute
    add a, %00001001;                   // increment paper and pen
    djnz clut2;                         // loop until done

    ld a, %11000000;                    // CLUT 3, paper 0, pen 0
    ld b, 8;                            // count

clut3:
    ld (hl), a;                         // set attribute
    inc hl;                             // next attribute
    add a, %00001001;                   // increment paper and pen
    djnz clut3;                         // loop until done

    ld hl, $5800;                       // start of attributes
    ld de, $5820;                       // destination
    ld b, 24;                           // low res lines to do

attr_fill:
    push bc;                            // stack count
    ld bc, 32;                          // byte count
    ldir;                               // copy 32 bytes
    pop bc;                             // unstack count
    djnz attr_fill;                     // loop until done

bmp_fill:
    ld hl, $4000;                       // start of bitmap
    ld de, $4001;                       // destination
    ld bc, 6143;                        // byte count
    ld a, %11110000;                    // first color will be pen
    ld (hl), a;                         // set first byte
    ldir

;   // required for original ROM
	ld bc, $fc3b;						// LD BC, uno_reg
	ld a, 12;       					// rasterline
	out (c), a;							// select it
	inc b;								// LD BC, uno_dat
	xor a;  							// LD A, 0
	out (c), a;							// set raster line to 0

	dec b;								// LD BC, uno_reg
	ld a, 13;		        			// rasterctrl
	out (c), a;							// select it
	inc b;								// LD BC, uno_dat
	ld a, %00000110;					// enable raster interrupt, switch off ULA interrupts
	out (c), a;							// select it
;   // end of original ROM setup

    ld a, $80;                          // IM2 addreess $80(ff)
    ld i, a;                            // set it
    im 2;           

    pop hl;
    pop de;
    pop bc;
    pop af;
    ei;
    ret;

;   // vector
    org $80ff;
im2_vector:
    defw im2_enter

;   // display code
im2_enter:
    push af;                            // stack registers
    push bc;
    push de;
    push hl;

lineaddr:
    ld hl, image;                       // start of data
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

im2_exit:
    pop hl;
    pop de;
    pop bc;
    pop af;
    ei;
    ret;

    defb "end";

;   // 12288 bytes of image data (64 x 192 pixel, 256 colors)
image:
rept 48
    defb $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f;
    defb $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f;
    defb $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f;
    defb $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $3f;
    defb $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f;
    defb $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d, $5e, $5f;
    defb $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $6e, $6f;
    defb $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f;
    defb $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8a, $8b, $8c, $8d, $8e, $8f;
    defb $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $9f;
    defb $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af;
    defb $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf;
    defb $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf;
    defb $d0, $d1, $d2, $d3, $d4, $d5, $d6, $d7, $d8, $d9, $da, $db, $dc, $dd, $de, $df;
    defb $e0, $e1, $e2, $e3, $e4, $e5, $e6, $e7, $e8, $e9, $ea, $eb, $ec, $ed, $ee, $ef;
    defb $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8, $f9, $fa, $fb, $fc, $fd, $fe, $ff;
endm
