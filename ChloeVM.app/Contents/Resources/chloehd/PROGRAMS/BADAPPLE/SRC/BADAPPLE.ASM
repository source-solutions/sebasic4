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

ZXUNOADDR           equ 64571  ; ZX-UNO ZXI register address
ZXUNODATA           equ 64827  ; ZX-UNO ZXI register data
SCANDBLR            equ 0bh    ; ZX-UNO register to set Z80 speed (we will use 28 MHz here)
DMACTRL             equ 0a0h   ; ZX-UNO register to start/stop DMA
DMASRC              equ 0a1h   ; ZX-UNO register to set DMA source
DMADST              equ 0a2h   ; ZX-UNO register to set DMA destination
DMAPRE              equ 0a3h   ; ZX-UNO register to set DMA preescaler
DMALEN              equ 0a4h   ; ZX-UNO register to set DMA length
DMASTAT             equ 0a6h
SPECDRUM            equ 0ffdfh ; Specdrum I/O port in 16-bit format for DMA destination
PREESCALER          equ 227    ; Preescaler for timed DMA. This number is got this way ( ROUND (3500000 / 15350) ) - 1
LBUFFER             equ 1024   ; DMA buffer length

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

                    org 8000h
L8000:
;	// move stack pointer
	ld sp, $8000

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

                    org 80FFh
                    dw NuevaIM2

Main:               ;Check whether we are using a PAL mode (50 fps) and reject if in NTSC mode.
;                     ld bc,ZXUNOADDR
;                     xor a
;                     out (c),a
;                     inc b
;                     in a,(c)
;                     and 01010000b
;                     cp  01010000b
;                     jr nz,PALMode
;                     ld a,2
;                     call 1601h
;                     ld hl,MenError
; BucMenError         ld a,(hl)
;                     or a
;                     ret z
;                     rst 10h
;                     inc hl
;                     jr BucMenError
; MenError            db "Sorry, I need PAL timings.",0

;	// Chloe uses NTSC mode
; PALMode             ;Keep current mode and force 48K ULA timings for this demo
;                    in a,(c)
;                    ; ld (Mode),a
;                    and 10101111b
;                    out (c),a

;	// Chloe is already running at 28MHz
                    ; ;Keep current speed settings and force 28 MHz for this demo
                    ; dec b
                    ; ld a,SCANDBLR
                    ; out (c),a
                    ; inc b
                    ; in a,(c)
                    ; ld (ScanDblr),a
                    ; or 0c0h
                    ; out (c),a

                    ;setup screens
                    di
                    ld a,00010111b  ;bank 7, ROM 1, screen 0
                    ld bc,7ffdh
                    out (c),a

                    xor a
                    out (254),a
                    ld hl,16384
                    ld de,16385
                    ld bc,6143
                    ld (hl),0
                    ldir
                    inc hl
                    inc de
                    ld (hl),7       ;paper 0, ink 7, bright 0
                    ld bc,767
                    ldir

                    ld hl,49152
                    ld de,49153
                    ld bc,6143
                    ld (hl),0
                    ldir
                    inc hl
                    inc de
                    ld (hl),7       ;paper 0, ink 7, bright 0
                    ld bc,767
                    ldir

                    ld a,80h
                    ld i,a
                    im 2
                    xor a
                    ld (FramCont),a  ;signal interrupt every other frame (30 fps)
                    ei

                    xor a
                    rst 08h
                    db m_getsetdrv  ;A = current drive

                    ld b,fa_read    ;B = open mode
                    ld ix,MovieFile   ;HL = pointer to filename (ASCIIZ)
                    rst 08h
                    db f_open

                    jp c,Error   ;return if error
                    ld (FHandle),a

                    ;setup pointer to sound buffer
                    ld hl,SoundBuffer
                    ld (PointerSoundBuffer),hl
                    
                    ;setup pointer to current working screen and display screen
                    ld hl,4000h       ;working screen is page 5
                    ld (ScreenAddr),hl
                    ld a,00011111b    ;display screen is page 7
                    ld (ScreenPage),a

                    ; A movie is a list of frames, one after another, starting with frame 0.
                    ; Even numbered frames are processed in page 5. Odd numbered frames in page 7
                    ; Each frame begins with 512 bytes of audio, then a 4 byte header which indicates
                    ; type of frame, border value and length of frame (minus these 4 bytes), then 
                    ; the rest of the frame
                    xor a
                    ld r,a  ;reset interrupt signalling
                    call ReadAudioFrame   ;fill first half of DMA audio buffer
WaitFirstINT:       ld a,r
                    jp p,WaitFirstINT  ;wait until 40ms have happened
                    call InitDMA       ;start DMA audio play

AnotherFrame:       ld a,7fh
                    in a,(254)
                    bit 0,a
                    jp z,ErrorLec    ;check if SPACE pressed to stop playing

                    ld ix,Buffer
                    ld bc,4          ;read 4 byte header
                    call Leer
                    jp c,ErrorLec
                    ld a,(Buffer)    ;get frame type

                    cp 0   ;KEY_FRAME
                    jp nz,NotKey
                    call DoKeyFrame
                    jp AnotherFrame

NotKey:             cp 1   ;DELTA_FRAME
                    jp nz,NotDelta
                    call DoDeltaFrame
                    jp AnotherFrame

NotDelta:           ;if not keyframe and not deltaframe, stop playing

ErrorLec:           ld a,(FHandle)
                    rst 08h
                    db f_close

;	// this won't work in SE BASIC, so just reset the machine.
                    ;Restore machine to its previous settings
                    ld bc,ZXUNOADDR
                    ld a,DMACTRL
                    out (c),a
                    inc b
                    xor a
                    out (c),a
;                    dec b
                    ; ld a,SCANDBLR
                    ; out (c),a
                    ; inc b
                    ; ld a,(ScanDblr)
                    ; out (c),a
                    ; dec b
                    ; xor a
                    ; out (c),a
                    ; ld a,(Mode)
                    ; inc b
                    ; out (c),a

Error:              ;Restore interrupt mode and memory settings
;                    im 1
;                    ld a,00010000b
;                    ld bc,7ffdh
;                    out (c),a
;                    ret  ; RETURN to BASIC
;	ld a, %00111100;	// enable access to bank 5 at $4000
;	out ($f4), a;		// set it
					rst 0; warm restart

;-----------------------------------------------------------------------------

;Read BC bytes to memory pointed by IX from current opened file
Leer:               ld a,(FHandle)
                    rst 08h
                    db f_read
                    ret

DoKeyFrame:         xor a
                    ld r,a             ;reset frame interrupt
                    ld bc,(Buffer+2)   ;set frame length from header
                    ld ix,(ScreenAddr) ;and frame destination (working screen)
                    call Leer          ;read it from file direct to working screen
                    jp c,ErrorLec
                    jp SwitchScreens   ;go flipping

DoDeltaFrame:       xor a              ;reset frame interrupt
                    ld r,a
                    ld bc,(Buffer+2)   ;set compressed frame length from header
                    ld ix,Buffer+4     ;set destination to internal buffer
                    call Leer
                    jp c,ErrorLec
                    ld hl,Buffer+4     ;HL to the beginning of the compressed buffer
                    ld bc,(Buffer+2)   ;BC to hold the length in bytes of this buffer
NextCell:           ld a,b             ;BC=0 ?
                    or c
                    jp z,SwitchScreens ;then go flipping
                    ld e,(hl)          ;
                    inc hl             ;DE = screen address for this character
                    ld d,(hl)          ;
                    inc hl             ;HL = character definition
                    rept 8             ;unrolled loop (works wonders here!)
                      ld a,(hl)        ;
                      ld (de),a        ;transfer character to screen
                      inc hl           ;
                      inc d            ;
                    endm               ;
                    ld a,c             ;substracts 10 from BC
                    sub 10             ;
                    ld c,a             ;
                    ld a,b             ;
                    sbc a,0            ;
                    ld b,a             ;
                    jp NextCell

NuevaIM2:           push af
                    ld a,(FramCont)
                    or a
                    jp nz,SignalIt
                    inc a
                    jp StoreAndExit
SignalIt:           ld a,80h
                    ld r,a   ;set bit 7 of R to signal 40ms interrupt
                    xor a
StoreAndExit:       ld (FramCont),a
                    pop af
                    rept 64  ;this waste of time is needed to avoid interrupt
                      nop    ;retriggering because of the CPU working at 28 MHz
                    endm     ;but interrupt length is still 32T states (T referred to 3.5 MHz CPU)
                    ei
                    ret

SwitchScreens:      call ReadAudioFrame  ;keep DMA full!
WaitINT:            ld a,r
                    jp p,WaitINT         ;wait for 40ms mark

                    ;switch working and display screens
                    ld a,(ScreenAddr+1)
                    xor 80h
                    ld (ScreenAddr+1),a
                    ld a,(ScreenPage)
                    xor 8
                    ld (ScreenPage),a
                    ld bc,7ffdh
                    out (c),a
                    ;just after switching screens, update border colour from the
                    ;border value stored in the just uncompressed frame we are
                    ;about to display
                    ld a,(Buffer+1)
                    out (254),a
                    ret

;Read 512 bytes to the (current) first or second half of the 1024 byte buffer. Switch
;halves to have the next one ready for the next read operation. While the DMA is playing
;the first half, the software is filling the second half. Once DMA begins to play this
;second half, software fills the first half with next audio data. DMA hardware automatically
;starts reading again from the start of the buffer when it reaches the end.
ReadAudioFrame      ld ix,(PointerSoundBuffer)
                    ld bc,512
                    call Leer

                    ld a,(PointerSoundBuffer+1)
                    cp HIGH(SoundBuffer)
                    jp z,Add1024
                    ld hl,SoundBuffer
                    jp EndAudioFrame
Add1024:            ld hl,SoundBuffer+512
EndAudioFrame:      ld (PointerSoundBuffer),hl
                    ret

InitDMA:            ld hl,SoundBuffer  ;begin of circular play buffer
                    ld bc,ZXUNOADDR
                    ld a,DMASRC
                    out (c),a
                    inc b
                    out (c),l
                    out (c),h
                    dec b

                    ld a,DMADST
                    out (c),a
                    inc b
                    ld hl,SPECDRUM
                    out (c),l
                    out (c),h
                    dec b

                    ld a,DMAPRE
                    out (c),a
                    inc b
                    ld hl,PREESCALER
                    out (c),l
                    out (c),h
                    dec b

                    ld a,DMALEN
                    out (c),a
                    inc b
                    ld hl,LBUFFER
                    out (c),l
                    out (c),h
                    dec b

                    ld a,DMACTRL
                    out (c),a
                    inc b
                    ld a,00000111b  ;mem to I/O, retriggeable, timed
                    out (c),a
                    dec b

                    ret

MovieFile:          db "BA.MVZ",0
FHandle:            db 0
FramCont:           db 0
ScanDblr:           db 0
Mode:               db 0
ScreenAddr:         dw 04000h
ScreenPage:         db 00011111b
PointerSoundBuffer: dw SoundBuffer
SoundBuffer:        equ $
Buffer:             equ $+LBUFFER

;                    end 8000h
