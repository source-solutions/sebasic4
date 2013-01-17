; Based on Proportional Printing by Tony Samuels
; First published Your Spectrum #20, November 1985.
; Including code by Ian Beardsmore from Your Spectrum #7, September 1984.

po_gr_1		equ	0x0b38
po_tokens	equ	0x0c10
report_j	equ	0x15c4
chan_open	equ	0x1601
make_room	equ	0x1655
pixel_add	equ	0x22aa
strms		equ	0x5c10
chars		equ	0x5c36
chans		equ	0x5c4f
prog		equ	0x5c53
udg			equ	0x5c7b
coords		equ	0x5c7d
coords_x	equ	0x5c7d
coords_y	equ	0x5c7e
df_cc		equ	0x5c84
s_posn		equ	0x5c88
attr_p		equ	0x5c8d
mem_0		equ	0x5c92

			org	65121		; 415 bytes

c_chan:
	ld		hl, (prog)		; a channel must be created below basic
							; so look at the system variable PROG
	dec		hl				; move hl down one address
	ld		bc, 5			; the new channel takes 5 bytes
	call	make_room		; call the MAKE_ROOM routine
	inc		hl				; move HL up one address
	ld		bc, do_it		; could write the bytes directly but
							; then code would be non-relocatable
	ld		(hl), c			; low byte of the output routine
	inc		hl				; move HL up one address
	push	hl				; save this address for later
	ld		(hl), b			; high byte of the output routine
	inc		hl				; move HL up one address
	ld		bc, report_j	; address of input routine (REPORT J)
	ld		(hl), c			; low byte of the input routine
	inc		hl				; move HL up one address
	ld		(hl), b			; high byte of the input routine
	inc		hl				; move HL up one address 
	ld		(hl), 'S'		; channel type; 'K', 'S', 'R' or 'P'

; attach stream

	pop		hl				; the first address plus one of the
							; extra space stored earlier
	ld		de, (chans)		; store the contents of CHANS in DE
	and		a				; clear the carry flag before
							; calculation
	sbc		hl, de			; the difference between the start of
							; the channels area and the start of the
							; extra space becomes the offset, stored
							; in HL
	ex		de, hl			; store the offset in DE
	ld		hl, strms		; store the contents of STRMS in HL
	ld		a, 4			; stream number 4
	add		a, 3			; take account of streams -3 to -1
	add		a, a			; each of the seven default streams has
							; two bytes of offset data
							; the total number of bytes occupied,
							; held in a, forms the offset for the
							; new stream
	ld		b, 0			; set b to hold $00
	ld		c, a			; set the low byte of the offset
	add		hl, bc			; the offset is added to the base
							; address to give the correct location
							; in the streams table to store the
							; offset
	ld		(hl), e			; the low byte of the offset
	inc		hl				; move HL up one address
	ld		(hl), d			; the high byte of the offset
	ret						; all done

do_it:
	push	hl				; Save all the registers, call the 
	push	bc				; printing routine, put all the registers
	push	de				; back again and leap back to the
	push	af				; operating system.
	call	doit1			;
	pop		af				;
	pop		de				;
	pop		bc				;
	pop		hl				;
	ret						;

doit1:
	push	af				; Look to see if last character was a
	ld		a, (atflg)		; control code 22 - the code for AT.
	and		a				;
	jr		nz, getxp		;
	pop		af				;

atchq:
	cp		22				; If the current character is an AT control
	jr		nz, crchq		; code, set the ATFLG to indicate that the
	ld		a, 255			; next two codes dealt with will be the X
	ld		(atflg), a		; and Y positions for the print.
	ret						;

getxp:
	cp		254				; If the last charater was an AT then fetch
	jr		z, getyp		; the X and Y co-ordinates and move to the
	pop		af				; new printing position.
	ld		(coords_x), a	;
	ld		hl, atflg		;
	dec		(hl)			;
	ret						;

getyp:
	pop		af				;
	ld		b, a			;
	ld		a, 184			;
	sub		b				;
	ld		(coords_y), a	;
	xor		a				;
	ld		(atflg), a		;
	ret						;

crchq:
	cp		13				; If the current character is a return 
	jr		nz, vchrq		; control code, move down 8 pixels and open
	call	dwncr			; channel 2 to deal with nasty INK and
	ld		a, 2			; PAPER control codes.
	call	chan_open		;

skipc:
	ret						;

vchrq:
	cp		24				; Burp! if the character is not between 32
	jr		c, prntq		; and 127 then print a question mark
	cp		128				; instead.
	jr		c, fchr			;
	cp		144				; block graphic?
	jr		c, blgr			; 
	cp		165				; UDGs?
	jr		c, udgs			; 
	bit		3, (iy + 1)		; see if 8-bit mode is set
	jr		nz, fchr		; just print a character if it is
	sub		165				; 
	jp		po_tokens		; exit via PO_TOKENS

prntq:
	ld		a, '?'			;
	jr		fchr			;

blgr:
	ld		b, a			; save character
	call	po_gr_1			; constructs the block graphic
	ld		hl, mem_0		;
	jr		prnit			;

udgs:
	sub		144				; reduce range
	call	get_addr		; 
	ld		hl, (udg)		; 
	jr		udg2			; 
	
get_addr:
	ld		h, 0			; Figure out where the character's
	ld		l, a			; definition is stored in memory.
	add		hl, hl			;
	add		hl, hl			;
	add		hl, hl			;
	ex		de, hl			;
	ret						; 

err5:
	rst		8				;
	defb	4				;

fchr:
	call	get_addr		; 
	ld		hl, (chars)		;

udg2:
	add		hl, de			;

prnit:
	ld		bc, 7			; the address of the seventh byte of the
	add		hl, bc			; character, check the character will fit
	ld		(chrad), hl		; on the screen and calculate the address
	ld		a, (coords_y)	; in the display file where the character
	cp		185				; will be printed.
	jr		nc, err5		;
	call	fitcq			;
	ld		bc, (coords)	;
	ld		a, 191			; mod to access lower screen
	call	pixel_add + 2	;
	ld		(s_posn), a		;
	ld		(df_cc), hl		;
	ld		b, 8			;

prnlp:
	push	bc				;
	ld		hl, (chrad)		;
	ld		a, (hl)			;
	sll		a				; pre-rotate left once to get the middle
	and		%11111100		; six and clear the right two pixels
	dec		hl				;
	ld		(chrad), hl 	;
	ld		l, a			;
	ld		a, (s_posn)		;
	ld		bc, 0xff03		; mask
	push	bc				; save mask
	and		a				; sometimes no rotation is required
	jr		z, putit		;
	pop		bc				; drop saved mask
	ld		b, a			;
	push	bc				; save count		
	ex		de, hl			; save character

mask:
	ld		hl, 0x00fc

rotmsk:
	srl		l
	rr		h
	and		a
	djnz	rotmsk
	ld		a, 255			; invert mask
	xor		h				;
	ld		h, a			;
	ld		a, 255			;
	xor		l				;
	ld		l, a			;
	pop		bc				; restore count
	push	hl				; save mask
	ex		de, hl			; restore character
	ld		h, 0			;

rotlp:
	srl		l				; Rotate the character definition into the 
	rr		h				; correct pixel position, place it on the
	and		a				; screen one byte at a time and make sure
	djnz	rotlp			; each byte is in the right colour.

putit:
	pop		bc				; restore mask
	ld		de, (df_cc)		;
	ld		a, (de)			;
	and		c				; mask off
	xor		l				;
	ld		(de), a			;
	call	colad			;
	ld		a, (s_posn)		;
	and		a				; was cp 0
	jr		z, pst			;

	inc		e				; Timmy's attribute patch
	ld		a, e			;
	and		31				;
	jr		z, pst			;
	ld		a, (coords_x)	;
	or		248				;
	add		a, 4			; always 6 pixels 
	jr		nc, pst			;

	ld		a, (de)			;
	and		b				; mask off
	xor		h				;
	ld		(de), a			;
	call	colad			;

pst:
	ld		hl, (df_cc) 	;
	call	uline			;
	ld		(df_cc), hl		;
	pop		bc				;
	djnz	prnlp			;
	ld		a, (coords_x)	; the character just printed.
	add		a, 6			; always 6 pixels
	ld		(coords_x), a	;
	ret						;

uline:
	push	af				; Here's a handy routine that sets HL to
	ld		a, h			; point to the next pixel line up in the
	dec		h				; display file.
	and		7				;
	jr		nz, _end		;
	ld		a, l			;
	sub		32				;
	ld		l, a			;
	jr		c, _end			;
	ld		a, h			;
	add		a, 8			;
	ld		h, a			;

_end:
	pop		af				;
	ret						;

fitcq:
	ld		b, 8			; Check if the character to be printed will fit
	ld		a, %00000011	; Always 6 pixels
	ld		c, a			;

cntlp:
	and		a				;
	srl		c				;  
	jr		nc, _out		; 		
	dec		b				;
	jr		cntlp			;

_out:
	ld		a, b			;
	ld		a, (coords_x)	;
	add		a, b			;
	ret		nc				;

dwncr:
	xor		a				; If it doesn't, move down 8 pixels and
	ld		(coords_x), a	; back to the left hand side of the screen.
	ld		a, (coords_y)	;
	sub		8				;
	ld		(coords_y), a	;
	ret						;

colad:
	push	hl				; And another useful routine - it
	push	af				; calculates the relevant address in the
	ld		a, d			; attributes file from a  given display
	rrca					; file address and stores the INK value of
	rrca					; ATTR_P (the permanent PAPER and INK
	rrca					; colours) in it.
	and		3				;
	or		%01011000		;
	ld		h, a			;
	ld		l, e			;
	ld		a, (attr_p)		;
	ld		(hl), a			;
	pop		af				;
	pop		hl				;
	ret						; That's all folks!

chrad:
	defw		0			; Reserve a bit of space for some
							; variables.

atflg:
	defb		0			;
