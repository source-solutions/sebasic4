
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pnmask:	defb	0	;Property number mask
psmask:	defb	0	;Property size mask
;
;A lot of the code in this file has been hand-crafted from the C 
;routines in jzip 2.0.1g.
;
;Find the property list for object DE
;
propadd:		;get_property_addr()
	push	af
	push	bc
	push	de
	call	objadd
	ld	a,(zver)
	ld	bc,7
	cp	4
	jr	c,propad3
	ld	c,12
propad3:
	add	hl,bc
	ld	e,0
	call	ZXPKWI	;BC = property pointer
	ld	h,b
	ld	l,c	;HL = property pointer
	call	ipeek	;Read length of text
	ld	c,a
	ld	b,0
	add	hl,bc
	add	hl,bc	;Skip over text
	pop	de
	pop	bc
	pop	af
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;HL->property, make it point at the next property
;
propnxt:		;get_next_property()
	push	bc
	push	af
	call	ZXPK64	;Get property ID
	inc	hl
	ld	c,a
	ld	a,(zver)
	cp	4
	jr	c,pnv3	;v1-3 property has size in top 3 bits
	bit	7,c
	jr	nz,pnv4
	bit	6,c
	jr	z,pnv7
	inc	hl
	jr	pnv7

pnv4:	call	ZXPK64	;Read property size	
	and	03Fh	;Size
	jr	pnv5
;
pnv3:	ld	a,c
	and	0E0h
	rlca
	rlca
	rlca		;A = length of property - 1
pnv5:	ld	c,a
	ld	b,0
	add	hl,bc
pnv7:	inc	hl
	pop	af
	pop	bc	
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;For object DE, property BC return next property
;
gnprop: call	propadd	;HL := address of property list
	ld	a,(pnmask)
	ld	b,a
	ld	a,c
	or	a
	jr	z,gnpret
gnprop1:
	call	peek64
	and	b	;A = next property ID. Get next if A > C
	cp	c
	jr	c,gnprop2
	jr	z,gnprop3	;Found!
	call	propnxt
	jr	gnprop1
;
gnprop2:
	call	ilprint
	defb	13,10,'Warning: Property not found!$'
gnprop3:
	call	propnxt
gnpret: call	peek64
	and	b
	ld	l,a
	ld	h,0
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Get object DE, property C into HL
;
gprop:		;load_property()

	call    propadd ;HL = Address of property list
        ld      a,(pnmask)
	ld	b,a
gpr3:	call	peek64  ;Get property ID
	and     b
        cp      c
        jr      c,dprop	;Not found!
        jr      z,gpr4 ;Found!
        call    propnxt ;Next property
        jr      gpr3
;
gpr4:	ld	a,(psmask)
	ld	b,a	;Property size mask
	call	peek64
	inc	hl
	and	b	;Size = 0 (ie one byte)?
	jr	nz,rword
	call	peek64	;Read the byte
	ld	l,a
	ld	h,0
	ret

dprop:	ld	hl,(obj_addr)	;Default properties
	ld	e,c
	ld	d,0
	dec	de
	add	hl,de
	add	hl,de
rword:	ld	e,0
	call	ZXPKWI		;Read word
	ld	h,b
	ld	l,c
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Get address of object DE, property C 
;
;			;load_property_address()
gpaddr:	call	propadd	;HL = Address of property list
	ld	a,(pnmask)
	ld	b,a
gpad3:	call	peek64	;Get property ID
	and	b
	cp	c
	jr	c,gpnot	;Not found!
	jr	z,gpad4	;Found!
	call	propnxt	;Next property
	jr	gpad3
;
gpnot:	ld	hl,0
	ret
;
gpad4:	ld	a,(zver)
	cp	4
	jr	c,gpad5
	call	peek64
	bit	7,a
	jr	z,gpad5
	inc	hl
gpad5:	inc	hl
	ret
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Set object DE property C to HL
;
putprop:		;store_property()
	push	hl
        call    propadd ;HL = Address of property list	
        ld      a,(pnmask)
        ld      b,a
ppr3:   call    peek64  ;Get property ID
        and     b
        cp      c
        jp	c,proper1
        jr      z,ppr4 ;Found!
        call    propnxt ;Next property
        jr      ppr3
;
ppr4:   ld      a,(psmask)
        ld      b,a     ;Property size mask
        call    peek64
        inc     hl
        and     b       ;Size = 0 (ie one byte)?
        jr      nz,wword
	pop	de
	ld	a,e
        call    ZXPOKE  ;Read the byte
	scf
        ret

wword: 	pop	de
	ld	a,d
	call	ZXPOKE
	inc	hl
	ld	a,e
	call	ZXPOKE
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gplen:	ld	a,(psmask)	;from jzip, load_property_length()
	ld	d,a
	dec	hl	;HL -> property ID
	ld	a,(zver)
	cp	4
	jr	c,gplen3
	call	peek64
	ld	e,a
	bit	7,a
	jr	z,gplen1
	ld	a,e
	and	d
	jr	rprop
;
gplen1:	ld	hl,2
	bit	6,a
	scf
	ret	nz
	dec	hl
	scf
	ret

gplen3:	call	peek64	;Get property length in v1-v3
	and	d	;from the 3 high bits of the byte
	rlca
	rlca
	rlca
	inc	a
rprop:	ld	l,a
	ld	h,0
	ret	
