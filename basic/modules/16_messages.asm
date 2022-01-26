;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2022 Source Solutions, Inc.

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

;	// --- MESSAGES ------------------------------------------------------------
;	// A total of 576 bytes are allocated for localized messages

    org $5970

;	// used in 06_screen_80
scrl_mssg:
	defb "Scroll?", 0;

;	// padding for translation
	org scrl_mssg + 12

sp_in_sp:
	defb " in ", 0;

ready:
	defb "Ready", 0;

;	// padding for localization
	org ready + 13

;	// used in 08_executive
rpt_mesgs:
	defb "Ok", 0;						// code 255
	defb "Break", 0;					// code 0
	defb "NEXT without FOR", 0;			// code 1
	defb "Syntax error", 0;				// code 2
	defb "RETURN without GOSUB", 0;		// code 3
	defb "Out of DATA", 0;				// code 4
	defb "Illegal function call", 0;	// code 5
	defb "Overflow", 0;+				// code 6
	defb "Out of memory", 0;			// code 7
	defb "Undefined line number", 0;	// code 8
	defb "Subscript out of range", 0;	// code 9
	defb "Undefined variable", 0;		// no equivalent
	defb "Address out of range", 0;		// no equivalent
	defb "Statement missing", 0;		// no equivalent
	defb "Type mismatch", 0;			// code 13
	defb "Out of screen", 0;			// no equivalent
	defb "Bad I/O device", 0;			// no equivalent
	defb "Undefined stream", 0;			// no equivalent
	defb "Undefined channel", 0;		// no equivalent
	defb "Undefined user function", 0;	// code 18
	defb "Line buffer overflow", 0;		// code 23
	defb "FOR without NEXT", 0;			// code 26
	defb "File not found", 0;			// code 53
	defb "Input past end", 0;			// code 62
	defb "Path not found", 0;			// code 76
