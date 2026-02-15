 
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


one_ops:	;1OP: 0     1      2      3     4         5     6       7  
	defw	 z_jz,   z_os,  z_oc,  z_op, prplen, incvar, decvar, praddr
        defw     call1s, rmobj, probj, z_rv, z_jmp,  printp, loadv,  call1n 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
z_jz:	
	ld	hl,(v_arg1)
	ld	a,h
	or	l
	jp	z,branch
	jp	nbranch
;
z_jmp:	ld	hl,(v_arg1)
	jp	pbranch
;
z_ld:	ld	a,(v_arg1)
	call	get_var
	jp	ret_hl
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Return a value
;
z_rv:	ld	hl,(v_arg1)
	jp	z_ret
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;1OP calls
;
call1s:	ld	a,1		;Call with 1 argument
	ld	(v_argc),a
	xor	a		;Call type = 0 (store return value)
	jp	call_gen
;
call1n:	ld	a,(zver)
	cp	5
	jp	c,znot
	ld	a,1		;Call with 1 argument	
	ld	(v_argc),a	;Call type = 1 (discard return value)
	jp	call_gen
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Printing calls
;
praddr:	ld	hl,(v_arg1)
	ld	e,0		;<< v0.03 >> This is a 24-bit address
	jr	printp1
;
printp:	
	ld	hl,(v_arg1)
	call	upack_addr
printp1:
	call	ZXPKWI
	call	printwrd
	bit	7,b 
	jr	z,printp1
	call	rshift
	scf
	ret
;
probj:	ld	de,(v_arg1)	;Based on jzip print_object()
	ld	a,d
	or	e
	scf			;NULL object
	ret	z	
	call	objadd		;Get address of object into HL
	ld	bc,7
	ld	a,(zver)
	cp	4
	jr	c,probj3
	ld	c,12
probj3:	add	hl,bc
	ld	e,0
	call	ZXPKWI		;BC = address
	inc	bc		;skip count byte
	ld	h,b
	ld	l,c
	jp	printp1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Increment & decrement
;
incvar: ld	a,(v_arg1)
	push	af
	call	get_var
	inc	hl
	pop	af
	call	put_var
	scf
	ret
;
decvar:	ld	a,(v_arg1)
	push	af
	call	get_var
	dec	hl
	pop	af
	call	put_var
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Getting related objects
;
z_op:	ld	de,(v_arg1)	;Parent
	ld	a,d		;<< v1.01 Object 0 errors
	or	e
	jp	z,pret0		;>> v1.01
	call	objadd
	call	read_parent
	ex	de,hl
	scf
	jp	ret_hl
;
z_oc:	ld	de,(v_arg1)	;Child
	ld	a,d		;<< v1.01 Object 0 errors
	or	e
	jr	z,condobj	;>> v1.01
	call	objadd
	call	read_child
	jr	condobj
;
z_os:	ld	de,(v_arg1)	;Sibling
	ld	a,d		;<< v1.01 Object 0 errors
	or	e	
	jr	z,condobj	;<< v1.01
	call	objadd
	call	read_sibling
condobj:
	ex	de,hl
	push	hl
	call	ret_hl
	pop	hl
	ld	a,h
	or	l
	jp	nz,branch
	jp	nbranch
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Remove object
;	
rmobj:	ld	de,(v_arg1)
	ld	a,d		;<< v1.01 Object 0 errors
	or	e
	scf
	ret	z		;>> v1.01
	call	obj_remove
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
loadv:	ld	a,(v_arg1)
	call	get_var	;HL = value of referenced variable
	scf
	jp	ret_hl
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
prplen:	ld	hl,(v_arg1)	;Property address
	call	gplen
	scf
	jp	ret_hl
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
