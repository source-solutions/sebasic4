; GRAPHIC ADVENTURE DISPLAY SYSTEM

; GADS is an IM2 routine to be used for creating Magnetic Scrolls
; style mixed-mode graphic adventure games on Chloe 280SE compatible
; computers. The timing may need adjusting for non-3.5MHz/50Hz machines.

; Local constants

pause_1		equ	$024e		; first pause in im2 routine (50hz)
pause_2		equ	$0220		; second pause in im2 routine (50hz)


; IM2 TABLE
; 257 bytes that all point to address $acac avoiding problems with badly
; behaved hardware and not assuming the existence of a table in the ROM

	org	17408				; 0x4444
							; leave 1K after the ROM for an 8-bit code page

itable:
	defs	257, 0x45		; 257 byte table points to INTRPT

	org	17665				; call to start IM2 mode

set_im2:
	ld		a, 0x44	 		; A points to the table at 0x44xx
	ld		i, a			; copy A to the index register
	im		2				; set interrupt mode 2
	ret						; done

	org	17672				; call to switch off IM2 mode

set_im1:
	im		1				; set interrupt mode 1
	ret						; done

; MIXED MODE
; An IM2 routine that creates a mixed mode display on a machine with Timex
; compatible display modes. The top printable line is hi-res. The next 12
; are hi-colour. The rest are hi-res.

	org	17733				; 0x4545
	 
intrpt:
	push	af				; preserve
	push	bc				; registers

	in		a, (0xff)		; get setting of port 0xff
	and		0x80			; preserve the MMU bit
	or		0x3e			; hi-res/white on black
	out		(0xff), a		; set screen mode

	ld		bc, pause_1		; to the end of row 0

iloop1:
	dec		bc				; decrement the count
	ld		a,b				; test for
	or		c 				; zero
	jr		nz, iloop1		; loop if not

	in		a, (0xff)		; get setting of port 0xff
	and		0x80			; preserve the MMU bit
	or		0x02			; hi-col
	out		(0xff), a		; set screen mode

	ld		bc, pause_2		; to the end of row 12

iloop2:
	dec		bc				; same as loop1
	ld		a, b			; no byte saving
	or		c 				; by turning it into
	jr		nz, iloop2		; a subroutine

	in		a, (0xff)		; get setting of port $ff
	and		0x80			; preserve the MMU bit
	or		0x3e			; hi-res/white on black
	out		(0xff), a		; set screen mode

	pop		bc				; restore
	pop		af				; registers

	rst		38h				; call IM1 routine
	reti					; proper IM2 return
