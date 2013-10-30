; --- THE TAPE HANDLING ROUTINES ----------------------------------------------

; FIXME - text mode needs a separate screen handler to page in bank 7 during
;		  loading and saving of SCREEN$
;
;		- if ULAplus is enabled in graphics mode, loading and saving of SCREEN$
;		  should include the palette data

; THE 'SA-BYTES' SUBROUTINE
org 0x04c2
sa_bytes:
	ld		hl, sa_ld_ret			; return routine to HL
	push	hl						; stack it
	bit		7, a					; header?
	ld		hl, 0x1df8				; about 4.75 seconds (@ 50Hz)
	jr		z, sa_flag				; jump if header
	ld		hl, 0x0bfe				; slightly under 2 seconds (@ 50Hz)

org 0x04d0
sa_flag:
	ex		af, af'					;'store flag (trapped by emulators)
	di								; interrupts off
	ld		a, cyan					; MIC on and CYAN border
	dec		ix						; reduce base address
	inc		de						; increase length
	ld		b, a					; store A in B

org 0x04d8
sa_leader:
	djnz	sa_leader				; timing loop
	out		(ula), a				; write port
	ld		b, 164					; timing constant
	xor		%00001111				; switch MIC on/off and border each pass
	dec		l						; reduce low counter
	jr		nz, sa_leader			; jump back for another pulse
	dec		h						; reduce high counter
	dec		b						; reduce by 13 t-states
	jp		p, sa_leader			; jump back for another pulse
	ld		b, 47					; timing constant

org 0x04ea
sa_sync_1:
	djnz	sa_sync_1				; timing loop
	out		(ula), a				; write port
	ld		b, 55					; timing constant
	ld		a, 10					; MIC off and RED border

org 0x04f2
sa_sync_2:
	djnz	sa_sync_2				; timing loop
	out		(ula), a				; write port
	ex		af, af'					;'restore flag
	ld		l, a					; flag to L
	ld		bc, 0x3b0e				; B = timing constant, C = MIC off & YELLOW
	jp		sa_start				; immediate jump

org 0x04fe
sa_loop:
	ld		a, e					; test length
	or		d						; and jump
	jr		z, sa_parity			; when zero
	ld		l, (ix + 0)				; next byte to save

org 0x0505
sa_loop_p:
	ld		a, l					; get current parity
	xor		h						; include current byte

org 0x0507
sa_start:
	ld		h, a					; restore parity
	scf								; byte marker
	ld		a, blue					; MIC on and BLUE border
	jp		sa_8_bits				; immediate jump

org 0x050e
sa_parity:
	ld		l, h					; final parity value
	jr		sa_loop_p				; jump back

org 0x0511
sa_bit_2:
	bit		7, b					; set zero flag for second pass
	ld		a, c					; fetch MIC off and YELLOW border

org 0x0514
sa_bit_1:
	djnz	sa_bit_1				; timing loop
	jr		nc, sa_out				; take shorter path if saving a zero
	ld		b, 66					; add 855 t-states for a one

org 0x051a
sa_set:
	djnz	sa_set					; timing loop

org 0x051c
sa_out:
	out		(ula), a				; MIC on and BLUE / MIC off and YELLOW
	ld		b, 62					; timing constant
	jr		nz, sa_bit_2			; jump back after first pass
	xor		a						; clear carry flag
	dec		b						; reclaim 13 t-states
	inc		a						; MIC on and BLUE

org 0x0525
sa_8_bits:
	rl		l						; move bit 7 to carry, marker left
	jp		nz, sa_bit_1			; save bit unless finished byte
	ld		b, 49					; timing constant
	inc		ix						; increase base address
	dec		de						; decrease counter
	ld		a, 127					; test for
	in		a, (ula)				; space key
	rra								; return
	ret		nc						; if pressed
	ld		a, d					; test counter
	inc		a						; jump back even at zero
	jp		nz, sa_loop				; to include parity byte
	ld		b, 59					; timing constant

org 0x053c
sa_delay:
	djnz	sa_delay				; timing loop
	ret								; end of sa-bytes subroutine

; THE 'SA/LD-RET' SUBROUTINE
org 0x053f
sa_ld_ret:
	push	af						; stack carry flag
	ld		a, (bordcr)				; get border color
	and		%00111000				; mask it
	rrca							; rotate it to
	rrca							; rightmost
	rrca							; three bits
	out		(ula), a				; set border color
	ld		a, 127					; test for break
	in		a, (ula)				; read keyboard
	rra								; rotate right accumulator
	ei								; enable interrupts
	jr		c, sa_ld_end			; jump if no break
	rst		error					; else
	defb	BREAK_CONTINUE_repeats	; error

org 0x0554
sa_ld_end:
	pop		af						; unstack carry flag
	ret								; end of subroutine

; THE 'LD-BYTES' SUBROUTINE
org 0x0556
ld_bytes:
	di								; switch off interrupts
	inc		d						; reset zero flag
	ex		af, af'					;'A holds 0 for header or 127 for data
	dec		d						; restore D
	ld		a, 15					; set border
	out		(ula), a				; to black
	ld		hl, sa_ld_ret			; stack
	push	hl						; return address
	in		a, (ula)				; read ULA
	rra								; rotate
	and		%00100000				; keep EAR bit
	or		red						; red border
	ld		c, a					; store C (22=off, 2=on)
	cp		a						; set zero flag

org 0x056b
ld_break:
	ret		nz						; exit on break

org 0x056c
ld_start:
	call	ld_edge_1				; test for edge
	jr		nc, ld_break			; return with carry reset if not found
	ld		hl, 0x0115				; approx 1/4 second pause

org 0x0574
ld_wait:
	djnz	ld_wait					; pause
	dec		hl						; 
	ld		a, l					; 
	or		h						; 
	jr		nz, ld_wait				; 
	call	ld_edge_2				; continue if two edges found
	jr		nc, ld_break			; else exit

org 0x0580
ld_leader:
	ld		b, 156					; timing constant
	call	ld_edge_2				; test for second edge
	jr		nc, ld_break			; return with carry reset if not found
	ld		a, 198					; within 3000 t-states
	cp		b						; count edge pairs
	jr		nc, ld_start			; in H until
	inc		h						; 256 pairs
	jr		nz, ld_leader			; are found

org 0x058f
ld_sync:
	ld		b, 201					; timing constant
	call	ld_edge_1				; consider every edge
	jr		nc, ld_break			; until two found
	ld		a, b					; close together
	cp		212						; start and finishing
	jr		nc, ld_sync				; edges of off sync pulse
	call	ld_edge_1				; test for finishing edge of
	ret		nc						; on sync pulse
	ld		b, 176					; timing constant
	ld		h, 0					; parity byte to zero
	ld		a, c					; C to A
	xor		%00000011				; blue/yellow border
	ld		c, a					; A to C
	jr		ld_marker				; immediate jump

org 0x05a9
ld_loop:
	ex		af, af'					;'get flags
	jr		nz, ld_flag				; jump if first byte
	jr		nc, ld_verify			; jump to verify
	ld		(ix + 0), l				; load when required
	jr		ld_next					; next byte

org 0x05b3
ld_flag:
	rl		c						; store carry flag
	xor		l						; match for first byte?
	ret		nz						; return if not
	ld		a, c					; restore carry flag
	rra								; 
	ld		c, a					; 
	jp		ld_dec					; immediate jump

org 0x05bd
ld_verify:
	ld		a, (ix + 0)				; get original byte
	xor		l						; match for new byte?
	ret		nz						; return if not

org 0x05c2
ld_next:
	inc		ix						; increment destination
	dec		de						; reduce counter

org 0x05c5
ld_dec:
	ex		af, af'					;'store flags
	ld		b, 178					; timing constant

org 0x05c8
ld_marker:
	ld		l, %00000001			; clear L except for marker bit

org 0x05ca
ld_8_bits:
	call	ld_edge_2				; get length of pulses
	ret		nc						; return if time period exceeded
	ld		a, 203					; 2400 t-states
	cp		b						; carry flag
	rl		l						; store bit in L
	ld		b, 176					; timing constant
	jp		nc, ld_8_bits			; jump until L filled
	ld		a, l					; new byte
	xor		h						; parity byte
	ld		h, a					; store it
	ld		a, e					; test for
	or		d						; zero
	jr		nz, ld_loop 			; jump if not
	ld		a, h					; parity byte
	cp		1						; set carry flag on zero
	ret								; end of subroutine

; THE 'LD-EDGE-2' AND 'LD-EDGE-1' SUBROUTINES
org 0x05e3
ld_edge_2:
	call	ld_edge_1				; call ld_edge_1 twice
	ret		nc						; return on error

org 0x05e7
ld_edge_1:
	ld		a, 22					; 358 t-states

org 0x05e9
ld_delay:
	dec		a						; sampling
	jr		nz, ld_delay			; loop
	and		a						; test for zero

org 0x05ed
ld_sample:
	inc		b						; count each pass
	ret		z						; return with carry reset if zero
	ld		a, 0x7f					; read key row
	in		a, (ula)				; 0x7ffe
	rra								; shift the byte
	ret		nc						; return with carry and zero reset on BREAK
	xor		c						; test against
	and		%00100000				; last edge type
	jr		z, ld_sample			; jump back if unchanged
	ld		a, c					; change last edge type
	cpl								; and border color
	ld		c, a					; store A in C 
	and		%00000111				; preserve border color
	or		%00001000				; set MIC off
	out		(ula), a				; change the border
	scf								; signal success
	ret								; end of subroutine

; THE 'SAVE, LOAD & MERGE' COMMAND ROUTINES
org 0x0605
save_etc:
	pop		af						; take scan_loop return address off stack
	ld		a, (t_addr)				; subtract the offset from t_addr
	sub		p_save + 1 % 256		; safe to ignore overflow warning
	ld		(t_addr), a				; 0=SAVE, 1=LOAD, 2=MERGE
	call	expt_exp				; parameter to calculator stack
	call	syntax_z				; checking syntax?
	jr		z, sa_data				; jump if so
	ld		a, (t_addr)				; fetch parameter
	ld		bc, 17					; 17 bytes for SAVE
	and		a						; was it SAVE?
	jr		z, sa_space				; jump if so
	ld		c, 34					; else 34 bytes

org 0x0621
sa_space:
	rst		bc_spaces				; make room in the workspace
	ld		a, ' '					; store a space
	ld		b, 11					; eleven times
	push	de						; start address
	pop		ix						; into IX

org 0x0629
sa_blank:
	ld		(de), a					; put spaces in the
	inc		de						; filename area
	djnz	sa_blank				; loop until done
	ld		(ix + 1), 0xff			; a null name is represented by 0xff
	call	stk_fetch				; get parameters
	dec		bc						; reduce BC
	ld		hl, -10					; filenames can be 10 characters long
	add		hl, bc					; is filename valid?
	inc		bc						; increment BC
	jr		nc, sa_name				; jump if valid
	ld		a, (t_addr)				; get parameter
	and		a						; is it SAVE?
	jr		nz, sa_null				; jump if not for null values
	rst		error					; else
	defb	Bad_filename			; error

org 0x0644
sa_null:
	ld		a, c					; test for
	or		b						; null length
	jr		z, sa_data				; jump if so
	ld		bc, 10					; truncate longer names

org 0x064b
sa_name:
	ex		de, hl					; switch pointers
	push	ix						; copy IX
	pop		de						; to DE
	inc		de						; point to second location
	ldir							; copy filename

org 0x0652
sa_data:
	rst		get_char				; get character
	cp		tk_data					; DATA token?
	jr		nz, sa_scr_str			; jump if not
	ld		a, (t_addr)				; get parameter
	cp		2						; is it MERGE?
	jp		z, report_c				; error if so
	rst		next_char				; get next character
	call	look_vars				; find array
	set		7, c					; set bit 7 of array name
	jr		nc, sa_v_old			; jump with existing array
	ld		a, (t_addr)				; get parameter
	dec		a						; reduce it
	ld		hl, 0					; signal new array
	jr		z, sa_v_new				; trying to save new array?
	rst		error					; error
	defb	Undefined_variable		; if so

org 0x0672
sa_v_old:
	jp		nz, report_c			; jump if error
	call	sa_v_old_1				; exclude simple strings
	jr		z, sa_data_1			; 
	inc		hl						; point to low length of variable
	ld		a, (hl)					; store it in A
	ld		(ix + 11), a			; store it in the workspace
	inc		hl						; point to high byte
	ld		a, (hl)					; store it in A
	ld		(ix + 12), a			; store it in the workspace
	inc		hl						; step past length

org 0x0685
sa_v_new:
	ld		a, 1					; assume numeric array
	ld		(ix + 14), c			; copy array name
	bit		6, c					; numeric array?
	jr		z, sa_v_type			; jump if so
	inc		a						; else character array

org 0x068f
sa_v_type:
	ld		(ix + 0), a				; store type in first header byte

org 0x0692
sa_data_1:
	ex		de, hl					; pointer to DE
	rst		next_char				; get next character
	cp		')'						; closing parenthesis?
	jr		nz, sa_v_old			; error if not
	rst		next_char				; get next character
	call	check_end				; next statement if checking syntax
	ex		de, hl					; restore pointer to HL
	jp		sa_all					; immediate jump

org 0x06a0
sa_scr_str:
	cp		tk_screen_str			; SCREEN$ token?
	jr		nz, sa_code				; jump if not
	ld		a, (t_addr)				; get parameter
	cp		2						; MERGE?
	jp		z, report_c				; error if so
	rst		next_char				; get next character
	call	check_end				; next statement if checking syntax
.ifdef ROM0
	ld		hl, 49152				; point to alternate screen address
.endif
.ifdef ROM1
	ld		hl, bitmap				; point to screen address
.endif
	ld		(ix + 14), h			; 
	ld		(ix + 13), l			; 
.ifdef ROM0
	ld		(ix + 12), 0x38			; 14336 bytes
.endif
.ifdef ROM1
	ld		(ix + 12), 0x1b			; 6912 bytes
.endif
	ld		(ix + 11), 0			; of bitmap data
	jr		sa_type_3				; immediate jump

org 0x06c3
sa_code:
	cp		tk_code					; CODE token?
	jr		nz, sa_line				; jump if not
	ld		a, (t_addr)				; get parameter
	cp		2						; MERGE?
	jp		z, report_c				; error if so
	rst		next_char				; get next character
	call	pr_st_end				; check statement end
	jr		nz, sa_code_1			; jump if not
	ld		a, (t_addr)				; get parameter
	and		a						; test for SAVE
	jp		z, report_c				; error if not
	call	use_zero				; put zero on calculator stack
	jr		sa_code_2				; immediate jump

org 0x06e1
sa_code_1:
	call	expt_1num				; get first number
	rst		get_char				; get next character
	cp		','						; comma?
	jr		z, sa_code_3			; jump if so
	ld		a, (t_addr)				; get parameter
	and		a						; require start and length with SAVE
	jp		z, report_c				; error if not

org 0x06f0
sa_code_2:
	call	use_zero				; put zero on calculator stack
	jr		sa_code_4				; immediate jump

org 0x06f5
sa_code_3:
	rst		next_char				; get next character
	call	expt_1num				; get length

org 0x06f9
sa_code_4:
	call	check_end				; next statement if checking syntax
	call	find_int2				; get length in BC
	ld		(ix + 12), b			; store it
	ld		(ix + 11), c			; in header
	call	find_int2				; get start address in BC
	ld		(ix + 14), b			; store it
	ld		(ix + 13), c			; in header
	ld		l, c					; store pointer
	ld		h, b					; in HL

org 0x0710
sa_type_3:
	ld		(ix + 0), 3				; type 3 for CODE and SCREEN$
	jr		sa_all					; immediate jump

org 0x0716
sa_line:
	cp		tk_line					; LINE token?
	jr		z, sa_line_1			; jump if so
	call	check_end				; next statement if checking syntax
	ld		(ix + 14), end_marker	; store 0x80 when no further parameters
	jr		sa_type_0				; immediate jump

org 0x0723
sa_line_1:
	ld		a, (t_addr)				; get parameter
	and		a						; SAVE?
	jp		nz, report_c			; error if LINE without SAVE
	rst		next_char				; get next character
	call	expt_1num				; number to calculator stack
	call	check_end				; next statement if checking syntax
	call	find_line				; line number to BC
	ld		(ix + 14), b			; store line number
	ld		(ix + 13), c			; in header

org 0x073a
sa_type_0:
	ld		de, (prog)				; pointer to start of program
	ld		hl, (e_line)			; pointer to end of variables
	ld		(ix + 0), 0				; set type 0
	scf								; set carry flag
	sbc		hl, de					; get length of program and variables
	ld		(ix + 12), h			; store
	ld		(ix + 11), l			; result
	ld		hl, (vars)				; pointer to start of variables
	sbc		hl, de					; get length of program without variables
	ld		(ix + 16), h			; store
	ld		(ix + 15), l			; result
	ex		de, hl					; pointer to HL

org 0x075a
sa_all:
	ld		a, (t_addr)				; get parameter
	and		a						; SAVE?
	jp		z, sa_contrl			; jump if so
	push	hl						; stack destination pointer
	ld		bc, 17					; header length
	add		ix, bc					; base address of second header

org 0x0767
ld_look_h:
	xor		a						; signal header
	push	ix						; stack base address
	ld		de, 17					; load header
	scf								; signal LOAD
	call	ld_bytes				; look for header
	pop		ix						; unstack base address
	jr		nc, ld_look_h			; loop until match found
	ld		a, 254					; open 'S'
	call	chan_open				; channel
	ld		(iy + _scr_ct), 255		; scroll count to 255
	ld		a, (ix + 0)				; new type
	ld		c, 0x80					; signal no match
	cp		(ix - 17)				; compare against old type
	jr		nz, ld_type				; jump if no match
	ld		c, -10					; signal match 10

org 0x078a
ld_type:
	cp		4						; valid header (0 to 3)?
	jr		nc, ld_look_h			; load header if valid
	ld		de, tape_msgs - 1		; point to tape messages
	push	bc						; stack C
	call	po_msg					; print message
	pop		bc						; unstack C
	push	ix						; copy IX
	pop		de						; to DE
	ld		hl, -16					; make HL point
	add		hl, de					; to old name
	ld		a, (hl)					; get character
	ld		b, 10					; consider ten characters
	inc		a						; actual name?
	jr		nz, ld_name				; jump if so
	ld		a, b					; if old name is null
	add		a, c					; signal all
	ld		c, a					; characters match

org 0x07a6
ld_name:
	inc		de						; point to next character of new name
	ld		a, (de)					; store it in A
	cp		(hl)					; compare against old name
	inc		hl						; point to next character of old name
	jr		nz, ld_ch_pr			; jump if no match
	inc		c						; increment count

org 0x07ad
ld_ch_pr:
	rst		print_a					; print new character
	djnz	ld_name					; loop ten times
	bit		7, c					; accept name if count is zero
	jr		nz, ld_look_h			; look for next header if not
	ld		a, ctrl_enter			; print a
	rst		print_a					; carriage return
	pop		hl						; unstack pointer
	ld		a, (ix + 0)				; SCREEN$ and CODE are
	cp		3						; handled via vr_contrl
	jr		z, vr_contrl			; jump with a match
	ld		a, (t_addr)				; get byte
	dec		a						; reduce it
	jp		z, ld_contrl			; jump if LOAD
	jp		me_contrl				; else must be MERGE

org 0x07c9
	defs	2, 255					; unused locations (common)

org 0x07cb
vr_contrl:
	push	hl						; stack pointer
	ld		d, (ix + 12)			; get number of bytes
	ld		e, (ix + 11)			; from new header
	ld		h, (ix - 5)				; get number of bytes
	ld		l, (ix - 6)				; from old header
	ld		a, l					; test for zero
	or		h						; (length unspecified)
	jr		z, vr_cont_1			; jump if so
	sbc		hl, de					; is block longer than required length?
	jr		c, report_r				; error if so
	jr		z, vr_cont_1			; jump if not
	ld		a, (ix + 0)				; get type
	cp		3						; SCREEN$ or CODE?
	jr		nz, report_r			; error if so

org 0x07e9
vr_cont_1:
	pop		hl						; unstack pointer
	ld		a, l					; test
	or		h						; for zero
	jr		nz, vr_cont_2			; use old header if so
	ld		h, (ix + 14)			; use new header
	ld		l, (ix + 13)			; if not

org 0x07f4
vr_cont_2:
	push	hl						; copy pointer
	pop		ix						; to IX
	scf								; set carry flag
	ld		a, 0xff					; signal LOAD
	jp		ld_block				; immediate jump

; -----------------------------------------------------------------------------

; THE 'STREAM-FE' SUBROUTINE 
org 0x7fd
stream_fe:
	ld		a, 254					; located here
	jp		chan_open				; for space efficiency

; -----------------------------------------------------------------------------

; THE 'LOAD A DATA BLOCK' SUBROUTINE
org 0x0802
ld_block:
	call	ld_bytes				; LOAD a data block
	ret		c						; return unless error

org 0x0806
report_r:
	rst		error					; report
	defb	Loading_error			; loading error

; THE 'LOAD' CONTROL ROUTINE
org 0x0808
ld_contrl:
	ld		d, (ix + 12)			; get number of bytes
	ld		e, (ix + 11)			; from new header
	push	hl						; stack destination pointer
	ld		a, l					; test for
	or		h						; zero
	jr		nz, ld_cont_1			; jump unless loading undeclared array
	inc		de						; add three bytes
	inc		de						; for variable name
	inc		de						; and length
	ex		de, hl					; length to HL
	jr		ld_cont_2				; immediate jump

org 0x0819
ld_cont_1:
	ld		h, (ix - 5)				; get size of
	ld		l, (ix - 6)				; program and variables
	ex		de, hl					; put in DE
	scf								; set carry flag
	sbc		hl, de					; extra room needed?
	jr		c, ld_data				; jump if not

org 0x0825
ld_cont_2:
	ld		de, 5					; add five
	add		hl, de					; bytes
	ld		c, l					; result
	ld		b, h					; to BC
	call	test_room				; test for room

org 0x082e
ld_data:
	pop		hl						; unstack pointer
	ld		a, (ix + 0)				; loading a
	and		a						; program?
	jr		z, ld_prog				; jump if so
	ld		a, l					; test for zero
	or		h						; an array?
	jr		z, ld_data_1			; jump if so
	dec		hl						; get
	ld		b, (hl)					; length of
	dec		hl						; existing
	ld		c, (hl)					; array
	dec		hl						; point to old name
	inc		bc						; add three bytes
	inc		bc						; for name
	inc		bc						; and length
	ld		(x_ptr), ix				; store IX
	call	reclaim_2				; reclaim old array
	ld		ix, (x_ptr)				; restore IX

org 0x084c
ld_data_1:
	ld		hl, (e_line)			; pointer to end of variables
	dec		hl						; point to end marker
	ld		b, (ix + 12)			; get length
	ld		c, (ix + 11)			; of new array
	push	bc						; stack it
	inc		bc						; add three bytes
	inc		bc						; for name
	inc		bc						; and length
	ld		a, (ix - 3)				; get name from old header
	push	af						; stack it
	call	make_room				; make room
	pop		af						; unstack name
	inc		hl						; point to next location
	ld		(hl), a					; store name
	inc		hl						; point to next location
	pop		de						; unstack length
	ld		(hl), e					; store low byte
	inc		hl						; point to next location
	ld		(hl), d					; store high byte
	inc		hl						; point to next location
	push	hl						; copy pointer
	pop		ix						; to IX
	scf								; set carry flag
	ld		a, 0xff					; signal data block
	jp		ld_block				; immediate jump

org 0x0873
ld_prog:
	ex		de, hl					; destination pointer to DE
	ld		hl, (e_line)			; address of end of variables
	dec		hl						; point to end marker
	ld		(x_ptr), ix				; store IX
	ld		b, (ix + 12)			; get
	ld		c, (ix + 11)			; length
	push	bc						; stack it
	call	reclaim_1				; reclaim program and variables area
	pop		bc						; unstack length
	push	hl						; stack pointer to program area
	push	bc						; stack length
	call	make_room				; make room
	inc		hl						; increment pointer
	ld		ix, (x_ptr)				; restore IX
	ld		b, (ix + 16)			; calculate
	ld		c, (ix + 15)			; new value
	add		hl, bc					; of vars
	ld		(vars), hl				; and store it
	ld		h, (ix + 14)			; was a
	ld		a, h					; line number
	and		%11000000				; specified?
	jr		nz, ld_prog_1			; jump if not
	ld		l, (ix + 13)			; get rest of line number
	ld		(newppc), hl			; and store it
	ld		(iy + _nsppc), 0		; set nsppc

org 0x08ad
ld_prog_1:
	pop		de						; get length
	pop		ix						; get start
	scf								; set carry flag
	ld		a, 0xff					; signal data block
	jp		ld_block				; immediate jump

; THE 'MERGE' CONTROL ROUTINE
org 0x08b6
me_contrl:
	ld		b, (ix + 12)			; get length
	ld		c, (ix + 11)			; of data block
	push	bc						; stack length
	inc		bc						; length plus one
	rst		bc_spaces				; make space in workspace
	ld		(hl), end_marker		; end marker
	ex		de, hl					; start pointer to HL
	pop		de						; unstack length
	push	hl						; stack start
	push	hl						; start
	pop		ix						; to IX
	scf								; set carry flag
	ld		a, 0xff					; signal data block
	call	ld_block				; LOAD data block
	pop		hl						; unstack start of new program
	ld		de, (prog)				; start of old program to DE

org 0x08d2
me_new_lp:
	ld		a, (hl)					; get line number
	and		%11000000				; test it
	jr		nz, me_var_lp			; jump when all lines complete

org 0x08d7
me_old_lp:
	ld		a, (de)					; compare high line number byte
	cp		(hl)					; of old program with new
	inc		hl						; increment
	inc		de						; both pointers
	jr		nz, me_old_l1			; jump with no match
	ld		a, (de)					; compare low line number byte
	cp		(hl)					; of old program with new

org 0x08df
me_old_l1:
	dec		hl						; restore pointers
	dec		de						; to high byte
	jr		nc, me_new_l2			; jump if correct place found for new line
	ex		de, hl					; switch pointers
	push	de						; stack old program pointer
	call	next_one				; find address of start of next old line
	pop		hl						; unstack old program pointer
	jr		me_old_lp				; loop until done

org 0x08eb
me_new_l2:
	call	me_enter				; enter new line
	jr		me_new_lp				; loop until done

org 0x08f0
me_var_lp:
	ld		a, (hl)					; get variable name
	ld		c, a					; test it
	cp		end_marker				; no more variables?
	ret		z						; return if so
	push	hl						; stack new pointer
	ld		hl, (vars)				; old program variables address to HL

org 0x08f9
me_old_vp:
	ld		a, (hl)					; get variable name
	cp		end_marker				; test for end marker
	jr		z, me_var_l2			; jump if so
	cp		c						; compare names
	jr		z, me_old_v2			; jump with match

org 0x0901
me_old_v1:
	push	bc						; stack new variable name
	call	next_one				; get next old variable
	ex		de, hl					; restore pointer
	pop		bc						; unstack new variable name
	jr		me_old_vp				; immediate jump

org 0x0909
me_old_v2:
	and		%11100000				; consider bits 7 to 5
	cp		%10100000				; accept all variable types
	jr		nz, me_var_l1			; except long name variables
	pop		de						; DE points to the first character
	push	de						; of the new name
	push	hl						; stack pointer to old name

org 0x0912
me_old_v3:
	inc		de						; update new and
	inc		hl						; old pointers
	ld		a, (de)					; new pointer to A
	cp		(hl)					; compare characters
	jr		nz, me_old_v4			; jump if no match
	rla								; last character?
	jr		nc, me_old_v3			; loop until found
	pop		hl						; unstack pointer to start of old name
	jr		me_var_l1				; immediate jump

org 0x091e
me_old_v4:
	pop		hl						; unstack pointer
	jr		me_old_v1				; immediate jump

org 0x0921
me_var_l1:
	ld		a, 255					; signal replace variable

org 0x0923
me_var_l2:
	ex		de, hl					; switch pointers and set zero flag for
	inc		a						; replacement or reset for insertion
	pop		hl						; unstack pointer to new name
	scf								; signal handling variables
	call	me_enter				; make the entry
	jr		me_var_lp				; loop until done

; THE 'MERGE A LINE OR VARIABLE' SUBROUTINE
org 0x092c
me_enter:
	jr		nz, me_ent_1			; jump with insertion
	ld		(x_ptr), hl				; store flags
	ex		af, af'					;'store new pointer
	ex		de, hl					; while old line
	call	next_one				; or variable
	call	reclaim_2				; is reclaimed
	ex		af, af'					;'restore new pointer
	ex		de, hl					; swap registers
	ld		hl, (x_ptr)				; restore flags

org 0x093e
me_ent_1:
	push	de						; stack destination pointer
	ex		af, af'					;'store flags
	call	next_one				; get length of new variable or line
	ld		(x_ptr), hl				; store pointer to new variable or line
	ld		hl, (prog)				; avoid corruption
	ex		(sp), hl				; stack prog
	push	bc						; stack length
	ex		af, af'					;'restore flags
	jr		c, me_ent_2				; jump if inserting variable
	dec		hl						; new line to be added before destination
	call	make_room				; make room
	inc		hl						; restore destination
	jr		me_ent_3				; immediate jump

org 0x0955
me_ent_2:
	call	make_room				; make room

org 0x0958
me_ent_3:
	pop		bc						; unstack length
	pop		de						; unstack prog
	inc		hl						; point to first location
	ld		(prog), de				; restore prog
	ld		de, (x_ptr)				; get new pointer
	push	bc						; stack length
	ex		de, hl					; swap pointers 
	push	hl						; stack new pointer
	ldir							; copy the new variable or line
	pop		hl						; unstack new pointer
	pop		bc						; unstack length
	push	de						; stack old pointer
	call	reclaim_2				; remove variable or line from workspace
	pop		de						; unstack old pointer
	ret								; end of subroutine

; THE 'SAVE' CONTROL ROUTINE
org 0x0970
sa_contrl:
	push	hl						; stack pointer
	push	ix						; stack base address of header
	xor		a						; signal header
	ld		de, 17					; SAVE 17 bytes
	call	sa_bytes				; send header with type and parity byte
	ld		b, 50					; one second delay (@ 50Hz)
	pop		ix						; unstack base address of header

org 0x097e
sa_1_sec:
	halt							; wait for interrupt
	djnz	sa_1_sec				; jump until delay is complete
	ld		a, 0xff					; signal data block 
	ld		d, (ix + 12)			; get length
	ld		e, (ix + 11)			; of data block
	pop		ix						; unstack start of block
	jp		sa_bytes				; immediate jump

org 0x098e
sa_v_old_1:
	call	syntax_z				; return if
	ret		z						; checking syntax
	bit		7, (hl)					; simple string?
	ret		nz						; return if not
	rst		error					; otherwise
	defb	Syntax_error			; error

; THE TAPE MESSAGES
	defb	0xff					; preceding byte must be 128 or higher 
tape_msgs:
	incbin	"filetypes.txt"			; tape messages
