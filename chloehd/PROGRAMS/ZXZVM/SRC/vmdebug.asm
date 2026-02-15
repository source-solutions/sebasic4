
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
;Debugging routines. These are of two kinds: 
; 
; * Routines to assist in debugging the z-machine itself. 
; * Diagnostic output should a z-program fail. 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Code for debugging the Z-machine. 
;
;This prints the text immediately following the CALL:
;
;	call ilprint
;	defb 'text'
;
ilprint:
	ex	(sp),hl	;HL -> inline parameter
	push	af
	push	bc
	push	de
	ld	d,h
	ld	e,l
	push	hl
	ld	c,9
	ld	a,(trace)
	or	a
	call	ZXFDOS
	pop	hl
ilpr1:	ld	a,(hl)
	inc	hl
	cp	'$'
	jr	nz,ilpr1
	pop	de
	pop	bc
	pop	af
	ex	(sp),hl
	ret
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;This subroutine causes a border colour change and waits for a keypress.
;It is intended to provide a simple method of tracing where the program has
;got to. 
;
;yes_i_live:
;
;<< v0.02 >> Spectrum-specific code moved to ZXIO.BIN as ZXILIV.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Print a hex number in A/BC/DE/HL/IX, and wait for a keypress.
;
hexa:	push	de
	ld	d,0
	ld	e,a
	jr	hexd1
;
hexix:	push	de
	push	ix
	pop	de
	jr	hexd1
	
hexbc:	push	de
	ld	d,b
	ld	e,c
hexd1:	call	hexde
	pop	de
	ret
;
hexhl:	ex	de,hl
	call	hexde
	ex	de,hl
	ret
;
hexde:	push	af
	push	bc
	push	de
	push	hl
	ex	de,hl
	ld	de,hbuf+4
	push	de
	call	sphex4
	pop	de
	ld	c,9
	call	zxfdos
popd:	pop	hl	;<< v0.02 This code was in yes_i_live
	pop	de	;  but has been moved
	pop	bc
	pop	af
	ret		;>>
;
showlcl:
	push	af	;<< v0.04 Show local variables 
	push	bc
	push	de
	push	hl
showl0:	push	ix
	ld	b,6
showl3:	call	ilprint
	defb	'  Locals $'
	ld	hl,(zsp)
	ld	de,4
	add	hl,de
;

showl1:	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl

	call	hexde
	call	ilprint
	defb	' $'
	djnz	showl1
showle:	call	ilprint
	defb	13,10,'$'
	pop	ix
	jr	popd

showpc:	push	af
	push	bc
	push	de
	push	hl
	ld	a,(trace)
	or	a
	jr	z,popd

spc2:	ld	hl,(zpc)
	ld	bc,(zpc+2)
	ld	de,hbuf+2
	push	de
	call	sphex6
	pop	de
	ld	c,9
	call	zxfdos

	jr	showl0	;Show local variables

	ld	de,crlf
	ld	c,9
	call	zxfdos
;;	ld	c,1
;;	call	zxfdos
	jr	popd
	
hbuf:	defb	'00000000$'
crlf:	defb	13,10,'$'
trace:	defb	0	;; Set to nonzero to enable debug trace
;
ifpc:	push	hl
	ld	hl,(zpc)
	and	a
	sbc	hl,bc
	jr	nz,ifpc0
	ld	a,(zpc+2)
	cp	d
ifpc0:	pop	hl
	ret

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routines for debugging Z-programs. 
;
; This prints the Z-machine's stack (excluding the artificial 'entry' frame).
;
showstk:
	ld	de,strace	;"Stack trace:"
	ld	c,9
	call	zxfdos
	ld	ix,(zsp)	;Bottom of stack
shows1:	call	dframe		;Dump a frame
	ld	de,38
	add	ix,de		;Reached the top yet?
	push	ix
	pop	hl
	ld	de,(zstop)
	and	a
	sbc	hl,de
	jr	nz,shows1
	ld	de,strend	;"[End of stack]"
	ld	c,9
	call	zxfdos
	ret
;
dframe:	ld	de,sfr1		;Dump a single stack frame
	ld	l,(ix+0)
	ld	h,(ix+1)
	ld	c,(ix+2)
	call	sphex6		;PC
	ld	de,sfr2
	ld	a,(ix+34)
	call	sphex2		;Call method
	ld	de,sfr3
	ld	l,(ix+36)
	ld	h,(ix+37)
	call	sphex4		;Routine stack pointer
	ld	de,sfr4
	ld	a,(ix+35)
	call	sphex2		;No. of parameters
	push	ix
	ld	de,sframe
	ld	c,9
	call	zxfdos		;Print stack frame line
	pop	ix
	ld	b,15
	push	ix
llp:	ld	de,lln
	ld	l,(ix+4)
	ld	h,(ix+5)
	push	bc
	push	ix
	call	sphex4
	ld	de,lln
	ld	c,9
	call	zxfdos
	pop	ix
	pop	bc
	inc	ix
	inc	ix
	djnz	llp
	ld	de,crlf$
	ld	c,9
	call	ZXFDOS
	pop	ix
	ret
;	
sframe:	defb	'Caller PC='
sfr1:	defb	'000000  Call type='
sfr2:	defb	'00  Routine sp='
sfr3:	defb	'0000  params '
sfr4:	defb	'00'
	defb	13,10,'$'
lln:	defb	'0000$'
strace:	defb	'Z-machine stack trace:',13,10,'$'
strend:	defb	'[End of stack]'
crlf$:	defb	13,10,'$'
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Illegal instruction error
;
fail2:	pop	de		;Pop the stack twice first
fail1:	pop	de		;Pop the stack once first
fail:	ld	hl,(zipc)
	ld	bc,(zipc+2)
	ld	de,iistr1
	call	sphex6		;PC
	ld	de,iistr
	ld	a,(inst)
	cp	0BEh		;EXT:?
	jr	nz,faila
	call	sphex2
	ld	a,(inst+1)
	call	sphex2
	ex	de,hl
	ld	(hl),13
	inc	hl
	ld	(hl),10
	inc	hl
	ld	(hl),'$'
	jr	failb
;
faila:	call	sphex2		;Opcode
failb:	ld	de,iistr0
	ld	c,9		;Print message
	call	ZXFDOS
	ld	hl,iinst
	xor	a
	ret
;
iinst:	defb	'A Illegal instructio'
	defb	0EEh			;'n'+ 80h
iistr0:	defb	'Illegal instruction at PC='
iistr1:	defb	'000000 : opcode = '
iistr:	defb	'00'
	defb	13,10,36,0,0	;The 2 zeroes allow the string to grow...
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Stack overflow error
;
spfail2:
	pop	de
spfail1:
	pop	de
spfail:	ld      hl,(zpc)
        ld      bc,(zpc+2)
        ld      de,sostr1
        call    sphex6          ;PC
        ld      a,(inst)
        ld      de,sostr
        call    sphex2          ;Opcode
        ld      de,sostr0
        ld      c,9             ;Print message
        call    ZXFDOS
        ld      hl,sover
        xor     a
        ret
;
sover:	defb	'4 Out of stac'
	defb	0EBh		;'k'+80h
sostr0: defb    'Illegal instruction at PC='
sostr1: defb    '000000 : opcode = '
sostr:  defb    '00'
        defb    13,10,36
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
proper2:
	pop	hl
proper1:
	pop	hl
properr:
	push	de	;Object no.
	push	bc	;Property no.
	ld      hl,(zpc)
        ld      bc,(zpc+2)
        ld      de,pestr1
        call    sphex6          ;PC
	pop	bc
	ld	a,c
	ld	de,pestr3
	call	sphex2
	pop	hl
	ld	de,pestr2
	call	sphex4
        ld      de,pestr
        ld      c,9             ;Print message
        call    ZXFDOS
        ld      hl,perr
        xor     a
        ret
;
perr:	defb    '2 Property not foun'
        defb    0E4h            ;'d'+80h
pestr:	defb	'Invalid property at PC='
pestr1:	defb	'000000 Object '
pestr2:	defb	'0000 property '
pestr3:	defb	'00',13,10,'$'
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Division by 0
;
div0:	ld	hl,(zpc)
	ld	bc,(zpc+2)
	ld	de,d0str1
	call	sphex6
	ld	de,d0str
	ld	c,9
	call	ZXFDOS
	ld	hl,d0err
	xor	a
	ret
;
d0str:	defb	'Division by zero at PC='
d0str1:	defb	'000000',13,10,'$'
d0err:	defb	'6 Division by zer'
	defb	0EFh	;'o'+80h
;
