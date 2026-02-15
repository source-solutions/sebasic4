
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ctype:	defb	0	;Call type of current call operation (0/1/2/3)
			;0 => CALL_VS (store return value)
			;1 => CALL_VN (discard return value)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
var_ops:	;VAR:0         1         2      3        4       5      6    7	
	defw	call_fv, zstorew, zstoreb,zpprop,  zread, prchar, prnum,z_rand
	defw	zput,    zpull,   split_w, sel_w,call_fv, erase_w,erase_l,setcur
	defw	getcpos, style,   sbfmde,  ostrm,  istrm, sfx,    rchr, scantbl
	defw	znot,    call_pv, call_pv, ztok, zencode, cpytab, prtbl,ck_arg
;
call_pv:
	ld	a,1	  ; Call type 1
	jr	call_gen
;
callfv2:
        ld      b,8
        ld      hl,v_arg1
lp2:    ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        inc     hl
        inc     hl
        djnz    lp2

call_fv:
	xor	a
call_gen:
	ld	(ctype),a	;Set call type
	ld	hl,(v_arg1)	;Packed routine address

	ld	a,h
	or	l		;<< v0.04 Return false if HL = 0
	jr	nz,call_g1	
				;<< v1.12 Don't return anything if we are
				;   discarding the result 
	ld	a,(ctype)
	or	a
	scf
	jp	z,ret_hl	;   Type 0: Discard result
	ret			;   Type 1: Just return
				;>> v1.12

call_g1:			;>> v0.04

	call	upack_addr	;Unpack it
	call	ipeek
	ld	b,a		;B = no. of local variables
	ld	a,(v_argc)
	dec	a	
	ld	c,a		;C = no. of parameters
	cp	b		;If C <= B, ok
	jr	c,cfv1
	jr	z,cfv1
	ld	c,b		;Ignore surplus parameters
cfv1:	push	hl
	push	de		;EHL -> start of routine
	call	mkframe
	jp	nc,spfail2
	push	hl
	pop	ix		;IX -> new frame
	ld	hl,(zpc)
	ld	(ix+0),l
	ld	(ix+1),h
	ld	hl,(zpc+2)
	ld	(ix+2),l
	ld	(ix+3),h	;Old ZPC into frame
	ld	(ix+35),c	;No. of parameters
	ld	a,c
	or	a
	jr	z,noarg
	push	ix
	ld	hl,v_arg2
arglp:	ld	a,(hl)		;Args copied into frame
	ld	(ix+4),a
	inc	hl
	inc	ix
	ld	a,(hl)
	ld	(ix+4),a
	inc	ix
	inc	hl
	inc	hl
	inc	hl
	dec	c
	jr	nz,arglp
	pop	ix	
noarg:	ld	hl,(rsp)
	ld	a,(ctype)
	ld	(ix+34),a	;Procedure, function or interrupt?
	ld	(ix+36),l
	ld	(ix+37),h	;Routine stack pointer
	pop	hl
	ld	(zpc+2),hl
	pop	hl		;New ZPC
	ld	(zpc),hl
	ld	a,(zver)	;<< v0.04 support for v3-style calls
	cp	5		;<< v1.10 v4 uses v3-style calls >>
	ccf
	ret	c		;v1-v4: Set up the initial values of locals
        ld      hl,(v_arg1)     ;Packed routine address
        call    upack_addr      ;Unpack it
        call    ipeek
	or	a
	scf
	ret	z		;No locals
        ld      b,a             ;B = no. of local variables
	ld	hl,(zsp)
	ld	de,4
	add	hl,de		;HL->local vars
	ld	a,(v_argc)	;A = no. of parameters (which override the
				;initial values)
	ld	d,a		;D = no. of parameters
argl:	push	bc
	call	zpcipeek	;Get default parameter into BC
	ld	b,a
	call	zpcipeek
	ld	c,a	
	ld	a,d
	dec	d
	jr	z,argl1		;Argument was provided. Skip.
	inc	hl
	inc	hl
	jr	argl2
;
argl1:	inc	d		;To counterbalance the dec d above, so that
	ld	(hl),c		;the test works the next time round
	inc	hl		;Copy in the initial values, flipping them
	ld	(hl),b		;to little-endian as we go
	inc	hl
argl2:	pop	bc
	djnz	argl	
	scf
	ret			;>> v0.04
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ck_arg:	ld	ix,(zsp)
	ld	a,(v_arg1)	;Argument number to check
	cp	(ix+35)		;No. of arguments
	jp	z,branch
	jp	c,branch	;If A <= no. of args, it is provided.
	jp	nbranch		;Not provided.	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Push and pop...
;
zput:	ld	hl,(v_arg1)
	call	zpush
	scf
	ret
;
zpull:	call	zpop		;HL = value
	ld	a,(v_arg1)	;A = variable number
	scf
	jp	put_var
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
zstorew:
	ld	hl,(v_arg1)
	ld	de,(v_arg2)
	add	hl,de
	add	hl,de
	ld	bc,(v_arg3)
	ld	a,b
	call	trap_poke	; << v0.03 >> trap writes to location 11h
	inc	hl
	ld	a,c
	jr	trap_poke	; << v0.03 >> trap writes to location 11h
;
zstoreb:
	ld	hl,(v_arg1)
	ld	de,(v_arg2)
	add	hl,de
	ld	a,(v_arg3)
;
;<< v0.03 If there's a write to Flags 2 (at address 11h) then flush buffers
;
trap_poke:
	push	af
	ld	a,h
	or	a
	jr	nz,trap1
	ld	a,l
	cp	11h
	jr	nz,trap1
	push	hl
	call	flush_buf
	call	ZXUSCR	
	pop	hl
trap1:	pop	af
	call	ZXPOKE
	scf
	ret
;
; >> v0.03
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;
zpprop:	ld	de,(v_arg1)	;DE = object no.
	ld	a,d		;<< v1.01
	or	e
	scf
	ret	z		;>> v1.01 Object 0 errors
	ld	bc,(v_arg2)	;C  = property no.
	ld	hl,(v_arg3)	;HL = value
	jp	putprop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Screen operations. These mostly map directly to ZXIO functions
;
erase_w:
	call	flush_buf
	ld	a,(v_arg1)
	jp	ZXERAW
;
erase_l:
	ld	a,(v_arg1)
	dec	a
	scf
	ret	nz
	call	flush_buf
	jp	ZXERAL
;
split_w:
	call	flush_buf
	ld	a,(v_arg1)
	jp	ZXSWND

sel_w:	call	flush_buf
	ld	a,(v_arg1)
	xor	1
	ld	(cwin),a
	xor	1
	jp	ZXUWND
;
getcpos:
	call	flush_buf
	call	ZXGETX
	push	hl
	call	ZXGETY
	ex	de,hl
	pop	bc
	ld	d,0	;DE = Y
	ld	b,0	;BC = X
	ld	hl,(v_arg1)
	ld	a,b
	call	ZXPOKE
	inc	hl
	ld	a,c
	call	ZXPOKE
	inc	hl
	ld	a,d
	call	ZXPOKE
	inc	hl
	ld	a,e
	call	ZXPOKE
	scf
	ret	
;
style:	call	flush_buf
	ld	a,(v_arg1)
	jp	ZXSTYL
;
setcur:	call	flush_buf
	ld	a,(v_arg1)
	ld	b,a
	ld	a,(v_arg2)
	ld	c,a
	jp	ZXSCUR
;
prchar:	ld	hl,(v_arg1)
	call	ll_zchr
	scf
	ret
;
sbfmde:	ld	a,(v_arg1)	;Set buffer mode
	ld	(bufmde),a
	or	a
	call	z,flush_buf
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
prnum:
	ld	de,numbuf
	ld	hl,(v_arg1)
	bit	7,h	;Negative?
	jr	z,prnum1
	ld	a,'-'
	ld	(de),a
	inc	de
	call	neghl
prnum1:	call	spdec
	ld	a,'$'
	ld	(de),a
	ld	de,numbuf	
opbuf:	ld	a,(de)
	cp	'$'
	scf
	ret	z
	ld	l,a
	ld	h,0
	push	de
	call	ll_zchr
	pop	de
	inc	de
	jr	opbuf	

numbuf:	
	defb	'-00000$'
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Text entry interrupt...
;
tr_a1:	defw	0
tr_a2:	defw	0
tr_a3:	defw	0
tr_a4:	defw	0	;Arguments
;
timer:	defb	0	;In the timer already?
;
rch_timer:
	ld	c,3	;Timer called from read_char
	ld	de,(v_arg3)
	ld	(tr_a3),de
	ld	hl,(v_arg4)
	ld	(tr_a4),hl
	ld	a,(timer)
	or	a
	ret	nz
	inc	a
	ld	(timer),a
	jr	rch_t1
;
timer_int:
	ld	c,2	;Timer called from read_line
	ld	a,(timer)
	or	a
	ret	nz
	inc	a
	ld	(timer),a
;
;DE = routine, HL = time	
;
	ld	(tr_a3),hl
	ld	(tr_a4),de
rch_t1:	ld	hl,(v_arg1)
	ld	(tr_a1),hl
	ld	hl,(v_arg2)
	ld	(tr_a2),hl
	ld	(v_arg1),de	;Routine address
	ld	a,1
	ld	(v_argc),a
	pop	hl		;Return address, we don't use this.
	ld	a,c
	jp	call_gen
;
rchr_iret:
	ld	hl,(tr_a1)
	ld	(v_arg1),hl
	ld	hl,(tr_a2)
	ld	(v_arg2),hl
	ld	hl,(tr_a3)
	ld	(v_arg3),hl
	ld	a,3
	ld	(v_argc),a
	ld	a,(timer)
	dec	a
	ld	(timer),a	
	ld	a,d
	or	e
	jp	z,rchr
	ld	hl,0
	scf
	jp	ret_hl
;		
timer_iret:
	ld	hl,(tr_a1)
	ld	(v_arg1),hl
	ld	hl,(tr_a2)
	ld	(v_arg2),hl
	ld	hl,(tr_a3)
	ld	(v_arg3),hl
	ld	hl,(tr_a4)
	ld	(v_arg4),hl
	ld	a,4
	ld	(v_argc),a
	ld	a,(timer)
	dec	a
	ld	(timer),a
	ld	a,d
	or	e
	jr	nz,iterm
;
;The input routine wants the z-program to have printed its data for it again
;after a return from a timer interrupt...
;
	ld	hl,(v_arg1)
	inc	hl
	call	peek64	;Length of line
	or	a
	jr	z,zread
	ld	b,a
	ld	a,(zver)
	cp	5
	jr	nc,iplp1
iplp4:	call	peek64	;<< v1.10 reprint input line in the v4 model
	or	a
	jp	z,sreadt	;Reprint the line
	inc	hl
	push	hl
	push	bc
	ld	l,a
	ld	h,0
	call	ll_zchr
	pop	bc
	pop	hl
	jr	iplp4	;>> v1.10 end reprint input line

iplp1:	inc	hl
	call	peek64	;Print it
	push	hl
	push	bc
	ld	l,a
	ld	h,0
	call	ll_zchr
	pop	bc
	pop	hl
	djnz	iplp1
	jr	zread	
;
;Terminate input at once...
;
iterm:	ld	hl,(v_arg1)	;Input buffer
	call	peek64
	ld	b,a		;B = no. of bytes
	inc	b		;+1 for length
	xor	a
ztlp:	inc	hl	
	call	ZXPOKE		;Zap the buffer
	djnz	ztlp
	jr	aread2
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Reading text
;
zread:	ld	a,(zver)
	cp	5
	jr	c,sread
aread:	ld	hl,(v_arg1)
	ld	a,(v_argc)
	ld	de,0
	cp	3
	jr	c,aread1
	ld	de,(v_arg3)
aread1:	call	flush_buf
	call	ZXINP	;Input line
	ld	a,b
	or	a	;Timeout
	jr	nz,aread2
	ld	hl,(v_arg3)	;Timeout
	ld	a,h
	or	l
	jr	z,aread2
	ld	de,(v_arg4)
	ld	a,d	
	or	e
	call	nz,timer_int	;This function only returns if unsuccessful.
aread2:
	push	bc		;<< v1.11 >> save result from read op
	ld	hl,(v_arg1)	;<< v0.04 remove invalid characters 
	inc	hl		;Length
	call	ZXPK64		;A = actual length
	or	a
	jr	z,areadw	;No length?
	ld	b,a
areadv:	inc	hl
	call	ZXPK64		;Character
	call	valid_char
	call	ZXPOKE
	djnz	areadv		;>> v0.04
areadw: ld	hl,0dh
	call	ll_zchr
	ld	hl,(v_arg2)
	ld	a,h
	or	l
	jr	z,nopse
;
;Tokenise?
;
	ld	bc,0
	ld	a,c
	ld	hl,(v_arg1)
	ld	de,(v_arg2)
	call	tokenise
	
nopse:	pop	hl		;Returned keystroke
	ld	l,h
	ld	h,0
	scf
	jp	ret_hl
;
;<< v0.04 read for v3
;
;I'm going to do v3 input by converting the input format to v5-style before,
;and back afterwards. There's enough room, because the 1 byte for length 
;matches the 1-byte terminator.
;
sreadt:	call	sstatus		;<< v1.10 rewritten for timer events in v4
	call	line_from_v5
	ld	hl,(v_arg1)
	jr	sreads

sread:	call	sstatus
	ld      hl,(v_arg1)
	inc	hl
	xor	a
	call	ZXPOKE		;Write current length = 0 (no passed data)
	dec	hl
sreads: ld      de,0	
	ld	a,(zver) 
	cp	4
	jr	c,sreadu
        ld      a,(v_argc)
        ld      de,0
        cp      3
        jr      c,sreadu
        ld      de,(v_arg3)	;>> v1.10

sreadu:	call    flush_buf	;
        call    ZXINP		;Input line

	push	bc		;<< v1.10
	call	line_to_v5
	pop	bc		;>> v1.10

        ld      a,b		;<< v1.10 Handle timeouts in v4 input
        or      a      		;Timeout
        jr      nz,sreadr
        ld      hl,(v_arg3)     ;Timeout
        ld      a,h
        or      l
        jr      z,sreadr
        ld      de,(v_arg4)
        ld      a,d
        or      e
        call    nz,timer_int    ;This function only returns if unsuccessful.
				;>> v1.10

sreadr:	ld      hl,0dh
        call    ll_zchr
;
; << v1.10 >> v5 -> v4 line converter was here 
;
sread1:	ld      hl,(v_arg2)
        ld      a,h
        or      l
	scf
	ret	z
;
;Tokenise?
;
        push    bc
        ld      bc,0
        ld      a,c
        ld      hl,(v_arg1)
        ld      de,(v_arg2)
        call    tokenise
        pop     bc
	scf
	ret
;>> v0.04
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Read a character
;
rchr:	ld	a,(v_argc)
	cp	2
	ld	de,0
	jr	c,rchr1
	ld	de,(v_arg2)
rchr1:	call	flush_buf
	call	ZXRCHR
	or	a
	call	z,rch_timer
	call	valid_char
	ld	l,a
	ld	h,0
	scf
	jp	ret_hl
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Output and input streams
;
ostrm:	ld	a,(v_arg1)
	ld	hl,(v_arg2)
	jp	ll_strm
;
istrm:	ld	a,(v_arg1)
	ld	hl,(v_arg2)
	scf		;Instruction has no effect
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
sfx:	ld	hl,(v_arg1)
	ld	de,(v_arg2)
	ld	bc,(v_arg3)
	call	ZXSND
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
z_rand:	ld	hl,(v_arg1)
	call	random
	scf
	jp	ret_hl
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
znot:	ld	hl,(v_arg1)
	ld	a,h
	cpl
	ld	h,a
	ld	a,l	
	cpl	
	ld	l,a
	scf
	jp	ret_hl
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Tokenise & encode text
;
ztok:	ld	a,(v_arg4)
	ld	hl,(v_arg1)
	ld	de,(v_arg2)
	ld	bc,(v_arg3)
	jp	tokenise
;
zencode:
	ld	hl,(v_arg1)	;Text in
	ld	de,(v_arg3)	;offset
	add	hl,de
	ld	a,(v_arg2)
	ld	b,a
	call	encode
	ld	a,(encptr)
	ld	hl,(v_arg4)	;Destination	
	ld	de,encbuf
zenc1:	or	a
	scf
	ret	z
	push	af		;Transfer 3 Z-characters
	ld	a,(de)
	ld	b,a
	call	ZXPOKE
	inc	hl
	inc	de
	ld	a,(de)
	ld	c,a
	call	ZXPOKE
	inc	hl
	inc	de
	pop	af
	sub	3		;3 characters moved
	ret	c
	jr	zenc1
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Scan table for byte or word pattern
;
scantbl:
	ld	a,(v_argc)
	cp	4
	ld	a,82h
	jr	c,scant1
	ld	a,(v_arg4)
scant1:	bit	7,a
	jr	z,scanbyt
	and	7Fh	;<< v1.10: Only bits 0-7 are entry size >>
	ld	e,a
	ld	d,0	;DE = step between table entries
	ld	bc,(v_arg3)
	ld	hl,(v_arg2)
scanw1:	
	push	de
	call	peek64
	ld	d,a	
	inc	hl
	call	peek64
	ld	e,a	;DE = word from table
	dec	hl
	push	hl
	ld	hl,(v_arg1)
	call	cphlde
	pop	hl
	pop	de
	jr	z,tmatch
	add	hl,de
	dec	bc
	ld	a,b
	or	c
	jr	nz,scanw1
	jr	tnmatch
;
scanbyt:
	ld	e,a
	ld	d,0		;DE = step between table entries
	ld	bc,(v_arg3)	;Table length
	ld	hl,(v_arg2)
scanb1:	push	de
	call	peek64
	ld	e,a
	ld	a,(v_arg1)
	cp	e	;Byte to find
	pop	de
	jr	z,tmatch
	add	hl,de
	dec	bc
	ld	a,b
	or	c
	jr	nz,scanb1
tnmatch:
	ld	hl,0
	call	ret_hl
	jp	nbranch
;
tmatch:	call	ret_hl
	jp	branch
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Copy_table
;
cpytab:	ld	hl,(v_arg2)	;Destination
	ld	a,l
	or	h
	jr	z,zerotab
	ld	de,(v_arg1)	;Source
	ld	bc,(v_arg3)	;Count
	ld	a,b		;<< v1.11
	or	c		;If count=0 (vacuous) do nothing
	scf			;rather than copy 64k bytes.
	ret	z		;>> v1.11
	bit	7,b
	jr	nz,fwdcpy
;
;If source < dest, use backward copy
;
	call	cphlde
	jr	c,fwdcpy
bwdcpy:	add	hl,bc
	ex	de,hl
	add	hl,bc
	ex	de,hl
bcpylp:	dec	de
	dec	hl
	ex	de,hl
	call	peek64
	ex	de,hl
	call	zxpoke
	dec	bc
	ld	a,b
	or	c
	jr	nz,bcpylp
	scf
	ret
;
fwdcpy:	call	absbc
fcpylp:	ex	de,hl
	call	peek64	;Read from source
	ex	de,hl
	call	zxpoke	;Write to dest
	inc	hl
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,fcpylp
	scf
	ret	
;
zerotab:
	ld	hl,(v_arg1)
	ld	bc,(v_arg3)	;Size
	ld	a,b		;<< v1.11
	or	c		;If count=0 (vacuous) do nothing
	scf			;rather than copy 64k bytes.
	ret	z		;>> v1.11
	call	absbc
zerot1:	xor	a
	call	ZXPOKE
	inc	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,zerot1
	scf
	ret
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
prtbl:	call	flush_buf	;<< v0.04 >> Ensure the screen is up to date

	ld	a,(v_argc)
	cp	3
	jr	nc,prtbl0	;<< v0.04 >> If there is 1 line, initialise
	ld	hl,1		;            properly
	ld	(v_arg3),hl	;<< v1.11 >> A=2 - store HL!
prtbl0:	ld	hl,(v_arg3)	;<< v1.04 deal with degenerate case
	ld	a,h		;        when height is 0
	or	l
	scf
	ret	z		;>> v1.04
;
; Get current cursor position
;
	call	ZXGETX
	ld	e,l
	call	ZXGETY
	ld	d,l	;D=Y E=X
	ld	bc,(v_arg2) 	;<< v1.02 rewritten for lines
	ld	hl,(v_arg1)	;        longer than 256 chars
	ld	a,b		;<< v1.04 deal with degenerate case
	or	c		;        when width is 0
	scf
	ret	z		;>> v1.04
	xor	a		;<< v1.11 >> Move this xor a down so that	
				;A really is zero on the first line.
prtbl1:	call	doline
	push	de
	ld	de,(v_arg4)
	add	hl,de
	pop	de
	inc	a
	inc	d	;Next line
	push	hl
	ld	hl,v_arg3
	dec	(hl)
	pop	hl
	jr	nz,prtbl1	;>> v1.02
	call	flush_buf	;<< v1.11 >>
	scf
	ret
;
doline:	push	de	;<< v1.02 rewritten for lines >256 chars
	push	bc
	or	a	;<< v0.04  Don't position the cursor if on 1st line
	jr	z,doln1	;>> v0.04
	ld	b,d
	ld	c,e
	inc	b
	inc	c	;1-based
	push	hl	;<< v1.11 ZXSCUR is allowed to trash HL! 
	call	ZXSCUR
	pop	hl	;>> v1.11
	pop	bc
	push	bc
doln1:	push	bc
	call	peek64	;ZSCII character	
	push	hl
	ld	l,a
	ld	h,0	
	call	ll_zchr
	pop	hl
	inc	hl	;HL = address of character to read
	pop	bc
	dec	bc
	ld	a,b
	or	c
	jr	nz,doln1
	
	pop	bc
	pop	de	;>> v1.02
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; << v1.10: New line conversion functions
;
; Convert line from v3 format to v5.
;
line_to_v5:
	ld      hl,(v_arg1)     ;input buffer
        inc     hl              ;Length
        call    ZXPK64          ;A = actual length
        or      a
	ret	z		;No input; the 0 becomes a terminating null
        ld      b,a
sreadv: inc     hl
        call    ZXPK64          ;Character
        call    valid_char      ;Ensure it's valid
	dec	hl
        call    ZXPOKE		;Write it to previous slot
	inc	hl
        djnz    sreadv
sreadw:
	xor	a
	jp	ZXPOKE		;Terminating 0
;
; Convert line from v5 format to v3. Only used when recovering from a 
; timeout.
;
line_from_v5:
	ld	hl,(v_arg1)
	inc	hl
	ld	bc,0		;B = length, C = character being moved up
lv501:	call	ZXPK64
	or	a
	jr	z,l5eol
	ld	e,a		;E = character just read
	ld	a,c
	call	ZXPOKE		;Write character from previous slot
	ld	c,e		;C = next character to write back
	inc	hl
	inc	b
	jr	lv501
;
l5eol:	ld	a,c
	call	ZXPOKE		;Write back the last character
	ld	hl,(v_arg1)
	inc	hl
	ld	a,b		;A = count
	jp	ZXPOKE
;

