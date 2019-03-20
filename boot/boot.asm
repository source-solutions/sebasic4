;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2019 Source Solutions, Inc.

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

; 	// This source is compatible with Zeus (http://www.desdes.com/products/oldfiles)

	zoWarnFlow = false;					// prevent pseudo op-codes triggering warnings.
	output_bin "../bin/boot.rom",0,$4000

	mmu		equ	$f4
	scld	equ	$ff
	paging	equ $7ffd

	org $0000;
	di;									// interrupts off
	rst $18;							// quick jump if DOS has been patched to enable ROM0

	org $0007;
	rst 18h;							// quick jump avoids triggering error detect

	org $0008;
	ret;								// trapped address

	org $0009;
to_rom1:
	ld de, $ffff;						// RAMTOP
	ld bc, paging;						// HOME bank paging
	ld l, %00011000;					// ROM 1, VID 1, RAM 0
	out (c), l;							// swap

	org $0018;
	jr init;							// jump to avoid trapped address

	org $0020;
;	// ASCII art, just for fun
ascii:
	defb " ____ ____ ____ "
	defb "||2 |||8 |||0 ||"
	defb "||__|||__|||__||"
	defb $7c, $2f, $5f, $5f, $5c, $7c, $2f, $5f, $5f, $5c, $7c, $2f, $5f, $5f, $5c, $7c

	org $0066;
	ret;								// trapped address

	org $0067;
init:
	ld sp, $7fff;						// set stack pointer to top of HOME page 5
	call low_8;							// wipe the lowest 8KiB of sideways RAM
	ld a, %11111110;					// page in all but the lower 8KiB of EX bank
	out (mmu),a;						// set it
	xor a;								// LD A, 0
	out ($fe), a;						// get rid of yellow border (from lazy decoding)

;	// wipe ex bank
	ld hl, $2000;						// start with first visible bank
	ld de, $2001;						// copy from destination
	ld bc, 57343;						// 56KiB less one byte
	ld (hl), a;							// clear first byte
	ldir;								// wipe it

;	// wipe dock bank
	out (scld), a;						// set dock bank
	dec de;								// RAMPTOP
	dec de;								// one below RAMTOP
	ld bc, 57343;						// 56KiB less one byte
	ld (hl), a;							// clear last byte
	lddr;								// wipe it

;	// page out shadow RAM
	out (mmu),a;						// set it

;	// wipe home bank
;	//
;	// skip page 5 for now because it contians the boot logo and the stack
;	// skip page 0 because it will be wiped by the BASIC ROM
;	// page 2 gets wiped twice on a 256K machine but if there is a page 8 at $c000
;	// instead, it will get wiped by the BASIC ROM

	ld a, 7;							// top bank

wipe_home:
	cp 5;								// page 5?
	jr nz, not_5;						// jump if not
	dec a;								// skip page 5 (don't wipe stack)
	
not_5:
	ld bc, paging;						// HOME bank paging
	out (c), a;							// set page
	call wipe_page;						// wipe page
	ld b, a;							// use a as counter
	dec a;								// next page
	djnz wipe_home;						// loop around until all pages are done

;	// install font
	ld a, %00001111;					// ROM 0, VID 1, RAM 7
	ld bc, paging;						// HOME bank paging
	out (c), a;							// set it
	ld hl, font;						// soruce
	ld de, $f800;						// destination
	ld bc, 2048;						// 2KiB of data
	ldir;								// block copy

;	// set palette
	ld c, $3b;							// ULAplus port
	ld de, $00bf;						// d = data + 1, e = register
	xor a;								// LD A, 0-2

pal_1st:
	ld hl, ega_pal;						// start of data
	jr pal_loop;

pal_2nd:
	ld hl, ega_pal + 8;					// offset to bright colors

pal_loop:
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port + 10
	outi;								// DEC B
;										// OUT BC, (HL)
;										// DEC HL
	inc a;								// next register

	cp 8;
	jr z, pal_1st;						// jump if so
	
	cp 24;
	jr z, pal_1st;						// jump if so

	cp 32;
	jr z, pal_1st;						// jump if so

	cp 48;
	jr z, pal_2nd;						// jump if so
	
	cp 56;
	jr z, pal_2nd;						// jump if so

	cp 65;
	jr nz, pal_loop;					// loop until done

;	// read palette back into buffer in HOME 7
	ld c, $3b;							// ULAplus port
	ld de, $ffbf;						// d = data, e = register
	ld hl, $dfff;						// last byte of palette map
	ld a, 64;							// becomes 63	

read_pal:
	dec a;								// next register
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	ind;								// in (hl), bc; dec b; dec hl
	and a;								// was that the last register?
	jr nz, read_pal;					// set all 64 entries

;	// wipe page 5
	ld a, 5;							// stack no longer required 
	ld bc, paging;						// HOME bank paging
	out (c), a;							// so safe to wipe page 5
	ld hl, $c000;						// start of paged RAM
	ld de, $c001;						// next byte
	ld bc, 16383;						// 16 KiB less one byte
	ld (hl), l;							// clear first byte
	ldir;								// wipe it

;	// copy second part of ROM to correct place
;	// (basic goes up to $5bb9, sysvars start at $5bba)
	ld hl, basic;
	ld de, $4000;
	ld bc, 7098;
	ldir;

; switch ROMs
	jp to_rom1;							// start BASIC

ega_pal:
;										// #	name			G R B
	defb %00000000;						// 00 	black			0 0 0  
	defb %00000010;						// 01	blue			0 0 2
	defb %10100000;						// 02	green			5 0 0
	defb %10100010;						// 03	cyan			5 0 2
	defb %00010100;						// 04	red				0 5 0
	defb %00010110;						// 05	magenta			0 5 2
	defb %01110100;						// 06	brown			3 5 0
	defb %10110110;						// 07	light gray		5 5 2
	defb %01101101;						// 08	dark gray		3 3 1
	defb %01101111;						// 09	bright blue		3 3 3
	defb %11101101;						// 10	bright green	7 3 1
	defb %11101111;						// 11	bright cyan		7 3 3
	defb %01111101;						// 12	bright red		3 7 1
	defb %01111111;						// 13	bright magenta	3 7 3
	defb %11111101;						// 14	bright yellow	7 7 1
	defb %11111111;						// 15	bright white	7 7 3

pal_end:
	defb 1;								// enable ULAplus

wipe_page:
	ld hl, $c000;						// start of paged RAM
	ld de, $c001;						// next byte
	ld bc, 16383;						// 16 KiB less one byte
	ld (hl), l;							// clear first byte
	ldir;								// wipe it
	ret;								// done

;	// part two of BASIC
	org $0400
basic:
	import_bin "basic.bin"

; wipe lower 8KiB of shadow RAM

	org $2000;
low_8:
	xor a;								// dock bank
	out (scld), a;						// set it
	inc a;								// lowet 8 KiB
	out (mmu), a;						// set it
	call wipe_8;						// wipe it
	ld a, %10000000;					// ex bank
	out (scld), a;						// set it
	call wipe_8;						// wipe it
	xor a;								// page out all shadow RAM
	out (mmu), a;						// set it
	ret;								// done

wipe_8:
	ld hl, 0;							// source
	ld (hl), 0;							// clear it
	ld de, 1;							// destination
	ld bc, 8191;						// 8KiB less one byte
	ldir;								// block copy
	ret;								// done

	org $2700
	ld hl, os;							// os
	ld de, $c000;						// top 16K of RAM
	ld bc, 4096;						// 4K to copy
	ldir;								// copy it
	ret;								// done (back to MMC ROM)

 	org $2800;
os:
;import_bin "unodos.sys"

;	// code page 437 font
	org $3800;
font:
	import_bin "../codepages/0437-ibm.bin"
