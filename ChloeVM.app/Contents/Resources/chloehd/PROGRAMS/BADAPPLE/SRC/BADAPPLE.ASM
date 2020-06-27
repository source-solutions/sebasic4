;	// Movie player for the BAD APPLE 2 tech demo for the ZX-UNO
;	// (C)2018 Miguel Angel Rodriguez Jodar. ZX Projects. ZX-UNO Team.
;	// 
;	// This program is free software: you can redistribute it and/or modify
;	// it under the terms of the GNU General Public License as published by
;	// the Free Software Foundation, either version 3 of the License, or
;	// (at your option) any later version.
;	// 
;	// This program is distributed in the hope that it will be useful, 
;	// but WITHOUT ANY WARRANTY; without even the implied warranty of
;	// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;	// GNU General Public License for more details.
;	// 
;	// You should have received a copy of the GNU General Public License
;	// along with this program.  If not, see <http://www.gnu.org/licenses/>.

;	// Conversion to app format / 60Hz by Source Solutions, Inc.

;	// OS hook codes
	include "UNODOS3.INC"

;	// I/O ports
	uno_reg equ $fc3b;
	uno_dat equ $fd3b;
 	scandbl_ctrl equ 11;

	dma_ctrl equ $a0;					// start/stop DMA
	dma_src equ $a1;					// set DMA source
	dma_dst equ $a2;					// set DMA destination
	dma_pre equ $a3;					// set DMA prescaler
	dma_len equ $a4;					// set DMA length
	dma_stat equ $a6;

	specdrum equ $ffdf;					// DMA destination

;	// constants
	prescaler equ 227;					// prescaler for timed DMA: (ROUND (3500000 / 15350)) - 1
	lbuffer equ 1024;					// DMA buffer length

;	// app entry point
	org $6000

;	// set palette
	ld c, $3b;							// ZXI port
	ld de, $ffbf;						// LD D, $ff; LD E, $bf (ULAplus ports)
	ld b, e;							// register port
	ld a, 7;							// INK 7
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), d;							// bright white
	ld b, e;							// register port
	ld a, 15;							// PAPER 7
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), d;							// bright white

;	// set screen mode
	xor a;								// LD A, 0
	out ($ff), a;						// set low-res screen mode

	jp L8000

	org $8000

L8000:
;	// move stack pointer
	ld sp, $8000;						// grows down from $7fff

;	// swap out shadow RAM
	ld bc, $7ffd;						// paging
	ld a, %00010010;					// bank 2, ROM 1, screen 0
	out (c), a;							// set it

;	// copy shadow RAM to main RAM
	ld hl, $8000;						// source (shadow RAM @ $8000)
	ld de, $c000;						// destination (main RAM @ $8000)
	ld bc, $4000;						// byte count;
	ldir;								// copy it

;	// page out shadow RAM
	xor a;								// LD A, 0;
	out ($f4), a;						// page out all shadow RAM

	nop;								// wait a couple of instructions
	nop;								// to allow paging to settle

;	// original code starts here
	jp Main

;	// IM2 interrupt routine
	org $80ff
	defw NuevaIM2

Main:

;	// setup screens
	di;
	ld a, %00010111;					// bank 7, ROM 1, screen 0
	ld bc, $7ffd;
	out (c), a;

	xor a;
	out (254), a;
	ld hl, 16384;
	ld de, 16385;
	ld bc, 6143;
	ld (hl), 0;
	ldir;
	inc hl;
	inc de;
	ld (hl), 7;							// paper 0, ink 7, bright 0
	ld bc, 767;
	ldir;

	ld hl, 49152;
	ld de, 49153;
	ld bc, 6143;
	ld (hl), 0;
	ldir;
	inc hl;
	inc de;
	ld (hl), 7;							// paper 0, ink 7, bright 0
	ld bc, 767;
	ldir;

	ld a, $80;
	ld i, a;
	im 2;
	xor a;
	ld (FramCont), a;					// signal interrupt every other frame (30 fps)
	ei;

	xor a;
	rst $08;
	defb m_getsetdrv;					// A = current drive

	ld b, fa_read;						// B = open mode
	ld ix, MovieFile;					// HL = pointer to filename (ASCIIZ)
	rst $08;
	defb f_open;

	jp c, Error;						// return if error
	ld (FHandle), a;

;	// setup pointer to sound buffer
	ld hl, SoundBuffer;
	ld (PointerSoundBuffer), hl;
	
;	// setup pointer to current working screen and display screen
	ld hl, 4000h;						// working screen is page 5
	ld (ScreenAddr), hl;
	ld a, %00011111;					// display screen is page 7
	ld (ScreenPage), a;

;	// A movie is a list of frames, one after another, starting with frame 0.
;	// Even numbered frames are processed in page 5. Odd numbered frames in page 7
;	// Each frame begins with 512 bytes of audio, then a 4 byte header which indicates
;	// type of frame, border value and length of frame (minus these 4 bytes), then 
;	// the rest of the frame

	xor a;
	ld r, a;							// reset interrupt signalling
	call ReadAudioFrame;				// fill first half of DMA audio buffer

WaitFirstINT:
	ld a, r;
	jp p, WaitFirstINT;					// wait until 40ms have happened
	call InitDMA;						// start DMA audio play

AnotherFrame:
	ld a, $7f;
	in a, (254);
	bit 0, a;
	jp z, ErrorLec;						// check if SPACE pressed to stop playing

	ld ix, Buffer;
	ld bc, 4;							// read 4 byte header
	call Leer;
	jp c, ErrorLec;
	ld a, (Buffer);						// get frame type

	cp 0;								// KEY_FRAME
	jp nz, NotKey;
	call DoKeyFrame;
	jp AnotherFrame;

NotKey:
	cp 1;								// DELTA_FRAME
	jp nz, NotDelta;
	call DoDeltaFrame;
	jp AnotherFrame;

NotDelta:;								// if not keyframe and not deltaframe, stop playing

ErrorLec:
	ld a, (FHandle);
	rst $08;
	defb f_close;

;	// reset DMA
	ld bc, uno_reg
	ld a, dma_ctrl
	out (c), a
	inc b
	xor a
	out (c), a

;	// do a warm restart on error to restore default settings
Error:
	rst 0;

;	// -------------------------------------------------------------------------

;	// Read BC bytes to memory pointed by IX from current opened file
Leer:
	ld a, (FHandle);
	rst $08;
	defb f_read;
	ret;

DoKeyFrame:
	xor a;
	ld r, a;							// reset frame interrupt
	ld bc, (Buffer + 2);				// set frame length from header
	ld ix, (ScreenAddr);				// and frame destination (working screen)
	call Leer;							// read it from file direct to working screen
	jp c, ErrorLec;
	jp SwitchScreens;					// go flipping

DoDeltaFrame:
	xor a;								// reset frame interrupt
	ld r, a;
	ld bc, (Buffer + 2);				// set compressed frame length from header
	ld ix, Buffer + 4;					// set destination to internal buffer
	call Leer;
	jp c, ErrorLec;
	ld hl, Buffer + 4;					// HL to the beginning of the compressed buffer
	ld bc, (Buffer + 2);				// BC to hold the length in bytes of this buffer

NextCell:
	ld a, b;							// BC=0 ?
	or c;
	jp z, SwitchScreens;				// then go flipping
	ld e, (hl);
	inc hl;								// DE = screen address for this character
	ld d, (hl);
	inc hl;								// HL = character definition

	rept 8;								// unrolled loop (works wonders here!)
		ld a, (hl);
		ld (de), a;						// transfer character to screen
		inc hl;
		inc d;
	endm;

	ld a, c;							// substracts 10 from BC
	sub 10;
	ld c, a;
	ld a, b;
	sbc a, 0;
	ld b, a;
	jp NextCell;

NuevaIM2:
	push af;
	ld a, (FramCont);
	or a;
	jp nz, SignalIt;
	inc a;
	jp StoreAndExit;

SignalIt:
	ld a, $80;
	ld r, a;							// set bit 7 of R to signal 40ms interrupt
	xor a
StoreAndExit:
	ld (FramCont), a;
	pop af;

	rept 64;							// this waste of time is needed to avoid interrupt
		nop;							// retriggering because of the CPU working at 28 MHz
	endm;								// but interrupt length is still 32T states (T referred to 3.5 MHz CPU)

	ei;
	ret;

SwitchScreens:
	call ReadAudioFrame;				// keep DMA full!

WaitINT:
	ld a, r
	jp p, WaitINT;						// wait for 40ms mark

;	// switch working and display screens
	ld a, (ScreenAddr + 1);
	xor $80;
	ld (ScreenAddr + 1), a;
	ld a, (ScreenPage);
	xor 8;
	ld (ScreenPage), a;
	ld bc, 7ffdh;
	out (c), a;

;	// just after switching screens, update border colour from the
;	// border value stored in the just uncompressed frame we are
;	// about to display

	ld a, (Buffer + 1);
	out (254), a;
	ret;

;	// Read 512 bytes to the (current) first or second half of the 1024 byte buffer. Switch
;	// halves to have the next one ready for the next read operation. While the DMA is playing
;	// the first half, the software is filling the second half. Once DMA begins to play this
;	// second half, software fills the first half with next audio data. DMA hardware automatically
;	// starts reading again from the start of the buffer when it reaches the end.

ReadAudioFrame:
	ld ix, (PointerSoundBuffer);
	ld bc, 512;
	call Leer;

	ld a, (PointerSoundBuffer + 1);
	cp HIGH(SoundBuffer);
	jp z, Add1024;
	ld hl, SoundBuffer;
	jp EndAudioFrame;

Add1024:
	ld hl, SoundBuffer + 512;

EndAudioFrame:
	ld (PointerSoundBuffer), hl;
	ret;

InitDMA:
	ld hl, SoundBuffer;					// begin of circular play buffer
	ld bc, uno_reg;
	ld a, dma_src;
	out (c), a;
	inc b;
	out (c), l;
	out (c), h;
	dec b;

	ld a, dma_dst;
	out (c), a;
	inc b;
	ld hl, specdrum;
	out (c), l;
	out (c), h;
	dec b;

	ld a, dma_pre;
	out (c), a;
	inc b;
	ld hl, prescaler;
	out (c), l;
	out (c), h;
	dec b;

	ld a, dma_len;
	out (c), a;
	inc b;
	ld hl, lbuffer;
	out (c), l;
	out (c), h;
	dec b;

	ld a, dma_ctrl;
	out (c), a;
	inc b;
	ld a, %00000111;;					// mem to I/O, retriggeable, timed
	out (c), a;
	dec b;

	ret;

MovieFile:
	defb "BA.MVZ", 0;

FHandle:
	defb 0;

FramCont:
	defb 0;

ScreenAddr:
	defw $4000;

ScreenPage:
	defb %00011111;

PointerSoundBuffer:
	defw SoundBuffer;

SoundBuffer	equ $;
Buffer equ $ + lbuffer;
