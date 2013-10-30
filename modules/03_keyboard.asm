; --- THE KEYBOARD ROUTINES ---------------------------------------------------

; safe to ignore overflow warnings at lines 73, 81, 86, 101, 103, and 111

; THE 'KEYBOARD SCANNING' SUBROUTINE
org 0x028e
key_scan:
	ld		bc, 0xfefe				; B = counter, C = port
	ld		de, 0xffff				; set DE to no key
	ld		l, 47					; initial key value

org 0x0296
key_line:
	in		a, (c)					; read ULA
	cpl								; complement A
	and		%00011111				; test for key press
	jr		z, key_done				; jump if not
	ld		h, a					; key bits to H
	ld		a, l					; initial value to L

org 0x029f
key_3keys:
	inc		d						; check for three keys pressed
	ret		nz						; return if so

org 0x02a1
key_bits:
	sub		8						; subtract 8
	srl		h						; from key value
	jr		nc, key_bits			; until bit found
	ld		d, e					; existing key value to D
	ld		e, a					; new key value to E
	jr		nz, key_3keys			; jump if full_addnal keys

org 0x02ab
key_done:
	dec		l						; reduce key value 
	rlc		b						; shift counter
	jr		c, key_line				; jump for remaining key lines
	ld		a, d					; check for single key
	inc		a						; or no key
	ret		z						; return if so
	cp		40						; check for shift + alphanum
	ret		z						; return if so
	cp		25						; check for symbol + alphanum
	ret		z						; return if so
	ld		a, e					; new key value to A
	ld		e, d					; existing key value to E
	ld		d, a					; new key value to D
	cp		24						; check for shift + symbol
	ret								; end of subroutine

; THE 'KEYBOARD' SUBROUTINE
org 0x02bf
keyboard:
	call	key_scan				; get key pair in DE
	ret		nz						; return if no key
	ld		hl, kstate				; kstate_0 to HL

org 0x02c6
k_st_loop:
	bit		7, (hl)					; is set free?
	jr		nz, k_ch_set			; jump if so
	inc		hl						; else
	dec		(hl)					; decrease
	dec		hl						; 5 call
	jr		nz, k_ch_set			; counter
	ld		(hl), 255				; then make set free

org 0x02d1
k_ch_set:
	ld		a, l					; low address to A
	ld		l, kstate_4				; has second set
	cp		l						; been considered? 
	jr		nz, k_st_loop			; jump if not
	call	k_test					; change key to main code
	ret		nc						; return if no key or shift
	ld		hl, kstate				; kstate_0 to HL
	cp		(hl)					; jump if match
	jr		z, k_repeat				; including repeat
	ld		l, kstate_4				; kstate_4 to HL
	cp		(hl)					; jump if match
	jr		z, k_repeat				; including repeat
	bit		7, (hl)					; test second set
	jr		nz, k_new				; jump if free
	ld		l, kstate				; kstate_0 to HL
	bit		7, (hl)					; test first set
	ret		z						; return if not free

org 0x02ef
k_new:
	ld		(hl), a					; code to kstate
	ld		e, a					; code to E
	inc		hl						; 5 call counter
	ld		(hl), 5					; reset to 5
	ld		a, (repdel)				; repeat delay to A
	inc		hl						; HL to kstate2/6
	ld		(hl), a					; store A
	inc		hl						; HL to kstate 3/7
	push	hl						; stack pointer
	ld		l, flags				; HL points to flags
	ld		d, (hl)					; flags to D
	ld		l, mode					; HL points to mode
	ld		c, (hl)					; mode to C
	call	k_meta					; decode with test for meta and control
	pop		hl						; unstack pointer
	ld		(hl), a					; code to kstate 3/7

org 0x0306
k_end:
	ld		l, flags				; HL points to flags
	set		5, (hl)					; signal new key
	ld		(last_k), a				; code to last_k
	ret								; end of subroutine

org 0x030e
	defs	2, 255					; unused locations (common)

; THE 'REPEATING-KEY' SUBROUTINE
org 0x0310
k_repeat:
	inc		hl						; set 5 call counter
	ld		(hl), 5					; to 5
	inc		hl						; point to repdel value
	dec		(hl)					; reduce it
	ret		nz						; return if delay not finished
	ld		a, (repper)				; repeat period to A
	ld		(hl), a					; store it
	inc		hl						; point to kstate3/7
	ld		a, (hl)					; get code
	jr		k_end					; immediate jump

; THE 'K-TEST' SUBROUTINE
org 0x031e
k_test:
	ld		b, d					; copy shift byte
	ld		a, e					; move key number
	ld		d, 0					; clear D register
	cp		39						; shift or no-key?
	ret		nc						; return if so
	cp		24						; test for alternate
	jr		nz, k_main				; jump if not
	bit		7, b					; test for alternate and key
	ret		nz						; return with alternate only

org 0x032c
k_main:
	ld		hl, kt_unshifted		; base of table
	add		hl, de					; get offset
	scf								; signal valid keystroke
	ld		a, (hl)					; get code
	ret								; end of subroutine

; THE 'KEYBOARD DECODING' SUBROUTINE
org 0x0333
k_decode:
	ld		a, e					; copy main code

k_decode_1:
	cp		':'						; jump if digit, return, shift
	jr		c, k_digit				; or alternate
	ld		hl, kt_alphasym - 'A'	; point to alpha symbol table
	bit		0, b					; test for alternate
	jr		z, k_look_up			; jump if so
	ld		hl, flags2				; address flags2
	bit		3, (hl)					; test for caps lock
	jr		z, k_caps				; jump if not
	xor		%00100000				; toggle bit 6

org 0x0348
k_caps:
	inc		b						; test for shift
	ret		nz						; return if not
	xor		%00100000				; toggle bit 6
	ret								; end of subroutine

org 0x034d
k_meta:
	call	k_decode				; get the key in A
	ld		c, (iy + _mode)			; get mode
	ld		(iy + _mode), 0			; set normal mode
	dec		c						; test for meta
	ret		m						; return if normal
	jr		nz, k_control			; jump if control
	set		7, a					; set high bit
	ret								; end of subroutine

org 0x035e
k_control:
	add		a, 79					; CTRL+"A" = UDG A
	ret								; end of subroutine

org 0x0361
k_digit:
	cp		'0'						; digit, return, space, shift, alt?
	ret		c						; return if not
	inc		b						; shift or alternate?
	ret		z						; return if not
	bit		5, b					; shift?
	ld		hl, kt_ctrl - '0'		; set control table
	jr		nz, k_look_up			; jump if shift
	ld		hl, kt_numsym - '0'		; else use symbol table

org 0x0370
k_look_up:
	ld		d, 0					; clear D
	add		hl, de					; index table
	ld		a, (hl)					; get character
	ret								; end of subroutine
