;	// SE Basic IV 4.2 Cordelia - A classic BASIC interpreter for the Z80 architecture.
;	// Copyright (c) 1999-2024 Source Solutions, Inc.

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

; 	// This source is compatible with RASM
;	// (http://www.cpcwiki.eu/forum/programming/rasm-z80-assembler-in-beta/)

	include "basic.inc";				// label definitions and X80 instruction set

;	slam equ 1;							// uncomment to build SLAM+128/divMMC version

;	// export program in separate ROM and RAM segments

	save "../bin/basic.rom", 0, 16384
	save "../boot/basic.bin", 16384, 7168
	save "../bin/23.bin", 0, 23552

;	// modules

	include "modules/01_restarts.asm"
	include "modules/02_tokenizer.asm"
	include "modules/03_keyboard.asm"
	include "modules/04_se-os.asm"
	include "modules/05_preprocessor.asm"
	include "modules/06_screen_0.asm"
	include "modules/07_editor.asm"
	include "modules/08_executive.asm"
	include "modules/09_command.asm"
	include "modules/10_expression.asm"
	include "modules/11_arithmentic.asm"
	include "modules/12_calculator.asm"
	include "modules/13_data.asm"
	include "modules/14_screen_1.asm"
	include "modules/15_files.asm"
	include "modules/16_audio.asm"
	include "modules/standard_mml.asm"
	include "modules/17_messages.asm"
	include "modules/riff_support.asm"

;	// last byte
org $5bb9;
	defb $A0;							// end marker

;	// this will be overwritten with system variables
	defb "The supreme art of war is to subdue the enemy without fighting-Sun Tzu";
