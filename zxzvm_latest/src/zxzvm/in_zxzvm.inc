
;    ZXZVM: Z-Code interpreter for the Z80 processor
;    Copyright (C) 1998-9,2006,2016  John Elliott <seasip.webmaster@gmail.com>
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;
;System-dependent code for ZXZVM: header file
;
;Entry points for the I/O module:
;
;General principles: Routines marked * will return Carry set if they succeeded
;otherwise Carry clear, with HL = address of fatal error string.
;
;Filenames are terminated by 0FFh (+3DOS API).
;Fatal error strings are terminated by a character with bit 7 set 
;(48BASIC API) and should be short (max. 24 characters).
;Strings passed to ZXFDOS are terminated by '$' (CP/M API)
;
ZXINIT	EQU	ZJT+00h	;*Initialise the I/O subsystem. 
			; DE = 705Ch, address of gamefile name. 
			;      Any data at 705Ch have to be set by the
			;      BASIC loader before ZXZVM is started. 
			;        The PCW16 version ignores DE and asks for the 
			;      game name itself, since PCW16s don't have
			;      command line parameters or BASIC loaders.
ZXEXIT	EQU	ZJT+03h	;If carry set: Deinit I/O subsystem and return.
			;Otherwise terminate program & do not return, 
			;HL = address of fatal error string.
ZXCLS	EQU	ZJT+06h	;*Clear screen
ZXPEEK	EQU	ZJT+09h	;*Read Z-machine address EHL; return result in A. 
			; << New in 1.12: Passes carry set for instruction
			;   fetch, carry clear for data fetch. >>
ZXPOKE	EQU	ZJT+0Ch	;Store A in machine address HL (max 64k writable memory)
ZXPK64	EQU	ZJT+0Fh	;Read Z-machine address HL in the low 64k; return in A.
ZXPKWD	EQU	ZJT+12h	;Read Z-machine word into BC from EHL.
ZXPKWI	EQU	ZJT+15h	;As ZXPKWD, but auto-increments EHL.
ZXFDOS	EQU	ZJT+18h	;*Vaguely CP/M-like functions:
			;  C=1: Wait for character and return it in A. Echo
			;       the character to screen.
			;  C=2: Output character in E
			;  C=6: If E=0FFh: Poll keyboard, return character 
			;                  in A if there is one, else 0.
			;       If E=0FEh: Poll keyboard, return 1 if a
			;                  character is waiting, else 0.
			;       If E=0FDh: Wait for character and return it
			;                  in A. Don't echo it to screen
			;       If E<0FDh: Output character in E
			;  C=9: Output characters at DE until a '$' is 
			;       encountered.
ZXIHDR	EQU	ZJT+1Bh	;*Allow the I/O subsystem to set and clear bytes in
			;the header. The I/O subsystem gets first crack at
			;the header, followed by the main code. Either 
			;module can veto the header.
ZXTMEM	EQU	ZJT+1Eh	;Get top of memory in HL.
ZXERAW	EQU	ZJT+21h	;*Erase_window opcode, parameter in A.
ZXZCHR	EQU	ZJT+24h	;Output a ZSCII character in HL, to stream A. 
			;v0.04 If A=2 (printer) then carry reset on return 
			;         indicates that the printer is offline.
			;>> v0.04
ZXSWND	EQU	ZJT+27h	;*Split_window opcode, parameter in A.
ZXUWND	EQU	ZJT+2Ah	;*Set_window opcode, parameter in A.
ZXSTYL	EQU	ZJT+2Dh	;*Set_text_style opcode, parameter in A.
ZXSCUR	EQU	ZJT+30h	;*Set_cursor opcode, B=row, C=column
ZXINP	EQU	ZJT+33h	;Line input. HL = byte address of buffer in Z-memory
			;DE=timeout, tenths of a second.
			;Returns B=10 for success, 0 for timeout
ZXRCHR	EQU	ZJT+36h	;Read a character. DE=timeout, tenths of second, or 0
			;Returns A=character or 0 for timeout
ZXSCOL	EQU	ZJT+39h	;Set colour. B=foreground C=background, IBM colours
ZXSFNT	EQU	ZJT+3Ch	;Set font. A=font, returns A=old font or 0.
ZXRNDI	EQU	ZJT+3Fh	;Get a random integer (eg the computer's clock) in DE.
ZXGETX	EQU	ZJT+42h	;Get cursor X position in L, characters remaining in H,
			;total screen width in A. Must not change DE.
ZXGETY	EQU	ZJT+45h	;Get cursor Y position in L
ZXSTRM	EQU	ZJT+48h	;*Called when a stream is opened or closed. A = 
			;stream number (+ or -)
ZXERAL	EQU	ZJT+4Bh	;Erase current line to EOL
ZXSND	EQU	ZJT+4Eh	;Sound effect; HL,DE,BC hold the parameters
			;number, effect and volume respectively.
ZXRST	EQU	ZJT+51h	;Restart game
ZXNAME	EQU	ZJT+54h	;Get filename. Enter with A=0 to get "load" filename,
			;1 to get "save" filename. Returns HL = filename ID to
			;pass to create/open routine. ZXZVM will not try to
			;parse this, so it could be a pointer to ASCIIZ, 
			;pointer to FCB etc. Carry set if OK, reset for user
			;cancel.
ZXOPEN	EQU	ZJT+57h	;Open filename in HL. B=mode: 0=read 1=create. 
			;Returns Carry set if OK, clear if error.
			;For simplicity, only one file may be open at 
			;any one time.
ZXCLSE	EQU	ZJT+5Ah	;Close current open file.
ZXREAD	EQU	ZJT+5Dh	;Read BC bytes to HL.
ZXWRIT	EQU	ZJT+60h	;Write BC bytes at HL.
ZXRMEM	EQU	ZJT+63h	;Read BC bytes of Z-machine memory, starting at HL.
ZXWMEM	EQU	ZJT+66h	;Write BC bytes of Z-machine memory, starting at HL.
			;(note: In these last four, BC=0 is valid and 
			; means zero bytes, not 64k)
ZXVRFY	EQU	ZJT+69h	;Checksum the game file. Entered with DBC = game file
			;length; return HL = checksum.
;
;0.02+
;
ZXBFIT	EQU	ZJT+6Ch	;Check if the text in the buffer at HL will fit on
			;the current line. B = no. of letters; C = no. of
			;non-letters. Returns:
			; A=0 : Everything will fit
			; A=1 : Letters will fit, separators won't
			; A=2 : Nothing will fit
ZXRCPU	EQU	ZJT+6Fh	;Called every 2000 z-cycles (approx) - allow a 
			;multitasking OS's message pump to run.
ZXILIV	EQU	ZJT+72h	;Some sort of simple debug breakpoint. This should
			;interfere with the screen as little as possible; the
			;Spectrum implementation changes the border colour and
			;waits for a keypress, and other versions should do
			;something similar.
			;
			;<< v1.01 >> The VM passes EHL = Z-machine program
			;           counter.
ZXVER	EQU	ZJT+75h	;Get module compatibility number into A. Used to
			;check for version mismatches. Current number is 4:
VMVER	EQU	4
;
;0.03+
; 
ZXUSCR	EQU	ZJT+78h	;Flush any screen output buffers in the I/O module.
			;No entry or exit conditions.
