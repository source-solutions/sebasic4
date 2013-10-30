; --- THE AUXILIARY ROUTINES --------------------------------------------------

; THE 'TRACE' COMMAND ROUTINE
org 0x3901
trace:
	call	test_0_or_1				; get variable
	set		7, (iy + _flags2)		; switch on
	and		a						; test for zero
	ret		nz						; return if not
	res		7, (iy + _flags2)		; switch off
	ret								; end of routine

; THE 'UDG' COMMAND ROUTINE
org 0x390f
c_udg:
	call	test_0_or_1				; get variable
	set		3, (iy + _flags)		; 8-bit mode
	and		a						; test for zero
	ret		z						; return if so

org 0x3918
c_udg_1:
	res		3, (iy + _flags)		; set 7-bit ASCII
	ret								; end of routine

; THE 'CONSOLE IN' SUBROUTINE
org 0x391d
console_in:
	ld		hl, last_k				; address system variable
	ld		(hl), l					; signal no key

org 0x3921
console_in_2:
	ld		a, (hl)					; get key
	cp		ctrl_enter				; carriage return?
	jr		z, console_in_3			; jump if so
	cp		' '						; space or higher?
	jr		c, console_in_2			; jump if not

org 0x392a
console_in_3:
	jp		key_input_1				; immediate jump

; THE 'CALL' COMMAND ROUTINE		; 17 bytes
org 0x392d
c_call:
	call	find_int2				; get address
	ld		a, c					; test
	or		b						; for zero
	ret		z						; safely ignore COPY command
	ld		h, b					; address
	ld		l, c					; to HL
	call	call_jump				; call address
	exx								; alternate register set
	ld		hl, 0x2758				; restore value of HL'
	exx								; main register set
	ret								; return

org 0x393e
	defs	130, 255				; unused locations (common)

; THE 'RENUM' COMMAND ROUTINE
org 0x39c0
renum:
	ld		hl, (stkend)			; value on stack end to HL
	ld		b, 2					; two values required
	cp		ctrl_enter				; carriage return?
	jr		z, renum_1				; jump if so
	cp		':'						; next statement?
	jr		z, renum_1				; jump if so
	call	expt_1num				; number expected
	ld		b, 1					; one value required

org 0x39d2
renum_param:
	rst		get_char				; get next character
	cp		','						; comma?
	jr		nz, renum_1				; jump if not
	push	bc						; stack BC
	call	sexpt1num				; test for final number
	pop		bc						; unstack BC
	djnz	renum_param				; loop for additional parameters

org 0x39de
renum_1:
	call	check_end				; end of line?
	ld		a, b					; B to A
	cp		2						; two values required?
	jr		z, line_10				; jump if so
	cp		1						; one value required?
	jr		z, step_10				; jump if so
	jr		renum_2					; immediate jump

org 0x39ec
renum_error:
	rst		error					; report
	defb	Parameter_error			; error

org 0x39ee
line_10:
	fwait							; stack
	fstk10							; 10 as
	fce								; first line

org 0x39f1
step_10:
	fwait							; stack
	fstk10							; 10 as
	fce								; step

org 0x39f4
renum_2:
	fwait							; enter calculator
	fst		1						; store step in mem-1
	fdel							; remove it
	fst		0						; store start in mem-0
	fdel							; remove it
	fce								; exit calulator
	ld		hl, (vars)				; start of variables to HL
	jr		l3a01

org 0x39ff
	defs	2, 255					; IM2 vector

l3a01:
	ld		de, (prog)				; start of program to DE
	or		a						; is there a program
	sbc		hl, de					; to renumber?
	ret		z						; return if not
	call	lines_to_de				; get line count
	ld		hl, (mem_1_2)			; get increment
	ld		a, l					; is increment
	or		h						; zero?
	jr		z, renum_error			; error if no increment
	call	hl_equ_hl_x_de			; call hl=hl*de
	jr		c, renum_error			; error with overflow
	ex		de, hl					; offset of last number from first number
	ld		hl, (mem_0_2)			; get new first line number
	add		hl, de					; new last line number
	ld		de, 16384				; max line number is 16383
	or		a						; compare
	sbc		hl, de					; in range?
	jr		nc, renum_error			; error if not
	ld		hl, (prog)				; first line address

org 0x3a28
renum_3:
	call	next_one				; get next line address
	inc		hl						; point to
	inc		hl						; line length
	ld		(mem_4_3), hl			; store it
	inc		hl						; point to
	inc		hl						; command address
	ld		(mem_2), de				; store it

org 0x3a36
renum_4:
	ld		a, (hl)					; get character
	call	number					; skip floating point if required
	cp		ctrl_enter				; carriage return?
	jr		z, renum_5				; jump if so
	call	renum_line				; parse line
	jr		renum_4					; loop until done

org 0x3a43
renum_5:
	ld		de, (mem_2)				; get next line address
	ld		hl, (vars)				; get end of program
	and		a						; test for
	sbc		hl, de					; end of program
	ex		de, hl					; start of current line to HL
	jr		nz, renum_3				; loop until end reached
	call	lines_to_de				; get number of lines in DE
	ld		b, d					; transfer
	ld		c, e					; to BC
	ld		de, 0					; clear DE
	ld		hl, (prog)				; first line address to HL

org 0x3a5b
renum_6:
	push	bc						; stack number of lines to update
	push	de						; stack index of current line
	push	hl						; stack current line address
	ld		hl, (mem_1_2)			; get increment
	call	hl_equ_hl_x_de			; calculate offset
	ld		de, (mem_0_2)			; get new first line number
	add		hl, de					; combine to produce
	ex		de, hl					; current line number in DE
	pop		hl						; unstack current address
	ld		(hl), d					; store
	inc		hl						; new
	ld		(hl), e					; line
	inc		hl						; number
	ld		c, (hl)					; get
	inc		hl						; new
	ld		b, (hl)					; line
	inc		hl						; length
	add		hl, bc					; point to next line
	pop		de						; unstack index
	inc		de						; increment it
	pop		bc						; unstack line count
	dec		bc						; reduce it
	ld		a, c					; no more
	or		b						; lines?
	jr		nz, renum_6				; loop until done
	ret								; exit

;THE 'RENUM LINE' SUBROUTINE
org 0x3a7d
renum_line:
	inc		hl						; point to next character
	ld		(mem_4_1), hl			; store it
	ex		de, hl					; next character address to DE
	ld		bc, 6					; 6 tokens may be followed by a line
	ld		hl, renum_tbl			; table of tokens
	cpir							; match found?
	ex		de, hl					; next character address to HL
	ret		nz						; return if no match
	ld		c, 0					; BC = 0

org 0x3a8e
renum_line_1:
	ld		a, (hl)					; get next character
	cp		' '						; space?
	jr		z, renum_line_3			; jump if so
	call	numeric					; digit?
	jr		nc, renum_line_3		; jump if so
	cp		'.'						; decimal point?
	jr		z, renum_line_3			; jump if so
	cp		ctrl_number				; hidden number?
	jr		z, renum_line_4			; jump if so
	or		%00100000				; make lower case
	cp		'e'						; exponent?
	jr		nz, renum_line_2		; jump if not
	ld		a, c					; digits
	or		b						; found?
	jr		nz, renum_line_3		; jump if so

org 0x3aaa
renum_line_2:
	ld		hl, (mem_4_1)			; address next character
	ret								; return

org 0x3aae
renum_line_3:
	inc		bc						; increment number digit count
	inc		hl						; point to next character
	jr		renum_line_1			; jump to parse character

org 0x3ab2
renum_line_4:
	ld		(mem_2_2), bc			; number of digits in old reference
	push	hl						; stack current character address
	call	number					; skip floating point representation
	call	fn_skpovr_1				; skip spaces
	ld		a, (hl)					; get new character
	pop		hl						; unstack current character address
	cp		':'						; next statement?
	jr		z, renum_line_5			; jump if so
	cp		ctrl_enter				; end of line?
	ret		nz						; return if not

org 0x3ac6
renum_line_5:
	inc		hl						; point to next character
	call	stack_num				; floating point number to calculator stack
	call	fp_to_bc				; line number to BC
	ld		h, b					; BC
	ld		l, c					; to HL
	call	line_addr				; get line address
	jr		c, renum_line_6			; jump if line number too large
	jr		z, renum_line_7			; jump if line exists
	ld		a, (hl)					; end of
	and		%11000000				; of BASIC?
	jr		z, renum_line_7			; jump if not

org 0x3adb
renum_line_6:
	ld		hl, 16383				; use line 16383
	jr		renum_line_8			; immediate jump

org 0x3ae0
renum_line_7:
	ld		(mem_3_4), hl			; store referenced line address
	call	count_to_de				; number of previous lines to DE
	ld		hl, (mem_1_2)			; get increment
	call	hl_equ_hl_x_de			; HL * DE to HL
	ld		de, (mem_0_2)			; get stating line number
	add		hl, de					; new referenced line number to HL

org 0x3af1
renum_line_8:
	ld		de, mem_2_4				; temporary buffer
	push	hl						; stack line number
	call	ln_to_str					; create string representation
	ld		e, b					; number of digits
	inc		e						; in line number
	ld		d, 0					; to DE
	push	de						; stack it
	jr		l3b01

org 0x3aff
	defs	2, 255					; IM2 vector

l3b01:
	push	hl						; stack address of first non-zero
	ld		h, d					; LD H, 0
	ld		l, e					; number of digits in new line number to HL
	ld		bc, (mem_2_2)			; number of digits in old line number to BC
	or		a						; prepare for subtraction
	sbc		hl, bc					; number of digits changed?
	ld		(mem_2_2), hl			; store difference
	jr		z, renum_line_10		; jump if same length
	jr		c, renum_line_9			; jump if fewer digits than old
	ld		b, h					; additional space
	ld		c, l					; required to BC
	ld		hl, (mem_4_1)			; start address of old line number
	call	make_room				; make space
	jr		renum_line_10			; immediate jump

org 0x3b1c
renum_line_9:
	dec		bc						; for each additional digit in old line
	dec		e						; reduce number in new line
	jr		nz, renum_line_9		; loop until done
	ld		hl, (mem_4_1)			; start address of old line number
	call	reclaim_2				; remove excess bytes

org 0x3b26
renum_line_10:
	ld		de, (mem_4_1)			; start address of old line number
	pop		hl						; unstack address of first non-zero
	pop		bc						; unstack digits in new line number
	ldir							; copy new line number into place
	ex		de, hl					; address after line number text to HL
	ld		(hl), 14				; store hidden number marker
	pop		bc						; unstack new line number
	inc		hl						; address of next position in line to HL
	push	hl						; stack it
	call	stack_bc_1				; put it on the calculator stack
	pop		de						; unstack next position in line
	ld		bc, 5					; five bytes
	ldir							; copy them
	ex		de, hl					; address of character after fp to HL
	push	hl						; stack it
	call	fp_to_bc				; remove from calculator stack
	ld		hl, (mem_4_3)			; address of current line's byte length
	push	hl						; stack it
	ld		e, (hl)					; existing length
	inc		hl						; of current line
	ld		d, (hl)					; to DE
	ld		hl, (mem_2_2)			; change in line length
	add		hl, de					; new length of
	ex		de, hl					; current line to DE
	pop		hl						; unstack address of current line's length
	ld		(hl), e					; store
	inc		hl						; new
	ld		(hl), d					; length
	ld		hl, (mem_2)				; next line
	ld		de, (mem_2_2)			; change in length of current line
	add		hl, de					; new address of next line
	ld		(mem_2), hl				; store it
	pop		hl						; unstack address of character after fp
	ret								; end of subroutine

org 0x3b5f
lines_to_de:
	ld		hl, (vars)				; get variables address
	ld		(mem_3_4), hl			; store it
	jr		lines_to_de_1			; immediate jump

org 0x3b67
count_to_de:
	ld		hl, (prog)				; start of program
	ld		de, (mem_3_4)			; end address
	or		a						; prepare for subtraction
	sbc		hl, de					; program present?
	jr		z, lines_to_de_4		; jump if no program

org 0x3b73
lines_to_de_1:
	ld		hl, (prog)				; start address of program
	ld		bc, 0					; initialize counter

org 0x3b79
lines_to_de_2:
	push	bc						; stack counter
	call	next_one				; get address of next line
	ld		hl, (mem_3_4)			; end address
	and		a						; prepare for subtraction
	sbc		hl, de					; end reached?
	jr		z, lines_to_de_3		; jump if so
	ex		de, hl					; address of current line to HL
	pop		bc						; unstack line number count
	inc		bc						; increment it
	jr		lines_to_de_2			; immediate jump

org 0x3b8a
lines_to_de_3:
	pop		de						; unstack number of lines
	inc		de						; increment it
	ret								; and return

org 0x3b8d
lines_to_de_4:
	ld		de, 0					; no program found
	ret								; so return

; THE 'LINE NUMBER TO STRING' SUBROUTINE
org 0x3b91
ln_to_str:
	push	de						; store buffer address
	ld		bc, -10000				; insert
	call	insert_dgt				; ten-thousands
	ld		bc, -1000				; insert
	call	insert_dgt				; thousands
	ld		bc, -100				; insert
	call	insert_dgt				; hundreds
	ld		c, -10					; insert
	call	insert_dgt				; tens
	ld		a, l					; insert
	add		a, '0'					; ones
	ld		(de), a					; store in buffer
	inc		de						; point to next position
	ld		b, 4					; skip four leading zeros
	pop		hl						; unstack start address

org 0x3bb1
ln_to_str_1:
	ld		a, (hl)					; get character
	cp		'0'						; leading zero?
	ret		nz						; return if not
	ld		(hl), ' '				; replace with space
	inc		hl						; next location
	djnz	ln_to_str_1				; loop until done
	ret								; end of subroutine

org 0x3bbb
insert_dgt:
	xor		a						; LD A, 0

org 0x3bbc
insert_dgt_1:
	add		hl, bc					; add negative value
	inc		a						; overflow?
	jr		c, insert_dgt_1			; jump if not
	sbc		hl, bc					; undo last step
	add		a, '0' - 1				; convert to ASCII
	ld		(de), a					; store in buffer
	inc		de						; next location
	ret								; end of subroutine
