
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

	include	in_zxzvm.inc

peek64	equ	ZXPK64


	org	7000h	;Program Segment Prefix (aka Zero Page). Those
	jp	main	;things are so useful!
zinum:	defb	7	;<< v0.02 >> Pretend to be a C128

param	equ	705Ch	;Where the FCB parameter would be.

	org	7100h
main:	ld	(isp),sp	;Save BASIC's SP
	ld	hl,0
	ld	(cycles),hl
	ld	de,param
	call	ZXINIT	;Initialise the I/O code
	jp	nc,syserr
	call	ZXVER
	ld	hl,vererr
	cp	VMVER
	jp	nz,syserr
	call	ZXIHDR
	jp	nc,syserr
	call	init_hdr
	jp	nc,syserr
	call	init_scr
	jp	nc,syserr
	call	init_rnd
	jp	nc,syserr
	call	init_stack
	jp	nc,syserr
	call	test_mem	;<< v0.02 Check we can write Z-memory
	jp	nc,syserr	;>> v0.02
	ld	a,1
	ld	(running),a
	call	showpc
zloop:	call	zinst
	push	hl		;<< v0.02
	push	af
	ld	hl,(cycles)
	inc	hl
	ld	(cycles),hl	;Call ZXRCPU once every 2048 z-cycles.
	ld	a,h
	cp	8
	jr	c,zlp0	
	ld	hl,0
	ld	(cycles),hl
	call	ZXRCPU		
zlp0:				; v0.02 >>
zlp1:	pop	af
	pop	hl

	call	showpc
	jp	nc,zmstop
	ld	a,(running)	;Running = 1 to continue
	dec	a		;        = 0 to quit
	jr	z,zloop		;        = 2 to restart
	inc	a
	jr	z,zmexit
	cp	2
	jr	z,zmreset
	jp	stub
;
zmstop:	push	hl	
	call	flush_buf
	call	showstk
	ld	de,anykey
	ld	c,9
	call	ZXFDOS
	ld	c,6
	ld	e,0FDh
	call	ZXFDOS
	pop	hl
	jp	syserr
;
zmexit:	call	flush_buf
	ld	de,anykey
	ld	c,9
	call	ZXFDOS
	ld	c,6
	ld	e,0FDh
	call	ZXFDOS
	scf
	call	ZXEXIT
        ld      sp,(isp)
	ret			;<< v0.02 >> Spectrum-specific code removed
;				;from ZXZVM
zmreset:
        call    ZXRST		;Restart
        jp      nc,syserr
        call    ZXIHDR
        jp      nc,syserr
        call    init_hdr
        jp      nc,syserr
        call    init_scr
        jp      nc,syserr
        call    init_rnd
        jp      nc,syserr
        call    init_stack
        jp      nc,syserr
        ld      a,1
        ld      (running),a
	jp	zloop

stub:	ld	a,8
	ld	(5C3Ah),a
	ld	hl,msg1
syserr:	xor	a
	call	ZXEXIT
;
;ZXEXIT should not return if called with Carry reset. But in case it does,
;      reboot!
;
	rst	0
	di
	halt
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Numerical data
;
cycles:	defw	0	;No. of Z-machine cycles executed modulo 2048
isp:	defw	0	;BASIC's SP
zsp:	defw	0	;Z-machine stack pointer
zstop:	defw	0	;Top of Z-machine stack
rsp:	defw	0	;Routine stack pointer
rstop:	defw	0	;Top of routine stack
zpc:	defw	0,0	;Z-machine program counter
zipc:	defw	0,0	;Address of last opcode (as opposed to data)
zver:	defb	0	;Version of the Z-Machine
inst:	defw	0	;Current instruction
running:
	defb	0	;Set to 1 while the Z-machine is running
;
;Some strings
;
msg1:	defb	'9 Stub encountere'
	defb	0E4h		;'d'+80h
;
vererr:	defb	'A Version mismatc'
	defb	0E8h		;'h'+80h
;	
memerr:	defb	'4 Memory test faile'	;<< v0.02
	defb	0E4h		;'d'+80h;>> v0.02
;
anykey:	defb	13,10,'Press SPACE to finish',13,10,'$'
;
zvbad:  defb    'A Story type '
zvbuf:  defb    '000'
;
;;;;;;;;;;;;;;;;;;; Set up the header ;;;;;;;;;;;;;;;;;;;;;
;
init_hdr:
	ld	e,0
	ld	hl,0
	and	a		;<< v1.12 >> Non-instruction fetch
	call	ZXPEEK		;Get Z-file version
        ld      (zver),a
        ld      de,zvbuf
        ld      l,a
        ld      h,0             ;Create the "invalid version" error
        call    spdec3
        ex      de,hl
        dec     hl
        set     7,(hl)          ;Fatal error, so set bit 7 of last char
        ld      hl,zvbad
	ld	a,(zver)	;v5 only?
	cp	8
	jr	z,verok
	cp	3	;<< v0.04 v3 support
	jr	z,verok	;>> v0.04
	cp	4	;<< v1.10 v4 support
	jr	z,verok	;>> v1.10
	cp	5	
        jp      nz,ihdr8
verok:	ld	hl,001Eh	;Interpreter no.
	ld	a,(zinum)	;The interpreter number we pretend to be
	call	zxpoke
	ld	hl,001Fh
	ld	a,'I'		;<< v1.03 >> Our release number
	call	zxpoke
;
;Get g_addr, address of globals table; also strings & routines
;
	ld	e,0
	ld	hl,08h
	call	ZXPKWI	
	ld	(d_addr),bc	;Dictionary
	call	ZXPKWI	
	ld	(obj_addr),bc
	call	ZXPKWI	
	ld	(g_addr),bc
;
	ld	hl,28h
	call	ZXPKWI
	ld	(r_offs),bc
	call	ZXPKWI
	ld	(s_offs),bc
;
;Work out which upack_addr to use
;
	ld	a,(zver)
	ld	l,a
	ld	h,0	
	add	hl,hl
	ld	de,upack_table
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(upack_addr+1),de
;
;Compute property sizes
;
	ld	a,(zver)
	cp	4
	jr	c,psv3
	ld	a,03Fh
	ld	(psmask),a
	ld	(pnmask),a
	ld	hl,14
	ld	(objlen),hl
	ld	hl,126
	ld	(ptlen),hl
	jr	psv4

psv3:	ld	a,0E0h
	ld	(psmask),a
	ld	a,01Fh
	ld	(pnmask),a
	ld	hl,9
	ld	(objlen),hl
	ld	hl,62
	ld	(ptlen),hl
psv4:	scf
	ret
;
ihdr8:  and     a
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
init_scr:
	ld	a,-1	;erase_window(-1)
	call	ZXERAW
	xor	a
	ld	(abbrev),a
	ld	(alpha),a
	ld	(dalpha),a
	ld	(shift),a
	ld	(multi),a
	ld	(timer),a
	call	inibuf	;Initialise I/O buffering
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Initialise the random number generator
;
init_rnd:
	xor	a
	ld	(rmode),a
	ld	hl,0
	call	random	;Seed the generator
	scf
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Stack frame format (little-endian):
;
;+0:  DD pc		;Previous ZPC
;+4:  DS 30		;Local variables
;+34: DB call type	;0=function, 1=procedure, 2=interrupt
;+35: DB pcount		;Count of parameters
;+36: DW rsp		;Routine stack pointer
;
init_stack:
	call	ZXTMEM	
	inc	hl		;1st unusable byte
	ld	(zsp),hl
	ld	(zstop),hl
	ld	de,-2048	;2k call stack
	add	hl,de
	ld	(rsp),hl	;Routine stack
	ld	(rstop),hl
	call	mkframe		;Returns HL->frame
	ret	nc
	push	hl
	pop	ix		;IX -> frame
	ld	de,(rsp)
	ld	(ix+36),e
	ld	(ix+37),d	;Routine stack pointer
	ld	(ix+34),1	;Procedure
	ld	(ix+35),0	;No local variables
	ld	hl,6
	ld	e,0		;00000006
	call	ZXPKWD		;PC high
	ld	(zpc),bc
	ld	bc,0
	ld	(zpc+2),bc
	scf
	ret
;
mkframe:
	push	de
	ld	hl,(zsp)
	ld	de,-38		;Frame size
	add	hl,de
	ld	(zsp),hl
	push	hl
	ld	de,(rstop)	;Call stack hits routine stack?
	and	a
	sbc	hl,de
	pop	hl
	ccf	
	jp	nc,spfail1		;Stack overflow!
	push	hl
	ld	e,38
mframe1:
	ld	(hl),0		;Initialise the frame to zeroes.
	inc	hl
	dec	e
	jr	nz,mframe1
	pop	hl
	pop	de
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
zinst:	
;;; DEBUG
;;;	ld	hl,(zpc)
;;;	ld	de,(zpc+2)
;;;	call	ZXILIV

;;;	ld	hl,(zpc+2)
;;;	call	hexhl
;;;	ld	hl,(zpc)
;;;	call	hexhl
;;; DEBUG

	ld	hl,(zpc)
	ld	(zipc),hl	;Last opcode location
	ld	hl,(zpc+2)
	ld	(zipc+2),hl	
	call	zpcipeek		;Get instruction byte
	ret	nc
	ld	(inst),a
	cp	0FAh
	jp	z,v2_inst		;8-operand VAR
	cp	0ECh
	jr	z,v2_inst
	cp	0E0h
	jp	nc,var_inst
	cp	0C0h
	jp	nc,op2_vainst
	cp	0BEh
	jp	z,ext_inst
	cp	0B0h
	jp	nc,op0_inst
	cp	080h
	jp	nc,op1_inst
;
;It's a 2OP.
;
	call	parse_2op	;This decodes the parameters.
	ld	a,2
	ld	(v_argc),a
op2_main:
	ld	a,(inst)
	and	1Fh
	ld	de,two_ops
	jr	dispatch
;
op2_vainst:
	call	zpcipeek	;Operand types
	ret	nc
	call	parse_var	;2OP with VAR parameters
	jr	op2_main
;
op1_inst:
	ld	a,1		;<< v1.00  Set argument count correctly
	ld	(v_argc),a	;>> v1.00
	call	parse_1op
	ld	a,(inst)
	and	0Fh
	ld	de,one_ops
	jr	dispatch
;
op0_inst:
	xor	a		;<< v1.00 Set argument count correctly
	ld	(v_argc),a	;>> v1.00
	ld	a,(inst)
	and	0Fh
	ld	de,zero_ops
	jr	dispatch
;
ext_inst:
	ld	a,(zver)	;Aren't allowed extended opcodes in v1-v4
	cp	5
	jp	c,fail
	call	zpcipeek	;Get real opcode
	ret	nc
	ld	(inst+1),a
	call	zpcipeek	;Operand types
	ret	nc
	call	parse_var
	ld	a,(inst+1)
	bit	7,a
	jp	nz,ext_high
	ld	de,ext_ops
	cp	MAXEXT		;In range?
	jr	c,dispatch
	jr	z,dispatch
	jp	fail

v2_inst:
	call	zpcipeek
	ret	nc
	ld	b,a
	call	zpcipeek
	ret	nc
	ld	c,a	
	call	parse_v2
	jr	var_main
;
var_inst:
	call	zpcipeek	;Operand types
	ret	nc
	call	parse_var	;Count in argc, args in arg1-arg4
var_main:
	ld	a,(inst)
	and	1Fh
	ld	de,var_ops
dispatch:
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	jp	(hl)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Utility code to read the Z-machine's memory
;
ipeek:	scf		;<< v1.12 Reset carry for non-instruction fetch
	ccf		;>> v1.12
ipeek0:	call	ZXPEEK
	push	af
	inc	hl
	ld	a,h
	or	l
	jr	nz,ipeek1
	inc	e
ipeek1:	pop	af
	ret
;
zpcipeek:
	push	hl
	push	de
	ld	hl,(zpc)
	ld	de,(zpc+2)	
	scf		;<< v1.12 >> Set carry for instruction fetch
	call	ipeek0
	ld	(zpc),hl
	ld	(zpc+2),de
	pop	de
	pop	hl
	ret
;
zpcpeek:
	push	hl
	push	de
	ld	hl,(zpc)
	ld	de,(zpc+2)
	scf		;<< v1.12 >> Set carry for instruction fetch
	call	ZXPEEK
	pop	de
	pop	hl
	ret
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; << v0.02 Check that Z-machine memory is writable. If not, then
;          we can't run.
;
test_mem:
	ld	hl,40h
	call	ZXPK64
	ld	d,a	;Correct value
	cpl
	ld	e,a	;Different value
	call	ZXPOKE
	call	ZXPK64
	cp	e	;Has the change registered?
	jr	nz,tm_fail
	ld	a,d	;Change back to the correct value.
	call	ZXPOKE
	call	ZXPK64
	cp	d	;Has the change back registered?
	jr	nz,tm_fail
	scf
	ret
;
tm_fail:
	ld	hl,memerr
	xor	a
	ret

; >> v0.02
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Other source files
;
	include vmdebug.zsm	;Debugging ops
	include vmvar.zsm	;Access to variables & operand decoding
	include	vm0ops.zsm	;0OP: operations
	include vm1ops.zsm	;1OP: operations
	include vm2ops.zsm	;2OP: operations
	include	vmvops.zsm	;VAR: operations
	include vmeops.zsm	;EXT: operations
	include vmarith.zsm	;Arithmetic operations
	include vmobj.zsm	;Object operations
	include vmprop.zsm	;Property operations
	include vmzchar.zsm	;I/O and buffering
	include vmdict.zsm	;Dictionary oprations
	include in_wrhex.inc	;Output hex and decimal numbers

	end
