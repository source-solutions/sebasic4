; --- THE RESTART ROUTINES ----------------------------------------------------

; THE 'START'
org 0x0000
;start:
	di								; switch off the 50Hz (or 60Hz) interrupt
.ifdef ROM0
	ld		sp, 0					; set stack to top of RAM
	call	cold_start				; deal with initial power on
.endif
.ifdef ROM1
	xor		a						; A = 0
	ld		e, a					; set low byte of DE
	dec		e						; to top of RAM
	jp		test_16k				; clear normal RAM in case of a hard reset
.endif

; THE 'ROM-0 ENTRY' SUBROUTINE
org 0x0007
rom0_entry:
	rst		start					; jump back to start when coming from ROM 0

; THE 'ERROR' RESTART
org 0x0008
;error:
	ld		hl, (ch_add)			; copy address of current character
	ld		(x_ptr), hl				; to error pointer
	jr		error_2					; then jump

; THE 'PRINT A CHARACTER' RESTART
org 0x0010
;print_a:
	jp		print_a_2				; immediate jump

; THE 'REPORT-G' SUBROUTINE
org 0x013
report_g:
	ld		a, No_room_for_line + 1 ; change message
	jp		main_g					; jump back

; THE 'COLLECT CHARACTER' RESTART
org 0x0018
_get_char:
	ld		hl, (ch_add)			; put address of current character
	ld		a, (hl)					; in A

org 0x001c
test_char:
	call	skip_over				; check for printable character
	ret		nc						; return if so

; THE 'COLLECT NEXT CHARACTER' RESTART
org 0x0020
;next_char:
	call	ch_add_plus_1			; increment current character address
	jr		test_char				; then jump

org 0x0025
version:
	defb	"410"					; version number

; THE 'CALCULATOR' RESTART
org 0x0028
calc:
	jp		calculate				; immediate jump

; THE IDENTIFIER STRING
org 0x002b
ident:
	defb	"SE"					; SE BASIC identifier string

; THE 'MAKE BC SPACES' RESTART
org 0x002d
bc_1_space:
	ld		bc, 1					; create one free location in workspace 

org 0x0030
;bc_spaces:
	push	bc						; store number of spaces to create
	ld		hl, (worksp)			; get address of workspace
	push	hl						; and store it
	jp		reserve					; then jump

; THE 'MASKABLE INTERRUPT' ROUTINE
org 0x0038
;mask_int:
	push	hl						; stack HL
	push	af						; stack AF
	ld		hl, frames				; L addresses low byte of frames
	inc		(hl)					; increment lowest byte
	jr		nz, key_int				; jump if no roll over
	inc		l						; L addresses middle byte of frames 
	inc		(hl)					; increment middle byte
	jr		nz, key_int				; jump if no roll over
	inc		l						; L addresses high byte of frames
	inc		(hl)					; increment high byte

org 0x0046
key_int:
	push	de						; stack DE
	push	bc						; stack BC
	call	keyboard				; read keypress
	pop		bc						; unstack BC
	pop		de						; unstack DE
	pop		af						; unstack AF
	pop		hl						; unstack HL
	ei								; switch on interrupts
	ret								; end of maskable interrupt

org 0x0051
initpal:
	defb	0xff, 0x00				; code used as palette data

; THE 'ERROR-2' ROUTINE
org 0x0053
error_2:
	ld		(k_cur), hl				; move cursor to position of error
	pop		hl						; return location holds error number
	ld		l, (hl)					; store in L

org 0x0058
error_3:
	ld		(iy + _err_nr), l		; then copy to err_nr
	ld		sp, (err_sp)			; put value of err_sp in SP
	res		3, (iy + _flags)		; set 7-bit ASCII
	jp		set_stk					; then jump

; THE 'NON-MASKABLE INTERRUPT' ROUTINE
org 0x0066
nmi:
	push	hl						; stack HL
	push	af						; stack AF
	ld		hl, (nmiadd)			; put value of nmiadd in HL
	ld		a, l					; test for
	or		h						; zero
	jr		z, nmi_ret				; return if so

org 0x006f
call_jump:
	jp		(hl)					; jump to address in HL

org 0x0070
nmi_ret:
	pop		af						; unstack AF
	pop		hl						; unstack HL
	retn							; end of non maskable interrupt

; THE 'CH-ADD+1' SUBROUTINE
org 0x0074
ch_add_plus_1:
	ld		hl, (ch_add)			; get current character address

org 0x0077
temp_ptr1:
	inc		hl						; increment it

org 0x0078
temp_ptr2:
	ld		(ch_add), hl			; store it
	ld		a, (hl)					; copy character at current address to A
	ret								; end of ch-add+1 subroutine

; THE 'SKIP-OVER' SUBROUTINE
org 0x007d
skip_over:
	cp		' '						; test for space or higher
	scf								; set carry flag
	ret		z						; and return if so
	cp		24						; test for characters 24-31
	ret		nc						; and return if so with carry cleared
	cp		ctrl_enter				; test for enter
	ret		z						; and return if so
	cp		6						; test for characters 0-5 (tokens)
	ccf								; complement carry flag
	ret		nc						; and return if so
	cp		ctrl_pen				; test for embedded control codes
	ret		c						; and return if so
	inc		hl						; advance a character
	cp		ctrl_at					; test for AT or TAB
	jr		c, skips				; jump if not
	inc		hl						; else advance another character 

org 0x0094
skips:
	scf								; set carry flag
	ld		(ch_add), hl			; put new character address in ch_add
	ret								; end of subroutine

; THE 'MODE SWITCH' SUBROUTINE
org 0x0099
mode_switch:
.ifdef ROM0
	ld		a, 0					; 256x192 mode
	ld		e, 16					; ROM 1, VRAM 0
	ld		hl, 0x0218				; set longer key repeat
.endif
.ifdef ROM1
	ld		a, 62					; 512x192 mode, white on black
	ld		e, %00001000			; ROM 0, VRAM 1, RAM 0
	ld		hl, 0x0208				; set shorter key repeat
.endif
	ld		(repdel), hl			; set key repeat
	ld		bc, paging				; 16-bit I/O
	out		(scld), a				; set video mode
	out		(c), e					; set ROM and VRAM page
	ret								; end of subroutine

	defs	1, 255					; unused locations (common)
