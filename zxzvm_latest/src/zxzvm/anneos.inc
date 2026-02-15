
; ****************************************************************************
; *									     *
; *	       		  CONSTOS.Z80  d2.76  5/7/96			     *
; *									     *
; ****************************************************************************

; [JCE] adapted for z80asm assembler 14-3-1998
;
; This is for use OUTSIDE the OS.


constos	equ	$

; HARD-CODED VARIABLES ...

FA		equ	040Eh
FA2		equ	041Ch
FA3		equ	0422h



appid_dt	equ	0100h
appid_wp	equ	0101h
appid_ss	equ	0102h
appid_ab	equ	0103h
appid_da	equ	0104h
appid_cc	equ	0105h
appid_fm	equ	0106h
appid_ex	equ	0107h

id_times	equ	0100h
id_swiss	equ	0101h



_floppy		equ	1
_flash		equ	2

_read		equ	0
_write		equ	1




floats_in_os	equ	1


os_call		equ	3Bh

; list of OS call RB's grepped out of ANNE.Z80...

	include annecall.inc




xp_end			equ	0
xp_cold			equ	1
xp_continue		equ	2
xp_new			equ	3
xp_edit			equ	4
xp_print		equ	5
xp_calc			equ	6
xp_abrec		equ	7
xp_abID			equ	8
xp_abIDlist		equ	9
xp_dapam		equ	10
xp_wpinit		equ	11





ob_box			equ	1
ob_label		equ	2
ob_textbutton		equ	3
ob_bmpbutton		equ	4
ob_dropbutton		equ	5
ob_checkbox		equ	6
ob_radio		equ	7
ob_textedit		equ	8
ob_list			equ	9
ob_listmulti		equ	10
ob_vscroll		equ	11
ob_hscroll		equ	12
ob_spinner		equ	13


;obev_movein		equ	1
;obev_moveout		equ	2
obev_click		equ	1
obev_dclick		equ	2
obev_key		equ	3
obev_curup		equ	4
obev_curdn		equ	5
obev_curhome		equ	6
obev_curend		equ	7
obev_curpgup		equ	8
obev_curpgdn		equ	9
obev_focup		equ	10
obev_focdn		equ	11
obev_focfire		equ	12
obev_clickout		equ	13







dg_blk_white		equ	1
dg_blk_black		equ	2
dg_blk_grey		equ	3
dg_blk_grey_xor		equ	4
dg_blk_hilite		equ	5
dg_blk_move		equ	6
dg_blk_skewmove		equ	7
dg_blk_skewwhite	equ	8
dg_blk_skewlite		equ	9
dg_blk_copy		equ	10
dg_blk_scroll		equ	11
dg_blk_get		equ	12
dg_blk_put		equ	13
dg_multi_box		equ	14
dg_alert_box		equ	15
dg_dialog_box		equ	16

dg_box			equ	17
dg_label		equ	18
dg_textbutton		equ	19
dg_bmpbutton		equ	20
dg_greybutton		equ	21
dg_dropbutton		equ	22
dg_checkbox		equ	23
dg_radio		equ	24
dg_textedit		equ	25
dg_list			equ	26
dg_listmulti		equ	27
dg_vscroll		equ	28
dg_hscroll		equ	29
dg_spinner		equ	30

max_dgpars		equ	1+8+24+65

					;max param bytes for os_scr_direct
					; - max needed by dg_textedit
					;		  (1 for dg_code
					;		   8 for x,y,w,h
					;		  24 for paramblk
					;		 +65 for text incl 0)





om_topbar	equ	1
om_alarm	equ	2
om_prscreen	equ	3
om_objevent	equ	4
om_exit		equ	5








os_float_nop            equ	0
os_float_ten		equ	1
os_float_two            equ	2
os_float_one            equ	3
os_float_zero		equ	4
os_float_half           equ	5
os_float_quarter        equ	6
os_float_pi             equ	7
os_float_half_pi        equ	8
os_float_e              equ	9
os_float_rand           equ	10

os_float_minus          equ	11
os_float_add_half       equ	12
os_float_mul10          equ	13
os_float_div10          equ	14
os_float_ceiling        equ	15
os_float_floor          equ	16
os_float_sqrt           equ	17
os_float_sin            equ	18
os_float_cos            equ	19
os_float_tan            equ	20
os_float_sinh           equ	21
os_float_cosh           equ	22
os_float_tanh           equ	23
os_float_log10          equ	24
os_float_log            equ     25
os_float_asin           equ     26
os_float_acos           equ     27
os_float_atan           equ     28
os_float_asinh          equ     29
os_float_acosh          equ     30
os_float_atanh          equ     31
os_float_exp            equ     32

os_float_add            equ	33
os_float_sub            equ	34
os_float_mul            equ	35
os_float_div            equ	36
os_float_mod            equ	37
os_float_pow            equ	38
os_float_compare        equ	39
os_float_min            equ	40
os_float_max            equ	41

os_float_cmp_ge		equ	42
os_float_cmp_gt		equ	43
os_float_cmp_le		equ	44
os_float_cmp_lt		equ	45
os_float_cmp_eq		equ	46
os_float_cmp_ne		equ	47

os_float_float          equ	48
os_float_int            equ	49
os_float_sgn            equ	50
os_float_rand_seed      equ	51
;
; Errors that can be returned from the floating point
; routines.
e_overflow              equ     1
e_div_zero              equ     2
e_unknown_function      equ     3
e_illegal_sqrt          equ     4
e_too_long		equ	5	; float_to_ascii only







ddc_grey		equ	8	;ddc = 'drop-down-code'
ddc_tked		equ	4	;
ddc_tkbl		equ	2	;

ul_code			equ	1Fh	;
tab_code		equ	09h	;

menubar_y	equ	2
menubar_x	equ	6
menubar_h	equ	17

helpbar_h	equ	22

dia_textfont	equ	7
dia_buttonfont	equ	6
dia_titlefont	equ	8
dia_tith	equ	24

maxfonts	equ	10		;max no of FNFs in Flash
no_of_ptszs	equ	10		;no of ptszs defined in FNFs (6,8,10,11,12,14,18,24,36,72)
tf_listln 	equ	37
tf_chars	equ	192
tf_slots	equ	21

baseyear	equ	1980

max_stripewidth	equ	400		;max width in bytes of printer stripes


bios_jumpblock		equ	80h	; call this + (func * 3)

; In case anyone wants it, this macro allows:
;
;	bcall	bios_mouson
; or	bcall	nc,bios_mouson
;
;bcall	MACRO
;
;    IF	narg=1
;	call	bios_jumpblock+(3*\1)
;    ELSE
;	call	\1,bios_jumpblock+(3*\2)
;    ENDIF
;
;	ENDM
;
;
;bjump	MACRO
;
;    IF	narg=1
;	jp	bios_jumpblock+(3*\1)
;    ELSE
;	jp	\1,bios_jumpblock+(3*\2)
;    ENDIF
;
;	ENDM


bios_restart		equ	0	;
bios_getkey		equ	1	;
bios_putkey		equ	2	;
bios_keystate		equ	3	;
bios_setleds		equ	4	;
bios_getleds		equ	5	;
bios_setrate		equ	6	;
bios_mousoff		equ	7	;
bios_mouson		equ	8	;
bios_getmsxy		equ	9	;
bios_setmsxy		equ	10	;
bios_getmsbt		equ	11	;
bios_msupdate		equ	12	;
bios_setmsptr		equ	13	;
bios_getmsptr		equ	14	;
bios_defmsptr		equ	15	;
bios_gettime		equ	16	;
bios_settime		equ	17	;
bios_getdate		equ	18	;
bios_setdate		equ	19	;

;bios_setmem0				;!! DO NOT USE !!
;			equ	20

bios_setmem1		equ	21	;
bios_setmem2		equ	22	;
bios_setmem3		equ	23	;
bios_getmem0		equ	24	;
bios_getmem1		equ	25	;
bios_getmem2		equ	26	;
bios_getmem3		equ	27	;
bios_di			equ	28	;
bios_ei			equ	29	;
bios_gi			equ	30	;
bios_clrscrn		equ	31	;
bios_setink		equ	32	;
bios_getink		equ	33	;
bios_setmode		equ	34	;
bios_getmode		equ	35	;
bios_setpatt		equ	36	;
bios_getpatt		equ	37	;
bios_pixel		equ	38	;
bios_getpxl		equ	39	;
bios_line		equ	40	;
bios_rectang		equ	41	;
bios_block		equ	42	;
bios_patblock		equ	43	;
bios_storebitmap	equ	44	;
bios_restorebitmap	equ	45	;
bios_plotbitmap		equ	46	;
bios_plotmaskedbitmap	equ	47	;
bios_plotmaskvari	equ	48	;
bios_getbitmap		equ	49	;
bios_bitmapinfo		equ	50	;
bios_setfont		equ	51	;
bios_getfont		equ	52	;
bios_setalign		equ	53	;
bios_getalign		equ	54	;
bios_string		equ	55	;
bios_putchar		equ	56	;
bios_clipstring		equ	57	;
bios_diskio		equ	58	;
bios_intserve		equ	59	;
bios_intkill		equ	60	;
bios_printbyte		equ	61	;
bios_printstring	equ	62	;



