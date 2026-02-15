;    ZXZVM: Z-Code interpreter for the Z80 processor - Chloe I/O interface
;    Copyright (C) 1998-9,2006,2016  John Elliott <seasip.webmaster@gmail.com>
;    Adapted for Chloe by Source Solutions, Inc.
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.

; Chloe-specific I/O routines for ZXZVM

	include "../../../../boot/os.inc"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Jump table for ZXZVM I/O functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	jp	chloe_init		; ZXINIT
	jp	chloe_exit		; ZXEXIT  
	jp	chloe_cls		; ZXCLS
	jp	chloe_peek		; ZXPEEK
	jp	chloe_poke		; ZXPOKE
	jp	chloe_pk64		; ZXPK64
	jp	chloe_pkwd		; ZXPKWD
	jp	chloe_pkwi		; ZXPKWI
	jp	chloe_fdos		; ZXFDOS
	jp	chloe_ihdr		; ZXIHDR
	jp	chloe_tmem		; ZXTMEM
	jp	chloe_eraw		; ZXERAW
	jp	chloe_zchr		; ZXZCHR
	jp	chloe_swnd		; ZXSWND
	jp	chloe_uwnd		; ZXUWND
	jp	chloe_styl		; ZXSTYL
	jp	chloe_scur		; ZXSCUR
	jp	chloe_inp		; ZXINP
	jp	chloe_rchr		; ZXRCHR
	jp	chloe_scol		; ZXSCOL
	jp	chloe_sfnt		; ZXSFNT
	jp	chloe_rndi		; ZXRNDI
	jp	chloe_getx		; ZXGETX
	jp	chloe_gety		; ZXGETY
	jp	chloe_strm		; ZXSTRM
	jp	chloe_eral		; ZXERAL
	jp	chloe_snd		; ZXSND
	jp	chloe_rst		; ZXRST
	jp	chloe_name		; ZXNAME
	jp	chloe_open		; ZXOPEN
	jp	chloe_clse		; ZXCLSE
	jp	chloe_read		; ZXREAD
	jp	chloe_writ		; ZXWRIT
	jp	chloe_rmem		; ZXRMEM
	jp	chloe_wmem		; ZXWMEM
	jp	chloe_vrfy		; ZXVRFY
	jp	chloe_bfit		; ZXBFIT
	jp	chloe_rcpu		; ZXRCPU
	jp	chloe_iliv		; ZXILIV
	jp	chloe_ver		; ZXVER
	jp	chloe_uscr		; ZXUSCR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

chloe_file_handle:	defb	0
game_filename:		defs	32
input_buffer:		defs	256
screen_width:		defb	80		; Chloe screen mode 0 width (80 columns)
screen_height:		defb	24		; Chloe screen mode 0 height (24 text rows)
cursor_x:		defb	0
cursor_y:		defb	0
current_window:		defb	0
text_style:		defb	0

; Memory layout for Chloe - using main RAM
HDRADDR			EQU	8000h		; Z-machine header at $8000
SCRADDR			EQU	8000h		; Screen memory (when needed)
Z_MEM_BASE		EQU	8000h		; Base of Z-machine memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ZXINIT - Initialize I/O subsystem
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
chloe_init:
	; DE points to filename (for esxDOS version)
	; For Chloe, we'll get filename from BASIC parameters later
	
	; Initialize screen
	call	chloe_cls
	
	; Copy filename if provided
	ld	hl, de
	ld	de, game_filename
	ld	bc, 20
	ldir
	
	; Initialize file handle
	xor	a
	ld	(chloe_file_handle), a
	
	; Try to open the game file
	call	open_game_file
	jp	nc, init_error
	
	scf				; Success
	ret

init_error:
	ld	hl, no_file_err
	ccf				; Failure
	ret

no_file_err:
	defb	'Game file not found', 13 + 128

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File operations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

open_game_file:
	; Open the Z-machine game file
	ld	a, 0			; Drive 0
	ld	ix, game_filename	; Filename
	ld	b, 0			; Read mode
	ld	de, 0			; No header buffer needed
	rst	8
	defb	f_open
	jp	c, open_error
	
	ld	(chloe_file_handle), a	; Save file handle
	scf				; Success
	ret

open_error:
	ccf				; Failure
	ret

chloe_open:
	; HL = filename, B = mode (0=read, 1=create)
	push	hl
	
	ld	a, 0			; Drive 0
	push	hl
	pop	ix			; Filename pointer
	; B already contains mode
	ld	de, 0			; No header
	rst	8
	defb	f_open
	jp	c, open_file_error
	
	ld	(chloe_file_handle), a
	pop	hl
	scf
	ret

open_file_error:
	pop	hl
	ccf
	ret

chloe_clse:
	ld	a, (chloe_file_handle)
	and	a
	ret	z			; No file open
	
	rst	8
	defb	f_close
	
	xor	a
	ld	(chloe_file_handle), a
	ret

chloe_read:
	; Read BC bytes to HL
	push	hl
	push	bc
	
	ld	a, (chloe_file_handle)
	push	hl
	pop	ix			; Buffer address
	; BC already contains byte count
	rst	8
	defb	f_read
	
	pop	bc
	pop	hl
	ret

chloe_writ:
	; Write BC bytes from HL  
	push	hl
	push	bc
	
	ld	a, (chloe_file_handle)
	push	hl
	pop	ix			; Buffer address
	; BC already contains byte count
	rst	8
	defb	f_write
	
	pop	bc
	pop	hl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Screen and keyboard operations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

chloe_cls:
	; Clear screen using BASIC ROM routine
	rst	18h
	defw	0DAFh			; CLS routine in ROM
	scf
	ret

chloe_fdos:
	; CP/M-style console I/O
	ld	a, c
	cp	1
	jp	z, fdos_conin_echo
	cp	2  
	jp	z, fdos_conout
	cp	6
	jp	z, fdos_coninp
	cp	9
	jp	z, fdos_string
	ret

fdos_conin_echo:
	; Wait for key and echo
	rst	18h
	defw	15DEh			; KEY_SCAN in ROM
	ld	a, l
	rst	10h			; Echo character
	ret

fdos_conout:
	; Output character in E
	ld	a, e
	rst	10h
	ret

fdos_coninp:
	; Input/polling functions
	ld	a, e
	cp	0FFh
	jp	z, fdos_poll_key
	cp	0FEh  
	jp	z, fdos_key_waiting
	cp	0FDh
	jp	z, fdos_key_nowait
	; Otherwise output character
	rst	10h
	ret

fdos_poll_key:
	; Poll keyboard, return char or 0
	rst	18h
	defw	15DEh			; KEY_SCAN
	ld	a, l
	ret

fdos_key_waiting:
	; Return 1 if key waiting, 0 otherwise
	rst	18h
	defw	15DEh
	ld	a, 0
	ld	l, a
	or	l
	ret	z
	inc	a
	ret

fdos_key_nowait:
	; Wait for key without echo
	rst	18h
	defw	15DEh
	ld	a, l
	ret

fdos_string:
	; Print string at DE until '$'
print_loop:
	ld	a, (de)
	cp	'$'
	ret	z
	rst	10h
	inc	de
	jr	print_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory access functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

chloe_peek:
	; Read Z-machine address EHL, return in A
	; Simple implementation - just read from RAM
	ld	a, e
	or	a
	jr	nz, peek_high
	; Low memory access
	ld	a, (hl)
	scf
	ret

peek_high:
	; High memory - for now, just return 0
	; A proper implementation would handle banked memory
	xor	a
	scf  
	ret

chloe_poke:
	; Store A in address HL
	ld	(hl), a
	ret

chloe_pk64:
	; Read address HL in low 64k
	ld	a, (hl)
	ret

chloe_pkwd:
	; Read word from EHL into BC
	call	chloe_peek
	ld	b, a
	inc	hl
	call	chloe_peek
	ld	c, a
	ret

chloe_pkwi:
	; Read word and increment
	call	chloe_pkwd
	inc	hl
	ld	a, e
	or	a
	jr	nz, pkwi_high
	jr	nc, pkwi_carry
	inc	hl
	ret

pkwi_high:
	inc	e
	ret	nz
	inc	hl
	ret

pkwi_carry:
	inc	e
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Other required functions (stubs for now)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

chloe_exit:
	scf
	ret

chloe_ihdr:
	scf
	ret

chloe_tmem:
	ld	hl, 0C000h		; Top of available memory
	ret

chloe_eraw:
	scf
	ret

chloe_zchr:
	; Output ZSCII character HL to stream A
	ld	a, l
	rst	10h			; Simple character output
	scf
	ret

chloe_swnd:
chloe_uwnd:
chloe_styl:
chloe_scur:
	scf
	ret

chloe_inp:
	; Line input - simplified
	ld	b, 10			; Success code
	scf
	ret

chloe_rchr:
	; Read character
	rst	18h
	defw	15DEh
	ld	a, l
	ret

chloe_scol:
chloe_sfnt:
	scf
	ret

chloe_rndi:
	; Return random number
	ld	de, 12345		; Fixed for now
	ret

chloe_getx:
	ld	a, (cursor_x)
	ld	l, a
	ld	a, (screen_width)
	ld	h, a
	sub	l
	ld	h, a			; Characters remaining
	ld	a, (screen_width)
	ret

chloe_gety:
	ld	a, (cursor_y)
	ld	l, a
	ret

chloe_strm:
chloe_eral:
chloe_snd:
chloe_rst:
chloe_name:
chloe_rmem:
chloe_wmem:
chloe_vrfy:
chloe_bfit:
chloe_rcpu:
chloe_iliv:
	scf
	ret

chloe_ver:
	ld	a, VMVER
	ret

chloe_uscr:
	ret