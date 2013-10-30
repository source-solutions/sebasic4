; Open81 - A free firmware for the Timex TS1000 / Sinclair ZX81
; Copyright (C) 1981 Nine Tiles Networks Ltd.

; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

; section headings and labels from
; The Complete Timex TS1000 / Sinclair ZX81 ROM disassembly
; by Dr. Ian Logan & Dr. Frank O'Hara

; THE 'TEST CHARACTERS'
double_quote	equ	0x0b
dollar			equ	0x0d
open_bracket	equ	0x10
close_bracket	equ	0x11
close_angle		equ	0x12
equals			equ	0x14
plus			equ	0x15
minus			equ	0x16
comma			equ	0x1a
period			equ	0x1b
zero			equ	0x1c
capital_a		equ	0x26
capital_e		equ	0x2a

; THE 'CONTROL CHARACTERS'
ctrl_up			equ	0x70
ctrl_down		equ	0x71
ctrl_left		equ	0x72
ctrl_right		equ	0x73
ctrl_graphics	equ	0x74
ctrl_edit		equ	0x75
ctrl_newline	equ	0x76
ctrl_rubout		equ	0x77
ctrl_kl			equ	0x78
ctrl_function	equ	0x79
ctrl_number		equ	0x7e

; THE 'TOKENS'
tk_rnd		equ	0x40
tk_inkeys	equ	0x41
tk_pi		equ	0x42
tk_dquote	equ	0xc0
tk_at		equ	0xc1
tk_tab		equ	0xc2
tk_code		equ	0xc4
tk_val		equ	0xc5
tk_len		equ	0xc6
tk_sin		equ	0xc7
tk_cos		equ	0xc8
tk_tan		equ	0xc9
tk_asn		equ	0xca
tk_acs		equ	0xcb
tk_atn		equ	0xcc
tk_ln		equ	0xcd
tk_exp		equ	0xce
tk_int		equ	0xcf
tk_sqr		equ	0xd0
tk_sgn		equ	0xd1
tk_abs		equ	0xd2
tk_peek		equ	0xd3
tk_usr		equ	0xd4
tk_strS		equ	0xd5
tk_chrS		equ	0xd6
tk_not		equ	0xd7
tk_dstar	equ	0xd8
tk_or		equ	0xd9
tk_and		equ	0xda
tk_l_eql	equ	0xdb
tk_gr_eq	equ	0xdc
tk_neql		equ	0xdd
tk_then		equ	0xde
tk_to		equ	0xdf
tk_step		equ	0xe0
tk_lprint	equ	0xe1
tk_llist	equ	0xe2
tk_stop		equ	0xe3
tk_slow		equ	0xe4
tk_fast		equ	0xe5

; THE 'I/O PORTS'
nmigen		equ	0xfd

; THE 'RESTARTS'
start		equ	0x00
error_1		equ	0x08
print_a		equ	0x10
get_ch		equ	0x18
next_ch		equ	0x20
fp_calc		equ	0x28
bc_spaces	equ	0x30
interrupt	equ	0x38

; THE 'COMMAND CLASSES'
no_f_ops		equ	0x00
var_rqd			equ	0x01
expr_num_str	equ	0x02
num_exp_0		equ	0x03
chr_var			equ	0x04
var_syn			equ	0x05
num_exp			equ	0x06

; THE 'ERROR REPORTS'

next_without_for		equ	0x00
missing_variable		equ	0x01
subscript_out_of_range	equ	0x02
out_of_ram				equ	0x03
insufficient_room		equ	0x04
arithmetic_overflow		equ	0x05
return_without_gosub	equ	0x06
input_as_direct_command	equ	0x07
stop_command			equ	0x08
invalid_argument		equ	0x09
integer_out_of_range	equ	0x0a
no_numeric_value		equ	0x0b
break_pressed			equ	0x0c
not_used				equ	0x0d
no_name_supplied		equ	0x0e

; THE 'CALCULATOR' INSTRUCTIONS

jump_true	equ	0x00
exchange	equ	0x01
delete		equ	0x02
subtract	equ	0x03
multiply	equ	0x04
division	equ	0x05
to_power	equ	0x06
fn_or		equ	0x07
no_and_no	equ	0x08
no_l_eql	equ	0x09
no_gr_eql	equ	0x0a
nos_neql	equ	0x0b
no_grtr		equ	0x0c
no_less		equ	0x0d
nos_eql		equ	0x0e
addition	equ	0x0f
str_and_no	equ	0x10
str_l_eql	equ	0x11
str_gr_eql	equ	0x12
strs_neql	equ	0x13
str_grtr	equ	0x14
str_less	equ	0x15
strs_eql	equ	0x16
strs_add	equ	0x17
negate		equ	0x18
code		equ	0x19
val			equ	0x1a
len			equ	0x1b
sin			equ	0x1c
cos			equ	0x1d
tan			equ	0x1e
asn			equ	0x1f
acs			equ	0x20
atn			equ	0x21
ln			equ	0x22
exp			equ	0x23
int			equ	0x24
sqr			equ	0x25
sgn			equ	0x26
abs			equ	0x27
peek		equ	0x28
usr			equ	0x29
strS		equ	0x2a
chrS		equ	0x2b
fn_not		equ	0x2c
duplicate	equ	0x2d
n_mod_m		equ	0x2e
jump		equ	0x2f
stk_data	equ	0x30
dec_jr_nz	equ	0x31
less_0		equ	0x32
greater_0	equ	0x33
end_calc	equ	0x34
get_argt	equ	0x35
truncate	equ	0x36
calc_2		equ	0x37
e_to_fp		equ	0x38

stk_zero		equ	0xa0
stk_one			equ	0xa1
stk_half		equ	0xa2
stk_pi_div_2	equ	0xa3
stk_ten			equ	0xa4

st_mem_0	equ	0xc0
st_mem_1	equ	0xc1
st_mem_2	equ	0xc2
st_mem_3	equ	0xc3
st_mem_4	equ	0xc4

get_mem_0	equ	0xe0
get_mem_1	equ	0xe1
get_mem_2	equ	0xe2
get_mem_3	equ	0xe3
get_mem_4	equ	0xe4


; THE 'SYSTEM VARIABLES'

sys_var		equ 0x4000
err_nr		equ sys_var			; iy + 0x00
_err_nr		equ 0x00
flags		equ err_nr		+ 1	; iy + 0x01
_flags		equ 0x01
err_sp		equ flags		+ 1	; iy + 0x02
ramtop		equ err_sp		+ 2	; iy + 0x04
ramtop_hi	equ ramtop		+ 1	; iy + 0x05
mode		equ ramtop		+ 2	; iy + 0x06
ppc			equ mode		+ 1	; iy + 0x07
ppc_hi		equ ppc			+ 1	; iy + 0x08
_ppc_hi		equ 0x08
versn		equ ppc			+ 2	; iy + 0x09
e_ppc		equ versn		+ 1	; iy + 0x0a
e_ppc_hi	equ e_ppc		+ 1	; iy + 0x0b
d_file		equ e_ppc		+ 2	; iy + 0x0c
df_cc		equ d_file		+ 2	; iy + 0x0e
vars		equ df_cc		+ 2	; iy + 0x10
dest		equ vars		+ 2	; iy + 0x12
e_line		equ dest		+ 2	; iy + 0x14
e_line_hi	equ dest		+ 3	; iy + 0x15
_e_line_hi	equ 0x15
ch_add		equ e_line		+ 2	; iy + 0x16
x_ptr		equ ch_add		+ 2	; iy + 0x18
x_ptr_hi	equ ch_add		+ 2	; iy + 0x19
_x_ptr_hi	equ 0x19
stkbot		equ x_ptr		+ 2	; iy + 0x1a
stkend		equ stkbot		+ 2	; iy + 0x1c
stkend_h	equ stkend		+ 1	; iy + 0x1d
breg		equ stkend		+ 2	; iy + 0x1e
_breg		equ 0x1e
mem			equ breg		+ 1	; iy + 0x1f
df_size		equ mem			+ 3	; iy + 0x22
_df_size	equ 0x22
s_top		equ df_size		+ 1	; iy + 0x23
last_k		equ s_top		+ 2	; iy + 0x25
debounce	equ last_k		+ 2	; iy + 0x27
margin		equ debounce	+ 1	; iy + 0x28
_margin		equ 0x28
nxtlin		equ margin		+ 1	; iy + 0x29
oldppc		equ nxtlin		+ 2	; iy + 0x2b
flagx		equ oldppc		+ 2	; iy + 0x2d
_flagx		equ 0x2d
strlen		equ flagx		+ 1	; iy + 0x2e
_strlen		equ 0x2e
t_addr		equ strlen		+ 2	; iy + 0x30
seed		equ t_addr		+ 2	; iy + 0x32
frames		equ seed		+ 2	; iy + 0x34
frames_hi	equ seed		+ 3	; iy + 0x35
_frames_hi	equ 0x35
coords		equ frames		+ 2	; iy + 0x36
pr_cc		equ coords		+ 2	; iy + 0x38
_pr_cc		equ 0x38
s_posn		equ pr_cc		+ 1	; iy + 0x39
s_posn_lo	equ pr_cc		+ 1	; iy + 0x39
_s_posn_lo	equ 0x39
s_posn_hi	equ pr_cc		+ 2	; iy + 0x3a
_s_posn_hi	equ 0x3a
cdflag		equ s_posn		+ 2	; iy + 0x3b
_cdflag		equ 0x3b
prbuff		equ cdflag		+ 1
prbuff_end	equ prbuff		+ 32
mem_0_1		equ prbuff_end	+ 1	; iy + 0x5d
membot		equ 0x5d
_membot		equ 0x5d
program		equ 0x407d

; THE 'START'

org 0x0000
; start:
	out		(nmigen), a
	ld		bc, 0x7fff
	jp		ram_check

; THE 'ERROR' RESTART
; error_1:
	ld		hl, (ch_add)
	ld		(x_ptr), hl
	jr		error_2

; THE 'PRINT A CHARACTER' RESTART
; print_a:
	and		a
	jp		nz,  print_ch
	jp		print_sp
	defb	0xff

; THE 'COLLECT CHARACTER' RESTART
jp_get_ch:
; get_ch:
	ld		hl, (ch_add)
	ld		a, (hl)

test_sp:
	and		a
	ret		nz
	nop
	nop

; THE 'COLLECT NEXT CHARACTER' RESTART
; next_ch:
	call	ch_add_inc
	jr		test_sp
	defb	0xff
	defb	0xff
	defb	0xff

; THE 'FP-CALCULATOR' RESTART
; fp_calc:
	jp		calculate

; THE 'END-CALC' SUBROUTINE
fp_end_calc:
	pop		af
	exx
	ex		(sp), hl
	exx
	ret

; THE 'MAKE BC SPACES' RESTART
; bc_spaces:
	push	bc 
	ld		hl, (e_line) 
	push	hl 
	jp		reserve 

; THE 'INTERRUPT' RESTART
; interrupt:
	dec		c
	jp		nz, scan_line
	pop		hl
	dec		b
	ret		z
	set		3, c

wait_int:
	ld		r, a
	ei
	jp		(hl)

scan_line:
	pop		de
	ret		z
	jr		wait_int

; THE 'INCREMENT CH-ADD' SUBROUTINE
ch_add_inc:
	ld		hl, (ch_add)

cursor_so:
	inc		hl

temp_ptr:
	ld		(ch_add), hl
	ld		a, (hl)
	cp		0x7f
	ret		nz
	jr		cursor_so

; THE 'ERROR-2' ROUTINE
error_2:
	pop		hl
	ld		l, (hl)

error_3:
	ld		(iy + _err_nr), l
	ld		sp, (err_sp)
	call	slow_fast
	jp		set_mem
	defb	0xff

; THE 'NMI' ROUTINE
nmi:
	ex		af, af'															;'															;'
	inc		a
	jp		m, nmi_ret
	jr		z, nmi_cont

nmi_ret:
	ex		af, af'															;'
	ret

; THE 'PREPARE FOR 'SLOW' DISPLAY' ROUTINE
nmi_cont:
	ex		af, af'															;'
	push	af
	push	bc
	push	de
	push	hl
	ld		hl, (d_file)
	set		7, h
	halt
	out		(nmigen), a
	jp		(ix)

; THE 'KEY TABLES'
k_unshifted:
	defb	'Z' - 27
	defb	'X' - 27
	defb	'C' - 27
	defb	'V' - 27
	defb	'A' - 27
	defb	'S' - 27
	defb	'D' - 27
	defb	'F' - 27
	defb	'G' - 27
	defb	'Q' - 27
	defb	'W' - 27
	defb	'E' - 27
	defb	'R' - 27
	defb	'T' - 27
	defb	'1' - 20
	defb	'2' - 20
	defb	'3' - 20
	defb	'4' - 20
	defb	'5' - 20
	defb	'0' - 20
	defb	'9' - 20
	defb	'8' - 20
	defb	'7' - 20
	defb	'6' - 20
	defb	'P' - 27
	defb	'O' - 27
	defb	'I' - 27
	defb	'U' - 27
	defb	'Y' - 27
	defb	ctrl_newline
	defb	'L' - 27
	defb	'K' - 27
	defb	'J' - 27
	defb	'H' - 27
	defb	' ' - 32
	defb	'.' - 19
	defb	'M' - 27
	defb	'N' - 27
	defb	'B' - 27

k_shifted:
	defb	':' - 44
	defb	';' - 34
	defb	'?' - 48
	defb	'/' - 23
	defb	tk_stop, tk_lprint, tk_slow, tk_fast, tk_llist, tk_dquote
	defb	tk_or, tk_step, tk_l_eql, tk_neql, ctrl_edit, tk_and
	defb	tk_then, tk_to, ctrl_left, ctrl_rubout, ctrl_graphics
	defb	ctrl_right, ctrl_up, ctrl_down
	defb	'"' - 23
	defb	')' - 24
	defb	'(' - 24
	defb	'$' - 23
	defb	tk_gr_eq
	defb	ctrl_function
	defb	'=' - 41
	defb	'+' - 22
	defb	'-' - 23
	defb	tk_dstar
	defb	0x0c ; £
	defb	',' - 18
	defb	'>' - 44
	defb	'<' - 41
	defb	'*' - 19

k_function:
	defb	tk_ln, tk_exp, tk_at, ctrl_kl, tk_asn, tk_acs, tk_atn, tk_sgn
	defb	tk_abs, tk_sin, tk_cos, tk_tan, tk_int, tk_rnd, ctrl_kl, ctrl_kl
	defb	ctrl_kl, ctrl_kl, ctrl_kl, ctrl_kl, ctrl_kl, ctrl_kl, ctrl_kl
	defb	ctrl_kl, tk_tab, tk_peek, tk_code, tk_chrS, tk_strS, ctrl_kl
	defb	tk_usr, tk_len, tk_val, tk_sqr, ctrl_kl, ctrl_kl, tk_pi
	defb	tk_not, tk_inkeys

k_graphic:
	defb	0x08, 0x0a, 0x09, 0x8a, 0x89, 0x81, 0x82, 0x07
	defb	0x84, 0x06, 0x01, 0x02, 0x87, 0x04, 0x05
	defb	ctrl_rubout, ctrl_kl, 0x85, 0x03, 0x83, 0x8b
	defb	')' + 104
	defb	'(' + 104
	defb	'$' + 105
	defb	0x86, ctrl_kl
	defb	'>' + 84
	defb	'+' + 106
	defb	'-' + 105
	defb	0x88

k_token:
	defb	0x8f								; ?
	defb	0x0b, 0x8b							; ""
	defb	0x26, 0xb9							; AT
	defb	0x39, 0x26, 0xa7					; TAB
	defb	0x8f								; ?
	defb	0x28, 0x34, 0x29, 0xaa				; CODE
	defb	0x3b, 0x26, 0xb1					; VAL
	defb	0x31, 0x2a, 0xb3					; LEN
	defb	0x38, 0x2e, 0xb3					; SIN
	defb	0x28, 0x34, 0xb8					; COS
	defb	0x39, 0x26, 0xb3					; TAN
	defb	0x26, 0x38, 0xb3					; ASN
	defb	0x26, 0x28, 0xb8					; ACS
	defb	0x26, 0x39, 0xb3					; ATN
	defb	0x31, 0xb3							; LN
	defb	0x2a, 0x3d, 0xb5					; EXP
	defb	0x2e, 0x33, 0xb9					; INT
	defb	0x38, 0x36, 0xb7					; SQR
	defb	0x38, 0x2c, 0xb3					; SGN
	defb	0x26, 0x27, 0xb8					; ABS
	defb	0x35, 0x2a, 0x2a, 0xb0				; PEEK
	defb	0x3a, 0x38, 0xb7					; USR
	defb	0x38, 0x39, 0x37, 0x8d				; STR$
	defb	0x28, 0x2d, 0x37, 0x8d				; CHR$
	defb	0x33, 0x34, 0xb9					; NOT
	defb	0x17, 0x97							; **
	defb	0x34, 0xb7							; OR
	defb	0x26, 0x33, 0xa9					; AND
	defb	0x13, 0x94							; <=
	defb	0x12, 0x94							; >=
	defb	0x13, 0x92							; <>
	defb	0x39, 0x2d, 0x2a, 0xb3				; THEN
	defb	0x39, 0xb4							; TO
	defb	0x38, 0x39, 0x2a, 0xb5				; STEP
	defb	0x31, 0x35, 0x37, 0x2e, 0x33, 0xb9	; LPRINT
	defb	0x31, 0x31, 0x2e, 0x38, 0xb9		; LLIST
	defb	0x38, 0x39, 0x34, 0xb5				; STOP
	defb	0x38, 0x31, 0x34, 0xbc				; SLOW
	defb	0x2b, 0x26, 0x38, 0xb9				; FAST
	defb	0x33, 0x2a, 0xbc					; NEW
	defb	0x38, 0x28, 0x37, 0x34, 0x31, 0xb1	; SCROLL
	defb	0x28, 0x34, 0x33, 0xb9				; CONT
	defb	0x29, 0x2e, 0xb2					; DIM
	defb	0x37, 0x2a, 0xb2					; REM
	defb	0x2b, 0x34, 0xb7					; FOR
	defb	0x2c, 0x34, 0x39, 0xb4				; GOTO
	defb	0x2c, 0x34, 0x38, 0x3a, 0xa7		; GOSUB
	defb	0x2e, 0x33, 0x35, 0x3a, 0xb9		; INPUT
	defb	0x31, 0x34, 0x26, 0xa9				; LOAD
	defb	0x31, 0x2e, 0x38, 0xb9				; LIST
	defb	0x31, 0x2a, 0xb9					; LET
	defb	0x35, 0x26, 0x3a, 0x38, 0xaa		; PAUSE
	defb	0x33, 0x2a, 0x3d, 0xb9				; NEXT
	defb	0x35, 0x34, 0x30, 0xaa				; POKE
	defb	0x35, 0x37, 0x2e, 0x33, 0xb9		; PRINT
	defb	0x35, 0x31, 0x34, 0xb9				; PLOT
	defb	0x37, 0x3a, 0xb3					; RUN
	defb	0x38, 0x26, 0x3b, 0xaa				; SAVE
	defb	0x37, 0x26, 0x33, 0xa9				; RAND
	defb	0x2e, 0xab							; IF
	defb	0x28, 0x31, 0xb8					; CLS
	defb	0x3a, 0x33, 0x35, 0x31, 0x34, 0xb9	; UNPLOT
	defb	0x28, 0x31, 0x2a, 0x26, 0xb7		; CLEAR
	defb	0x37, 0x2a, 0x39, 0x3a, 0x37, 0xb3	; RETURN
	defb	0x28, 0x34, 0x35, 0xbe				; COPY
	defb	0x37, 0x33, 0xa9					; RND
	defb	0x2e, 0x33, 0x30, 0x2a, 0x3e, 0x8d	; INKEY$
	defb	0x35, 0xae							; PI

; THE 'LOAD/SAVE UPDATE' SUBROUTINE
load_save:
	inc		hl
	ex		de, hl
	ld		hl, (e_line)
	scf
	sbc		hl, de
	ex		de, hl
	ret		nc
	pop		hl

; THE 'DISPLAY' ROUTINES
slow_fast:
	ld		hl, cdflag
	ld		a, (hl)
	rla
	xor		(hl)
	rla
	ret		nc
	ld		a, 0x7f
	ex		af, af'															;'
	ld		b, 0x11
	out		(0xfe), a

loop_11:
	djnz	loop_11
	out		(nmigen), a
	ex		af, af'															;'
	rla
	jr		nc, no_slow
	set		7, (hl)
	push	af
	push	bc
	push	de
	push	hl
	jr		display_1

no_slow:
	res		6, (hl)
	ret

display_1:
	ld		hl, (frames)
	dec		hl

display_p:
	ld		a, 0x7f
	and		h
	or		l
	ld		a, h
	jr		nz, another
	rla
	jr		over_nc

another:
	ld		b, (hl)
	scf

over_nc:
	ld		h, a
	ld		(frames), hl
	ret		nc

display_2:
	call	keyboard
	ld		bc, (last_k)
	ld		(last_k), hl
	ld		a, b
	add		a, 0x02
	sbc		hl, bc
	ld		a, (debounce)
	or		h
	or		l
	ld		e, b
	ld		b, 0x0b
	ld		hl, cdflag
	res		0, (hl)
	jr		nz, no_key
	bit		7, (hl)
	set		0, (hl)
	ret		z
	dec		b
	nop
	scf

no_key:
	ld		hl, debounce
	ccf
	rl		b

loop_b:
	djnz	loop_b
	ld		b, (hl)
	ld		a, e
	cp		0xfe
	sbc		a, a
	ld		b, 0x1f
	or		(hl)
	and		b
	rra
	ld		(hl), a
	out		(0xff), a
	ld		hl, (d_file)
	set		7, h
	call	display_3
	ld		a, r
	ld		bc, 0x1901
	ld		a, 0xf5
	call	display_5
	dec		hl
	call	display_3
	jp		display_1

display_3:
	pop		ix
	ld		c, (iy + _margin)
	bit		7, (iy + _cdflag)
	jr		z, display_4
	ld		a, c
	neg
	inc		a
	ex		af, af'															;'
	out		(0xfe), a
	pop		hl
	pop		de
	pop		bc
	pop		af
	ret

display_4:
	ld		a, 0xfc
	ld		b, 0x01
	call	display_5
	dec		hl
	ex		(sp), hl
	ex		(sp), hl
	jp		(ix)

display_5:
	ld		r, a
	ld		a, 0xdd
	ei
	jp		(hl)

; THE 'KEYBOARD SCANNING' SUBROUTINE
keyboard:
	ld		hl, 0xffff
	ld		bc, 0xfefe
	in		a, (c)
	or		0x01

each_line:
	or		0xe0
	ld		d, a
	cpl
	cp		0x01
	sbc		a, a
	or		b
	and		l
	ld		l, a
	ld		a, h
	and		d
	ld		h, a
	rlc		b
	in		a, (c)
	jr		c, each_line
	rra
	rl		h
	rla
	rla
	rla
	sbc		a, a
	and		0x18
	add		a, 0x1f
	ld		(margin), a
	ret

; THE 'SET FAST MODE' SUBROUTINE
set_fast:
	bit		7, (iy + _cdflag)
	ret		z
	halt
	out		(nmigen), a
	res		7, (iy + _cdflag)
	ret

report_f:
	rst		error_1
	defb	no_name_supplied

; THE 'SAVE' COMMAND ROUTINE
save:
	call	name
	jr		c, report_f
	ex		de, hl
	ld		de, 0x12cb

header:
	call	break_1
	jr		nc, break_2

delay_1:
	djnz	delay_1
	dec		de
	ld		a, d
	or		e
	jr		nz, header

out_name:
	call	out_byte
	bit		7, (hl)
	inc		hl
	jr		z, out_name
	ld		hl, versn

out_prog:
	call	out_byte
	call	load_save
	jr		out_prog

out_byte:
	ld		e, (hl)
	scf

each_bit:
	rl		e
	ret		z
	sbc		a, a
	and		0x05
	add		a, 0x04
	ld		c, a

pulses:
	out		(0xff), a
	ld		b, 0x23

delay_2:
	djnz	delay_2
	call	break_1

break_2:
	jr		nc, report_d
	ld		b, 0x1e

delay_3:
	djnz	delay_3
	dec		c
	jr		nz, pulses

delay_4:
	and		a
	djnz	delay_4
	jr		each_bit

; THE 'LOAD' COMMAND ROUTINE
load:
	call	name
	rl		d
	rrc		d

next_prog:
	call	in_byte
	jr		next_prog

in_byte:
	ld		c, 0x01

next_bit:
	ld		b, 0x00

break_3:
	ld		a, 0x7f
	in		a, (0xfe)
	out		(0xff), a
	rra
	jr		nc, break_4
	rla
	rla
	jr		c, get_bit
	djnz	break_3
	pop		af
	cp		d

restart:
	jp		nc, initial
	ld		h, d
	ld		l, e

in_name:
	call	in_byte
	bit		7, d
	ld		a, c
	jr		nz, matching
	cp		(hl)
	jr		nz, next_prog

matching:
	inc		hl
	rla
	jr		nc, in_name
	inc		(iy + _e_line_hi)
	ld		hl, versn
in_prog:
	ld		d, b
	call	in_byte
	ld		(hl), c
	call	load_save
	jr		in_prog

get_bit:
	push	de
	ld		e, 0x94

trailer:
	ld		b, 0x1a

counter:
	dec		e
	in		a, (0xfe)
	rla
	bit		7, e
	ld		a, e
	jr		c, trailer
	djnz	counter
	pop		de
	jr		nz, bit_done
	cp		0x56
	jr		nc, next_bit

bit_done:
	ccf
	rl		c
	jr		nc, next_bit
	ret

break_4:
	ld		a, d
	and		a
	jr		z, restart

report_d:
	rst		error_1
	defb	break_pressed

; THE 'PROGRAM NAME' SUBROUTINE
name:
	call	scanning
	ld		a, (flags)
	add		a, a
	jp		m, report_c
	pop		hl
	ret		nc
	push	hl
	call	set_fast
	call	stk_fetch
	ld		h, d
	ld		l, e
	dec		c
	ret		m
	add		hl, bc
	set		7, (hl)
	ret

; THE 'NEW' COMMAND ROUTINE
new:
	call	set_fast
	ld		bc, (ramtop)
	dec		bc

; THE 'RAM-CHECK' ROUTINE
ram_check:
	ld		h, b
	ld		l, c
	ld		a, 0x3f

ram_fill:
	ld		(hl),  0x02
	dec		hl
	cp		h
	jr		nz, ram_fill

ram_read:
	and		a
	sbc		hl, bc
	add		hl, bc
	inc		hl
	jr		nc, set_top
	dec		(hl)
	jr		z, set_top
	dec		(hl)
	jr		z, ram_read

set_top:
	ld		(ramtop), hl

; THE 'INITIALISATION' ROUTINE
initial:
	ld		hl, (ramtop)
	dec		hl
	ld		(hl), 0x3e
	dec		hl
	ld		sp, hl
	dec		hl
	dec		hl
	ld		(err_sp), hl
	ld		a, 0x1e
	ld		i, a
	im		1
	ld		iy, err_nr
	ld		(iy + _cdflag), 0x40
	ld		hl, program
	ld		(d_file), hl
	ld		b, 0x19

line:
	ld		(hl), 0x76
	inc		hl
	djnz	line
	ld		(vars), hl
	call	clear

n_l_only:
	call	cursor_in
	call	slow_fast

; PRODUCE THE BASIC LISTING
upper:
	call	cls
	ld		hl, (e_ppc)
	ld		de, (s_top)
	and		a
	sbc		hl, de
	ex		de, hl
	jr		nc, addr_top
	add		hl, de
	ld		(s_top), hl

addr_top:
	call	line_addr
	jr		z, list_top
	ex		de, hl

list_top:
	call	list_prog
	dec		(iy + _breg)
	jr		nz, lower
	ld		hl, (e_ppc)
	call	line_addr
	ld		hl, (ch_add)
	scf
	sbc		hl, de
	ld		hl, s_top
	jr		nc, inc_line
	ex		de, hl
	ld		a, (hl)
	inc		hl
	ldi
	ld		(de), a
	jr		upper

down_key:
	ld		hl, e_ppc

inc_line:
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	push	hl
	ex		de, hl
	inc		hl
	call	line_addr
	call	line_no
	pop		hl

key_input:
	bit		5, (iy + _flagx)
	jr		nz, lower
	ld		(hl), d
	dec		hl
	ld		(hl), e
	jr		upper

; COPY THE EDIT-LINE
edit_inp:
	call	cursor_in

lower:
	ld		hl, (e_line)

each_char:
	ld		a, (hl)
	cp		0x7e
	jr		nz, end_line
	ld		bc, 0x0006
	call	reclaim_2
	jr		each_char

end_line:
	cp		0x76
	inc		hl
	jr		nz, each_char

edit_line:
	call	cursor

edit_room:
	call	line_ends
	ld		hl, (e_line)
	ld		(iy + _err_nr), 0xff
	call	copy_line
	bit		7, (iy + _err_nr)
	jr		nz, display_6
	ld		a, (df_size)
	cp		0x18
	jr		nc, display_6
	inc		a
	ld		(df_size), a
	ld		b, a
	ld		c, 0x01
	call	loc_addr
	ld		d, h
	ld		e, l
	ld		a, (hl)

free_line:
	dec		hl
	cp		(hl)
	jr		nz, free_line
	inc		hl
	ex		de, hl
	ld		a, (ramtop_hi)
	cp		0x4d
	call	c, reclaim_1
	jr		edit_room

; WAITING FOR A KEY
display_6:
	ld		hl, 0x0000
	ld		(x_ptr), hl
	ld		hl, cdflag
	bit		7, (hl)
	call	z, display_1

slow_disp:
	bit		0, (hl)
	jr		z, slow_disp
	ld		bc, (last_k)
	call	d_bounce
	call	decode
	jr		nc, lower

; MODE SORTING
mode_sort:
	ld		a, (mode)
	dec		a
	jp		m, fetch_2
	jr		nz, fetch_1
	ld		(mode), a
	dec		e
	ld		a, e
	sub		0x27
	jr		c, func_base
	ld		e, a

func_base:
	ld		hl, 0x00cc
	jr		table_add

fetch_1:
	ld		a, (hl)
	cp		0x76
	jr		z, k_l_key
	cp		0x40
	set		7, a
	jr		c, enter
	ld		hl, 0x00c7

table_add:
	add		hl, de
	jr		fetch_3

fetch_2:
	ld		a, (hl)
	bit		2, (iy + _flags)
	jr		nz, test_curs
	add		a, 0xc0
	cp		0xe6
	jr		nc, test_curs

fetch_3:
	ld		a, (hl)

test_curs:
	cp		0xf0
	jp		pe, key_sort

enter:
	ld		e, a
	call	cursor
	ld		a, e
	call	add_char

back_next:
	jp		lower

; THE 'ADD-CHAR' SUBROUTINE
add_char:
	call	one_space
	ld		(de), a
	ret

; SORTING THE CURSOR KEYS
k_l_key:
	ld		a, 0x78

key_sort:
	ld		e, a
	ld		hl, 0x0482
	add		hl, de
	add		hl, de
	ld		c, (hl)
	inc		hl
	ld		b, (hl)
	push	bc

; CHOOSING K v. L MODE
cursor:
	ld		hl,  (e_line)
	bit		5, (iy + _flagx)
	jr		nz, l_mode

k_mode:
	res		2, (iy + _flags)

test_char:
	ld		a, (hl)
	cp		0x7f
	ret		z
	inc		hl
	call	number
	jr		z, test_char
	cp		0x26
	jr		c, test_char
	cp		0xde
	jr		z, k_mode

l_mode:		set		2, (iy + _flags)
	jr		test_char

; THE 'CLEAR-ONE' SUBROUTINE
clear_one:
	ld		bc, 0x0001
	jp		reclaim_2

; THE 'CURSOR' KEYTABLE
	defw		up_key
	defw		down_key
	defw		left_key
	defw		right_key
	defw		function
	defw		edit_key
	defw		n_l_key
	defw		rubout
	defw		function
	defw		function

; THE 'CURSOR LEFT' ROUTINE
left_key:
	call	left_edge
	ld		a, (hl)
	ld		(hl), 0x7f
	inc		hl
	jr		get_code

; THE 'CURSOR RIGHT' ROUTINE
right_key:
	inc		hl
	ld		a, (hl)
	cp		0x76
	jr		z, ended_2
	ld		(hl), 0x7f
	dec		hl

get_code:
	ld		(hl), a

ended_1:
	jr		back_next

; THE 'RUBOUT' ROUTINE
rubout:
	call	left_edge
	call	clear_one
	jr		ended_1

; THE 'LEFT_EDGE' SUBROUTINE
left_edge:
	dec		hl
	ld		de, (e_line)
	ld		a, (de)
	cp		0x7f
	ret		nz
	pop		de

ended_2:
	jr		ended_1

; THE 'CURSOR UP' ROUTINE
up_key:
	ld		hl, (e_ppc)
	call	line_addr
	ex		de, hl
	call	line_no
	ld		hl, e_ppc_hi
	jp		key_input

; THE 'FUNCTION KEY' ROUTINE
function:
	ld		a, e
	and		0x07
	ld		(mode), a
	jr		ended_2

; THE 'COLLECT LINE NUMBER' SUBROUTINE
zero_de:
	ex		de, hl
	ld		de, 0x04c2

line_no:
	ld		a, (hl)
	and		0xc0
	jr		nz, zero_de
	ld		d, (hl)
	inc		hl
	ld		e, (hl)
	ret

; THE 'EDIT KEY' ROUTINE
edit_key:
	call	line_ends
	ld		hl, edit_inp
	push	hl
	bit		5, (iy + _flagx)
	ret		nz
	ld		hl, (e_line)
	ld		(df_cc), hl
	ld		hl, 0x1821
	ld		(s_posn), hl
	ld		hl, (e_ppc)
	call	line_addr
	call	line_no
	ld		a, d
	or		e
	ret		z
	dec		hl
	call	out_no
	inc		hl
	ld		c, (hl)
	inc		hl
	ld		b, (hl)
	inc		hl
	ld		de, (df_cc)
	ld		a, 0x7f
	ld		(de), a
	inc		de
	push	hl
	ld		hl, 0x001d
	add		hl, de
	add		hl, bc
	sbc		hl, sp
	pop		hl
	ret		nc
	ldir
	ex		de, hl
	pop		de
	call	set_stk_b
	jr		ended_2

; THE 'NEWLINE KEY' ROUTINE
n_l_key:
	call	line_ends
	ld		hl, lower
	bit		5, (iy + _flagx)
	jr		nz, now_scan
	ld		hl, (e_line)
	ld		a, (hl)
	cp		0xff
	jr		z, stk_upper
	call	clear_prb
	call	cls

stk_upper:
	ld		hl, upper

now_scan:
	push	hl
	call	line_scan
	pop		hl
	call	cursor
	call	clear_one
	call	e_line_no
	jr		nz, n_l_inp
	ld		a, b
	or		c
	jp		nz, n_l_line
	dec		bc
	dec		bc
	ld		(ppc), bc
	ld		(iy + _df_size), 0x02
	ld		de, (d_file)
	jr		test_null

n_l_inp:
	cp		0x76
	jr		z, n_l_null
	ld		bc, (t_addr)
	call	loc_addr
	ld		de, (nxtlin)
	ld		(iy + _df_size), 0x02

test_null:
	rst		get_ch
	cp		0x76

n_l_null:
	jp		z, n_l_only
	ld		(iy + _flags), 0x80
	ex		de, hl

next_line:
	ld		(nxtlin), hl
	ex		de, hl
	call	temp_ptr
	call	line_run
	res		1, (iy + _flags)
	ld		a, 0xc0
	ld		(iy + _x_ptr_hi), a
	call	x_temp
	res		5, (iy + _flagx)
	bit		7, (iy + _err_nr)
	jr		z, stop_line
	ld		hl, (nxtlin)
	and		(hl)
	jr		nz, stop_line
	ld		d, (hl)
	inc		hl
	ld		e, (hl)
	ld		(ppc), de
	inc		hl
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	inc		hl
	ex		de, hl
	add		hl, de
	call	break_1
	jr		c, next_line
	ld		hl, err_nr
	bit		7, (hl)
	jr		z, stop_line
	ld		(hl), 0x0c

stop_line:
	bit		7, (iy + _pr_cc)
	call	z, copy_buff
	ld		bc, 0x0121
	call	loc_addr
	ld		a, (err_nr)
	ld		bc, (ppc)
	inc		a
	jr		z, report
	cp		0x09
	jr		nz, continue
	inc		bc

continue:
	ld		(oldppc), bc
	jr		nz, report
	dec		bc

report:
	call	out_code
	ld		a, 0x18
	rst		print_a
	call	out_num
	call	cursor_in
	jp		display_6

n_l_line:
	ld		(e_ppc), bc
	ld		hl, (ch_add)
	ex		de, hl
	ld		hl, n_l_only
	push	hl
	ld		hl, (stkbot)
	sbc		hl, de
	push	hl
	push	bc
	call	set_fast
	call	cls
	pop		hl
	call	line_addr
	jr		nz, copy_over
	call	next_one
	call	reclaim_2

copy_over:
	pop		bc
	ld		a, c
	dec		a
	or		b
	ret		z
	push	bc
	inc		bc
	inc		bc
	inc		bc
	inc		bc
	dec		hl
	call	make_room
	call	slow_fast
	pop		bc
	push	bc
	inc		de
	ld		hl, (stkbot)
	dec		hl
	lddr
	ld		hl, (e_ppc)
	ex		de, hl
	pop		bc
	ld		(hl), b
	dec		hl
	ld		(hl), c
	dec		hl
	ld		(hl), e
	dec		hl
	ld		(hl), d
	ret

; THE 'LIST' COMMAND ROUTINE
llist:
	set		1, (iy + _flags)

list:
	call	find_int
	ld		a, b
	and		0x3f
	ld		h, a
	ld		l, c
	ld		(e_ppc), hl
	call	line_addr

list_prog:
	ld		e, 0x00

until_end:
	call	out_line
	jr		until_end

; THE 'PRINT A BASIC LINE' SUBROUTINE
out_line:
	ld		bc, (e_ppc)
	call	cp_lines
	ld		d, 0x92
	jr		z, test_end
	ld		de, 0x0000
	rl		e

test_end:
	ld		(iy + _breg), e
	ld		a, (hl)
	cp		0x40
	pop		bc
	ret		nc
	push	bc
	call	out_no
	inc		hl
	ld		a, d
	rst		print_a
	inc		hl
	inc		hl

copy_line:
	ld		(ch_add), hl
	set		0, (iy + _flags)

more_line:
	ld		bc, (x_ptr)
	ld		hl, (ch_add)
	and		a
	sbc		hl, bc
	jr		nz, test_num
	ld		a, 0xb8
	rst		print_a

test_num:
	ld		hl, (ch_add)
	ld		a, (hl)
	inc		hl
	call	number
	ld		(ch_add), hl
	jr		z, more_line
	cp		0x7f
	jr		z, out_curs
	cp		0x76
	jr		z, out_ch
	bit		6, a
	jr		z, not_token
	call	tokens
	jr		more_line

not_token:
	rst		print_a
	jr		more_line

out_curs:
	ld		a, (mode)
	ld		b, 0xab
	and		a
	jr		nz, flags_2
	ld		a, (flags)
	ld		b, 0xb0

flags_2:
	rra
	rra
	and		0x01
	add		a, b
	call	print_sp
	jr		more_line

; THE 'NUMBER' SUBROUTINE
number:
	cp		0x7e
	ret		nz
	inc		hl
	inc		hl
	inc		hl
	inc		hl
	inc		hl
	ret

; THE 'KEYBOARD DECODE' SUBROUTINE
decode:
	ld		d, 0x00
	sra		b
	sbc		a, a
	or		0x26
	ld		l, 0x05
	sub		l

key_line:
	add		a, l
	scf
	rr		c
	jr		c, key_line
	inc		c
	ret		nz
	ld		c, b
	dec		l
	ld		l, 0x01
	jr		nz, key_line
	ld		hl, 0x007d
	ld		e, a
	add		hl, de
	scf
	ret

; THE 'PRINTING' SUBROUTINE
lead_sp:
	ld		a, e
	and		a
	ret		m
	jr		print_ch

out_digit:
	xor		a

digit_inc:
	add		hl, bc
	inc		a
	jr		c, digit_inc
	sbc		hl, bc
	dec		a
	jr		z, lead_sp

out_code:
	ld		e, zero
	add		a, e

out_ch:
	and		a
	jr		z, print_sp

print_ch:
	res		0, (iy + _flags)

print_sp:
	exx
	push	hl
	bit		1, (iy + _flags)
	jr		nz, lprint_a
	call	enter_ch
	jr		print_exx

lprint_a:
	call	lprint_ch

print_exx:
	pop		hl
	exx
	ret

enter_ch:
	ld		d, a
	ld		bc, (s_posn)
	ld		a, c
	cp		0x21
	jr		z, test_low

test_n_l:
	ld		a, 0x76
	cp		d
	jr		z, write_n_l
	ld		hl, (df_cc)
	cp		(hl)
	ld		a, d
	jr		nz, write_ch
	dec		c
	jr		nz, expand_1
	inc		hl
	ld		(df_cc), hl
	ld		c, 0x21
	dec		b
	ld		(s_posn), bc

test_low:
	ld		a, b
	cp		(iy + _df_size)
	jr		z, report_5
	and		a
	jr		nz, test_n_l

report_5:
	ld		l, insufficient_room
	jp		error_3

expand_1:
	call	one_space
	ex		de, hl

write_ch:
	ld		(hl), a
	inc		hl
	ld		(df_cc), hl
	dec		(iy + _s_posn_lo)
	ret

write_n_l:
	ld		c, 0x21
	dec		b
	set		0, (iy + _flags)
	jp		loc_addr

; THE 'LPRINT-CH' SUBROUTINE
lprint_ch:
	cp		0x76
	jr		z, copy_buff
	ld		c, a
	ld		a, (pr_cc)
	and		0x7f
	cp		0x5c
	ld		l, a
	ld		h, 0x40
	call	z, copy_buff
	ld		(hl), c
	inc		l
	ld		(iy + _pr_cc), l
	ret

; THE 'COPY' COMMAND ROUTINE
copy:
	ld		d, 0x16
	ld		hl, (d_file)
	inc		hl
	jr		copy_x_d

copy_buff:
	ld		d, 0x01
	ld		hl, prbuff

copy_x_d:
	call	set_fast
	push	bc

copy_loop:
	push	hl
	xor		a
	ld		e, a

copy_time:
	out		(0xfb), a
	pop		hl

copy_brk:
	call	break_1
	jr		c, copy_cont
	rra
	out		(0xfb), a

report_d2:
	rst		error_1
	defb	0x0c

copy_cont:
	in		a, (0xfb)
	add		a, a
	jp		m, copy_end
	jr		nc, copy_brk
	push	hl
	push	de
	ld		a, d
	cp		0x02
	sbc		a, a
	and		e
	rlca
	and		e
	ld		d, a

copy_next:
	ld		c, (hl)
	ld		a, c
	inc		hl
	cp		0x76
	jr		z, copy_n_l
	push	hl
	sla		a
	add		a, a
	add		a, a
	ld		h, 0x0f
	rl		h
	add		a, e
	ld		l, a
	rl		c
	sbc		a, a
	xor		(hl)
	ld		c, a
	ld		b, 0x08

copy_bits:
	ld		a, d
	rlc		c
	rra
	ld		h, a

copy_wait:
	in		a, (0xfb)
	rra
	jr		nc, copy_wait
	ld		a, h
	out		(0xfb), a
	djnz	copy_bits
	pop		hl
	jr		copy_next

copy_n_l:
	in		a, (0xfb)
	rra
	jr		nc, copy_n_l
	ld		a, d
	rrca
	out		(0xfb), a
	pop		de
	inc		e
	bit		3, e
	jr		z, copy_time
	pop		bc
	dec		d
	jr		nz, copy_loop
	ld		a, 0x04
	out		(0xfb), a

copy_end:
	call	slow_fast
	pop		bc

; THE 'CLEAR PRINTER BUFFER' SUBROUTINE
clear_prb:
	ld		hl, 0x405c
	ld		(hl), 0x76
	ld		b, 0x20

prb_bytes:
	dec		hl
	ld		(hl), 0x00
	djnz	prb_bytes
	ld		a, l
	set		7, a
	ld		(pr_cc), a
	ret

; THE 'PRINT AT' SUBROUTINE
print_at:
	ld		a, 0x17
	sub		b
	jr		c, wrong_val

test_val:
	cp		(iy + _df_size)
	jp		c, report_5
	inc		a
	ld		b, a
	ld		a, 0x1f
	sub		c

wrong_val:
	jp		c, report_b
	add		a, 0x02
	ld		c, a

set_field:
	bit		1, (iy + _flags)
	jr		z, loc_addr
	ld		a, 0x5d
	sub		c
	ld		(pr_cc), a
	ret

; THE 'LOC_ADDR' SUBROUTINE
loc_addr:
	ld		(s_posn), bc
	ld		hl, (vars)
	ld		d, c
	ld		a, 0x22
	sub		c
	ld		c, a
	ld		a, 0x76
	inc		b

look_back:
	dec		hl
	cp		(hl)
	jr		nz, look_back
	djnz	look_back
	inc		hl
	cpir
	dec		hl
	ld		(df_cc), hl
	scf
	ret		po
	dec		d
	ret		z
	push	bc
	call	make_room
	pop		bc
	ld		b, c
	ld		h, d
	ld		l, e

expand_2:
	ld		(hl), 0x00
	dec		hl
	djnz	expand_2
	ex		de, hl
	inc		hl
	ld		(df_cc), hl
	ret

; THE 'EXPAND TOKENS' SUBROUTINE
tokens:
 		push	af
	call	token_add
	jr		nc, all_chars
	bit		0, (iy + _flags)
	jr		nz, all_chars
	xor		a
	rst		print_a

all_chars:
	ld		a, (bc)
	and		0x3f
	rst		print_a
	ld		a, (bc)
	inc		bc
	add		a, a
	jr		nc, all_chars
	pop		bc
	bit		7, b
	ret		z
	cp		comma
	jr		z, trail_sp
	cp		0x38
	ret		c

trail_sp:
	xor		a
	set		0, (iy + _flags)
	jp		print_sp

token_add:
	push	hl
	ld		hl, 0x0111
	bit		7, a
	jr		z, test_high
	and		0x3f

test_high:
	cp		0x43
	jr		nc, found
	ld		b, a
	inc		b

words:
	bit		7, (hl)
	inc		hl
	jr		z, words
	djnz	words
	bit		6, a
	jr		nz, comp_flag
	cp		0x18

comp_flag:
	ccf

found:
	ld		b, h
	ld		c, l
	pop		hl
	ret		nc
	ld		a, (bc)
	add		a, 0xe4
	ret

; THE 'ONE-SPACE' SUBROUTINE
one_space:
	ld		bc, 0x0001

; THE 'MAKE-ROOM' SUBROUTINE
make_room:
	push	hl
	call	test_room
	pop		hl
	call	pointers
	ld		hl, (stkend)
	ex		de, hl
	lddr
	ret

; THE 'CHANGE ALL POINTERS' SUBROUTINE
pointers:
	push	af
	push	hl
	ld		hl, d_file
	ld		a, 0x09

next_ptr:
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ex		(sp), hl
	and		a
	sbc		hl, de
	add		hl, de
	ex		(sp), hl
	jr		nc, ptr_done
	push	de
	ex		de, hl
	add		hl, bc
	ex		de, hl
	ld		(hl), d
	dec		hl
	ld		(hl), e
	inc		hl
	pop		de

ptr_done:
	inc		hl
	dec		a
	jr		nz, next_ptr
	ex		de, hl
	pop		de
	pop		af
	and		a
	sbc		hl, de
	ld		b, h
	ld		c, l
	inc		bc
	add		hl, de
	ex		de, hl
	ret

; THE 'LINE-ADDR' SUBROUTINE
line_addr:
	push	hl
	ld		hl, program
	ld		d, h
	ld		e, l

next_test:
	pop		bc
	call	cp_lines
	ret		nc
	push	bc
	call	next_one
	ex		de, hl
	jr		next_test

; THE 'COMPARE LINE NUMBERS' SUBROUTINE
cp_lines:
	ld		a, (hl)
	cp		b
	ret		nz
	inc		hl
	ld		a, (hl)
	dec		hl
	cp		c
	ret

; THE 'NEXT LINE OR VARIABLE' SUBROUTINE
next_one:
	push	hl
	ld		a, (hl)
	cp		0x40
	jr		c, lines
	bit		5, a
	jr		z, bit_5_nil
	add		a, a
	jp		m, next_five
	ccf

next_five:
	ld		bc, 0x0005
	jr		nc, next_lett
	ld		c, 0x11

next_lett:
	rla
	inc		hl
	ld		a, (hl)
	jr		nc, next_lett
	jr		next_add

lines:
	inc		hl

bit_5_nil:
	inc		hl
	ld		c, (hl)
	inc		hl
	ld		b, (hl)
	inc		hl

next_add:
	add		hl, bc
	pop		de

; THE 'DIFFERENCE' SUBROUTINE
differ:
	and		a
	sbc		hl, de
	ld		b, h
	ld		c, l
	add		hl, de
	ex		de, hl
	ret

; THE 'LINE ENDS' SUBROUTINE
line_ends:
	ld		b, (iy + _df_size)
	push	bc
	call	b_lines
	pop		bc
	dec		b
	jr		b_lines

; THE 'CLS' COMMAND ROUTINE
cls:
	ld		b, 0x18

b_lines:
	res		1, (iy + _flags)
	ld		c, 0x21
	push	bc
	call	loc_addr
	pop		bc
	ld		a, (ramtop_hi)
	cp		0x4d
	jr		c, collapsed
	set		7, (iy + _s_posn_hi)

clear_loc:
	xor		a
	call	print_sp
	ld		hl, (s_posn)
	ld		a, l
	or		h
	and		0x7e
	jr		nz, clear_loc
	jp		loc_addr

collapsed:
	ld		d, h
	ld		e, l
	dec		hl
	ld		c, b
	ld		b, 0x00
	ldir
	ld		hl, (vars)

; THE 'RECLAIMING' SUBROUTINES
reclaim_1:
	call	differ

reclaim_2:
	push	bc
	ld		a, b
	cpl
	ld		b, a
	ld		a, c
	cpl
	ld		c, a
	inc		bc
	call	pointers
	ex		de, hl
	pop		hl
	add		hl, de
	push	de
	ldir
	pop		hl
	ret

; THE 'E-LINE NUMBER' SUBROUTINE
e_line_no:
	ld		hl, (e_line)
	call	temp_ptr
	rst		get_ch
	bit		5, (iy + _flagx)
	ret		nz
	ld		hl, 0x405d		; mem_0_1st
	ld		(stkend), hl
	call	int_to_fp
	call	fp_to_bc
	jr		c, no_number
	ld		hl, 0xd8f0
	add		hl, bc

no_number:
	jp		c, report_c
	cp		a
	jp		set_mem

; THE 'REPORT & LINE NUMBER' PRINTING SUBROUTINES
out_num:
	push	de
	push	hl
	xor		a
	bit		7, b
	jr		nz, units
	ld		h, b
	ld		l, c
	ld		e, 0xff
	jr		thousand

out_no:
	push	de
	ld		d, (hl)
	inc		hl
	ld		e, (hl)
	push	hl
	ex		de, hl
	ld		e, 0x00

thousand:
	ld		bc, 0xfc18
	call	out_digit
	ld		bc, 0xff9c
	call	out_digit
	ld		c, 0xf6
	call	out_digit
	ld		a, l

units:
	call	out_code
	pop		hl
	pop		de
	ret

; THE 'UNSTACK_Z' SUBROUTINE
unstack_z:
	call	syntax_z
	pop		hl
	ret		z
	jp		(hl)

; THE 'LPRINT' COMMAND ROUTINE
lprint:
	set		1, (iy + _flags)

; THE 'PRINT' COMMAND ROUTINE
print:
	ld		a, (hl)
	cp		0x76
	jp		z, print_end

print_1:
	sub		0x1a
	adc		a, 0x00
	jr		z, spacing
	cp		0xa7
	jr		nz, not_at
	rst		next_ch
	call	class_6
	cp		comma
	jp		nz, report_c
	rst		next_ch
	call	class_6
	call	syntax_on
	rst		fp_calc
	defb	exchange
	defb	end_calc
	call	stk_to_bc
	call	print_at
	jr		print_on

not_at:
	cp		0xa8
	jr		nz, not_tab
	rst		next_ch
	call	class_6
	call	syntax_on
	call	stk_to_a
	jp		nz, report_b
	and		0x1f
	ld		c, a
	bit		1, (iy + _flags)
	jr		z, tab_test
	sub		(iy + _pr_cc)
	set		7, a
	add		a, 0x3c
	call	nc, copy_buff

tab_test:
	add		a, (iy + _s_posn_lo)
	cp		0x21
	ld		a, (s_posn_hi)
	sbc		a, 0x01
	call	test_val
	set		0, (iy + _flags)
	jr		print_on

not_tab:
	call	scanning
	call	print_stk

print_on:
	rst		get_ch
	sub		0x1a
	adc		a, 0x00
	jr		z, spacing
	call	check_end
	jp		print_end

spacing:
	call	nc, field
	rst		next_ch
	cp		0x76
	ret		z
	jp		print_1

syntax_on:
	call	syntax_z
	ret		nz
	pop		hl
	jr		print_on

print_stk:
	call	unstack_z
	bit		6, (iy + _flags)
	call	z, stk_fetch
	jr		z, pr_str_4
	jp		print_fp

pr_str_1:
	ld		a, 0x0b

pr_str_2:
	rst		print_a

pr_str_3:
	ld		de, (x_ptr)

pr_str_4:
	ld		a, b
	or		c
	dec		bc
	ret		z
	ld		a, (de)
	inc		de
	ld		(x_ptr), de
	bit		6, a
	jr		z, pr_str_2
	cp		0xc0
	jr		z, pr_str_1
	push	bc
	call	tokens
	pop		bc
	jr		pr_str_3

print_end:
	call	unstack_z
	ld		a, 0x76
	rst		print_a
	ret

field:
	call	unstack_z
	set		0, (iy + _flags)
	xor		a
	rst		print_a
	ld		bc, (s_posn)
	ld		a, c
	bit		1, (iy + _flags)
	jr		z, centre
	ld		a, 0x5d
	sub		(iy + _pr_cc)

centre:
	ld		c, 0x11
	cp		c
	jr		nc, right
	ld		c, 0x01

right:
	call	set_field
	ret

; THE 'PLOT & UNPLOT' COMMAND ROUTINES
plot_unp:
	call	stk_to_bc
	ld		(coords), bc
	ld		a, 0x2b
	sub		b
	jp		c, report_b
	ld		b, a
	ld		a, 0x01
	sra		b
	jr		nc, columns
	ld		a,  0x04

columns:
	sra		c
	jr		nc, find_addr
	rlca

find_addr:
	push	af
	call	print_at
	ld		a, (hl)
	rlca
	cp		open_bracket
	jr		nc, table_ptr
	rrca
	jr		nc, sq_saved
	xor		0x8f

sq_saved:
	ld		b, a

table_ptr:
	ld		de, 0x0c9e
	ld		a, (t_addr)
	sub		e
	jp		m, plot
	pop		af
	cpl
	and		b
	jr		unplot

plot:
	pop		af
	or		b

unplot:
	cp		0x08
	jr		c, plot_end
	xor		0x8f

plot_end:
	exx
	rst		print_a
	exx
	ret

; the 'stk_to_bc' subroutine
stk_to_bc:
	call	stk_to_a
	ld		b, a
	push	bc
	call	stk_to_a
	ld		e, c
	pop		bc
	ld		d, c
	ld		c, a
	ret

; THE 'STK-TO-A' SUBROUTINE
stk_to_a:
	call	fp_to_a
	jp		c, report_b
	ld		c, 0x01
	ret		z
	ld		c, 0xff
	ret

; THE 'SCROLL' COMMAND ROUTINE
scroll:
	ld		b, (iy + _df_size)
	ld		c, 0x21
	call	loc_addr
	call	one_space
	ld		a, (hl)
	ld		(de), a
	inc		(iy + _s_posn_hi)
	ld		hl, (d_file)
	inc		hl
	ld		d, h
	ld		e, l
	cpir
	jp		reclaim_1

; THE 'SYNTAX TABLES'
offst_tbl:
	defb	p_lprint - $
	defb	p_llist - $
	defb	p_stop - $
	defb	p_slow - $
	defb	p_fast - $
	defb	p_new - $
	defb	p_scroll - $
	defb	p_cont - $
	defb	p_dim - $
	defb	p_rem - $
	defb	p_for - $
	defb	p_goto - $
	defb	p_gosub - $
	defb	p_input - $
	defb	p_load - $
	defb	p_list - $
	defb	p_let - $
	defb	p_pause - $
	defb	p_next - $
	defb	p_poke - $
	defb	p_print - $
	defb	p_plot - $
	defb	p_run - $
	defb	p_save - $
	defb	p_rand - $
	defb	p_if - $
	defb	p_cls - $
	defb	p_unplot - $
	defb	p_clear - $
	defb	p_return - $
	defb	p_copy - $

p_let:
	defb	var_rqd, equals, expr_num_str

p_goto:
	defb	num_exp, no_f_ops
	defw		goto

p_if:
	defb	num_exp, tk_then, var_syn
	defw		fn_if

p_gosub:
	defb	num_exp, no_f_ops
	defw		gosub

p_stop:
	defb	no_f_ops
	defw		stop

p_return:
	defb	no_f_ops
	defw		return

p_for:
	defb	chr_var, equals, num_exp, tk_to, num_exp, var_syn
	defw		for

p_next:
	defb	chr_var, no_f_ops
	defw		next

p_print:
	defb	var_syn
	defw		print

p_input:
	defb	var_rqd, no_f_ops
	defw		input

p_dim:
	defb	var_syn
	defw		dim

p_rem:
	defb	var_syn
	defw		rem

p_new:
	defb	no_f_ops
	defw		new

p_run:
	defb	num_exp_0
	defw		run

p_list:
	defb	num_exp_0
	defw		list

p_poke:
	defb	num_exp, comma, num_exp, no_f_ops
	defw		poke

p_rand:
	defb	num_exp_0
	defw		rand

p_load:
	defb	var_syn
	defw		load

p_save:
	defb	var_syn
	defw		save

p_cont:
	defb	no_f_ops
	defw		cont

p_clear:
	defb	no_f_ops
	defw		clear

p_cls:
	defb	no_f_ops
	defw		cls

p_plot:
	defb	num_exp, comma, num_exp, no_f_ops
	defw		plot_unp

p_unplot:
	defb	num_exp, comma, num_exp, no_f_ops
	defw		plot_unp

p_scroll:
	defb	no_f_ops
	defw		scroll

p_pause:
	defb	num_exp, no_f_ops
	defw		pause

p_slow:
	defb	no_f_ops
	defw		slow

p_fast:
	defb	no_f_ops
	defw		fast

p_copy:
	defb	no_f_ops
	defw		copy

p_lprint:
	defb	var_syn
	defw		lprint

p_llist:
	defb	num_exp_0
	defw		llist

; THE 'LINE SCANNING' ROUTINE
line_scan:
	ld		(iy + _flags), 0x01
	call	e_line_no

line_run:
	call	set_mem
	ld		hl, err_nr
	ld		(hl), 0xff
	ld		hl, flagx
	bit		5, (hl)
	jr		z, line_null
	cp		0xe3
	ld		a, (hl)
	jp		nz, input_rep
	call	syntax_z
	ret		z
	rst		error_1
	defb	0x0c

; THE 'STOP' COMMAND ROUTINE
stop:
report_9:
	rst		error_1
	defb	stop_command

line_null:
	rst		get_ch
	ld		b, 0
	cp		0x76
	ret		z
	ld		c, a
	rst		next_ch
	ld		a, c
	sub		0xe1		; last command
	jr		c, report_c2
	ld		c, a
	ld		hl, offst_tbl
	add		hl, bc
	ld		c, (hl)
	add		hl, bc
	jr		get_param

scan_loop:
	ld		hl, (t_addr)

get_param:
	ld		a, (hl)
	inc		hl
	ld		(t_addr), hl
	ld		bc, 0x0cf4
	push	bc
	ld		c, a
	cp		0x0b
	jr		nc, separator
	ld		hl, 0x0d16
	ld		b, 0x00
	add		hl, bc
	ld		c, (hl)
	add		hl, bc
	push	hl
	rst		get_ch 
	ret

separator:
	rst		get_ch
	cp		c
	jr		nz, report_c2
	rst		next_ch
	ret

; THE 'COMMAND CLASS' TABLE
class_tbl:
	defb	class_0 - $
	defb	class_1 - $
	defb	class_2 - $
	defb	class_3 - $
	defb	class_4 - $
	defb	class_5 - $
	defb	class_6 - $

; THE 'CHECK-END' SUBROUTINE
check_end:
	call	syntax_z
	ret		nz
	pop		bc

check_2:
	ld		a, (hl)
	cp		0x76
	ret		z

report_c2:
	jr		report_c

; THE 'COMMAND CLASS 3' ROUTINE
class_3:
	cp		0x76
	call	no_to_stk

; THE 'COMMAND CLASS 0' ROUTINE
class_0:
	cp		a

; THE 'COMMAND CLASS 5' ROUTINE
class_5:
	pop		bc
	call	z, check_end
	ex		de, hl
	ld		hl, (t_addr)
	ld		c, (hl)
	inc		hl
	ld		b, (hl)
	ex		de, hl

class_end:
	push	bc
	ret

; THE 'COMMAND CLASS 1' ROUTINE
class_1:
	call	look_vars

class_4_2:
	ld		(iy + _flagx), 0x00
	jr		nc, set_stk
	set		1, (iy + _flagx)
	jr		nz, set_strln

report_2:
	rst		error_1
	defb	missing_variable

set_stk:
	call	z, stk_var
	bit		6, (iy + _flags)
	jr		nz, set_strln
	xor		a
	call	syntax_z
	call	nz, stk_fetch
	ld		hl, flagx
	or		(hl)
	ld		(hl), a
	ex		de, hl

set_strln:
	ld		(strlen), bc
	ld		(dest), hl

rem:
	ret

; THE 'COMMAND CLASS 2' ROUTINE
class_2:
	pop		bc
	ld		a, (flags)

input_rep:
	push	af
	call	scanning
	pop		af
	ld		bc, 0x1321
	ld		d, (iy + _flags)
	xor		d
	and		%01000000
	jr		nz, report_c
	bit		7, d
	jr		nz, class_end
	jr		check_2

; THE 'COMMAND CLASS 4' ROUTINE
class_4:
	call	look_vars
	push	af
	ld		a, c
	or		%10011111
	inc		a
	jr		nz, report_c
	pop		af
	jr		class_4_2

; THE 'COMMAND CLASS 6' ROUTINE
class_6:
	call	scanning
	bit		6, (iy + _flags)
	ret		nz

report_c:
	rst		error_1
	defb	no_numeric_value

; THE 'NO-TO-STK' SUBROUTINE
no_to_stk:
	jr		nz, class_6
	call	syntax_z
	ret		z
	rst		fp_calc
	defb	stk_zero
	defb	end_calc
	ret

; THE 'SYNTAX-Z' SUBROUTINE
syntax_z:
	bit 7, (iy + 0x01)		; flags
	ret 

; THE 'IF' COMMAND ROUTINE
fn_if:
	call	syntax_z
	jr		z, if_end
	rst		fp_calc
	defb	delete
	defb	end_calc
	ld		a, (de)
	and		a
	ret		z

if_end:
	jp		line_null

; THE 'FOR' COMMAND ROUTINE
for:
	cp		0xe0
	jr		nz, use_one
	rst		next_ch
	call	class_6
	call	check_end
	jr		reorder

use_one:
	call	check_end
	rst		fp_calc
	defb	stk_one
	defb	end_calc

reorder:
	rst		fp_calc
	defb	st_mem_0
	defb	delete
	defb	exchange
	defb	get_mem_0
	defb	exchange
	defb	end_calc
	call	let
	ld		(mem), hl
	dec		hl
	ld		a, (hl)
	set		7, (hl)
	ld		bc, 0x0006
	add		hl, bc
	rlca
	jr		c, lmt_step
	sla		c
	call	make_room
	inc		hl

lmt_step:
	push	hl
	rst		fp_calc
	defb	delete
	defb	delete
	defb	end_calc
	pop		hl
	ex		de, hl
	ld		c, 0x0a
	ldir
	ld		hl, (ppc)
	ex		de, hl
	inc		de
	ld		(hl), e
	inc		hl
	ld		(hl), d
	call	next_loop
	ret		nc
	bit		7, (iy + _ppc_hi)
	ret		nz
	ld		b, (iy + _strlen)
	res		6, b
	ld		hl, (nxtlin)

nxtlin_no:
	ld		a, (hl)
	and		0xc0
	jr		nz, for_end
	push	bc
	call	next_one
	pop		bc
	inc		hl
	inc		hl
	inc		hl
	call	cursor_so
	rst		get_ch
	cp		0xf3
	ex		de, hl
	jr		nz,  nxtlin_no
	ex		de, hl
	rst		next_ch
	ex		de, hl
	cp		b
	jr		nz, nxtlin_no

for_end:
	ld		(nxtlin), hl
	ret

; THE 'NEXT' COMMAND ROUTINE
next:
	bit		1, (iy + _flagx)
	jp		nz, report_2
	ld		hl, (dest)
	bit		7, (hl)
	jr		z, report_1
	inc		hl
	ld		(mem), hl
	rst		fp_calc
	defb	get_mem_0
	defb	get_mem_2
	defb	addition
	defb	st_mem_0
	defb	delete
	defb	end_calc
	call	next_loop
	ret		c
	ld		hl, (mem)
	ld		de, 0x000f
	add		hl, de
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ex		de, hl
	jr		goto_2

report_1:
	rst		error_1
	defb	next_without_for

; THE 'NEXT-LOOP' SUBROUTINE
next_loop:
	rst		fp_calc
	defb	get_mem_1
	defb	get_mem_0
	defb	get_mem_2
	defb	less_0
	defb	jump_true, lmt_v_val - $ - 1
	defb	exchange

lmt_v_val:
	defb	subtract
	defb	greater_0
	defb	jump_true, imposs - $ - 1
	defb	end_calc
	and		a
	ret

imposs:
	defb	end_calc
	scf
	ret

; THE 'RAND' COMMAND ROUTINE
rand:
	call	find_int
	ld		a, b
	or		c
	jr		nz, set_seed
	ld		bc, (frames)

set_seed:
	ld		(seed), bc
	ret

; THE 'CONT' COMMAND ROUTINE
cont:
	ld		hl, (oldppc)
	jr		goto_2

; THE 'GOTO' COMMAND ROUTINE
goto:
	call	find_int
	ld		h, b
	ld		l, c

goto_2:
	ld		a, h
	cp		0xf0
	jr		nc, report_b
	call	line_addr
	ld		(nxtlin), hl
	ret

; THE 'POKE' COMMAND ROUTINE
poke:
	call	fp_to_a
	jr		c, report_b
	jr		z, poke_save
	neg

poke_save:
	push	af
	call	find_int
	pop		af
	bit		7, (iy + _err_nr)
	ret		z
	ld		(bc), a
	ret

; THE 'FIND-INT' SUBROUTINE
find_int:
	call	fp_to_bc
	jr		c, report_b
	ret		z

report_b:
	rst		error_1
	defb	integer_out_of_range

; THE 'RUN' COMMAND ROUTINE
run:
	call	goto
	jp		clear

; THE 'GOSUB' COMMAND ROUTINE
gosub:
	ld		hl, (ppc)
	inc		hl
	ex		(sp), hl
	push	hl
	ld		(err_sp), sp
	call	goto
	ld		bc, 0x0006

; THE 'TEST-ROOM' SUBROUTINE
test_room:
	ld		hl, (stkend)
	add		hl, bc
	jr		c, report_4
	ex		de, hl
	ld		hl, 0x0024
	add		hl, de
	sbc		hl, sp
	ret		c

report_4:
	ld		l, out_of_ram
	jp		error_3

; THE 'RETURN' COMMAND ROUTINE
return:
	pop		hl
	ex		(sp), hl
	ld		a, h
	cp		0x3e
	jr		z, report_7
	ld		(err_sp), sp
	jr		goto_2

report_7:
	ex		(sp), hl
	push	hl
	rst		error_1
	defb	return_without_gosub

; THE 'INPUT' COMMAND ROUTINE
input:
	bit		7, (iy + _ppc_hi)
	jr		nz, report_8
	call	x_temp
	ld		hl, flagx
	set		5, (hl)
	res		6, (hl)
	ld		a, (flags)
	and		0x40
	ld		bc, 0x0002
	jr		nz, prompt
	ld		c, 0x04

prompt:
	or		(hl)
	ld		(hl), a
	rst		bc_spaces
	ld		(hl), 0x76
	ld		a, c
	rrca
	rrca
	jr		c, enter_cur
	ld		a, 0x0b
	ld		(de), a
	dec		hl
	ld		(hl), a

enter_cur:
	dec		hl
	ld		(hl), 0x7f
	ld		hl, (s_posn)
	ld		(t_addr), hl
	pop		hl
	jp		lower

report_8:
	rst		error_1
	defb	input_as_direct_command

; THE 'FAST' COMMAND ROUTINE
fast:
	call	set_fast
	res		6, (iy + _cdflag)
	ret

; THE 'SLOW' COMMAND ROUTINE
slow:
	set		6, (iy + _cdflag)
	jp		slow_fast

; THE 'PAUSE' COMMAND ROUTINE
pause:
	call	find_int
	call	set_fast
	ld		h, b
	ld		l, c
	call	display_p
	ld		(iy + _frames_hi), 0xff
	call	slow_fast
	jr		d_bounce

; THE 'BREAK-1' SUBROUTINE
break_1:
	ld		a, 0x7f
	in		a, (0xfe)
	rra

; THE 'DEBOUNCE' SUBROUTINE
d_bounce:
	res		0, (iy + _cdflag)
	ld		a, 0xff
	ld		(debounce), a
	ret

; THE 'SCANNING' SUBROUTINE
scanning:
	rst 		get_ch
	ld		b, 0x00
	push	bc

s_rnd:
	cp		0x40
	jr		nz, s_pi
	call	syntax_z
	jr		z, s_rnd_end
	ld		bc, (seed)
	call	stack_bc
	rst		fp_calc
	defb	stk_one
	defb	addition
	defb	stk_data
	defb	0x37
	defb	0x16
	defb	multiply
	defb	stk_data
	defb	0x80
	defb	0x41
	defb	0x00, 0x00, 0x80
	defb	n_mod_m
	defb	delete
	defb	stk_one
	defb	subtract
	defb	duplicate
	defb	end_calc
	call	fp_to_bc
	ld		(seed), bc
	ld		a, (hl)
	and		a
	jr		z, s_rnd_end
	sub		16
	ld		(hl), a

s_rnd_end:
	jr		s_pi_end

s_pi:
	cp		0x42
	jr		nz, s_inkeys
	call	syntax_z
	jr		z, s_pi_end
	rst		fp_calc
	defb	stk_pi_div_2
	defb	end_calc
	inc		(hl)

s_pi_end:
	rst		next_ch
	jp		s_numeric


s_inkeys:
	cp		tk_inkeys
	jr		nz, s_alphnum
	call	keyboard
	ld		b, h
	ld		c, l
	ld		d, c
	inc		d
	call	nz, decode
	ld		a, d
	adc		a, d
	ld		b, d
	ld		c, a
	ex		de, hl
	jr		s_string

s_alphnum:
	call	alphanum
	jr		c, s_let_num
	cp		period
	jp		z, s_decimal
	ld		bc, 0x09d8
	cp		minus
	jr		z, s_push_p0
	cp		open_bracket
	jr		nz, s_quote
	call	ch_add_inc
	call	scanning
	cp		close_bracket
	jr		nz, s_rprt_c1
	call	ch_add_inc
	jr		s_cont_1

s_quote:
	cp		double_quote
	jr		nz, s_funct
	call	ch_add_inc
	push	hl
	jr		s_q_end

s_q_next:
	call	ch_add_inc

s_q_end:
	cp		0x0b
	jr		nz, s_n_lerr
	pop		de
	and		a
	sbc		hl, de
	ld		b, h
	ld		c, l

s_string:
	ld		hl, flags
	res		6, (hl)
	bit		7, (hl)
	call	nz, stk_store
	rst		next_ch

s_cont_1:
	jp		s_cont_3

s_n_lerr:
	cp		ctrl_newline
	jr		nz, s_q_next

s_rprt_c1:
	jp		report_c

s_funct:
	sub		0xc4
	jr		c, s_rprt_c1
	ld		bc, 0x04ec
	cp		0x13
	jr		z, s_push_p0
	jr		nc, s_rprt_c1
	ld		b, 0x10
	add		a, 0xd9
	ld		c, a
	cp		0xdc
	jr		nc, s_no_to_s
	res		6, c

s_no_to_s:
	cp		0xea
	jr		c, s_push_p0
	res		7, c

s_push_p0:
	push	bc
	rst		next_ch
	jp		s_rnd

s_let_num:
	cp		0x26
	jr		c, s_decimal
	call	look_vars
	jp		c, report_2
	call	z, stk_var
	ld		a, (flags)
	cp		0xc0
	jr		c, s_cont_2
	inc		hl
	ld		de, (stkend)
	call	fp_move_fp
	ex		de, hl
	ld		(stkend), hl
	jr		s_cont_2

s_decimal:
	call	syntax_z
	jr		nz, s_stk_dec
	call	dec_to_fp
	rst		get_ch
	ld		bc, 0x0006
	call	make_room
	inc		hl
	ld		(hl), ctrl_number
	inc		hl
	ex		de, hl
	ld		hl, (stkend)
	ld		c, 5
	and		a
	sbc		hl, bc
	ld		(stkend), hl
	ldir
	ex		de, hl
	dec		hl
	call	cursor_so
	jr		s_numeric

s_stk_dec:
	rst		next_ch
	cp		ctrl_number
	jr		nz, s_stk_dec
	inc		hl
	ld		de, (stkend)
	call	fp_move_fp
	ld		(stkend), de
	ld		(ch_add), hl

s_numeric:
	set		6, (iy + _flags)

s_cont_2:
	rst		get_ch

s_cont_3:
	cp		open_bracket
	jr		nz, s_opertr
	bit		6, (iy + _flags)
	jr		nz, s_loop
	call	slicing
	rst		next_ch
	jr		s_cont_3

s_opertr:
	ld		bc, 0x00c3
	cp		close_angle
	jr		c, s_loop
	sub		0x16
	jr		nc, s_high_op
	add		a, 0x0d
	jr		s_end_op

s_high_op:
	cp		0x03
	jr		c, s_end_op
	sub		0xc2
	jr		c, s_loop
	cp		0x06
	jr		nc, s_loop
	add		a, 0x03

s_end_op:
	add		a, c
	ld		c, a
	ld		hl, 0x104c
	add		hl, bc
	ld		b, (hl)

s_loop:
	pop		de
	ld		a, d
	cp		b
	jr		c, s_tighter
	and		a
	jp		z, jp_get_ch
	push	bc
	push	de
	call	syntax_z
	jr		z, s_syntest
	ld		a, e
	and		0x3f
	ld		b, a
	rst		fp_calc
	defb	calc_2
	defb	end_calc
	jr		s_runtest

s_syntest:
	ld		a, e
	xor		(iy + 0x01)		; flags
	and		%01000000

s_rport_c2:
	jp		nz, report_c

s_runtest:
	pop		de
	ld		hl, flags
	set		6, (hl)
	bit		7, e
	jr		nz, s_endloop
	res		6, (hl)

s_endloop:
	pop		bc
	jr		s_loop

s_tighter:
	push	de
	ld		a, c
	bit		6, (iy + _flags)
	jr		nz, s_next
	and		%00111111
	add		a, 8
	ld		c, a
	cp		str_and_no
	jr		nz, s_not_and
	set		6, c
	jr		s_next

s_not_and:
	jr		c, s_rport_c2
	cp		strs_add
	jr		z, s_next
	set		7, c

s_next:
	push	bc
	rst		next_ch
	jp		s_rnd

; THE PRIORITY TABLE
pri_tbl:
	defb	0x06		; -
	defb	0x08		; *
	defb	0x08		; /
	defb	0x0a		; **
	defb	0x02		; OR
	defb	0x03		; AND
	defb	0x05		; <=
	defb	0x05		; >=
	defb	0x05		; <>
	defb	0x05		; >
	defb	0x05		; <
	defb	0x05		; =
	defb	0x06		; +

; THE 'LOOK-VARS' SUBROUTINE
look_vars:
	set		6, (iy + _flags)
	rst		get_ch
	call	alpha
	jp		nc, report_c
	push	hl
	ld		c, a
	rst		next_ch
	push	hl
	res		5, c
	cp		open_bracket
	jr		z, v_run_syn
	set		6, c
	cp		dollar
	jr		z, v_str_var
	set		5, c

v_char:
	call	alphanum
	jr		nc, v_run_syn
	res		6, c
	rst		next_ch
	jr		v_char

v_str_var:
	rst		next_ch
	res		6, (iy + _flags)

v_run_syn:
	ld		b, c
	call	syntax_z
	jr		nz, v_run
	ld		a, c
	and		0xe0
	set		7, a
	ld		c, a
	jr		v_syntax

v_run:
	ld		hl, (vars)

v_each:
	ld		a, (hl)
	and		0x7f
	jr		z, v_80_byte
	cp		c
	jr		nz, v_next
	rla
	add		a, a
	jp		p, v_found_2
	jr		c, v_found_2
	pop		de
	push	de
	push	hl

v_matches:
	inc		hl

v_spaces:
	ld		a, (de)
	inc		de
	and		a		; test space
	jr		z, v_spaces
	cp		(hl)
	jr		z, v_matches
	or		%10000000
	cp		(hl)
	jr		nz, v_get_ptr
	ld		a, (de)
	call	alphanum
	jr		nc, v_found_1

v_get_ptr:
	pop		hl

v_next:
	push	bc
	call	next_one
	ex		de, hl
	pop		bc
	jr		v_each


v_80_byte:
	set		7, b

v_syntax:
	pop		de
	rst		get_ch
	cp		open_bracket
	jr		z, v_pass
	set		5, b
	jr		v_end

v_found_1:
	pop		de

v_found_2:
	pop		de
	pop		de
	push	hl
	rst		get_ch

v_pass:
	call	alphanum
	jr		nc, v_end
	rst		next_ch
	jr		v_pass

v_end:
	pop		hl
	rl		b
	bit		6, b
	ret

; THE 'STK-VAR' SUBROUTINE
stk_var:
	xor		a
	ld		b, a
	bit		7, c
	jr		nz, sv_count
	bit		7, (hl)
	jr		nz, sv_arrays
	inc		a

sv_simpleS:
	inc		hl
	ld		c, (hl)
	inc		hl
	ld		b, (hl)
	inc		hl
	ex		de, hl
	call	stk_store
	rst		get_ch
	jp		sv_slice_query

sv_arrays:
	inc		hl
	inc		hl
	inc		hl
	ld		b, (hl)
	bit		6, c
	jr		z, sv_ptr
	dec		b
	jr		z, sv_simpleS
	ex		de, hl
	rst		get_ch
	cp		open_bracket
	jr		nz, report_3
	ex		de, hl

sv_ptr:
	ex		de, hl
	jr		sv_count

sv_comma:
	push	hl
	rst		get_ch
	pop		hl
	cp		comma
	jr		z, sv_loop
	bit		7, c
	jr		z, report_3
	bit		6, c
	jr		nz, sv_close
	cp		close_bracket
	jr		nz, sv_rpt_c
	rst		next_ch
	ret

sv_close:
	cp		close_bracket
	jr		z, sv_dim
	cp		tk_to
	jr		nz, sv_rpt_c

sv_ch_add:
	rst		get_ch
	dec		hl
	ld		(ch_add), hl
	jr		sv_slice

sv_count:
	ld		hl, 0x0000

sv_loop:
	push	hl
	rst		next_ch
	pop		hl 
	ld		a, c
	cp		%11000000
	jr		nz, sv_mult
	rst		get_ch
	cp		close_bracket
	jr		z, sv_dim
	cp		tk_to
	jr		z, sv_ch_add

sv_mult:
	push	bc
	push	hl
	call	de_inc_to_de
	ex		(sp), hl
	ex		de, hl
	call	int_exp1
	jr		c, report_3
	dec		bc
	call	hl_hl_x_de
	add		hl, bc
	pop		de
	pop		bc
	djnz	sv_comma
	bit		7, c

sv_rpt_c:
	jr		nz, sl_rpt_c
	push	hl
	bit		6, c
	jr		nz, sv_elemS
	ld		b, d
	ld		c, e
	rst		get_ch
	cp		close_bracket
	jr		z, sv_number

report_3:
	rst		error_1
	defb	subscript_out_of_range 

sv_number:
	rst		next_ch
	pop		hl
	ld		de, 0x0005
	call	hl_hl_x_de
	add		hl, bc
	ret

sv_elemS:
	call	de_inc_to_de
	ex		(sp), hl
	call	hl_hl_x_de
	pop		bc
	add		hl, bc
	inc		hl
	ld		b, d
	ld		c, e
	ex		de, hl
	call	stk_st_0
	rst		get_ch
	cp		close_bracket
	jr		z, sv_dim
	cp		comma
	jr		nz, report_3

sv_slice:
	call	slicing

sv_dim:
	rst		next_ch

sv_slice_query:
	cp		open_bracket
	jr		z, sv_slice
	res		6, (iy + _flags)
	ret

; THE 'SLICING' SUBROUTINE
slicing:
	call	syntax_z
	call	nz, stk_fetch
	rst		next_ch
	cp		close_bracket
	jr		z, sl_store
	push	de
	xor		a
	push	af
	push	bc
	ld		de, 0x0001
	rst		get_ch
	pop		hl
	cp		tk_to
	jr		z, sl_second
	pop		af
	call	int_exp2
	push	af
	ld		d, b
	ld		e, c
	push	hl
	rst		get_ch
	pop		hl
	cp		tk_to
	jr		z, sl_second
	cp		close_bracket

sl_rpt_c:
	jp		nz, report_c
	ld		h, d
	ld		l, e
	jr		sl_define

sl_second:
	push	hl
	rst		next_ch
	pop		hl
	cp		close_bracket
	jr		z, sl_define
	pop		af
	call	int_exp2
	push	af
	rst		get_ch
	ld		h, b
	ld		l, c
	cp		close_bracket
	jr		nz, sl_rpt_c

; THE 'NEW' PARAMETERS ARE NOW DEFINED
sl_define:
	pop		af
	ex		(sp), hl
	add		hl, de
	dec		hl
	ex		(sp), hl
	and		a
	sbc		hl, de
	ld		bc, 0x0000
	jr		c, sl_over
	inc		hl
	and		a
	jp		m, report_3
	ld		b, h
	ld		c, l

sl_over:
	pop		de
	res		6, (iy + _flags)

sl_store:
	call	syntax_z
	ret		z

; THE 'STKSTORE' SUBROUTINE
stk_st_0:
	xor		a

stk_store:
	push	bc
	call	test_5_sp
	pop		bc
	ld		hl, (stkend)
	ld		(hl), a
	inc		hl
	ld		(hl), e
	inc		hl
	ld		(hl), d
	inc		hl
	ld		(hl), c
	inc		hl
	ld		(hl), b
	inc		hl
	ld		(stkend), hl
	res		6, (iy + _flags)
	ret

; THE 'INT:EXP' SUBROUTINE
int_exp1:
	xor		a

int_exp2:
	push	de
	push	hl
	push	af
	call	class_6
	pop		af
	call	syntax_z
	jr		z, i_restore
	push	af
	call	find_int
	pop		de
	ld		a, b
	or		c
	scf
	jr		z, i_carry
	pop		hl
	push	hl
	and		a
	sbc		hl, bc

i_carry:
	ld		a, d
	sbc		a, 0

i_restore:
	pop		hl
	pop		de
	ret



; THE 'DE, (DE+1)' SUBROUTINE
de_inc_to_de:
	ex		de, hl
	inc		hl
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ret

; THE 'HL=HL*DE' SUBROUTINE
hl_hl_x_de:
	call	syntax_z
	ret		z
	push	bc
	ld		b, 16
	ld		a, h
	ld		c, l
	ld		hl, 0x0000

hl_loop:
	add		hl, hl
	jr		c, hl_over
	rl		c
	rla
	jr		nc, hl_again
	add		hl, de

hl_over:
	jp		c, report_4

hl_again:
	djnz	hl_loop
	pop		bc
	ret

; THE 'LET' COMMAND ROUTINE
let:
	ld		hl, (dest)
	bit		1, (iy + _flagx)
	jr		z, l_exists
	ld		bc, 0x0005

l_each_ch:
	inc		bc
l_no_sp:
	inc		hl
	ld		a, (hl)
	and		a		; test space
	jr		z, l_no_sp
	call	alphanum
	jr		c, l_each_ch
	cp		dollar
	jp		z, l_news
	rst		bc_spaces
	push	de
	ld		hl, (dest)
	dec		de
	ld		a, c
	sub		6
	ld		b, a
	ld		a, 0x40
	jr		z, l_single

l_char:
	inc		hl
	ld		a, (hl)
	and		a		; test space
	jr		z, l_char
	inc		de
	ld		(de), a
	djnz	l_char
	or		%10000000
	ld		(de), a
	ld		a, %10000000

l_single:
	ld		hl, (dest)
	xor		(hl)
	pop		hl
	call	l_clear

l_numeric:
	push	hl
	rst		fp_calc
	defb	delete
	defb	end_calc
	pop		hl
	ld		bc, 0x0005
	and		a
	sbc		hl, bc
	jr		l_enter

l_exists:
	bit		6, (iy + _flags)
	jr		z, l_deletes
	ld		de, 0x0006
	add		hl, de
	jr		l_numeric

l_deletes:
	ld		hl, (dest)
	ld		bc, (strlen)
	bit		0, (iy + _flagx)
	jr		nz, l_adds
	ld		a, b
	or		c
	ret		z
	push	hl
	rst		bc_spaces
	push	de
	push	bc
	ld		d, h
	ld		e, l
	inc		hl
	ld		(hl), 0x00		; space
	lddr
	push	hl
	call	stk_fetch
	pop		hl
	ex		(sp), hl
	and		a
	sbc		hl, bc
	add		hl, bc
	jr		nc, l_length
	ld		b, h
	ld		c, l

l_length:
	ex		(sp), hl
	ex		de, hl
	ld		a, b
	or		c
	jr		z, l_in_w_s
	ldir

l_in_w_s:
	pop		bc
	pop		de
	pop		hl

l_enter:
	ex		de, hl
	ld		a, b
	or		c
	ret		z
	push	de
	ldir
	pop		hl
	ret

l_adds:
	dec		hl
	dec		hl
	dec		hl
	ld		a, (hl)
	push	hl
	push	bc
	call	l_string
	pop		bc
	pop		hl
	inc		bc
	inc		bc
	inc		bc
	jp		reclaim_2


l_news:
	ld		a, 0x60
	ld		hl, (dest)
	xor		(hl)

l_string:
	push	af
	call	stk_fetch
	ex		de, hl
	add		hl, bc
	push	hl
	inc		bc
	inc		bc
	inc		bc
	rst		bc_spaces
	ex		de, hl
	pop		hl
	dec		bc
	dec		bc
	push	bc
	lddr
	ex		de, hl
	pop		bc
	dec		bc
	ld		(hl), b
	dec		hl
	ld		(hl), c
	pop		af

l_clear:
	push	af
	call	reclaim_3
	pop		af
	dec		hl
	ld		(hl), a
	ld		hl, (stkbot)
	ld		(e_line), hl
	dec		hl
	ld		(hl), 0x80
	ret

; THE 'STK_FETCH' SUBROUTINE
stk_fetch:
	ld		hl, (stkend)
	dec		hl
	ld		b, (hl)
	dec		hl
	ld		c, (hl)
	dec		hl
	ld		d, (hl)
	dec		hl
	ld		e, (hl)
	dec		hl
	ld		a, (hl)
	ld		(stkend), hl
	ret

; THE 'DIM' COMMAND ROUTINE
dim:
	call	look_vars

d_rport_c:
	jp		nz, report_c
	call	syntax_z
	jr		nz, d_run
	res		6, c
	call	stk_var
	call	check_end

d_run:
	jr		c, d_letter
	push	bc
	call	next_one
	call	reclaim_2
	pop		bc

d_letter:
	set		7, c
	ld		b, 0
	push	bc
	ld		hl, 0x0001
	bit		6, c
	jr		nz, d_size
	ld		l, 5

d_size:
	ex		de, hl

d_no_loop:
	rst		next_ch
	ld		h, 0x40
	call	int_exp1
	jp		c, report_3
	pop		hl
	push	bc
	inc		h
	push	hl
	ld		h, b
	ld		l, c
	call	hl_hl_x_de
	ex		de, hl
	rst		get_ch
	cp		comma
	jr		z, d_no_loop
	cp		close_bracket
	jr		nz, d_rport_c
	rst		next_ch
	pop		bc
	ld		a, c
	ld		l, b
	ld		h, 0
	inc		hl
	inc		hl
	add		hl, hl
	add		hl, de
	jp		c, report_4
	push	de
	push	bc
	push	hl
	ld		b, h
	ld		c, l
	ld		hl, (e_line)
	dec		hl
	call	make_room
	inc		hl
	ld		(hl), a
	pop		bc
	dec		bc
	dec		bc
	dec		bc
	inc		hl
	ld		(hl), c
	inc		hl
	ld		(hl), b
	pop		af
	inc		hl
	ld		(hl), a 
	ld		h, d
	ld		l, e
	dec		de
	ld		(hl), 0
	pop		bc
	lddr

; THE 'DIMENSION_SIZES' ARE NOW ENTERED
dim_sizes:
	pop		bc
	ld		(hl), b
	dec		hl
	ld		(hl), c
	dec		hl
	dec		a
	jr		nz, dim_sizes
	ret

; THE 'RESERVE' SUBROUTINE
reserve:
	ld		hl, (stkbot)
	dec		hl
	call	make_room
	inc		hl
	inc		hl
	pop		bc
	ld		(e_line), bc
	pop		bc
	ex		de, hl
	inc		hl
	ret

; THE 'CLEAR' COMMAND ROUTINE
clear:
	ld		hl, (vars)
	ld		(hl), 0x80
	inc		hl
	ld		(e_line), hl

; THE 'X-TEMP' SUBROUTINE
x_temp:
	ld		hl, (e_line)

; THE 'SETSTK-B' SUBROUTINE
set_stk_b:
	ld		(stkbot), hl

set_stk_e:
	ld		(stkend), hl
	ret

; THE 'CURSOR-IN' SUBROUTINE
cursor_in:
	ld		hl, (e_line)
	ld		(hl), 0x7f
	inc		hl
	ld		(hl), 0x76
	inc		hl
	ld		(iy + _df_size), 0x02
	jr		set_stk_b

; THE 'SET-MEM' SUBROUTINE
set_mem:
	ld		hl, 0x405d		; membot
	ld		(mem), hl
	ld		hl, (stkbot)
	jr		set_stk_e

; THE 'RECLAIM-3' SUBROUTINE
reclaim_3:
	ld		de, (e_line)
	jp		reclaim_1

; THE 'ALPHA' SUBROUTINE
alpha:
	cp		capital_a
	jr		alpha_2

; THE 'ALPHANUM' SUBROUTINE
alphanum:
	cp		zero

alpha_2:
	ccf
	ret		nc
	cp		0x40		; test 'Z' + 1
	ret

; THE 'DECIMAL TO FLOATING_POINT' SUBROUTINE
dec_to_fp:
	call	int_to_fp
	cp		period
	jr		nz, e_format
	rst		fp_calc
	defb	stk_one
	defb	st_mem_0
	defb	delete
	defb	end_calc

nxt_dgt_1:
	rst		next_ch
	call	stk_digit
	jr		c, e_format
	rst		fp_calc
	defb	get_mem_0
	defb	stk_ten
	defb	division		; should be multiply
	defb	st_mem_0
	defb	multiply		; should be division
	defb	addition
	defb	end_calc
	jr		nxt_dgt_1

e_format:
	cp		capital_e
	ret		nz
	ld		(iy + _membot), 0xff
	rst		next_ch
	cp		plus
	jr		z, sign_done
	cp		minus
	jr		nz, st_e_part
	inc		(iy + _membot)

sign_done:
	rst		next_ch

st_e_part:
	call	int_to_fp
	rst		fp_calc
	defb	get_mem_0
	defb	jump_true, e_fp - $ - 1
	defb	negate

e_fp:
	defb	e_to_fp
	defb	end_calc
	ret

; THE 'STK-DIGIT' SUBROUTINE
stk_digit:
	cp		zero
	ret		c
	cp		0x26
	ccf
	ret		c
	sub		zero

; THE 'STACK-A' SUBROUTINE
stack_a:
	ld		c, a
	ld		b, 0

; THE 'STACK_BC' SUBROUTINE
stack_bc:
	ld		iy, err_nr
	push	bc
	rst		fp_calc
	defb	stk_zero
	defb	end_calc
	pop		bc
	ld		(hl), 0x91
	ld		a, b
	and		a
	jr		nz, norml_fp
	ld		(hl), a
	or		c
	ret		z
	ld		b, c
	ld		c, (hl)
	ld		(hl), 0x89

norml_fp:
	dec		(hl)
	sla		c
	rl		b
	jr		nc, norml_fp
	srl		b
	rr		c
	inc		hl
	ld		(hl), b
	inc		hl
	ld		(hl), c
	dec		hl
	dec		hl
	ret

; THE 'INTEGER TO FLOATING-POINT' SUBROUTINE
int_to_fp:
	push	af
	rst		fp_calc
	defb	stk_zero
	defb	end_calc
	pop		af

nxt_dgt_2:
	call	stk_digit
	ret		c
	rst		fp_calc
	defb	exchange
	defb	stk_ten
	defb	multiply
	defb	addition
	defb	end_calc
	rst		next_ch
	jr		nxt_dgt_2

; THE 'E-FORMAT TO FLOATING-POINT' SUBROUTINE 
fp_e_to_fp:
	rst		fp_calc
	defb	duplicate
	defb	less_0
	defb	st_mem_0
	defb	delete
	defb	abs

e_vet:
	defb	stk_one
	defb	subtract
	defb	duplicate
	defb	less_0
	defb	jump_true, end_e - $ - 1
	defb	duplicate
	defb	stk_data
	defb	0x33, 0x40
	defb	subtract
	defb	duplicate
	defb	less_0
	defb	jump_true, e_one - $ - 1
	defb	exchange
	defb	delete
	defb	exchange
	defb	stk_data
	defb	0x80, 0x48, 0x18, 0x96, 0x80
	defb	jump, e_m_d - $ - 1

e_one:
	defb	delete
	defb	exchange
	defb	stk_ten

e_m_d:
	defb	get_mem_0
	defb	jump_true, e_div - $ - 1
	defb	multiply
	defb	jump, e_exc - $ - 1

e_div:
	defb	division

e_exc:
	defb	exchange
	defb	jump, e_vet - $ - 1

end_e:
	defb	delete
	defb	end_calc
			ret

; THE 'FLOATING-POINT TO BC' SUBROUTINE
fp_to_bc:
	call	stk_fetch
	and		a
	jr		nz, not_zero
	ld		b, a
	ld		c, a
	push	af
	jr		fbc_end

not_zero:
	ld		b, e
	ld		e, c
	ld		c, d
	sub		0x91
	ccf
	bit		7, b
	push	af
	set		7, b
	jr		c, fbc_end
	inc		a
	neg
	cp		0x08
	jr		c, shift_tst
	ld		e, c
	ld		c, b
	ld		b, 0x00
	sub		0x08

shift_tst:
	and		a
	ld		d, a
	ld		a, e
	rlca
	jr		z, in_place

shift_bc:
	srl		b
	rr		c
	dec		d
	jr		nz, shift_bc

in_place:
	jr		nc, fbc_end
	inc		bc
	ld		a, b
	or		c
	jr		nz, fbc_end
	pop		af
	scf
	push	af

fbc_end:
	push	bc
	rst		fp_calc
	defb	end_calc
	pop		bc
	pop		af
	ld		a, c
	ret

; THE 'FLOATING-POINT TO A' SUBROUTINE
fp_to_a:
	call	fp_to_bc
	ret		c
	push	af
	dec		b
	inc		b
	jr		z, fp_a_end
	pop		af
	scf
	ret

fp_a_end:
	pop		af
	ret

; THE 'PRINT A FLOATING-POINT NUMBER' SUBROUTINE
print_fp:
	rst		fp_calc
	defb	duplicate
	defb	less_0
	defb	jump_true, p_neg - $ - 1
	defb	duplicate
	defb	greater_0
	defb	jump_true, p_pos - $ - 1
	defb	delete
	defb	end_calc
	ld		a, zero
	rst		print_a
	ret

p_neg:
	defb	abs
	defb	end_calc
	ld		a, minus
	rst		print_a
	rst		fp_calc

p_pos:
	defb	end_calc
	ld		a, (hl)
	call	stack_a
	rst		fp_calc
	defb	stk_data
	defb	0x78, 0x00, 0x80
	defb	subtract
	defb	stk_data
	defb	0xef, 0x1a, 0x20, 0x9a, 0x85
	defb	multiply
	defb	int
	defb	st_mem_1
	defb	stk_data
	defb	0x34, 0x00
	defb	subtract
	defb	negate
	defb	e_to_fp
	defb	stk_half
	defb	addition
	defb	int
	defb	end_calc
	ld		hl, 0x406b		; last byte mem2
	ld		(hl), 0x90
	ld		b, 0x0a

nxt_dgt_3:
	inc		hl
	push	hl
	push	bc
	rst		fp_calc
	defb	stk_ten
	defb	n_mod_m
	defb	exchange
	defb	end_calc
	call	fp_to_a
	or		0x90
	pop		bc
	pop		hl
	ld		(hl), a
	djnz	nxt_dgt_3
	inc		hl
	ld		bc, 0x0008
	push	hl

get_first:
	dec		hl
	ld		a, (hl)
	cp		0x90
	jr		z, get_first
	sbc		hl, bc
	push	hl
	ld		a, (hl)
	add		a, 0x6b
	push	af

round_up:
	pop		af
	inc		hl
	ld		a, (hl)
	adc		a, 0x00
	daa
	push	af
	and		0x0f
	ld		(hl), a
	set		7, (hl)
	jr		z, round_up
	pop		af
	pop		hl
	ld		b, 0x06

markers:
	ld		(hl), 0x80
	dec		hl
	djnz	markers
	rst		fp_calc
	defb	delete
	defb	get_mem_1
	defb	end_calc
	call	fp_to_a
	jr		z, signd_exp
	neg

signd_exp:
	ld		e, a
	inc		e
	inc		e
	pop		hl

get_fst_2:
	dec		hl
	dec		e
	ld		a, (hl)
	and		0x0f
	jr		z, get_fst_2
	ld		a, e
	sub		0x05
	cp		0x08
	jp		p, e_needed
	cp		0xf6
	jp		m, e_needed
	add		a, 0x06
	jr		z, out_zero
	jp		m, exp_minus
	ld		b, a

out_b_chs:
	call	out_next
	djnz	out_b_chs
	jr		test_int

e_needed:
	ld		b, e
	call	out_next
	call	test_int
	ld		a, capital_e
	rst		print_a
	ld		a, b
	and		a
	jp		p, plus_sign
	neg
	ld		b, a
	ld		a, minus
	jr		out_sign

plus_sign:
	ld		a, plus

out_sign:
	rst		print_a
	ld		a, b
	ld		b, 0xff

ten_more:
	inc		b
	sub		0x0a
	jr		nc, ten_more
	add		a, 0x0a
	ld		c, a
	ld		a, b
	and		a
	jr		z, byte_two
	call	out_code

byte_two:
	ld		a, c
	call	out_code
	ret

exp_minus:
	neg
	ld		b, a
	ld		a, period
	rst		print_a
	ld		a, zero

out_zeros:
	rst		print_a
	djnz	out_zeros
	jr		test_done

out_zero:
	ld		a, zero
	rst		print_a

; THE 'TEST-INT' SUBROUTINE
test_int:
	dec		(hl)
	inc		(hl)
	ret		pe
	ld		a, period
	rst		print_a

; THE 'TEST-DONE' SUBROUTINE
test_done:
	dec		(hl)
	inc		(hl)
	ret		pe
	call	out_next
	jr		test_done

; THE 'OUT_NEXT' SUBROUTINE
out_next:
	ld		a, (hl)
	and		0x0f
	call	out_code
	dec		hl
	ret

; THE 'PREPARE TO ADD' SUBROUTINE
prep_add:
	ld		a, (hl)
	ld		(hl), 0
	and		a
	ret		z
	inc		hl
	bit		7, (hl)
	set		7, (hl)
	dec		hl
	ret		z
	push	bc
	ld		bc, 0x0005
	add		hl, bc
	ld		b, c
	ld		c, a
	scf

neg_byte:
	dec		hl
	ld		a, (hl)
	cpl
	adc		a, 0
	ld		(hl), a
	djnz	neg_byte
	ld		a, c
	pop		bc
	ret

; THE 'FETCH TWO NUMBERS' SUBROUTINE
fetch_two:
	push	hl
	push	af
	ld		c, (hl)
	inc		hl
	ld		b, (hl)
	ld		(hl), a
	inc		hl
	ld		a, c
	ld		c, (hl)
	push	bc
	inc		hl
	ld		c, (hl)
	inc		hl
	ld		b, (hl)
	ex		de, hl
	ld		d, a
	ld		e, (hl)
	push	de
	inc		hl
	ld		d, (hl)
	inc		hl
	ld		e, (hl)
	push	de
	exx
	pop		de
	pop		hl
	pop		bc
	exx
	inc		hl
	ld		d, (hl)
	inc		hl
	ld		e, (hl)
	pop		af
	pop		hl
	ret

; THE 'SHIFT ADDEND' SUBROUTINE
shift_fp:
	and		a
	ret		z
	cp		33
	jr		nc, addend_0
	push	bc
	ld		b, a

one_shift:
	exx
	sra		l
	rr		d
	rr		e
	exx
	rr		d
	rr		e
	djnz	one_shift
	pop		bc
	ret		nc
	call	add_back
	ret		nz

addend_0:
	exx
	xor		a

zeros_4_5:
	ld		l, 0
	ld		d, a
	ld		e, l
	exx
	ld		de, 0x0000
	ret

; THE 'ADD_BACK' SUBROUTINE
add_back:
	inc		e
	ret		nz
	inc		d
	ret		nz
	exx
	inc		e
	jr		nz, all_added
	inc		d

all_added:
	exx
	ret

; THE 'SUBTRACTION' OPERATION
fp_subtract:
	ld		a, (de)
	and		a
	ret		z
	inc		de
	ld		a, (de)
	xor		0x80
	ld		(de), a
	dec		de

; THE 'ADDITION' OPERATION
fp_addition:
	exx
	push	hl
	exx
	push	de
	push	hl
	call	prep_add
	ld		b, a
	ex		de, hl
	call	prep_add
	ld		c, a
	cp		b
	jr		nc, shift_len
	ld		a, b
	ld		b, c
	ex		de, hl

shift_len:
	push	af
	sub		b
	call	fetch_two
	call	shift_fp
	pop		af
	pop		hl
	ld		(hl), a
	push	hl
	ld		l, b
	ld		h, c
	add		hl, de
	exx
	ex		de, hl
	adc		hl, bc
	ex		de, hl
	ld		a, h
	adc		a, l
	ld		l, a
	rra
	xor		l
	exx
	ex		de, hl
	pop		hl
	rra
	jr		nc, test_neg
	ld		a, 1
	call	shift_fp
	inc		(hl)
	jr		z, add_rep_6

test_neg:
	exx
	ld		a, l
	and		%10000000
	exx
	inc		hl
	ld		(hl), a
	dec		hl
	jr		z, go_nc_mlt
	ld		a, e
	neg
	ccf
	ld		e, a
	ld		a, d
	cpl
	adc		a, 0
	ld		d, a
	exx
	ld		a, e
	cpl
	adc		a, 0
	ld		e, a
	ld		a, d
	cpl
	adc		a, 0
	jr		nc, end_compl
	rra
	exx
	inc		(hl)

add_rep_6:
	jp		z, report_6
	exx

end_compl:
	ld		d, a
	exx

go_nc_mlt:
	xor		a
	jr		test_norm

; THE 'PREPARE TO MULTIPLY OR DIVIDE' SUBROUTINE
prep_m_d:
	scf
	dec		(hl)
	inc		(hl)
	ret		z
	inc		hl
	xor		(hl)
	set		7, (hl)
	dec		hl
	ret

; THE 'MULTIPLICATION' OPERATION
fp_multiply:
	xor		a
	call	prep_m_d
	ret		c
	exx
	push	hl
	exx
	push	de
	ex		de, hl
	call	prep_m_d
	ex		de, hl
	jr		c, zero_rslt
	push	hl
	call	fetch_two
	ld		a, b
	and		a
	sbc		hl, hl
	exx
	push	hl
	sbc		hl, hl
	exx
	ld		b, 33
	jr		strt_mlt

mlt_loop:
	jr		nc, no_add
	add		hl, de
	exx
	adc		hl, de
	exx

no_add:
	exx
	rr		h
	rr		l
	exx
	rr		h
	rr		l

strt_mlt:
	exx
	rr		b
	rr		c
	exx
	rr		c
	rra
	djnz	mlt_loop
	ex		de, hl
	exx
	ex		de, hl
	exx
	pop		bc
	pop		hl
	ld		a, b
	add		a, c
	jr		nz, make_expt
	and		a

make_expt:
	dec		a
	ccf

divn_expt:
	rla
	ccf
	rra
	jp		p, oflw1_clr
	jr		nc, report_6
	and		a

oflw1_clr:
	inc		a
	jr		nz, oflw2_clr
	jr		c, oflw2_clr
	exx
	bit		7, d
	exx
	jr		nz, report_6

oflw2_clr:
	ld		(hl), a
	exx
	ld		a, b
	exx

test_norm:
	jr		nc, normalize
	ld		a, (hl)
	and		a

near_zero:
	ld		a, 128
	jr		z, skip_zero

zero_rslt:
	xor		a

skip_zero:
	exx
	and		d
	call	zeros_4_5
	rlca
	ld		(hl), a
	jr		c, oflow_clr
	inc		hl
	ld		(hl), a
	dec		hl
	jr		oflow_clr

normalize:
	ld		b, 32

shift_one:
	exx
	bit		7, d
	exx
	jr		nz, norml_now
	rlca
	rl		e
	rl		d
	exx
	rl		e
	rl		d
	exx
	dec		(hl)
	jr		z, near_zero
	djnz	shift_one
	jr		zero_rslt

norml_now:
	rla
	jr		nc, oflow_clr
	call	add_back
	jr		nz, oflow_clr
	exx
	ld		d, 128
	exx
	inc		(hl)
	jr		z, report_6

oflow_clr:
	push	hl
	inc		hl
	exx
	push	de
	exx
	pop		bc
	ld		a, b
	rla
	rl		(hl)
	rra
	ld		(hl), a
	inc		hl
	ld		(hl), c
	inc		hl
	ld		(hl), d
	inc		hl
	ld		(hl), e
	pop		hl
	pop		de
	exx
	pop		hl
	exx
	ret

report_6:
	rst		error_1 
	defb	arithmetic_overflow

; THE 'DIVISION' OPERATION
fp_division:
	ex		de, hl
	xor		a
	call	prep_m_d
	jr		c, report_6
	ex		de, hl
	call	prep_m_d
	ret		c
	exx
	push	hl
	exx
	push	de
	push	hl
	call	fetch_two
	exx
	push	hl
	ld		h, b
	ld		l, c
	exx
	ld		h, c
	ld		l, b
	xor		a
	ld		b, 0xdf
	jr		div_start

div_loop:
	rla
	rl		c
	exx
	rl		c
	rl		b
	exx
	add		hl, hl
	exx
	adc		hl, hl
	exx
	jr		c, subn_only

div_start:
	sbc		hl, de
	exx
	sbc		hl, de
	exx
	jr		nc, no_rstore
	add		hl, de
	exx
	adc		hl, de
	exx
	and		a
	jr		count_one

subn_only:
	and		a
	sbc		hl, de
	exx
	sbc		hl, de
	exx

no_rstore:
	scf

count_one:
	inc		b
	jp		m, div_loop
	push	af
	jr		z, div_start
	ld		e, a
	ld		d, c
	exx
	ld		e, c
	ld		d, b
	pop		af
	rr		b
	pop		af
	rr		b
	exx
	pop		bc
	pop		hl
	ld		a, b
	sub		c
	jp		divn_expt

; THE 'INTEGER TRUNCATION TOWARDS ZERO' SUBROUTINE
fp_truncate:
	ld		a, (hl)
	cp		129
	jr		nc, x_large
	ld		(hl), 0
	ld		a, 32
	jr		nil_bytes

x_large:
	sub		160
	ret		p
	neg

nil_bytes:
	push	de
	ex		de, hl
	dec		hl
	ld		b, a
	srl		b
	srl		b
	srl		b
	jr		z, bits_zero

byte_zero:
	ld		(hl), 0
	dec		hl
	djnz	byte_zero

bits_zero:
	and		%00000111
	jr		z, ix_end
	ld		b, a
	ld		a, 255

less_mask:
	sla		a
	djnz	less_mask
	and		(hl)
	ld		(hl), a

ix_end:
	ex		de, hl
	pop		de
	ret

; THE 'CALCULATOR' TABLES
table_con:
	defb	0x00, 0xb0, 0x00				; 0
	defb	0x31, 0x00						; 1
	defb	0x30, 0x00						; 1/2
	defb	0xf1, 0x49, 0x0f, 0xda, 0xa2		; PI/2
	defb	0x34, 0x20						; 10

table_adr:
	defw		fp_jump_true
	defw		fp_exchange
	defw		fp_delete
	defw		fp_subtract
	defw		fp_multiply
	defw		fp_division
	defw		fp_to_power
	defw		fp_or
	defw		fp_no_and_no
	defw		fp_comparison
	defw		fp_comparison
	defw		fp_comparison
	defw		fp_comparison
	defw		fp_comparison
	defw		fp_comparison
	defw		fp_addition
	defw		fp_str_and_no
	defw		fp_comparison
	defw		fp_comparison
	defw		fp_comparison
	defw		fp_comparison
	defw		fp_comparison
	defw		fp_comparison
	defw		fp_strs_add
	defw		fp_negate
	defw		fp_code
	defw		fp_val
	defw		fp_len
	defw		fp_sin
	defw		fp_cos
	defw		fp_tan
	defw		fp_asn
	defw		fp_acs
	defw		fp_atn
	defw		fp_ln
	defw		fp_exp
	defw		fp_int
	defw		fp_sqr
	defw		fp_sgn
	defw		fp_abs
	defw		fp_peek
	defw		fp_usr
	defw		fp_strS
	defw		fp_chrS
	defw		fp_not
	defw		fp_move_fp
	defw		fp_n_mod_m
	defw		fp_jump
	defw		fp_stk_data
	defw		fp_dec_jr_nz
	defw		fp_less_0
	defw		fp_greater_0
	defw		fp_end_calc
	defw		fp_get_argt
	defw		fp_truncate
	defw		fp_calc_2
	defw		fp_e_to_fp
	defw		fp_series_xx
	defw		fp_stk_con_xx
	defw		fp_st_mem_xx
	defw		fp_get_mem_xx

; THE 'CALCULATOR ' SUBROUTINE
calculate:
	call	stk_pntrs

gen_ent_1:
	ld		a, b
	ld		(breg),a

gen_ent_2:
	exx
	ex		(sp), hl
	exx

re_entry:
	ld		(stkend), de
	exx
	ld		a, (hl)
	inc		hl

scan_ent:
	push	hl
	and		a
	jp		p, first_38
	ld		d, a
	and		%01100000
	rrca
	rrca
	rrca
	rrca
	add		a, 0x72
	ld		l, a
	ld		a, d
	and		%00011111
	jr		ent_table

first_38:
	cp		24
	jr		nc, double_a
	exx
	ld		bc, 0xfffb
	ld		d, h
	ld		e, l
	add		hl, bc
	exx

double_a:
	rlca
	ld		l, a

ent_table:
	ld		de, table_adr
	ld		h, 0
	add		hl, de
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ld		hl, re_entry
	ex		(sp), hl
	push	de
	exx
	ld		bc, (stkend_h)

; THE 'DELETE' SUBROUTINE
fp_delete:
	ret

; THE 'SINGLE OPERATION' SUBROUTINE
fp_calc_2:
	pop		af
	ld		a, (breg)
	exx
	jr		scan_ent

; THE 'TEST 5_SPACES' SUBROUTINE
test_5_sp:
	push	de
	push	hl
	ld		bc, 0x0005
	call	test_room
	pop		hl
	pop		de
	ret

; THE 'MOVE A FLOATING_POINT NUMBER' SUBROUTINE
fp_move_fp:
	call	test_5_sp
	ldir
	ret

; THE 'STACK LITERALS' SUBROUTINE
fp_stk_data:
	ld		h, d
	ld		l, e

stk_const:
	call	test_5_sp
	exx
	push	hl
	exx
	ex		(sp), hl
	push	bc
	ld		a, (hl)
	and		%11000000
	rlca
	rlca
	ld		c, a
	inc		c
	ld		a, (hl)
	and		%00111111
	jr		nz, form_exp
	inc		hl
	ld		a, (hl)

form_exp:
	add		a, 80
	ld		(de), a
	ld		a, 5
	sub		c
	inc		hl
	inc		de
	ld		b, 0
	ldir
	pop		bc
	ex		(sp), hl
	exx
	pop		hl
	exx
	ld		b, a
	xor		a

stk_zeros:
	dec		b
	ret		z
	ld		(de), a
	inc		de
	jr		stk_zeros

; THE 'SKIP CONSTANTS' SUBROUTINE
skip_cons:
	and		a

skip_next:
	ret z
	push	af
	push	de
	ld		de, 0x0000
	call	stk_const
	pop		de
	pop		af
	dec		a
	jr		skip_next

; THE 'MEMORY LOCATION' SUBROUTINE
loc_mem:
	ld		c, a
	rlca
	rlca
	add		a, c
	ld		c, a
	ld		b, 0
	add		hl, bc
	ret

; THE 'GET FROM MEMORY AREA' SUBROUTINE
fp_get_mem_xx:
	push	de
	ld		hl, (mem)
	call	loc_mem
	call	fp_move_fp
	pop		hl
	ret

; THE 'STACK A CONSTANT' SUBROUTINE
fp_stk_con_xx:
	ld		h, d
	ld		l, e
	exx
	push	hl
	ld		hl, table_con
	exx
	call	skip_cons
	call	stk_const
	exx
	pop		hl
	exx
	ret

; THE 'STORE IN MEMORY AREA' SUBROUTINE
fp_st_mem_xx:
	push	hl
	ex		de, hl
	ld		hl, (mem)
	call	loc_mem
	ex		de, hl
	call	fp_move_fp
	ex		de, hl
	pop		hl
	ret

; THE 'EXCHANGE' SUBROUTINE
fp_exchange:
	ld		b, 5

swap_byte:
	ld		a, (de)
	ld		c, (hl)
	ex		de, hl
	ld		(de), a
	ld		(hl), c
	inc		hl
	inc		de
	djnz	swap_byte
	ex		de, hl
	ret

; THE 'SERIES GENERATOR ' SUBROUTINE 
fp_series_xx:
	ld		b, a
	call	gen_ent_1
	defb	duplicate
	defb	addition
	defb	st_mem_0
	defb	delete
	defb	stk_zero
	defb	st_mem_2

g_loop:
	defb	duplicate
	defb	get_mem_0
	defb	multiply
	defb	get_mem_2
	defb	st_mem_1
	defb	subtract
	defb	end_calc
	call	fp_stk_data
	call	gen_ent_2
	defb	addition
	defb	exchange
	defb	st_mem_2
	defb	delete
	defb	dec_jr_nz, g_loop - $ - 1
	defb	get_mem_1
	defb	subtract
	defb	end_calc
	ret

; THE 'UNARY MINUS' OPERATION
fp_negate:
	ld		a, (hl)
	and		a
	ret		z
	inc		hl
	ld		a, (hl)
	xor		0x80
	ld		(hl), a
	dec		hl
	ret

; THE 'ABSOLUTE MAGNITUDE' FUNCTION
fp_abs:
	inc		hl
	res		7, (hl)
	dec		hl
	ret

; THE 'SIGNUM' FUNCTION
fp_sgn:
	inc		hl
	ld		a, (hl)
	dec		hl
	dec		(hl)
	inc		(hl)
	scf
	call	nz, fp_0_div_1
	inc		hl
	rlca
	rr		(hl)
	dec		hl
	ret

; THE 'PEEK' FUNCTION
fp_peek:
	call	find_int
	ld		a, (bc)
	jp		stack_a

; THE'USR' FUNCTION
fp_usr:
	call	find_int
	ld		hl, stack_bc
	push	hl
	push	bc
	ret

; THE 'GREATER THAN ZERO' OPERATION
fp_greater_0:
	ld		a, (hl)
	and		a
	ret		z
	ld		a, 0xff
	jr		sign_to_c

; THE 'NOT' FUNCTION
fp_not:
	ld		a, (hl)
	neg
	ccf
	jr		fp_0_div_1

; THE 'LESS THAN ZERO' OPERATION
fp_less_0:
	xor		a

sign_to_c:
	inc		hl
	xor		(hl)
	dec		hl
	rlca

fp_0_div_1:
	push	hl
	ld		b, 0x05

fp_zero:
	ld		(hl), 0x00
	inc		hl
	djnz	fp_zero
	pop		hl
	ret		nc
	ld		(hl), 0x81
	ret

; THE 'OR ' OPERATION
fp_or:
	ld		a, (de)
	and		a
	ret		z
	scf
	jr		fp_0_div_1

; THE 'NUMBER AND NUMBER' OPERATION
fp_no_and_no:
	ld		a, (de)
	and		a
	ret		nz
	jr		fp_0_div_1

; the 'string and number' operation
fp_str_and_no:
	ld		a, (de)
	and		a
	ret		nz
	push	de
	dec		de
	xor		a
	ld		(de), a
	dec		de
	ld		(de), a
	pop		de
	ret

; THE 'COMPARISON' OPERATIONS
fp_comparison:
	ld		a, b
	sub		8
	bit		2, a
	jr		nz, ex_or_not
	dec		a

ex_or_not:
	rrca
	jr		nc, nu_or_str
	push	af
	push	hl
	call	fp_exchange
	pop		de
	ex		de, hl
	pop		af

nu_or_str:
	bit		2, a
	jr		nz, strings
	rrca
	push	af
	call	fp_subtract
	jr		end_tests

strings:
	rrca
	push	af
	call	stk_fetch
	push	de
	push	bc
	call	stk_fetch
	pop		hl

byte_comp:
	ld		a, h
	or		l
	ex		(sp), hl
	ld		a, b
	jr		nz, sec_plus
	or		c

secnd_low:
	pop		bc
	jr		z, both_null
	pop		af
	ccf
	jr		str_test

both_null:
	pop		af
	jr		str_test

sec_plus:
	or		c
	jr		z, frst_less
	ld		a, (de)
	sub		(hl)
	jr		c, frst_less
	jr		nz, secnd_low
	dec		bc
	inc		de
	inc		hl
	ex		(sp), hl
	dec		hl
	jr		byte_comp

frst_less:
	pop		bc
	pop		af
	and		a

str_test:
	push	af
	rst		fp_calc
	defb	stk_zero
	defb	end_calc

end_tests:
	pop		af
	push	af
	call	c, fp_not
	call	fp_greater_0
	pop		af
	rrca
	call	nc, fp_not
	ret

; THE 'STRING CONCATENATION' OPERATION
fp_strs_add:
	call	stk_fetch
	push	de
	push	bc
	call	stk_fetch
	pop		hl
	push	hl
	push	de
	push	bc
	add		hl, bc
	ld		b, h
	ld		c, l
	rst		bc_spaces
	call	stk_store
	pop		bc
	pop		hl
	ld		a, b
	or		c
	jr		z, other_str
	ldir

other_str:
	pop		bc
	pop		hl
	ld		a, b
	or		c
	jr		z, stk_pntrs
	ldir

; THE 'STK_PNTRS' SUBROUTINE
stk_pntrs:
	ld		hl, (stkend)
	ld		de, 0xfffb
	push	hl
	add		hl, de
	pop		de
	ret

; THE 'CHR$' FUNCTION
fp_chrS:
	call	fp_to_a
	jr		c, report_b2
	jr		nz, report_b2
	push	af
	ld		bc, 0x0001
	rst		bc_spaces
	pop		af
	ld		(de), a
	call	stk_store
	ex		de, hl
	ret

report_b2:
	rst		error_1 
	defb	integer_out_of_range

; THE 'VAL' FUNCTION
fp_val:
	ld		hl, (ch_add)
	push	hl
	call	stk_fetch
	push	de
	inc		bc
	rst		bc_spaces
	pop		hl
	ld		(ch_add), de
	push	de
	ldir
	ex		de, hl
	dec		hl
	ld		(hl), ctrl_newline
	res		7, (iy + _flags)
	call	class_6
	call	check_2
	pop		hl
	ld		(ch_add), hl
	set		7, (iy + _flags)
	call	scanning
	pop		hl
	ld		(ch_add), hl
	jr		stk_pntrs

; THE 'STR$' FUNCTION
fp_strS:
	ld		bc, 0x0001
	rst		bc_spaces
	ld		(hl), ctrl_newline
	ld		hl, (s_posn)
	push	hl
	ld		l, 0xff
	ld		(s_posn), hl
	ld		hl, (df_cc)
	push	hl
	ld		(df_cc), de
	push	de
	call	print_fp
	pop		de
	ld		hl, (df_cc)
	and		a
	sbc		hl, de
	ld		b, h
	ld		c, l
	pop		hl
	ld		(df_cc), hl
	pop		hl
	ld		(s_posn), hl
	call	stk_store
	ex		de, hl
	ret

; THE 'CODE' FUNCTION
fp_code:
	call	stk_fetch
	ld		a, b
	or		c
	jr		z, stk_code
	ld		a, (de)

stk_code:
	jp		stack_a

; THE 'LEN' FUNCTION
fp_len:
	call	stk_fetch
	jp		stack_bc

; THE 'DECREASE THE COUNTER' SUBROUTINE
fp_dec_jr_nz:
	exx
	push	hl
	ld		hl, breg
	dec		(hl)
	pop		hl
	jr		nz, jump_2
	inc		hl
	exx
	ret

; THE 'JUMP' SUBROUTINE
fp_jump:
	exx

jump_2:
	ld		e, (hl)
	xor		a
	bit		7, e
	jr		z, new_addr
	cpl

new_addr:
	ld		d, a
	add		hl, de
	exx
	ret

; THE 'JUMP ON TRUE' SUBROUTINE
fp_jump_true:
	ld		a, (de)
	and		a
	jr		nz, fp_jump
	exx
	inc		hl
	exx
	ret

; THE 'MODULUS' SUBROUTINE
fp_n_mod_m:
	rst		fp_calc
	defb	st_mem_0
	defb	delete
	defb	duplicate
	defb	get_mem_0
	defb	division
	defb	int
	defb	get_mem_0
	defb	exchange
	defb	st_mem_0
	defb	multiply
	defb	subtract
	defb	get_mem_0
	defb	end_calc
	ret

; THE 'INT' FUNCTION
fp_int:
	rst		fp_calc
	defb	duplicate
	defb	less_0
	defb	jump_true, x_neg - $ - 1
	defb	truncate
	defb	end_calc
	ret

x_neg:
	defb	duplicate
	defb	truncate
	defb	st_mem_0
	defb	subtract
	defb	get_mem_0
	defb	exchange
	defb	fn_not
	defb	jump_true, exit - $ - 1
	defb	stk_one
	defb	subtract

exit:
	defb	end_calc
	ret

; THE 'EXPONENTIAL' FUNCTION
fp_exp:
	rst		fp_calc
	defb	stk_data
	defb	0xf1, 0x38, 0xaa, 0x3b, 0x29
	defb	multiply
	defb	duplicate
	defb	int
	defb	st_mem_3
	defb	subtract
	defb	duplicate
	defb	addition
	defb	stk_one
	defb	subtract
	defb	0x88
	defb	0x13, 0x36
	defb	0x58, 0x65, 0x66
	defb	0x9d, 0x78, 0x65, 0x40
	defb	0xa2, 0x60, 0x32, 0xc9
	defb	0xe7, 0x21, 0xf7, 0xaf, 0x24
	defb	0xeb, 0x2f, 0xb0, 0xb0, 0x14
	defb	0xee, 0x7e, 0xbb, 0x94, 0x58
	defb	0xf1, 0x3a, 0x7e, 0xf8, 0xcf
	defb	get_mem_3
	defb	end_calc
	call	fp_to_a
	jr		nz, n_negtv
	jr		c, report6_2
	add		a, (hl)
	jr		nc, result_ok

report6_2:
	rst		error_1 
	defb	arithmetic_overflow

n_negtv:
	jr		c, rslt_zero
	sub		(hl)
	jr		nc, rslt_zero
	neg

result_ok:
	ld		(hl), a
	ret

rslt_zero:
	rst		fp_calc
	defb	delete
	defb	stk_zero
	defb	end_calc
	ret

; THE 'NATURAL LOGARITHM' FUNCTION
fp_ln:
	rst		fp_calc
	defb	duplicate
	defb	greater_0
	defb	jump_true, valid - $ - 1
	defb	end_calc

report_a:
	rst		error_1
	defb	invalid_argument

valid:
	defb	stk_zero
	defb	delete
	defb	end_calc
	ld		a, (hl)
	ld		(hl), 0x80
	call	stack_a
	rst		fp_calc
	defb	stk_data
	defb	0x38, 0x00
	defb	subtract
	defb	exchange
	defb	duplicate
	defb	stk_data
	defb	0xf0, 0x4c, 0xcc, 0xcc, 0xcd
	defb	subtract
	defb	greater_0
	defb	jump_true, gre_8 - $ - 1
	defb	exchange
	defb	stk_one
	defb	subtract
	defb	exchange
	defb	end_calc
	inc		(hl)
	rst		fp_calc

gre_8:
	defb	exchange
	defb	stk_data
	defb	0xf0, 0x31, 0x72, 0x17, 0xf8
	defb	multiply
	defb	exchange
	defb	stk_half
	defb	subtract
	defb	stk_half
	defb	subtract
	defb	duplicate
	defb	stk_data
	defb	0x32, 0x20
	defb	multiply
	defb	stk_half
	defb	subtract
	defb	0x8c
	defb	0x11, 0xac
	defb	0x14, 0x09
	defb	0x56, 0xda, 0xa5
	defb	0x59, 0x30, 0xc5
	defb	0x5c, 0x90, 0xaa
	defb	0x9e, 0x70, 0x6f, 0x61
	defb	0xa1, 0xcb, 0xda, 0x96
	defb	0xa4, 0x31, 0x9f, 0xb4
	defb	0xe7, 0xa0, 0xfe, 0x5c, 0xfc
	defb	0xea, 0x1b, 0x43, 0xca, 0x36
	defb	0xed, 0xa7, 0x9c, 0x7e, 0x5e
	defb	0xf0, 0x6e, 0x23, 0x80, 0x93
	defb	multiply
	defb	addition
	defb	end_calc
	ret

; THE 'REDUCE ARGUMENT' SUBROUTINE
fp_get_argt:
	rst		fp_calc
	defb	stk_data
	defb	0xee, 0x22, 0xf9, 0x83, 0x6e
	defb	multiply
	defb	duplicate
	defb	stk_half
	defb	addition
	defb	int
	defb	subtract
	defb	duplicate
	defb	addition
	defb	duplicate
	defb	addition
	defb	duplicate
	defb	abs
	defb	stk_one
	defb	subtract
	defb	duplicate
	defb	greater_0
	defb	st_mem_0
	defb	jump_true, zplus - $ - 1
	defb	delete
	defb	end_calc
	ret

zplus:
	defb	stk_one
	defb	subtract
	defb	exchange
	defb	less_0
	defb	jump_true, yneg - $ - 1
	defb	negate

yneg:
	defb	end_calc
	ret

; THE 'COSINE' FUNCTION
fp_cos:
	rst		fp_calc
	defb	get_argt
	defb	abs
	defb	stk_one
	defb	subtract
	defb	get_mem_0
	defb	jump_true, c_ent - $ - 1
	defb	negate
	defb	jump, c_ent - $ - 1

; THE 'SINE' FUNCTION
fp_sin:
	rst		fp_calc
	defb	get_argt

c_ent:
	defb	duplicate
	defb	duplicate
	defb	multiply
	defb	duplicate
	defb	addition
	defb	stk_one
	defb	subtract
	defb	0x86
	defb	0x14, 0xe6
	defb	0x5c, 0x1f, 0x0b
	defb	0xa3, 0x8f, 0x38, 0xee
	defb	0xe9, 0x15, 0x63, 0xbb, 0x23
	defb	0xee, 0x92, 0x0d, 0xcd, 0xed
	defb	0xf1, 0x23, 0x5d, 0x1b, 0xea
	defb	multiply
	defb	end_calc
	ret

; THE 'TANGENT' FUNCTION
fp_tan:
	rst		fp_calc
	defb	duplicate
	defb	sin
	defb	exchange
	defb	cos
	defb	division
	defb	end_calc
	ret

; THE 'ARCTANGENT' FUNCTION
fp_atn:
	ld		a, (hl)
	cp		0x81
	jr		c, small
	rst		fp_calc
	defb	stk_one
	defb	negate
	defb	exchange
	defb	division
	defb	duplicate
	defb	less_0
	defb	stk_pi_div_2
	defb	exchange
	defb	jump_true, cases - $ - 1
	defb	negate
	defb	jump, cases - $ - 1

small:
	rst		fp_calc
	defb	stk_zero

cases:
	defb	exchange
	defb	duplicate
	defb	duplicate
	defb	multiply
	defb	duplicate
	defb	addition
	defb	stk_one
	defb	subtract
	defb	0x8c
	defb	0x10, 0xb2
	defb	0x13, 0x0e
	defb	0x55, 0xe4, 0x8d
	defb	0x58, 0x39, 0xbc
	defb	0x5b, 0x98, 0xfd
	defb	0x9e, 0x00, 0x36, 0x75
	defb	0xa0, 0xdb, 0xe8, 0xb4
	defb	0x63, 0x42, 0xc4
	defb	0xe6, 0xb5, 0x09, 0x36, 0xbe
	defb	0xe9, 0x36, 0x73, 0x1b, 0x5d
	defb	0xec, 0xd8, 0xde, 0x63, 0xbe
	defb	0xf0, 0x61, 0xa1, 0xb3, 0x0c
	defb	multiply
	defb	addition
	defb	end_calc
	ret

; THE 'ARCSINE' FUNCTION
fp_asn:
	rst		fp_calc
	defb	duplicate
	defb	duplicate
	defb	multiply
	defb	stk_one
	defb	subtract
	defb	negate
	defb	sqr
	defb	stk_one
	defb	addition
	defb	division
	defb	atn
	defb	duplicate
	defb	addition
	defb	end_calc
	ret

; THE 'ARCCOSINE' FUNCTION
fp_acs:
	rst		fp_calc
	defb	asn
	defb	stk_pi_div_2
	defb	subtract
	defb	negate
	defb	end_calc
	ret

; THE 'SQUARE ROOT' FUNCTION
fp_sqr:
	rst		fp_calc
	defb	duplicate
	defb	fn_not
	defb	jump_true, last -$ - 1
	defb	stk_half
	defb	end_calc

; THE 'EXPONENTIATION' OPERATION
fp_to_power:
	rst		fp_calc
	defb	exchange
	defb	duplicate
	defb	fn_not
	defb	jump_true, xis0 - $ - 1
	defb	ln
	defb	multiply
	defb	end_calc
	jp		fp_exp

xis0:
	defb	delete
	defb	duplicate
	defb	fn_not
	defb	jump_true, one - $ - 1
	defb	stk_zero
	defb	exchange
	defb	greater_0
	defb	jump_true, last - $ - 1
	defb	stk_one
	defb	exchange
	defb	division

one:
	defb	delete
	defb	stk_one

last:
	defb	end_calc
	ret

	defb	0xff

; THE 'FONT'
font:
	defb	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00		; 
	defb	0xf0, 0xf0, 0xf0, 0xf0, 0x00, 0x00, 0x00, 0x00		; '
	defb	0x0f, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 0x00, 0x00		;  '
	defb	0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00		; ''
	defb	0x00, 0x00, 0x00, 0x00, 0xf0, 0xf0, 0xf0, 0xf0		; .
	defb	0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0		; |
	defb	0x0f, 0x0f, 0x0f, 0x0f, 0xf0, 0xf0, 0xf0, 0xf0		; .'
	defb	0xff, 0xff, 0xff, 0xff, 0xf0, 0xf0, 0xf0, 0xf0		; |'
	defb	0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55		; ;;
	defb	0x00, 0x00, 0x00, 0x00, 0xaa, 0x55, 0xaa, 0x55		; ,,
	defb	0xaa, 0x55, 0xaa, 0x55, 0x00, 0x00, 0x00, 0x00		; ''
	defb	0x00, 0x24, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00		; "
	defb	0x00, 0x1c, 0x22, 0x78, 0x20, 0x20, 0x7e, 0x00		; £
	defb	0x00, 0x08, 0x3e, 0x28, 0x3e, 0x0a, 0x3e, 0x08		; $
	defb	0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x10, 0x00		; :
	defb	0x00, 0x3c, 0x42, 0x04, 0x08, 0x00, 0x08, 0x00		; ?
	defb	0x00, 0x04, 0x08, 0x08, 0x08, 0x08, 0x04, 0x00		; (
	defb	0x00, 0x20, 0x10, 0x10, 0x10, 0x10, 0x20, 0x00		; )
	defb	0x00, 0x00, 0x10, 0x08, 0x04, 0x08, 0x10, 0x00		; >
	defb	0x00, 0x00, 0x04, 0x08, 0x10, 0x08, 0x04, 0x00		; <
	defb	0x00, 0x00, 0x00, 0x3e, 0x00, 0x3e, 0x00, 0x00		; =
	defb	0x00, 0x00, 0x08, 0x08, 0x3e, 0x08, 0x08, 0x00		; +
	defb	0x00, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x00, 0x00		; -
	defb	0x00, 0x00, 0x14, 0x08, 0x3e, 0x08, 0x14, 0x00		; *
	defb	0x00, 0x00, 0x02, 0x04, 0x08, 0x10, 0x20, 0x00		; /
	defb	0x00, 0x00, 0x10, 0x00, 0x00, 0x10, 0x10, 0x20		; ;
	defb	0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x08, 0x10		; ,
	defb	0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x18, 0x00		; .
	defb	0x00, 0x3c, 0x46, 0x4a, 0x52, 0x62, 0x3c, 0x00		; 0
	defb	0x00, 0x18, 0x28, 0x08, 0x08, 0x08, 0x3e, 0x00		; 1
	defb	0x00, 0x3c, 0x42, 0x02, 0x3c, 0x40, 0x7e, 0x00		; 2
	defb	0x00, 0x3c, 0x42, 0x0c, 0x02, 0x42, 0x3c, 0x00		; 3
	defb	0x00, 0x08, 0x18, 0x28, 0x48, 0x7e, 0x08, 0x00		; 4
	defb	0x00, 0x7e, 0x40, 0x7c, 0x02, 0x42, 0x3c, 0x00		; 5
	defb	0x00, 0x3c, 0x40, 0x7c, 0x42, 0x42, 0x3c, 0x00		; 6
	defb	0x00, 0x7e, 0x02, 0x04, 0x08, 0x10, 0x10, 0x00		; 7
	defb	0x00, 0x3c, 0x42, 0x3c, 0x42, 0x42, 0x3c, 0x00		; 8
	defb	0x00, 0x3c, 0x42, 0x42, 0x3e, 0x02, 0x3c, 0x00		; 9
	defb	0x00, 0x3c, 0x42, 0x42, 0x7e, 0x42, 0x42, 0x00		; A
	defb	0x00, 0x7c, 0x42, 0x7c, 0x42, 0x42, 0x7c, 0x00		; B
	defb	0x00, 0x3c, 0x42, 0x40, 0x40, 0x42, 0x3c, 0x00		; C
	defb	0x00, 0x78, 0x44, 0x42, 0x42, 0x44, 0x78, 0x00		; D
	defb	0x00, 0x7e, 0x40, 0x7c, 0x40, 0x40, 0x7e, 0x00		; E
	defb	0x00, 0x7e, 0x40, 0x7c, 0x40, 0x40, 0x40, 0x00		; F
	defb	0x00, 0x3c, 0x42, 0x40, 0x4e, 0x42, 0x3c, 0x00		; G
	defb	0x00, 0x42, 0x42, 0x7e, 0x42, 0x42, 0x42, 0x00		; H
	defb	0x00, 0x3e, 0x08, 0x08, 0x08, 0x08, 0x3e, 0x00		; I
	defb	0x00, 0x02, 0x02, 0x02, 0x42, 0x42, 0x3c, 0x00		; J
	defb	0x00, 0x44, 0x48, 0x70, 0x48, 0x44, 0x42, 0x00		; K
	defb	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x7e, 0x00		; L
	defb	0x00, 0x42, 0x66, 0x5a, 0x42, 0x42, 0x42, 0x00		; M
	defb	0x00, 0x42, 0x62, 0x52, 0x4a, 0x46, 0x42, 0x00		; N
	defb	0x00, 0x3c, 0x42, 0x42, 0x42, 0x42, 0x3c, 0x00		; O
	defb	0x00, 0x7c, 0x42, 0x42, 0x7c, 0x40, 0x40, 0x00		; P
	defb	0x00, 0x3c, 0x42, 0x42, 0x52, 0x4a, 0x3c, 0x00		; Q
	defb	0x00, 0x7c, 0x42, 0x42, 0x7c, 0x44, 0x42, 0x00		; R
	defb	0x00, 0x3c, 0x40, 0x3c, 0x02, 0x42, 0x3c, 0x00		; S
	defb	0x00, 0xfe, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00		; T
	defb	0x00, 0x42, 0x42, 0x42, 0x42, 0x42, 0x3c, 0x00		; U
	defb	0x00, 0x42, 0x42, 0x42, 0x42, 0x24, 0x18, 0x00		; V
	defb	0x00, 0x42, 0x42, 0x42, 0x42, 0x5a, 0x24, 0x00		; W
	defb	0x00, 0x42, 0x24, 0x18, 0x18, 0x24, 0x42, 0x00		; X
	defb	0x00, 0x82, 0x44, 0x28, 0x10, 0x10, 0x10, 0x00		; Y
	defb	0x00, 0x7e, 0x04, 0x08, 0x10, 0x20, 0x7e, 0x00		; Z
