;	// TC48 - A Timex Computer 2048 emulator
;	// Copyright (c) 2019 Source Solutions, Inc.
;	// Copyright (c) 1984 Timex Group B.V.
;	// Copyright (c) 1982 Sky In-Home Service Ltd.

;	// OS hook codes
	include "UNODOS3.INC"

	uno_reg equ $fc3b
	uno_dat equ $fd3b
 
	uno_conf equ 0
	uno_mapper equ 1
	flash_spi equ 2
	flash_cs equ 3
	scan_code equ 4
	key_stat equ 5
	joy_conf equ 6
	key_map equ 7
	nmi_event equ 8
	mouse_data equ 9
	mouse_status equ 10
	scandbl_ctrl equ 11
	raster_line equ 12
	raster_ctrl equ 13
	dev_control equ 14
	dev_ctrl2 equ 15

	ad724 equ $fb;						// AD724 video encoder 

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

;	// set speed for Prism
	ld bc, $8e3b;						// Prism port
	ld a, %00000000;					// 3.5 MHz
	out (c), a;							// set it

;	// configure hardware
	ld bc, uno_reg;						// Uno register port
	xor a;								// master config
	out (c), a;							// set register
	inc b;								// Uno data port
	ld a, %00000010;					// bit 0 - 0: don't use boot mode (cannot access all RAM)
;										//     1 - 1: enable divMMC
;										//     2 - 0: enable divMMC NMI
;										//     3 - 0: Port #FE behaves as issue 3
;										//     4 - 0: 312 scanlines per frame (PAL)
;										//     5 - 0: Enable video contention
;										//     6 - 0: 312 scanlines per frame (PAL)
;										//     7 - 0: unlock SPI (necessary to switch to boot mode)
	out (c), a;							// write data

;	// set speed
;	ld bc, uno_reg;						// Uno register select
	dec b;								// Uno register select
	ld a, scandbl_ctrl;					// scan double and control register
	out (c),a;							// select it
	inc b;								// LD BC, uno_dat
	in a, (c);							// get current value
	and %00000011;						// 3.5 MHz | TC sync | 50Hz | user scanlines | user scandouble
	out (c),a;							// set it

;	// set PAL output
;	ld bc, uno_reg;						// Uno register select
	dec b;
	ld a, ad724;						// video register
	out (c),a;							// select it
	inc b;								// LD BC, uno_dat
	in a, (c);							// get value;
	and %11111110;						// set PAL
	out (c), a;							// set it

;	// device setup
;	ld bc, uno_reg;						// Uno register select
	dec b;								// Uno register select
	ld a, dev_control;					// device control register
	out (c),a;							// select it
	inc b;								// LD BC, uno_dat
	ld a, %01101000;					// SPI enabled     | MMU enabled     | $1FFD b2 mask 1 | $7FFD b4 mask 0
;										// $1FFD disabled  | $7FFD enabled   | YM2 enabled     | YM1 enabled
	out (c), a;							// set it

;	ld bc, uno_reg;						// Uno register select
	dec b;
	ld a, dev_ctrl2;					// device control register 2
	out (c),a;							// select it
	inc b;								// LD BC, uno_dat
	ld a, %00000000;					// 00000 | Radastan video enabled | Timex video enabled | ULAplus enabled 
	out (c), a;							// set it

;	// set pan
	ld a, %10011111;					// ACB stereo
	out ($f7), a;						// set it

;	// change to `SNAPS` folder
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
	defb "/PROGRAMS/TC2048/RSC/SNAPS/", 0;

;	// skip middle 32K of shadow RAM that will be paged out
	org $c000
shadow_ram:
	ld a, %00000011;					// lower 16K to be shadow RAM
	out ($f4), a;						// set it

;	// start the emulator
	jp 1;								// skip over divMMC trap