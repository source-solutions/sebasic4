;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2020 Source Solutions, Inc.

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
	include "uno.inc";					// label definitions
	include "os.inc";					// label definitions

;	// restarts
	divmmc equ $08
	wreg equ $20

;	// IO ports
	mmu equ	$f4
	ula equ $fe
	scld equ $ff
	paging equ $7ffd

;	// control codes
	ctrl_cr			equ $0d;
	ctrl_lf			equ $0a;

	org $0000;
	di;									// interrupts off
	rst $18;							// quick jump if DOS has been patched to enable ROM0

	org $0007;
	rst $18;							// quick jump avoids triggering error detect

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

;	// write to SPI flash
	org $0020;
wreg:
	ld bc, uno_reg + $100;				// $fd3b. Will be decremented to $fc before the OUT by OUTI.
	pop hl;								// drop return address.
	outi;								// DEC B; OUT [BC], (HL); INC HL.
	ld b, (uno_reg >> 8) + 2;			// $fe. Will be decremented to $fd before the OUT by OUTI.
	outi;								// DEC B; OUT [BC], (HL); INC HL.
	jp (hl);							// jump to address after second parameter.

	org $0030;
;	// ASCII art, just for fun
ascii:
	defb "||2 |||8 |||0 ||"
	defb "||__|||__|||__||"
	defb $7c, $2f, $5f, $5f, $5c, $7c, $2f, $5f, $5f, $5c, $7c, $2f, $5f, $5f, $5c, $7c

	org $0066;
	ret;								// trapped address

;	// the mute PSG code is a copy of the routin from BASIC module 04
	org $0067;
mute_psg:
	ld hl, $fe07;						// H = AY-0, L = Volume register (7)
	ld de, $bfff;						// D = data port, E = register port / mute
	ld c, $fd;							// low byte of AY port
	call mute_ay;						// mute AY-0
	inc h;								// AY-1

mute_ay:
	ld b, e;							// AY register port
	out (c), h;							// select AY (255/254)
	out (c), l;							// select register
	ld b, d;							// AY data port
	out (c), e;							// AY off;
	ret;								// end of subroutine

;	// start bootstrap
init:
	xor a;								// LD A, 0
	out (ula), a;						// black border
	ld hl, 23295;						// source
	ld de, 23294;						// destination
	ld bc, 767;							// byte count
	ld (hl), a;							// set first value to zero
	lddr;								// zero attributes (22528 to 23295) in reverse to avoid tearing
	out ($ff), a;						// set low res screen

	ld sp, $5f00;						// set stack pointer for update

	call mute_psg;						// mute AY-1

;	// copy update code to RAM and call it
	ld hl, fwupdate;					// firmware update routine
	ld de, $5f00;						// destination
	ld bc, updatefw - fwupdate;			// length
	ldir;								// copy routine to RAM
	call $5f00;							// call it (returns if no firmware update present)

	ld sp, $8000;						// set stack pointer to top of HOME page 5

;	// RAM clearing routines
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

;	// map in 32K of sideways RAM where available
	ld a, %00111100;					// page shadow RAM over
	out (mmu), a;						// the middle 32K

;	// copy second part of ROM to correct place
;	// (basic goes up to $5bb9, sysvars start at $5bba)
	ld hl, basic;
	ld de, $4000;
	ld bc, 7098;
	ldir;

	jp config;							// handle CONFIG.SYS file

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

;	// firware update RAM code
fwupdate:
	ld bc, uno_reg;						// Uno register select
	ld a, scandbl_ctrl;					// scan double and control register
	out (c),a;							// select it
	inc b;								// LD BC, uno_dat
	in a, (c);							// get current value
	and %00111111;						// 3.5MHz mode
	out (c),a;							// set it

	ld bc, paging;						// HOME bank paging
	ld a, %00010000;					// ROM 1, VID 0, RAM 0
	out (c), a;							// swap

	handle_t equ $4000;					// any byte of RAM < $5e00 will do

;	// load update file if present
	ld ix, (update_fn-fwupdate)+$5f00;	// filename (LD IX, update_fn)
	ld a, '*';							// use current drive
	ld b, fa_read | fa_open_ex;			// open for reading if file exists
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
	jr c, no_fw;						// return if no update file found
	ld (handle_t), a;					// store file handle
	ld bc, 40962;						// file size
	ld ix, $5ffe;						// load at 24318
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_read;						// read file
	jr c, no_fw;						// return if wrong file length
	ld a, (handle_t);					// restore handle
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
	jr c, no_fw;						// return if file close failed

;	// delete file after loading
	ld a, '*';							// use current drive
	ld ix, (update_fn-fwupdate)+$5f00;	// pointer to path (LD IX, update_fn)
	rst divmmc;							// issue a hookcode
	defb f_unlink;						// delete file

;	// verify delete
;	ld ix, (update_fn-fwupdate)+$5f00;	// filename (LD IX, update_fn)
;	ld a, '*';							// use current drive
;	ld b, fa_read | fa_open_ex;			// open for reading if file exists
;	rst divmmc;							// issue a hookcode
;	defb f_open;						// open file
;	jr nc, power_off;					// jump if file was not deleted

;	// return to ROM
	call (no_fw-fwupdate)+$5f00;		// switch to ROM 0 (CALL no_fw)
	jp updatefw;						// continue in ROM

no_fw:
	ld bc, paging;						// HOME bank paging
	xor a;								// ROM 0, VID 0, RAM 0
	out (c), a;							// swap
	ret;								// return

update_fn:
	defb "FIRMWA~1.BIN", 0;				// short filename for "Firmware Update YYYYMMDD"

;;   // draw power logo (same logo code as in OS)
;power_off:
;	ld hl, image;						// start of data
;	ld a, 18;							// line count
;
;gfx_loop:
;	ld e, (hl);							// get low byte of screen address to D
;	inc hl;								// point to next byte
;	ld d, (hl);							// get high byte of screen address to E
;	inc hl;								// point to data
;	ld bc, 4;							// 4 bytes to write
;	ldir;								// copy (HL) to (DE) then INC HL; INC DE
;	dec a;								// reduce count
;	jr nz, gfx_loop;					// loop until done
;
;attributes:
;	ld hl, 22862;						// 
;	ld de, 28;							// 
;	ld b, 4;							// 
;
;outer_loop:
;	ld a, 4;							// 
;
;inner_loop:
;	ld (hl), %01000111;					// bright white
;	inc hl;								// 
;	dec a;								// 
;	jr nz, inner_loop;					// do four cells
;	add hl, de;							// 
;	djnz outer_loop;					// do four rows
;
;power_loop:
;	jr power_loop;						// wait for power off
;
;;   // power logo
;image:
;	defw 20302;
;	defb %00000000, %00000001, %10000000, %00000000;
;	defw 18542;
;	defb %00000000, %00000001, %10000000, %00000000;
;	defw 18798;
;	defb %00000000, %00001101, %10110000, %00000000;
;	defw 19054;
;	defb %00000000, %00011101, %10111000, %00000000;
;	defw 19310;
;	defb %00000000, %00111101, %10111100, %00000000;
;	defw 19566;
;	defb %00000000, %01111001, %10011110, %00000000;
;	defw 19822;
;	defb %00000000, %01110001, %10001110, %00000000;
;	defw 20078;
;	defb %00000000, %11100001, %10000111, %00000000;
;	defw 20334;
;	defb %00000000, %11100001, %10000111, %00000000;
;	defw 18574;
;	defb %00000000, %11100001, %10000111, %00000000;
;	defw 18830;
;	defb %00000000, %11100000, %00000111, %00000000;
;	defw 19086;
;	defb %00000000, %01110000, %00001110, %00000000;
;	defw 19342;
;	defb %00000000, %01111000, %00011110, %00000000;
;	defw 19598;
;	defb %00000000, %00111100, %00111100, %00000000;
;	defw 19854;
;	defb %00000000, %00011111, %11111000, %00000000;
;	defw 20110;
;	defb %00000000, %00001111, %11110000, %00000000;
;	defw 20366;
;	defb %00000000, %00000011, %11000000, %00000000;
;	defw 18606;
;	defb %00000000, %00000000, %00000000, %00000000;

	osrom equ $5ffe
	basicrom equ $7ffe

updatefw:
	ld bc, uno_reg;						// #fc3b
	xor a;
	out (c), 0;							// defb $ed, $71
	inc b;
	in f, (c);							// defb $ed, $70
	jp p, chk_string;
	ret;								// return if lock mode is set

chk_string:
	ld a, (49193);						// offset $002b in BASIC ROM
	cp 'S';								// is it an 'S'?
	ret nz;								// return if character check failed
	ld a, (49194);						// offset $002c in BASIC ROM
	cp 'E';								// is it an 'E'?
	ret nz;								// return if character check failed
	
xor_checksum:
	xor a;								// LD A, 0
	ld bc, 40960;						// byte count (40K)
	ld hl, $5ffe;						// source address
	
xor_loop:
	xor (hl);							// xor (HL) with A
	inc hl;								// next address
	dec bc;								// reduce count
	ex af, af';							// store A
	ld a, c ;							// test for
	or b;								// zero
	jr z, xor_done;						// jump if done
	ex af, af';							// else restore A
	jr xor_loop;						// and loop
	
xor_done:
	ex af, af';							// restore A
	cp (hl);							// compare with xor checksum byte (Sfffe)
	ret nz;								// return if checksum failed

add_checksum:
	xor a;								// LD A, 0
	ld bc, 40960;						// byte count (40K)
	ld hl, $5ffe;						// source address
	
add_loop:
	add a, (hl);						// add (HL) to A
	inc hl;								// next address
	dec bc;								// reduce count
	ex af, af';							// store A
	ld a, c ;							// test for
	or b;								// zero
	jr z, add_done;						// jump if done
	ex af, af';							// else restore A
	jr add_loop;						// and loop
	
add_done:
	ex af, af';							// restore A
	inc hl;								// next address
	cp (hl);							// compare with xor checksum byte ($ffff)
	ret nz;								// return if checksum faild

upgrade_os:
	ld a, 32;							// 256 byte pages to write (8K)
	exx;								// change register set
	ld hl, osrom;						// HL' = source address
	exx;								// change register set
	ld de, $0040;						// destination ($004000)
	call wrflsh;						// write to SPI flash

upgrade_basic:
	ld a, 128;							// 256 byte pages to write (32K)
	exx;								// change register set
	ld hl, basicrom;					// HL' = source address
	exx;								// change register set
	ld de, $0100;						// destination ($010000) - ROM slot 1&2
	call wrflsh;						// write to SPI flash

cold_reset:
	ld bc, uno_reg;						// Uno register select
	ld a, $fd;							// coreboot register
	out (c), a;							// set it
	ld a, 1;							// prepare for cold boot
	inc b;								// Uno data port
	out (c), a;							// cold boot

emu_loop:
;	jp power_off;						// for emulators that don't implement cold boot
	jr emu_loop;

;	// Write to SPI flash
;	// A: number of pages (256 bytes) to write
;	// DE: top two bytes of 24-bit address
;	// HL': source address from memory
wrflsh:
	ex af, af';
	xor a;

wrfls1:
	rst wreg;
	defb flash_cs, 0;					// SPI control, activate
	rst wreg;
	defb flash_spi, 6;					// access SPI, write enable
	rst wreg;
	defb flash_cs, 1;					// SPI control, deactivate
	rst wreg;
	defb flash_cs, 0;					// SPI control, activate
	rst wreg;
	defb flash_spi, $20;				// access SPI, sector erase
	out (c), d;
	out (c), e;
	out (c), a;
	rst wreg;
	defb flash_cs, 1;					// SPI control, deactivate

wrfls2:
	call waits5;						// timing control
	rst wreg;
	defb flash_cs, 0;					// SPI control, activate
	rst wreg;
	defb flash_spi, 6;					// access SPI, write enable
	rst wreg;
	defb flash_cs, 1;					// SPI control, deactivate
	rst wreg;
	defb flash_cs, 0;					// SPI control, activate
	rst wreg;
	defb flash_spi, 2;					// access SPI, program page
	out (c), d;
	out (c), e;
	out (c), a;
	ld a, $20;
	exx;
	ld bc, uno_dat;						// select Uno data register

wrfls3:
	inc b;
	outi;
	inc b;
	outi;
	inc b;
	outi;
	inc b;
	outi;
	inc b;
	outi;
	inc b;
	outi;
	inc b;
	outi;
	inc b;
	outi;
	dec a;
	jr nz, wrfls3;
	exx;
	rst wreg
	defb flash_cs, 1;					// SPI control, deactivate
	ex af, af';
	dec a;
	jr z, waits5;
	ex af, af';
	inc e;
	ld a, e;
	and $0f;
	jr nz, wrfls2;
	ld hl, wrfls1;
	push hl;

waits5:
	rst wreg
	defb flash_cs, 0;					// SPI control, activate
	rst wreg
	defb flash_spi, 5;					// access SPI, send read status
	in a, (c);

waits6:
	in a, (c);
	and 1;
	jr nz, waits6;
	rst wreg;
	defb flash_cs, 1;					// SPI control, deactivate
	ret;

;	// part two of BASIC
	org $0400
basic:
	import_bin "basic.bin"

	defb "The supreme art of war is to subdue the enemy without fighting-Sun Tzu"

;	// wipe lower 8KiB of shadow RAM
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

;	// CONFIG.SYS RAM code
	handle_c equ $c000
	cf_stats equ $c001
	cf_size equ $c008
	cf_file equ $c400

config:
	ld bc, paging;						// HOME bank paging
	ld a, %00000111;					// ROM 0, VID 0, RAM 7
	out (c), a;							// swap

	ld sp, $c100;						// create a 256 byte stack in the frame buffer

;	// copy config file code to RAM and call it
	ld hl, cf_ram;						// config.sys load routine
	ld de, $c100;						// destination
	ld bc, cf_end - cf_ram;				// length
	ldir;								// copy routine to RAM
	call $c100;							// call it

;	// wipe RAM used by CONFIG.SYS
	xor a;								// LD A, 0
	ld hl, $c000;						// source
	ld (hl), a;							// set source to zero
	ld de, $c001;						// destination
	ld bc, 8127;						// bytes to start of palette file in framebuffer
	ldir;								// clear it

;	// lock SPI
;	ld bc, uno_reg;						// Uno register port
;	xor a;								// master config
;	out (c), a;							// set register
;	inc b;								// Uno data port
;	ld a, %10000010;					// enable lock (bit 1 keeps MMC enabled)
;	out (c), a;							// write data

;	// configure hardware
	ld bc, uno_reg;						// Uno register port
	xor a;								// master config
	out (c), a;							// set register
	inc b;								// Uno data port
	ld a, %01100110;					// bit 0 - 0: don't use boot mode (cannot access all RAM)
;										//     1 - 1: enable divMMC
;										//     2 - 1: disblae divMMC NMI
;										//     3 - 0: Port #FE behaves as issue 3
;										//     4 - 0: Pentagon timing
;										//     5 - 1: Disable video contention
;										//     6 - 1: Pentagon timing
;										//     7 - 0: unlock SPI (necessary to switch to boot mode)
	out (c), a;							// write data

;	// set speed
	ld bc, uno_reg;						// Uno register select
	ld a, scandbl_ctrl;					// scan double and control register
	out (c),a;							// select it
	inc b;								// LD BC, uno_dat
	in a, (c);							// get current value
	or %11000000;						// 28MHz mode
	out (c),a;							// set it

;	// switch ROMs
	jp to_rom1;							// start BASIC

cf_ram:
	ld bc, paging;						// HOME bank paging
	ld a, %00010111;					// ROM 1, VID 0, RAM 7
	out (c), a;							// swap

cf_open:
	ld ix, (cf_path-cf_ram)+$c100;		// path to config.sys file (cf_path)
;	ld a, '*';							// use current drive
;	ld b, fa_read | fa_open_ex;			// open for reading if file exists
;	and a;								// signal no error (clear carry flag)
;	rst divmmc;							// issue a hookcode
;	defb f_open;						// open file
	call (open_ex-cf_ram)+$c100;		// open file if it exits

	jr c, cf_exit;						// return if error
	ld (handle_c), a;					// store handle

cf_length:
	ld ix, cf_stats;					// buffer for file stats
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_fstat;						// get file stats
	jr c, cf_exit;						// return if error
	ld hl, cf_file;						// start of file in memory
	ld bc, (cf_size);					// file length
	add hl, bc;							// one byte after file
	xor a;								// LD A, 0
	ld (hl), a;							// add a null byte after the file end

cf_load:
	ld a, (handle_c);					// file handle
	ld ix, cf_file;						// file destination
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_read;						// 
	jr c, cf_exit;						// return if error
	ld a, (handle_c);					// 
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_close;						// 
	call nc, (cf_parse-cf_ram)+$c100;	// if no errors, parse file

cf_exit:
	ld a, %00000111;					// ROM 0, VID 0, RAM 7
	ld bc, paging;						// HOME bank paging
	out (c), a;							// swap
	ret;								// return (with carry set if error)

cf_parse:
	ld de, (cp_def-cf_ram)+$c100;		// string to match (LD DE, cp_def)
	call (match_string-cf_ram)+$c100;	// test for it (CALL match_string)
	ld de, (cp_file-cf_ram)+$c100;		// point to filename buffer (LD DE, cp_file)
	call z, (cp_found-cf_ram)+$c100;	// call with match (CALL cp_found)

	ld de, (kb_def-cf_ram)+$c100;		// string to match (LD DE, kb_def)
	call (match_string-cf_ram)+$c100;	// test for it (CALL match_string)
	ld de, (kb_file-cf_ram)+$c100;		// point to filename buffer (LD DE, kb_file)
	call z, (kb_found-cf_ram)+$c100;	// call with match (CALL kb_found)

	ld de, (ln_def-cf_ram)+$c100;		// string to match (LD DE, ln_def)
	call (match_string-cf_ram)+$c100;	// test for it (CALL match_string)
	ld de, (ln_file-cf_ram)+$c100;		// point to filename buffer (LD DE, ln_file)
	call z, (ln_found-cf_ram)+$c100;	// call with match (CALL ln_found)

	ret;			                	// done

cp_found:
	ld a, (hl);		                 	// get character

	cp ctrl_cr;		                  	// test for CR
	jr z, cp_end;	                	// jump if so
	cp ctrl_lf;		                  	// test for LF
	jr z, cp_end;	                	// jump if so

	ld (de), a;							// write character
	inc hl;								// next character source
	inc de;								// next character destination
	jr cp_found;	              		// loop until done

cp_end:
	ld hl, (cp_ext-cf_ram)+$c100;		// file extension (LD HL, cp_ext)
	ld bc, 4;							// four bytes to copy
	ldir;								// DE already points to destination so copy it

cp_load:
	ld ix, (cp_path-cf_ram)+$c100;		// path to code page file (cp_path)
;	ld a, '*';							// use current drive
;	ld b, fa_read | fa_open_ex;			// open for reading if file exists
;	and a;								// signal no error (clear carry flag)
;	rst divmmc;							// issue a hookcode
;	defb f_open;						// open file
	call (open_ex-cf_ram)+$c100;		// open file if it exits

	ret c;								// return if error
	ld ix, $f800;						// file destination
	ld bc, $0800;						// 2K of data to load

any_load:
	ld (handle_c), a;					// store handle
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_read;						// 
	ret c;								// return if error
	ld a, (handle_c);					// 
	rst divmmc;							// issue a hookcode
	defb f_close;						// 
	ret;								// end of subroutine

kb_found:
	ld a, (hl);		                 	// get character
	cp ctrl_cr;		                  	// test for CR
	jr z, kb_end;	                	// jump if so
	cp ctrl_lf;		                  	// test for LF
	jr z, kb_end;	                	// jump if so

	ld (de), a;							// write character
	inc hl;								// next character source
	inc de;								// next character destination
	jr kb_found;	              		// loop until done

kb_end:
	ld hl, (kb_ext-cf_ram)+$c100;		// file extension (LD HL, kb_ext)
	ld bc, 4;							// four bytes to copy
	ldir;								// DE already points to destination so copy it

kb_load:
	ld ix, (kb_path-cf_ram)+$c100;		// path to keyboard file (kb_path)
;	ld a, '*';							// use current drive
;	ld b, fa_read | fa_open_ex;			// open for reading if file exists
;	and a;								// signal no error (clear carry flag)
;	rst divmmc;							// issue a hookcode
;	defb f_open;						// open file
	call (open_ex-cf_ram)+$c100;		// open file if it exits

	ret c;								// return if error
	ld ix, $4240;						// file destination
	ld bc, 85;							// 85 bytes of data to load
	jr any_load;						// continue to common code

ln_found:
	ld a, (hl);		                 	// get character
	cp ctrl_cr;			               	// test for CR
	jr z, ln_end;	                	// jump if so
	cp ctrl_lf;		                  	// test for LF
	jr z, ln_end;	                	// jump if so

	ld (de), a;							// write character
	inc hl;								// next character source
	inc de;								// next character destination
	jr ln_found;	              		// loop until done

ln_end:
	ld hl, (ln_ext-cf_ram)+$c100;		// file extension (LD HL, ln_ext)
	ld bc, 4;							// four bytes to copy
	ldir;								// DE already points to destination so copy it

ln_load:
	ld ix, (ln_path-cf_ram)+$c100;		// path to language file (ln_path)
;	ld a, '*';							// use current drive
;	ld b, fa_read | fa_open_ex;			// open for reading if file exists
;	and a;								// signal no error (clear carry flag)
;	rst divmmc;							// issue a hookcode
;	defb f_open;						// open file
	call (open_ex-cf_ram)+$c100;		// open file if it exits

	ret c;								// return if error
	ld ix, $4000;						// file destination
	ld bc, 576;							// 576 bytes of data to load
	jr any_load;						// continue to common code

;   // open a file if it exists (called four times)
open_ex;
	ld a, '*';							// use current drive
	ld b, fa_read | fa_open_ex;			// open for reading if file exists
	and a;								// signal no error (clear carry flag)
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
    ret;                                // back for error checking

match_string:
	ld hl, cf_file;	     	         	// first character of file

ms_loop:
	ld a, (de);		                  	// get character
	and a;		                   		// test for zero
	ret z;		                   		// return with match
	cp (hl);		                   	// compare character
	jr nz, no_match;            		// jump with no match
	inc de;			                	// next character in string 
	inc hl;		            		    // next character in file
	jr ms_loop;	            		    // loop until match

no_match:
	inc hl;			            	    // next character in file
	ld a, (hl);		                 	// get character from file
	and a;			                 	// test for zero
	jr z, eof;		                  	// end of file found
	cp ctrl_cr;		                  	// test for CR (newline)
	jr z, newline;	              		// jump if so
	cp ctrl_lf;		                  	// test for LF (UNIX newline)
	jr z, newline;	              		// jump if so

	jr nz, no_match;	              	// jump if not
	inc hl;			                   	// next character in file
	jr ms_loop;		                	// and check next line

newline:	
	inc hl;			                   	// next character in file
	ld a, (hl);		                   	// get character
	cp ctrl_lf;							// test for LF (Windows newline)
	jr nz, ms_loop;	        	    	// to check next line if not
	inc hl;			                  	// else skip LF
	jr ms_loop;		                	// and check next line

eof:
	xor a;			                 	// reset
	inc a;								// zero flag (not zero)
	ret;			                	// return

cf_path:
	defb "/SYSTEM/CONFIG.SYS", 0;		// null terminated path to config.sys file

cp_path:
	defb "/SYSTEM/FONTS/";				// path for language files

cp_file:
	defb "FILENAME";					// filename

cp_ext:
	defb ".CP", 0;						// extension and null terminator

kb_path:
	defb "/SYSTEM/KEYBOARD.S/";			// path for language files (dot required for emulator only)

kb_file:
	defb "FILENAME";					// filename

kb_ext:
	defb ".KB", 0;						// extension and null terminator

ln_path:
	defb "/SYSTEM/LANGUAGE.S/";			// path for language files (dot required for emulator only)

ln_file:
	defb "FILENAME";					// filename

ln_ext:
	defb ".LN", 0;						// extension and null terminator

cp_def:
	defb "cp=", 0;	           	    	// codepage

kb_def:
	defb "kb=", 0;		            	// keyboard definition

ln_def:
	defb "ln=", 0;		               	// error messages

cf_end:

;	// code page 437 font
	org $2a00
font:
	import_bin "0437-IBM.CP"

;	// entry point from OS ROM
	org $3200
	ld hl, os;							// os
	ld de, $c000;						// top 16K of RAM
	ld bc, 3556;						// 3556 bytes to copy
	ldir;								// copy it
	ret;								// done (back to MMC ROM)

os:
;	import_bin "../bin/unodos-0.sys"
;	import_bin "../bin/unodos-1.sys"
	import_bin "../bin/unodos.sys"

os_end:
	defb "Source Solutions";
