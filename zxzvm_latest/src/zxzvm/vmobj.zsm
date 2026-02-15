
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;A lot of the code in this file has been hand-crafted from the
;C routines in JZIP 2.0.1g
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
obj_addr:
	defw	0	;Object table address
objlen:	defw	0	;Length of 1 object
ptlen:	defw	0	;Length of default property table

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Get address of object DE into HL.
;
objadd:	push	de	;get_object_address()
	push	bc
	push	af
	ld	a,d	;<< v1.01 Check for Vile 0 Error. It should have been
	or	e	;        caught earlier but this is the last defence.
	call	z,v0efh	;>> v1.01
	ld	hl,(obj_addr)
	ld	bc,(ptlen)	;Default property table length
	add	hl,bc		;HL -> start of objects
	push	hl
	ld	bc,(objlen)	;BC = object length, DE = object number 
	dec	de		;DE was 1 based
	call	umult16		;DE:= offset to object
	pop	hl
	add	hl,de
	pop	af
	pop	bc
	pop	de
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Locate attribute BC in object DE.
;
attradd:
	push	bc
	call	objadd	;HL:=object address
	pop	bc
	ld	a,c	;A=attribute number
	rrca
	rrca
	rrca		;Divide by 8, giving offset in bytes
	and	7	;Remove the bits which went round to the top
	ld	e,a
	ld	d,0
	add	hl,de
;
;Create a bitmask 
;
mkmask: ld      a,c
        and     7       ;Attribute number
        ld      b,80h
mkms1:  ret     z
        srl     b
        dec     a
        jr      mkms1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;For HL->object, read/write its parent, child, siblings
;
read_child:
	push	bc
	ld	bc,060Ah	;B=offset for v1-v3; C=offset for v4-v8
	jr	oread
;
write_child:
	push	bc
	ld	bc,060Ah
	jr	owrite
;
read_sibling:
	push	bc
	ld	bc,0508h
	jr	oread
;
write_sibling:
	push	bc
	ld	bc,0508h
	jr	owrite
;
read_parent:
	push	bc
	ld	bc,0406h
oread:	ld	a,(zver)	
	cp	4
	jr	c,oreadb
	ld	b,0
	add	hl,bc
	ld	e,0
	call	ZXPKWI
	ld	d,b
	ld	e,c
	pop	bc
	ret
;
oreadb:	ld	c,b
	ld	b,0
	add	hl,bc
	call	peek64
	ld	e,a
	ld	d,0
	pop	bc
	ret
;
write_parent:	
	push	bc
	ld	bc,0406h
owrite:	ld	a,(zver)
	cp	4
	jr	c,owriteb
	ld	b,0
	add	hl,bc
	ld	a,d
	call	ZXPOKE
	inc	hl
	jr	owritee
;
owriteb:
	ld	c,b
	ld	b,0
	add	hl,bc
owritee:
	ld	a,e
	call	ZXPOKE
	pop	bc
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Remove object DE from its container
;
obj_remove:
	push	bc
	push	hl
	push	de
	call	objadd
	ld	a,d		;<< v1.01 Vile 0 Error?
	or	e
	jp	z,remret	;>> v1.01

	ld	(objptr),hl
	call	read_parent
	ld	a,d
	or	e
	jp	z,remret	;Object already removed
	call	objadd
	ld	(objpar),hl	;HL -> parent
	call	read_child	;DE = no. of 1st child
	pop	bc	
	push	bc		;BC = no. to remove
	call	cpdebc		;Are they the same?

	jr	nz,remv1
	ld	hl,(objptr)
	call	read_sibling	;DE = object's sibling

	ld	hl,(objpar)
	call	write_child
	jr	remv2
;
;DE = number of current child object. BC = number to delete.
;
remv1:	call	objadd		;HL -> current child
	push	hl		;<< v0.02 bug fix >>
	call	read_sibling	;DE = sibling of current child
	pop	hl		;<< v0.02 bug fix >>
	
	call	cpdebc		;Is this object's sibling the one to remove?
	jr	nz,remv1
	push	hl
	ld	hl,(objptr)
	call	read_sibling

	pop	hl
	call	write_sibling
remv2:	ld	hl,(objptr)
	ld	de,0
	push	hl
	call	write_sibling
	pop	hl
	call	write_parent
remret:	pop	de
	pop	hl
	pop	bc
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Insert object DE in object HL.
;
objptr:	defw	0	;Points to object being removed or inserted
objpar:	defw	0	;Parent of object being removed or inserted
objpno:	defw	0	;Number of new parent object

obj_insert:
	ld	(objpno),hl	;Number of new parent
	call	obj_remove	;Remove object DE from where it was

	ld	a,d		;<< v1.01 Vile 0 Error?
	or	e
	scf
	ret	z		;>> v1.01

	push	de		;Sets objptr but not objpar
	ex	de,hl
	call	objadd
	ld	(objpar),hl	;so set objpar here
;
;Get number of new parent's 1st child, set it to current object's sibling
;
	push	hl
	call	read_child	;New parent's 1st child
	ld	hl,(objptr)
	push	hl
	call	write_sibling
	pop	hl
;
;Tell the object about its new parent
;
	ld	de,(objpno)
	call	write_parent
	pop	hl
;
;Set new parent's child to new object
;
	pop	de	
	jp	write_child
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;<< v0.02
;
;Print data for object DE (debugging code)
;
obtree:	push	af
	push	bc
	push	de
	push	hl
	call	ilprint
	defb	'Object $'
	call	hexde

	call	objadd	;HL -> the object
obtr0:	push	hl

	call	ilprint
	defb	' @ $'
	call	hexhl

	call	ilprint
	defb	13,10,'Siblings: $'

siblp:	call	read_sibling
	call	hexde
	ld	a,d
	or	e
	jr	z,obtr1
	call	objadd
	call	ilprint
	defb	'[$'
	call	hexhl
	call	ilprint
	defb	'] $'
	jr	siblp

obtr1:	call	ilprint
	defb	13,10,'Children: $'
	pop	hl
	call	read_child
chlp:	call	hexde
	ld	a,d
	or	e
	jr	z,obtr2
	call	objadd
	call	ilprint
        defb    '[$'
        call    hexhl
        call    ilprint
        defb    '] $'
	call	read_sibling
	jr	chlp

obtr2:	call	ilprint
	defb	13,10,'$'
	jp	popd
;
; >> v0.02
; << v1.01
;
v0efh:	nop
	call	ilprint
	defb	'WARNING: This story file has attempted to access object 0.'
	defb	13,10
	defb	'The story file may behave unpredictably, or you may need '
	defb	13,10
	defb	'an updated version of the story file.'
	defb	13,10,'$'

	push	af
	push	de
	ld	a,(zpc+2)
	call	hexa
	ld	de,(zpc)
	call	hexde

	ld	a,0C9h	;RET - only show the message once.
	ld	(v0efh),a
	pop	de
	pop	af
	ret	
;
; >> v1.01
;
