; --- THE SCREEN HANDLING ROUTINES --------------------------------------------

; FIXME
; remember to call scroll buffer before po_scr_3 when putting text mode back

; THE 'SCROLL' COMMAND ROUTINE
org 0x09c6
scroll:
	call	find_int1				; get value
	and		a						; zero?
	jr		nz, scrl_nz				; jump if not
	inc		a						; default to one line
	
org 0x09cd
scrl_nz:
	cp		25						; range 1 to 24?
	jr		nc, scrl_err			; error if not
	ld		b, a					; store A
	ld		a, 2					; use upper screen
	call	chan_open				; select it
	ld		a, b					; restore A
	call	scrl_lp					; scroll required lines
	ld		a, 22					; move cursor
	rst		print_a					; to start
	dec		a						; of line
	rst		print_a					; 21
	xor		a						; in either
	rst		print_a					; screen mode
	ret								; end of subroutine

org 0x09e3
scrl_lp:
	dec		a						; reduce count
	ret		z						; return if zero
	ex		af, af'					;'store count
.ifdef ROM0
	call	scrl_bfr				; scroll the buffer
.endif
.ifdef ROM1
	call	po_scr_3				; scroll the screen
.endif
	ex		af, af'					;'restore count
	jp		scrl_lp					; loop until done

org 0x09ed
scrl_err:
	rst		error					; number
	defb	Integer_out_of_range	; too large

; THE 'PRINT-OUT' ROUTINES
org 0x09ef
po_xt:
	add		a, 91					; range is now 91 to 96
	jp		po_t					; jump to print it

org 0x09f4
print_out:
	call	po_fetch				; current print position
	cp		24						; printable character?
	jp		nc, po_able				; jump if so
	cp		6						; token in the range 0-5?
	jr		c, po_xt				; jump if so
	cp		24						; non-printable character?
	jr		nc, po_quest			; jump if so
	ld		d, 0					; move character
	ld		e, a					; to DE
	ld		hl, ctlchrtab - 6		; base of control table
	add		hl, de					; index into table
	ld		e, (hl)					; get offset
	add		hl, de					; add offset
	push	hl						; stack it
	jp		po_fetch				; indirect return

; THE 'CONTROL CHARACTER' TABLE
org 0x0a11
ctlchrtab:
	defb	po_comma - $			; comma
	defb	po_quest - $			; edit
	defb	po_back - $				; left
	defb	po_right - $			; right
	defb	po_quest - $			; down
	defb	po_quest - $			; up
	defb	po_quest - $			; delete
	defb	po_enter - $			; enter
	defb	po_quest - $			; not used
	defb	po_quest - $			; not used
	defb	po_1_oper - $			; pen
	defb	po_1_oper - $			; paper
	defb	po_1_oper - $			; color
	defb	po_1_oper - $			; clut
	defb	po_1_oper - $			; inverse
	defb	po_1_oper - $			; over
	defb	po_2_oper - $			; at
	defb	po_2_oper - $			; tab

; THE 'CURSOR LEFT' SUBROUTINE
org 0x0a23
po_back:
	inc		c						; move left one column
.ifdef ROM0
	ld		a, 82					; left side (text mode)
.endif
.ifdef ROM1
	ld		a, 34					; left side (graphics mode)
.endif
	cp		c						; against left side?
	jp		nz, cl_set				; jump if so
	dec		c						; down one line
	ld		a, 24					; top line
	cp		b						; is it?
	jp		nz, cl_set				; jump if so
	ld		c, 2					; set column value
	inc		b						; up one line
	jp		cl_set					; indirect return

; THE 'CURSOR RIGHT' SUBROUTINE
org 0x0a37
po_right:
	ld		a, (p_flag)				; get p-flag
	push	af						; stack it
	ld		a, ' '					; space
	ld		(iy + _p_flag), 1		; set p-flag to over 1
	call	po_able					; print it
	pop		af						; unstack A
	ld		(p_flag), a				; restore p-flag
	ret								; end of cursor right subroutine

; THE 'CARRIAGE RETURN' SUBROUTINE
org 0x0a49
po_enter:
.ifdef ROM0
	ld		c, 81					; left column (text mode)
.endif
.ifdef ROM1
	ld		c, 33					; left column (graphics mode)
.endif
	call	po_scr					; scroll if required
	dec		b						; down a line
	jp		cl_set					; indirect return

; THE 'PRINT COMMA' SUBROUTINE
org 0x0a52
po_comma:
	ld		a, c					; current column
	dec		a						; move right
	dec		a						; twice
	and		%00010000				; test
	jr		po_fill					; indirect return

; THE 'PRINT A QUESTION MARK' SUBROUTINE
org 0x0a59
po_quest:
	ld		a, '?'					; change character
	jr		po_able					; print it

; THE 'CONTROL CHARACTERS WITH OPERANDS' ROUTINE
org 0x0a5d
po_tv_2:
	ld		(vdu_data_h), a			; store first operand	
	ld		de, po_cont				; change address of output routine
	jr		po_change				; indirect return

org 0x0a65
po_2_oper:
	ld		de, po_tv_2				; change output routine
	jr		po_tv_1					; indirect return

org 0x0a6a
po_1_oper:
	ld		de, po_cont				; change output routine

org 0x0a6d
po_tv_1:
	ld		(vdu_data), a			; store character code

org 0x0a70
po_change:
	ld		hl, (curchl)			; HL = output routine address
	ld		(hl), e					; put new address
	inc		hl						; from DE
	ld		(hl), d					; into (HL)
	ret								; end of subroutine

org 0x0a77
po_cont:
	ld		de, print_out			; original address
	call	po_change				; restore it 
	ld		hl, (vdu_data)			; get control code and first operand
	ld		d, a					; last operand to D
	ld		a, l					; control code to A
	cp		22						; pen or higher?
	jp		c, co_temp_5			; jump if so
	jr		nz, po_tab				; jump if tab
	ld		c, d					; column number
	ld		b, h					; line number
.ifdef ROM0
	ld		a, 79					; reverse line (text mode)
.endif
.ifdef ROM1
	ld		a, 31					; reverse line (graphics mode)
.endif
	sub		c						; in range?
	jr		c, po_at_err			; jump if not
	add		a, 2					; add offset
	ld		c, a					; store it in C
	ld		a, 22					; reverse row
	sub		b						; in range?

org 0x0a96
po_at_err:
	jp		c, report_b2			; jump if not
	inc		a						; increase range
	ld		b, a					; store it in B
	inc		b						; increase range
	bit		0, (iy + _vdu_flag)		; lower screen
	jp		nz, po_scr				; jump if so
	cp		(iy + _df_sz)			; in screen?
	jp		c, report_5				; jump if not
	jp		cl_set					; indirect return

org 0x0aac
po_tab:
	ld		a, h					; first operand

org 0x0aad
po_fill:
	call	po_fetch				; current position
	add		a, c					; add column
	dec		a						; number of spaces
	and		%00011111				; modulo 32
	ret		z						; return if zero
	set		0, (iy + _flags)		; no leading space
	ld		d, a					; use 0 as counter

org 0x0aba
po_space:
	ld		a, ' '					; space
	call	po_save					; recursively
	dec		d						; print
	jr		nz, po_space			; until
	ret								; done

; THE 'MODE' COMMAND ROUTINE
org 0x0ac3
c_mode:
	call	test_0_or_1				; get variable
	and		a						; test for zero
.ifdef ROM0
	call	z, mode_switch			; switch if required
.endif
.ifdef ROM1
	call	nz, mode_switch			; switch if required
.endif
	jp		cls						; exit via cls

org 0x0acd
	defs	1, 255					; unused locations (common)

; PRINTABLE CHARACTER CODES
org 0x0ace
po_able:
	bit		3, (iy + _flags)		; test for 8-bit ASCII
	jr		z, po_able_2			; jump if not
	call	po_char					; print a character if so
	jr		po_store				; and store

org 0x0ad9
po_able_2:
	call	po_any					; print character and continue

; THE 'POSITION STORE' SUBROUTINE
org 0x0adc
po_store:
	bit		0, (iy + _vdu_flag)		; test for lower screen
	jr		nz, po_st_e				; jump if so
	ld		(df_cc), hl				; store values for
	ld		(s_posn), bc			; upper screen
	ret								; end of subroutine

org 0x0aea
po_st_e:
	ld		(df_ccl), hl			; store values
	ld		(sposnl), bc			; for lower
	ld		(echo_e), bc			; screen
	ret								; end of subroutine

; THE 'PUT' COMMAND ROUTINE
org 0x0af6
put:
	call	find_int2				; get byte count
	push	bc						; stack it
	call	find_int2				; get destination
	push	bc						; stack it
	call	find_int2				; get source
	jr		put_1					; immediate jump

; THE 'POSITION FETCH' SUBROUTINE
org 0x0b03
po_fetch:
	ld		hl, (df_cc)				; get main
	ld		bc, (s_posn)			; screen values
	bit		0, (iy + _vdu_flag)		; main screen?
	ret		z						; return if so
	ld		hl, (df_ccl)			; get lower
	ld		bc, (sposnl)			; screen values
	ret								; and return

; THE 'PUT' COMMAND ROUTINE (CONTINUED)
org 0x0b17
put_1:
	push	bc						; stack it
	pop		hl						; unstack source
	pop		de						; unstack destination
	pop		bc						; unstack byte count
	ldir							; block copy
	ret								; end of routine

; THE 'SET 7-BIT ASCII' SUBROUTINE
org 0x0b1e
set_7:								; 6 bytes
	call	line_addr				; get line address
	jp		c_udg_1					; set 7-bit ASCII

; THE 'PRINT ANY CHARACTER(S)' SUBROUTINE
org 0x0b24
po_any:
	cp		128						; 7-bit ASCII?
	jr		c, po_char				; jump if so
	cp		144						; TOKENs or UDGs?
	jr		nc, po_t_and_udg		; jump if so
	ld		b, a					; block graphic
	call	po_gr_1					; construct form
	call	po_fetch				; restore HL
	ld		de, membot				; point to block graphic in membot
	jr		pr_all					; immediate jump

org 0x0b38
po_gr_1:
	ld		hl, membot				; membot to HL
	call	po_gr_2					; call subroutine twice

org 0x0b3e
po_gr_2:
	rr		b						; determine bit 0 or 2 of graphic
	sbc		a, a					; A will hold either 0x00 or 0x0f
.ifdef ROM0
	and		%00001110				; right side (text mode)
.endif
.ifdef ROM1
	and		%00001111				; right side (graphics mode)
.endif
	ld		c, a					; result to C
	rr		b						; determine bit 1 or 3 of graphic
	sbc		a, a					; A will hold either 0x00 or 0xf0
.ifdef ROM0
	and		%01110000				; left side (text mode)
.endif
.ifdef ROM1
	and		%11110000				; left side (grahpics mode)
.endif
	or		c						; combine results
	ld		c, 4					; A holds half the form, used four times

org 0x0b4c
po_gr_3:
	ld		(hl), a					; write bitmap
	dec		c						; reduce count
	inc		hl						; next location
	jr		nz, po_gr_3				; loop until done
	ret								; end of subroutine

org 0x0b52
po_t_and_udg:
	sub		tk_rnd					; RND token or higher?
	jr		nc, po_t				; jump if so
	push	bc						; stack position
	add		a, 21					; codes now 0 to 20
	ld		bc, (udg)				; get base address of UDGs
	jr		po_char_2				; immediate jump

org 0x0b5f
po_t:
	call	po_tokens				; print token
	jp		po_fetch				; indirect return

org 0x0b65
po_char:
	push	bc						; stack current position
	ld		bc, (chars)				; address of font definition - 256

org 0x0b6a
po_char_2:
	ex		de, hl					; store print address in DE
	ld		hl, flags				; get flags
	res		0, (hl)					; possible leading space
	cp		' '						; test for space
	jr		nz, po_char_3			; jump if not
	set		0, (hl)					; suppress if so

org 0x0b76
po_char_3:
	ld		l, a					; character code
	ld		h, 0					; to HL
	add		hl, hl					; multiply
	add		hl, hl					; character
	add		hl, hl					; code
	add		hl, bc					; by eight
	ex		de, hl					; base address to DE
	pop		bc						; unstack current position

; THE 'PRINT ALL CHARACTERS' SUBROUTINE
org 0x0b7f
pr_all:
	ld		a, c					; get column number
	dec		a						; move it right one position
.ifdef ROM0
	ld		a, 81					; new column? (text mode)
.endif
.ifdef ROM1
	ld		a, 33					; new column? (graphics mode)
.endif
	jr		nz, pr_all_1			; jump if not
	ld		c, a					; move down
	dec		b						; one line

org 0x0b87
pr_all_1:
	cp		c						; new line?
	push	de						; stack DE
	call	z, po_scr				; scrolling required?
	pop		de						; unstack DE
	push	bc						; stack position
	push	hl						; stack destination

.ifdef ROM0
	ld		a, 81					; text mode printing
	sub		c						; get position
	ld		b, a					; save it
	and		0x07					; mask off bit 0-2
	ld		c, a					; store number of routine to use
	ld		a, b					; retrieve it
	and		0x78					; mask off bit 3-6
	rrca							; shift three
	rrca							; bits to
	rrca							; the right
	and		a						; test for zero
	push	de						; save font address *
	jr		z, pr_all_2				; to next part if so
	ld		d, 0					; clear d
	ld		e, a					; put a in e
	add		hl, de					; add three times
	add		hl, de					; contents of a
	add		hl, de					; to hl

org 0x0ba6
pr_all_2:
	ex		de, hl					; put the result back in DE

; HL now points to the location of the first byte of char data in FONT_1
; DE points to the first screen byte in SCREEN_1
; C holds the offset to the routine

	ld		b, 0					; prepare to add
	rlc		c						; double the value in C
	ld		hl, rtable				; base address of table
	add		hl, bc					; add C
	ld		c, (hl)					; fetch low byte of routine
	inc		hl						; increment HL
	ld		b, (hl)					; fetch high byte of routine
	pop		hl						; restore font address *
	ld		(attr_t), sp			; save old stack pointer
	ld		sp, mem_5_4				; point to end of calc memory
	push	bc						; push the address on machine stack
	ld		bc, paging				; page out VRAM
	ld		a, %00001111			; ROM 0, VRAM 1, RAM 7
	out		(c), a					; set it
	ret								; indirect jump forward to routine

org 0x0bc3
pr_all_f:
	ld		bc, paging				; page out VRAM
	ld		a, %00001000			; ROM 0, VRAM 1, RAM 0
	out		(c), a					; set it
	ld		sp, (attr_t)			; restore stack pointer
	pop		hl						; get original screen position
	pop		bc						; get original row/col
	dec		c						; move right
	ret								; return via po_store

org 0x0bd2
cl_scr_x:
	jp		nz, cl_line_1			; clear text mode screen
	ld		h, d					; DE
	ld		l, e					; to HL
	inc		de						; increment DE
	ld		bc, paging				; page out VRAM
	ld		a, %00001000			; ROM 0, VRAM 1, RAM 0
	out		(c), a					; set it
	ld		sp, (attr_t)			; restore stack pointer
	pop		bc						; unstack BC
	ret								; end of subroutine
.endif
.ifdef ROM1
	ld		a, (p_flag)				; get p-flag
	ld		b, 255					; set OVER mask
	rra								; OVER state to carry flag
	jr		c, pr_all_2				; jump if not
	inc		b						; clear mask

org 0x0b98
pr_all_2:
	rra								; bit 2 of p-flag
	rra								; to carry flag
	sbc		a, a					; set INVERSE mask
	ld		c, a					; INVERSE state to C
	ld		a, 8					; pixel line count
	and		a						; clear carry flag
	ex		de, hl					; switch destination and base address

org 0x0ba0
pr_all_4:
	ex		af, af'					;'store AF
 	ld		a, (de)					; get existing screen byte
 	and		b						; use OVER mask
 	xor		c						; use INVERSE mask
 	xor		(hl)					; mix with character byte
 	ld		(de), a					; store result
	ex		af, af'					;'restore AF
 	inc		d						; next screen byte
 	dec		a						; reduce counter
	inc		hl						; next character byte
	jr		nz, pr_all_4			; loop until zero
 	ex		de, hl					; put correct high-address for character
 	dec		h						; in H
	call	po_attr					; set attribute byte
	pop		hl						; unstack destination
	pop		bc						; unstack position
	dec		c						; reduce column number
	inc		hl						; next screen position
	ret								; end of subroutine 

; THE 'SET ATTRIBUTE BYTE' SUBROUTINE
org 0x0bb6
po_attr:
	ld		a, h					; high byte of destination address
	rrca							; divide
	rrca							; by
	rrca							; eight
	and		%00000011				; determine which third of screen to use
	or		%01011000				; form high byte for attribute area
	ld		h, a					; high byte to H
	ld		de, (attr_t)			; temporary attribute and mask
	ld		a, (hl)					; old attribute value to A
	xor		e						; mask-t
	and		d						; attr-t
	xor		e						; mask-t
	bit		6, (iy + _p_flag)		; PAPER 9?
	jr		z, po_attr_1			; jump if not
	and		%11000111				; ignore PAPER color
	bit		2, a					; test PEN color
	jr		nz, po_attr_1			; conditional jump
	xor		%00111000				; set black or white PAPER accordingly

org 0x0bd5
po_attr_1:
	bit		4, (iy + _p_flag)		; PEN 9?
	jr		z, po_attr_2			; jump if not
	and		%11111000				; ignore PEN color
	bit		5, a					; test PEN color
	jr		nz, po_attr_2			; conditional jump
	xor		%00000111				; set black or white PEN accordingly

org 0x0be3
po_attr_2:
	ld		(hl), a					; set new attribute value
	ret								; end of subroutine
.endif

; THE 'SET INITIAL PALETTE' SUBROUTINE
org 0x0be5
set_init_pal:
	ld		a, 64					; byte count
	ld		e, 0					; clear E
	call	set_pal					; set palette

; THE 'RESET' COMMAND
org 0x0bec
reset:
	xor		a						; LD A, 0
	ld		hl, palbuf				; address palette buffer

org 0x0bf0
reset_loop:
	ld		e, (hl)					; get palette byte
	call	set_pal					; set it
	inc		a						; increase count
	inc		l						; increase location
	cp		64						; all done?
	jr		c, reset_loop			; loop until done
	ret								; end of routine

; THE 'MESSAGE PRINTING' SUBROUTINE
org 0x0bfb
po_can_tok:
	ld		a, (de)					; get code
	and		%01111111				; cancel inverted bit
	cp		' '						; test for printable character
	ret		nc						; return if so
	cp		ctrl_enter				; test for carriage return
	ret		z						; return if so
	cp		ctrl_left				; test for cursor left
	ret		z						; return if so
	add		a, 223					; add canned token offset
	ret								; end of subroutine

org 0x0c0a
po_msg:
	push	hl						; stack last entry
	ld		h, 0					; zero high byte
	ex		(sp), hl				; to suppress trailing spaces
	jr		po_table				; immediate jump

org 0x0c10
po_tokens:
	ld		de, token_table - 1		; address token table
	push	af						; stack code

org 0x0c14
po_table:
	call	po_search				; locate required entry 
	jr		c, po_each				; print message or token
	ld		a, ' '					; print a space
	bit		0, (iy + _flags)		; before
	call	z, po_save				; if required

org 0x0c22
po_each:
	call	po_can_tok				; handle canned tokens
	call	po_save					; print the character
	ld		a, (de)					; get code again
	inc		de						; increment pointer
	add		a, a					; inverted bit to carry flag
	jr		nc, po_each				; loop until done
	pop		de						; D = 0x00 for tokens, -0x5a for messages
	cp		72						; last character a '$'?
	jr		z, po_trsp				; jump if so
	cp		130						; last character less than 'A'?
	ret		c						; return if so

org 0x0c35
po_trsp:
	ld		a, d					; offset to A
	cp		3						; RND, INKEY$ or PI?
	ret		c						; return if so
	ld		a, ' '					; print trailing space

; THE 'PO-SAVE' SUBROUTINE
org 0x0c3b
po_save:
	push	de						; stack DE
	exx								; preserve HL and BC
	rst		print_a					; print one character
	exx								; restore HL and BC
	pop		de						; unstack DE
	ret								; end of subroutine

; THE 'TABLE SEARCH' SUBROUTINE
org 0x0c41
po_search:
	ex		de, hl					; base address to HL
	push	af						; stack entry number
	inc		a						; increase range

org 0x0c44
po_step:
	bit		7, (hl)					; last character?
	inc		hl						; next character
	jr		z, po_step				; jump if not
	dec		a						; reduce count
	jr		nz, po_step				; loop until entry found
	ex		de, hl					; DE points to initial character
	pop		af						; unstack entry number
	cp		32						; one of the first 32 entries?
	ret		c						; return with carry set if so
	ld		a, (de)					; get initial character
	sub		'A'						; test against letter, leading space if so
	ret								; end of subroutine

; THE 'TEST FOR SCROLL' SUBROUTINE
org 0x0c55
po_scr:
	ld		de, cl_set				; put cl-set
	push	de						; on the stack
	ld		a, b					; line number to B
	bit		0, (iy + _vdu_flag)		; INPUT or AT?
	jp		nz, po_scr_4			; jump if so
	cp		(iy + _df_sz)			; line number less than df_sz?
	jr		c, report_5				; jump if so
	ret		nz						; return via cl-set if greater
	bit		4, (iy + _vdu_flag)		; automatic listing?
	jr		z, po_scr_2				; jump if not
	ld		e, (iy + _breg)			; get line counter
	dec		e						; reduce it
	jp		z, po_scr_3				; jump if listing scroll required
	xor		a						; LD A, 0
	call	chan_open				; open channel 'K'
	ld		sp, (list_sp)			; restore stack pointer
	res		4, (iy + _vdu_flag)		; flag automatic listing finished
	ret								; return via cl-set

org 0x0c81
	defs	5, 255					; unused locations (common)

org 0x0c86
report_5:
	rst		error					; error
	defb	Off_screen				; off screen

org 0x0c88
po_scr_2:
	dec		(iy + _scr_ct)			; reduce scroll count
	jr		nz, po_scr_3			; jump unless zero
	ld		a, 24					; reset
	sub		b						; counter
	ld		(scr_ct), a				; store scroll count
.ifdef ROM1
	ld		hl, (attr_t)			; get temporary attribute and mask
	push	hl						; stack HL
	ld		a, (p_flag)				; p-flag to A
	push	af						; stack A
.endif
	ld		a, 0xfd					; open
	call	chan_open				; channel 'K'
	xor		a						; message offset
	ld		de, scrl_msg			; message address
	call	po_msg					; print it
	set		5, (iy + _vdu_flag)		; signal clear lower screen after keystroke
	ld		hl, flags				; address flags
	res		5, (hl)					; signal no key
	call	console_in				; fetch a single key code
	cp		' '						; space?
	jr		z, report_d				; treat as BREAK and jump if so
	or		%00100000				; 'N' or
	cp		'n'						; 'n'?
	jr		z, report_d				; treat as BREAK and jump if so
	ld		a, 0xfe					; open
	call	chan_open				; channel 'S'
.ifdef ROM1
	pop		af						; unstack p-flag
	ld		(p_flag), a				; restore it
	pop		hl						; unstack temporary attribute and mask
	ld		(attr_t), hl			; restore them

org 0x0cca
.endif

po_scr_3:
	call	cl_sc_all				; scroll whole display
	ld		b, (iy + _df_sz)		; get line number
	inc		b						; for start of line
.ifdef ROM0
	ld		c, 81					; first column (text mode)
.endif
.ifdef ROM1
	ld		c, 33					; first column (graphics mode)
	push	bc						; stack line and column
	call	cl_addr					; calculate address
	ld		a, h					; attribute byte to A
	rrca							; divide
	rrca							; by
	rrca							; eight
	and		%00000011				; determine which third of screen to use
	or		%01011000				; form high byte for attribute area
	ld		h, a					; high byte to H
	ld		de, attrmap + 0x02e0	; first attribute of bottom line
	ld		a, (de)					; get value
	ld		c, (hl)					; lower part value
	ld		b, 32					; 32 bytes
	ex		de, hl					; exchange pointers

org 0x0ce8
po_scr_3a:
	ld		(de), a					; swap attribute
	ld		(hl), c					; bytes
	inc		de						; next destination attribute
	inc		hl						; next source attribute
	djnz	po_scr_3a				; loop until done
	pop		bc						; unstack line and column numbers
.endif
	ret								; end of subroutine
.ifdef ROM0

org 0x0cc4
ldir2:
	push	hl						; stack source
	push	de						; stack destination
	push	bc						; stack byte count
	set		5, h					; add 8192 byte offset to source
	set		5, d					; add 8192 byte offset to destination
	ldir							; clear odd columns
	pop		bc						; unstack original source
	pop		de						; unstack original destination
	pop		hl						; unstack original byte count
	ldir							; clear even columns
	ret								; end of subroutine

org 0x0cd3
cls2nd:
	ld		d, h					; copy HL
	ld		e, l					; to DE
	ld		(hl), 0					; zero byte addressed by HL
	inc		de						; DE points to next byte
	ldir							; wipe bytes
	ret								; end of subroutine

org 0x0cdb
 	defs	21, 255					; unused locations (ROM 0)
.endif
 
org 0x0cf0
report_d:
	rst		error					; error
	defb	BREAK_CONTINUE_repeats	; BREAK key

org 0x0cf2
po_scr_4:
	cp		2						; lower part fits?
	jr		c, report_5				; error if not
	add		a, (iy + _df_sz)		; number of scrolls to A
	sub		25						; scroll required?
	ret		nc						; return if not
	neg								; make number positive
	push	bc						; stack line and column numbers

.ifdef ROM1
	ld		b, a					; store scroll number
	ld		hl, (attr_t)			; get attr-t
	push	hl						; stack it
	ld		hl, (p_flag)			; get p-flag
	push	hl						; stack it
	call	temps					; use permanent color items
	ld		a, b					; restore scroll number
.endif

po_scr_4a:
	push	af						; stack number
	ld		hl, df_sz				; address of df-sz
	ld		b, (hl)					; df-sz to b
	ld		a, b					; df-sz to a
	inc		a						; increment df-sz
	ld		(hl), a					; store it
	ld		hl, s_posn_h			; address of s-posn-h
	cp		(hl)					; lower scrolling only required?
	jr		c, po_scr_4b			; jump if so
	inc		(hl)					; increment s-posn-h
	ld		b, 23					; scroll whole display

po_scr_4b:
	call	cl_scroll				; scroll number of lines in B
	pop		af						; unstack scroll number
	dec		a						; reduce it
	jr		nz, po_scr_4a			; loop until done
.ifdef ROM1
	pop		hl						; unstack p-flag
	ld		(iy + _p_flag), l		; restore p-flag
	pop		hl						; unstack temporary attr and mask 
	ld		(attr_t), hl			; restore attr-t
.endif
	ld		bc, (s_posn)			; get s-posn
	res		0, (iy + _vdu_flag)		; in case changed
	call	cl_set					; give matching value to df-cc
	set		0, (iy + _vdu_flag)		; set lower screen in use
	pop		bc						; unstack line and column numbers
	ret								; end of subroutine
.ifdef ROM0

org 0x0d28
 	defs	21, 255					; unused locations (ROM 0)
.endif

org 0x0d3d
 	defs	3, 255					; unused locations (common)

; THE 'TEST 0 OR 1' SUBROUTINE
org 0x0d40
test_0_or_1:
	call	find_int1				; get variable
	cp		2						; 0 or 1?
	ret		c						; return if so
	pop		af						; else drop return address
	rst		error					; and call
	defb	Integer_out_of_range	; error handler

; THE 'TEMPORARY COLOR ITEMS' SUBROUTINE
org 0x0d49
temps:
	ld		hl, (attr_p)			; get permanent attribute and mask
	xor		a						; LD A, 0
	bit		0, (iy + _vdu_flag)		; main screen?
	jr		z, temps_1				; jump if so
	ld		l, (iy + _bordcr)		; else use border color
	ld		h, a					; and 0

org 0x0d57
temps_1:
	ld		(attr_t), hl			; get temporary attribute and mask
	ld		hl, p_flag				; point to p-flag
	jr		nz, temps_2				; jump with lower screen
	ld		a, (hl)					; p-flag to A
	rrca							; rotate odd bits to even bits

org 0x0d61
temps_2:
	xor		(hl)					; copy even bits
	and		%01010101				; of a
	xor		(hl)					; to
	ld		(hl), a					; p-flag
	ret								; end of subroutine

; THE 'CLS' COMMAND ROUTINE
org 0x0d67
cls:
	set		0, (iy + _flags)		; suppress leading space
	call	cl_all					; clear whole display

; THE 'SPECTRANET' ENTRY POINT
org 0x0d6e
cls_lower:
	ld		hl, vdu_flag			; address system variable
	res		5, (hl)					; signal no lower screen clear after key
	set		0, (hl)					; signal lower part
	ld		b, (iy + _df_sz)		; get address
	call	cl_line					; clear lower part of screen
.ifdef ROM1
	ld		hl, attrmap + 0x02c0	; first attribute byte
	ld		a, (attr_p)				; attr-p to A
.endif
	dec		b						; reduce counter
	jp		cls_3					; immediate jump

org 0x0d87
cls_1:
.ifdef ROM0
	ld		c, 80					; 80 characters per line in text mode
.endif
.ifdef ROM1
	ld		c, 32					; 32 characters per line in graphics mode
.endif

org 0x0d89
cls_2:
	dec		hl						; back along line
	ld		(hl), a					; set attribute byte
	dec		c						; reduce count
	jr		nz, cls_2				; loop until done

; FIXME - the cls-2 code is redundant in text mode

org 0x0d8e
cls_3:
	djnz	cls_1					; loop until done
	ld		(iy + _df_sz), 2		; two lines

org 0x0d94
cl_chan:
	ld		a, 253					; channel 'K'
	call	chan_open				; open it
	ld		hl, (curchl)			; current channel address
	ld		de, print_out			; output address
	and		a						; clear carry flag

org 0x0da0
cl_chan_a:
	ld		(hl), e					; set
	inc		hl						; address
	ld		(hl), d					; and advance
	inc		hl						; pointer
	ld		de, key_input			; input address
	ccf								; complement carry flag
	jr		c, cl_chan_a			; loop until both addresses set
.ifdef ROM0
	ld		bc, 0x1751				; row 23, column 81 in text mode
.endif
.ifdef ROM1
	ld		bc, 0x1721				; row 23, column 33 in graphics mode
.endif
	jr		cl_set					; immediate jump

; THE 'CLEARING THE WHOLE DISPLAY AREA' SUBROUTINE
org 0x0daf
cl_all:
	ld		hl, 0					; 
	ld		(coords), hl			; 
	res		0, (iy + _flags2)		; 
	call	cl_chan					; 
	call	stream_fe				; 
	ld		b, 24					; 
	call	cl_line					; 
	ld		hl, (curchl)			; 
	ld		de, print_out			; 
	ld		(hl), e					; 
	inc		hl						; 
	ld		(hl), d					; 
	ld		(iy + _scr_ct), 1		; 
.ifdef ROM0
	ld		bc, 0x1851				; row 24, column 81 in text mode 
.endif
	jr		cl_set					; 

.ifdef ROM1
org 0x0dd3
; THE 'CLS-PAL' SUBROUTINE
cls_pal:
	call	cls						; clear the screen
.endif

org 0x0dd6
	jp		set_init_pal			; immediate jump

; THE 'CL-SET' SUBROUTINE
org 0x0dd9
cl_set:
	ld		a, b					; 
	bit		0, (iy + _vdu_flag)		; 
	jr		z, cl_set_1				; 
	add		a, (iy + _df_sz)		; 
	sub		24						; 

org 0x0de5
cl_set_1:
	push	bc						; 
	ld		b, a					; 
	call	cl_addr					; 
	pop		bc						; 

.ifdef ROM1
	ld		a, 33					; 
	sub		c						; 
	ld		e, a					; 
	ld		d, 0					; 
	add		hl, de					; 
.endif
	jp		po_store				; 


; THE 'SCROLLING' SUBROUTINE
cl_sc_all:
	ld		b, 23					; 

cl_scroll:
.ifdef ROM0
	ld		(attr_t), sp			; save old stack pointer
	ld		sp, mem_5_4				; point to end of calc memory
	push	bc
	ld		bc, paging				; page out VRAM
	ld		a, 15					; 
	out		(c), a					; 
	pop		bc						; 
.endif

	call	cl_addr					; 
	ld		c, 8					; 

cl_scr_1:
	push	bc						; 
	push	hl						; 
	ld		a, b					; 
	and		%00000111				; 
	ld		a, b					; 
	jr		nz, cl_scr_3			; 

cl_scr_2:
	ex		de, hl					; 
	ld		hl, 0xf8e0				; 
	add		hl, de					; 
	ex		de, hl					; 
	ld		bc, 0x0020				; 
	dec		a						; 
.ifdef ROM0
	call	ldir2
.endif
.ifdef ROM1
	ldir							; 
.endif

cl_scr_3:
	ex		de, hl					; 
	ld		hl, 0xffe0				; 
	add		hl, de					; 
	ex		de, hl					; 
	ld		b, a					; 
	and		%00000111				; 
	rrca							; 
	rrca							; 
	rrca							; 
	ld		c, a					; 
	ld		a, b					; 
	ld		b, 0					; 
.ifdef ROM0
	call	ldir2					; 
.endif
.ifdef ROM1
	ldir							; 
.endif
	ld		b, 7					; 
	add		hl, bc					; 
	and		%11111000				; 
	jr		nz, cl_scr_2			; 
	pop		hl						; 
	inc		h						; 
	pop		bc						; 
	dec		c						; 
	jr		nz, cl_scr_1			; 
.ifdef ROM1
	call	cl_attr					; 
	ld		hl, 0xffe0				; 
	add		hl, de					; 
	ex		de, hl					; 
	ldir							; 
.endif
	ld		b, 1					; 
.ifdef ROM0
	push	bc
	ld		bc, paging				; page out VRAM
	ld		a, %00001000			; ROM 0, VRAM 1, RAM 0
	out		(c), a					; set it
	pop		bc						; 
	ld		sp, (attr_t)			; 
.endif

; THE 'CLEAR LINES' SUBROUTINE
cl_line:
	push	bc						; 
.ifdef ROM0
	ld		(attr_t), sp			; save old stack pointer
	ld		sp, mem_5_4				; point to end of calc memory
	push	bc
	ld		bc, paging				; page out VRAM
	ld		a, %00001111			; ROM 0, VRAM 1, RAM 7
	out		(c), a					; 
	pop		bc						; 
.endif
	call	cl_addr					; 
	ld		c, 8					; 

cl_line_1:
	push	bc						; 
	push	hl						; 
	ld		a, b					; 

cl_line_2:
	and		%00000111				; 
	rrca							; 
	rrca							; 
	rrca							; 
	ld		c, a					; 
	ld		a, b					; 
	ld		b, 0					; 
	dec		c						; 
.ifdef ROM0
	push	hl						; 
	push	bc						; 
	set		5, h					; 
	call	cls2nd					; 
	pop		bc						; 
	pop		hl						; 
	call	cls2nd					; 
.endif
.ifdef ROM1
	ld		d, h					; 
	ld		e, l					; 
	ld		(hl), b					; 
	inc		de						; 
	ldir							; 
.endif
	ld		de, 0x0701				; 
	add		hl, de					; 
	dec		a						; 
	and		%11111000				; 
	ld		b, a					; 
	jr		nz, cl_line_2			; 
	pop		hl						; 
	inc		h						; 
	pop		bc						; 
	dec		c						; 
.ifdef ROM0
	jp		cl_scr_x				; 

	defs	1, 255					; unused locations (ROM 0)
.endif
.ifdef ROM1
	jp		nz, cl_line_1			; 
	call	cl_attr					; 
	ld		h, d					; 
	ld		l, e					; 
	inc		de						; 
	ld		a, (attr_p)				; 
	bit		0, (iy + _vdu_flag)		; 
	jr		z, cl_line_3			; 
	ld		a, (bordcr)				; 

cl_line_3:
	ld		(hl), a					; 
	dec		bc						; 
	ldir							; 
	pop		bc						; 
	ld		c, 33					; 
	ret								; 

; THE 'CL-ATTR' SUBROUTINE
cl_attr:
	ld		a, h					; 
	rrca							; 
	rrca							; 
	rrca							; 
	dec		a						; 
	or		%01010000				; 
	ld		h, a					; 
	ex		de, hl					; 
	ld		h, c					; 
	ld		l, b					; 
	add		hl, hl					; 
	add		hl, hl					; 
	add		hl, hl					; 
	add		hl, hl					; 
	add		hl, hl					; 
	ld		b, h					; 
	ld		c, l					; 
	ret								; 
.endif

; THE 'CL-ADDR' SUBROUTINE
cl_addr:
	ld		a, 24					; 
	sub		b						; 
	ld		d, a					; 
	rrca							; 
	rrca							; 
	rrca							; 
	and		%11100000				; 
	ld		l, a					; 
	ld		a, d					; 
	and		%00011000				; 
.ifdef ROM0
	or		0xc0					; 
.endif
.ifdef ROM1
	or		0x40					; 
.endif
	ld		h, a					; 
.ifdef ROM0
	inc		hl						; skip first 16 pixels
.endif
	ret								; 

; THE 'PALETTE' COMMAND ROUTINE
org 0x0ea3
palette:
	call	two_param				; 
	ld		e, a					; 
	ld		d, c					; 
	ld		a, b					; 
	and		a						; 
	jp		nz, report_k			; 
	ld		a, c					; 
	cp		65						; 
	jp		nc, report_k			; 

set_pal:
	ld		bc, ulaplus_reg			; 
	out		(c), a					; 
	ld		b, 0xff					; 
	out		(c), e					; 
	ret								; 

org 0x0ebd
	defs	2, 255					; unused locations (common)

; THE 'DETOKENIZER' SUBROUTINE
org 0x0ebf
detokenizer:
	bit		2, (iy + _flags)		; was detokenized character a control code?
	jr		nz, detokenizer_3		; jump if not
	cp		21						; range 0 to 21?
	jr		nc, detokenizer_1		; jump if not
	cp		15						; range 0 to 14?
	jr		c, detokenizer_1		; jump if so
	set		2, (iy + _flags)		; signal control code found
	jr		detokenizer_4			; immediate jump

org 0x0ed3
detokenizer_1:
	cp		6						; extended tokens?
	jr		c, detokenizer_2		; jump if range is 0 to 5
	cp		tk_rnd					; normal tokens?
	jr		c, detokenizer_4		; jump if not

org 0x0edb
detokenizer_2:
	exx								; 
	push	de						; 
	exx								; 
	call	detokenizer_5			; 
	exx								; 
	pop		de						; 
	exx								; 
	ret								; 

org 0x0ee5
detokenizer_3:
	res		2, (iy + _flags)		; 

org 0x0ee9
detokenizer_4:
	jp		add_char				; 

org 0x0eec
detokenizer_5:
	push	de						; 
	pop		ix						; 
	sub		0xa5					; 
	ld		de, token_table - 1		; 
	push	af						; 
	call	po_search				; 
	jr		c, detokenizer_6		; 
	ld		a, ' '					; 
	bit		0, (iy + _flags)		; 
	call	z, detokenizer_8		; 

org 0x0f03
detokenizer_6:
	ld		a, (de)					; 
	and		%01111111				; 
	call	detokenizer_8			; 
	ld		a, (de)					; 
	inc		de						; 
	add		a, a					; 
	jr		nc, detokenizer_6		; 
	pop		de						; 
	cp		'$'						; 
	jr		z, detokenizer_7		; 
	cp		0x82					; 
	ret		c						; 

org 0x0f16
detokenizer_7:
	ld		a, d					; 
	cp		'&'						; 
	ret		z						; 
	cp		0x60					; 
	ret		z						; 
	cp		0x03					; 
	ret		c						; 
	ld		a, ' '					; 

org 0x0f22
detokenizer_8:
	push	de						; 
	push	ix						; 
	pop		de						; 
	rst		print_a					; 
	push	de						; 
	pop		ix						; 
	pop		de						; 
	ret								; 

; THE 'EDITOR' ROUTINES
org 0x0f2c
editor:
	ld		hl, (err_sp)			; 
	push	hl						; 

org 0x0f30
ed_again:
	ld		hl, ed_error			; 
	push	hl						; 
	ld		(err_sp), sp			; 

org 0x0f38
ed_loop:
	call	wait_key				; 
	push	af						; 
	ld		hl, 200					; 
	ld		a, (pip)				; 
	ld		e, a					; 
	and		a						; 
	call	nz, beeper				; 
	pop		af						; 
	ld		hl, ed_loop				; 
	push	hl						; 
	cp		24						; 
	jr		nc, add_char			; 
	cp		7						; 
	jr		c, add_char				; 
	cp		16						; 
	jr		c, ed_keys				; 
	ld		bc, 2					; 
	ld		d, a					; 
	cp		22						; 
	jr		c, ed_contr				; 
	inc		bc						; 
	call	wait_key				; 
	bit		7, (iy + _flagx)		; 
	jp		z, ed_ignore			; 
	ld		e, a					; 

org 0x0f6c
ed_contr:
	call	wait_key				; 
	push	de						; 
	ld		hl, (k_cur)				; 
	res		0, (iy + _mode)			; 
	call	make_room				; 
	pop		bc						; 
	inc		hl						; 
	ld		(hl), b					; 
	inc		hl						; 
	ld		(hl), c					; 
	jr		add_ch_1				; 

; THE 'ADDCHAR' SUBROUTINE
add_char:
	ld		hl, (k_cur)				; 
	call	one_space				; 

add_ch_1:
	ld		(de), a					; 
	inc		de						; 
	ld		(k_cur), de				; 
	ret								; 

ed_keys:
	ld		e, a					; 
	ld		d, 0					; 
	ld		hl, ed_keys_t - 8		; offset to ed_keys_t
	add		hl, de					; 
	ld		e, (hl)					; 
	add		hl, de					; 
	push	hl						; 
	ld		hl, (k_cur)				; 
	ret

; THE 'EDITING KEYS' TABLE
ed_keys_t:
	defb	ed_left - $				; 
	defb	ed_right - $			; 
	defb	ed_down - $				; 
	defb	ed_up - $				; 
	defb	ed_delete - $			; 
	defb	ed_enter - $			; 
	defb	ed_symbol - $			; 

; THE 'CURSOR LEFT EDITING' SUBROUTINE
ed_left:
	call	ed_edge					; move cursor

ed_cur:
	ld		(k_cur), hl				; set system variable
	ret								; end of subroutine

; THE 'CURSOR RIGHT EDITING' SUBROUTINE
ed_right:
	ld		a, (hl)					; get current character
	cp		ctrl_enter				; test for enter
	ret		z						; return if so
	call	ed_right_1				; advance cursor position
	cp		ctrl_over				; test for AT or TAB
	ret		nc						; return if so
	cp		ctrl_pen				; test for embedded control code
	ret		c						; return if not

ed_right_1:
	inc		hl						; move cursor past it if so
	jr		ed_cur					; set k-cur and exit

; THE 'CURSOR DOWN EDITING' SUBROUTINE
ed_down:
	call	ed_all					; 
	ld		hl, e_ppc				; 
	ex		de, hl					; 

ed_down_1:
	call	ed_right				; 
	djnz	ed_down_1				; 
	ret								; 

; THE 'CURSOR UP EDITING' SUBROUTINE
ed_up:
	call	ed_all					; 
	ld		hl, (e_ppc)				; 
	ex		de, hl					; 

ed_up_1:
	push	bc						; 
	call	ed_left					; 
	pop		bc						; 
	djnz	ed_up_1					; 
	ret								; 

ed_all:
	ld		hl, (e_line)			; 
	ld		de, (k_cur)				; 
	and		a						; 
	sbc		hl, de					; 
.ifdef ROM0
	ld		b, 80					; 
.endif
.ifdef ROM1
	ld		b, 32					; 
.endif
	ret								; 

; THE 'DELETE EDITING' SUBROUTINE
ed_delete:
	call	ed_edge					; 
	ex		de, hl					; 
	jp		reclaim_1				; 

; THE 'ED-IGNORE' SUBROUTINE
ed_ignore:
	call	wait_key				; 

; THE 'ENTER EDITING' SUBROUTINE
ed_enter:
	pop		hl						; 
	pop		hl						; 

ed_end:
	pop		hl						; 
	ld		(err_sp), hl			; 
	bit		7, (iy + _err_nr)		; 
	ret		nz						; 
	ld		sp, hl					; 
	ret								; 

; THE 'ED-SYMBOL' SUBROUTINE
ed_symbol:
	bit		7, (iy + _flagx)		; 
	jr		z, ed_enter				; 
	jp		add_char				; 

; THE 'ED-EDGE' SUBROUTINE
ed_edge:
	scf								; 
	call	set_de					; 
	sbc		hl, de					; 
	add		hl, de					; 
	inc		hl						; 
	pop		bc						; 
	ret		c						; 
	push	bc						; 
	ld		b, h					; 
	ld		c, l					; 

ed_edge_1:
	ld		h, d					; 
	ld		l, e					; 
	inc		hl						; 
	ld		a, (de)					; 
	and		%11110000				; 
	cp		ctrl_pen				; 
	jr		nz, ed_edge_2			; 
	inc		hl						; 

ed_edge_2:
	and		a						; 
	sbc		hl, bc					; 
	add		hl, bc					; 
	ex		de, hl					; 
	jr		c, ed_edge_1			; 
	ret

; THE 'ED-ERROR' SUBROUTINE
ed_error:
	bit		4, (iy + _flags2)		; 
	jr		z, ed_end				; 
	call	play_rasp				; 
	jp		ed_again				; 

; THE 'KEYBOARD INPUT' SUBROUTINE
key_input:
	bit		3, (iy + _vdu_flag)		; 
	call	nz, ed_copy				; 
	and		a						; 
	bit		5, (iy + _flags)		; 
	ret		z						; 

key_input_1:
	ld		a, (last_k)				; 
	res		5, (iy + _flags)		; 
	push	af						; 
	bit		5, (iy + _vdu_flag)		; 
	call	nz, cls_lower			; 
	pop		af						; 
	cp		' '						; 
	jr		nc, key_done2			; 
	cp		ctrl_pen				; 
	jr		nc, key_contr			; 
	cp		6						; 
	jr		nc, key_m_cl			; 
	ld		b, a					; 
	and		%00000001				; 
	ld		c, a					; 
	ld		a, b					; 
	rra								; 
	add		a, 18					; 
	jr		key_data	

key_m_cl:
	ld		hl, flags2				; 
	jp		z, key_mode				; 
	cp		7						; 
	jr		nz, key_mode_1			; 
	dec		a						; 
	scf								; 
	ret								; 

key_mode:
	ld		a, %00001000			; 
	xor		(hl)					; 
	ld		(hl), a					; 
	jr		key_flag				; 

key_mode_1:
	cp		ctrl_symbol				; 
	ret		c						; 
	sub		13						; 
	ld		hl, mode				; 
	cp		(hl)					; 
	ld		(hl), a					; 
	jr		nz, key_flag			; 
	ld		(hl), 0					; 

key_flag:
	set		3, (iy + _vdu_flag)		; 
	cp		a						; 
	ret								; 

key_contr:
	ld		b, a					; 
	and		%00000111				; 
	ld		c, a					; 
	ld		a, ctrl_pen				; 
	bit		3, b					; 
	jr		nz, key_data			; 
	inc		a						; 

key_data:
	ld		(iy - _k_data), c		; 
	ld		de, key_next			; 
	jr		key_chan				; 

key_next:
	ld		a, (k_data)				; 
	ld		de, key_input			; 

key_chan:
	ld		hl, (chans)				; 
	inc		hl						; 
	inc		hl						; 
	ld		(hl), e					; 
	inc		hl						; 
	ld		(hl), d					; 

key_done2:
	scf								; 
	ret								; 

; THE 'LOWER SCREEN COPYING' SUBROUTINE
ed_copy:
	call	temps					; 
	res		3, (iy + _vdu_flag)		; 
	res		5, (iy + _vdu_flag)		; 
	ld		hl, (sposnl)			; 
	push	hl						; 
	ld		hl, (err_sp)			; 
	push	hl						; 
	ld		hl, ed_full				; 
	push	hl						; 
	ld		(err_sp), sp			; 
	ld		hl, (echo_e)			; 
	push	hl						; 
	scf								; 
	call	set_de					; 
	ex		de, hl					; 
	call	out_line2				; 
	ex		de, hl					; 
	call	out_curs				; 
	ld		hl, (sposnl)			; 
	ex		(sp), hl				; 
	ex		de, hl					; 
	call	temps					; 

ed_blank:
	ld		a, (sposnl_h)			; 
	sub		d						; 
	jr		c, ed_c_done			; 
	jr		nz, ed_spaces			; 
	ld		a, e					; 
	sub		(iy + _sposnl)			; 
	jr		nc, ed_c_done			; 

ed_spaces:
	ld		a, ' '					; 
	push	de						; 
	call	print_out				; 
	pop		de						; 
	jr		ed_blank				; 

ed_full:
	call	play_rasp				; 
	ld		de, (sposnl)			; 
	jr		ed_c_end				; 

ed_c_done:
	pop		de						; 
	pop		hl						; 

ed_c_end:
	pop		hl						; 
	ld		(err_sp), hl			; 
	pop		bc						; 
	push	de						; 
	call	cl_set					; 
	pop		hl						; 
	ld		(echo_e), hl			; 
	ld		(iy + _x_ptr_h), 0		; 
	ret								; 

; THE 'SET-HL' SUBROUTINE
set_hl:
	ld		hl, (worksp)			; 
	dec		hl						; 
	and		a						; 

; THE 'SET-DE' SUBROUTINE
set_de:
	ld		de, (e_line)			; 
	bit		5, (iy + _flagx)		; 
	ret		z						; 
	ld		de, (worksp)			; 
	ret		c						; 
	ld		hl, (stkbot)			; 
	ret								; 

; THE 'EDIT' COMMAND ROUTINE
edit:
	call	find_line				; 
	ld		a, c					; 
	or 		b						; 
	jr		nz, edit_1				; 
	pop		bc						; 
	jr		edit_2					; 

edit_1:
	ld		(e_ppc), bc				; 

edit_2:
	call	set_min					; 
	call	cls_lower				; 
	res		5, (iy + _flagx)		; 
	ld		hl, (e_ppc)				; 
	call	line_addr				; 
	call	line_no					; 
	ld		a, e					; 
	or		d						; 
	jp		z, clear_sp				; 
	push	hl						; 
	inc		hl						; 
	ld		c, (hl)					; 
	inc		hl						; 
	ld		b, (hl)					; 
	ld		hl, 10					; 
	add		hl, bc					; 
	ld		c, l					; 
	ld		b, h					; 
	call	test_room				; 
	call	clear_sp				; 
	ld		hl, (curchl)			; 
	ex		(sp), hl				; 
	push	hl						; 
	ld		a, 255					; 
	call	chan_open				; 
	pop		hl						; 
	dec		hl						; 
	call	out_line				; 
	ld		hl, (e_line)			; 
	call	number_1				; 
	ld		(k_cur), hl				; 
	pop		hl						; 
	call	chan_flag				; 
	ld		sp, (err_sp)			; 
	pop		af						; 
	jp		main_2					; 

; THE 'CLEAR-SP' SUBROUTINE
clear_sp:
	push	hl						; 
	call	set_hl					; 
	dec		hl						; 
	call	reclaim_1				; 
	ld		(k_cur), hl				; 
	ld		(iy + _mode), 0			; 
	pop		hl						; 
	ret								; 

; THE 'REMOVE-FP' SUBROUTINE
remove_fp:
	ld		a, (hl)					; 
	cp		ctrl_number				; 
	ld		bc, 6					; 
	call	z, reclaim_2			; 
	ld		a, (hl)					; 
	inc		hl						; 
	cp		ctrl_enter				; 
	jr		nz, remove_fp			; 
	ret								; 
