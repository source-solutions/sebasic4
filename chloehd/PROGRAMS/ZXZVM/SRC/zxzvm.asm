;    ZXZVM: Z-Code interpreter for the Z80 processor - Chloe version
;    Copyright (C) 1998-9,2006,2016  John Elliott <seasip.webmaster@gmail.com>
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

	include	"in_zxzvm.inc"
	include	"chloedep.asm"

peek64	equ	ZXPK64

; Entry point for Chloe app - launch ZXZVM
	org	6000h
	
; Restore BASIC stack pointer
	ld	hl, (oldsp)
	ld	sp, hl
	
; Simple parameter handling - for now we'll prompt for filename
; Future versions could parse BASIC RUN parameters properly
	
	call	get_filename
	jp	nc, param_error
	
	jp	main

; Get Z-machine game filename from user
get_filename:
	ld	de, filename_prompt
	ld	c, 9
	call	print_string
	
	; Simple input routine
	ld	hl, param_buffer
	ld	b, 30			; Max length
	call	input_line
	
	; Check if user entered anything
	ld	hl, param_buffer
	ld	a, (hl)
	or	a			; Empty string?
	jr	z, no_file_error	; Show help if nothing entered
	
	; Add .z5 extension if none provided
	call	check_add_extension
	
	; Terminate with 0FFh for compatibility
	ld	hl, param_buffer
find_end:
	ld	a, (hl)
	or	a
	jr	z, add_term
	inc	hl
	jr	find_end
add_term:
	ld	(hl), 0FFh
	
	scf				; Success
	ret

param_error:
	ld	de, param_err_msg
	ld	c, 9
	call	print_string
	ret

no_file_error:
	ld	de, no_file_msg
	ld	c, 9
	call	print_string
	ret

; Simple string input
input_line:
	ld	c, 0			; Character count
input_loop:
	push	bc
	push	hl
	call	wait_key
	pop	hl
	pop	bc
	
	cp	13			; Enter?
	jr	z, input_done
	cp	8			; Backspace?
	jr	z, input_bs
	cp	32			; Printable?
	jr	c, input_loop
	
	ld	a, c
	cp	b			; At max length?
	jr	nc, input_loop
	
	pop	af			; Get key back
	ld	(hl), a			; Store in buffer
	call	print_char		; Echo
	inc	hl
	inc	c
	jr	input_loop

input_bs:
	ld	a, c
	or	a			; At start?
	jr	z, input_loop
	dec	hl
	dec	c
	ld	a, 8
	call	print_char
	ld	a, ' '
	call	print_char
	ld	a, 8
	call	print_char
	jr	input_loop

input_done:
	ld	(hl), 0			; Null terminate
	ret

; Check if extension exists, add .z5 if not
check_add_extension:
	ld	hl, param_buffer
	call	strlen
	ld	de, param_buffer
	add	hl, de
	
	; Check last 3 characters for .z
	ld	de, -3
	add	hl, de
	ld	a, (hl)
	cp	'.'
	ret	nz			; No extension
	
	inc	hl
	ld	a, (hl)
	and	0DFh			; Uppercase
	cp	'Z'
	ret	nz			; Not .z
	
	ret				; Already has .z extension

; Add .z5 extension
add_z5_ext:
	ld	hl, param_buffer
	call	strlen
	ld	de, param_buffer
	add	hl, de
	ld	de, z5_ext
	ld	bc, 3
	ldir
	ret

; Utility functions
strlen:
	ld	bc, -1
	ld	a, 0
	cpir
	ld	hl, bc
	xor	a
	sbc	hl, bc
	dec	hl
	ret

wait_key:
	; Wait for keypress
wait_key_loop:
	call	scan_key
	or	a
	jr	z, wait_key_loop
	ret

scan_key:
	; Scan keyboard (simplified)
	rst	18h
	defw	15DEh			; KEY_SCAN in ROM
	ld	a, l
	ret

print_char:
	rst	10h
	ret

print_string:
	ld	a, (de)
	cp	'$'
	ret	z
	rst	10h
	inc	de
	jr	print_string

; System variables and constants
oldsp			equ	5BBAh		; BASIC stack pointer
param_buffer:		defs	32
filename_prompt:	defb	13, 10, 'Z-machine file: $'
param_err_msg:		defb	'Parameter error', 13, '$'
no_file_msg:		defb	13, 10, 'No file specified!', 13, 10
			defb	'Please enter a Z-machine game filename (.z3, .z5, .z8)', 13, 10
			defb	'Copy your game files to /PROGRAMS/ZXZVM/RSC/ first', 13, '$'
z5_ext:			defb	'.z5', 0

; BASIC parameter buffer and storage

main:	
	ld	(isp), sp	; Save current SP
	ld	hl, 0
	ld	(cycles), hl
	ld	de, param_buffer
	call	ZXINIT		; Initialise the I/O code
	jp	nc, syserr
	call	ZXVER
	ld	hl, vererr
	cp	VMVER
	jp	nz, syserr
	call	ZXIHDR
	jp	nc, syserr
	call	init_hdr
	jp	nc, syserr
	call	init_scr
	jp	nc, syserr
	call	init_rnd
	jp	nc, syserr
	call	init_stack
	jp	nc, syserr
	call	test_mem	; Check we can write Z-memory
	jp	nc, syserr
	ld	a, 1
	ld	(running), a
	call	showpc

zloop:	
	call	zinst
	push	hl		
	push	af
	ld	hl, (cycles)
	inc	hl
	ld	(cycles), hl	; Call ZXRCPU once every 2048 z-cycles.
	ld	a, h
	cp	8
	jr	c, zlp0	
	ld	hl, 0
	ld	(cycles), hl
	call	ZXRCPU		
zlp0:				
zlp1:	
	pop	af
	pop	hl

	call	showpc
	jp	nc, zmstop
	ld	a, (running)	; Running = 1 to continue
	dec	a		;        = 0 to quit
	jr	z, zloop	;        = 2 to restart
	inc	a
	jr	z, zmexit
	cp	2
	jr	z, zmreset
	jp	stub

zmstop:	
	push	hl	
	call	flush_buf
	call	showstk
	ld	de, anykey
	ld	c, 9
	call	ZXFDOS
	ld	c, 6
	ld	e, 0FDh
	call	ZXFDOS
	pop	hl
	jp	syserr

zmexit:	
	call	flush_buf
	ld	de, anykey
	ld	c, 9
	call	ZXFDOS
	ld	c, 6
	ld	e, 0FDh
	call	ZXFDOS
	jp	zexit

zmreset:
	call	init_hdr
	jp	nc, syserr
	call	init_scr
	jp	nc, syserr
	call	init_rnd
	jp	nc, syserr
	call	init_stack
	jp	nc, syserr
	ld	a, 1
	ld	(running), a
	jp	zloop

; System variables
isp:		defw	0
cycles:		defw	0
running:	defb	0

; Error messages
vererr:		defb	'Version mismatch', 13, '$'
anykey:		defb	13, 10, 'Press any key...', '$'

; System error handler
syserr:
	ld	c, 9
	call	ZXFDOS
	ret

; Exit back to BASIC
zexit:
	ret

; Stub for unimplemented functions
stub:
	ld	hl, stub_msg
	jp	syserr

stub_msg:
	defb	'Unimplemented function', 13, '$'

; Include VM core files
	include	"in_ver.inc"		; Version information  
	include	"in_wrhex.inc"		; Hex output routines
	
; Placeholder for missing VM functions that need proper implementation
zinst:
	; Instruction decode and execute - needs full VM implementation
	ld	a, (running)
	dec	a
	ld	(running), a		; Set to exit for now
	ret

showpc:
	; Show program counter - stub
	scf
	ret

init_hdr:
	; Initialize Z-machine header
	scf
	ret

init_scr:
	; Initialize screen
	call	ZXCLS
	scf
	ret

init_rnd:
	; Initialize random number generator
	scf
	ret

init_stack:
	; Initialize Z-machine stack
	scf
	ret

test_mem:
	; Test memory access
	scf
	ret

flush_buf:
	; Flush output buffers
	ret

showstk:
	; Show stack - debug function
	ret