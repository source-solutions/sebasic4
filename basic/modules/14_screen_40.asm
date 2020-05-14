;	// SE Basic IV 4.2 Cordelia
;	// Copyright (c) 1999-2020 Source Solutions, Inc.

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

;	// FRAME BUFFER
;	//
;	// $FFFF +---------------+ 65535
;	//       | font          |
;	// $F800 +---------------+ 63488
;	//       | attributes    |
;	// $E000 +---------------+ 57344
;	//       | palette       |
;	// $DFC0 +---------------+ 57280
;	//       | temp stack    |
;	// $DF80 +---------------+ 57216
;	//       | unused        |
;	// $DBC0 +---------------+ 56256
;	//       | character map |
;	// $D800 +---------------+ 55296
;	//       | bitmap        |
;	// $C000 +---------------+ 49152

;	// 368 BYTES to s40_print_out

;	// WRITE A CHARACTER TO THE SCREEN
;	// There are eight separate routines called based on the first three bits of
;	// the column value.

	org $4800
;	// HL points to the first byte of a character in FONT_1
;	// DE points to the first byte of the block of screen addresses
