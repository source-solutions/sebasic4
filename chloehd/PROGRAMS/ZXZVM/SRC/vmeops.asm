
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
;Extended operations
;
MAXEXT	EQU	0Fh	;Maximum extended opcode.
;
ext_high:
	scf		;Extended operations 128-255. 
	ret		;Entered with (inst+1) = opcode
;
ext_ops:	;0       1        2       3      4      5        6        7
	defw	d_save,  d_restr, z_srl,  z_sra, sfont, drawpic, picdata, erapic
	defw	smargin, u_save,  u_restr,pruni, ckuni, fail,    fail,    fail
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
flags2:	defb	0
;
save_magic:	;1...5...10..14  15 16
	defb	'ZXZVM savefile',1Ah,2	;(version 2)

save_hdr:
	defs	16	;Magic number
save_zpc:
	defw	0,0	;Program counter
save_mlen:
	defw	0	;DRAM length
save_slen:
	defw	0	;Z-stack length
save_rlen:
	defw	0	;Routine stack length
	defs	102	;Takes it up to 128 bytes

			;<< v1.01
filever:
	defb	0	;Savefile version - 1 if the Z-stack has not been
			;manipulated due to bug in v1.00, else 2
			;>> v1.01

d_save:	ld	a,1	;<< v0.02 >> Flag "Save as" 
	call	ZXNAME
	ex	de,hl	;DE = filename parameter
	call	ilprint
	defb	13,10,'$'
	ld	hl,abandoned ;<< v1.01 >>
	ccf		  ;<< v0.02 >> Carry-reset return here means "cancel"
	jp	c,badsave ;<< v1.01 >> Don't RET, it will send the Z-machine
		          ;           into hyperspace!
	ex	de,hl	;Restore filename parameter
	ld	b,1	;Create
	call	ZXOPEN	;Create savefile
	jp	nc,badsave
	ld	a,(v_argc)	;<< v1.00  Nasty SAVE bug in v3 games
	cp	1		;         (and maybe others) - the base
	jr	nc,d_sav0	;	  address was not being set to 0
	ld	hl,0		;         so save was from random address
	ld	(v_arg1),hl
d_sav0:	ld	a,(v_argc)	;>> v1.00
	cp	2
	jr	nc,d_sav1
	ld	hl,0eh
	ld	e,0	;Address of DRAM length
	call	ZXPKWI	;BC = DRAM length
	ld	(v_arg2),bc
d_sav1:	ld	hl,save_magic
	ld	de,save_hdr
	ld	bc,16
	ldir		;Copy magic number into header
	ld	hl,(zpc)
	ld	(save_zpc),hl
	ld	hl,(zpc+2)
	ld	(save_zpc + 2),hl
	ld	hl,(zstop)	;Top of Z-stack
	ld	de,(zsp)	;Bottom of Z-stack
	and	a
	sbc	hl,de		;HL = Z-stack length
	ld	(save_slen),hl
	ld	hl,(rstop)
	ld	de,(rsp)	;Routine stack length
	and	a
	sbc	hl,de
	ld	(save_rlen),hl
	ld	hl,(v_arg2)
	ld	(save_mlen),hl
;
;Write out the header
;
	ld	hl,save_hdr
	ld	bc,128
	call	ZXWRIT
	jp	nc,badsave
;
;Write out the memory
;
	ld	bc,(save_mlen)
	ld	hl,(v_arg1)	;Base
	call	ZXWMEM		;Write z-machine memory
	jr	nc,badsave
;
	call	fixup_stack	;Write call stack. 
	ld	bc,(save_slen)
	ld	hl,(zsp)
	call	ZXWRIT
	call	fixup_stack
	jr	nc,badsave	;Write routine stack
	ld	bc,(save_rlen)
	ld	hl,(rsp)
	call	ZXWRIT
;
	ld	b,1
	call	ZXCLSE

	ld	a,(zver)	;<< v0.04  Early versions branch if OK
	cp	4
	jp	c,branch	;>> v0.04
	scf
	ld	hl,1
	jp	ret_hl
;
ts_err:
	ld	a,(hl)
	push	hl
	push	af
	and	7fh
	ld	l,a
	ld	h,0
	ld	a,1
	call	ZXZCHR
	pop	af
	pop	hl
	inc	hl
	bit	7,a
	jr	z,ts_err
	ld	hl,0dh
	ld	a,1
	call	ZXZCHR
	scf
	ret

badsave:
	call	ts_err
	ld	b,1
	call	ZXCLSE
;
	ld	a,(zver)	;<< v0.04 Early versions branch not store
	cp	4
	jp	c,nbranch	;>> v0.04

	scf
	ld	hl,0
	jp	ret_hl
;		
d_restr:
	ld	hl,11h
	call	peek64
	ld	(flags2),a	;save low byte of flags2
	xor	a		;<< v0.02 >> "Load" rather than "Save"
	call    ZXNAME
	ex	de,hl		;DE = "name" parameter
	call	ilprint
	defb	13,10,'$'
	ld	hl,abandoned	;<< v1.01 >>
	ccf			;<< v0.02 >> Carry reset here does not abort
        jr	c,badsave	;<< v1.01 >> nor send Z-machine into hyperspace
        ld      b,0     ;Open to read
	ex	de,hl		;HL = "name" parameter
        call    ZXOPEN  ;
        jp      nc,badsave
	ld	a,(v_argc)	;<< v1.00 v3 'save' bug fix
	cp	1
	jr	nc,d_rstr0	
	ld	hl,0		;Start restoring at byte 0
	ld	(v_arg1),hl
d_rstr0:			;>> v1.00
	ld      a,(v_argc)
        cp      2
        jr      nc,d_rstr1
        ld      hl,0eh
        ld      e,0     ;Address of DRAM length
        call    ZXPKWI	;BC = DRAM length
        ld      (v_arg2),bc
d_rstr1:
	ld	hl,save_hdr
	ld	bc,128
	call	ZXREAD
	jp	nc,badsave
	ld	hl,save_hdr
	ld	de,save_magic
	ld	b,15		;<< v1.01 >> Can be v1 or v2
d_rstr2:
	ld	a,(de)
	cp	(hl)
	inc	hl
	inc	de
	jp	nz,d_rstr3
	djnz	d_rstr2
	ld	a,(hl)		;<< v1.01 Special check on savefile version
	ld	(filever),a
	or	a		;== 0
	jp	z,d_rstr3
	cp	3		;>= 3
	jp	nc,d_rstr3	;Savefile versions 1 and 2 are acceptable
				;>> v1.01
;
;Header recognised. Load Z-memory & stacks
;
	ld	a,(v_argc)
	or	a
	jp	nz,rstr_tab
        ld      bc,(save_mlen)	;Load memory
        ld      hl,0		;Base
        call    ZXRMEM          ;Read z-machine memory
        jp      nc,badsave
	ld	hl,11h
	call	ZXPK64		;get low byte of flags2
	res	0,a		;clear transcript bit
	ld	d,a
	ld	a,(flags2)	;get current flags2
	and	1		;mask transcript bit only
	or	d		;combine
	call	ZXPOKE		;set flags2 in header
;
	ld	hl,(zstop)
	ld	de,(save_slen)
	and	a
	sbc	hl,de
	ld	(zsp),hl	;We have now passed the point of no return!
				;Errors now result in game abort!
	ld	hl,(rstop)
	ld	de,(save_rlen)
	and	a
	sbc	hl,de
	ld	(rsp),hl
				;<< v1.01 don't fixup stack for v1 savefile 
	push	af
	ld	a,(filever)
	cp	1
        call    nz,fixup_stack	
	pop	af		;>> v1.01 Read call stack
        ld      bc,(save_slen)
        ld      hl,(zsp)
        call    ZXREAD
	push	af		;<< v1.01
	ld	a,(filever)	;Don't fixup stack for v1 savefile
	cp	1
	call	nz,fixup_stack	
	pop	af		;>> v1.01
	ret	nc
        ld      bc,(save_rlen)
        ld      hl,(rsp)
        call    ZXREAD
	ret	nc
	call	ZXCLSE
	ld	hl,(save_zpc)	;Returning from a successful restore.
	ld	(zpc),hl
	ld	hl,(save_zpc+2)
	ld	(zpc+2),hl
	ld	hl,2
	ld	a,(zver)	;<< v0.04 Branch if successful
	cp	4
	jp	c,branch	;>> v0.04
	scf
	jp	ret_hl
;
rstr_tab:
;
;Only load memory
;
	ld	hl,(v_arg1)
	ld	bc,(v_arg2)
	call	ZXRMEM
	jp	nc,badsave
	ld	hl,(v_arg2)
	scf
	jp	ret_hl
;
d_rstr3:
	ld	hl,badfrm
	jp	badsave
;
fixup_stack:
	push	af	;For each entry in the Z-stack, replace its RSP
	push	bc	;entry with (RSPTOP - RSP). This operation is
	push	de	;self-inverse.
	push	hl	;Doing it like this means the stack in the savefile
	push	ix	;does not depend on the local ZXZVM's setting of
	ld	ix,(zsp) ;RSPTOP.
fixup_s1:
	ld	de,(zstop)
	push	ix
	pop	bc
	call	cpdebc
	jr	z,fixend
	ld	e,(ix+36)
	ld	d,(ix+37)	;DE = associated RSP
	ld	hl,(rstop)
	and	a
	sbc	hl,de		;HL = RSP offset	
	ld	(ix+36),l	;<< v1.01 - write back the RESULT, not 
	ld	(ix+37),h	;>> v1.01   the parameter!
	ld	bc,38
	add	ix,bc
	jr	fixup_s1
;
fixend:	pop	ix
	jp	popd
;
badfrm:	defb	'Not a ZXZVM savefile'
	defb	0AEh			;'.'+80h
;
abandoned:
	defb	'Operation abandoned'
	defb	0AEh			;'.'+80h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;ZXZVM does not support Undo in this incarnation. We can't guarantee
;enough memory in the target computer to hold the RAMsaved undo image.
;
;Possibly in the future this could be implemented (some PCWs have enough
;memory) but the speed hit might be too much for a 3.5MHz Z80 to take.
;
u_save:	ld	hl,0ffffh	;RAMsave failed
	scf
	jp	ret_hl
;
u_restr:
	ld	hl,0		;RAM restore failed
	scf
	jp	ret_hl	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
z_srl:	ld	hl,(v_arg1)	;logical shift
	ld	bc,(v_arg2)
	bit	7,b
	jr	nz,z_srlr
z_srll:	add	hl,hl
	dec	c
	jr	nz,z_srll
z_srlm:	scf
	jp	ret_hl
;
z_srlr:	res	7,h
	call	absbc
z_srlt:	srl	h
	rr	l
	dec	c
	jr	nz,z_srlt
	jr	z_srlm
;
;Arithmetic shift
;
z_sra:	ld	hl,(v_arg1)
	ld	bc,(v_arg2)
	bit	7,b
	jr	z,z_srll
	call	absbc
z_srar:	srl	h
	rr	l
	bit	6,h
	jr	nz,z_srat
	set	7,h
z_srat:	dec	c
	jr	nz,z_srar
	scf
	jp	ret_hl
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;set_font
;
sfont:	call	flush_buf	;<< v1.02 >> Flush buffers before
	ld	a,(v_arg1)	;changing fonts
	call	ZXSFNT
	ld	l,a
	ld	h,0
	scf
	jp	ret_hl
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;v6 routines (no-ops)
;
erapic:
drawpic:
smargin:
	scf
	ret
picdata:	
	jp	nbranch
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Unicode routines
;
pruni:	ld	hl,(v_arg1)
	ld	a,h
	or	a
	scf
	ret	nz	;Only allow ASCII characters to print
	jp	prchar	
;
ckuni:	ld	de,(v_arg1)
	ld	hl,0
	ld	a,d
	or	a
	jr	nz,ckunie
	set	0,l
	ld	a,e
	cp	128
	jr	nc,ckunie
	set	1,l	
ckunie: scf
	jp	ret_hl


