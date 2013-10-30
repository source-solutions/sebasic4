; --- THE MISCELLANEOUS ROUTINES ----------------------------------------------

.ifdef ROM0
org 0x3cac
	defs	4, 255					; unused locations (ROM 0)

org 0x3cb0
	incbin	"copyright.txt"			; 80 characters
.endif

.ifdef ROM1
; THE 'CO-ORDS TO BC' SUBROUTINE
org 0x3cac
coords_to_bc:
	call	stk_to_bc				; co-ords to BC, sign bytes to DE
	dec		e						; x positive?
	jr		nz, xy_error			; error if not
	dec		d						; y positive?
	ld		a, b					; y coord to A
	jr		z, y_pos				; jump if positive
	cp		17						; 1 to 16?
	jr		nc, xy_error			; error if not
	neg								; subtract from zero

org 0x3cbc
y_pos:
	add		a, 16					; change range (0 to 191)
	ld		b, a					; store result in B
	ret								; end of subroutine

org 0x3cc0
xy_error:
	rst		error					; else
	defb	Integer_out_of_range	; error
	
; THE 'CIRCLE CO-ORDS' SUBROUTINE
org 0x3cc2
circle_coords:
	fwait							; x, y, z
	fxch							; x, z, y
	fce								; x, z, y
	call	fp_to_a					; y to A
	jr		z, circle_pos			; jump if positive
	neg								; subtract from zero

org 0x3ccc
circle_pos:
	add		a, 16					; offset to get real value
	call	stack_a					; put it on the stack
	fwait							; x, z, y
	fxch							; x, y, z
	fstkpix.5						; x, y, z, pi * 0.5
	fce								; exit calculator
	ret								; end of subroutine

; THE 'STK TO LC' SUBROUTINE
org 0x3cd6
stk_to_lc:
	call	stk_to_bc				; calculator stack to BC
	ld		a, d					; both
	add		a, e					; positive?
	jr		c, lc_error				; error if not
	ld		a, b					; column to A
	cp		32						; in range (0 to 31)?
	jr		nc, lc_error			; error if not
	ld		a, c					; row to A
	cp		24						; in range (0 to 23)?
	ret		c						; return if so

org 0x3ce6
lc_error:
	rst		error					; else
	defb	Integer_out_of_range	; error

; THE 'SCANNING SCREEN$' SUBROUTINE (CONTINUED)
org 0x3ce8
s_scrn_str_s_1:
	ld		hl, (chars)				; address of font
	inc		h						; offset to first character
	ld		a, c					; line to A
	rrca							; multiply
	rrca							; by
	rrca							; 32
	and     %11100000				; combine
	xor		b						; with column
	ld		e, a					; to get low byte
	ld		a, c					; of top line
	and		%00011000				; preserve bits 3 to 4
	xor		%01000000				; add screen address
	ld		d, a					; start address to DE
	ld		b, 2					; two passes
	jp		s_scrn_str_s_2			; immediate jump

org 0x3cff
	defs	1, 255					; unused locations (ROM 1)
.endif
