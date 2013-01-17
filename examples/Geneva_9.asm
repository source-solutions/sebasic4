; 16 Row Proportional Printing

; Based on code by Tony Samuels (Your Spectrum issue 20, November 1985)
; and Ian Beardsmore (Your Spectrum issue 7, September 1984).
; Geneva 9 font by Susan Kare (c) 1984 Apple Computer, Inc.

; 1435 bytes. Channel code only needs to run once so you can use:
; CLEAR 64100: RANDOMIZE USR 64101: CLEAR 64153
; to free up an extra 53 bytes. Print with PRINT #4;"Hello Sailor!"

report_j	equ	0x15c4
chan_open	equ	0x1601
make_room	equ	0x1655
clear_1		equ	0x1eb7
pixel_add	equ	0x22aa
strms		equ	0x5c10
chans		equ	0x5c4f
prog		equ	0x5c53
coords_x	equ	0x5c7d
coords_y	equ	0x5c7e
df_cc		equ	0x5c84
s_posn		equ	0x5c88
attr_p		equ	0x5c8d

			org	64101

; create a new channel and attach it to stream 4

c_chan:
	ld		hl, (prog)
	dec		hl
	ld		bc, 5
	call	make_room
	inc		hl
	ld		bc, do_it
	ld		(hl), c
	inc		hl
	push	hl
	ld		(hl), b
	inc		hl
	ld		bc, report_j
	ld		(hl), c
	inc		hl
	ld		(hl), b
	inc		hl
	ld		(hl), 'S'
	pop		hl
	ld		de, (chans)
	and		a
	sbc		hl, de
	ex		de, hl
	ld		hl, strms
	ld		a, 4
	add		a, 3
	add		a, a
	ld		b, 0
	ld		c, a
	add		hl, bc
	ld		(hl), e
	inc		hl
	ld		(hl), d
	ret

; proportional printing code

do_it:
	push	hl
	push	bc
	push	de
	push	af
	call	doit1
	pop		af
	pop		de
	pop		bc
	pop		hl
	ret

doit1:
	push	af
	ld		a, (atflag)
	and		a
	jr		nz, getxp
	pop		af
	cp		22
	jr		nz, crchq
	ld		a, 255
	ld		(atflag), a
	ret

getxp:
	cp		254
	jr		z, getyp
	pop		af
	ld		(coords_x), a
	ld		hl, atflag
	dec		(hl)
	ret

getyp:
	pop		af
	ld		b, a
	ld		a, 181
	sub		b
	ld		(coords_y), a
	xor		a
	ld		(atflag), a
	ret

crchq:
	cp		13
	jr		nz, vchrq
	call	dwncr
	ld		a, 2
	call	chan_open
	ret

err5:
	ld		a, (crmsk)
	ld		hl, (crad1)
	ld		(hl), a
	rst		8
	defb	4

vchrq:
	cp		32
	jr		c, prntqm
	cp		128
	jr		c, fchr

prntqm:
	ld		a, 63

fchr:
	ld		h, 0
	ld		l, a
	ld		d, h
	ld		e, l
	add		hl, hl
	add		hl, hl
	add		hl, de
	add		hl, hl
	add		hl, de
	ex		de, hl
	ld		hl, font - 352
	add		hl, de
	ld		a, (hl)
	ld		(crmsk), a
	ld		(hl), 0
	ld		(crad1), hl

prnit:
	ld		bc, 10
	add		hl, bc
	ld		(chrad), hl
	ld		a, (coords_y)
	cp		182
	jr		nc, err5
	call	fitcq
	ld		bc, (coords_x)
	ld		a, 191
	call	pixel_add + 2
	ld		(s_posn), a
	ld		(df_cc), hl
	ld		b, 11

prnlp:
	push	bc
	ld		hl, (chrad)
	ld		a, (hl)
	dec		hl
	ld		(chrad), hl
	ld		l, a
	ld		a, (s_posn)
	and		a
	jr		z, putit
	ld		b, a
	ld		h, 0

rotlp: 
	srl		l
	rr		h
	and		a
	djnz	rotlp
	
putit:
	ld		de, (df_cc)
	ld		a, (de)
	xor		l
	ld		(de), a
	call	colad
	ld		a, (s_posn)
	and		a
	jr		z, pst
	inc		e
	ld		a, e
	and		31
	jr		z, pst
	ld		a, (coords_x)
	or		248
	ld		b, a
	ld		a, (width)
	dec		a
	dec		a
	add		a, b
	jr		nc, pst
	ld		a, (de)
	xor		h
	ld		(de), a
	call	colad

pst:
	ld		hl, (df_cc)
	call	uline
	ld		(df_cc), hl
	pop		bc
	djnz	prnlp
	ld		a, (crmsk)
	ld		hl, (crad1)
	ld		(hl), a
	ld		a, (coords_x)
	ld		b, a
	ld		a, (width)
	add		a, b
	ld		(coords_x), a
	ret

uline:
	push	af
	ld		a, h
	dec		h
	and		7
	jr		nz, endit
	ld		a, l
	sub		32
	ld		l, a
	jr		c, endit
	ld		a, h
	add		a, 8
	ld		h, a
	
endit:
	pop		af
	ret

fitcq:
	ld		b, 8
	ld		a, (crmsk)
	ld		c, a

cntlp:
	and		a
	srl		c
	jr		nc, outit
	dec		b
	jr		cntlp

outit:
	ld		a, b
	ld		(width), a
	ld		a, (coords_x)
	add		a, b
	ret		nc

dwncr:
	xor		a
	ld		(coords_x), a
	ld		a, (coords_y)
	sub		12
	ld		(coords_y), a
	ret

colad:
	push	hl
	push	af
	ld		a, d
	rrca
	rrca
	rrca
	and		3
	or		$58
	ld		h, a
	ld		l, e
	ld		a, (attr_p)
	ld		(hl), a
	pop		af
	pop		hl
	ret

; variables

chrad:
	defw	0

atflag:
	defb	0

crmsk:
	defb	0

crad1:
	defw	0

width:
	defb	0

font:

; space
	defb %00011111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000

; !
	defb %00011111
	defb %00000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %00000000
	defb %01000000
	defb %00000000
	defb %00000000

; "
	defb %00000111
	defb %00000000
	defb %01010000
	defb %01010000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000

; #
	defb %00000001
	defb %00010100
	defb %01111100
	defb %00101000
	defb %01111100
	defb %01010000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000

; $
	defb %00000011
	defb %00100000
	defb %01110000
	defb %10101000
	defb %10100000
	defb %01110000
	defb %00101000
	defb %10101000
	defb %01110000
	defb %00100000
	defb %00000000

; %
	defb %00000000
	defb %00000000
	defb %01111111
	defb %10010010
	defb %10010100
	defb %01101110
	defb %00011001
	defb %00101001
	defb %01000110
	defb %00000000
	defb %00000000

; &
	defb %00000000
	defb %00110000
	defb %01001000
	defb %01010000
	defb %00100000
	defb %01010100
	defb %10001000
	defb %10010100
	defb %01100010
	defb %00000000
	defb %00000000

; '
	defb %00011111
	defb %00000000
	defb %01000000
	defb %01000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000

; (
	defb %00001111
	defb %00100000
	defb %01000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %01000000
	defb %00100000
	defb %00000000

; )
	defb %00001111
	defb %10000000
	defb %01000000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %01000000
	defb %10000000
	defb %00000000

; *
	defb %00000001
	defb %00000000
	defb %00010000
	defb %01010100
	defb %00111000
	defb %00101000
	defb %01000100
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000

; +
	defb %00000011
	defb %00000000
	defb %00000000
	defb %00100000
	defb %00100000
	defb %11111000
	defb %00100000
	defb %00100000
	defb %00000000
	defb %00000000
	defb %00000000

; , 
	defb %00001111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00100000
	defb %00100000
	defb %01000000

; -
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %11110000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000

; .
	defb %00011111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %01000000
	defb %00000000
	defb %00000000

; /
	defb %00000011
	defb %00001000
	defb %00001000
	defb %00010000
	defb %00010000
	defb %00100000
	defb %00100000
	defb %01000000
	defb %01000000
	defb %00000000
	defb %00000000

; 0
	defb %00000011
	defb %00000000
	defb %01110000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %01110000
	defb %00000000
	defb %00000000

; 1
	defb %00000011
	defb %00000000
	defb %00100000
	defb %01100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00000000
	defb %00000000

; 2
	defb %00000011
	defb %00000000
	defb %01110000
	defb %10001000
	defb %00001000
	defb %00010000
	defb %00100000
	defb %01000000
	defb %11111000
	defb %00000000
	defb %00000000

; 3
	defb %00000011
	defb %00000000
	defb %11111000
	defb %00010000
	defb %00100000
	defb %01110000
	defb %00001000
	defb %10001000
	defb %01110000
	defb %00000000
	defb %00000000

; 4
	defb %00000011
	defb %00000000
	defb %00010000
	defb %00110000
	defb %01010000
	defb %10010000
	defb %11111000
	defb %00010000
	defb %00010000
	defb %00000000
	defb %00000000

; 5
	defb %00000011
	defb %00000000
	defb %11111000
	defb %10000000
	defb %11110000
	defb %00001000
	defb %00001000
	defb %10001000
	defb %01110000
	defb %00000000
	defb %00000000

; 6
	defb %00000011
	defb %00000000
	defb %00110000
	defb %01000000
	defb %10000000
	defb %11110000
	defb %10001000
	defb %10001000
	defb %01110000
	defb %00000000
	defb %00000000

; 7
	defb %00000011
	defb %00000000
	defb %11111000
	defb %00001000
	defb %00010000
	defb %00010000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00000000
	defb %00000000

; 8
	defb %00000011
	defb %00000000
	defb %01110000
	defb %10001000
	defb %10001000
	defb %01110000
	defb %10001000
	defb %10001000
	defb %01110000
	defb %00000000
	defb %00000000

; 9
	defb %00000011
	defb %00000000
	defb %01110000
	defb %10001000
	defb %10001000
	defb %01111000
	defb %00001000
	defb %00010000
	defb %01100000
	defb %00000000
	defb %00000000

; :
	defb %00001111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00100000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00100000
	defb %00000000
	defb %00000000

; ;
	defb %00001111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00100000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00100000
	defb %00100000
	defb %01000000

; <
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00010000
	defb %00100000
	defb %01000000
	defb %00100000
	defb %00010000
	defb %00000000
	defb %00000000
	defb %00000000

; =
	defb %00000011
	defb %00000000
	defb %00000000
	defb %00000000
	defb %11111000
	defb %00000000
	defb %11111000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000

; >
	defb %00000111
	defb %00000000
	defb %00000000
	defb %01000000
	defb %00100000
	defb %00010000
	defb %00100000
	defb %01000000
	defb %00000000
	defb %00000000
	defb %00000000

; ?
	defb %00000011
	defb %00000000
	defb %00110000
	defb %01001000
	defb %00001000
	defb %00010000
	defb %00100000
	defb %00000000
	defb %00100000
	defb %00000000
	defb %00000000

; @
	defb %00000000
	defb %00000000
	defb %00111000
	defb %01000100
	defb %10011010
	defb %10101010
	defb %10101010
	defb %10011100
	defb %01000000
	defb %00111000
	defb %00000000

; A
	defb %00000001
	defb %00000000
	defb %00010000
	defb %00010000
	defb %00101000
	defb %00101000
	defb %01111100
	defb %01000100
	defb %01000100
	defb %00000000
	defb %00000000

; B
	defb %00000011
	defb %00000000
	defb %11110000
	defb %10001000
	defb %10001000
	defb %11110000
	defb %10001000
	defb %10001000
	defb %11110000
	defb %00000000
	defb %00000000

; C
	defb %00000011
	defb %00000000
	defb %01110000
	defb %10001000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10001000
	defb %01110000
	defb %00000000
	defb %00000000

; D
	defb %00000011
	defb %00000000
	defb %11100000
	defb %10010000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %10010000
	defb %11100000
	defb %00000000
	defb %00000000

; E
	defb %00000111
	defb %00000000
	defb %11110000
	defb %10000000
	defb %10000000
	defb %11100000
	defb %10000000
	defb %10000000
	defb %11110000
	defb %00000000
	defb %00000000

; F
	defb %00000111
	defb %00000000
	defb %11110000
	defb %10000000
	defb %10000000
	defb %11100000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %00000000
	defb %00000000

; G
	defb %00000011
	defb %00000000
	defb %01110000
	defb %10001000
	defb %10000000
	defb %10011000
	defb %10001000
	defb %10001000
	defb %01110000
	defb %00000000
	defb %00000000

; H
	defb %00000011
	defb %00000000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %11111000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %00000000
	defb %00000000

; I
	defb %00011111
	defb %00000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %00000000
	defb %00000000

; J
	defb %00000011
	defb %00000000
	defb %00001000
	defb %00001000
	defb %00001000
	defb %00001000
	defb %10001000
	defb %10001000
	defb %01110000
	defb %00000000
	defb %00000000

; K
	defb %00000011
	defb %00000000
	defb %10001000
	defb %10010000
	defb %10100000
	defb %11000000
	defb %10100000
	defb %10010000
	defb %10001000
	defb %00000000
	defb %00000000

; L
	defb %00000111
	defb %00000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %11110000
	defb %00000000
	defb %00000000

; M
	defb %00000000
	defb %00000000
	defb %10000010
	defb %11000110
	defb %10101010
	defb %10010010
	defb %10000010
	defb %10000010
	defb %10000010
	defb %00000000
	defb %00000000

; N
	defb %00000011
	defb %00000000
	defb %11001000
	defb %11001000
	defb %10101000
	defb %10101000
	defb %10011000
	defb %10011000
	defb %10001000
	defb %00000000
	defb %00000000

; O
	defb %00000011
	defb %00000000
	defb %01110000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %01110000
	defb %00000000
	defb %00000000

; P
	defb %00000011
	defb %00000000
	defb %11110000
	defb %10001000
	defb %10001000
	defb %11110000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %00000000
	defb %00000000

; Q
	defb %00000011
	defb %00000000
	defb %01110000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %10101000
	defb %01110000
	defb %00010000
	defb %00000000

; R
	defb %00000011
	defb %00000000
	defb %11110000
	defb %10001000
	defb %10001000
	defb %11110000
	defb %10100000
	defb %10010000
	defb %10001000
	defb %00000000
	defb %00000000

; S
	defb %00000011
	defb %00000000
	defb %01110000
	defb %10001000
	defb %10000000
	defb %01110000
	defb %00001000
	defb %10001000
	defb %01110000
	defb %00000000
	defb %00000000

; T
	defb %00000011
	defb %00000000
	defb %11111000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00000000
	defb %00000000

; U
	defb %00000011
	defb %00000000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %01110000
	defb %00000000
	defb %00000000

; V
	defb %00000011
	defb %00000000
	defb %10001000
	defb %10001000
	defb %10001000
	defb %01010000
	defb %01010000
	defb %00100000
	defb %00100000
	defb %00000000
	defb %00000000

; W
	defb %00000000
	defb %00000000
	defb %10000010
	defb %10000010
	defb %01010100
	defb %01010100
	defb %00101000
	defb %00101000
	defb %00101000
	defb %00000000
	defb %00000000

; X
	defb %00000011
	defb %00000000
	defb %10001000
	defb %10001000
	defb %01010000
	defb %00100000
	defb %01010000
	defb %10001000
	defb %10001000
	defb %00000000
	defb %00000000

; Y
	defb %00000011
	defb %00000000
	defb %10001000
	defb %10001000
	defb %01010000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00000000
	defb %00000000

; Z
	defb %00000111
	defb %00000000
	defb %11110000
	defb %00010000
	defb %00100000
	defb %01000000
	defb %10000000
	defb %10000000
	defb %11110000
	defb %00000000
	defb %00000000

; [
	defb %00001111
	defb %01100000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01100000
	defb %00000000

; \
	defb %00000011
	defb %01000000
	defb %01000000
	defb %00100000
	defb %00100000
	defb %00010000
	defb %00010000
	defb %00001000
	defb %00001000
	defb %00000000
	defb %00000000

; ]
	defb %00001111
	defb %01100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %01100000
	defb %00000000

; ^
	defb %00001111
	defb %00000000
	defb %01000000
	defb %10100000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000

; _
	defb %00000011
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %11111100
	defb %00000000
	defb %00000000

; £
	defb %00000011
	defb %00000000
	defb %00110000
	defb %01000000
	defb %01000000
	defb %11100000
	defb %01000000
	defb %01001000
	defb %11110000
	defb %00000000
	defb %00000000

; a
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %01100000
	defb %00010000
	defb %01110000
	defb %10010000
	defb %01110000
	defb %00000000
	defb %00000000

; b
	defb %00000111
	defb %00000000
	defb %10000000
	defb %10000000
	defb %11100000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %11100000
	defb %00000000
	defb %00000000

; c
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %01100000
	defb %10010000
	defb %10000000
	defb %10010000
	defb %01100000
	defb %00000000
	defb %00000000

; d
	defb %00000111
	defb %00000000
	defb %00010000
	defb %00010000
	defb %01110000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %01110000
	defb %00000000
	defb %00000000

; e
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %01100000
	defb %10010000
	defb %11110000
	defb %10000000
	defb %01100000
	defb %00000000
	defb %00000000

; f
	defb %00001111
	defb %00000000
	defb %00110000
	defb %01000000
	defb %11100000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %00000000
	defb %00000000

; g
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %01110000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %01110000
	defb %00010000
	defb %01100000

; h
	defb %00000111
	defb %00000000
	defb %10000000
	defb %10000000
	defb %11100000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %00000000
	defb %00000000

; i
	defb %00011111
	defb %00000000
	defb %01000000
	defb %00000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %00000000
	defb %00000000

; j
	defb %00001111
	defb %00000000
	defb %00100000
	defb %00000000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %00100000
	defb %11000000

; k
	defb %00000111
	defb %00000000
	defb %10000000
	defb %10000000
	defb %10010000
	defb %10100000
	defb %11000000
	defb %10100000
	defb %10010000
	defb %00000000
	defb %00000000

; l
	defb %00011111
	defb %00000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %00000000
	defb %00000000

; m
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %11101100
	defb %10010010
	defb %10010010
	defb %10010010
	defb %10010010
	defb %00000000
	defb %00000000

; n
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %11100000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %00000000
	defb %00000000

; o
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %01100000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %01100000
	defb %00000000
	defb %00000000

; p
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %11100000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %11100000
	defb %10000000
	defb %10000000

; q
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %01110000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %01110000
	defb %00010000
	defb %00010000

; r
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %10110000
	defb %11000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %00000000
	defb %00000000

; s
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %01110000
	defb %10000000
	defb %01100000
	defb %00010000
	defb %11100000
	defb %00000000
	defb %00000000

; t
	defb %00001111
	defb %00000000
	defb %01000000
	defb %01000000
	defb %11100000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %00100000
	defb %00000000
	defb %00000000

; u
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %10010000
	defb %01110000
	defb %00000000
	defb %00000000

; v
	defb %00000011
	defb %00000000
	defb %00000000
	defb %00000000
	defb %10001000
	defb %01010000
	defb %01010000
	defb %00100000
	defb %00100000
	defb %00000000
	defb %00000000

; w
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %10000010
	defb %01010100
	defb %01010100
	defb %00101000
	defb %00101000
	defb %00000000
	defb %00000000

; x
	defb %00000011
	defb %00000000
	defb %00000000
	defb %00000000
	defb %10001000
	defb %01010000
	defb %00100000
	defb %01010000
	defb %10001000
	defb %00000000
	defb %00000000

; y
	defb %00000011
	defb %00000000
	defb %00000000
	defb %00000000
	defb %10001000
	defb %10001000
	defb %01010000
	defb %01010000
	defb %00100000
	defb %00100000
	defb %11000000

; z
	defb %00000111
	defb %00000000
	defb %00000000
	defb %00000000
	defb %11110000
	defb %00100000
	defb %01000000
	defb %10000000
	defb %11110000
	defb %00000000
	defb %00000000

; {
	defb %00001111
	defb %00100000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %10000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %00100000
	defb %00000000

; |
	defb %00111111
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %10000000
	defb %00000000

; }
	defb %00001111
	defb %10000000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %00100000
	defb %01000000
	defb %01000000
	defb %01000000
	defb %10000000
	defb %00000000

; ~
	defb %00000011
	defb %00000000
	defb %01101000
	defb %10110000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000
	defb %00000000

; ©
	defb %00000000
	defb %00111100
	defb %01000010
	defb %10011001
	defb %10100001
	defb %10100001
	defb %10011001
	defb %01000010
	defb %00111100
	defb %00000000
	defb %00000000
