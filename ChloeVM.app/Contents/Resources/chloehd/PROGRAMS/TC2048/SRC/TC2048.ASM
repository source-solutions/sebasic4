;	// TC48 - A Timex Computer 2048 emulator
;	// Copyright (c) 2019 Source Solutions, Inc.
;	// Copyright (c) 1984 Timex Group B.V.
;	// Copyright (c) 1982 Sky In-Home Service Ltd.

;	// OS hook codes
	include "UNODOS3.INC"

	uno_reg equ $fc3b
	uno_dat equ $fd3b
	scandbl_ctrl equ 11

	org $6000

;	// load ROM file
	ld ix, filename;					// /rsc/48.rom
	ld a, '*';							// use current drive
	ld b, fa_read | fa_open_ex;			// open for reading if file exists
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
	ld (handle), a;						// store file handle
	ld bc, 16384;						// file size
	ld ix, $8000;						// load in fast RAM.
	rst divmmc;							// issue a hookcode
	defb f_read;						// read file
	ld a, (handle);						// restore handle
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file

;	// initial setup
	di;									// interrupts off
	ld bc, $bf3b;						// register select
	ld de, 0;							// destination address
	ld a, $40;							// register 64
	out (c), a;							// select it
	ld b, $ff;							// data port
	out (c), e;							// switch off ULAplus
	ld c, b;							// LD C, $FF
	out (c), e;							// Spectrum screen mode, DOCK
	ld bc, $7ffd;						// 128 paging
	out (c), e;							// ROM-0, VRAM-0, HOME-0
	ld c, e;							// byte count
	ld b, a;							// to 16384
	ld a, %00111111;					// lower 48K to be shadow RAM
	out ($f4), a;						// set it
	ld hl, $8000;						// source
	ldir;								// copy ROM

;	// patch ROM to prevent it overwriting itself
	ld a, $17;							// po_scr_4a
	ld hl, $0d2c;						// used to overwrite
	ld (hl), a;							// the font
	xor a;								// skip_ret
	ld hl, $33fb;						// used to overwrite
	ld (hl), a;							// restart 0

;	// set speed
	ld bc, uno_reg;						// Uno register select
	ld a, scandbl_ctrl;					// scan double and control register
	out (c),a;							// select it
	inc b;								// LD BC, uno_dat
	in a, (c);							// get current value
	or %00111100;						// 3.5 MHz | PAL sync | 60Hz | user scanlines | user scandouble
	out (c),a;							// set it
	ld bc, $8e3b;						// Prism port
	ld a, %00000000;					// 3.5 MHz
	out (c), a;							// set it


;	// change to `roms` folder
	ld a, '*';							// use current drive
	ld ix, path;						// pointer to path
	rst divmmc;							// issue a hookcode
	defb f_chdir;						// change folder
	jp shadow_ram;						// switch off shadow RAM

filename:
	defb "tc2048.rom", 0;				// ROM file in resource folder

handle:
	defb 0

path:
	defb "/PROGRAMS/TC2048/RSC/ROMS/", 0;

;	// skip middle 32K of shadow RAM that will be paged out
	org $c000
shadow_ram:
	ld a, %00000011;					// lower 16K to be shadow RAM
	out ($f4), a;						// set it

;	// start the emulator
	jp 1;								// skip over divMMC trap