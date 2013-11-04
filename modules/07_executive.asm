; --- THE EXECUTIVE ROUTINES --------------------------------------------------

org 0x11b7
e_l_0:
	push	af						; stack carry flag
	call	int_to_fp				; number to temporary stack
	pop		af						; unstack carry flag
	ret		nc						; return if number not found immediately
	pop		bc						; discard return address
	call	fp_to_bc				; number from temporary stack to BC
	scf								; set carry flag
	jp		set_stk					; immediate jump

org 0x11c5
	defs	1, 255					; unused locations (common)

.ifdef ROM0
; THE 'COLD START' ROUTINE
cold_start:
 	xor		a						; LD A, 0
 	out		(ula), a				; BORDER 0
 	out		(mmu), a				; ensure no sideways RAM is paged in
	ld		a, %00001000			; ROM 0, VRAM 1; RAM 0
	ld		bc, paging				; select paging
	out		(c), a					; set it
	ld		hl, font - 256			; offest to ASCII character zero
	ld		(chars), hl				; store it in chars
	ld		iy, err_nr				; err-nr to IY
	ld		bc, 21					; byte count
	ld		de, init_chan			; destination
	ld		hl, channels			; source
	ld		(chans), hl				; set system variable
	ex		de, hl					; swap pointers
	ldir							; copy initial channel table
	ld		c, 14					; byte count
	ld		de, strms				; destination
	ld		hl, init_strm			; source
	ldir							; copy initial streams table
	ld		(iy + _df_sz), 2		; set lower display size
	call	cls						; clear screen
	xor		a						; prepare for printing
	ld		de, copyright - 1		; copyright message
	call 	po_msg					; print it
 	ld		a, 62					; 512x192 mode, white on black
 	out		(scld), a				; DOCK bank, interrupts on
	ld		b, 6					; bank count
		
cold_start_1:
	ld		a, b					; count to A
	or		%00001000				; set VRAM 1
	ld		bc, paging				; select paging
	out		(c), a					; set page
 	ld		hl, 49152				; first byte of top 16K
 	ld		de, 49153				; second byte of top 16K
 	ld		bc, 16383				; 16K - 1
 	ld		(hl), 0					; zero first byte
 	ldir							; clear bank
	and		%00000111				; get real count
 	ld		b, a					; restore count to B
 	djnz	cold_start_1			; loop until banks 1 to 6 cleared
	im		1						; set interrupt
	ld		b, 144					; pause approximately 5 seconds in total
	ei								; enable interrupts

cold_start_2:
	halt							; pause
	djnz	cold_start_2			;
	di								; switch off interrupts again
	ld		e, %00011000			; ROM 1, VRAM 1, RAM 0
  	jp		mode_switch_2			; switch immediately to ROM 1
.endif
ifdef ROM1

; THE 'TEST 16K' ROUTINE
org 0x11c6
test_16k:
	ld		d, e					; set high byte of top of RAM
	ld		(de), a					; set to 0
	ld		a, (de)					; load it back
	and		a						; still 0 (will be 255 on 16K machine)
	jr		z, start_new			; jump with 48K machine or greater
	xor		a						; A = 0
	ld		d, 0x7f					; ramptop to 32767

; THE 'INITIALIZATION' ROUTINE
org 0x11cf
start_new:
	ex		af, af'					;'store A
	xor		a						; black
	out		(ula), a				; set border
	ld		a, 63					; set I
	ld		i, a					; to 63
	ld		iyh, d					; ramtop
	ld		iyl, e					; to IY
	ex		de, hl					; swap pointers
	ld		de, kstate				; start of system variables to DE
	sbc		hl, de					; bytes to clear
	ld		b, h					; byte count
	ld		c, l					; to BC
	ld		h, d					; start address
	ld		l, e					; to HL
	ld		(hl), l					; store zero in first address
	inc		e						; start address plus one to DE
	ldir							; wipe bytes
	exx								; alternate register set
	ld		(udg), bc				; restore udg
	ld		(nmiadd), de			; restore nmiadd
	ld		(p_ramt), hl			; restore p-ramt
	exx								; main resister set
	ex		af, af'					;'restore A
	inc		a						; NEW command?
	jr		z, set_top				; jump if sp
	ld		(p_ramt), iy			; set top of RAM
	ld		hl, initpal - 7			; source
	ld		de, palbuf				; destination
	ld		bc, 64					; byte count
	ldir							; copy bytes
 	ld		(udg), de				; next destination will hold UDGs
	ld		hl, 0x3e08				; address 'A' in font
	ld		c, 168					; 21 characters, 8 bytes each
 	ldir							; copy bytes
	ld		hl, (p_ramt)			; p-ramt to HL

org 0x1217
set_top:
	ld		(ramtop), hl			; HL to ramtop

org 0x121a
initial:
	ld		hl, font - 256			; offest to ASCII character zero
	ld		(chars), hl				; store it in chars
	ld		hl, 60					; set initial values
	ld		(rasp), hl				; for rasp and pip
	ld		hl, (ramtop)			; ramtop to HL
	ld		(hl), 0x3e				; set it to the GOSUB end marker
	dec		hl						; skip one location
	ld		sp, hl					; point stack to next location
	dec		hl						; skip two
	dec		hl						; locations
	ld		(err_sp), hl			; set err-sp
	im		1						; interrupt mode 1
	ld		iy, err_nr				; err-nr to IY
	ei								; enable interrupts
	ld		a, (chans)				; coming from
	and		a						; start or new?
	ld		(iy + _onerrflag_h), 255; signal on error stop
	ld		a, BREAK_into_program +1; prepare error
	jp		nz, main_g				; jump if not
	ld		bc, 21					; byte count
	ld		de, init_chan			; destination
	ld		hl, channels			; source
	ld		(chans), hl				; set system variable
	ex		de, hl					; swap pointers
	ldir							; copy initial channel table
	ex		de, hl					; swap pointers
	dec		hl						; last location of channel data
	ld		(datadd), hl			; store it in ddatadd
	inc		hl						; next location
	ld		(vars), hl				; store address in
	ld		(prog), hl				; vars and prog
	ld		(hl), end_marker		; store variables end marker
	inc		hl						; next location
	ld		(e_line), hl			; store address in e-line
	ld		a, white				; white PEN, black PAPER, CLUT 0
	ld		(bordcr), a				; set BORDER color
	ld		(attr_p), a				; set permanent attribute
	ld		hl, 0x0219				; set initial values
	ld		(repdel), hl			; for repdel and repper
	ld		hl, initial				; set default
	ld		(nmiadd), hl			; nmi routine
	dec		(iy - _kstate_4)		; set kstate-4 to 255
	dec		(iy - _kstate)			; set kstate to 255
	ld		c, 14					; byte count
	ld		de, strms				; destination
	ld		hl, init_strm			; source
	ldir							; copy initial streams table
	ld		(iy + _df_sz), 2		; set lower display size
	xor		a						; LD A, 0
	ld		bc, paging				; VRAM / ROM
	out		(scld), a				; set mode
	ld		a, 16					; normal video
	out		(c), a					; set video	
	call	cls_pal					; clear screen and set palette
	res		5, (iy + _vdu_flag)		; lower screen will need clearing
	jr		main_1					; immediate jump
.endif

;THE 'MAIN EXECUTION' LOOP
org 0x12a2
main_exec:
	ld		(iy + _df_sz), 2		; set lower screen
	call	auto_list				; auto list

org 0x12a9
main_1:
	call	set_min					; set minimums

org 0x12ac
main_2:
	xor		a						; LD A, 0
	call	chan_open				; open channel 'K'
	call	tokenizer				; tokenize input
	call	line_scan				; check syntax
	bit		7, (iy + _err_nr)		; correct?
	jr		nz, main_3				; jump if so
	bit		4, (iy + _flags2)		; channel 'K'?
	jr		z, main_4				; jump if not
	ld		hl, (e_line)			; address syntax error
	call	remove_fp				; remove floating point forms
	ld		(iy + _err_nr), OK		; reset error
	jr		main_2					; jump back
 
; THE 'FIND LINE' SUBROUTINE
org 0x12ce
find_line:
	call	find_int2				; line number to BC
	ld		a, b					; high byte to A
	cp		0x40					; less than 16384?
	ret		c						; return if so
	rst		error					; else
	defb	Integer_out_of_range	; error

org 0x12d7
main_3:
	ld		(iy + _mode), 0			; cancel control or meta
	call	e_line_no				; get line number
	ld		a, c					; valid
	or		b						; line?
	jp		nz, main_add			; jump if so
	rst		get_char				; else get character
	cp		ctrl_enter				; carriage return?
	jr		z, main_exec			; jump if so
	bit		0, (iy + _flags2)		; clear whole display?
	call	nz, cl_all				; jump if so
	call	cls_lower				; clear lower display
	ld		a, 25					; scroll counter value
	sub		(iy + _s_posn_h)		; subtract to get true count
	ld		(scr_ct), a				; current count to A
	set		7, (iy + _flags)		; signal line execution
	ld		(iy + _nsppc), 1		; first statement 
	ld		(iy + _err_nr), OK		; signal no error
	call	line_run				; interpret line

org 0x1309
main_4:
	ld		a, (err_nr)				; error number to A
	res		5, (iy + _flags)		; signal ready for new key
 	call	onerr_test				; test on error
	ld		a, (err_nr)				; get error number again
	inc		a						; increase it
	
org 0x1317
main_g:
	push	af						; stack report code
	ld		bc, ay_reg				; AY register for Timex and 128
	ld		a, 7					; volume
	out		(c), a					; select it
	ld		a, 0xff					; silence AY
	call	sound_2					; write to data register
	ld		hl, 0					; zero 
	ld		(defadd), hl			; HL to defadd
 	ld		(iy + _x_ptr_h), l		; x-ptr-h
 	ld		(iy + _flagx), l		; and flag x
 	inc		hl						; LD HL, 1
 	ld		(strms_00), hl			; point to channel 'K'
 	call	set_min					; clear all work areas and calculator stack
 	call	cls_lower				; clear lower screen
 	pop		af						; restore report code
 	set		5, (iy + _vdu_flag)		; signal lower screen in use
 	ld		de, rpt_mesgs - 1		; address table
 	set		0, (iy + _flags)		; suppress leading space
 	call	po_msg					; print the message

; THE 'SHADOW ROM ERROR REPORT' ENTRY POINT
org 0x1349
l1349:
	ld		a, ','					; print
	rst		print_a					; a comma
	ld		a, ' '					; and
	rst		print_a					; a space
	ld		bc, (ppc)				; current line number to BC
	call	out_num_1				; print it
	ld		a, ':'					; print
	rst		print_a					; a colon
	ld		b, 0					; clear B
	ld		c, (iy + _subppc)		; statement number to BC
	call	out_num_1				; print it
	call	clear_sp				; clear editing area
	ld		a, (err_nr)				; restore error number
	inc		a						; increase it
	jr		z, main_9				; immediate jump if successful
	cp		STOP_statement + 1		; STOP?
	jr		z, main_6				; set CONTINUE to next statement if so
	cp		BREAK_into_program + 1	; BREAK? 
	jr		nz, main_7				; set CONTINUE to next statement if so

org 0x1372
main_6:
	inc		(iy + _subppc)			; increase subppc

org 0x1375
main_7:
	ld		hl, nsppc				; HL addresses nsppc
	ld		de, osppc				; destination
	ld		bc, 3					; byte count
	bit		7, (hl)					; BREAK before jump?
	jr		z, main_8				; jump if not
	add		hl, bc					; source to subppc

org 0x1383
main_8:
	lddr							; copy bytes

org 0x1385
main_9:
	ld		(iy + _nsppc), 255		; signal no jump
	jp		main_2					; immediate jump

; THE 'ON ERROR' SUBROUTINE
org 0x138c
onerr_test:
	cp		OK						; no error?
	ret		z						; return if so
	cp		STOP_statement			; STOP statement?
	ret		z						; return if so
	ld		hl, (onerrflag)			; get flag or line number
	ld		a, h					; flag to H
	cp		0xff					; on error stop?
	ret		z						; return if so
	cp		0xfe					; on error continue?
	jr		z, onerr_test_1			; jump if so
	ld		(newppc), hl			; store line to jump to in newppc
	ld		(iy + _nsppc), 0		; clear statement number

org 0x13a4
onerr_test_1:
	ld		(iy + _err_nr), OK		; signal no error
	pop		hl						; discard return address
	ld		hl, main_4				; make main-4
	push	hl						; new return address
	jp		stmt_ret				; immediate jump
 
; THE 'NEW' COMMAND	ROUTINE 
org 0x13b0
new:
	call	find_int1				; get variable
	and		a						; zero?
	jr		z, new_0				; handle NEW 0
	cp		48						; 48?
	jr		z, new_48				; handle NEW 48
	cp		128						; 128?
	jr		z, new_128				; handle NEW 128
	rst		error					; else
	defb	Parameter_error			; error
.ifdef ROM0

org 0x13c0
new_0:
	call	mode_switch				; ensure ROM 1
	defs	23, 255					; unused locations (ROM 0)
.endif
.ifdef ROM1

org 0x13c0
	defs	3, 255					; unused locations (ROM 1)

org 0x13c3
new_0:
	di								; switch off interrupts
	ld	a, 255						; signal coming from new
	ld	de, (ramtop)				; ramtop to DE
	exx								; alternate register set
	ld	bc, (p_ramt)				; p-ramt to BC'
	ld	de, (nmiadd)				; nmiadd to DE'
	ld	hl, (udg)					; udg to HL'
	exx								; main register set
	jp	start_new					; immediate jump
.endif

.ifdef ROM0

org 0x13da
new_48:
	call	mode_switch				; ensure ROM 1

org 0x13dd
	defs	9, 255					; unused locations (ROM 0)
.endif
.ifdef ROM1

org 0x13da
new_128:
	xor		a						; retain graphics mode
	jr		new_128_1				; immediate jump

org 0x13dd
new_48:
	ld		bc, paging				; select paging
	ld		a, %00110000			; lock paging, ROM 1, VRAM 0, RAM 0
	out		(c), a					; 48 compatibility mode
	jr		new_0					; normal reset
.endif
.ifdef ROM0

org 0x13e6
	defs	3, 255					; unused locations (ROM 0)

org 0x13e9
new_128:
	rst		start					; cold start
.endif
.ifdef ROM1

org 0x13e6
new_128_1:
	call	mode_switch_1			; ensure ROM 0

org 0x13e9
	defs	1, 255					; unused locations (ROM 1)
.endif

; THE 'DELETE' COMMAND ROUTINE
org 0x13ea
delete:
	call	get_line				; get a valid line number
	call	next_one				; find address
	push	de						; stack it
	call	get_line				; get next line number
	pop		de						; unstack address
	and		a						; clear carry flag
	sbc		hl, de					; check line range
	jr		nc, del_error			; error if not valid
	add		hl, de					; restore line number
	ex		de, hl					; swap pointers
	jp		reclaim_1				; delete lines

org 0x13ff
get_line:
	call	find_line				; get line
	ld		h, b					; BC
	ld		l, c					; to HL
	call	line_addr				; get line address
	ret		z						; return if valid

org 0x1408
del_error:
	rst		error					; else
	defb	Bad_argument			; error

org 0x140a
	defs	2, 255					; unused locations (common)

; THE REPORT MESSAGES
org 0x140c
rpt_mesgs:
	incbin	"reports.txt"			; each message has last character inverted

; THE 'MAIN-ADD' SUBROUTINE
org 0x155d
main_add:
	ld		(e_ppc), bc				; make new line current line
	ld		hl, (ch_add)			; ch-add to HL
	ex		de, hl					; store it in DE
	ld		hl, report_g			; set report-g
	push	hl						; as return address
	ld		hl, (worksp)			; worksp to HL
	scf								; set carry flag
	sbc		hl, de					; length from end of line number to end
	push	hl						; stack length
	ld		h, b					; transfer
	ld		l, c					; to BC
	call	line_addr				; line number exists?
	jr		nz, main_add1			; jump if not
	call	next_one				; get length of old line
	call	reclaim_2				; and reclaim it

org 0x157d
main_add1:
	pop		bc						; get length of new line in BC
	ld		a, c					; test for a
	dec		a						; line number followed
	or		b						; by carriage return
	jr		z, main_add2			; jump if so
	push	bc						; stack BC
	inc		bc						; add four
	inc		bc						; locations
	inc		bc						; for number
	inc		bc						; and length
	dec		hl						; location before destination to HL
	ld		de, (prog)				; prog to DE
	push	de						; stack it
	call	make_room				; make space
	pop		hl						; unstack prog to HL
	ld		(prog), hl				; restore prog
	pop		bc						; unstack length without parameters
	push	bc						; restack
	inc		de						; end location to DE
	ld		hl, (worksp)			; worksp to HL
	dec		hl						; point to
	dec		hl						; carriage return
	lddr							; copy over line
	ld		hl, (e_ppc)				; line number to HL
	ex		de, hl					; swap pointers
	pop		bc						; unstack length
	ld		(hl), b					; most significant byte of length
	dec		hl						; next
	ld		(hl), c					; least significant byte of length
	dec		hl						; next
	ld		(hl), e					; most significant byte of line number
	dec		hl						; next
	ld		(hl), d					; least significant byte of line number

org 0x15ab
main_add2:
	pop		af						; discard report-g return address
	jp		main_exec				; immediate jump

; THE 'INITIAL CHANNEL INFORMATION'
org 0x15af
init_chan:
	defw	print_out, key_input	; keyboard
	defb	'K'						; channel
	defw	print_out, report_j		; screen
	defb	'S'						; channel
	defw	detokenizer, report_j	; work space
	defb	'R'						; channel
	defw	x80_fdel, report_j		; null
	defb	'P'						; channel
	defb	end_marker				; no more channels

org 0x15c4
report_j:
	rst		error					; report
	defb	Bad_device				; error

; THE 'INITIAL STREAM DATA'
org 0x15c6
init_strm:
	defb	 1, 0					; -3, 'K'
	defb	 6, 0					; -2, 'S'
	defb	11, 0					; -1, 'R'
	defb	 1, 0					;  0, 'K' 
	defb	 1, 0					;  1, 'K'
	defb	 6, 0					;  2, 'S'
	defb	16, 0					;  3, 'P'

; THE 'WAIT-KEY' SUBROUTINE
org 0x15d4
wait_key:
	bit		5, (iy + _vdu_flag)		; does lower screen require clearing?
	jr		nz, wait_key1			; jump if not
	set		3, (iy + _vdu_flag)		; signal mode change

org 0x15de
wait_key1:
	call	input_ad				; call input subroutine
	ret		c						; return with valid result
	jr		z, wait_key1			; loop if no key pressed
	rst		error					; else
	defb	End_of_file				; error

;THE 'INPUT-AD' SUBROUTINE
org 0x15e6
input_ad:
	exx								; alternate register set
	push	hl						; stack HL'
	ld		hl, (curchl)			; current channel to HL'
	inc		hl						; skip output
	inc		hl						; address
	jr		call_sub				; immediate jump

; THE 'MAIN PRINTING' SUBROUTINE
org 0x15ef
out_code:
	ld		e, '0'					; convert number
	add		a, e					; value to ASCII

org 0x15f2
print_a_2:
	exx								; alternate register set 
	push	hl						; stack HL'
	ld		hl, (curchl)			; current channel to HL'

org 0x15f7
call_sub:
	ld		e, (hl)					; address
	inc		hl						; to
	ld		d, (hl)					; DE
	ex		de, hl					; swap pointers
	call	call_jump				; call subroutine
	pop		hl						; unstack HL'
	exx								; main register set
	ret								; end of subroutine

; THE 'CHAN-OPEN' SUBROUTINE
org 0x1601
chan_open:
	add		a, a					; A * 2
	add		a, 22					; 16 + A * 2
	ld		h, kstate/256			; stream address
	ld		l, a					; to HL
	ld		e, (hl)					; output
	inc		hl						; address
	ld		d, (hl)					; to DE
	ld		a, e					; stream
	or		d						; exists?
	jr		nz, chan_op_1			; jump if so

org 0x160e
report_o:
	rst		error					; else
	defb	Bad_stream				; error

org 0x1610
chan_op_1:
	dec		de						; reduce base address
	ld		hl, (chans)				; chans to HL
	add		hl, de					; channel base address to HL

; THE 'CHAN-FLAG' SUBROUTINE
org 0x1615
chan_flag:
	res		4, (iy + _flags2)		; signal using channel 'K'
	ld		(curchl), hl			; base address for channel to curchl
	inc		hl						; skip
	inc		hl						; past
	inc		hl						; input
	inc		hl						; address
	ld		c, (hl)					; letter to C
	ld		hl, chn_cd_lu			; HL points to lookup table
	call	indexer					; get offset for a valid code
	ret		nc						; return if not valid
	ld		e, (hl)					; offset
	ld		d, 0					; to DE
	add		hl, de					; address of routine
	jp		(hl)					; immediate jump

; THE 'CHANNEL CODE LOOK-UP' TABLE
org 0x162d
chn_cd_lu:
	defb	'K', chan_k - $			; keyboard
	defb	'S', chan_s - $			; screen
	defb	'R', chan_r - $			; work space
	defb	0						; end marker

; THE 'CHANNEL 'K' FLAG' SUBROUTINE
org 0x1634
chan_k:
	res		5, (iy + _flags)		; signal lower screen
	set		4, (iy + _flags2)		; signal ready for key
	set		0, (iy + _vdu_flag)		; signal using channel 'K'
	jr		chan_s_1				; immediate jump

; THE 'CHANNEL 'S' FLAG' SUBROUTINE
org 0x1642
chan_s:
	res		0, (iy + _vdu_flag)		; signal main screen

org 0x1646
chan_s_1:
	jp		temps					; immediate jump

; THE 'CLOSE STREAM LOOK-UP' TABLE
org 0x1649
cl_str_lu:
	defb	'K', close_str - $		; keyboard
	defb	'S', close_str - $		; screen
	defb	'R', close_str - $		; work space
	defb	0						; end marker

org 0x1650
close_str:
	pop		hl						; unstack channel information pointer

; THE 'CHANNEL 'R' FLAG' SUBROUTINE
org 0x1651
chan_r:
	ret								; return

;THE 'MAKE-ROOM' SUBROUTINE
org 0x1652
one_space:
	ld		bc, 1					; single location required

org 0x1655
make_room:
	push	hl						; stack pointer
	call	test_room				; check available memory
	pop		hl						; unstack pointer
	call	pointers				; alter pointers
	ld		hl, (stkend)			; new stack end to HL
	ex		de, hl					; swap pointers
	lddr							; make room
	ret								; end of subroutine

; THE 'POINTERS' SUBROUTINE
org 0x1664
pointers:
	push	af						; stack AF
	push	hl						; and HL
	ld		hl, vars				; address system variable
	ld		a, 14					; fourteen system pointers

org 0x166b
ptr_next:
	ld		e, (hl)					; two bytes of
	inc		hl						; current pointer
	ld		d, (hl)					; to DE
	ex		(sp), hl				; swap with address of position
	and		a						; prepare for subtraction
	sbc		hl, de					; set carry if address requires updating
	add		hl, de					; restore HL
	ex		(sp), hl				; restore address of position
	jr		nc, ptr_done			; jump if no change
	push	de						; stack old value
	ex		de, hl					; swap pointers
	add		hl, bc					; add value in BC to old value
	ex		de, hl					; swap pointers
	ld		(hl), d					; store new
	dec		hl						; value in
	ld		(hl), e					; system variable
	inc		hl						; point to next system variable
	pop		de						; unstack old value

org 0x167f
ptr_done:
	inc		hl						; point to next system variable
	dec		a						; reduce count
	jr		nz, ptr_next			; loop until done
	ex		de, hl					; old stkend to HL
	pop		de						; unstack DE
	pop		af						; unstack AF
	and		a						; prepare for subtraction
	sbc		hl, de					; difference of old stkend and position
	ld		b, h					; put it
	ld		c, l					; in BC
	inc		bc						; add one for the inclusive byte
	add		hl, de					; restore HL
	ex		de, hl					; swap pointers
	ret								; end of subroutine

; THE 'COLLECT A LINE NUMBER' SUBROUTINE
org 0x168f
line_zero:
	defw	0						; zero

org 0x1691
line_no_a:
	ex		de, hl					; swap pointers
	ld		de, line_zero			; point to line-zero

org 0x1695
line_no:
	ld		a, (hl)					; most significant byte to A
	and		%11000000				; test it
	jr		nz, line_no_a			; jump if not suitable
	ld		d, (hl)					; line
	inc		hl						; number
	ld		e, (hl)					; to HL
	ret								; end of subroutine

; THE 'RESERVE' SUBROUTINE
org 0x169e
reserve:
	ld		hl, (stkbot)			; stkbot to HL
	dec		hl						; last location of workspace to HL
	call	make_room				; make number of spaces in BC
	inc		hl						; point to second
	inc		hl						; new space
	pop		bc						; unstack old worksp
	ld		(worksp), bc			; restore it
	pop		bc						; unstack number of spaces
	ex		de, hl					; swap pointers
	inc		hl						; HL points to first displaced byte
	ret								; end of subroutine

; THE 'SET-MIN' SUBROUTINE
org 0x16b0
set_min:
	ld		hl, (e_line)			; e-line to HL
	ld		(k_cur), hl				; store it in k-cur
	ld		(hl), ctrl_enter		; store a carriage return
	inc		hl						; next
	ld		(hl), end_marker		; store the end marker
	inc		hl						; next
	ld		(worksp), hl			; update worksp

org 0x16bf
set_work:
	ld		hl, (worksp)			; clear
	ld		(stkbot), hl			; workspace

org 0x16c5
set_stk:
	ld		hl, (stkbot)			; clear
	ld		(stkend), hl			; the stack
	push	hl						; stack stkend
	ld		hl, membot				; address system variable
	ld		(mem), hl				; store it in mem
	pop		hl						; unstack stkend
	ret								; end of subroutine

; THE 'PAUSE' ENTRY POINT
org 0x16d4
pause:
	call	pause_end				; signal no key pressed
	jp		pause_0					; immediate jump

org 0x16da
	defs	1, 255					; unused locations (common)

; THE 'INDEXER' SUBROUTINE
org 0x16db
indexer_1:
	inc		hl						; next

org 0x16dc
indexer:
	ld		a, (hl)					; first pair to A
	and		a						; end marker?
	ret		z						; return if so
	cp		c						; matching code?
	inc		hl						; next
	jr		nz, indexer_1			; jump with incorrect code
	scf								; set carry flag
	ret								; end of subroutine

; THE 'CLOSE' COMMAND ROUTINE
org 0x16e5
close:
	call	str_data				; get stream data
	call	close_0					; check stream is open
	ld		bc, 0					; signal stream not in use
	ld		de, 0xa3e2				; handle streams 0 to 3
	ex		de, hl					; swap pointers
	add		hl, de					; set carry with streams 4 to 15
	jr		c, close_1				; jump if carry set
	ld		bc, init_strm + 14		; address table
	add		hl, bc					; find entry
	ld		c, (hl)					; address
	inc		hl						; to
	ld		b, (hl)					; BC

org 0x16fc
close_1:
	ex		de, hl					; swap pointers
	ld		(hl), c					; close streams 4 to 15
	inc		hl						; or set initial values
	ld		(hl), b					; for streams 0 to 3
	ret								; end of subroutine

; THE 'CLOSE-2' SUBROUTINE
org 0x1701
close_2:
	push	hl						; stack stream data address
	ld		hl, (chans)				; base address of channel to HL
	add		hl, bc					; channel address
	inc		hl						; skip past
	inc		hl						; output and
	inc		hl						; input routines
	ld		c, (hl)					; channel letter to C
	ex		de, hl					; swap pointers
	ld		hl, cl_str_lu			; address lookup table
	call	indexer					; get offset
	ld		c, (hl)					; offset to BC
	jr		close_4					; immediate jump

org 0x1714
close_3:
	add		hl, bc					; jump to appropriate
	jp		(hl)					; close routine

org 0x1716
close_4:
	ld		b, 0					; clear B
	jr		c, close_3				; jump with valid address
	rst		error					; else
	defb	Bad_stream				; error

org 0x171c
	defs	2, 255					; unused locations (common)

; THE 'STREAM DATA' SUBROUTINE
org 0x171e
str_data:
	call	find_int1				; get stream number
	cp		16						; in range (0 to 15)?
	jr		c, str_data1			; jump if so

org 0x1725
report_o2:
	rst		error					; else
	defb	Bad_stream				; error

org 0x1727
str_data1:
	add		a, 3					; adjust (3 to 18)
	rlca							; range  (6 to 36)
	ld		hl, strms				; base address of streams
	ld		b, 0					; clear B
	ld		c, a					; offset to BC
	add		hl, bc					; stream address to HL
	ld		c, (hl)					; data
	inc		hl						; bytes
	ld		b, (hl)					; to BC
	dec		hl						; point to first data byte
	ret								; end of subroutine

; THE 'OPEN' COMMAND ROUTINE
org 0x1736
open:
	fwait							; enter calculator
	fxch							; swap stream number and channel code
	fce								; exit calculator
	call	str_data				; get stream data
	ld		a, c					; stream
	or		b						; closed?
	jr		z, open_1				; jump if so
	ex		de, hl					; swap pointers
	ld		hl, (chans)				; base address of channel
	add		hl, bc					; channel address to HL
	inc		hl						; skip to
	inc		hl						; channel
	inc		hl						; letter
	ld		a, (hl)					; put it in A
	ex		de, hl					; swap pointers
	cp		'K'						; keyboard?
	jr		z, open_1				; jump if so
	cp		'S'						; screen?
	jr		z, open_1				; jump if so
	cp		'R'						; work space?
	jr		nz, report_o2			; error if not

org 0x1756
open_1:
	call	open_2					; channel address to DE
	ld		(hl), e					; store it
	inc		hl						; in 
	ld		(hl), d					; stream
	ret								; and return

org 0x175d
open_2:
	push	hl						; stack HL
	call	stk_fetch				; get parameters
	ld		a, c					; letter
	or		b						; provided?
	jr		nz, open_3				; jump if so

org 0x1765
report_f:
	rst		error					; else
	defb	Bad_filename			; error

org 0x1767
open_3:
	push	bc						; stack length
	ld		a, (de)					; get first character
	and		%11011111				; make upper case
	ld		c, a					; store in C
	ld		hl, op_str_lu			; address look up table
	call	indexer					; get offset
	jr		nc, report_f			; error if not found
	ld		b, 0					; clear B
	ld		c, (hl)					; offset to BC
	add		hl, bc					; real address to HL
	pop		bc						; unstack length
	jp		(hl)					; immediate jump

; THE 'OPEN STREAM LOOK-UP' TABLE
org 0x177a
op_str_lu:
	defb	'K', open_k - $			; keyboard
	defb	'S', open_s - $			; screen
	defb	'R', open_r - $			; work space
	defb	0						; end marker

; THE 'OPEN-K' SUBROUTINE
org 0x1781
open_k:
	ld		e, 1					; data bytes 1, 0
	jr		open_end				; immediate jump

; THE 'OPEN-S' SUBROUTINE
org 0x1785
open_s:
	ld		e, 6					; data bytes 6, 0
	jr		open_end				; immediate jump

; THE 'OPEN-R' SUBROUTINE
org 0x1789
open_r:
	ld		e, 11					; data bytes 11, 0

org 0x178b
open_end:
	dec		bc						; reduce length
	ld		a, c					; single
	or		b						; character?
	jr		nz, report_f			; error if not
	ld		d, a					; clear D
	pop		hl						; unstack HL
	ret								; end of subroutine

; THE 'INTERFACE I' ENTRY POINT
org 0x1793
report_o3:
	rst		error					; report
	defb	Bad_stream				; error

; THE 'CLOSE' COMMAND ROUTINE (CONTINUED)
org 0x1795
close_0:
	ld		d, a					; store stream in D
	ld		a, c					; stream
	or		b						; open?
	ld		a, d					; restore stream to A
	jp		nz, close_2				; jump if open
	rst		error					; else
	defb	Bad_stream				; error

; THE 'LIST' COMMAND ROUTINES
org 0x179e
auto_list:
	ld		(iy + _vdu_flag), 16	; signal automatic listing
	ld		(list_sp), sp			; store stack pointer
	call	cl_all					; clear main screen
	ld		b, (iy + _df_sz)		; lower screen display file size
	set		0, (iy + _vdu_flag)		; signal lower screen
	call	cl_line					; clear lower screen
	res		0, (iy + _vdu_flag)		; signal main screen
	set		0, (iy + _flags2)		; signal screen clear
	ld		de, (s_top)				; automatic line number to DE
	ld		hl, (e_ppc)				; current line number to HL
	and		a						; prepare for subtraction
	sbc		hl, de					; current line number less than automatic?
	add		hl, de					; restore current line number
	jr		c, auto_l_2				; jump to update automatic number
	push	de						; stack automatic number
	call	set_7					; set 7-bit ASCII and get line address
	ld		de, 0x02c0				; start of current line
	ex		de, hl					; swap pointers
	sbc		hl, de					; estimate address
	ex		(sp), hl				; result to stack
	call	line_addr				; get line address
	pop		bc						; unstack result

org 0x17d7
auto_l_1:
	push	bc						; stack result
	call	next_one				; address of next line
	pop		bc						; unstack result
	add		hl, bc					; finished?
	jr		c, auto_l_3				; jump if so
	ex		de, hl					; swap pointers
	ld		d, (hl)					; get line
	inc		hl						; number
	ld		e, (hl)					; in DE
	dec		hl						; decrease pointer
	ld		(s_top), de				; store line number in s-top
	jr		auto_l_1				; immediate jump

org 0x17ea
auto_l_2:
	ld		(s_top), hl				; store line number in s-top

org 0x17ed
auto_l_3:
	ld		hl, (s_top)				; get line number
	call	line_addr				; get address
	jr		z, auto_l_4				; jump if found
	ex		de, hl					; else use DE

org 0x17f6
auto_l_4:
	ld		e, 1					; signal before current line

org 0x17f8
auto_l_5:
	call	out_line				; print whole BASIC line
	rst		print_a					; print carriage return
	ld		a, (df_sz)				; still room
	sub		(iy + _s_posn_h)		; on screen?
	jr		nz, auto_l_5			; jump if so
	xor		e						; current line printed?
	jr		z, auto_l_6				; jump if so
	push	de						; stack both
	push	hl						; pointers
	ld		hl, s_top				; address s-top
	call	ln_fetch				; get next line
	pop		hl						; unstack both
	pop		de						; pointers
	jr		auto_l_5				; loop until done

org 0x1813
auto_l_6:
	res		4, (iy + _vdu_flag)		; signal automatic listing finished 
	ret								; end of subroutine

; THE 'LIST' ENTRY POINT
org 0x1818
list:
	ld		a, 2					; use stream 2 
	ld		(iy + _vdu_flag), 0		; signal normal listing
	call	syntax_z				; checking syntax?
	call	nz, chan_open			; open channel if not
	rst		get_char				; get character
	call	str_alter				; change stream?
	jr		c, list_1				; jump if unchanged	
	rst		get_char				; current character
	cp		';'						; semi-colon?
	jr		nz, list_8				; jump if not
	rst		next_char				; next character

org 0x1830
list_1:
	rst		get_char				; current character
	cp		':'						; colon?
	jr		z, list_8				; jump if end of statement
	cp		ctrl_enter				; carriage return?
	jr		z, list_8				; jump if end of statement
	cp		','						; comma?
	jr		z, list_2				; jump with preceding stream
	call	expt_1num				; expecting a number
	jr		list_3					; immediate jump

org 0x1842
list_2:
	call	use_zero				; default start at zero
	rst		get_char				; get current character

org 0x1846
list_3:
	cp		','						; comma?
	jr		nz, list_5				; jump if not
	rst		next_char				; get next character
	call	fetch_num				; get number
	call	check_end				; check end of statement
	call	find_line				; line number to BC
	ld		a, c					; test
	or		b						; for zero
	jr		nz, list_4				; jump if not
	ld		bc, 16384				; range limit

org 0x185b
list_4:
	ld		(t_addr), bc			; 16384 to t_addr
	call	find_line				; line number to BC
	ld		(strlen),bc				; value to strlen
	jr		list_6					; immediate jump

org 0x1868
list_5:
	call	check_end				; end of line?
	call	find_line				; line number to BC
	ld		(strlen), bc			; store it in strlen
	ld		(t_addr), bc			; and t-addr

org 0x1876
list_6:
	ld		hl, (strlen)			; strlen to HL
	ld		(e_ppc), hl				; strlent to e_ppc
	call	set_7					; to line_addr

org 0x187f
list_7:
	ld		de, 0					; clear DE
	call	out_line				; print a BASIC line
	rst		print_a 				; print carriage return
	ld		bc, (t_addr)			; restore current line
	call	cp_lines				; compare it
	jr		c, list_7				; loop
	jr		z, list_7				; until
	ret								; done

org 0x1892
list_8:
	call	check_end				; end of line
	ld		bc, 16383				; maximum line number
	ld		(t_addr), bc			; store it in t-addr
	ld		bc, 0					; clear BC
	ld		(strlen), bc			; store it in strlen
	jr		list_6					; immediate jump

; THE 'PRINT A WHOLE BASIC LINE' SUBROUTINE
org 0x18a5
out_line:
	ld		e, 0					; LD DE, 0
	rl		e						; E to 1 for curent line, 0 for next line
	ld		(iy + _breg), e			; store line marker
	ld		a, (hl)					; most significant byte of line number to A
	cp		64						; in range? (0 to 16383)
	pop		bc						; unstack BC
	ret		nc						; return if listing finished
	push	bc						; stack BC
	call	out_num_2				; print line number with leading spaces
	inc		hl						; point to
	inc		hl						; first
	inc		hl						; command
	jr		out_line3				; immediate jump

org 0x18ba
out_line2:
	set		0, (iy + _flags)		; suppress leading space

org 0x18be
out_line3:
	push	de						; stack DE
	ex		de, hl					; swap pointers

org 0x18c0
out_line4:
	ld		hl, (x_ptr)				; get syntax error
	and		a						; prepare for subtraction
	sbc		hl, de					; error reached? 
	jr		nz, out_line5			; jump if not
	call	play_rasp				; error sound

org 0x18cb
out_line5:
	call	out_curs				; cursor reached?
	ex		de, hl					; swap pointers
	ld		a, (hl)					; character to A
	call	number					; test for hidden number marker
	inc		hl						; next
	cp		ctrl_enter				; carriage return?
	jr		z, out_line6			; jump if so
	ex		de, hl					; swap pointers
	rst		print_a					; print character
	jr		out_line4				; loop until done

org 0x18dc
out_line6:
	pop		de						; unstack DE
	ret								; end of subroutine

; THE 'NUMBER' SUBROUTINE
org 0x18de
number:
	cp		ctrl_number				; hidden number marker?
	ret		nz						; return if not
	inc		hl						; advance pointer six times

org 0x18e2
number_1:
	inc		hl						; called from
	inc		hl						; the EDIT
	inc		hl						; command to
	inc		hl						; advance pointer
	inc		hl						; five times
	ld		a, (hl)					; code to A
	ret								; end of subroutine

; THE 'PRINT THE CURSOR' SUBROUTINE
org 0x18e9
out_curs:
	ld		hl, (k_cur)				; address cursor
	and		a						; correct
	sbc		hl, de					; position?
	ret		nz						; return if not
	ld		a, ' '					; use space as cursor
	exx								; alternate register set
	ld		hl, p_flag				; address p-flag
	ld		d, (hl)					; p-flag to D
	push	de						; stack p-flag
	ld		(hl), 12				; set p-flag to inverse
	call	print_out				; print cursor
	pop		hl						; unstack p-flag to H
	ld		(iy + _p_flag), h		; restore p-flag
	exx								; main register set
	ret								; end of subroutine

; THE 'SPEED' COMMAND ROUTINE
org 0x1903
speed:
	call	find_int1				; get value
	and		%00001111				; discard top four bits
	ld		bc, 0x8e3b				; prism CPU speed select
	out		(c), a					; change speed
	ret								; end of subroutine

org 0x190e
	defs	1, 255					; unused locations (common)

; THE 'LN-FETCH' SUBROUTINE
org 0x190f
ln_fetch:
	ld		e, (hl)					; line
	inc		hl						; number
	ld		d, (hl)					; to DE
	push	hl						; stack pointer (to s-top or e-ppc)
	ex		de, hl					; line number to HL
	inc		hl						; increase line number
	call	line_addr				; get address of line number
	call	line_no					; get line number
	pop		hl						; unstack pointer to system variable

org 0x191c
ln_store:
	bit		5, (iy + _flagx)		; INPUT mode?
	ret		nz						; return if so
	ld		(hl), d					; store line
	dec		hl						; number in 
	ld		(hl), e					; system variable
	ret								; end of subroutine

; THE 'PRINTING CHARACTERS IN A BASIC LINE' SUBROUTINE
org 0x1925
out_sp_2:
	ld		a, e					; space or 255
	and		a						; test it
	ret		m						; return if no space
	rst		print_a					; print a space
	ret								; end of subroutine

org 0x192a
out_sp_no:
	xor		a						; LD A, 0

org 0x192b
out_sp_1:
	add		hl, bc					; trial subtraction
	inc		a						; increase A
	jr		c, out_sp_1				; loop until done
	sbc		hl, bc					; restore HL
	dec		a						; decrease A
	jr		z, out_sp_2				; jump if no subtraction possible
	jp		out_code				; immediate jump

; THE 'ON ERROR' COMMAND ROUTINE
org 0x1937
on_error:
	rst		get_char				; first character
	cp		tk_goto					; GOTO?
	jr		z, on_err_goto			; jump if so
	cp		tk_continue				; CONTINUE?
	jr		z, on_err_cont			; jump if so
	cp		tk_stop					; STOP?
	jr		z, on_err_stop			; jump if so
	rst		error					; else
	defb	Syntax_error			; error

org 0x1946
on_err_goto:
	rst		next_char				; next character
	call	expt_1num				; expect number
	call	check_end				; expect end of line
	call	find_line				; get line number
	call	syntax_z				; checking syntax?
	ret		z						; return if so
	ld		(onerrflag), bc			; set on error address
	ret								; done

org 0x1959
on_err_cont:
	rst		next_char				; next character
	call	check_end				; expect end of line
	call	syntax_z				; checking syntax?
	ret		z						; return if so
	ld		a, 0xfe					; signal on err continue

org 0x1963
on_err_exit:
	ld		(onerrflag_h), a		; set on err flag
	ret								; end of subroutine

org 0x1967
on_err_stop:
	call	on_err_cont				; expect end of line
	ret		z						; return if checking syntax
	inc		a						; signal on err stop
	jr		on_err_exit				; immediate jump

; THE 'LINE-ADDR' SUBROUTINE
org 0x196e
line_addr:
	push	hl						; stack line number
	ld		hl, (prog)				; prog to HL
	ld		d, h					; HL to
	ld		e, l					; DE

org 0x1974
line_ad_1:
	pop		bc						; unstack line number in BC
	call	cp_lines				; compare with addressed line
	ret		nc						; return if carry clear
	push	bc						; stack line number
	call	next_one				; address next line
	ex		de, hl					; swap pointers
	jr		line_ad_1				; immediate jump

; THE 'COMPARE LINE NUMBERS' SUBROUTINE
org 0x1980
cp_lines:
	ld		a, (hl)					; high byte of addressed number to A
	cp		b						; compare with B
	ret		nz						; return if no match
	inc		hl						; address low byte
	ld		a, (hl)					; low byte to A
	dec		hl						; restore pointer
	cp		c						; compare with C
	ret								; end of subroutine

org 0x1988
	defs	3, 255					; unused locations (common)

; THE 'FIND EACH STATEMENT' SUBROUTINE
org 0x198b
each_stmt:
	ld		(ch_add), hl			; set ch-add
	ld		c, 0					; signal quotes off

org 0x1990
each_s_1:
	dec		d						; statement found?
	ret		z						; return if so
	rst		next_char				; next character
	cp		e						; token match?
	jr		nz, each_s_3			; jump if not
	and		a						; else clear zero and carry flags
	ret								; and return

org 0x1998
each_s_2:
	inc		hl						; increase pointer
	ld		a, (hl)					; next code to A

org 0x199a
each_s_3:
	call	number					; skip numbers
	ld		(ch_add), hl			; update ch-add
	cp		'"'						; quote?
	jr		nz, each_s_4			; jump if not
	dec		c						; signal quotes on

org 0x19a5
each_s_4:
	cp		':'						; colon?
	jr		z, each_s_5				; jump if so
	cp		tk_then					; THEN?
	jr		nz, each_s_6			; jump if not

org 0x19ad
each_s_5:
	bit		0, c 					; test quotes flag
	jr		z, each_s_1				; jump at statement end

org 0x19b1
each_s_6:
	cp		ctrl_enter				; carriage return?
	jr		nz, each_s_2			; jump if not
	dec		d						; decrease statement counter
	scf								; set carry flag
	ret								; end of subroutine

; THE 'NEXT-ONE' SUBROUTINE
org 0x19b8
next_one:
	push	hl						; stack address
	ld		a, (hl)					; first byte to A
	cp		64						; next line?
	jr		c, next_o_3				; jump if so
	bit		5, a					; next string or array variable?
	jr		z, next_o_4				; jump if so
	add		a, a					; FOR-NEXT variable?
	jp		m, next_o_1				; jump if so
	ccf								; else long name variable

org 0x19c7
next_o_1:
	ld		bc, 5					; five locations required
	jr		nc, next_o_2			; jump if not FOR-NEXT
	ld		c, 18					; else 18 locations required

org 0x19ce
next_o_2:
	rla								; clear carry for long name variables
	inc		hl						; increase pointer
	ld		a, (hl)					; get character
	jr		nc, next_o_2			; loop unless last character
	jr		next_o_5				; immediate jump

org 0x19d5
next_o_3:
	inc		hl						; skip low byte

org 0x19d6
next_o_4:
	inc		hl						; skip high byte
	ld		c, (hl)					; length
	inc		hl						; to
	ld		b, (hl)					; BC
	inc		hl						; advance pointer

org 0x19db
next_o_5:
	add		hl, bc					; point to first byte of next item
	pop		de						; unstack address of previous item

; THE 'DIFFERENCE' SUBROUTINE
org 0x19dd
differ:
	and		a						; prepare for subtraction
	sbc		hl, de					; get length
	ld		b, h					; length
	ld		c, l					; to BC
	add		hl, de					; restore HL
	ex		de, hl					; swap pointers
	ret								; end of subroutine

; THE 'RECLAIMING' SUBROUTINE
org 0x19e5
reclaim_1:
	call	differ					; get required values in HL and BC

org 0x19e8
reclaim_2:
	push	bc						; stack number of bytes to reclaim
	ld		a, b					; B to A
	cpl								; one's complement
	ld		b, a					; A to B
	ld		a, c					; C to A
	cpl								; one's complement
	ld		c, a					; A to C
	inc		bc						; two's complement
	call	pointers				; get pointers
	ex		de, hl					; swap pointers
	pop		hl						; unstack bytes to reclaim
	add		hl, de					; address to HL
	push	de						; stack first location
	ldir							; reclaim bytes
	pop		hl						; unstack first location
	ret								; end of subroutine

; THE 'E-LINE-NO' SUBROUTINE
org 0x19fb
e_line_no:
	ld		hl, (e_line)			; pointer to edit line
	dec		hl						; move ch-add back
	ld		(ch_add), hl			; one character
	rst		next_char				; get next code
	ld		hl, membot				; address membot
	ld		(stkend), hl			; use membot as temporary stack
	call	numeric					; test for digit
	call	e_l_0					; read digits
	call	fp_to_bc				; number from temporary stack to BC
	jr		c, e_l_1				; error if overflow
	ld		hl, 16384				; line range  is 0 to 16383
	add		hl, bc					; add to line number in BC

org 0x1a18
e_l_1:
	jp		c, report_c				; error if overflow
	jp		set_stk					; else immediate jump

org 0x1a1e
	defs	4, 255					; unused locations (common)

; THE 'REPORT AND LINE NUMBER PRINTING' SUBROUTINE
org 0x1a22
out_num_1:
	push	de						; stack DE
	push	hl						; and HL
	xor		a						; LD A, 0
	bit		7, b					; edit line?
	jr		nz, out_num_5			; jump if so
	ld		h, b					; BC
	ld		l, c					; to HL
	ld		e, 255					; signal no leading spaces
	jr		out_num_3				; immediate jump

org 0x1a2f
out_num_2:
	push	de						; stack DE
	ld		d, (hl)					; number
	inc		hl						; to 
	ld		e, (hl)					; DE
	push	hl						; stack HL
	ex		de, hl					; number to HL
	ld		e, ' '					; leading space

org 0x1a37
out_num_3:
	ld		bc, -10000				; fist digit
	call	out_sp_no				; print it
	ld		bc, -1000				; second digit
	call	out_sp_no				; print it

org 0x1a43
out_num_4:
	ld		bc, -100				; third digit
	call	out_sp_no				; print it
	ld		c, -10					; fourth digit
	call	out_sp_no				; print it
	ld		a, l					; fifth digit

org 0x1a4f
out_num_5:
	call	out_code				; print it
	pop		hl						; unstack HL
	pop		de						; and DE
	ret								; end of subroutine
