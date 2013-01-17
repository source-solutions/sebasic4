; COPY command for the ZX Printer

org 65446

copy:
	di
	ld		b, 192
	ld		hl, 16384

copy_1:
	push	hl
	push	bc
	call	copy_line
	pop		bc
	pop		hl
	inc		h
	ld		a, h
	and		7
	jr		nz, copy_2
	ld		a, l
	add		a, 32
	ld		l, a
	ccf
	sbc		a, a
	and		-8
	add		a, h

	ld		h, a

copy_2:
	djnz	copy_1

copy_end:
	ld		a, 4
	out		(0xfb), a
	ei
	ret

copy_line:
	ld		a, b
	cp		3
	sbc		a, a
	and		2
	out		(0xfb), a
	ld		d, a

copy_l_1:
	call	0x1f54			; break_key
	jr		c, copy_l_2
	ld		a, 4
	out		(0xfb), a
	ei
	rst		8
	defb	0x0c

copy_l_2:
	in 		a, (0xfb)
	add		a, a
	ret		m
	jr		nc, copy_l_1
	ld		c, 32

copy_l_3:
	ld		e, (hl)
	inc		hl
	ld		b, 8

copy_l_4:
	rl		d
	rl		e
	rr		d

copy_l_5:
	in		a, (0xfb)
	rra
	jr		nc, copy_l_5
	ld		a, d
	out		(0xfb), a
	djnz	copy_l_4
	dec		c
	jr		nz, copy_l_3
	ret