
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
;Dictionary operations. Most of these functions are hand-compiled
;from those in jzip.
;
d_addr:	defw	0	;Address of the dictionary
toksrc:	defw	0	;Source string
tokdst:	defw	0	;Destination string
tokdct:	defw	0	;Dictionary
punct:	defs	16	;Punctuation
seps:	defb	9,10,12,13,' .,?'
tokpc:	defb	0	;Punctuation count
tokcp:	defw	0	;Pointer to characters
toktp:	defw	0	;Pointer to tokens
tokmax:	defb	0	;Max tokens allowed in line
tokesz:	defb	0	;Entry size
tokdsz:	defw	0	;Dictionary size
tokchp:	defw	0	;chop
tokwi:	defw	0	;word index
tokln:	defb	0	;Token length
tokptr:	defw	0	;Token pointer
tokflg:	defb	0	;Flag
encbuf:	defs	32	;Word encoding buf
llen:	defb	0	;Length of the line
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Check if the character in C is an interpreter-defined 'separator' character
;
cksepa:
	push	hl
	push	bc
	ld	b,8
	ld	hl,seps
	jr	ckpn1
;
;Check if the character in C is a game-defined 'punctuation' character
;
ckpunct:
	push	hl
	push	bc
	ld	a,(tokpc)
	or	a
	jr	z,ckpn
	ld	b,a	;Count of special punctuation characters
	ld	hl,punct
ckpn1:	ld	a,(hl)
	cp	c
	scf		;Carry set if found.	
	jr	z,ckpn	
	inc	hl
	djnz	ckpn1
	xor	a	;Carry reset, not found.
ckpn:	pop	bc
	pop	hl
	ret
;
;next_token - based on the eponymous routine in jzip
;
;HL->string. Returns tokln = token length; tokptr -> token base
;
next_token:
;
;Set the token length to zero
;
	xor	a
	ld	(tokln),a	
;
;Step through the string looking for separators 
;
nt1:	ld	a,(llen)
	or	a		;End of line, reached by counting
	ret	z
	call	peek64		
	or	a
	ret	z		;End of line, reached by 0-termination
	ld	c,a		;C = current character
;
;Look for game specific punctuation
;
	call	ckpunct		;Returns Carry set if C is punctuation
	jr	nc,nt2
;
;If a separator is found then return the information.
;If length has been set, then just return the word position
;
	ld	a,(tokln)
	or	a
	ret	nz
;
;Else set length and token pointer
;
	inc	a
	ld	(tokln),a
	ld	(tokptr),hl

	inc	hl
	call	dllen
	ret
;
; Look for statically defined separators last
;
nt2:	call	cksepa
	jr	nc,nt3
;
;If length has been set then return the word position
;
	ld	a,(tokln)
	or	a
	jr	z,nt99	;<< v0.02 >> Skip it, and don't increment length

	inc	hl
	call	dllen
	ret
;
;If 1st token character then remember its position
;
nt3:	ld	a,(tokln)
	or	a
	jr	nz,nt4
	ld	(tokptr),hl
nt4:	inc	a
	ld	(tokln),a

nt99:	inc	hl
	call	dllen
	jp	nt1
;
;Decrement LLEN
;
dllen:	push	af
	push	hl
	ld	hl,llen
	dec	(hl)
	pop	hl
	pop	af
	ret
;
;Tokenise text at Z-address HL to buffer DE. BC->dictionary
;
;Based on tokenise_line() in jzip.
;
tokenise:
	ld	(tokflg),a	;A = flag parameter
	ld	a,b
	or	c
	jr	nz,tok1
	ld	bc,(d_addr)	;BC = dict parameter
tok1:	ld	(toksrc),hl	;HL = z-address of line
	ld	(tokdst),de	;DE = z-address of output
	ld	a,255
	ld	(llen),a
	ld	a,(zver)
	cp	5
	jp	c,tok4
	inc	hl
	call	peek64
	ld	(llen),a
tok4:	inc	hl	;HL -> words
	ld	(tokcp),hl
	ex	de,hl
	call	peek64
	ex	de,hl	;Max. tokens
	ld	(tokmax),a
	inc	de
	inc	de	;DE -> destination
	ld	(toktp),de
	ld	ix,0	;IX = word count
	ld	h,b
	ld	l,c	;HL->dictionary

	call	peek64	;No. of punctuation characters

	push	af
	push	hl
	cp	10h
	jr	c,tok5
	ld	a,10h
tok5:	ld	b,a	;Punctuation count
	ld	(tokpc),a	
	inc	hl
	ld	de,punct
tok6:	call	peek64	;Read the punctuation characters
	ld	(de),a
	inc	hl
	inc	de
	djnz	tok6
	xor	a
	ld	(de),a
	pop	hl
	pop	af
	inc	hl
	ld	e,a
	ld	d,0
	add	hl,de	;HL ->entry lengtha

	call	peek64
	ld	(tokesz),a	
	inc	hl
	call	peek64
	ld	b,a	
	inc	hl
	call	peek64	;Dictionary size
	ld	c,a
	ld	(tokdsz),bc
	inc	hl
	ld	(tokdct),hl	;Start of dictionary proper
;
;Calculate the binary chop start position
;
	ld	bc,(tokdsz)
	srl	b
	rr	c
	ld	hl,1	;Chop value
tok7:	ld	a,b
	or	c
	jr	z,tok8
	srl	b
	rr	c
	add	hl,hl
	jr	tok7
;
tok8:	ld	(tokchp),hl
;
;Tokenise
;
tok9:	ld	hl,(tokcp)
	call	next_token
	ld	(tokcp),hl
	push	ix		;C = word count
	pop	bc
	ld	a,(tokln)	;Length=0 => EOL
	or	a
	jp	z,tok99
	ld	hl,(tokdst)	;Max words
	call	peek64
	cp	c		;If C >= A, ok.
	jp	c,tok99
;	
tok10:	ld	a,(tokln)
	ld	hl,(tokptr)
	ld	de,(tokchp)
	call	find_word	;BC := word no.
	ld	hl,(toktp)
	ld	a,(tokflg)
	or	a
	jr	z,tok11
	ld	a,b
	or	c
	jr	z,tok12
tok11:	ld	a,b
	call	ZXPOKE
	inc	hl
	ld	a,c
	call	ZXPOKE
	inc	hl
	jr	tok14
;
tok12:	inc	hl
	inc	hl
tok14:	
	ld	a,(tokln)
	call	ZXPOKE
	inc	hl
	push	hl
	ld	hl,(tokptr)
	ld	de,(toksrc)
	and	a
	sbc	hl,de
	ld	a,l
	pop	hl
	call	ZXPOKE
	inc	hl
	ld	(toktp),hl
	inc	ix	;Word count
	jp	tok9

tok99:	push	ix
	pop	bc	;C=no. of words
	ld	hl,(tokdst)
	inc	hl
	ld	a,c
	call	ZXPOKE
;
;Diagnostic
;
	scf
	ret	
;
fwlen:	defb	0
fwchp:	defw	0
fwadd:	defw	0
;
;Compare encrypted words at DE and z-address HL, length 4 or 6 bytes.
;
cpenc:	ld	b,4		;Returns: Zero set if words match
	ld	a,(zver)	;Carry set if word at DE is less than at HL.
	cp	4
	jr	c,cpenc1
	ld	b,6
cpenc1:	call	peek64		;Get from Z-memory
	ld	c,a
	ld	a,(de)
	cp	c		;
	ret	nz
	inc	hl
	inc	de
	djnz	cpenc1
	xor	a
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
fwoffs:	
;
;HL := (tokwi * tokesz) + tokdct
;
	push	af
	push	de
	ld	hl,(tokdct)
	ld	de,(tokwi)
	ld	a,(tokesz)
fwolp:	add	hl,de
	dec	a
	jr	nz,fwolp
	pop	de
	pop	af
	ret	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Limit tokwi to 0 <= tokwi < abs(tokdsz)
;
limit_wi:
	push	hl
	push	de
	ld	hl,(tokwi)
	bit	7,h
	jr	nz,limw1
	ld	de,(tokdsz)
	call	absde
	and	a
	sbc	hl,de
	jr	c,limw2
	dec	de
	ld	(tokwi),de
	pop	de
	pop	hl
	ret	
	
limw1:	ld	hl,0	
	ld	(tokwi),hl
limw2:	pop	de
	pop	hl
	ret
;
dtok:	push	af
	push	bc
	push	de
	push	hl
	ld	b,a
dtok1:	call	peek64
	push	bc
	cp	20h
	ld	e,a
	ld	c,2
	call	nc,zxfdos
	pop	bc
	inc	hl
	djnz	dtok1

	jp	popd
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;From jzip's find_word()
;
find_word:	;A=token len HL=addr DE=chop
;;;	call	dtok
	ld	(fwchp),de
	ld	(fwadd),hl
	ld	(fwlen),a
	ld	bc,(tokdsz)
	ld	a,b
	or	c
	ret	z
	ld	a,(fwlen)	;A=length
	ld	b,a
	call	encode		;to z-string at encbuf
;
	ld	hl,(fwchp)
	dec	hl
	ld	(tokwi),hl
	ld	hl,(tokdsz)	
	bit	7,h		;Dictionary size negative?
	jr	nz,dszlt0
fww1:	ld	bc,(fwchp)	;while (fwchp)
	ld	a,b
	or	c
	ret	z		;Not found
	srl	b
	rr	c	;fwchp /= 2;
	ld	(fwchp),bc
	call	limit_wi
;
	call	fwoffs	;HL := offset of word tokwi
;
	ld	de,encbuf	
	push	hl
	call	cpenc
	pop	bc
	jr	c,fww5	;Go back
	jr	nz,fww4	;Go forward
;
;We have a match!
;
	ret
;
fww4:	ld	hl,(tokwi)
	ld	bc,(fwchp)
	add	hl,bc
	ld	(tokwi),hl
	call	limit_wi
	jr	fww1
;
fww5:	ld	hl,(tokwi)
	ld	bc,(fwchp)
	and	a
	sbc	hl,bc
	ld	(tokwi),hl
	call	limit_wi
	jr	fww1

dszlt0:	call	absbc	;BC = word count
	ld	hl,0
	ld	(tokwi),hl
dszlp1:	ld	a,b
	or	c
	ret	z
	push	bc
	call	fwoffs
	ld	de,encbuf
	push	hl
	call	cpenc
	pop	bc
	jr	z,dszok
	ld	hl,(tokwi)
	inc	hl
	ld	(tokwi),hl
	pop	bc
	dec	bc
	jr	dszlp1
	
dszok:	pop	de
	ret

