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
