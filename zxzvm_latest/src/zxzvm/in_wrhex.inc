
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Write a Hex number in BCHL, CHL, HL or A to memory at DE.
;
sphex8:	ld	a,b		;Big multidecker fall-through...
	call	sphex2
sphex6:	ld	a,c
	call	sphex2
sphex4: ld      a,h
        call    sphex2
        ld      a,l
sphex2: push    af
        rrca
        rrca
        rrca
        rrca
        call    sphex1
        pop     af
sphex1: and     0fh
        cp      0ah
        jr      c,sph1a
        add     a,7
sph1a:  add     a,'0'
        ld      (de),a
        inc     de
        ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Write decimal numbers in HL to memory at DE
;
cphlbc:	push	hl
	and	a
	sbc	hl,bc
	pop	hl
	ret
;
spdec:	ld	bc,10000
	call	cphlbc
	jr	nc,spdec5
	ld	bc,1000
	call	cphlbc
	jr	nc,spdec4
	ld	bc,100
	call	cphlbc
	jr	nc,spdec3
	ld	a,l
	cp	10
	jr	nc,spdec2	;>=10
	jr	spdec1
;
spdec5:	ld	bc,10000
	call	dodec
spdec4:	ld	bc,1000
	call	dodec
spdec3:	ld	bc,100
	call	dodec
spdec2:	ld	bc,10
	call	dodec
spdec1:	ld	a,l
	add	a,'0'
	ld	(de),a
	inc	de
	ret
;
dodec:	ld	a,'0'
ddlp:	inc	a
	and	a
	sbc	hl,bc
	jr	nc,ddlp
	dec	a
	add	hl,bc
	ld	(de),a
	inc	de
	ret
;
