
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

two_ops:	;2OP: 0      1       2       3       4      5      6      7  
	defw	zbreak,   z_je,   z_jl,   z_jg, z_dck, z_ick,  z_jin, testv 
        defw      z_or,  z_and,   z_ta,   z_sa,  z_ca, store, insobj, z_ldw
        defw     z_ldb,   z_gp,  z_gpa,  z_gnp, z_add, z_sub,  z_mul, z_div 
        defw     z_mod, call2s, call2n, z_scol, throw,  fail,   fail,  fail
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;According to the Z-Machine Standards Document, 2OP:0 is possibly a debug 
;breakpoint. So let it call ZXILIV, which is the nearest thing to a 
;debug breakpoint currently in ZXZVM.
;
zbreak:
	ld	hl,(zpc)	;<< v1.01 call breakpoint with 
	ld	de,(zpc+2)	;>>       EHL = program counter
	call	ZXILIV
	scf
	ret
;
z_jg:	ld	hl,(v_arg2)
	ld	de,(v_arg1)
	call	cpsign
	jr	c,branch
	jp	nbranch
;
z_jl:	ld	hl,(v_arg1)
	ld	de,(v_arg2)
	call	cpsign
	jr	c,branch
	jp	nbranch

z_je:	ld	bc,(v_arg1)
	ld	hl,v_arg2
	ld	a,(v_argc)

cplp:	dec	a
	jr	z,nbranch
	push	af
	ld	e,(hl)
	inc	hl
	ld	d,(hl)	;DE = argument to compare with
	inc	hl
	inc	hl
	inc	hl
	call	cpdebc
	jr	z,branch1
	pop	af
	jr	cplp

branch1:
	pop	af
branch:	call	zpcipeek	;Branch argument, byte 1
	bit	7,a
	jr	z,rnbrnch	;Meaning reversed?
rbranch:
	res	7,a
	bit	6,a		;Far branch?
	jr	z,br_far
	res	6,a
;
;Near branch, offset in A
;
br_near:
	or	a
	jp	z,rfalse
	cp	1
	jp	z,rtrue
	ld	e,a
	ld	d,0
	jr	do_brnch
;
;Far branch, get offset into HL.
;
br_far: ld	h,a
	call	zpcipeek
	ld	l,a		;HL = offset
	bit	5,h		;Negative?
	jr	z,pbranch
	ld	a,h
	or	0e0h		;Extend 14-bit signed int to 16 bits. 
	ld	h,a
pbranch:
	ld	a,h		;If H is 0 (ie, offset fits in 8 bits)
	or	a		;then check for rtrue / rfalse
	ld	a,l
	jr	z,br_near
	ex	de,hl
do_brnch:       
        dec     de
        dec     de
        ld      hl,(zpc)
        ld      bc,(zpc+2)
	bit	7,d		;If backjumping, different code because
	jr	nz,backjmp	;the high word of PC rolls over differently
        add     hl,de
        jr      nc,dbrnc1
	inc	bc
	jr	dbrnc1
;
backjmp:
	add	hl,de
	jr	c,dbrnc1
	dec	bc
dbrnc1:	ld	(zpc),hl
	ld	(zpc+2),bc
	scf
	ret
;
nbranch:call	zpcipeek	;Branch argument, byte 1
	bit	7,a
	jr	z,rbranch	;Meaning reversed?
rnbrnch:
	bit	6,a
	scf
	ret	nz		;If only one byte, skip it.
	jp	zpcipeek	;Skip 2nd byte
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Arithmetic & logic operations
;
z_and:	ld	hl,(v_arg1)
	ld	de,(v_arg2)
	ld	a,h
	and	d
	ld	h,a
	ld	a,l
	and	e
	ld	l,a
	scf
	jp	ret_hl
;
z_or:	ld	hl,(v_arg1)
	ld	de,(v_arg2)
	ld	a,h
	or	d
	ld	h,a
	ld	a,l
	or	e
	ld	l,a
	scf
	jp	ret_hl
;
testv:	ld	hl,(v_arg1)
	ld	de,(v_arg2)
	ld	a,d
	and	h
	cp	d
	jp	nz,nbranch
	ld	a,e
	and	l
	cp	e
	jp	nz,nbranch
	jp	branch
;
z_add:	ld	hl,(v_arg1)
	ld	de,(v_arg2)
	add	hl,de
	scf
	jp	ret_hl
;
z_sub:	ld	hl,(v_arg1)
	ld	de,(v_arg2)
	and	a
	sbc	hl,de
	scf
	jp	ret_hl
;
z_mul:	ld	de,(v_arg1)
	ld	bc,(v_arg2)
	call	mult16
	ex	de,hl
	scf
	jp	ret_hl
;
z_div:	ld	bc,(v_arg1)
	ld	de,(v_arg2)
	call	sdiv16
	jp	nc,div0
	ld	h,b
	ld	l,c
	jp	ret_hl
;
z_mod:	ld	bc,(v_arg1)
	ld	de,(v_arg2)
	call	smod16
	jp	nc,div0
	jp	ret_hl	
;
z_dck:	ld	a,(v_arg1)	;Variable number
	push	af
	call	get_var		;value into HL
	pop	af
	dec	hl		;Decrement
	push	hl
	call	put_var		;Write back
	pop	hl
	ld	de,(v_arg2)	;Limit
	call	cpsign		;Now under limit?
	jp	c,branch
	jp	nbranch
;
z_ick:	ld	a,(v_arg1)	;Variable number
	push	af
	call	get_var		;value into HL
	pop	af
	inc	hl		;Decrement
	push	hl
	call	put_var		;Write back
	pop	de
	ld	hl,(v_arg2)	;Limit	
	call	cpsign		;Limit now < value?
	jp	c,branch
	jp	nbranch
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;get_property; get_property_addr; get_next_property
;
z_gp:	ld	de,(v_arg1)	;Get property - object DE property BC
	ld	a,d		;<< v1.01 Object 0 error avoidance
	or	e
	jr	z,pret0		;>> v1.01
	ld	bc,(v_arg2)
	call	gprop
	scf
	jp	ret_hl
;
z_gpa:	ld	de,(v_arg1)	;Get property addr - object DE
	ld	a,d		;<< v1.01 Object 0 error avoidance
	or	e
	jr	z,pret0		;>> v1.01
	ld	bc,(v_arg2)	;                    property BC
	call	gpaddr
	scf
	jp	ret_hl
;
z_gnp:	ld	de,(v_arg1)
	ld	a,d		;<< v1.01 Object 0 error avoidance
	or	e		;<< v1.04 This incorrectly returned 0
				;>> v1.04 for objects 0-255
	jr	z,pret0		;>> v1.01
	ld	bc,(v_arg2)
	call	gnprop
	scf
	jp	ret_hl
;
;<< v1.01 Results for Object 0
;
pret0:	ld	hl,0
	scf
	jp	ret_hl
;
;>> v1.01	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Setting, clearing and testing attributes
;
z_ta:	ld	de,(v_arg1)
	ld	a,d		;<< v1.01 Eliminate Object 0 error
	or	e
	jp	z,nbranch	;>> v1.01
	ld	bc,(v_arg2)
	call	attradd
	call	peek64
	and	b
	jp	nz,branch
	jp	nbranch
;
z_sa:	ld	de,(v_arg1)
	ld	a,d		;<< v1.01 Eliminate Object 0 error
	or	e
	scf
	ret	z		;>> v1.01	
	ld	bc,(v_arg2)
	call	attradd
	call	peek64
	or	b
	call	ZXPOKE
	scf
	ret
;
z_ca:	ld	de,(v_arg1)
        ld      a,d             ;<< v1.01 Eliminate Object 0 error
        or      e
        scf
        ret     z               ;>> v1.01
	ld	bc,(v_arg2)
	call	attradd
	ld	a,b
	cpl
	ld	b,a
	call	peek64
	and	b
	call	ZXPOKE
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;JIN
;
z_jin:	ld	de,(v_arg1)
	ld	a,d		;<< v1.01
	or	e		;Avoid Zero Error; if 1st operand
	jp	z,nbranch	;is 0, don't branch. >>
	call	objadd		;HL->object
	ld	a,(zver)
	cp	4
	jr	c,v3jin
	ld	de,6
	add	hl,de
	ld	e,0
	call	ZXPKWI
	ld	e,c
	ld	d,b		;DE = parent
	ld	hl,(v_arg2)
	call	cpusgn		;Unsigned compare DE,HL
	jp	z,branch
	jp	nz,nbranch
;
v3jin:	ld	de,4
	add	hl,de
	call	peek64	 ;Parent
	ld	e,a	;<< v0.04 >> Bug fix: compare A with parent, not 4!
	ld	a,(v_arg2)
	cp	e
	jp	z,branch
	jp	nbranch
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
call2n:	ld	a,2		;Call with 1 parameter, dump result
	ld	(v_argc),a
	ld	a,1
	jp	call_gen
;
call2s:	ld	a,2		;Call with 1 parameter, keep result
	ld	(v_argc),a
	xor	a
	jp	call_gen	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Load and store operations
;
z_ldb:	ld	hl,(v_arg1)
	ld	bc,(v_arg2)
	add	hl,bc
	call	peek64
	ld	l,a
	ld	h,0
	scf
	jp	ret_hl
;
z_ldw:	ld	hl,(v_arg1)	;Array
	ld	bc,(v_arg2)	;Offset
	add	hl,bc
	add	hl,bc
	ld	e,0
	call	ZXPKWI		;Read word into bc
	ld	h,b
	ld	l,c
	scf
	jp	ret_hl	
;
store:	ld	a,(v_arg1)	;Variable
	ld	hl,(v_arg2)	;Value
	scf
	jp	put_var
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
z_scol:	ld	a,(v_arg1)
	ld	b,a
	ld	a,(v_arg2)
	ld	c,a
	jp	ZXSCOL		;Set colour
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
insobj:	ld	de,(v_arg1)
	ld	hl,(v_arg2)
	ld	a,d		;<< v1.01 avoid Object 0 errors
	or	e
	scf
	ret	z
	ld	a,h
	or	l
	scf
	ret	z		;>> v1.01
	call	obj_insert
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
throw:	ld	de,(v_arg2)	;Stack frame value
	ld	hl,(zstop)
	and	a
	sbc	hl,de		;HL -> new ZSP
	ld	(zsp),hl
	ld	hl,(v_arg1)	;Return value
	jp	z_ret
;
