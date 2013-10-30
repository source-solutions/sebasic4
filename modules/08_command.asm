; --- BASIC LINE AND COMMAND INTERPRETATION -----------------------------------

_165 equ token_table + 269			; start of REM token
_5 equ token_table + 389			; start of ON ERROR token

; THE 'TOKENIZER' ROUTINE
org 0x1a55
tokenizer:
	set		7, (iy + _err_nr)		; set no error
	call	editor					; prepare line
	xor		a						; first pass
	ld		de, _165				; check REM first

org 0x1a60
tokenizer_1:
	ld		hl, (e_line)			; fetch line start
	push	de						; store token
	pop		ix						; position in IX

org 0x1a66
tokenizer_2:
	ld		bc, 0					; clear alpha flag
	push	af						; stack token number

org 0x1a6a
tokenizer_3:
	push	ix						; restore token
	pop		de						; position to DE

org 0x1a6d
tokenizer_4:
	ld		a, (hl)					; get character
	cp		'%'						; Spectranet command?
	jr		z, tokenizer_14			; jump if so
	cp		tk_rem					; REM token?
	jr		z, tokenizer_14			; jump if so				
	cp		ctrl_enter				; enter?
	jr		z, tokenizer_14			; jump if so
	cp		'"'						; in quotes?
	jr		nz, tokenizer_5			; jump if not
	inc		c						; toggle bit 0

org 0x1a7f
tokenizer_5:
	bit		0, c					; in quotes?
	jr		nz, tokenizer_7			; jump if so
	call	tokenizer_17			; alpha?
	jr		nc, tokenizer_6			; jump if not
	bit		7, b					; was previous alpha?
	jr		nz, tokenizer_7			; jump if so

org 0x1a8c
tokenizer_6:
	ex		de, hl					; switch HL and DE
	cp		(hl)					; first character match?
	ex		de, hl					; switch back
	jr		z, tokenizer_8			; jump if match

org 0x1a91
tokenizer_7:
	inc		hl						; next character
	jr		tokenizer_4				; repeat until end of line

org 0x1a94
tokenizer_8:
	ld		(mem_5_1), hl			; store position

org 0x1a97
tokenizer_9:
	inc		hl						; next position
	ld		a, (hl)					; character to A	
	call	tokenizer_17			; make caps
	ex		af, af'					;'store A

org 0x1a9d
tokenizer_10:
	ex		af, af'					;'restore A
	inc		de						; next character of token
	ex		de, hl					; switch HL and DE
	cp		(hl)					; does next character match?
	ex		de, hl					; switch back
	jr		z, tokenizer_9			; jump if match
	ex		af, af'					;'store A
	ld		a, (de)					; token character to A
	cp		' '						; space?
	jr		z, tokenizer_10			; jump if so
	ex		af, af'					;'restore A
	cp		'.'						; abbreviation?
	jr		z, tokenizer_11			; jump if so
	or		%10000000				; set bit 7
	ex		de, hl					; token character address to HL
	cp		(hl)					; final character?
	ex		de, hl					; token character address to DE
	jr		nz, tokenizer_3			; start at next with no match
	cp		128 + '@'				; non-alpha?
	jr		c, tokenizer_12			; jump if so

org 0x1aba
tokenizer_11:
	inc		hl						; next character
	ld		a, (hl)					; trailing character to A
	cp		' '						; space?	
	jr		z, tokenizer_12			; jump if so
	dec		hl						; final character of token
	cp		'$'						; string?
	jr		z, tokenizer_3			; jump if so
	call	alpha					; alpha?
	jr		c, tokenizer_3			; jump if so

org 0x1aca
tokenizer_12:
	ld		de, (mem_5_1)			; first character 

org 0x1ace
tokenizer_13:
	dec		de						; point to leading character
	ld		a, (de)					; store it in A
	cp		' '						; space?
	jr		z, tokenizer_13			; jump if so
	inc		de						; first character
	call	reclaim_1				; remove spaces
	pop		af						; unstack token
	push	ix						; store IX
	pop		de						; in DE
	push	af						; stack A
	add		a, 6					; add offset
	ld		(hl), a					; insert token
	pop		af						; unstack A
	and		a						; REM?
	jr		nz, tokenizer_2			; jump if not
	ld		(hl), tk_rem			; store REM token
	push	af						; prevent loop

org 0x1ae7
tokenizer_14:
	ld		de, _5					; start of final token
	pop		af						; restore token
	sub		1						; dec A and set carry if zero
	jp		c, tokenizer_1			; jump if carry flag set.
	cp		tk_rnd - 7				; first token?
	ret		z						; return if so
	push	ix						; IX to
	pop		hl						; HL

org 0x1af6
tokenizer_15:
	dec		hl						; end of previous token

org 0x1af7
tokenizer_16:
	dec		hl						; down one character
	bit		7, (hl)					; final character of a token?
	jr		z, tokenizer_16			; jump if not
	inc		hl						; first character of next token
	ex		de, hl					; store in DE
	jp		tokenizer_1				; next token

org 0x1b01
tokenizer_17:
	bit		3, (iy + _flags2)		; don't tokenize lower case
	ret		nz						; if caps in use
	call	alpha					; test alpha
	ld		b, c					; previous result to B
	ld		c, 0					; clear C
	ret		nc						; return if non-alpha
	res		5, a					; make upper case
	set		7, c					; set flag if alpha
	ret								; end of subroutine

org 0x1b12
ext_command:
	cp		56						; valid command?
	ret		c						; return if so
	rst		error					; else
	defb	Syntax_error			; syntax error

; THE 'MAIN PARSER' OF THE BASIC INTERPRETER
org 0x1b17
line_scan:
	res		7, (iy + _flags)		; signal checking syntax
	call	e_line_no				; point to first code after a line number
	xor		a						; LD A, 0
	ld		(subppc), a				; zero subppc
	dec		a						; LD A, 0xFF
	ld		(err_nr), a				; set err_nr to OK
	jr		stmt_l_1				; immediate jump

; THE STATEMENT LOOP
org 0x1b28
stmt_loop:
	rst		next_char				; get next character

org 0x1b29
stmt_l_1:
	call	test_trace				; handle trace and clear workspace
	inc		(iy + _subppc)			; increase subppc each time around
	jp		m, report_c				; error if more than 127 statements
	rst		get_char				; get current character
	ld		b, 0					; clear B
	cp		ctrl_enter				; carriage return?
	jr		z, line_end				; jump if so
	cp		':'						; colon?
	jr		z, stmt_loop			; loop if so
	ld		hl, stmt_ret			; stack new
	push	hl						; return address
	ld		c, a					; store command in C
	rst		next_char				; advance ch-add
	ld		a, c					; restore command to A
	sub		tk_def_fn				; reduce range
	call	c, ext_command			; test for extended commands (ASCII 0 to 5)
	ld		c, a					; code to BC, B = 0
	ld		hl, offst_tbl			; address table
	add		hl, bc					; calculate offset
	ld		c, (hl)					; offset to C
	add		hl, bc					; base address to HL
	jr		get_param				; immediate jump

org 0x1b52
scan_loop:
	ld		hl, (t_addr)			; temporary pointer to parameter table

org 0x1b55
get_param:
	ld		a, (hl)					; get each entry
	inc		hl						; increase pointer
	ld		(t_addr), hl			; store it in t-addr
	ld		hl, scan_loop			; stack new
	push	hl						; return address
	ld		c, a					; entry to C
	cp		' '						; separator?
	jr		nc, separator			; jump if so
	ld		hl, class_tbl			; address table
	ld		b, 0					; clear B
	add		hl, bc					; index into table
	ld		c, (hl)					; offset to C
	add		hl, bc					; base address to HL
	push	hl						; use as new return address
	rst		get_char				; get current character
	dec		b						; LD B, 255
	ret								; indirect jump

; THE 'SEPARATOR' SUBROUTINE
org 0x1b6f
separator:
	rst		get_char				; get current character
	cp		c						; compare with entry
	jp		nz, report_c			; error if no match
	rst		next_char				; get next character
	ret								; end of subroutine

; THE 'STMT-RET' SUBROUTINE
org 0x1b76
stmt_ret:
	call	break_key				; break? 
	jr		c, stmt_r_1				; jump if not
	rst		error					; else
	defb	BREAK_into_program		; error

org 0x1b7d
stmt_r_1:
	bit		7, (iy + _nsppc)		; statement jump required?
	jr		nz, stmt_next			; jump if not
	ld		hl, (newppc)			; get new line number
	bit		7, h					; statement in editing area?
	jr		z, line_new				; jump if not

; THE 'LINE-RUN' ENTRY POINT
org 0x1b8a
line_run:
	ld		hl, -2					; line in editing area
	ld		(ppc), hl				; store in ppc
	ld		hl, (worksp)			; worksp to HL
	dec		hl						; HL points to end of editing area
	ld		de, (e_line)			; e-line to DE
	dec		de						; DE points to location before editing area
	ld		a, (nsppc)				; number of next statement to A
	jr		next_line				; immediate jump

; THE 'LINE-NEW' SUBROUTINE
org 0x1b9e
line_new:
	call	line_addr				; get starting address
	ld		a, (nsppc)				; statement number to A
	jr		z, line_use				; jump if line found
	and		a						; valid statement number?
	jr		nz, report_n			; error if not
	ld		a, (hl)					; is first line after
	and		%11000000				; end of program?
	jr		z, line_use				; jump if not
	rst		error					; else
	defb	OK						; program end

org 0x1bb0
	defs	2, 255					; unused locations (common)

; THE 'REM' COMMAND ROUTINE
org 0x1bb2
rem:
	pop		af						; discard stmt-ret return address

; THE 'LINE-END' ROUTINE
org 0x1bb3
line_end:
	call	syntax_z				; checking syntax?
	ret		z						; return if so
	ld		hl, (nxtlin)			; get address
	ld		a, 192					; address after
	and		(hl)					; end of program?
	ret		nz						; return if so
	xor		a						; signal statement zero

; THE 'LINE-USE' ROUTINE
org 0x1bbf
line_use:
	cp		1						; signal
	adc		a, 0					; statement one
	ld		d, (hl)					; line
	inc		hl						; number
	ld		e, (hl)					; to DE
	inc		hl						; point to length
	ld		(ppc), de				; store line number
	ld		e, (hl)					; length
	inc		hl						; to
	ld		d, (hl)					; DE
	ex		de, hl					; location before next line's
	add		hl, de					; first character to DE
	inc		hl						; start of line after to HL

; THE 'NEXT-LINE' ROUTINE
org 0x1bd1
next_line:
	ld		(nxtlin), hl			; set next line
	ex		de, hl					; swap pointers
	ld		(ch_add), hl			; ch-add to location before first character
	ld		e, 0					; clear in case of each-stmt
	ld		d, a					; statement number to D
	ld		(iy + _nsppc), 255		; signal no jump
	dec		d						; reduce statement number
	ld		(iy + _subppc), d		; store in subppc
	jp		z, stmt_loop			; consider first statement
	inc		d						; increase D
	call	each_stmt				; find start address
	jr		z, stmt_next			; jump if statement exists

org 0x1bec
report_n:
	rst		error					; else
	defb	Missing_statement		; error

; THE 'CHECK-END' SUBROUTINE
org 0x1bee
check_end:
	call	syntax_z				; checking syntax?
	ret		nz						; return if not
	pop		bc						; discard scan-loop and
	pop		bc						; stmt-ret return addresses

; THE 'STMT-NEXT' ROUTINE
org 0x1bf4
stmt_next:
	rst		get_char				; get current character
	cp		ctrl_enter				; carriage return?
	jr		z, line_end				; jump if so
	cp		':'						; colon?
	jp		z, stmt_loop			; jump if so
	rst		error					; else
	defb	Syntax_error			; error

; THE 'COMMAND CLASS' TABLE
org 0x1c00
class_tbl:
	defb	class_0 - $				; no operands
	defb	class_1 - $				; a variable must follow
	defb	class_2 - $				; LET
	defb	class_3 - $				; a number may follow
	defb	class_4 - $				; FOR or NEXT
	defb	class_5 - $				; a set of items may follow
	defb	expt_1num - $			; a number must follow
	defb	perms - $				; set permanent colors
	defb	expt_2num - $			; two comma-separated numbers must follow
	defb	class_9 - $				; drawing commands
	defb	expt_exp - $			; an expression must follow
	defb	class_b - $				; tape commands
	defb	class_c - $				; class-1 followed by class-0

; THE 'COMMAND CLASSES - 0, 3 & 5'
org 0x1c0d
class_3:
	call	fetch_num				; get number, default to zero

org 0x1c10
class_0:
	cp		a						; set zero flag

org 0x1c11
class_5:
	pop		bc						; discard scan-loop return address
	call	z, check_end			; next statement if checking syntax
	ex		de, hl					; swap pointers
	ld		hl, (t_addr)			; pointer to parameter table entry
	ld		c, (hl)					; get
	inc		hl						; entry
	ld		b, (hl)					; in BC
	ex		de, hl					; swap pointers
	push	bc						; stack entry
	ret								; end of subroutine

; THE 'COMMAND CLASSES - 1, 2 & 4'
org 0x1c1f
class_1:
	call	look_vars				; variable exists?

; THE 'VARIABLE IN ASSIGNMENT' SUBROUTINE
org 0x1c22
var_a_1:
	ld		(iy + _flagx), 0		; clear flagx
	jr		nc, var_a_2				; jump if variable exists
	set		1, (iy + _flagx)		; signal new variable
	jr		nz, var_a_3				; jump unless undimensioned array

org 0x1c2e
report_2:
	rst		error					; else
	defb	Undefined_variable		; error

org 0x1c30
var_a_2:
	call	z, stk_var				; parameters and variables to calculator
	bit		6, (iy + _flags)		; numeric variable?
	jr		nz, var_a_3				; jump if so
	xor		a						; LD A, 0
	call	syntax_z				; checking syntax?
	call	nz, stk_fetch			; get paramaters of string if not
	ld		hl, flagx				; address system variable
	or		(hl)					; set bit 0 for simple strings
	ld		(hl), a					; update flagx
	ex		de, hl					; HL points to string or element

org 0x1c46
var_a_3:
	ld		(strlen), bc			; set strlen
	ld		(dest), hl				; and destination
	ret								; end of subroutine

org 0x1c4e
class_2:
	pop		bc						; discard scan-loop return address
	jr		class_2_1				; immediate jump

; THE 'COMMAND CLASS C' ROUTINE
org 0x1c51
class_c:
	call	expt_1num				; expect a number with
	jr		class_0					; no further parameters

; THE 'FETCH A VALUE' SUBROUTINE
org 0x1c56
val_fet_1:
	ld		a, (flags)				; address system variable

org 0x1c59
val_fet_2:
	push	af						; stack system variable
	call	scanning				; evaluate expression
	pop		af						; unstack system variable
	ld		d, (iy + _flags)		; get new flags
	xor		d						; test for
	and		%01000000				; numeric or string
	jr		nz, report_c			; error if no match
	bit		7, d					; checking syntax?
	jp		nz, let					; jump if not
	ret								; else return

; THE 'COMMAND CLASS 4' ROUTINE
org 0x1c6c
class_4:
	call	look_vars				; find variable
	push	af						; stack AF
	ld		a, c					; test
	or		%10011111				; discriminator byte
	inc		a						; for FOR-NEXT
	jr		nz, report_c			; error if not
	pop		af						; unstack AF
	jr		var_a_1					; immediate jump

; THE 'EXPECT NUMERIC / STRING EXPRESSIONS' SUBROUTINE
org 0x1c79
next_2num:
	rst		next_char				; advance ch-add

org 0x1c7a
expt_2num:
	call	expt_1num				; get expression
	cp		','						; comma?
	jr		nz, report_c			; error if not

org 0x1c81
sexpt1num:
	rst		next_char				; advance ch-add

org 0x1c82
expt_1num:
	call	scanning				; evaluate expression
	bit		6, (iy + _flags)		; numeric result
	ret		nz						; return if so

org 0x1c8a
report_c:
	rst		error					; else
	defb	Syntax_error			; error

org 0x1c8c
expt_exp:
	call	scanning				; evaluate expression
	bit		6, (iy + _flags)		; string result
	ret		z						; return if so
	jr		report_c				; else error

; THE 'SET PERMANENT COLORS' SUBROUTINE
org 0x1c96
perms:
	call	syntax_z				; checking syntax?
	call	nz, stream_fe			; set stream if so
	pop		af						; discard scan-loop return address
	ld		a, (t_addr)				; get low byte of t-addr
	sub		p_pen - (tk_pen-1)% 256	; safe to ignore overflow warning
	call	co_temp_4				; change temporary colors
	call	check_end				; next statement if checking syntax
	ld		hl, (attr_t)			; attr-t and mask-t to HL
	ld		(attr_p), hl			; HL to attr-p and mask-p
	ld		hl, p_flag				; address p-flag
	ld		a, (hl)					; p-flag to A
	rlca							; shift mask left
	xor		(hl)					; exclusive or with p-flag
	and		%10101010				; discard odd bits
	xor		(hl)					; permanent bits now set with temp bits
	ld		(hl), a					; write result
	ret								; end of subroutine

org 0x1cb9
class_2_1:
	call	val_fet_1				; make assignment
	jr		class_2_2				; immediate jump

; THE 'COMMAND CLASS 9' ROUTINE
org 0x1cbe
class_9:
	call	syntax_z				; checking syntax?
	jr		z, cl_09_1				; jump if so
	call	stream_fe				; set stream
	ld		hl, mask_t				; address system variable
	ld		a, (hl)					; mask-t to A
	or		%11111000				; retain pen mask
	ld		(hl), a					; write new value
	res		6, (iy + _p_flag)		; ensure not PAPER 9
	rst		get_char				; get current character

org 0x1cd2
cl_09_1:
	call	co_temp_2				; handle color items
	jr		expt_2num				; get operands for drawing commands

org 0x1cd7
class_2_2:
	call	check_end				; next statement if checking syntax
	ret								; indirect jump to stmt-ret in runtime

; THE 'COMMAND CLASS B' ROUTINE
org 0x1cdb
class_b:
	jp		save_etc				; immediate jump

; THE 'FETCH A NUMBER' SUBROUTINE
org 0x1cde
fetch_num:
	cp		ctrl_enter				; carriage return?
	jr		z, use_zero				; jump if so
	cp		':'						; colon?
	jr		nz, expt_1num			; jump if not

org 0x1ce6
use_zero:
	call	syntax_z				; checking syntax?
	ret		z						; return if so
	fwait							; enter calculator
	fstk0							; stack zero
	fce								; exit calculator
	ret								; end of subroutine

; THE 'STOP' COMMAND ROUTINE
org 0x1cee
stop:
	rst		error					; report
	defb	STOP_statement			; stop

; THE 'IF' COMMAND ROUTINE
org 0x1cf0
c_if:
	pop		bc						; discard stmt-ret return address
	call	syntax_z				; checking syntax?
	jr		z, if_1					; jump if so
	fwait							; enter calculator
	fdel							; remove last item
	fce								; exit calculator
	ex		de, hl					; swap pointers
	call	test_zero				; zero?
	jp		c, line_end				; jump if not

org 0x1d00
if_1:
	jp		stmt_l_1				; next statement

; THE 'FOR' COMMAND ROUTINE
org 0x1d03
for:
	cp		tk_step					; STEP?
	jr		nz, f_use_1				; jump if not
	rst		next_char				; advance ch-add
	call	expt_1num				; get step
	call	check_end				; next statement if checking syntax
	jr		f_reorder				; immediate jump

org 0x1d10
f_use_1:
	call	check_end				; next statement if checking syntax
	fwait							; enter calculator
	fstk1							; stack one
	fce								; exit calculator

org 0x1d16
f_reorder:
	fwait							; enter calculator
	fst		0						; store step in mem-0
	fdel							; remove last item
	fxch							; l, v
	fgt		0						; l, v, s
	fxch							; l, s, v
	fce								; exit calculator
	call	let						; find or create variable
	ld		(mem), hl				; contents of mem to HL
	dec		hl						; point to single character name
	ld		a, (hl)					; store it in A
	set		7, (hl)					; set bit 7
	ld		bc, 6					; make six locations
	add		hl, bc					; point to following location
	rlca							; FOR variable?
	jr		c, f_l_and_s			; jump if so
	ld		c, 13					; else 13 more bytes required
	call	make_room				; make space
	inc		hl						; point to limit position

org 0x1d34
f_l_and_s:
	push	hl						; stack pointer
	fwait							; l, x
	fdel							; l
	fdel							; empty calculator stack
	fce								; exit calculator
	pop		hl						; unstack pointer
	ex		de, hl					; swap pointers
	ld		c, 10					; ten bytes of limit
	ldir							; copy bytes
	ld		hl, (ppc)				; current line number to HL
	ex		de, hl					; swap pointers
	ld		(hl), e					; line number
	inc		hl						; to FOR control
	ld		(hl), d					; variables
	ld		d, (iy + _subppc)		; next statement to D
	inc		hl						; increase variable pointer
	inc		d						; increase statement
	ld		(hl), d					; store control variable
	call	next_loop				; pass possible?
	ret		nc						; return if so
	ld		a, (subppc)				; statement to A
	ld		hl, (ppc)				; current line number
	ld		(newppc), hl			; to newppc via HL
	ld		b, (iy + _strlen)		; character name to B
	neg								; negate statement
	ld		hl, (ch_add)			; current value of ch-add
	ld		d, a					; statement to D 
	ld		e, tk_next				; NEXT

org 0x1d64
f_loop:
	push	bc						; stack variable name
	ld		bc, (nxtlin)			; current value of nxtlin
	call	look_prog				; search program area
	ld		(nxtlin), bc			; store new value of nxtlin
	pop		bc						; unstack variable name
	jr		c, report_i				; error with missing next
	rst		next_char				; skip NEXT
	or		%00100000				; ignore letter case
	cp		b						; variable found?
	jr		z, f_found				; jump if so
	rst		next_char				; advance ch-add
	jr		f_loop					; loop until done

org 0x1d7c
f_found:
	rst		next_char				; advance ch-add
	ld		a, 1					; subtract statement
	sub		d						; counter from one
	ld		(nsppc), a				; store result
	ret								; indirect jump to stmt-ret

org 0x1d84
report_i:
	rst		error					; report
	defb	FOR_without_NEXT		; error

; THE 'LOOK-PROG' SUBROUTINE
org 0x1d86
look_prog:
	ld		a, (hl)					; current character
	cp		':'						; colon?
	jr		z, look_p_2				; jump if so

org 0x1d8b
look_p_1:
	inc		hl						; most significant byte of line number
	ld		a, (hl)					; copy to A
	and		%11000000				; end of program?
	scf								; set carry flag
	ret		nz						; return if no more lines
	ld		b, (hl)					; line
	inc		hl						; number
	ld		c, (hl)					; to BC
	ld		(newppc), bc			; store in newppc
	inc		hl						; get
	ld		c, (hl)					; length
	inc		hl						; in
	ld		b, (hl)					; BC
	push	hl						; stack pointer
	add		hl, bc					; calculate end of line address
	ld		c, l					; result
	ld		b, h					; to BC
	pop		hl						; unstack pointer
	ld		d, 0					; zero statement counter

org 0x1da3
look_p_2:
	push	bc						; stack end of line pointer
	call	each_stmt				; examine statements
	pop		bc						; unstack end of line pointer
	ret		nc						; return with occurence
	jr		look_p_1				; immediate jump

; THE 'NEXT' COMMAND ROUTINE
org 0x1dab
next:
	bit		1, (iy + _flagx)		; variable found?
	jp		nz, report_2			; jump if not
	ld		hl, (dest)				; address to HL
	bit		7, (hl)					; valid name?
	jr		z, report_1				; jump if not
	inc		hl						; skip name
	ld		(mem), hl				; variable address to temporary memory area
	fwait							; enter calculator
	fgt		0						; v
	fgt		2						; v, s
	fadd							; v + s
	fst		0						; v + s to mem-0
	fdel							; remove last item
	fce								; exit calculator
	call	next_loop				; test value against limit
	ret		c						; return if FOR-NEXT loop done
	ld		hl, (mem)				; address least significant byte
	ld		de, 15					; of looping
	add		hl, de					; line number
	ld		e, (hl)					; line
	inc		hl						; numer
	ld		d, (hl)					; to DE
	inc		hl						; statement
	ld		h, (hl)					; number to H
	ex		de, hl					; swap pointers
	jp		goto_2					; immediate jump

org 0x1dd8
report_1:
	rst		error					; report
	defb	NEXT_without_FOR		; error

; THE 'NEXT-LOOP' SUBROUTINE
org 0x1dda
next_loop:
	fwait							; enter calculator
	fgt		1						; l
	fgt		0						; l, v
	fgt		2						; l, v, s
	fcp		.lz						; less-0?
	fjpt	next_1					; jump if so
	fxch							; v, l

org 0x1de2
next_1:
	fsub							; v - l or l - v
	fcp		.gz						; greater-0?
	fjpt	next_2					; jump if so
	fce								; exit calculator
	and		a						; clear carry flag
	ret								; return

org 0x1de9
next_2:
	fce								; exit calculator
	scf								; set carry flag
	ret								; end of subroutine

; THE 'READ' COMMAND ROUTINE
org 0x1dec
read_3:
	rst		next_char				; next character

org 0x1ded
read:
	call	class_1					; get entry for existing variable
	call	syntax_z				; checking syntax?
	jr		z, read_2				; jump if so
	rst		get_char				; get current character
	ld		(x_ptr), hl				; ch-add to x-ptr
	ld		hl, (datadd)			; DATA address pointer to HL
	ld		a, (hl)					; first value to A
	cp		','						; comma?
	jr		z, read_1				; jump if not
	ld		e, tk_data				; DATA?
	call	look_prog				; search for token
	jr		nc, read_1				; jump if found
	rst		error					; else
	defb	End_of_DATA				; error

org 0x1e0a
read_1:
	call	temp_ptr1				; advance DATA pointer and set ch-add
	call	val_fet_1				; get value and assign to variable
	rst		get_char				; get ch-add
	ld		(datadd), hl			; store it in datadd
	ld		hl, (x_ptr)				; pointer to READ statement to HL
	ld		(iy + _x_ptr_h), 0		; clear x-ptr
	call	temp_ptr2				; point ch-add to READ statement

org 0x1e1e
read_2:
	rst		get_char				; get current character
	cp		','						; comma?
	jr		z, read_3				; jump if so
	call	check_end				; next statement if checking syntax
	ret 							; end of routine

; THE 'DATA' COMMAND ROUTINE
org 0x1e27
data:
	call	syntax_z				; checking syntax?
	jr		nz, data_2				; jump if so

org 0x1e2c
data_1:
	call	scanning				; next expression
	cp		','						; comma?
	call	nz, check_end			; next statement if checking syntax
	rst		next_char				; advance ch-add
	jr		data_1					; loop until done

org 0x1e37
data_2:
	ld		a, tk_data				; DATA?

; THE 'PASS-BY' SUBROUTINE
org 0x1e39
pass_by:
	ld		b, a					; token to B
	cpdr							; back to find token
	ld		de, 0x0200				; find following statement (D - 1)
	jp		each_stmt				; immediate jump

; THE 'RESTORE' COMMAND ROUTINE
org 0x1e42
restore:
	call	find_line				; line number to BC

org 0x1e45
rest_run:
	ld		l, c					; result
	ld		h, b					; to HL
	call	line_addr				; get address of line or next line
	dec		hl						; point to location before
	ld		(datadd), hl			; and store in dat-add
	ret								; end of routine

; THE 'RANDOMIZE' COMMAND ROUTINE
org 0x1e4f
randomize:
	call	find_int2				; get operand
	ld		a, c					; is it
	or		b						; zero?
	jr		nz, rand_1				; jump if not
	ld		bc, (frames)			; get low 16-bits of frames

org 0x1e5a
rand_1:
	ld		(seed), bc				; result to seed
	ret								; end of routine

; THE 'CONTINUE' COMMAND ROUTINE
org 0x1e5f
continue:
	ld		hl, (oldppc)			; line number to HL
	ld		d, (iy + _osppc)		; statement number to D
	jr		goto_2					; immediate jump

; THE 'GOTO' COMMAND ROUTINE
org 0x1e67
goto:
	call	find_line				; line number to BC
	ld		h, b					; result
	ld		l, c					; to HL
	ld		d, 0					; zero statement
	ld		a, h					; most significant byte to H
	cp		0x40					; line greater than 16383?
	jr		nc, report_b2			; error if so

org 0x1e73
goto_2:
	ld		(iy + _nsppc), d		; store line number
	ld		(newppc), hl			; store statement number
	ret								; end of routine

; THE 'OUT' COMMAND ROUTINE
org 0x1e7a
fn_out:
	call	two_param				; get operands
	out		(c), a					; perform out
	ret								; end of routine

; THE 'POKE' COMMAND ROUTINE
org 0x1e80
poke:
	call	two_param				; get operands
	ld		(bc), a					; store A in address BC
	ret								; end of routine

; THE 'TWO-PARAM' SUBROUTINE
org 0x1e85
two_param:
	call	fp_to_a					; first parameter
	jr		c, report_b2			; error if out of range
	jr		z, two_p_1				; jump with positive number
	neg								; else negate

org 0x1e8e
two_p_1:
	push	af						; stack first parameter
	call	find_int2				; get second parameter in BC
	pop		af						; unstack first parameter
	ret								; end of subroutine

; THE 'FIND INTEGERS' SUBROUTINE
org 0x1e94
find_int1:
	call	fp_to_a					; value on calculator stack to A
	jr		find_i_1				; immediate jump

org 0x1e99
find_int2:
	call	fp_to_bc				; value on calculator stack to BC

org 0x1e9c
find_i_1:
	jr		c, report_b2			; error if overflow
	ret		z						; return with positive numbers

org 0x1e9f
report_b2:
	rst		error					; else
	defb	Integer_out_of_range	; error

; THE 'RUN' COMMAND ROUTINE
org 0x1ea1
run:
	call	goto					; set newppc
	ld		bc, 0					; restore value
	call	rest_run				; perform restore
	jr		clear_run				; immediate jump

; THE 'CLEAR' COMMAND ROUTINE
org 0x1eac
clear:
	call	find_int2				; get operand

org 0x1eaf
clear_run:
	ld		a, c					; test
	or		b						; for zero
	jr		nz, clear_1				; jump if not
	ld		bc, (ramtop)			; else use existing ramtop

org 0x1eb7
clear_1:
	push	bc						; stack value
	ld		hl, (e_line)			; reclaim
	ld		de, (vars)				; all bytes
	dec		hl						; of current
	call	reclaim_1				; variables area
	call	clr_rst					; clear display and restore
	ld		de, 50					; add
	ld		hl, (stkend)			; fifty to
	add		hl, de					; stack end
	pop		de						; unstack value in DE
	sbc		hl, de					; subtract it from ramptop
	jr		nc, report_m			; jump if ramtop too low
	and		a						; prepare for subtraction
	ld		hl, (p_ramt)			; upper value to HL
	sbc		hl, de					; subtract from upper value
	jr		nc, clear_2				; jump if valid

org 0x1eda
report_m:
	rst		error					; else
	defb	Bad_CLEAR_address		; error

org 0x1edc
clear_2:
	ex		de, hl					; value to HL
	ld		(ramtop), hl			; store it
	pop		de						; stmt-ret address to DE
	pop		bc						; error address to BC
	ld		(hl), 0x3e				; GOSUB stack marker
	dec		hl						; skip one location
	ld		sp, hl					; SP to empty GOSUB stack
	push	bc						; stack error address
	ld		(err_sp), sp			; store in err-sp
	ex		de, hl					; stmt-ret address to HL
	jp		(hl)					; immediate jump

; THE 'GOSUB' COMMAND ROUTINE
org 0x1eed
gosub:
	pop		de						; stmt-ret address to DE
	ld		h, (iy + _subppc)		; get statement number
	inc		h						; increase it
	ex		(sp), hl				; swap with error address
	inc		sp						; reclaim one location
	ld		bc, (ppc)				; get current line number
	push	bc						; stack it
	push	hl						; stack error address
	ld		(err_sp), sp			; point err-sp to it
	push	de						; stack stmt-ret address
	call	goto					; set newppc and nsppc
	ld		bc, 20					; 20 bytes required

; THE 'TEST-ROOM' SUBROUTINE
org 0x1f05
test_room:
	ld		hl, (stkend)			; stack end to HL
	add		hl, bc					; add value in BC
	jr		c, report_4				; error if greater than 65535
	ex		de, hl					; swap pointers
	ld		hl, 80					; allow for additional 80 bytes
	add		hl, de					; try again
	jr		c, report_4				; jump with error 
	sbc		hl, sp					; subtract stack
	ret		c						; return if room

org 0x1f15
report_4:
	ld		l, Out_of_memory		; else
	jp		error_3					; error

; -----------------------------------------------------------------------------

; THE 'TEST TRACE' SUBROUTINE (CONTINUED)
org 0x1f1a
test_trace_2:
	call	out_num_1				; the line number
	ld		a, ' '					; a space
	rst		10h						; print it
	jp		test_trace_3			; immediate jump	

; -----------------------------------------------------------------------------
	
; THE 'RETURN' COMMAND ROUTINE
org 0x1f23
return:
	pop		bc						; stmt-ret address to BC
	pop		hl						; error address to HL
	pop		de						; last entry on GOSUB stack to DE
	ld		a, d					; D to A
	cp		0x3e					; test for end marker
	jr		z, report_7				; error if so
	dec		sp						; three locations required
	ex		(sp), hl				; swap statement number and error address
	ex		de, hl					; statement number to DE
	ld		(err_sp), sp			; set error pointer
	push	bc						; stack stmt-ret address
	jp		goto_2					; immediate jump

org 0x1f36
report_7:
	push	de						; stack end marker
	push	hl						; stack error address
	rst		error					; report
	defb	RETURN_without_GOSUB	; error

; THE 'PAUSE' COMMAND ROUTINE
org 0x1f3a
pause_0:
	call	find_int2				; jump here from entry point to get operand

org 0x1f3d
pause_1:
	halt							; wait for maskable interrupt
	dec		bc						; reduce counter
	ld		a, c					; test
	or		b						; for zero
	jr		z, pause_end			; jump if so
	ld		a, c					; is it
	and		b						; was it
	inc		a						; originally zero?
	jr		nz, pause_2				; jump if not
	inc		bc						; LD BC, 0

org 0x1f49
pause_2:
	bit		5, (iy + _flags)		; key pressed?
	jr		z, pause_1				; jump if no key

org 0x1f4f
pause_end:
	res		5, (iy + _flags)		; signal no key
	ret								; end of routine

; THE 'BREAK-KEY' SUBROUTINE
org 0x1f54
break_key:
	ld		a, 0x7f					; high byte of I/O address
	in		a, (ula)				; read byte
	rra								; set carry if SPACE pressed
	ret		c						; return if not
	ld		a, 0xfe					; high byte of I/O address
	in		a, (ula)				; read byte
	rra								; set carry if SHIFT pressed
	ret								; end of subroutine

; THE 'DEF FN' COMMAND ROUTINE
org 0x1f60
def_fn:
	call	syntax_z				; checking syntax?
	jr		z, def_fn_1				; jump if not
	ld		a, tk_def_fn			; DEF FN?
	jp		pass_by					; immediate jump

org 0x1f6a
def_fn_1:
	set		6, (iy + _flags)		; signal numeric variable
	call	alpha					; letter?
	jr		nc, def_fn_4			; jump if not
	rst		next_char				; next character
	cp		'$'						; dollar?
	jr		nz, def_fn_2			; jump if not
	res		6, (iy + _flags)		; signal string variable
	rst		next_char				; next character

org 0x1f7d
def_fn_2:
	cp		'('						; opening parenthesis?
	jr		nz, def_fn_7			; jump if not
	rst		next_char				; next character
	cp		')'						; closing parenthesis?
	jr		z, def_fn_6				; jump if so

org 0x1f86
def_fn_3:
	call	alpha					; letter?

org 0x1f89
def_fn_4:
	jp		nc, report_c			; jump if not
	ex		de, hl					; swap pointers
	rst		next_char				; next character
	cp		'$'						; dollar?
	jr		nz, def_fn_5			; jump if not
	ex		de, hl					; swap pointers
	rst		next_char				; next character

org 0x1f94
def_fn_5:
	ex		de, hl					; swap pointers
	ld		bc, 6					; six locations required
	call	make_room				; make space
	inc		hl						; point to first new location
	inc		hl						; new location
	ld		(hl), ctrl_number		; store number marker
	cp		','						; comma in A?
	jr		nz, def_fn_6			; jump if so
	rst		next_char				; next character
	jr		def_fn_3				; immediate jump

org 0x1fa6
def_fn_6:
	cp		')'						; closing parenthesis?
	jr		nz, def_fn_7			; jump if not
	rst		next_char				; next character
	cp		'='						; equals?
	jr		nz, def_fn_7			; jump if not
	rst		next_char				; next character
	ld		a, (flags)				; variable type to A
	push	af						; stack it
	call	scanning				; evaluate expression
	pop		af						; unstack type
	xor		(iy + _flags)			; matching
	and		%01000000				; type?

org 0x1fbd
def_fn_7:
	jp		nz, report_c			; jump if not
	call	check_end				; next statement if checking syntax

; THE 'UNSTACK-Z' SUBROUTINE
org 0x1fc3
unstack_z:
	call	syntax_z				; checking syntax?
	pop		hl						; return address to HL
	ret		z						; return if not in runtime
	jp		(hl)					; else immediate jump

; -----------------------------------------------------------------------------

; THE 'TEST TRACE' SUBROUTINE (CONTINUED)
org 0x1fc9
test_trace_3:
	ld		(iy + _vdu_flag), d		; restore VDU flag
	ret								; and return

; -----------------------------------------------------------------------------

; THE 'PRINT' COMMAND ROUTINE
org 0x1fcd
print:
	ld		a, 2					; channel 'S'

org 0x1fcf
print_1:
	call	syntax_z				; checking syntax?
	call	nz, chan_open			; open channel if not
	call	temps					; set temporary colors
	call	print_2					; print control
	call	check_end				; next statement if checking syntax
	ret								; end of routine

org 0x1fdf
print_2:
	rst		get_char				; get current character
	call	pr_end_z				; end of item list?
	jr		z, print_4				; jump if so

org 0x1fe5
print_3:
	call	pr_posn_1			 	; position controls?
	jr		z, print_3				; loop if so
	call	pr_item_1				; single print item
	call	pr_posn_1				; more position controls?
	jr		z, print_3				; loop if so

org 0x1ff2
print_4:
	cp		')'						; closing parenthesis?
	ret		z						; return if so

; THE 'PRINT A CARRIAGE RETURN' SUBROUTINE
org 0x1ff5
print_cr:
	call	unstack_z				; return if checking syntax
	ld		a, ctrl_enter			; carriage return
	rst		print_a					; print it
	ret								; end of subroutine

; THE 'PRINT ITEMS' SUBROUTINE
org 0x1ffc
pr_item_1:
	rst		get_char				; get current character
	cp		tk_at					; AT?
	jr		nz, pr_item_2			; jump if not
	call	next_2num				; get coords
	call	unstack_z				; return if checking syntax
	call	stk_to_bc				; stack coords
	ld		a, ctrl_at				; AT control character
	jr		pr_at_tab				; immediate jump

org 0x200e
pr_item_2:
	cp		tk_tab					; TAB?
	jr		nz, pr_item_3			; jump if not
	rst		next_char				; next character
	call	expt_1num				; get parameter
	call	unstack_z				; return if checking syntax
	call	find_int2				; parameter to BC
	ld		a, ctrl_tab				; TAB control character

org 0x201e
pr_at_tab:
	rst		print_a					; print control character
	ld		a, c					; first value
	rst		print_a					; print it
	ld		a, b					; second value
	rst		print_a					; print it
	ret								; end of subroutine

org 0x2024
pr_item_3:
	call	co_temp_3				; color item?
	ret		nc						; return if so
	call	str_alter				; stream change?
	ret		nc						; return if so
	call	scanning				; evaluate expression
	call	unstack_z				; return if checking syntax
	bit		6, (iy + _flags)		; test type
	call	z, stk_fetch			; call stk-fetch if string
	jp		nz, print_fp			; immediate jump if numeric

org 0x203c
pr_string:
	ld		a, c					; no remaining
	or		b						; characters?
	dec		bc						; reduce count
	ret		z						; return if done
	ld		a, (de)					; code to A
	inc		de						; increase pointer
	rst		print_a					; print it
	jr		pr_string				; loop until done

; THE 'END OF PRINTING' SUBROUTINE
org 0x2045
pr_end_z:
	cp		')'						; closing parenthesis
	ret		z						; return if so

org 0x2048
pr_st_end:
	cp		ctrl_enter				; carriage return?
	ret		z						; return if so
	cp		':'						; colon?
	ret								; end of subroutine

; THE 'PRINT POSITION' SUBROUTINE
org 0x204e
pr_posn_1:
	rst		get_char				; get current character
	cp		';'						; semi-colon?
	jr		z, pr_posn_3			; jump if so
	cp		','						; comma?
	jr		nz, pr_posn_2			; jump if not
	call	syntax_z				; checking syntax?
	jr		z, pr_posn_3			; jump if so
	ld		a, ctrl_comma			; comma control character
	rst		print_a					; print it
	jr		pr_posn_3				; immediate jump

org 0x2061
pr_posn_2:
	cp		0x27					; single quote ( ' )
	ret		nz						; return if not
	call	print_cr				; print carriage return

org 0x2067
pr_posn_3:
	rst		next_char				; next character
	call	pr_end_z				; end of PRINT statement?
	jr		nz, pr_posn_4			; jump if not
	pop		bc						; unstack BC

org 0x206e
pr_posn_4:
	cp		a						; clear zero flag
	ret								; end of subroutine

; THE 'ALTER STREAM' SUBROUTINE
org 0x2070
str_alter:
	cp		'#'						; number sign?
	scf								; set carry flag
	ret		nz						; and return if not
	rst		next_char				; next character
	call	expt_1num				; get parameter
	and		a						; clear carry flag
	call	unstack_z				; return if checking syntax

org 0x207c
str_alter_1:
	call	find_int1				; parameter to A
	cp		16						; in range (0 to 15)?
	jp		nc, report_o			; error if not
	call	chan_open				; open channel
	and		a						; clear carry flag
	ret								; end of subroutine

; THE 'INPUT' COMMAND ROUTINE
org 0x2089
input:
	call	syntax_z				; checking syntax?
	jr		z, input_1				; jump if so
	call	cls_lower				; clear lower display
	ld		a, 1					; channel 'K'
	call	chan_open				; open channel

org 0x2096
input_1:
	ld		(iy + _vdu_flag), 1		; signal lower screen
	call	in_item_1				; deal with input items
	call	check_end				; next statement if checking syntax
	ld		bc, (s_posn)			; print position to bc
	ld		a, (df_sz)				; df-sz to A
	cp		b						; current position above lower screen?
	jr		c, input_2				; jump if so
	ld		b, a					; set print position to top of lower screen
.ifdef ROM0
	ld		c, 81					; leftmost position in text mode
.endif
.ifdef ROM1
	ld		c, 33					; leftmost position in graphics mode
.endif

org 0x20ad
input_2:
	ld		(s_posn), bc			; set print position
	ld		a, 25					; 24 rows
	sub		b						; subtract to get real count
	ld		(scr_ct), a				; set scroll count
	res		0, (iy + _vdu_flag)		; signal main screen
	call	cl_set					; set system variables
	jp		cls_lower				; immediate jump

org 0x20c1
in_item_1:
	call	pr_posn_1				; position controls?
	jr		z, in_item_1			; jump if so
	cp		'('						; opening parenthesis?
	jr		nz, in_item_2			; jump if not
	rst		next_char				; next character
	call	print_2					; print items in parentheses
	rst		get_char				; get current character
	cp		')'						; closing parenthesis?
	jp		nz, report_c			; error if not
	rst		next_char				; next character
	jp		in_next_2				; immediate jump

org 0x20d8
in_item_2:
	cp		tk_line					; LINE?
	jr		nz, in_item_3			; jump if not
	rst		next_char				; next character
	call	class_1					; get value
	set		7, (iy + _flagx)		; signal INPUT LINE
	bit		6, (iy + _flags)		; string variable?
	jp		nz, report_c			; error if not
	jr		in_prompt				; immediate jump

org 0x20ed
in_item_3:
	call	alpha					; letter?
	jp		nc, in_next_1			; jump if not
	call	class_1					; get variable address
	res		7, (iy + _flagx)		; signal not INPUT LINE

org 0x20fa
in_prompt:
	call	syntax_z				; checking syntax?
	jp		z, in_next_2			; jump if so
	call	set_work				; clear workspace
	ld		bc, 1					; one location for prompt
	ld		hl, flagx				; point to flagx
	set		5, (hl)					; signal INPUT mode
	res		6, (hl)					; signal string result
	bit		7, (hl)					; LINE?
	jr		nz, in_pr_2				; jump if so
	ld		a, (flags)				; flags to A
	and		%01000000				; numeric?
	jr		nz, in_pr_1				; jump if so
	ld		c, 3					; three locations required

org 0x211a
in_pr_1:
	or		(hl)					; set bit 6 of
	ld		(hl), a					; flagx if numeric

org 0x211c
in_pr_2:
	rst		bc_spaces				; make space
	ld		(hl), ctrl_enter		; set last location to carriage return
	bit		1, c					; only one location required?
	jr		z, in_pr_3				; jump if so
	ld		a, '"'					; store double quote
	ld		(de), a					; in second location
	dec		hl						; next location
	ld		(hl), a					; store in first location

org 0x2128
in_pr_3:
	ld		(k_cur), hl				; set cursor position
	bit		7, (iy + _flagx)		; INPUT LINE?
	jr		nz, in_var_3			; jump if so
	ld		hl, (ch_add)			; get ch-add
	push	hl						; stack it
	ld		hl, (err_sp)			; get err-sp
	push	hl						; stack it

org 0x2139
in_var_1:
	ld		hl, in_var_1			; stack
	push	hl						; return address
	bit		4, (iy + _flags2)		; channel 'K'?
	jr		z, in_var_2				; jump if not
	ld		(err_sp), sp			; else update error stack pointer

org 0x2147
in_var_2:
	ld		hl, (worksp)			; HL to start of INPUT line
	call	remove_fp				; deal with floating point forms
	ld		(iy + _err_nr), OK		; signal no error
	call	editor					; get the INPUT
	res		7, (iy + _flags)		; signal syntax checking
	call	in_assign				; validate input
	jp		in_var_4				; immediate jump

org 0x215e
in_var_3:
	call	editor					; get line

org 0x2161
in_var_4:
	ld		(iy + _k_cur_h), 0		; clear cursor address
	call	in_chan_k				; channel 'K'?
	jr		nz, in_var_5			; jump if not
	call	ed_copy					; copy input to display
	ld		bc, (echo_e)			; current position to BC
	call	cl_set					; make it current lower screen position

org 0x2174
in_var_5:
	ld		hl, flagx				; address flagx
	res		5, (hl)					; signal EDIT mode
	bit		7, (hl)					; test for INPUT LINE
	res		7, (hl)					; clear bit 7
	jr		nz, in_var_6			; jump with INPUT LINE
	pop		hl						; discard in-var-1 address
	pop		hl						; unstack err-sp address
	ld		(err_sp), hl			; restore err-sp address
	set		7, (iy + _flags)		; signal runtime
	pop		hl						; unstack original ch-add pointer
	ld		(x_ptr), hl				; store it in x-ptr
	call	in_assign				; make assignment
	ld		hl, (x_ptr)				; original ch-add to HL
	ld		(iy + _x_ptr_h), 0		; clear most significant byte of x-ptr
	ld		(ch_add), hl			; restore HL
	jr		in_next_2				; immediate jump

org 0x219b
in_var_6:
	ld		hl, (stkbot)			; end of LINE to HL
	ld		de, (worksp)			; start of workspace to DE
	scf								; prepare for subtraction
	sbc		hl, de					; length to HL
	ld		c, l					; HL
	ld		b, h					; to BC
	call	stk_store				; stack parameters
	call	let						; make assignment
	jr		in_next_2				; immediate jump

org 0x21af
in_next_1:
	call	pr_item_1				; print items

org 0x21b2
in_next_2:
	call	pr_posn_1				; position controls
	jp		z, in_item_1			; loop until done
	ret								; end of subroutine

; THE 'IN-ASSIGN' SUBROUTINE
org 0x21b9
in_assign:
	ld		hl, (worksp)			; first location of workspace
	ld		(ch_add), hl			; set ch-add to point to it
	rst		get_char				; get current character
	cp		tk_stop					; STOP?
	jr		z, in_stop				; jump if so
	ld		a, (flagx)				; flagx to A
	call	val_fet_2				; get value
	rst		get_char				; get current character
	cp		ctrl_enter				; carriage return?
	ret		z						; return if so
	rst		error					; else
	defb	Syntax_error			; error

org 0x21d0
in_stop:
	call	syntax_z				; checking syntax?
	ret		z						; return if so
	rst		error					; else
	defb	STOP_in_INPUT			; report

; THE 'IN-CHAN-K' SUBROUTINE
org 0x21d6
in_chan_k:
	ld		hl, (curchl)			; base address of current channel
	inc		hl						; high byte of output routine
	inc		hl						; low byte of input routine
	inc		hl						; high byte of input routine
	inc		hl						; channel type
	ld		a, (hl)					; get channel type
	cp		'K'						; 'K'?
	ret								; end of subroutine

; THE 'COLOR ITEM' ROUTINES
org 0x21e1
co_temp_1:
	rst		next_char				; next character

org 0x21e2
co_temp_2:
	call	co_temp_3				; embedded control code?
	ret		c						; return with carry set if not
	rst		get_char				; get current character
	cp		';'						; semi-colon?
	jr		z, co_temp_1			; jump if so
	cp		','						; comma?
	jr		z, co_temp_1			; jump if so
	jp		report_c				; else error

org 0x21f2
co_temp_3:
	cp		tk_pen					; lower than PEN?
	ret		c						; return with carry set if so
	cp		tk_over + 1				; greater than OVER?
	ccf								; set carry and
	ret		c						; return if so
	ld		c, a					; color item to C
	rst		next_char				; advance ch-add
	ld		a, c					; color item to A

org 0x21fc
co_temp_4:
	sub		tk_pen - 16				; reduce range
	push	af						; stack color item
	call	expt_1num				; parameter to calculator stack
	pop		af						; unstack color item
	call	unstack_z				; return if checking syntax
	rst		print_a					; print color item
	call	find_int1				; parameter to A
	rst		print_a					; print parameter
	ret								; return

org 0x220c
	defs	5 , 255					; unused locations (common)

org 0x2211
co_temp_5:
	sub		17						; reduce range
	ld		c, 0					; clear C
	adc		a, c					; PEN or PAPER?
	jr		z, co_temp_7			; jump if so
	sub		2						; reduce range
	adc		a, c					; CLUT or COLOR?
	jr		z, co_temp_c			; jump if so
	inc		c						; LD C, 1
	cp		c						; over?
	ld		b, c					; prepare mask
	ld		a, d					; get parameter
	jr		nz, co_temp_6			; jump with over
	rlca							; clear bit 2 for inverse 0
	rlca							; set for inverse 1
	ld		b, 4					; mask has bit 2 set

org 0x2227
co_temp_6:
	ld		c, a					; store A in C
	ld		a, d					; range to A
	cp		2						; in range?
	jr		nc, report_k			; error if not
	ld		a, c					; restore A
	ld		hl, p_flag				; address p-flag
	jp		co_change				; immediate jump

org 0x2234
co_temp_7:
	ld		a, d					; parameter to A
	ld		b, %00000111			; mask for PEN
	jr		c, co_temp_8			; jump with PEN
	rlca							; shift
	rlca							; left
	rlca							; three times
	ld		b, %00111000			; mask for PAPER

org 0x223e
co_temp_8:
	ld		c, a					; parameter to C
	ld		a, d					; range to A
	cp		10						; in range?
	jr		c, co_temp_9			; jump if so

org 0x2244
report_k:
	rst		error					; else
	defb	Bad_color				; error

org 0x2246
co_temp_9:
	ld		hl, attr_t				; address attr-t
	cp		8						; 0 to 7?
	jr		c, co_temp_b			; jump if so
	ld		a, (hl)					; attr-t to A
	jr		z, co_temp_a			; jump with 8
	or		b						; else apply
	cpl								; mask to make
	and		%00100100				; black or white
	jr		z, co_temp_a			; jump with black
	ld		a, b					; else use white

org 0x2257
co_temp_a:
	ld		c, a					; value to C

org 0x2258
co_temp_b:
	ld		a, c					; value to A
	call	co_change				; update attr-t
	ld		a, 7					; was it
	cp		d						; 0 to 7?
	sbc		a, a					; LD A, 0 if so, else LD A, 255
	call	co_change				; update mask-t
	rlca							; shift mask
	rlca							; left twice
	and		%01010000				; set either bit 6 or 4
	ld		b, a					; store in B
	ld		a, 8					; was it
	cp		d						; 9?
	sbc		a, a					; LD A, 255 if so, else LD A, 255

; THE 'CO-CHANGE' SUBROUTINE
org 0x226c
co_change:
	xor		(hl)					; xor A and contents of system variable
	and		b						; apply mask
	xor		(hl)					; form new system variable
	ld		(hl), a					; store it
	ld		a, b					; mask to A
	inc		hl						; next system variable
	ret								; end of subroutine

org 0x2273
co_temp_c:
	sbc		a, a					; test for COLOR
	ld		a, d					; get parameter
	ld		b, %11111111			; set mask for whole byte
	ld		hl, attr_t				; update temporary attribute
	jr		nz, co_change			; set attr_t for COLOR n
	ld		b, %11000000			; mask CLUT bits
	cp		8						; CLUT 8?
	jr		z, co_temp_d			; jump if so
	cp		4						; greater than CLUT 3?
	jr		nc, report_k			; error if so
	rrca							; rotate
	rrca							; into position
	jr		co_change				; set CLUT
	
org 0x228a
co_temp_d:
	inc		hl						; address mask_t
	ld		a, b					; both CLUT bits will be set
	jr		co_change				; immediate jump

org 0x228e
clr_rst:
	call	rest_run				; do a restore
	jp		cls						; on clear

; THE 'BORDER' COMMAND ROUTINE
org 0x2294
border:
	call	find_int1				; get parameter
	cp		8						; in range?
	jr		nc, report_k			; error if not
.ifdef ROM0
	ld		b, a					; invert
	ld		a, 7					; to get
	sub		b						; paper
	rlca							; shift left
	rlca							; three
	rlca							; times
	or		%00000110				; preserve 512x192 mode
	out		(scld), a				; change color
	ret								; end of subroutine

org 0x22a7	
	defs	96, 255					; unused locations (ROM 0)
.endif
.ifdef ROM1
	out		(ula), a				; set border color
	rlca							; shift
	rlca							; left
	rlca							; three times
	bit		5, a					; light paper?
	jr		nz, border_1			; jump if so
	xor		%00000111				; dark paper so set light pen

org 0x22a6
border_1:
	ld		(bordcr), a				; set system variable
	ret								; end of subroutine

; THE 'PIXEL ADDRESS' SUBROUTINE
org 0x22aa
pixel_add:
	ld		a, 191					; y co-ordinate
	sub		b						; in range?
	jp		c, report_b2			; error if not
	ld		b, a					; 191 - y
	rra								; shift right and clear bit 7
	scf								; set carry flag
	rra								; shift right and set bit 7
	and		a						; clear carry flag
	rra								; shift right and clear bit 7
	xor		b						; xor 191 - y
	and		%11111000				; preserve high five bits
	xor		b						; xor 191 - y
	ld		h, a					; high byte of pixel address to H
	ld		a, c					; x to A
	rlca							; shift
	rlca							; left
	rlca							; three times
	xor		b						; xor 191 - y
	and		%11000111				; discard bits 3 to 5
	xor		b						; xor 191 - y
	rlca							; shift left
	rlca							; twice
	ld		l, a					; low byte of pixel address to L
	ld		a, c					; x to A
	and		%00000111				; x mod 8
	ret								; end of subroutine

org 0x22ca
	defs	1, 255					; unused locations (common)

; THE 'POINT' SUBROUTINE
org 0x22cb
point_sub:
	call	coords_to_bc			; accept negative values as offset
	call	pixel_add				; pixel address to HL
	inc		a						; increase A
	ld		b, a					; set loop count
	ld		a, (hl)					; pixel byte to A

org 0x22d4
point_lp:
	rlca							; shift left
	djnz	point_lp				; loop until done
	and		%00000001				; place PEN/PAPER bit
	jp		stack_a					; immediate jump

; THE 'PLOT' COMMAND ROUTINE
org 0x22dc
plot:
	call	coords_to_bc			; accept negative values as offset
	call	plot_sub				; plot
	jp		temps					; immediate jump

org 0x22e5
plot_sub:
	ld		(coords), bc			; set system variable
	call	pixel_add				; pixel address to HL
	inc		a						; increase A
	ld		b, a					; set loop count
	ld		a, %11111110			; place zero

org 0x22f0
plot_loop:
	rrca							; shift right
	djnz	plot_loop				; loop until done
	ld		b, a					; result to B
	ld		a, (hl)					; pixel byte to A
	ld		c, (iy + _p_flag)		; p-flag to C
	bit		0, c					; OVER 1?
	jr		nz, pl_tst_in			; jump if so
	and		b						; zero pixel

org 0x22fd
pl_tst_in:
	bit		2, c					; INVERSE 1?
	jr		nz, plot_end			; jump if so
	xor		b						; else
	cpl								; INVERSE 0

org 0x2303
plot_end:
	ld		(hl), a					; write pixel byte
	jp		po_attr					; immediate jump
.endif

; THE 'STK-TO-BC' SUBROUTINE
org 0x2307
stk_to_bc:
	call	stk_to_a				; first number to A
	ld		b, a					; store in B
	push	bc						; stack it
	call	stk_to_a				; second number to A
	ld		e, c					; sign to E
	pop		bc						; unstack first number
	ld		d, c					; sign to D
	ld		c, a					; second number to C
	ret								; end of subroutine

; THE 'STK-TO-A' SUBROUTINE
org 0x2314
stk_to_a:
	call	fp_to_a					; last value to A
	jp		c, report_b2			; error if out of range
	ld		c, 1					; positive sign to C
	ret		z						; return if positive
	ld		c, 255					; negative sign to C
	ret								; end of subroutine

.ifdef ROM0
; THE 'DISPLAY ROUTINE' TABLE
org 0x2320
rtable:
	defw	pos_0					; there are eight
	defw	pos_1					; possible positions,
	defw	pos_2					; each representing
	defw	pos_3					; a combination
	defw	pos_4					; of character
	defw	pos_5					; rotation and start
	defw	pos_6					; address at screen-1
	defw	pos_7					; or screen-2

; THE DISPLAY ROUTINES
org 0x2330
pos_4:
	inc		de						; DE now points to SCREEN_2 +1
	set		5, d					; routine continues into pos_0

org 0x2333
pos_0:
	ld		b, 8					; eight bytes to write

org 0x2335
pos_0a:
	ld		a, (de)					; read byte at destination
	bit		0, (iy + _p_flag)		; over?
	jr		nz, over_0				; 
	and		%00000011				; mask area used by new character

org 0x233e
over_0:
	bit		2, (iy + _p_flag)		; inverse?
	jr		z, inverse_0			; jump if so
	xor		%11111100				; else use normal mask

org 0x2346
inverse_0:
	ld		c, (hl)					; get character from font
	sla		c						; shift left one bit
	xor		c						; combine with character from font
	ld		(de), a					; write it back
	inc		d						; point to next screen location
	inc		l						; point to next font data
	djnz	pos_0a					; loop eight times
	jp		pr_all_f				; immediate jump

org 0x2352
pos_1:
	ld	b, 8						; 8 bytes to write

org 0x2354
pos_1a:
	ld		a, (de)					; read byte at destination
	bit		0, (iy + _p_flag)		; over?
	jr		nz, over_1				; jump if so
	and		%11111100				; mask area used by new character

org 0x235d
over_1:
	bit		2, (iy + _p_flag)		; inverse?
	jr		z, inverse_1			; jump if so
	xor		%00000011				; else use normal mask

org 0x2365
inverse_1:
	ld		c, (hl)					; get character from font
	srl		c						; shift
	srl		c						; left 
	srl		c						; by
	srl		c						; five
	srl		c						; bits
	xor		c						; combine with character from font
	ld		(de), a					; write it back
	set		5, d					; DE now points to SCREEN_2
	ld		a, (de)					; read byte at destination
	bit		0, (iy + _p_flag)		; over?
	jr		nz, over_1a				; jump if so
	and		%00001111				; mask area used by new character

org 0x237d
over_1a:
	bit		2, (iy + _p_flag)		; inverse?
	jr		z, inverse_1a			; jump if so
	xor		%11110000				; else use normal mask

org 0x2385
inverse_1a:
	ld		c, (hl)					; get character from font
	sla		c						; shift left
	sla		c						; three
	sla		c						; bits
	xor		c						; combine with character from font
	ld		(de), a					; write it back
	res		5, d					; restore pointer to SCREEN_1
	inc		d						; point to next screen location
	inc		l						; point to next font data
	djnz	pos_1a					; loop 8 times
	jp		pr_all_f				; immediate jump

org 0x2397
pos_2:
	ld		b, 8					; eight bytes to write

org 0x2399
pos_2a:
	set		5, d					; DE now points to SCREEN_2
	ld		a, (de)					; read byte at destination
	bit		0, (iy + _p_flag)		; over?
	jr		nz, over_2				; jump if so
	and		%11110000				; mask area used by new character

org 0x23a4
over_2:
	bit		2, (iy + _p_flag)		; inverse?
	jr		z, inverse_2			; jump if so
	xor		%00001111				; else use normal mask

org 0x23ac
inverse_2:
	ld		c, (hl)					; get character from font
	srl		c						; shift right
	srl		c						; three
	srl		c						; bits
	xor		c						; combine with character from font
	ld		(de), a					; write it back
	res		5, d					; restore pointer to SCREEN_1
	inc		de						; increase pointer
	ld		a, (de)					; read byte at destination
	bit		0, (iy + _p_flag)		; over?
	jr		nz, over_2a				; jump if so
	and		%00111111				; mask area used by new character

org 0x23c1
over_2a:
	bit		2, (iy + _p_flag)		; inverse?
	jr		z, inverse_2a			; jump if so
	xor		%11000000				; else use normal mask

org 0x23c9
inverse_2a:
	ld		c, (hl)					; get character from font
	sla		c						; shift left
	sla		c						; left
	sla		c						; by
	sla		c						; five
	sla		c						; bits
	xor		c						; combine with character from font
	ld		(de), a					; write it back
	inc		d						; point to next screen location
	inc		l						; point to next font data
	dec		de						; adjust screen pointer
	djnz	pos_2a					; loop eight times
	jp		pr_all_f				; immediate jump

org 0x23de
pos_7:
	inc		de						; DE now points to SCREEN_2 +1
	set		5, d					; routine continues into pos_3

org 0x23e1
pos_3:
	inc		de						; next column
	ld		b, 8					; eight bytes to write

org 0x23e4
pos_3a:
	ld		a, (de)					; read byte at destination
	bit		0, (iy + _p_flag)		; over?
	jr		nz, over_3				; jump if so
	and		%11000000				; mask area used by new character

org 0x23ed
over_3:
	bit		2, (iy + _p_flag)		; inverse?
	jr		z, inverse_3			; jump if so
	xor		%00111111				; else use normal mask

org 0x23f5
inverse_3:
	ld		c, (hl)					; get character from font
	sra		c						; shift right one bit
	xor		c						; combine with character from font
	ld		(de), a					; write it back
	inc		d						; point to next screen location
	inc		l						; point to next font data
	djnz	pos_3a					; loop 8 times
	jp		pr_all_f				; immediate jump

org 0x2401
pos_5:
	inc		de						; next column
	ld		b, 8					; eight bytes to write

org 0x2404
pos_5a:
	set		5, d					; DE now points to SCREEN_2
	ld		a, (de)					; read byte at destination
	bit		0, (iy + _p_flag)		; over?
	jr		nz, over_5				; jump if so
	and		%11111100				; mask area used by new character

org 0x240f
over_5:
	bit		2, (iy + _p_flag)		; inverse?
	jr		z, inverse_5			; jump if so
	xor		%00000011				; else use normal mask

org 0x2417
inverse_5:
	ld		c, (hl)					; get character from font
	sra		c						; shift
	sra		c						; right
	sra		c						; by
	sra		c						; five
	sra		c						; bits
	xor		c						; combine with character from font
	ld		(de), a					; write it back
	res		5, d					; restore pointer to SCREEN_1
	inc		de						; increase pointer
	ld		a, (de)					; read byte at destination
	bit		0, (iy + _p_flag)		; over?
	jr		nz, over_5a				; jump if so
	and		%00001111				; mask area used by new character

org 0x2430
over_5a:
	bit		2, (iy + _p_flag)		; inverse?
	jr		z, inverse_5a			; jump if so
	xor		%11110000				; else use normal mask

org 0x2438
inverse_5a:
	ld		c, (hl)					; get character from font
	sla		c						; shift left
	sla		c						; three
	sla		c						; bits
	xor		c						; combine with character from font
	ld		(de), a					; write it back
	inc		d						; point to next screen location
	inc		l						; point to next font data
	dec		de						; adjust screen pointer
	djnz 	pos_5a					; loop eight times
	jp		pr_all_f				; immediate jump

org 0x2449
pos_6:
	inc		de						; next column
	inc		de						; next column
	ld		b, 8					; eight bytes to write

org 0x244d
pos_6a:
	ld		a, (de)					; read byte at destination
	bit		0, (iy + _p_flag)		; over?
	jr		nz, over_6				; jump if so
	and		%11110000				; mask area used by new character

org 0x2456
over_6:
	bit		2, (iy + _p_flag)		; inverse?
	jr		z, inverse_6			; jump if so
	xor		%00001111				; else use normal mask

org 0x245e
inverse_6:
	ld		c, (hl)					; get character from font
	srl		c						; shift right
	srl		c						; three
	srl		c						; bits
	xor		c						; combine with character from font
	ld		(de), a					; write it back
	set		5, d					; DE now points to SCREEN_2
	ld		a, (de)					; read byte at destination
	bit		0, (iy + _p_flag)		; over?
	jr		nz, over_6a				; jump if so
	and		%00111111				; mask area used by new character

org 0x2472
over_6a:
	bit		2, (iy + _p_flag)		; inverse?
	jr		z, inverse_6a			; jump if so
	xor		%11000000				; else use normal mask

org 0x247a
inverse_6a:
	ld		c, (hl)					; get character from font
	sla		c						; shift
	sla		c						; left
	sla		c						; by
	sla		c						; five
	sla		c						; bits
	xor		c						; combine with character from font
	ld		(de), a					; write it back
	res		5, d					; restore pointer to SCREEN_1	
	inc		d						; point to next screen location
	inc		l						; point to next font data
	djnz	pos_6a					; loop eight times
	jp		pr_all_f				; immediate jump

org 0x2490
	defs	75, 255					; unused locations (ROM 0)
.endif
.ifdef ROM1
; THE 'CIRCLE' COMMAND ROUTINE
org 0x2320
circle:
	rst		get_char				; get current character
	cp		','						; comma?
	jp		nz, report_c			; error if not
	rst		next_char				; next character
	call	expt_1num				; stack radius
	call	check_end				; next statement if checking syntax
	fwait							; enter calculator
	fabs							; x, y, z
	frstk							; z to full floating point form
	fce								; exit calculator
	ld		a, (hl)					; get exponent
	cp		129						; radius less than one?
	jr		nc, c_r_gre_1			; jump if not
	fwait							; enter calculator
	fdel							; remove last item
	fce								; exit calculator
	jr		plot					; immediate jump

org 0x233b
c_r_gre_1:
	call	circle_coords			; handle possible negative offset
	ld		(hl), 131				; store new exponent
	fwait							; enter calculator
	fst		5						; store 2 * pi in mem-5
	fdel							; x, y, z
	fce								; exit calculator
	call	cd_prms1				; set parameters
	push	bc						; stack arc count
	fwait							; enter calculator
	fmove							; x, y, z, z
	fgt		1						; x, y, z, z, sin (pi/A)
	fmul							; x, y, z, z * sin (pi/A)
	fce								; exit calculator
	ld		a, (hl)					; arc length to A
	cp		128						; less than 0.5?
	jr		nc, c_arc_ge1			; jump if not
	fwait							; enter calculator
	fdel							; remove last 
	fdel							; two items
	fce								; exit calculator
	pop		bc						; unstack arc-count
	jp		plot					; immediate jump

org 0x235a
c_arc_ge1:
	fwait							; x, y, z, z * sin(pi/A)
	fst		2						; z * sin(pi/A) to mem-2
	fxch							; x, y, z * sin(pi/A), z
	fst		0						; z to mem-0
	fdel							; x, y, z * sin(pi/A)
	fsub							; x, y - z * sin(pi/A)
	fxch							; y - z * sin(pi/A), x
	fgt		0						; y - z * sin(pi/A), x, z
	fadd							; y - z * sin(pi/A), x + z = sa
	fst		0						; sa to mem-0
	fxch							; sa, y - z * sin(pi/A) = sb
	fmove							; sa, sb, sb
	fgt		0						; sa, sb, sb, sa
	fxch							; sa, sb, sa, sb
	fmove							; sa, sb, sa, sb, sb
	fgt		0						; sa, sb, sa, sb, sa
	fstk0							; sa, sb, sa, sb, sa, 0
	fst		1						; 0 to mem-1
	fdel							; sa, sb, sa, sb, sa
	fce								; exit calculator
	inc		(iy + _mem_2)			; increment exponent byte
	call	fp_to_bc				; x coord to A
	push	af						; stack it
	call	fp_to_bc				; y coord to A
	ld		h, a					; store it in H
	pop		af						; unstack x coord
	ld		l, a					; store it in L
	ld		(coords), hl			; set coords
	pop		bc						; unstack arc-count
	jp		drw_steps				; immediate jump

; THE 'DRAW' COMMAND ROUTINE
org 0x2382
draw:
	rst		get_char				; get current character
	cp		','						; comma?
	jr		z, dr_3_prms			; jump if so
	call	check_end				; next statement if checking syntax
	jp		line_draw				; immediate jump

org 0x238d
dr_3_prms:
	rst		next_char				; get angle
	call	expt_1num				; to calculator stack
	call	check_end				; next statement if checking syntax
	fwait							; enter calculator
	fst		5						; g to mem-5
	fstk.5							; x, y, g, 0.5
	fmul							; x, y, g/2
	fsin							; x, y, sin(g/2)
	fmove							; x, y, sin(g/2), sin(g/2)
	fnot							; x, y, sin(g/2), (0/1)
	fnot							; x, y, sin(g/2), (1/0)
	fjpt	dr_sin_nz				; jump if straight line
	fdel							; remove last item
	fce								; exit calculator
	jp		line_draw				; immediate jump

org 0x23a3
dr_sin_nz:
	fst		0						; sin (g/2) to mem-0
	fdel							; x, y
	fst		1						; y to mem-1
	fdel							; x
	fmove							; x, x
	fabs							; x, abs x = x'
	fgt		1						; x, x', y
	fxch							; x, y, x'
	fgt		1						; x, y, x', y
	fabs							; x, y, x', abs y = y'
	fadd							; x, y, x' + y'
	fgt		0						; x, y, x' + y', sin(g/2)
	fdiv							; x, y, (x' + y')/sin(g/2) = z'
	fabs							; x, y, abs z' = z
	fgt		0						; x, y, z, sin(g/2)
	fxch							; z, y, sin(g/2), z
	fce								; exit calculator
	call	cd_prms1				; call subroutine
	push	bc						; stack arc-count
	fwait							; x, y, sin(g/2), z
	fdel							; x, y, sin(g/2)
	fgt		1						; x, y, sin(g/2), sin(g/2 * A)
	fxch							; x, y, sin(g/2 * A), sin(g/2)
	fdiv							; x, y, sin(g/2 * A)/sin(g/2) = w
	fst		1						; w to mem-1
	fdel							; x, y
	fxch							; y, x
	fmove							; y, x, x
	fgt		1						; y, x, x, w
	fmul							; y, x, x * w
	fst		2						; x * w to mem-2
	fdel							; y, x
	fxch							; x, y
	fmove							; x, y, y
	fgt		1						; x, y, y, w
	fmul							; x, y, y * w
	fgt		2						; x, y, y * w, x * w
	fgt		5						; x, y, y * w, x * w, g
	fgt		0						; x, y, y * w, x * w, g, g/A
	fsub							; x, y, y * w, x * w, g - g/A
	fstk.5							; x, y, y * w, x * w, g - g/A, 0.5
	fmul							; x, y, y * w, x * w, g/2 - g/2 * A = f 
	fmove							; x, y, y * w, x * w, f, f
	fsin							; x, y, y * w, x * w, f, sin f
	fst		5						; sin f to mem-5
	fdel							; x, y, y * w, x * w, f
	fcos							; x, y, y * w, x * w, cos f
	fst		0						; cos f to mem-0
	fdel							; x, y, y * w, x * w
	fst		2						; x * w to mem-2
	fdel							; x, y, y * w
	fst		1						; y * w to mem-1
	fgt		5						; x, y, y * w, sin f
	fmul							; x, y, y * w * sin f
	fgt		0						; x, y, y * w * sin f, cos f
	fgt		2						; x, y, y * w * sin f, cos f, x * w 
	fmul							; x, y, y * w * sin f, cos f * x * w
	fadd							; x, y, y * w * sin f + cos f * x * w = u
	fgt		1						; x, y, u, y * w
	fxch							; x, y, y * w, u
	fst		1						; u to mem-1
	fdel							; x, y, y * w
	fgt		0						; x, y, y * w, cos f
	fmul							; x, y, y * w * cos f
	fgt		2						; x, y, y * w * cos f, x * w
	fgt		5						; x, y, y * w * cos f, x * w, sin f
	fmul							; x, y, y * w * cos f, x * w * sin f
	fsub							; x, y, y * w * cos f - x * w * sin f = v
	fst		2						; v to mem-2
	fdel							; x, y
	fxch							; y, x
	fce								; exit calculator
	ld		a, (coords)				; x coord to A
	call	stack_a					; A to calculator stack
	fwait							; y, x, x0
	fst		0						; x0 to mem-0
	fadd							; y , x + x0
	fxch							; x + x0, y
	fce								; exit calculator
	ld		a, (coord_y)			; y coord to A
	call	stack_a					; A to calculator stack
	fwait							; x + x0, y, y0
	fst		5						; y0 to mem-5
	fadd							; x + x0, y + y0
	fgt		0						; x + x0, y + y0, x0
	fgt		5						; x + x0, y + y0, x0, y0
	fce								; exit
	pop		bc						; unstack arc-count

org 0x2405
drw_steps:
	dec		b						; reduce count
	jr		arc_start				; immediate jump

org 0x2408
arc_loop:
	fwait							; enter calculator	
	fgt		1						; un-1
	fmove							; un-1, un-1
	fgt		3						; un-1, un-1, cos (g/A)
	fmul							; un-1, un-1 * cos (g/A)
	fgt		2						; un-1, un-1 * cos (g/A), vn-1
	fgt		4						; un-1, un-1 * cos (g/A), vn-1, sin(g/A)
	fmul							; un-1, un-1 * cos (g/A), vn-1 * sin(g/A)
	fsub							; un-1, un-1 * cos (g/A)-vn-1 * sin(g/A)=un
	fst		1						; Un to mem-1
	fdel							; un-1
	fgt		4						; un-1, sin(g/A)
	fmul							; un-1 * sin(g/A)
	fgt		2						; un-1 * sin(g/A), vn-1
	fgt		3						; un-1 * sin(g/A), vn-1, cos(g/A)
	fmul							; un-1 * sin(g/A), vn-1 * cos(g/A)
	fadd							; un-1 * sin(g/A) + vn-1 * cos(g/A) = vn
	fst		2						; vn to mem-2
	fdel							; x + x0, y + y0, xn, yn
	fce								; exit calculator

org 0x241c
arc_start:
	push	bc						; stack arc-count
	fwait							; x + x0, y + y0, xn, yn
	fst		0						; yn to mem-0
	fdel							; x + x0, y + y0, xn
	fgt		1						; x + x0, y + y0, xn, un
	fadd							; x + x0, y + y0, xn + un = xn + 1
	fmove							; x + x0, y + y0, xn + 1, xn + 1
	fce								; exit calculator
	ld		a, (coords)				; xn' to A
	call	stack_a					; stack xn'
	fwait							; x + x0, y + y0, xn + 1, xn + 1, xn'
	fsub							; x + x0, y + y0, xn + 1, xn + 1 - xn'=un'
	fgt		0						; x + x0, y + y0, xn + 1, un', yn
	fgt		2						; x + x0, y + y0, xn + 1, un', yn, vn
	fadd							; x + x0, y + y0, xn + 1, un', yn + vn=yn+1
	fst		0						; yn + 1 to mem-0
	fxch							; x + x0, y + y0, xn + 1, yn + 1, un'
	fgt		0						; x + x0, y + y0, xn + 1, yn + 1, un', yn+1
	fce								; exit calculator
	ld		a, (coord_y)			; yn' to A
	call	stack_a					; A to calculator stack
	fwait							; enter calculator
	fsub							; x+x0, y+y0, xn+1, yn+1, un', yn+1 - yn'
	fce								; exit calculator
	call	draw_line				; draw next arc
	pop		bc						; unstack arc-count
	djnz	arc_loop				; loop until done
	fwait							; enter calculator
	fdel							; remove last
	fdel							; two items
	fxch							; y  + y0, x + x0
	fce								; exit calculator
	ld		a, (coords)				; x coord to A
	call	stack_a					; A to calculator stack
	fwait							; enter calculator
	fsub							; y + y0, x + x0 - xz'
	fxch							; x + x0 - xz', y + y0
	fce								; exit calculator
	ld		a, (coord_y)			; y coord to A
	call	stack_a					; A to calculator stack
	fwait							; enter calculator
	fsub							; x + x0 - xz', y + y0 - yz'
	fce								; exit calculator

org 0x245a
line_draw:
	jp		draw_line				; immediate jump

; THE 'INITIAL PARAMETERS' SUBROUTINE
org 0x245d
cd_prms1:
	fwait							; z
	fmove							; z, z
	fsqrt							; z, sqr z
	fstk							; z, sqr z, 2
	defb	0x32					; exponent
	defb	0x00					; mantissa
	fxch							; z, 2, sqr z
	fdiv							; z, 2/sqr z
	fgt		5						; z, 2/sqr z, g
	fxch							; z, g, 2/sqr z
	fdiv							; z, mod g = g' * sqr z/2
	fabs							; z, g' * sqr z/2 = A1
	fce								; exit calculator
	call	fp_to_a					; last item to A
	jr		c, use_252				; jump if A rounds to 256 or more
	and		252						; 4 * int (A * 0.25) to A
	add		a, 4					; arc-count to A
	jr		nc, draw_save			; immediate jump

org 0x2475
use_252:
	ld		a, 252					; use 252

org 0x2477
draw_save:
	push	af						; stack arc-count
	call	stack_a					; put it on calculator stack
	fwait							; z, A
	fgt		5						; z, A, g
	fxch							; z, g, A
	fdiv							; z, g/A
	fmove							; z, g/A, g/A
	fsin							; z, g/A, sin(g/A)
	fst		4						; sin(g/A) to mem-4
	fdel							; z, g/A
	fmove							; z, g/A, g/A 
	fstk.5							; z, g/A, g/A, 0.5
	fmul							; z, g/A, g/2 * A
	fsin							; z, g/A, sin(g/2 * A)
	fst		1						; sin(g/2 * A) to mem-1
	fxch							; z, sin(g/2 * A), g/A
	fst		0						; g/A to mem-0
	fdel							; z, sin(g/2 * A) = s
	fmove							; z, s, s
	fmul							; z, s * s
	fmove							; z, s * s, s * s
	fadd							; z, 2 * s * s
	fstk1							; z, 2 * s * s, 1
	fsub							; z, 2 * s * s - 1
	fneg							; z, 1 - 2 * s * s = cos (g/A)
	fst		3						; cos (g/A) to mem-3
	fdel							; z
	fce								; exit calculator
	pop		bc						; restore arc count
	ret								; end of subroutine

; THE 'LINE-DRAWING' SUBROUTINE
org 0x2497
draw_line:
	call	stk_to_bc				; B: abs y, C: abs x, D: sgn y, E: sgn x
	ld		a, c					; abs x
	cp		b						; >= abs y?
	jr		nc, dl_x_ge_y			; jump if so
	xor		a						; vertical step (±1)
	ld		l, c					; abs x to L
	push	de						; stack diagonal step (±1, ±1)
	ld		e, a					; vertical step to DE
	jr		dl_larger				; immediate jump

org 0x24a4
dl_x_ge_y:
	or		c						; abs x and abs y both zero?
	ret		z						; return if so
	ld		l, b					; abs y to L
	ld		b, c					; abs x to B
	push	de						; stack diagonal step (±1, ±1)
	ld		d, 0					; horizontal step to DE (±1)

org 0x24ab
dl_larger:
	ld		h, b					; larger of abs x or abs y to H
	ld		a, h					; and to A
	rra								; int (h/2)

org 0x24ae
d_l_loop:
	add		a, l					; diagonal step?
	jr		c, d_l_diag				; jump if so
	cp		h						; horizontal or vertical step?
	jr		c, d_l_hr_vt			; jump if so

org 0x24b4
d_l_diag:
	sub		h						; reduce A by H
	ld		c, a					; store result in C
	exx								; alternate register set
	pop		bc						; diagonal step to BC'
	push	bc						; put it back on the stack
	jr		d_l_step				; immediate jump

org 0x24bb
d_l_hr_vt:
	ld		c, a					; store A in C
	push	de						; stack step
	exx								; alternate register set
	pop		bc						; horizontal or vertical step to BC'

org 0x24bf
d_l_step:
	ld		hl, (coords)			; coords to HL'
	ld		a, b					; y step from B' to A
	add		a, h					; add H'
	ld		b, a					; result to B'
	ld		a, c					; x step from C' to A
	inc		a						; in
	add		a, l					; range?
	jr		c, d_l_range			; jump if so
	jr		z, report_b3			; else error

org 0x24cc
d_l_plot:
	dec		a						; restore correct value
	ld		c, a					; copy A to C'
	call	plot_sub				; plot step
	exx								; main register set
	ld		a, c					; copy C to A
	djnz	d_l_loop				; loop eight times
	pop		de						; clear stack
	ret								; end of subroutine

org 0x24d7
d_l_range:
	jr		z, d_l_plot				; jump if x position in range

org 0x24d9
report_b3:
	rst		error					; else
	defb	Integer_out_of_range	; error
.endif

; THE 'TEST TRACE' SUBROUTINE
org 0x24db
test_trace_1:
	and		(iy + _flags)			; checking syntax?
	and		(iy + _flags2)			; or trace off?
	jr		z, jp_set_work			; jump if so
	ld		bc, (ppc)				; is it
	and		b						; a direct command?
	jr		nz, jp_set_work			; jump if so
	push	af						; store A
	ld		hl, vdu_flag			; address VDU flag
	ld		d, (hl)					; get a copy in D
	res		0, (hl)					; clear bit 0 of VDU flag
	ld		a, '#'					; number sign
	rst		print_a					; print it
	call	test_trace_2			; print the line number
	pop		af						; restore A

org 0x24f8
jp_set_work:
	jp		set_work				; immediate jump
