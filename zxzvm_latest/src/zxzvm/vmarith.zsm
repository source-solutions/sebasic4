
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Arithmetic operations:
;
;neg* : Calculate 2's complement of a 16-bit register
;abs* : Ensure a 16-bit register is +ve
;
abshl:	bit	7,h
	ret	z
neghl:	push	af	
	ld	a,h	;To ones complement
	cpl
	ld	h,a
	ld	a,l
	cpl	
	ld	l,a
	inc	hl	;To twos complement
	pop	af
	ret
;
absde:	bit	7,d
	ret	z
negde:  push    af
        ld      a,d     ;To ones complement
        cpl
        ld      d,a
        ld      a,e
        cpl
        ld      e,a
        inc     de      ;To twos complement
        pop     af
        ret
;
absbc:	bit	7,b
	ret	z
negbc:  push    af
        ld      a,b     ;To ones complement
        cpl
        ld      b,a
        ld      a,c
        cpl
        ld      c,a
        inc     bc      ;To twos complement
        pop     af
        ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Signed 16-bit comparison
;
cpsign:
;
;If HL < DE, return Carry set. If HL >= DE, return Carry clear. If HL=DE
;return Zero set.
;
;Check if one is -ve and the other positive
;
	ld	a,h
	xor	d	;If the sign bits were different, bit 7 of A is set
	bit	7,a
	jr	nz,dsign
;
;Signs are the same. 
;
; << v1.01 Do not reverse the comparison if both values are negative. 
;         (In 2s-complement, 0FFFFh (-1) > 0FFFDh (-3) )   
;
;        So just fall through to the unsigned comparison. 
; >>
;
cphlde:	
cpusgn: ld	a,h
	cp	d
	ret	nz
	ld	a,l
	cp	e	
	ret	
;
cpdebc:	ld	a,d
	cp	b
	ret	nz
	ld	a,e
	cp	c
	ret
;
dsign:	bit	7,h	;Is HL the negative one?
	scf
	ret	nz	;If so, HL < DE. Return NZ C
ncnz:	xor	a
	inc	a	;Force NZ
	ret		;Otherwise, HL >= DE. Return NZ NC
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Signed 16-bit multiplication, BC * DE -> DE 
;
mult16:	push	af
	push	bc
	push	hl
	call	m16w
	pop	hl
	pop	bc
	pop	af
	ret
;	
m16w:	ld	a,b
	xor	d
	bit	7,a	;Negative * positive
	jr	nz,mixmult
	call	absde
	call	absbc
	jr	umult16
;
mixmult:
	call	absde
	call	absbc
	call	umult16
	jp	negde
;
;Unsigned 16-bit multiplication, HLDE := BC * DE
;
umult16:
	ld	hl,0
	ld	a,16	;16-bit multiplication
umulta:	bit	0,e
	jr	z,umultb
	add	hl,bc
umultb:	srl	h
	rr	l
	rr	d
	rr	e
	dec	a
	jr	nz,umulta
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Compute BC mod DE, returns result in HL.
;
smod16:	push	de
	push	bc	
	call	mo16w
	pop	bc
	pop	de
	ret
;
mo16w:	call	absde	;a mod (-b) == a mod b
	bit	7,b	;(-a) mod b == - (a mod b)
	jr	z,udiv16
	call	absbc
	call	udiv16
	jp	neghl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Divide BC by DE, returns result in BC.
;
sdiv16:	push	de
	push	hl
	call	d16w
	pop	hl
	pop	de
	ret
;
d16w:	ld	a,b		;Same sign, or opposite signs?
	xor	d
	bit	7,a
	jr	nz,mixdiv
	call	absde
	call	absbc
	jr	udiv16
	
mixdiv:	call	absde
	call	absbc
	call	udiv16
	ret	nc
	call	negbc	
	scf
	ret
;
udiv16:	ld	a,d	;Divides BC by DE. Gives result in BC, remainder in HL.
	or	e	
	ret	z	;Return NC if dividing by 0
	ld	hl,0
	ld	a,16
udiv1:	scf
	rl	c
	rl	b
	adc	hl,hl
	sbc	hl,de
	jr	nc,udiv2
	add	hl,de
	dec	c
udiv2:	dec	a
	jr	nz,udiv1
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;<< v0.03 overhauled
;
;
;Random number generator...
;
rmode:	defb	0	;0: pseudo-random  1:counting 1-n  
rseed:	defw	0
rlast:	defw	0
;
;Seed with a randomish number
;
srandr:	call	ZXRNDI	;Get some randomish number
	ld	a,r
	xor	d
	ld	d,a	;DE = randomish number
	ld	(rseed),de
	xor	a
	ld	(rmode),a
	ld	(rlast),de
	ret
;
;Seed with a fixed number (-HL)
;
srand:	call	abshl
	ld	(rseed),hl
	ld	de,1000
	call	cphlde
	ld	a,1
	jr	c,srand1
	inc	a	
srand1:	ld	(rmode),a
	ld	hl,0
	ld	(rlast),hl
	ret
;
random:	bit	7,h		;If HL negative, set predictable mode
	jr	nz,srand	;
	ld	a,h		;If HL 0, seed from random number
	or	l	
	jr	z,srandr
	ld	a,(rmode)	;Mode 1: Generate random number by stepping
	dec	a
	jr	z,steprnd
;
;Conventional pseudo-random-number generator
;
;Using the algorithm: Add 1; multiply by 75; extract MOD 65537; subtract 1
;                     and 32-bit arithmetic
;
	push	hl		;HL = max value (0 < result <= HL)
	ld	hl,(rseed)
pred0:	ld	de,0		;DEHL = value
;
;Add 1 to DEHL.
;
	inc	hl
	ld	a,h
	or	l
	jr	nz,pred1
	inc	de
pred1:
;
;Multiply by 75. 75 = 64+8+2+1...
;
	push	de
	push	hl	;1xDEHL
	call	dblhde	;*2
	push	de
	push	hl	;2xDEHL
	call	dblhde	;*4
	call	dblhde	;*8
	push	de
	push	hl	;8xDEHL
	call	dblhde	;*16
	call	dblhde	;*32
	call	dblhde	;*64
	call	addpop	;+X*8 = X*72
	call	addpop	;+X*2 = X*74
	call	addpop	;+X   = X*75
;
;Extract modulo 65537 (0x10001). 
;
modlp:	ld	a,e
	cp	1
	jr	c,end655	;If it's under 0x10000, it's under 0x10001
	jr	nz,sub655	;If it's above 0x1FFFF, it's above 0x10001
	ld	a,h		;0x10000 <= DEHL <= 0x1FFFF
	or	a
	jr	nz,sub655	;If it's above 0x100FF, it's above 0x10001
	ld	a,l		;0x10000 <= DEHL <= 0x100FF
	cp	2
	jr	c,end655	;If it's <= 0x10001, return
;
;Subtract 65537 from DEHL...
;
sub655:	dec	de
	dec	hl
	jr	modlp
;
end655:
;
;Subtract 1
;
	dec	hl
	ld	(rseed),hl
	ld	b,h
	ld	c,l
;
;BC = number (16-bit). Reduce modulo parameter
;
	res	7,b
	pop	de
	call	smod16
	inc	hl		;<<v0.03>> value is 0 < n <= max
				;          not      0 <=n < max
	scf
	ret			;Return value in HL.



steprnd:
	push	hl
	ld	bc,(rlast)	;Stepping 1,2, ... seed
	inc	bc
;
;BC = number candidate
;
	ld	de,(rseed)
	call	smod16		;BC := BC mod (seed)
	ld	(rlast),hl
	pop	de
	ld	b,h
	ld	c,l
	res	7,b
	call	smod16		;Reduce mod parameter
	inc	hl		;0 < x <= param
	scf
	ret
;
;Double DEHL
;
dblhde:	sla	l
	rl	h
	rl	e
	rl	d
	ret
;
addpop:	pop	bc	;return address
	ld	(apret+1),bc
	pop	bc	;To add to the low word
	add	hl,bc
	pop	bc	;To add to the high word
	ex	de,hl
	adc	hl,bc
	ex	de,hl
apret:	jp	0
;

; >> v0.03
