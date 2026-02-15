
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

;
;Code for accessing variables
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Parse a VAR: instruction into arg1,arg2,arg3,arg4
;
v_arg1:	defw	0,0
v_arg2:	defw	0,0
v_arg3:	defw	0,0
v_arg4:	defw	0,0
v_arg5:	defw	0,0
v_arg6:	defw	0,0
v_arg7:	defw	0,0
v_arg8:	defw	0,0
v_argc:	defb	0
;
g_addr:	defw	0	;Address of global variables
r_offs:	defw	0	;Offset to routines (v6/7)
s_offs:	defw	0	;Offset to strings (v6/7)
;
zapargs:
	push	af	;Set v_arg1 upto v_argc (inclusive) to zero
	push	bc
	push	de
	push	hl
	ld	hl,v_arg1
	ld	d,h
	ld	e,l
	inc	de
	ld	bc,v_argc-v_arg1
	xor	a
	ld	(hl),b
	ldir
	jp	popd
;
parse_v2:		;Parse arguments for 8-arg functions. B holds 1st type
			;byte, C holds second
	ld	a,b
	push	bc
	call	parse_var
	pop	bc
	ld	a,c
	ld	b,4		;DE is still set correctly from 
	ld	ix,v_arg5	;last time round the loop
	jr	parlp
;			
parse_var:
;
;A = arg type byte
;
	ld	b,4
	ld	e,b
	ld	ix,v_arg1
	push	af
	xor	a
	ld	d,a
	call	zapargs
	ld	(v_argc),a
	pop	af
parlp:	rlca
	rlca
	push	af
	push	de
	push	bc
	and	3
	ld	l,a
	push	hl
	call	parse_type
	pop	hl
	pop	bc
	pop	de
	ld	a,l	
	cp	3
	jr	z,endpar
	ld	a,(v_argc)
	inc	a
	ld	(v_argc),a
	pop	af
	add	ix,de
	djnz	parlp	
	scf
	ret
;
endpar:	pop	af
	scf
	ret
;
parse_type:
	ld	l,a
	ld	h,0	;HL = 0-3
	add	hl,hl	;*2
	ld	de,parse_tbl
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	jp	(hl)
;
parse_tbl:
	defw	p_word
	defw	p_byte
	defw	p_var
	defw	p_none
;
;Get byte / word / variable arguments from an instruction.
;
p_none:	ret
;
p_byte:	push	af
	call	zpcipeek
	ld	(ix+0),a
	ld	(ix+1),0
	pop	af
	ret
;
p_word:	push	af
	call	zpcipeek	;Switch to little-endian
	ld	(ix+1),a
	call	zpcipeek
	ld	(ix+0),a
	pop	af
	ret
;
p_var:	push	af
	call	zpcipeek
	call	get_var
	ld	(ix+0),l
	ld	(ix+1),h
	pop	af
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Parse a 2OP instruction. 
;
parse_2op:
	ld	ix,v_arg1
	ld	a,(inst)	;Argument type is part of the instruction
	bit	6,a		;Type of 1st argument
	call	nz,p_var	
	call	z,p_byte
	ld	ix,v_arg2
	bit	5,a
	call	nz,p_var
	call	z,p_byte
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Parse a 1OP instruction.
;
parse_1op:
	ld	ix,v_arg1
	ld	a,(inst)
	cp	0A0h
	call	nc,p_var
	ccf
	ret	c
	cp	90h
	call	nc,p_byte
	ccf
	ret	c
	call	p_word
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Return a value in HL
;
ret_hl:
	call	zpcipeek
	ret	nc
put_var:
	cp	10h		;Write value in HL to
	jr	nc,put_glb	;variable number A
	or	a
	jp	nz,put_lcl
zpush:	push	ix
	ld	ix,(rsp)
	dec	ix
	ld	(ix+0),h
	dec	ix
	ld	(ix+0),l
	ld	(rsp),ix
	pop	ix
	scf
	ret
;
put_glb:
	ex	de,hl	;DE = value to store
        sub     10h
        ld      h,0
        ld      l,a     ;Var no.
        ld      bc,(g_addr)
        add     hl,hl
        add     hl,bc   ;Z-address
	ld	a,d
	call	ZXPOKE	;In big-endian format
	call	ZXPK64
	cp	d
	jr	nz,put_g1
	inc	hl
	ld	a,e
	ld	d,a
	call	ZXPOKE
	call	ZXPK64
	cp	d	
	scf
        ret	z
put_g1:	call	ilprint
	defb	13,10,'Memory write has failed! HL=$'
	call	HEXHL
	ld	e,d
	ld	d,0
	call	ilprint
	defb	' Expected $'
	call	hexde
	call	ilprint
	defb	' Got $'
	call	hexa
	call	ilprint
	defb	13,10,'$'
	ld	c,1
	call	zxfdos
	xor	a
	ld	hl,memerr
	ret
;
put_lcl:
	ex	de,hl	;DE=value
        ld      hl,(zsp)
        ld      bc,4
        add     hl,bc   ;Start of local vars area
        dec     a
        ld      c,a
        ld      b,0
        add     hl,bc
        add     hl,bc
        ld      (hl),e
        inc     hl
        ld      (hl),d
	scf
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Get the contents of a variable
;
get_var:
	cp	10h
	jr	nc,get_glb
	or	a
	jr	nz,get_lcl
zpop:	push	ix		;Pop the Z-stack
	ld	ix,(rsp)
	ld	l,(ix+0)
	inc	ix
	ld	h,(ix+0)
	inc	ix
	ld	(rsp),ix
	pop	ix
	ret
;
get_glb:
	sub	10h
	ld	h,0
	ld	l,a	;Var no.
	ld	de,(g_addr)
	add	hl,hl
	add	hl,de	;Z-address
	ld	e,0
	call	ZXPKWD
	ld	h,b
	ld	l,c
	ret
;	
get_lcl:		;Get a local variable
	ld	hl,(zsp)
	ld	bc,4
	add	hl,bc	;Start of local vars area
	dec	a
	ld	e,a
	ld	d,0
	add	hl,de
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Unpack a packed Z-address (HL -> EHL)
;
upack_table:
	defw	upack0
	defw	upack1, upack2, upack3, upack4
	defw	upack5, upack6, upack7, upack8

upack_addr:
	jp	0
;
upack1:
upack2:
upack3:	push	bc
	ld	b,1
	jr	upack_g
;
upack4:
upack5: push    bc
        ld      b,2
        jr      upack_g
;
upack8:	push	bc
	ld	b,3
upack_g:
	ld	e,0
upack_l:
	sla	l
	rl	h
	rl	e
	djnz	upack_l
	pop	bc
	ret
;
upack0:
upack6:
upack7:	ld	de,never
	ld	c,9
	call	zxfdos
	ld	c,1
	call	zxfdos
	rst	0	;Must never happen :-)
;
never:	defb	'You should never see this message!'
	defb	13,10,36

