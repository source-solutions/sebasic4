
;    ZXZVM: Z-Code interpreter for the Z80 processor
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Add termination bit to ENCBUF
;
eterm:	push	af
	push	bc
	push	de
	push	hl
	ld	hl,encbuf
	ld	a,(encptr)	;A = no. of characters in buffer.
	or	a
	jr	z,eterm2
	dec	a
eterm1:	cp	3		;Reset the "termination" bit on all 
	jr	c,eterm2	;characters except the last.
	res	7,(hl)
	inc	hl
	inc	hl
	sub	3
	jr	eterm1
;
eterm2:	or	a
	jr	z,eterm3
	ld	d,5		;If no. of characters remaining is not a
	call	eaddch		;multiple of 3, append character 5 until it is.
	dec	a
	jr	nz,eterm2
eterm3:	set	7,(hl)		;Set the termination bit at the end.
;
;<< v0.02 Also set termination bits at encbuf+4 (z1-z3) or encbuf+6 (z4+)
;
	ld	hl,encbuf+2	;Start of 2nd word
	ld	a,(zver)
	cp	4
	jr	c,etermz
	ld	hl,encbuf+4	;Start of 3rd word
	jr	etermz
;
etermz: set	7,(hl)	; >> v0.02
	jp	popd
; 
;Append the character in D to ENCBUF
;
eaddch:	push	af
	push	bc
	push	de
	push	hl
	ld	a,d
	and	1fh
	ld	d,a
;
;Append character D to encbuf
;
	ld	hl,encbuf
	ld	a,(encptr)
	inc	a
	ld	(encptr),a
	dec	a
encoff:	cp	3
	jr	c,encmap
	inc	hl
	inc	hl
	sub	3
	jr	encoff
;
;HL->correct part of the buffer. 
;
encmap:	or	a
	jr	z,eadd0
	dec	a
	jr	z,eadd1
eadd2:	inc	hl
	ld	a,(hl)
	and	0E0h
	or	d
	ld	(hl),a
	jp	popd
;
eadd0:	ld	a,(hl)
	and	083h	
	rlc	d
	rlc	d
	or	d
	ld	(hl),a
	jp	popd
;
eadd1:	ld	a,d
	rrca
	rrca		
	rrca		;A is now LLL000HH
	ld	e,a 
	and	3
	ld	d,a	;D is 000000HH
	ld	a,e
	and	0E0h
	ld	e,a	;E is LLL00000
	ld	a,(hl)
	and	07Ch
	or	d
	ld	(hl),a
	inc	hl
	ld	a,(hl)
	and	1Fh
	or	e
	ld	(hl),a
	jp	popd
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Encode B ASCII chars at z-address HL to z-chars in encbuf. encbuf
; holds big-endian words.
;
encal:  defb    0       ;Encoding alphabet
encptr: defb    0	;No. of characters in ENCBUF
;
encode:	push	af
	push	bc
	push	de
	push	hl
	xor	a
	ld	(encal),a
	ld	(encptr),a
enchar:	call	peek64	;A = ascii character
	inc	hl
	push	hl
;
;See if the character can be found in the alphabets al0, al1, al2
;	
	ld	hl,al0+6
	call	findc	
	jr	z,eadd5
	ld	hl,al1+6
	call	findc
	jr	z,eadd6
	ld	hl,al2+7
	call	finda2
	jr	z,eadd7
;
;Add literal character...
;
	ld	d,5	;Shift to alphabet 2
	call	eaddch
	ld	e,a	;E = ASCII character
	ld	d,6	;ASCII escape
	call	eaddch
	ld	a,e	;A = HHHLLLLL
	rlca
	rlca
	rlca
	and	7
	ld	d,a
	call	eaddch
	ld	a,e	
	and	1fh
	ld	d,a
	call	eaddch
	jr	ence
;
eadd5:	call	eaddch
	jr	ence
;
eadd6:	ld	a,d
	ld	d,4
	jp	adds
;
eadd7:	ld	a,d
	ld	d,5
adds:	call	eaddch
	ld	d,a
	call	eaddch
ence:	pop	hl
	djnz	enchar
ence1:	ld	a,(encptr)
	cp	9
	call	nc,eterm
	jp	nc,popd
	ld	d,5
	call	eaddch
	jr	ence1	
;
finda2:	push	bc	;Special case for alphabet 2.
	ld	c,a
	ld	b,25
	ld	d,7
	jr	findcl

findc:	push	bc	;Returns Zero set if a character matches, 
	ld	c,a	;D = character number
	ld	d,6	
	ld	b,26
findcl:	ld	a,(hl)
	cp	c
	jr	z,findc2
	inc	d
	inc	hl
	djnz	findcl
	xor	a
	inc	a
	ld	a,c
findc2:	pop	bc
	ret
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Output a z-char in A.
;
abbrev:	defb	0	;nonzero if expanding an abbreviation
dalpha:	defb	0	;Default alphabet number
alpha:	defb	0	;Alphabet number
shift:	defb	0	;Under shift conditions?
multi:	defb	0	;In multi-char sequence?
multw:	defw	0	;The character to create in multi-char sequence.
;
op_zchar:
	push	af
	push	bc
	push	de
	push	hl
	ld	c,a
	ld	a,(multi)
	or	a
	jr	nz,nabb2	;If in a multi-byte char, don't try to
	ld	a,(abbrev)	;expand it as an abbreviation
	or	a
	jp	nz,opabb

	ld	a,(zver)
	cp	3
	jr	c,nabb1
	ld	a,c
	cp	1	;1,2,3 are abbreviation characters
	jr	z,abbr
	cp	2
	jr	z,abbr
	cp	3
	jr	z,abbr	
	jr	nabb2
;
nabb1:	cp	2
	jr	c,nabb2
abbr:	ld	a,c
	ld	(abbrev),a	
	jp	popd
;
nabb2:	ld	a,c	;A = packed char
	call	zchar2
	jp	popd	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Expand abbreviation string - A is 1st character, C is second
;
opabb:	dec	a	;<< v0.02 thoroughly rewritten
	rlca
	rlca
	rlca
	rlca
	rlca		;A = (Z - 1) * 32
	and	60h
	add	a,c	;A = (Z - 1) * 32 + X
	ld	c,a
	ld	b,0	;BC = abbreviation no.
	push	bc
	ld	hl,18h
	ld	e,0
	call	ZXPKWI	;BC = base of abbreviation table
	pop	hl

	xor	a
	ld	(abbrev),a	;Reset "expand abbreviation" flag

	add	hl,hl
	add	hl,bc

	ld	e,0
	call	ZXPKWI	;BC = address of abbreviation string
	ld	h,b	;     (word address, so in the bottom 128k)
	ld	l,c
	ld	a,h
	add	hl,hl	;Convert to byte address
	bit	7,a
	ld	e,0
	jr	z,abblp	
	inc	e	;High byte of address

abblp:	call	ZXPKWI
	push	de
	push	hl
	push	bc
	ld	a,b
	rrca
	rrca
	and	01Fh
	call	op_zchar	;Recursive call. 
	ld	a,b		;According to the Z-Spec, an abbreviation
	rlca			;cannot contain other abbreviations.
	rlca			;But since Curses (R12) tries to print
	rlca			;abbreviations containing abbreviations,
	and	18h		;we have to support it.
	ld	b,a		;Otherwise, these calls would be to zchar2.
	ld	a,c
	rlca
	rlca
	rlca
	and	7
	or	b
	call	op_zchar	;Recursive call.
	ld	a,c
	and	1Fh
	call	op_zchar	;Recursive call.
	pop	bc
	pop	hl
	pop	de
	bit	7,b
	jr	z,abblp
	call	rshift	;Swallow any "packing" shift characters
	jp	popd	;>> v0.02	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Output a Z-char, which we know isn't an abbreviation
;
zchar2:	push	hl
	push	bc
	ld	l,a
	ld	a,(multi)
	or	a
	jp	nz,xmult
	ld	a,l
	cp	8
	jp	nc,zch0
	ld	h,0
	add	hl,hl
	ld	bc,chartbl
	add	hl,bc
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	jp	(hl)
;
zch6:	ld	l,a
	ld	a,(alpha)
	cp	2
	jr	nz,zch0a
	ld	a,1
	ld	(multi),a
	jr	zcret	
	
zch0:	ld	l,a
zch0a:	ld	a,(alpha)
	or	a
	ld	de,al0
	jr	z,xlet
	ld	de,al1
	dec	a
	jr	z,xlet
	ld	de,al2
	ld	a,(zver)
	cp	1
	jr	nz,xlet
	ld	de,al2a
xlet:	ld	h,0
	add	hl,de
	ld	l,(hl)
	ld	h,0
	call	ll_zchr
zcret:	call	rshift
zcr1:	pop	bc
	pop	hl
	ret
;
rshift:	push	af		;Reset shifts
	xor	a
	ld	(shift),a
	ld	a,(dalpha)
	ld	(alpha),a
	pop	af
	ret
;
;;;;;;;;;;;;;;;;;;;;;;
;
;Special handlers for the first 8 characters
;
chartbl:
	defw	zch0, zch1, zch2, zch3, zch4, zch5, zch6, zch0
;
zch1:	ld	hl,0dh		;Z-char 1 is a newline in v1
	call	ll_zchr	
	jp	zcret
;
zch2:	ld	a,(dalpha)	;Z-char 2: shift to next alphabet
	inc	a
	cp	3
	jr	c,zch2a
	xor	a
zch2a:	;ld	(dalpha),a	;<< v0.02 >> this is a shift not a lock
	ld	(alpha),a
	jp	zcr1	
;
zch3:	ld	a,(dalpha)	;Z-char 3: shift to prev alphabet
	dec	a
	jr	z,zch2a
	ld	a,2
	jr	zch2a
;
zch4:	ld	(shift),a	;Z-char 4: shift to alphabet 1 (3+)
	ld	a,(zver)	;or next alphabet (1,2)
	cp	3
	jr	c,zch4a
	ld	a,1
	ld	(alpha),a
	jp	zcr1
;
zch4a:	ld	a,(alpha)	;Shift lock to next alphabet
	inc	a
	cp	3
	jr	c,zch4b
	xor	a
zch4b:	ld	(alpha),a
	ld	(dalpha),a	;<< v0.02 >> this is the shift lock
	jp	zcr1
;
zch5:	ld	(shift),a	;Z-char 5: Shift to alphabet 2 (3+)
	ld	a,(zver)	;or previous alphabet (1,2)
	cp	3
	jr	c,zch5a
	ld	a,2
	ld	(alpha),a
	jp	zcr1
;
zch5a:	ld	a,(alpha)	;Shift lock to previous alphabet
	dec	a
	jr	nc,zch4b
	ld	a,2
	jr	zch4b
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Alphabets
;		;0123456789abcdef0123456789abcdef
al0:	defb	' *****abcdefghijklmnopqrstuvwxyz'
al1:	defb	' *****ABCDEFGHIJKLMNOPQRSTUVWXYZ'
al2:	defb	' ******'
	defb	0dh
	defb	'0123456789.,!?_#'
	defb	027h
	defb	'"/\-:()'
al2a:	defb	' ******0123456789.,!?_#'
	defb	027h
	defb	'"/\<-:()'
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Create a multi-byte char. A = 1 or 2; L = character
;
xmult:	dec	a
	jr	nz,xmult2
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	(multw),hl
	ld	a,2
	ld	(multi),a
	jp	zcret
;
xmult2:	ld	a,l
	ld	hl,(multw)
	or	l
	ld	l,a
	call	ll_zchr
	xor	a
	ld	(multi),a
	jp	zcret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;
;This code handles buffering and streamed output. Initialise...
;
inibuf:	ld	hl,buffer	;Initialise buffers and streams
	ld	(bufptr),hl
	ld	hl,0
	ld	(bufcc),hl
	ld	(bufcs),hl
	ld	a,1
	ld	(bufmde),a
	ld	hl,t3ptr
	ld	(t3ptr),hl
	scf
	xor	a
	ld	(strm3),a
	ld	(strm4),a
	inc	a
	ld	(strm1),a
	ld	hl,21h
	call	ZXPK64	;Screen width
	ld	(buf_maxw),a
	ld	a,1
	ld	(cwin),a
	ld	hl,34h	;<< v0.04 support alphabet table
	ld	e,0
	call	ZXPKWD	;Get alphabet table address
	ld	a,b
	or	c
	scf
	ret	z	;Default
	ld	h,b
	ld	l,c
	ld	de,al0+6
	ld	b,26	;Values for alphabet 0
	call	mcpy
	ld	de,al1+6
	ld	b,26	;For alphabet 1
	call	mcpy
	ld	de,al2+8
	inc	hl	;For alphabet 2 (skip nos. 6 & 7)
	inc	hl
	ld	b,24
	call	mcpy
	scf
	ret
;
mcpy:	call	ZXPK64
	ld	(de),a
	inc	hl
	inc	de
	djnz	mcpy
	ret 		;>> v0.04

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Write the buffer contents to screen
;
flush_buf:
	push	af
	push	bc
	push	de
	push	hl
;
;The buffer contains a word and some separators. See if the whole lot will fit.
;
	ld	hl,buffer	;<< v0.02
	ld	a,(bufcc)
	ld	b,a
	ld	a,(bufcs)
	ld	c,a
	call	ZXBFIT
	cp	2
	jr	c,flushm	;Yes, it will.
	ld      hl,0Dh		;No. Write CR; then the whole lot.
        call    char_out        ;Write character
	xor	a		;Change stacked AF to 0, Z set
flushm: or	a		;A = 0: flush all. A = 1: print text, not 
				;separators
	ld	hl,(bufcc)
	jr	nz,flush0
	ld	de,(bufcs)
	add	hl,de
flush0:	ld	bc,buffer	;HL = count of chars to print
	ld	(bufptr),bc
	ld	bc,0
	ld	(bufcs),bc	;Reset buffer counters
	ld	(bufcc),bc
	ld	a,(bufmde)
	or	a
	jr	z,flush1
	ld	a,1
	ld	(bufmde),a
flush1: ld	b,h	;BC = no. of bytes to print. See if it will fit
	ld	c,l	;within the margin
	ld	de,buffer
flushlp:
	ld	a,b
	or	c
	jp	z,popd
	dec	bc
	ld	a,(de)
	ld	l,a
	inc	de
	ld	a,(de)
	ld	h,a
	inc	de
	push	de
	push	bc
	call	char_out
	pop	bc
	pop	de
	jr	flushlp
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Passed a character in HL, decide where it goes.
;
ll_zchr:	
	ld	a,(strm3)	;To stream 3?
	or	a
	jp	z,strm_gen
;
;Write to stream 3
;
	push	hl
	ld	hl,(t3ptr)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)	;DE = address of table
	ld	h,d
	ld	l,e	;HL = address of table
	call	peek64
	ld	b,a
	inc	hl
	call	peek64
	ld	c,a	;BC = length of text so far
	inc	hl
	add	hl,bc
	ex	(sp),hl	
	ld	a,l	;A = byte to write
	ex	(sp),hl		
	call	ZXPOKE
	inc	bc
	ex	de,hl	;DE = address of table
	ld	a,b
	call	ZXPOKE
	inc	hl
	ld	a,c
	call	ZXPOKE
	pop	hl
	scf	
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Returns Carry set if character in L is a separator
;
issep:	ld	a,l
	cp	21h
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Write character in HL to its streams, taking account of buffering
;
strm_gen:
	ld	a,(cwin)	;Top window?
	or	a
	jp	z,char_out
	ld	a,(bufmde)	;bufmde is: 1 when reading non-separators
	or	a		;           2 when reading separators
	jp	z,char_out	;           0 if not buffered
	cp	2
	jr	nz,bufapp	;Append non-separator
	call	issep
	call	nc,flush_buf	;Next word; flush the buffer
bufapp: ld	a,l	
	cp	0Dh		;Newline, flush the buffer.
	jp	z,bufnl
	push    hl		;Append character in HL to the buffer.
        ex      de,hl
        ld      hl,(bufptr)
        ld      (hl),e
        inc     hl
        ld      (hl),d		;Character buffered.
        inc     hl
	ld	(bufptr),hl
	ex	de,hl
        call    issep		;Was it a separator?
        jr      c,isep
        ld      hl,(bufcc)
        inc     hl
        ld      (bufcc),hl
	jr	ckover
;
isep:	ld	hl,(bufcs)
	inc	hl
	ld	(bufcs),hl
	ld	a,2
	ld	(bufmde),a
;
;Check for buffer overflow. This happens when: 
;
ckover:	pop	hl	;The character.
;
;* There are <width> non-separators in the buffer.
;
	call	ZXGETX	
	ld	l,a	;L = total screen width
	ld	a,(bufcc)
	ld	c,a
	cp	l	;Screen width
	ccf
	jp	c,flush_buf
;
;* There are <width> separators in the buffer.
;	
	ld	a,(bufcs)
	ld	b,a
	cp	l
	ccf
	jp	c,flush_buf
;
;* There are <width> characters in the buffer in total.
;  (doing it separately avoids overflow on very wide screens :-) )
;
	ld	a,b
	add	a,c
	cp	l
	ret	c
	scf
	jp	flush_buf
;
bufnl:	call	flush_buf
	ld	hl,0dh
;
;Fall through to char_out
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Write a character in HL to its streams, with no buffering
;
char_out:
	ld	a,(strm1)
	or	a
	push	hl
	ld	a,1		;Stream 1
	call	nz,ZXZCHR
	ld	hl,11h		;FLAGS2
	call	ZXPK64
	bit	0,a		;transcripting?
	pop	hl
	ld	a,2		;Stream 2
	scf			;<< v0.04 support printer abort. If ZXZCHR
	call	nz,ZXZCHR	;        returns carry clear, turn off 
	ret	c		;        printer output and reset the
	jp	ts_off		;        transcript bit.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Select output stream.
;
ll_strm:
	cp	3
	jr	z,sets3
	cp	0FDh
	jp	z,usets3
	bit	7,a
	jr	z,strmon

strmoff:push	af	;Deactivate a stream
	neg
	dec	a
	ld	hl,strm1
	ld	e,a
	ld	d,0
	add	hl,de
	ld	(hl),0	
	pop	af
	cp	0FEh		;Transcript
	jp	nz,ZXSTRM
	call	ZXSTRM
	jr	c,ts_off
	jp	ts_err
;
strmon: push	af		;Activate a stream
	dec	a
	ld	hl,strm1
	ld	e,a
	ld	d,0	
	add	hl,de
	ld	(hl),1
	pop	af
	cp	2
	jp	nz,ZXSTRM
	call	ZXSTRM
	jr	c,ts_on
	jp	ts_err

ts_on:	ld	hl,11h
	call	ZXPK64
	or	1
	call	ZXPOKE
	scf
	ret
;
ts_off:	ld	hl,11h
	call	ZXPK64
	res	0,a
	call	ZXPOKE
	scf
	ret	
;
sets3:	ex	de,hl	;DE = data address
	ld	a,(strm3)
	cp	16
	ld	hl,s3err
	ret	nc
	ld	hl,(t3ptr)	;Open a stream 3.
	dec	hl
	ld	(hl),d
	dec	hl
	ld	(hl),e
	ld	(t3ptr),hl
	ld	a,(strm3)
	inc	a
	ld	(strm3),a
;
; << v0.04  Reset the "count" to 0 when the stream is selected
;
	ex	de,hl
	xor	a
	call	ZXPOKE
	inc	hl
	xor	a
	call	ZXPOKE
	dec	hl	
	ex	de,hl
;
; >> v0.04
;
	ld	a,3
	jp	ZXSTRM
;
usets3:	ld	a,(strm3)
	or	a
	scf			;Close a stream 3.
	ret	z
	dec	a
	ld	(strm3),a
	ld	hl,(t3ptr)
	inc	hl
	inc	hl
	ld	(t3ptr),hl
	ld	a,0FDh
	jp	zxstrm
;
;Numeric data.
;
cwin:	defb	0	;Current output window no.
bufmde: defb    0       ;Buffered?
buffer: defs    512     ;Wordwrap buffer
bufptr: defw    0       ;Pointer into same
bufcc:	defw	0	;No. of non-separator chars
bufcs:	defw	0	;No. of separator chars
table3: defs	32      ;Table stack for stream 3 to use
t3ptr:	defw	0	;Pointer into the table stack
strm1:  defb    1       ;Stream 1 (screen) active?
strm2:	defb	0	;Stream 2 (transcript) active? (Not used)
strm3:  defb    0       ;Stream 3 (memory) active?
strm4:	defb    0       ;Stream 4 (scripting) active?
buf_maxw:
	defb	0	;Screen width
s3err:	defb	'O Stream 3 nestin'	;Stream 3 nested too deeply.
	defb	0E7h	;'g'+80h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; << v0.04 Validate an input character in A. Invalid characters become " "
;
valid_char:
	cp	8
	ret	z
	cp	13
	ret	z
	cp	27
	ret	z
	cp	32
	jr	c,valid_c2
	cp	127
	ret	c
	cp	129
	jr	c,valid_c2
	cp	251
	ret	c
valid_c2:
	ld	a,' '
	ret
;
; >> v0.04

