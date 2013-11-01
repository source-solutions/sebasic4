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
	pop		de						; D = 0 to 96 for tokens, 0 for messages
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

; FIXME: the cls-2 code is redundant in text mode

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
	ld		hl, 0					; clear HL
	ld		(coords), hl			; reset coords
	res		0, (iy + _flags2)		; signal screen is clear
	call	cl_chan					; house keeping tasks
	call	stream_fe				; open channel 'S'
	ld		b, 24					; 24 lines
	call	cl_line					; clear them
	ld		hl, (curchl)			; current channel
	ld		de, print_out			; output address
	ld		(hl), e					; set
	inc		hl						; output
	ld		(hl), d					; address
	ld		(iy + _scr_ct), 1		; reset scroll count
.ifdef ROM0
	ld		bc, 0x1851				; row 24, column 81 in text mode 
.endif
	jr		cl_set					; immediate jump

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
	ld		a, b					; row to A
	bit		0, (iy + _vdu_flag)		; main display?
	jr		z, cl_set_1				; jump if so
	add		a, (iy + _df_sz)		; top row of lower display
	sub		24						; convert to real line

org 0x0de5
cl_set_1:
	push	bc						; stack row and column
	ld		b, a					; row to B 
	call	cl_addr					; address for start of row to HL
	pop		bc						; unstack row and column

.ifdef ROM1
	ld		a, 33					; reverse
	sub		c						; column
	ld		e, a					; transfer
	ld		d, 0					; to DE
	add		hl, de					; form address
.endif
	jp		po_store				; immediate jump


; THE 'SCROLLING' SUBROUTINE
cl_sc_all:
	ld		b, 23					; entry point after scroll message

cl_scroll:
.ifdef ROM0
	ld		(attr_t), sp			; save old stack pointer
	ld		sp, mem_5_4				; point to end of calc memory
	push	bc						; stack counter
	ld		bc, paging				; page out VRAM
	ld		a, %00001111			; ROM 0, VRAM 1, RAM 7
	out		(c), a					; set it
	pop		bc						; unstack counter
.endif

	call	cl_addr					; get start address of row
	ld		c, 8					; eight pixels per row

cl_scr_1:
	push	bc						; stack both
	push	hl						; counters
	ld		a, b					; B to A
	and		%00000111				; dealing with third of display?
	ld		a, b					; restore A
	jr		nz, cl_scr_3			; jump if not

cl_scr_2:
	ex		de, hl					; swap pointers
	ld		hl, 0xf8e0				; set DE to
	add		hl, de					; destination
	ex		de, hl					; swap pointers
	ld		bc, 32					; 32 bytes per row
	dec		a						; reduce count
.ifdef ROM0
	call	ldir2					; move 64 bytes in text mode
.endif
.ifdef ROM1
	ldir							; move 32 bytes in graphics mode
.endif

cl_scr_3:
	ex		de, hl					; swap pointers
	ld		hl, 0xffe0				; set DE to
	add		hl, de					; destination
	ex		de, hl					; swap pointers
	ld		b, a					; row to B
	and		%00000111				; number
	rrca							; of characters
	rrca							; in remaining
	rrca							; third
	ld		c, a					; total to C
	ld		a, b					; row to A
	ld		b, 0					; BC holds total
.ifdef ROM0
	call	ldir2					; scroll pixel line in text mode
.endif
.ifdef ROM1
	ldir							; scroll pixel line in graphics mode
.endif
	ld		b, 7					; prepare to cross screen third boundary
	add		hl, bc					; increase HL by 1792
	and		%11111000				; more thirds to consider?
	jr		nz, cl_scr_2			; jump if so
	pop		hl						; unstack original address
	inc		h						; address next pixel row
	pop		bc						; unstack counters
	dec		c						; reduce pixel row counter
	jr		nz, cl_scr_1			; loop until done
.ifdef ROM1
	call	cl_attr					; address attribute area
	ld		hl, 0xffe0				; displacement for
	add		hl, de					; attribute bytes to HL
	ex		de, hl					; swap pointers
	ldir							; copy bytes
.endif
	ld		b, 1					; one line
.ifdef ROM0
	push	bc						; stack counters
	ld		bc, paging				; page out VRAM
	ld		a, %00001000			; ROM 0, VRAM 1, RAM 0
	out		(c), a					; set it
	pop		bc						; unstack counters
	ld		sp, (attr_t)			; restore stack pointer
.endif

; THE 'CLEAR LINES' SUBROUTINE
cl_line:
	push	bc						; stack row number
.ifdef ROM0
	ld		(attr_t), sp			; save old stack pointer
	ld		sp, mem_5_4				; point to end of calc memory
	push	bc						; stack row number
	ld		bc, paging				; page out VRAM
	ld		a, %00001111			; ROM 0, VRAM 1, RAM 7
	out		(c), a					; set it
	pop		bc						; unstack row number
.endif
	call	cl_addr					; start address for row to HL
	ld		c, 8					; eight pixel rows

cl_line_1:
	push	bc						; stack line row and pixel row counter
	push	hl						; stack address
	ld		a, b					; row number to A

cl_line_2:
	and		%00000111				; number of characters
	rrca							; there are
	rrca							; B mod 8
	rrca							; rows
	ld		c, a					; result to C
	ld		a, b					; row number to A
	ld		b, 0					; clear B
	dec		c						; BC to number of characters less one
.ifdef ROM0
	push	hl						; stack address
	push	bc						; stack line row and pixel row counter
	set		5, h					; alter address for second bitmap area
	call	cls2nd					; clear second bitmap area
	pop		bc						; unstack address
	pop		hl						; unstack line row and pixel row
	call	cls2nd					; clear first bitmap area
.endif
.ifdef ROM1
	ld		d, h					; first character
	ld		e, l					; to DE
	ld		(hl), b					; clear pixel byte of first character
	inc		de						; advance DE to next location
	ldir							; clear bytes
.endif
	ld		de, 0x0701				; increment HL by 1793 bytes
	add		hl, de					; for each screen third
	dec		a						; reduce row number
	and		%11111000				; discard extra rows
	ld		b, a					; screen third count to B
	jr		nz, cl_line_2			; loop until done
	pop		hl						; unstack address for pixel row
	inc		h						; and increase pixel row
	pop		bc						; unstack counters
	dec		c						; decrease pixel row count
.ifdef ROM0
	jp		cl_scr_x				; text mode screen clear

	defs	1, 255					; unused locations (ROM 0)
.endif
.ifdef ROM1
	jp		nz, cl_line_1			; loop until done
	call	cl_attr					; get first attribute byte and count
	ld		h, d					; attribute byte
	ld		l, e					; to HL
	inc		de						; next byte to DE
	ld		a, (attr_p)				; permanent attribute to A
	bit		0, (iy + _vdu_flag)		; main screen?
	jr		z, cl_line_3			; jump if so
	ld		a, (bordcr)				; border color to A

cl_line_3:
	ld		(hl), a					; set attribute byte
	dec		bc						; reduce count
	ldir							; write bytes
	pop		bc						; unstack line number
	ld		c, 33					; set leftmost column
	ret								; end of subroutine

; THE 'CL-ATTR' SUBROUTINE
cl_attr:
	ld		a, h					; most significant byte to A
	rrca							; multiply
	rrca							; by
	rrca							; 32
	dec		a						; back one line
	or		%01010000				; address attributes
	ld		h, a					; restore most significant byte
	ex		de, hl					; swap pointers
	ld		h, c					; clear H
	ld		l, b					; line number to BC
	add		hl, hl					; * 2
	add		hl, hl					; * 4
	add		hl, hl					; * 8
	add		hl, hl					; * 16
	add		hl, hl					; * 32
	ld		b, h					; result
	ld		c, l					; to BC
	ret								; end of subroutine
.endif

; THE 'CL-ADDR' SUBROUTINE
cl_addr:
	ld		a, 24					; reverse line
	sub		b						; number
	ld		d, a					; result to D
	rrca							; A
	rrca							; mod
	rrca							; 8
	and		%11100000				; first line
	ld		l, a					; least significant byte to L
	ld		a, d					; get real line number
	and		%00011000				; 64 + 8 * INT (A/8)
.ifdef ROM0
	or		0xc0					; most significant byte (text mode)
.endif
.ifdef ROM1
	or		0x40					; most significant byte (graphics mode)
.endif
	ld		h, a					; most significant byte to H
.ifdef ROM0
	inc		hl						; skip first 16 pixels
.endif
	ret								; end of subroutine

; THE 'PALETTE' COMMAND ROUTINE
org 0x0ea3
palette:
	call	two_param				; get parameters
	ld		e, a					; data to E
	ld		a, b					; was BC less
	and		a						; than 256?
	jp		nz, report_k			; error if not
	ld		a, c					; register to A
	cp		65						; valid register (0 to 64)?
	jp		nc, report_k			; error if not

set_pal:
	ld		bc, ulaplus_reg			; address I/O register
	out		(c), a					; set it
	ld		b, 0xff					; address I/O data
	out		(c), e					; write it
	ret								; end of routine.

org 0x0ebc
	defs	3, 255					; unused locations (common)

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
	exx								; alternate register set
	push	de						; stack DE'
	exx								; main register set
	call	detokenizer_5			; do detokenization
	exx								; alternate register set
	pop		de						; unstack DE'
	exx								; main register set
	ret								; return

org 0x0ee5
detokenizer_3:
	res		2, (iy + _flags)		; signal no control code

org 0x0ee9
detokenizer_4:
	jp		add_char				; immediate jump

org 0x0eec
detokenizer_5:
	push	de						; store edit buffer destination
	pop		ix						; in IX
	sub		tk_rnd					; reduce range
	ld		de, token_table - 1		; base address of token table
	push	af						; stack token (0 to 96)
	call	po_search				; locate entry
	jr		c, detokenizer_6		; insert token in edit line
	ld		a, ' '					; insert
	bit		0, (iy + _flags)		; leading space
	call	z, detokenizer_8		; if required

org 0x0f03
detokenizer_6:
	ld		a, (de)					; get code
	and		%01111111				; cancel inverted bit
	call	detokenizer_8			; insert it
	ld		a, (de)					; get code
	inc		de						; advance pointer
	add		a, a					; inverted bit to carry flag
	jr		nc, detokenizer_6		; loop until done
	pop		de						; unstack token in D (0 to 96)
	cp		'$'						; FIXME: was 72 but that added extra spaces
	jr		z, detokenizer_7		; jump if so
	cp		130						; last character less than 'A'?
	ret		c						; return if so

org 0x0f16
detokenizer_7:
	ld		a, d					; offset to A
	cp		'&'						; FIXME don't remember
	ret		z						; FIXME what these
	cp		0x60					; FIXME instructions
	ret		z						; FIXME are for
	cp		3						; RND, INKEY$ or PI?
	ret		c						; return if so
	ld		a, ' '					; otherwise insert trailing space

org 0x0f22
detokenizer_8:
	push	de						; stack DE
	push	ix						; IX
	pop		de						; to DE
	rst		print_a					; insert one character
	push	de						; DE
	pop		ix						; to IX
	pop		de						; unstack DE
	ret								; end of subroutine

; THE 'EDITOR' ROUTINES
org 0x0f2c
editor:
	ld		hl, (err_sp)			; get current error pointer
	push	hl						; and stack it

org 0x0f30
ed_again:
	ld		hl, ed_error			; stack return
	push	hl						; address
	ld		(err_sp), sp			; set err-sp to stack pointer

org 0x0f38
ed_loop:
	call	wait_key				; get a key
	push	af						; stack it
	ld		hl, 200					; pitch
	ld		a, (pip)				; click
	ld		e, a					; to E
	and		a						; zero?
	call	nz, beeper				; sound click if not
	pop		af						; unstack code
	ld		hl, ed_loop				; stack
	push	hl						; return address
	cp		24						; printable codes?
	jr		nc, add_char			; jump if so
	cp		7						; tab?
	jr		c, add_char				; jump if so
	cp		16						; control key?
	jr		c, ed_keys				; jump if so
	ld		bc, 2					; color codes need two locations
	ld		d, a					; code to D
	cp		22						; PEN or PAPER?
	jr		c, ed_contr				; jump if so
	inc		bc						; three locations for other codes
	call	wait_key				; get second code
	bit		7, (iy + _flagx)		; INPUT LINE?
	jp		z, ed_ignore			; jump if not
	ld		e, a					; store second code in E

org 0x0f6c
ed_contr:
	call	wait_key				; get code
	push	de						; stack previous codes
	ld		hl, (k_cur)				; get k-cur
	res		0, (iy + _mode)			; signal 'K' mode
	call	make_room				; make space
	pop		bc						; unstack previous code
	inc		hl						; point to first location
	ld		(hl), b					; write code
	inc		hl						; next
	ld		(hl), c					; write code
	jr		add_ch_1				; immediate jump

; THE 'ADDCHAR' SUBROUTINE
org 0x0f81
add_char:
	ld		hl, (k_cur)				; cursor position to HL
	call	one_space				; make a space

org 0x0f87
add_ch_1:
	ld		(de), a					; store code in the space
	inc		de						; next
	ld		(k_cur), de				; store new cursor position
	ret								; end of subroutine

org 0x0f8e
ed_keys:
	ld		e, a					; code
	ld		d, 0					; to DE
	ld		hl, ed_keys_t - 8		; offset to ed_keys_t
	add		hl, de					; get entry
	ld		e, (hl)					; store in E
	add		hl, de					; address of handling routine
	push	hl						; stack it
	ld		hl, (k_cur)				; k-cur to HL
	ret								; indirect jump

; THE 'EDITING KEYS' TABLE
org 0x0f9c
ed_keys_t:
	defb	ed_left - $	
	defb	ed_right - $
	defb	ed_down - $
	defb	ed_up - $
	defb	ed_delete - $
	defb	ed_enter - $
	defb	ed_symbol - $

; THE 'CURSOR LEFT EDITING' SUBROUTINE
org 0x0fa3
ed_left:
	call	ed_edge					; move cursor

org 0x0fa6
ed_cur:
	ld		(k_cur), hl				; set system variable
	ret								; end of subroutine

; THE 'CURSOR RIGHT EDITING' SUBROUTINE
org 0x0faa
ed_right:
	ld		a, (hl)					; get current character
	cp		ctrl_enter				; test for enter
	ret		z						; return if so
	call	ed_right_1				; advance cursor position
	cp		ctrl_over				; test for AT or TAB
	ret		nc						; return if so
	cp		ctrl_pen				; test for embedded control code
	ret		c						; return if not

org 0x0fb7
ed_right_1:
	inc		hl						; move cursor past it if so
	jr		ed_cur					; set k-cur and exit

; THE 'CURSOR DOWN EDITING' SUBROUTINE
org 0x0fba
ed_down:
	call	ed_all					; common code
	ld		hl, e_ppc				; address system variable
	ex		de, hl					; swap pointers

org 0x0fc1
ed_down_1:
	call	ed_right				; cursor right
	djnz	ed_down_1				; loop until done
	ret								; end of subroutine

; THE 'CURSOR UP EDITING' SUBROUTINE
org 0x0fc7
ed_up:
	call	ed_all					; common code
	ld		hl, (e_ppc)				; e-ppc to HL
	ex		de, hl					; swap pointers

org 0x0fce
ed_up_1:
	push	bc						; stack count
	call	ed_left					; cursor left
	pop		bc						; unstack count
	djnz	ed_up_1					; loop until done
	ret								; end of subroutine

org 0x0fd6
ed_all:
	ld		hl, (e_line)			; e-line to HL
	ld		de, (k_cur)				; k-cur to DE
	and		a						; prepare for subtraction
	sbc		hl, de					; subtract
.ifdef ROM0
	ld		b, 80					; 80 characters in text mode
.endif
.ifdef ROM1
	ld		b, 32					; 32 characters in graphics mode
.endif
	ret								; 

; THE 'DELETE EDITING' SUBROUTINE
org 0x0fe3
ed_delete:
	call	ed_edge					; cursor left
	ex		de, hl					; swap pointers
	jp		reclaim_1				; immediate jump

; THE 'ED-IGNORE' SUBROUTINE
org 0x0fea
ed_ignore:
	call	wait_key				; wait for a key

; THE 'ENTER EDITING' SUBROUTINE
org 0x0fed
ed_enter:
	pop		hl						; discard ed-loop
	pop		hl						; and ed-error return addresses

org 0x0fef
ed_end:
	pop		hl						; unstack old err-sp
	ld		(err_sp), hl			; restore it
	bit		7, (iy + _err_nr)		; any errors?
	ret		nz						; return if not
	ld		sp, hl					; swap pointers
	ret								; indirect jump

; THE 'ED-SYMBOL' SUBROUTINE
org 0x0ffa
ed_symbol:
	bit		7, (iy + _flagx)		; INPUT LINE?
	jr		z, ed_enter				; jump if not
	jp		add_char				; immediate jump

; THE 'ED-EDGE' SUBROUTINE
org 0x1003
ed_edge:
	scf								; set carry flag
	call	set_de					; DE points to e-line or worksp
	sbc		hl, de					; set carry flag
	add		hl, de					; if cursor is at start of line
	inc		hl						; correct for subtraction
	pop		bc						; discard return address
	ret		c						; return via ed-loop if carry set
	push	bc						; restore return address
	ld		b, h					; cursor address
	ld		c, l					; to BC

org 0x1010
ed_edge_1:
	ld		h, d					; next character
	ld		l, e					; address to DE
	inc		hl						; next address
	ld		a, (de)					; code to A
	and		%11110000				; PEN to
	cp		ctrl_pen				; TAB?
	jr		nz, ed_edge_2			; jump if not
	inc		hl						; one parameter

org 0x101b
ed_edge_2:
	and		a						; prepare for subtraction
	sbc		hl, bc					; clear carry flag when
	add		hl, bc					; updated pointer reaches k-cur
	ex		de, hl					; swap pointers
	jr		c, ed_edge_1			; use updated pointer on next loop
	ret								; end of subroutine

; THE 'ED-ERROR' SUBROUTINE
org 0x1023
ed_error:
	bit		4, (iy + _flags2)		; channel 'K'?
	jr		z, ed_end				; jump if not
	call	play_rasp				; play rasp
	jp		ed_again				; immediate jump

; THE 'KEYBOARD INPUT' SUBROUTINE
org 0x102f
key_input:
	bit		3, (iy + _vdu_flag)		; screen mode changed?
	call	nz, ed_copy				; copy line if so
	and		a						; clear flags
	bit		5, (iy + _flags)		; no new key?
	ret		z						; return if so

org 0x103c
key_input_1:
	ld		a, (last_k)				; code to A
	res		5, (iy + _flags)		; signal key
	push	af						; stack code
	bit		5, (iy + _vdu_flag)		; lower display requires clearing?
	call	nz, cls_lower			; if so do it
	pop		af						; unstack code
	cp		' '						; space or above?
									; FIXME:	could enable direct entry of
									; 			tokens 0 to 5
	jr		nc, key_done2			; jump if so
	cp		ctrl_pen				; control codes?
	jr		nc, key_contr			; jump if so
	cp		6						; mode codes and caps lock?
	jr		nc, key_m_and_cl		; jump if so
	ld		b, a					; code to B
	and		%00000001				; discard top seven bits
	ld		c, a					; state to C
	ld		a, b					; code to A
	rra								; drop bit 0
	add		a, 18					; add offset
	jr		key_data				; immediate jump

org 0x1062
key_m_and_cl:
	ld		hl, flags2				; address system variable
	jp		z, key_mode				; jump with mode codes
	cp		7						; TAB key?
	jr		nz, key_mode_1			; jump if not
	dec		a						; A to code for TAB
	scf								; set carry flag
	ret								; and return

org 0x106f
key_mode:
	ld		a, %00001000			; toggle
	xor		(hl)					; bit 3
	ld		(hl), a					; of flags
	jr		key_flag				; immediate jump

org 0x1075
key_mode_1:
	cp		ctrl_symbol				; lower limit?
	ret		c						; return if so
	sub		13						; reduce range
	ld		hl, mode				; address system variable
	cp		(hl)					; changed?
	ld		(hl), a					; store new mode
	jr		nz, key_flag			; jump if changed
	ld		(hl), 0					; else 'L' mode

org 0x1083
key_flag:
	set		3, (iy + _vdu_flag)		; signal possible mode change
	cp		a						; clear carry flag
	ret								; and return

org 0x1089
key_contr:
	ld		b, a					; store code in B
	and		%00000111				; discard high five bits
	ld		c, a					; parameter to C
	ld		a, ctrl_pen				; PEN code
	bit		3, b					; shifted?
	jr		nz, key_data			; jump if so
	inc		a						; else make PAPER code

org 0x1094
key_data:
	ld		(iy - _k_data), c		; parameter to k-data
	ld		de, key_next			; address routine
	jr		key_chan				; immediate jump

org 0x109c
key_next:
	ld		a, (k_data)				; parameter to A
	ld		de, key_input			; address routine

org 0x10a2
key_chan:
	ld		hl, (chans)				; get channel address
	inc		hl						; skip input
	inc		hl						; address
	ld		(hl), e					; set
	inc		hl						; output
	ld		(hl), d					; address

org 0x10aa
key_done2:
	scf								; set carry flag
	ret								; end of subroutine

; THE 'LOWER SCREEN COPYING' SUBROUTINE
org 0x10ac
ed_copy:
	call	temps					; get permanent colors
	res		3, (iy + _vdu_flag)		; signal mode not changed
	res		5, (iy + _vdu_flag)		; signal lower screen clearing not required
	ld		hl, (sposnl)			; sponsl to HL
	push	hl						; stack it
	ld		hl, (err_sp)			; err-sp to HL
	push	hl						; stack it
	ld		hl, ed_full				; address ed-full
	push	hl						; stack it
	ld		(err_sp), sp			; make err-sp point to ed-full
	ld		hl, (echo_e)			; echo-e to HL
	push	hl						; stack it
	scf								; set carry flag
	call	set_de					; HL to start and DE to end
	ex		de, hl					; swap pointers
	call	out_line2				; print line
	ex		de, hl					; swap pointers
	call	out_curs				; print cursor
	ld		hl, (sposnl)			; sposnl to HL
	ex		(sp), hl				; swap with echo-e
	ex		de, hl					; swap pointers
	call	temps					; get permanent colors

org 0x10df
ed_blank:
	ld		a, (sposnl_h)			; current line number to A
	sub		d						; subtract old line number
	jr		c, ed_c_done			; jump if no blanking required
	jr		nz, ed_spaces			; jump if not on same line
	ld		a, e					; old column number to A
	sub		(iy + _sposnl)			; subtract new column number
	jr		nc, ed_c_done			; jump if no spaces required

org 0x10ed
ed_spaces:
	ld		a, ' '					; space
	push	de						; stack old values
	call	print_out				; print it
	pop		de						; unstack old values
	jr		ed_blank				; immediate jump

org 0x10f6
ed_full:
	call	play_rasp				; play rasp
	ld		de, (sposnl)			; sposnl to DE
	jr		ed_c_end				; immediate jump

org 0x10ff
ed_c_done:
	pop		de						; unstack new position value
	pop		hl						; unstack error address

org 0x1101
ed_c_end:
	pop		hl						; unstack old err-sp
	ld		(err_sp), hl			; store it
	pop		bc						; unstack old sposnl
	push	de						; unstack new position values
	call	cl_set					; set system variables
	pop		hl						; unstack old sposnl
	ld		(echo_e), hl			; store it in echo-e
	ld		(iy + _x_ptr_h), 0		; clear x-ptr
	ret								; end of subroutine

; THE 'SET-HL' SUBROUTINE
org 0x1113
set_hl:
	ld		hl, (worksp)			; HL to last location
	dec		hl						; of editing area
	and		a						; clear carry flag

; THE 'SET-DE' SUBROUTINE
org 0x1118
set_de:
	ld		de, (e_line)			; start of editing area to DE
	bit		5, (iy + _flagx)		; EDIT mode?
	ret		z						; return if so
	ld		de, (worksp)			; worksp to DE
	ret		c						; return if intended
	ld		hl, (stkbot)			; sktbot to HL
	ret								; end of subroutine

; THE 'EDIT' COMMAND ROUTINE
org 0x112a
edit:
	call	find_line				; get a valid line number
	ld		a, c					; is it
	or 		b						; zero?
	jr		nz, edit_1				; jump if not
	pop		bc						; unstack BC
	jr		edit_2					; immediate jump

org 0x1134
edit_1:
	ld		(e_ppc), bc				; store BC in e-ppc

org 0x1138
edit_2:
	call	set_min					; setup workspace
	call	cls_lower				; clear lower screen
	res		5, (iy + _flagx)		; signal INPUT mode
	ld		hl, (e_ppc)				; line number to HL
	call	line_addr				; get line address
	call	line_no					; get line number
	ld		a, e					; is it
	or		d						; zero?
	jp		z, clear_sp				; jump if so
	push	hl						; stack address of line
	inc		hl						; address line length
	ld		c, (hl)					; transfer
	inc		hl						; it to
	ld		b, (hl)					; BC
	ld		hl, 10					; add ten
	add		hl, bc					; to it
	ld		c, l					; transfer
	ld		b, h					; to BC
	call	test_room				; check for space
	call	clear_sp				; clear editing area
	ld		hl, (curchl)			; get current channel
	ex		(sp), hl				; swap with address of line
	push	hl						; stack it
	ld		a, 255					; channel 'R'
	call	chan_open				; open it
	pop		hl						; address of line
	dec		hl						; suppress cursor
	call	out_line				; print the line
	ld		hl, (e_line)			; start of line to HL
	call	number_1				; skip line number and address
	ld		(k_cur), hl				; store it in k-kur
	pop		hl						; unstack former channel address
	call	chan_flag				; set flags
	ld		sp, (err_sp)			; FIXME: don't remember why I did this
	pop		af						; FIXME: or this
	jp		main_2					; immediate jump

; THE 'CLEAR-SP' SUBROUTINE
org 0x1185
clear_sp:
	push	hl						; stack pointer to space
	call	set_hl					; DE to first character, HL to last
	dec		hl						; adjust amount
	call	reclaim_1				; reclaim
	ld		(k_cur), hl				; set k-cur
	ld		(iy + _mode), 0			; signal 'K' mode
	pop		hl						; unstack pointer
	ret								; end of subroutine

; THE 'REMOVE-FP' SUBROUTINE
org 0x1196
remove_fp:
	ld		a, (hl)					; get character
	cp		ctrl_number				; hidden number marker?
	ld		bc, 6					; six locations
	call	z, reclaim_2			; reclaim if so
	ld		a, (hl)					; get character
	inc		hl						; next
	cp		ctrl_enter				; carriage return?
	jr		nz, remove_fp			; jump if not
	ret								; end of subroutine
