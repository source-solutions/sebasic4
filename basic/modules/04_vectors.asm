;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2023 Source Solutions, Inc.

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

;	// temp - FIXME

;;
; 1-bit speaker
;;
beeper:
	di;									// interrupts off
	ld a, l;							// store L
	srl l;								// shift right logical
	srl l;								// to produce int (l/4)
	cpl;								// restore L
	and %00000011;						// get remainder
	ld b, 0;							// offset
	ld c, a;							// to BC
	ld ix, be_ix_plus_3;				// base loop
	add ix, bc;							// update loop length
	ld a, (bordcr);						// get border color
	and %00111000;						// discard unwanted bits
	rrca;								// rotate
	rrca;								// into
	rrca;								// place
	or %00001000;						// MIC off

be_ix_plus_3:
	nop;								// 12 t-state delay
	nop;								// 8 t-state delay
	nop;								// 4 t-state delay
	inc c;								// values in BC
	inc b;								// derived from HL

be_h_and_l_lp:
	dec c;								// timing loop
	jr nz, be_h_and_l_lp;				// 12 or 7 t-state jump
	dec b;								// reduce B
	ld c, 63;							// timing constant
	jp nz, be_h_and_l_lp;				// 10 t-state jump
	xor %00010000;						// toggle bit 4
	out (ula), a;						// write port
	ld c, a;							// store byte written
	ld b, h;							// reset B
	bit 4, a;							// half-cycle point?
	jr nz, be_again;					// jump if so
	ld a, e;							// test for
	or d;								// final pass
	jr z, be_end;						// jump if so
	dec de;								// decrease pass counter
	ld a, c;							// restore byte written
	ld c, l;							// reset C
	jp (ix);							// back to loop offset

be_again:
	ld c, l;							// reset C
	inc c;								// add 16 t-states
	jp (ix);							// jump back

be_end:
	ei;									// restore interrupts
	ret;								// end of subroutine

;	// SOUND <pitch integer>, <duration in seconds>
;;
; <code>SOUND</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#SOUND" target="_blank" rel="noopener noreferrer">Language reference</a>
;;
c_sound:
	fwait;								// enter calc with pitch and duration on stack
	fxch;								// d, p
	fmove;								// d, p, p
	fint;								// d, p, i (i = INT p)
	fst 0;								// i to mem_0
	fsub;								// d, p (p = fractional part of p)
	fstk;								// stack k
	defb $ec;							// exponent (112)
	defb $6c, $98, $1f, $f5;			// mantissa (0.0577622606)
	fmul;								// d, pk
	fstk1;								// d, pk, 1
	fadd;								// d, pk + 1
	fce;								// exit calculator
	ld hl, membot;						// mem_0 1st
	ld a, (hl);							// get exponent
	and a;								// error if not in 
	jr nz, report_overflow_0;			// short form
	inc hl;								// next location
	ld c, (hl);							// sign byte to C
	inc hl;								// next location
	ld b, (hl);							// low byte to B
	ld a, b;							// low byte to A
	rla;								// rotate left accumulator
	sbc a, a;							// subtract with carry
	cp c;								// -128 <= i <= +127
	jr nz, report_overflow_0;			// error if test failed
	inc hl;								// increment HL
	cp (hl);							// test against (HL)
	jr nz, report_overflow_0;			// error if not
	ld a, 60;							// set range
	add a, b;							// test low byte
	jp p, be_i_ok;						// jump if -60 <= i <=67
	jp po, report_overflow_0;			// error if -128 to -61

be_i_ok:
	ld b, 250;							// 6 octaves below middle C

be_octave:
	sub 12;								// reduce i to find
	inc b;								// correct octave
	jr nc, be_octave;					// loop until found
	ld hl, semi_tone;					// base of table
	push bc;							// stack octave
	add a, 12;							// pass back last subtraction
	call loc_mem;						// consider table and pass value
	call stack_num;						// at (A) to calculator stack
	fwait;								// d, pk + 1, C
	fmul;								// d, C(pk + 1)
	fce;								// exit calculator
	pop af;								// unstack octave
	add a, (hl);						// multiply last value by 2^A
	ld (hl), a;							// d, f
	fwait;								// store frequency
	fst 0;								// in mem_0
	fdel;								// remove last item
	fmove;								// d, d
	fce;								// exit calculator
	call find_int1;						// value 'INT d' must be
	cp 11;								// 0 to 11
	jr nc, report_overflow_0;			// jump if not
	fwait;								// d
	fgt 0;								// d, f
	fmul;								// f * d
	fgt 0;								// f * d, f
	fstk;								// stack 3.5 x 10^6 / 8
	defb $80;							// four bytes
	defb $43;							// mantissa
	defb $55, $9f, $80;					// exponent
	fxch;								// f * d, 437500, f
	fdiv;								// f * d, 437500 / f
	fstk;								// stack it
	defb $35;							// exponent
	defb $6c;							// mantissa
	fsub;								// subtract
	fce;								// exit calculator
	call find_int2;						// timing loop compressed into BC
	push bc;							// stack loop
	call find_int2;						// f*d value compressed into BC
	pop hl;								// unstack loop into HL
	ld e, c;							// move f*d value
	ld d, b;							// to
	ld a, e;							// DE
	or d;								// no cycles required?
	ret z;								// return if so
	dec de;								// reduce cycle count
	jp beeper;							// exit via beeper subroutine

report_overflow_0:
	rst error;
	defb overflow;

;;
; play bell
;;
bell:
;	ld (iy + _err_nr), 255;				// clear error
	ld de, (rasp);						// pitch
	ld hl, 2148;						// duration
	jp beeper;							// sound rasp and exit

;;
; mute PSG
;;
;mute_psg:
;	ld hl, $fe07;						// H = AY-0, L = Volume register (7)
;	ld de, $bfff;						// D = data port, E = register port / mute
;	ld c, $fd;							// low byte of AY port
;	call mute_ay;						// mute AY-0
;	inc h;								// AY-1
;
;mute_ay:
;	ld b, e;							// AY register port
;	out (c), h;							// select AY (255/254)
;	out (c), l;							// select register
;	ld b, d;							// AY data port
;	out (c), e;							// AY off;
;	ret;								// end of subroutine

;	// end of temp - FIXME

;;
;	// --- VECTOR TABLE ---------------------------------------------------------
;;
:

;	// PC must not hit $04c6 (load trap) or $0562 (save trap)

;	org $04c6;
;load_trap:
;	ret;								// must never call this address

;	org $0562;
;save_trap:
;	ret;								// must never call this address

	org $04c4;

;;
; open a file for appending if it exists
; @param IX - pointer to ASCIIZ file path
; @throws sets carry flag on error
;;
SEFileAppend:
	jp v_open_w_append;					// $00

;;
; close a file
; @param A - file handle
; @throws sets carry flag on error
;;
SEFileClose:
	jp v_close;							// $01

;;
; create a file for writing or open a file for writing if it exists
; @param IX - pointer to ASCIIZ file path
; @throws sets carry flag on error
;;
SEFileCreate:
	jp v_open_w_create;					// $02

;;
; load a file from disk to memory
; @param HL - destination address
; @param IX - pointer to ASCIIZ file path
; @throws sets carry flag on error
;;
SEFileLoad:
	jp v_load;							// $03

;;
; open a file from disk
; @param IX - pointer to ASCIIZ file path
; @return file handle in <code>A</code>
; @throws sets carry flag on error
;;
SEFileOpen:
	jp v_open;							// $04

;;
; open a file from disk for reading if it exists
; @param IX - pointer to ASCIIZ file path
; @return file handle in <code>A</code>
; @throws sets carry flag on error
;;
SEFileOpenExists:
	jp v_open_r_exists;					// $05

;;
; read bytes from a file to memory
; @param A - file handle
; @param BC - byte count
; @param IX - destination in memory
; @throws sets carry flag on error
;;
SEFileRead:
	jp v_read;							// $06

;;
; read one byte from a file to memory
; @param A - file handle
; @param IX - destination in memory
; @throws sets carry flag on error
;;
SEFileReadOne:
	jp v_read_one;						// $07

;;
; remove a file
; @param IX - pointer to ASCIIZ file path
; @throws sets carry flag on error
;;
SEFileRemove:
	jp v_delete;						// $08

;;
; rename a file or folder
; @param DE - pointer to new ASCIIZ path
; @param IX - pointer to old ASCIIZ path
; @throws sets carry flag on error
;;
SEFileRename:
	jp v_rename;						// $09

;;
; save a file from memory to disk
; @param BC - byte count
; @param HL - source address
; @param IX - pointer to ASCIIZ file path
; @throws sets carry flag on error
;;
SEFileSave:
	jp v_save;							// $0a

;;
; write bytes from memory to a file
; @param A - file handle
; @param BC - byte count
; @param IX - source in memory
; @throws sets carry flag on error
;;
SEFileWrite:
	jp v_write;							// $0b

;;
; write one byte from memory to a file
; @param A - file handle
; @param IX - source in memory
; @throws sets carry flag on error
;;
SEFileWriteOne:
	jp v_write_one;						// $0c

;;
; create a folder
; @param IX - pointer to ASCIIZ folder path
; @throws sets carry flag on error
;;
SEFolderCreate:
	jp v_mkdir;							// $0d

;;
; open a folder for reading
; @param IX - pointer to ASCIIZ folder path
; @return folder handle in <code>A</code>
; @throws sets carry flag on error
;;
SEFolderOpen:
	jp v_opendir;						// $0e

;;
; read a folder entry
; @param A - folder handle
; @param IX - destination memory address
; @throws sets carry flag on error
;;
SEFolderRead:
	jp v_readdir;						// $0f

;;
; remove a folder
; @param IX - pointer to ASCIIZ folder path
; @throws sets carry flag on error
;;
SEFolderRemove:
	jp v_rmdir;							// $10

;;
; set current working folder
; @param IX - pointer to ASCIIZ folder path
; @throws sets carry flag on error
;;
SEFolderSet:
	jp v_chdir;							// $11


;	// RESERVED
	jp $ffff;							// $12

;	// RESERVED
	jp $ffff;							// $13

;;
; set the screen mode
; @param A - mode (0 system, 1 user)
;;
SEScreenMode:
	jp v_scr_mode;						// $14

;;
; clear the screen
;;
SEScreenClear:
	jp v_cls;							// $15

;;
; print an ASCIIZ string to the main display
; @param IX - pointer to ASCIIZ string
;;
SEScreenPrintString:
	jp v_pr_str;						// $16

;;
; print an ASCIIZ string to the lower display
; @param IX - pointer to ASCIIZ string
;;
SEScreenLowerPrintString:
	jp v_pr_str_lo;						// $17

;;
; set the 64 palette registers (during vblank)
; @param IX - pointer to 64 bytes of palette data
;;
SEPaletteSet:
	jp v_write_pal;						// $18

;;
; flush keyboard buffer
;;
SEKeyFlushBuffer:
	jp flush_kb;						// $19

;;
; get a character from keyboard buffer
;;
SEKeyWait
	jp v_key_wait;						// $1a

; $1b
	jp $ffff;							// 

; $1c
	jp $ffff;							// 

; $1d
	jp $ffff;							// 

; $1e
	jp $ffff;							//

; $1f
	jp $ffff;							// 

; $20
	jp $ffff;							// 

; $21
	jp $ffff;							// 

; $22
	jp $ffff;							// 

; $23
	jp $ffff;							// 

; $24
	jp $ffff;							// 

; $25
	jp $ffff;							//

; $26
	jp $ffff;							// 

; $27
	jp $ffff;							// 

; $28
	jp $ffff;							// 

; $29
	jp $ffff;							// 

; $2a
	jp $ffff;							// 

; $2b
	jp $ffff;							// 

; $2c
	jp $ffff;							// 

; $2d
	jp $ffff;							// 

; $2e
	jp $ffff;							// 

; $2f
	jp $ffff;							// 

; $30
	jp $ffff;							// 

; $31
	jp $ffff;							// 

; $32
	jp $ffff;							// 

; $33
	jp $ffff;							// 

; $34
	jp $ffff;							// ($0562 must never be called)

;	// permits extension of vector table if required

;dll_init:
;    pop hl;                             // get return address
;
;    ld e, l;                            // store it in
;    ld d, h;                            // DE
;
;    dec hl;                             // point to init address
;    dec hl;                             //
;    dec hl;                             //
;
;    push hl;                            // stack it
;
;    ex de, hl;                          // first label to HL
;
;label:
;    ld c, (hl);                         // label address to BC
;    inc hl;                             //
;    ld b, (hl);                         // 
;
;    inc hl;                             // next word
;
;    ld a, c;                            // test for final end marker
;    or b;                               //
;    jr z, init_patch;                   // jump if so
;
;    ex de, hl;                          // store index pointer in DE
;    pop hl;                             // get init address
;    push hl;                            // restack it
;    add hl, bc;                         // get real addres
;    ld c, l;                            // store it in
;    ld b, h;                            // BC
;    ex de, hl;                          // restore index pointer to HL
;
;patch:
;    ld e, (hl);                         // patch address to DE
;    inc hl;                             //
;    ld d, (hl);                         //
;
;    inc hl;                             // next word
;
;    ld a, e;                            // test for patch end marker
;    or d;                               //
;    jr z, label;                        // jump if so to do next label
;
;    push hl;                            // store HL
;    pop ix;                             // in IX
;    pop hl;                             // get init address
;    push hl;                            // restack it
;    add hl, de;                         // label address to HL
;    ld (hl), c;                         // write low byte of label address
;    inc hl;                             // address high byte
;    ld (hl), b;                         // write high byte of label address
;    push ix;                            // restore IX
;    pop hl;                             // to HL
;
;    jr patch;                           // loop for next address
;
;init_patch;
;    ex de, hl;                          // start address to DE
;    pop hl;                             // init address to HL
;   
;    push hl;                            // restack it
;
;    ld (hl), $c3;                       // jump instruction
;    inc hl;                             // next address
;    ld (hl), e;                         // low byte of start
;    inc hl;                             // next address
;    ld (hl), d;                         // high byte of start
;
;    pop hl;                             // unstack init address
;
;    jp (hl);                            // immedaite jump (execute routine)
;
