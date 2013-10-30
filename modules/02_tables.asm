; --- THE TABLES --------------------------------------------------------------

; THE TOKEN TABLE
org 0x0ac
token_table:
	incbin	"tokens.txt"			; token definitions

; THE KEY TABLES 
org 0x0239
kt_unshifted:						
	incbin	"kt-unshifted.txt"		; unshifted character definitions

org 0x0260
kt_alphasym:							
	incbin	"kt-alphasym.txt"		; alpha symbol definitions

org 0x027a
kt_numsym:							
	incbin	"kt-numsym.txt"			; numeric symbol definitions

org 0x0284
kt_ctrl:								
	incbin	"kt-ctrl.txt"			; shifted numeric definitions
