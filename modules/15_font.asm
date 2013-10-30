; --- THE CHARACTER SET -------------------------------------------------------

org 0x3d00
font:
.ifdef ROM0
	incbin	"chloe.bin"				; text mode 80 column font
.endif
.ifdef ROM1
	incbin	"geneva-mono.bin"		; graphics mode 40 column font
.endif
