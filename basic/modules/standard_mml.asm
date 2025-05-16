;	// StandardMML - Standard Music Macro Language Implementation
;	// Copyright (c) 2024 Source Solutions, Inc.

;	// StandardMML is free software: you can redistribute it and/or modify
;	// it under the terms of the GNU General Public License as published by
;	// the Free Software Foundation, either version 3 of the License, or
;	// (at your option) any later version.
;	// 
;	// StandardMML is distributed in the hope that it will be useful, 
;	// but WITHOUT ANY WARRANTY; without even the implied warranty o;
;	// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;	// GNU General Public License for more details.
;	// 
;	// You should have received a copy of the GNU General Public License
;	// along with StandardMML. If not, see <http://www.gnu.org/licenses/>.

;	// Standard MML implementation for SE BASIC
;	// This implements the standard Music Macro Language (MML) syntax:
;	//
;	// Notes: a, b, c, d, e, f, g, A, B, C, D, E, F, G, r (rest)
;	// Accidentals: # or + (sharp) and - (flat) AFTER the note
;	// Octave: o1-o8 (set absolute) or > (up) and < (down)
;	// Length: l0-l9 (set default) or number after note (c4, d8, etc.)
;	// Dotted notes: dot after note or length (c. or c4.)
;	// Tempo: t32-t255 (beats per minute)
;	// Volume: v0-v15
;	// Envelope: s0-s15 (sets waveform and activates it)
;	// Tied notes: & (connects notes)
;	// Repeat: [...] (played twice), can nest up to 4 levels
;	// Comments: between ' characters
;	// Control: m (modulation), h (MIDI channel), z (MIDI command), x (exit)

;;
;	// --- STANDARD MML ROUTINES ------------------------------------------------
;;
:

; Update command lookup table
mml_ttab:
	defb "[",  0;							// repeat open
	defb "]",  1;							// repeat close
	defb "O",  2;							// set octave
	defb ">",  3;							// octave up
	defb "<",  4;							// octave down
	defb "T",  5;							// set tempo
	defb "L",  6;							// set length
	defb "V",  7;							// set volume
	defb "S",  8;							// set envelope
	defb "M",  9;							// set modulation
	defb "H", 10;							// set MIDI channel
	defb "Z", 11;							// MIDI command
	defb "X", 12;							// exit
	defb "'", 13;							// comment
	defb ttab_chars;						// number of characters in table minus 1

; Command vector table
mml_tab:
	defw play_rep;							// [ - repeat open
	defw play_rep_end;						// ] - repeat close
	defw play_octave;						// O - set octave
	defw play_oct_inc;						// > - octave up
	defw play_oct_dec;						// < - octave down
	defw play_tempo;						// T - set tempo
	defw play_length;						// L - set length
	defw play_volume;						// V - set volume
	defw play_envelope;						// S - set envelope
	defw play_envdur;						// M - set modulation
	defw play_midi_chan;					// H - set MIDI channel
	defw play_z;							// Z - MIDI command
	defw play_ret;							// X - exit
	defw play_comment;						// ' - comment

; Standard length values table (in 96ths of a note)
mml_durations:
	defb  96;								// 0 - whole note
	defb  48;								// 1 - half note
	defb  32;								// 2 - triplet half note
	defb  24;								// 3 - quarter note
	defb  16;								// 4 - eighth note
	defb  12;								// 5 - triplet quarter note
	defb   8;								// 6 - sixteenth note
	defb   6;								// 7 - triplet eighth note
	defb   4;								// 8 - thirty-second note
	defb   3;								// 9 - triplet sixteenth note

;;
; <code>PLAY</code> command (Standard MML implementation)
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#PLAY" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws Syntax error.
;;
c_std_play:
	res 0, (iy - _flagp);				// signal PSG
	rst get_char;						// get character
	cp '#';								// number sign?
	jr nz, std_play_1;					// jump if not
	rst next_char;						// next character
	call expt_1num;						// get parameter
	call syntax_z;						// checking syntax?
	jr z, std_play_0;					// jump if so
	call find_int1;						// parameter to A
	cp 2;								// in range (0 to 1)?
	jp nc, play_error;					// error if not
	and a;								// zero?
	jr z, std_play_0;					// jump if so
	set 0, (iy - _flagp);				// signal MIDI

std_play_0:
	rst get_char;						// get character
	cp ',';								// comma
	ret nz;								// return if not
	rst next_char;						// next character

std_play_1:
	ld b, 0;							// string index

std_play_2:
	push bc;							// stack BC
	call expt_exp;						// expect string expression
	pop bc;								// unstack BC
	inc b;								// increase B
	cp ',';								// another string?
	jr nz, std_play_3;					// jump if not
	rst next_char;						// get next character
	jr std_play_2;						// loop until done

std_play_3:
	ld a, b;							// check index
	cp 9;								// more than 8 strings?
	jr c, std_play_4;					// jump if not
	jp play_error;						// else error

std_play_4:
	call check_end;						// return if checking syntax
	di;									// interrupts off
	push bc;							// create workspace with channel string number (1 to 8) in B
	ld bc, uno_reg;						// Uno register select
	ld a, scandbl_ctrl;					// scan double and control register
	out (c), a;							// select it
	inc b;								// LD BC, uno_dat
	in a, (c);							// get current value
	and %00111111;						// 3.5MHz mode
	out (c), a;							// set it
	ld de, 55;							// channel block length
	ld hl, 60;							// command block length

std_play_5:
	add hl, de;							// HL + (DE * B) to HL
	djnz std_play_5;					// loop until done
	ld c, l;							// HL to BC
	ld b, h;							// space required (maximum 500 bytes)
	rst bc_spaces;						// make space
	push de;							// DE to IY
	pop iy;								// points to first new byte in command data block
	push hl;							// HL to IX
	pop ix;								// points to last new byte (after all channel info blocks)
	ld (iy + chan_bmp), 255;			// initialize channel bitmap (set zero strings)

std_play_6:
	ld bc, -55;							// PLAY channel string info block size
	add ix, bc;							// IX points to start of space for last channel
	ld (ix + octave), 4;				// default octave
	ld (ix + midi_chan), 255;			// no MIDI channel assigned
	ld (ix + volume), 15;				// default volume
	ld (ix + duration), 3;				// default note duration (quarter note)
	ld (ix + tied_notes), 0;			// tied notes count
	ld (ix + play_flag), 0;				// clear play flag and signal don't repeat string indefinitely
	ld (ix + op_nst_lv), 0;				// no open bracket nesting level
	ld (ix + cl_nst_lv), 255;			// no close bracket nesting level
	ld (ix + cl0_ret), 0;				// return address for close bracket nesting level 0
	call stk_fetch;						// get string details from stack
	ld (ix + str_pos), e;				// current position in string (start)
	ld (ix + str_pos_h), d;				// high byte
	ld (ix + op0_ret), e;				// return position in string for close bracket
	ld (ix + op0_ret_h), d;				// initially start of string in case single close bracket found
	ex de, hl;							// HL points to start of string, length of string to BC
	add hl, bc;							// HL points to address of byte after string
	ld (ix + str_end), l;				// address of character just after string
	ld (ix + str_end_h), h;				// high byte
	pop bc;								// string index (1 to 8) to B
	push bc;							// restack it
	dec b;								// reduce range (0 to 7)
	ld c, b;							// B to
	ld b, 0;							// BC
	sla c;								// multiply by 2
	push iy;							// IY to HL 
	pop hl;								// address of command data block to HL
	add hl, bc;							// skip 8 channel data pointer words
	push ix;							// IX to BC
	pop bc;								// address of current channel information block to BC
	ld (hl), c;							// store it in (HL)
	inc hl;								// increase HL
	ld (hl), b;							// high byte
	or a;								// clear carry flag
	rl (iy + chan_bmp);					// rotate one zero-bit to least significant bit of channel bitmap
	;									// initially holds %11111111 but after loop is over
	;									// a zero bit is set for each string parameter of PLAY command
	pop bc;								// current string index (1 to 8) to B
	dec b;								// decrease ranges (0 to 7)
	push bc;							// stack it for future use on next iteration
	ld (ix + chan_num), b;				// store channel number
	jr nz, std_play_6;					// loop until all channel strings processed
	pop bc;								// unstack item left on stack
	ld (iy + cur_tempo), $1a;			// set initial tempo timing value (2842)
	ld (iy + cur_tempo_h), $0b;			// corresponds to a tempo command value of 120
	ld e, %11111000;					// I/O ports are inputs, noise output off, tone output on
	ld d, 7;							// mixer register
	call L562C;							// set register
	ld e, 255;							// set to max
	ld d, 11;							// envelope period (fine) register
	call L562C;							// set register
	inc d;								// envelope period (coarse) register (12)
	call L562C;							// set register
	call L5291;							// select channel data block pointers

std_play_7:
	rr (iy + chan_bmp_tmp);				// test if next string present
	jr c, std_play_8;					// jump if no string for channel
	call L52A9;							// address of channel data block for current string to IX
	call mml_process_channel;			// find first note to play for channel from its string

std_play_8:
	sla (iy + chan_slct);				// all channels processed?
	jr c, std_play_9;					// jump if so
	call L52B0;							// advance to next channel data block pointer
	jr std_play_7;						// jump back to process next channel

std_play_9:
	call L5720;							// find smallest duration length of current notes across all channels
	push de;							// stack smallest duration length
	call L56D5;							// play note on each channel
	pop de;								// DE is smallest duration length

std_play_loop:
	ld a, (iy + chan_bmp);				// channel bitmap
	cp $FF;								// anything to play?
	jr nz, std_play_10;					// jump if so
	jp play_exit;						// max CPU speed, switch off all sound, restore IY and enable interrupts

std_play_10:
	dec de;								// DE is duration until next channel state change
	call L5705;							// wait
	call L5750;							// play note on each channel and update channel duration lengths
	call L5720;							// find smallest duration length of current notes across all channels
	jr std_play_loop;					// jump back to see if there is more to process

;;
; Process a single channel's MML string
; @param IX - pointer to channel data block
; @returns A - note value or 128 for rest
;;
mml_process_channel:
	call esc_key;						// break?
	jr c, mml_continue;					// jump if not
	call play_exit;						// max CPU speed, switch off all sound, restore IY and enable interrupts
	rst error;							// then
	defb msg_break;						// report

mml_continue:
	call L52DD;							// get current character from string, and advance position pointer
	jp c, L5570;						// jump if at end of string
	call mml_identify_command;			// find handler routine for MML command character
	cp 14;								// 14 or greater?
	jr nc, mml_process_note;			// jump if so - it's a note, not a command
	ld b, 0;							// generate offset to command vector table
	sla c;								// multiply by 2
	ld hl, mml_tab;						// offset to table
	add hl, bc;							// HL points to handler routine for command character
	ld e, (hl);							// get handler routine address for command character
	inc hl;								// increase HL
	ld d, (hl);							// high byte
	ex de, hl;							// to HL
	call call_jump;						// CALL HL
	jr mml_process_channel;				// jump back to handle next character in string

;;
; Process a note character (a-g, A-G, r)
; @param IX - pointer to channel data block
; @param A - character code
; @returns A - note value or 128 for rest
;;
mml_process_note:
	; Check if it's a note (a-g, A-G, r)
	cp 'r';								// rest?
	jr z, mml_process_rest;				// jump if so
	
	res 1, (ix + play_flag);			// clear flag to raise octave by one
	bit 5, a;							// lower case letter?
	jr nz, mml_note_case;				// jump if so
	set 1, (ix + play_flag);			// set a flag to raise octave by one
	
mml_note_case:
	; Save note letter and calculate note value
	and %11011111;						// make upper case
	sub 'A';							// reduce range (0 to 6)
	jp c, play_error;					// error if below A
	cp 7;								// 7 or above?
	jp nc, play_error;					// error if so
	
	; Convert letter to semitone value
	push af;							// save note letter (0=A, 1=B, 2=C, etc.)
	ld c, a;							// BC holds note (0 to 6)
	ld b, 0;							// high byte
	ld hl, semitones;					// look up number of semitones above note C for note 
	add hl, bc;							// add offset
	ld a, (hl);							// A is number of semitones above note C
	ld c, 0;							// C is number of semitones adjustment (initially 0)
	
	; Look ahead for accidentals or dotted notes
	push af;							// save semitone value
	push bc;							// save adjustment
	call mml_check_modifiers;			// check for accidentals and length
	pop bc;								// restore adjustment
	pop af;								// restore semitone value
	
	; Apply accidentals
	add a, c;							// adjust number of semitones above note C for sharpen/flatten characters
	ret;								// return note value in A

mml_process_rest:
	; Process a rest
	push af;							// save A
	push bc;							// save BC
	call mml_check_modifiers;			// check for length and dot
	pop bc;								// restore BC
	pop af;								// restore A
	ld a, 128;							// signal rest
	ret;								// return to caller

;;
; Check for note modifiers (accidentals, length, dot)
; @param IX - pointer to channel data block
;;
mml_check_modifiers:
	push hl;							// save HL
	push de;							// save DE
	
	; First check for accidentals (# or + for sharp, - for flat)
	call L56A6;							// get current character from string without advancing
	cp '#';								// sharp?
	jr z, mml_sharp;					// jump if so
	cp '+';								// sharp (alternate)?
	jr z, mml_sharp;					// jump if so
	cp '-';								// flat?
	jr z, mml_flat;					    // jump if so
	jr mml_check_length;				// jump to check for length
	
mml_sharp:
	inc c;								// increase semitone (sharp)
	call L52DD;							// advance pointer
	jr mml_check_length;				// jump to check for length
	
mml_flat:
	dec c;								// decrease semitone (flat)
	call L52DD;							// advance pointer
	
mml_check_length:
	; Now check for a length specifier (1-9)
	call L56A6;							// get current character from string without advancing
	call numeric;						// is it a number?
	jr c, mml_check_dot;				// jump if not
	
	; Process the length value
	call L533B;							// get numeric value from string to BC
	ld a, c;							// BC to A
	cp 10;								// 10 or above?
	jp nc, play_error;					// error if so
	ld (ix + duration), a;				// store length
	
mml_check_dot:
	; Check for dotted note
	call L56A6;							// get current character from string without advancing
	cp '.';								// dot?
	jr nz, mml_check_end;				// jump if not
	
	; Process dotted note - adds 50% to the length
	call L52DD;							// advance pointer
	call L557A;							// HL is address of duration length in channel data block
	call L5582;							// store address of duration length in command data block's channel duration length pointer table
	
	; Calculate dotted note length
	ld c, (ix + duration);				// get duration
	call L55A8;							// DE is duration length from table
	push de;							// save original duration
	srl d;								// divide by 2
	rr e;								// 
	pop hl;								// get original duration in HL
	add hl, de;							// add half (makes 1.5x original)
	ex de, hl;							// put result in DE
	
	; Store the result
	ld (hl), e;							// store the dotted duration
	inc hl;								// move to high byte
	ld (hl), d;							// store high byte
	
mml_check_end:
	; Check for tied notes
	call L56A6;							// get current character from string without advancing
	cp '&';								// tied note?
	jr nz, mml_modifiers_end;			// jump if not
	
	; Process tied note - this is handled by the original code
	call L52DD;							// advance pointer
	inc (ix + tied_notes);				// increase tied notes counter
	
mml_modifiers_end:
	pop de;								// restore DE
	pop hl;								// restore HL
	ret;								// return to caller

;;
; Identify MML command
; @param A - character
; @returns C - command index (0-13) or 14+ for a note
;;
mml_identify_command:
	call alpha;							// identify command character (is it a letter)
	jr nc, mml_non_alpha;				// jump if non-alpha
	and %11011111;						// make upper case
	cp 'R';								// rest?
	jr z, mml_note_found;				// jump if so
	cp 'A';								// A?
	jr c, mml_find_command;				// jump if below A
	cp 'H';								// H?
	jr c, mml_note_found;				// jump if note (A-G)
	
mml_find_command:
	ld bc, ttab_chars + 1;				// number of characters in table + 1
	ld hl, mml_ttab;					// start of table
	cpir;								// search for a match
	ret;								// return with C as command index or 14+ if not found

mml_non_alpha:
	ld bc, ttab_chars + 1;				// number of characters in table + 1
	ld hl, mml_ttab;					// start of table
	cpir;								// search for a match
	ret;								// return with C as command index or 14+ if not found

mml_note_found:
	ld c, 14;							// set high value to indicate a note
	ret;								// return to caller

;;
; Set default note length
; @param IX - pointer to channel data block
;;
play_length:
	call play_lt_256;					// get numeric value from string to A and test < 256
	cp 10;								// 10 or above?
	jp nc, play_error;					// error if so
	ld (ix + duration), a;				// store length
	ret;								// end of subroutine