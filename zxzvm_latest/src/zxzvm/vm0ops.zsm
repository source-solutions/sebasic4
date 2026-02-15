
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;0OPs
;

zero_ops:	;0OP: 0   1     2      3      4       5       6        7  
	defw	rtrue,  rfalse, print, prret, no_op,  d_save, d_restr, restart
        defw    rpop,   catch,  zquit, newln, sstatus,vrfy,   fail,    piracy
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;0OP returns
;
rpop:	call	zpop	
	jr	z_ret
;
rfalse: ld	hl,0
	jr	z_ret
;
rtrue:	ld	hl,1
z_ret:	ex	de,hl	;DE = returned value
	ld	ix,(zsp)
	ld	l,(ix+0)
	ld	h,(ix+1)
	ld	(zpc),hl
	ld	l,(ix+2)
	ld	h,(ix+3)
	ld	(zpc+2),hl
	ld	l,(ix+36)
	ld	h,(ix+37)	;Routine stack pointer
	ld	(rsp),hl
	ld	a,(ix+34)	;Call type - 0 to return a result in DE
	ld	bc,38		;1 to return nothing
	add	ix,bc		;2,3 for timer interrupt returns
	ld	(zsp),ix	;Pop that frame
	cp	3
	jp	z,rchr_iret
	cp	2
	jp	z,timer_iret
	or	a
	scf
	ret	nz
	ex	de,hl		;HL = returned value
	scf
	jp	ret_hl
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
prret:  call    print		;Print_ret
        call    newln
        jp      rtrue 
;
print: 	call    zpcipeek
        ld      b,a
        call    zpcipeek
        ld      c,a             ;BC=packed word
	call	printwrd
	bit	7,b
	jr	z,print
	call	rshift
	scf
	ret
;
printwrd:
	push	bc
	ld	a,b
	rrca
	rrca
	and	1Fh
	call	op_zchar
	ld	a,b		
	rla
	rla
	rla		
	and	018h		;
	ld	b,a
	ld	a,c
	rlca
	rlca
	rlca
	and	7
	or	b
	call	op_zchar
	ld	a,c
	and	1Fh
	call	op_zchar
	pop	bc
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
newln:	ld	hl,0dh
	call	ll_zchr
	scf
	ret
;
no_op:	scf
	ret
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
zquit:	xor	a
	ld	(running),a
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
piracy: jp	branch	;Assume genuine

vrfy:	ld	hl,1ah
	ld	e,0
	call	ZXPKWD
	ld	l,c
	ld	h,b	;HL = file length
	ld	e,0
	sla	l
	rl	h
	rl	e
	ld	a,(zver)
	cp	4
	jr	c,vrfy1	;v1-3: Scale by factor of 2
	sla	l
	rl	h
	rl	e
	cp	6	;v4-v5: Scale by factor of 4
	jr	c,vrfy1	
	sla	l	;v6: Scale by factor of 8
	rl	h
	rl	e	;EHL = true file length 
vrfy1:	ld	bc,40h	;<< v0.02 >> This label moved down 3 lines, bug fix
	and	a
	sbc	hl,bc
	jr	nc,vrfy2
	dec	e
vrfy2:	push	hl	;EHL = no. of bytes to verify
	pop	bc	
	ld	d,e	;DBC = no. of bytes to verify
	call	ZXVRFY
	push	hl	;Calculated sum
	ld	hl,1ch
	ld	e,0
	call	ZXPKWI	;BC = checksum
	pop	hl	;Calculated sum
	and	a
	sbc	hl,bc
	jp	z,branch
	jp	nbranch
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
catch:	ld	a,(zver)
	cp	5
	jr	c,v1pop
	ld	hl,(zstop)	;Top of z-stack
	ld	de,(zsp)
	and	a
	sbc	hl,de		;HL = stack frame ID, independent of the
				;stack base (necessary for savefile 
				;compatability).
	scf
	jp	ret_hl
;
v1pop:	call	zpop
	scf
	ret
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
restart:
	ld	a,2
	ld	(running),a	
	scf
	ret	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;<< v0.04  show_status - draw the status line
;
sstatus:
	ld	a,(zver)
	cp	3
	scf
	ret	nz
	call	flush_buf
	ld	a,1		;1 line for status line
	call	ZXSWND
	ld	a,1
	call	ZXUWND
	ld	a,1		;Reverse on
	call	ZXSTYL	

	call	ZXGETX		;A = screen width
	ld	b,a
sblank:	push	bc
	ld	hl,' ' 
	ld	a,1
	call	ZXZCHR
	pop	bc
	djnz	sblank
	ld	bc,0101h
	call	ZXSCUR

	ld	a,10h		;1st global
	call	get_glb		;HL := object number
	ex	de,hl	
	ld	a,d		;<< v1.01 Guard against object 0 errors
	or	e
	jr	z,noloc		;>> v1.01
        call    objadd          ;Get address of object into HL
        ld      bc,7
	add     hl,bc
        ld      e,0
        call    ZXPKWI          ;BC = address
        inc     bc              ;skip count byte
        ld      h,b
        ld      l,c
	call	printp1		;Print location object
	call	flush_buf
noloc:	ld	hl,1		;<< v1.04 Flags 1 is at address 1 >>
	call	ZXPK64		;Get Flags 1, bit 1
	bit	1,a
	ld	a,':'
	ld	de,stbuf
	jr	nz,sltime
	ld	a,'/'
sltime:
	ld	(statsep),a
;
;Status contains score/turns
;
	ld	a,11h		;"Score" global
	push	de	
	call	get_glb		;Score/turns
	pop	de
	bit	7,h
	jr	z,pscore
	ld	a,'-'
	ld	(de),a
	inc	de	
	call	neghl
pscore:	call	spdec		;Done score
	ld	a,(statsep)
	ld	(de),a
	inc	de
	ld	a,12h		;"Turns" global
	push	de
	call	get_glb
	pop	de
	ld	a,(statsep)
	cp	':'		; time game?
	jr	nz,pturns
	call	spdec2		; if so, always 2 digits
	jr	pmins
pturns:	call	spdec
pmins:	ld	hl,stbuf
	ex	de,hl
	and	a
	sbc	hl,de		;L = Length of the score/turns string
	ld	b,l
	push	bc
	ld	hl,21h
	call	ZXPK64		;A=width in chars
	pop	bc
	push	bc
	sub	b		;enough characters in from the left
	ld	c,a
	ld	b,1
	call	ZXSCUR		;Right-align the score/turns	
	pop	bc
	ld	de,stbuf
	jr	ostbuf
;
ostbuf:	push	bc
	push	de	
	ld	a,(de)
	ld	l,a
	ld	h,0	
	ld	a,1
	call	ZXZCHR
	pop	de
	pop	bc
	inc	de
	djnz	ostbuf
;
	xor	a
	call	ZXSTYL
	xor	a
	call	ZXUWND
	scf
	ret
;
statsep:
	defb	'/'
stbuf:	defb	'999/9999        '
