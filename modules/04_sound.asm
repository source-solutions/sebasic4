; --- THE PSG and LOUDSPEAKER ROUTINES ----------------------------------------

; THE 'SOUND' COMMAND
org 0x0375
sound_4:
	rst		next_char				; advance pointer

org 0x0376
sound:
	call	expt_2num				; check for pair of comma separated values
	call	syntax_z				; checking syntax?
	jr		z, sound_1				; jump if so
	call	fp_to_a					; get data byte (bit 7 ignored)
	push	af						; stack it
	call	fp_to_a					; get register byte
	cp		17						; check upper range
	jp		nc, report_b			; error if out of range
	dec		a						; check
	inc		a						; lower range
	jp		m, report_b				; error if out of range
	ld		bc, ay_reg				; register port
	out		(c), a					; write value to port
	pop		af						; unstack data
	call	sound_2					; call routine to write it

org 0x0398
sound_1:
	rst		get_char				; get next character
	cp		';'						; is it a semicolon?
	jr		z, sound_4				; loop if so
	call	check_end				; no more parameters?
	ret								; end of sound command routine

org 0x03a1
sound_2:
	ld		bc, ay_128dat			; 128 data port
	out		(c), a					; write value to port
	ld		e, a					; store value in E
	ld		a, (bordcr)				; get border color
	rrca							; rotate it
	rrca							; to the required
	rrca							; port value
	and		7						; mask unwanted bits
	ld		bc, ay_tmxdat			; Timex data port
	jp		sound_3					; remainder moved to maintain entry points

; THE 'BEEPER' SUBROUTINE
org 0x03b5
beeper:
	di								; interrupts off
	ld		a, l					; store L
	srl		l						; shift right logical
	srl		l						; to produce int (l/4)
	cpl								; restore L
	and		%00000011				; get remainder
	ld		b, 0					; offset
	ld		c, a					; to BC
	ld		ix, be_ix_plus_3		; base loop
	add		ix, bc					; update loop length
	ld		a, (bordcr)				; get border color
	and		%00111000				; discard unwanted bits
	rrca							; rotate
	rrca							; into
	rrca							; place
	or		%00001000				; MIC off

org 0x03d1
be_ix_plus_3:
	nop								; 12 t-state delay
	nop								; 8 t-state delay
	nop								; 4 t-state delay
	inc		c						; values in BC
	inc		b						; derived from HL

org 0x03d6
be_h_and_l_lp:
	dec		c						; timing loop
	jr		nz, be_h_and_l_lp		; 12 or 7 t-state jump
	dec		b						; reduce B
	ld		c, 63					; timing constant
	jp		nz, be_h_and_l_lp		; 10 t-state jump
	xor		%00010000				; toggle bit 4
	out		(ula), a				; write port
	ld		c, a					; store byte written
	ld		b, h					; reset B
	bit		4, a					; half-cycle point?
	jr		nz, be_again			; jump if so
	ld		a, e					; test for
	or		d						; final pass
	jr		z, be_end				; jump if so
	dec		de						; decrease pass counter
	ld		a, c					; restore byte written
	ld		c, l					; reset C
	jp		(ix)					; back to loop offset

org 0x03f2
be_again:
	ld		c, l					; reset C
	inc		c						; add 16 t-states
	jp		(ix)					; jump back

org 0x03f6
be_end:
	ei								; restore interrupts
	ret								; end of beeper subroutine

; THE 'BEEP' COMMAND ROUTINE
org 0x03f8
beep:
	fwait							; enter calc with pitch & duration on stack
	fmove							; d, p, p
	fint							; d, p, i (i = INT p)
	fst		0						; i to mem-0
	fsub							; d, p (p = fractional part of p)
	fstk							; stack k
	defb	0xec					; exponent (112)
	defb	0x6c, 0x98, 0x1f, 0xf5	; mantissa (0.0577622606)
	fmul							; d, pk
	fstk1							; d, pk, 1
	fadd							; d, pk + 1
	fce								; exit calc
	ld		hl, membot				; mem-0-1st
	ld		a, (hl)					; get exponent
	and		a						; error if not in 
	jr		nz, report_b			; short form
	inc		hl						; next location
	ld		c, (hl)					; sign byte to C
	inc		hl						; next location
	ld		b, (hl)					; low byte to B
	ld		a, b					; low byte to A
	rla								; rotate left accumulator
	sbc		a, a					; subtract with carry
	cp		c						; -128 <= i <= +127
	jr		nz, report_b			; error if test failed
	inc		hl						; increment HL
	cp		(hl)					; test against (HL)
	jr		nz, report_b			; error if not
	ld		a, 60					; set range
	add		a, b					; test low byte
	jp		p, be_i_ok				; jump if -60 <= i <=67
	jp		po, report_b			; error if -128 to -61

org 0x0425
be_i_ok:
	ld		b, 250					; 6 octaves below middle C

org 0x0427
be_octave:
	sub		12						; reduce i to find
	inc		b						; correct octave
	jr		nc, be_octave			; loop until found
	ld		hl, semi_tone			; base of table
	push	bc						; stack octave
	add		a, 12					; pass back last subtraction
	call	loc_mem					; consider table and pass value
	call	stack_num				; at (A) to calculator stack
	fwait							; d, pk+1, C
	fmul							; d, C(pk+1)
	fce								; exit calc
	pop		af						; unstack octave
	add		a, (hl)					; multiply last value by 2^A
	ld		(hl), a					; d, f
	fwait							; store frequency
	fst		0						; in mem-0
	fdel							; delete
	fmove							; d, d
	fce								; exit calc
	call	find_int1				; value 'INT d' must be
	cp		11						; 0 to 11
	jr		nc, report_b			; jump if not
	fwait							; d
	fgt		0						; d, f
	fmul							; f*d
	fgt		0						; f*d, f
	fstk							; stack 3.5 x 10^6/8
	defb	0x80					; four bytes
	defb	0x43					; mantissa
	defb	0x55, 0x9f, 0x80		; exponent
	fxch							; f*d, 437500, f
	fdiv							; f*d, 437500/f
	fstk							; stack it
	defb	0x35					; exponent
	defb	0x6c					; mantissa
	fsub							; subtract
	fce								; exit calc
	call	find_int2				; timing loop compressed into BC
	push	bc						; stack loop
	call	find_int2				; f*d value compressed into BC
	pop		hl						; unstack loop into HL
	ld		e, c					; move f*d value
	ld		d, b					; to
	ld		a, e					; DE
	or		d						; no cycles required?
	ret		z						; return if so
	dec		de						; reduce cycle count
	jp		beeper					; exit via beeper subroutine

org 0x046c
report_b:
	rst		error					; call error handler
	defb	Integer_out_of_range	; message

; THE 'SEMI-TONE' TABLE
org 0x046e
semi_tone:
	incbin	"semitone.bin"			; 12 semi-tones for 3.5Mhz Z80 

; THE 'PLAY RASP' SUBROUTINE
org 0x04aa
play_rasp:
	exx								; alternate register set
	ld		d, 0					; D = 0
	ld		e, (iy - _rasp)			; E = rasp
	ld		hl, 2148				; duration
	call	beeper					; play rasp
	exx								; default register set
	ld		(iy + _err_nr), OK		; clear error
	ret								; end of play-rasp subroutine

; THE 'SOUND' COMMAND continued
org 0x04bc
sound_3:
	out		(c), e					; write value to the port
	out		(ula), a				; even port hits ULA so restore border
	ret								; end of sound-2 subroutine

	defs	1, 255					; unused locations (common)
