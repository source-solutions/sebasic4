; SE Basic IV "Buffy" Version 4.1.0
; Copyright (c) 1999-2013 Andrew Owen. All rights reserved.

; This program is free software: you can redistribute it and/or modify it under
; the terms of the GNU General Public License as published by the Free Software
; Foundation, either version 2 of the License, or (at your option) any later
; version. This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
; FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
; more details.

; You should have received a copy of the GNU General Public License along with
; this program. If not, see <http://www.gnu.org/licenses/>.

; This software is a fork of OpenSE BASIC 
; <http://sourceforge.net/projects/sebasic/> and contains portions of the
; following GPLv2 licensed software:

; ZX81 ROM by John Grant & Steven Vickers, copyright (c) 1981 Nine Tiles.
; SAM BASIC by Andrew Wright, copyright (c) 1989-1990 BetaSoft.

; This assembly file produces two different ROM files which together make up
; the 32K firmware for the Chloe 280SE (a production ZX Spectrum SE) and the
; Chloe 140SE (a cut down version of the 280SE without the sideways RAM banks).
; ROM0 provides hi-res support while ROM1 supports the normal screen mode.
; ROM1 can be used on its own in ZX Spectrum clones that use a 16K firmware
; or do not support the 280SE text mode. This file has a tab width of four.

; busra.def differences
;printer			equ	0xfb
;
;prt_buff		equ	0x5b00
;
;ctrl_ink		equ	0x10
;ctrl_edit		equ	0x07
;ctrl_graphics	equ	0x0f
;
;tk_lprint		equ	0xe0
;tk_llist		equ	0xe1
;tk_ln			equ	0xb8
;tk_bright		equ	0xdc
;tk_asn			equ	0xb5
;tk_verify		equ	0xd6
;tk_flash		equ	0xdb
;tk_acs			equ	0xb6
;tk_ink			equ	0xd9
;tk_format		equ	0xd0
;tk_move			equ	0xd1
;tk_erase		equ	0xd2
;tk_cat			equ	0xcf
;
;p_posn			equ	coords + 2	; (iy + 0x45)
;pr_cc			equ	p_posn + 1	; (iy + 0x46)
;
;_p_posn			equ	0x45
;_pr_cc			equ	0x46

; ok						equ	0xff
; next_without_for		equ	0x00
; variable_not_found		equ	0x01
; subscript_wrong			equ	0x02
; out_of_memory			equ	0x03
; out_of_screen			equ	0x04
; number_too_big			equ	0x05
; return_without_gosub	equ	0x06
; end_of_file				equ	0x07
; stop_statement			equ	0x08
; invalid_argument		equ	0x09
; Integer_out_of_range	equ	0x0a
; nonsense_in_basic		equ	0x0b
; break_cont_repeats		equ	0x0c
; out_of_data				equ	0x0d
; invalid_file_name		equ	0x0e
; no_room_for_line		equ	0x0f
; stop_in_input			equ	0x10
; for_without_next		equ	0x11
; invalid_io_device		equ	0x12
; invalid_colour			equ	0x13
; break_into_program		equ	0x14
; ramtop_no_good			equ	0x15
; statement_lost			equ	0x16
; invalid_stream			equ	0x17
; fn_without_def			equ	0x18
; parameter_error			equ	0x19
; tape_loading_error		equ	0x1a
; --- end ---


include "01_restarts.asm"
include "02_tables.asm"
include "03_keyboard.asm"
include "04_sound.asm"
include "05_tape.asm"
include "06_screen.asm"

; --- temporary include
;include	"busra.asm"
; --- end ---

include "07_executive.asm"
include "08_command.asm"
include "09_expression.asm"
include "10_arithmetic.asm"
include "11_calculator.asm"
include "12_auxilliary.asm"
include "13_syntax.asm"
include "14_miscellaneous.asm"
include "15_font.asm"
