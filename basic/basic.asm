;	// SE Basic IV 4.2 Cordelia - A classic BASIC interpreter for the Z80 architecture.
;	// Copyright (c) 1999-2019 Source Solutions, Inc.

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

; 	// This source is compatible with Zeus
;	// (http://www.desdes.com/products/oldfiles)

	include "basic.inc";				// label definitions and X80 instruction set
	zoCheckORG = false;					// report if the ORG statements are moving the PC
	zoWarnFlow = false;					// ignore data
	zoSpectrumFloats = true;			// df stores a float/simple int in 5-byte form

;	// Export program in separate ROM and RAM segments

	output_bin "../bin/basic.rom", 0, $4000;
	output_bin "../boot/basic.bin", $4000, $1bba;
	output_bin "../bin/23.bin", 0, $5bba

;	// modules

	include "modules/01_restarts.asm"
	include "modules/02_tokenizer.asm"
	include "modules/03_keyboard.asm"
	include "modules/04_audio.asm"
	include "modules/05_miscellaneous.asm"
	include "modules/06_screen_80.asm"
	include "modules/07_editor.asm"
	include "modules/08_executive.asm"
	include "modules/09_command.asm"
	include "modules/10_expression.asm"
	include "modules/11_arithmentic.asm"
	include "modules/12_calculator.asm"
	include "modules/13_data.asm"
	include "modules/14_screen_40.asm"
	include "modules/15_files.asm"
