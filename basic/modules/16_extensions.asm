;	// SE Basic IV 4.3 Drusilla
;	// Copyright (c) 1999-2026 Source Solutions, Inc.

;	// SE Basic IV is free software: you can redistribute it and/or modify
;	// it under the terms of the GNU General Public License as published by
;	// the Free Software Foundation, either version 3 of the License, or
;	// (at your option) any later version.
;	// 
;	// SE Basic IV is distributed in the hope that it will be useful,
;	// but WITHOUT ANY WARRANTY; without even the implied warranty o;
;	// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;	// GNU General Public License for more details.
;	// 
;	// You should have received a copy of the GNU General Public License
;	// along with SE Basic IV. If not, see <http://www.gnu.org/licenses/>.

;	// addresses $3d00 to $3fff are trapped by the divIDE / divMMC hardware
;	// these addresses must not contain code or when the PC is in this range, paging will take place.

;;
;	// --- EXTENDED BASIC COMMANDS ---------------------------------------------
;;

;	// --- Extended command handler ---
ext_cmd_handler:
    rst next_char						// skip underscore
    call page_shadow_ram				// page in lower 16K shadow RAM
    call find_ext_cmd					// find routine address for token
    jp nc, report_syntax_err			// error if not found
    call call_ext_cmd					// call routine
;    call page_in_rom					// restore ROM
    jp stmt_ret							// return to statement loop

;	// --- Page RAM in ROM area ---
page_shadow_ram:
    ; [in production this will page RAM in the lower 16K which is pre-loaded ]
	ld hl, ext_cmd_tbl;
    ret;

;	// --- Find extended command ---
find_ext_cmd:
    ; HL = pointer to token table in RAM (ext_cmd_table)
    ; DE = pointer to BASIC code (token after '_')
    ; On success: HL = routine address, CF set
    ; On fail: CF clear
    push de
    ld bc, 0                ; BC = command index
find_ext_loop:
    ld a, (hl)              ; Get next char from table
    or a                    ; End of table?
    jr z, find_ext_fail     ; If zero, not found
    push hl                 ; Save HL (start of token)
    push de                 ; Save DE (start of BASIC token)
    ; Compare token after _ with table token
find_ext_cmp:
    ld a, (hl)
    ld c, a
    ld a, (de)
    cp c
    jr nz, find_ext_next    ; If not equal, try next
    ; Check for end of token (high bit set)
    bit 7, c
    jr z, find_ext_cmp_cont
    ; Found match
    pop de                  ; Restore DE
    pop hl                  ; Restore HL
    scf                     ; Set carry (found)
    pop de                  ; Restore DE
    ret
find_ext_cmp_cont:
    inc hl
    inc de
    jr find_ext_cmp
find_ext_next:
    pop de                  ; Restore DE
    pop hl                  ; Restore HL
    ; Skip to next token
find_ext_skip:
    ld a, (hl)
    bit 7, a
    jr z, find_ext_skip_cont
    inc hl
    inc bc                  ; Next command index
    jr find_ext_loop
find_ext_skip_cont:
    inc hl
    jr find_ext_skip
find_ext_fail:
    pop de                  ; Restore DE
    or a                    ; Clear carry
    ret

;	// --- Call extended command ---
call_ext_cmd:
    ; HL = routine address
    jp (hl)
;    ret
// ...existing code...


;	// Extended commands table
ext_cmd_tbl:
	str "BIP";
	str "RESET";
	defb 0;

ext_offset_tbl:
	defw x_beep
	defw x_reset

; 	// parameter table
x_beep:
	defb no_f_ops;
	defw c_beep;

x_reset:
	defb no_f_ops;
	defw c_reset;

;	// Extended commands

c_reset:
	rst 0;							// reset the system
