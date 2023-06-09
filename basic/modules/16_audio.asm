;	// SoftPLAY 2 - TurboSound-AY MML Edition
;	// Copyright (c) 2013-2023 Source Solutions, Inc.

;	// SoftPLAY 2 is free software: you can redistribute it and/or modify
;	// it under the terms of the GNU General Public License as published by
;	// the Free Software Foundation, either version 3 of the License, or
;	// (at your option) any later version.
;	// 
;	// SoftPLAY 2 is distributed in the hope that it will be useful, 
;	// but WITHOUT ANY WARRANTY; without even the implied warranty o;
;	// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;	// GNU General Public License for more details.
;	// 
;	// You should have received a copy of the GNU General Public License
;	// along with SoftPLAY 2. If not, see <http://www.gnu.org/licenses/>.

;	// SoftPLAY 2's Music Macro Language syntax is as follows:
;	//
;	// other than note names, commands are case-insensitive
;	// upper case notes are one octave higher than the current octave
;	// the default octave is 4 
;	// R is a rest
;	// - before a note flattens it, + or # before a note sharpens it (FIXME: this should go after the note)
;	// & indicates tied notes
;	// comments can be enclosed between single quote marks ( ' )
;	// O sets the octave (1 to 8)
;	// (optional ) L sets the note length (0 to 9) as classic MML,
;	//  10 to 12 for triplets (sixteenth, eighth or quarter note)
;	// phrases in square brackets ( [] ) are played twice
;	// brackets can be nested up to four levels
;	// a closing bracket without a matching opening bracket loops the
;	// preceding phrase indefinitely
;	// T sets the tempo in BPM (32 to 255, default 120)
;	// V sets the volume (0 to 15) and swithces off envelopes on that channel
;	// S sets the envelope waveform (0 to 15) and activates it on the current channel (setting a volume disables envelopes)
;	// M sets the modulation frequency (1 to 65536)
;	// H sets the MIDI channel (1 to 16)
;	// Z sends a command (0 to 255) to the MIDI port
;	// X exits the PLAY command immediately
;	// > increases the octave by one
;	// < decreases the octave by one

;;
;	// --- PSG AND MIDI ROUTINES -----------------------------------------------
;;
:

	org $518e

;	// SE Basic IV supports up to 6 channels of music (with or without noise)
;	// and up to 8 channels of GM-MIDI music. (FIXME: enable selection of PSG or MIDI)
;	// the PLAY command reserves space for a command block and data block for each channel

;	// command data block
	chan_0 equ 0;						// data for channel 0 (string 1)
	chan_0_h equ 1;						// 
	chan_1 equ 2;						// data for channel 1 (string 2)
	chan_1_h equ 3;						// 
	chan_2 equ 4;						// data for channel 2 (string 3)
	chan_2_h equ 5;						// 
	chan_3 equ 6;						// data for channel 3 (string 4)
	chan_3_h equ 7;						// 
	chan_4 equ 8;						// data for channel 4 (string 5)
	chan_4_h equ 9;						// 
	chan_5 equ 10;						// data for channel 5 (string 6)
	chan_5_h equ 11;					// 
	chan_6 equ 12;						// data for channel 6 (string 7)
	chan_6_h equ 13;					// 
	chan_7 equ 14;						// data for channel 7 (string 8)
	chan_7_h equ 15;					// 
	chan_bmp equ 16;					// channel bitmap (initially %11111111)
;										// 0 rotated in to the left for each string parameter
	chan_dur_0 equ 17;					// duration length store in channel 0 (string 1)
	chan_dur_0_h equ 18;				// 
	chan_dur_1 equ 19;					// duration length store in channel 1 (string 2)
	chan_dur_1_h equ 20;				// 
	chan_dur_2 equ 21;					// duration length store in channel 2 (string 3)
	chan_dur_2_h equ 22;				// 
	chan_dur_3 equ 23;					// duration length store in channel 3 (string 4)
	chan_dur_3_h equ 24;				// 
	chan_dur_4 equ 25;					// duration length store in channel 4 (string 5)
	chan_dur_4_h equ 26;				// 
	chan_dur_5 equ 27;					// duration length store in channel 5 (string 6)
	chan_dur_5_h equ 28;				// 
	chan_dur_6 equ 29;					// duration length store in channel 6 (string 7)
	chan_dur_6_h equ 30;				// 
	chan_dur_7 equ 31;					// duration length store in channel 7 (string 8)
	chan_dur_7_h equ 32;				// 
	chan_slct equ 33;					// used as a shift register with bit 0 initially set
;										// shifted to the left until a carry occurs, indicating
;										// all 8 possible channels have been processed
	chan_bmp_tmp equ 34;				// working copy of channel bitmap
	chan_ptrs_tmp equ 35;				// address of the channel data block pointers, or channel data block duration pointers
	chan_ptrs_tmp_h equ 36;				// 
	dur_min equ 37;						// smallest duration length of all currently playing channel notes
	dur_min_h equ 38;					// 
	cur_tempo equ 39;					// current tempo timing value (from tempo parameter 60 to 240 beats per minute)
	cur_tempo_h equ 40;					// 
	waveform equ 41;					// current effect waveform value
	ct_temp equ 42;						// temporary string counter selector

;	// command entries 43 to 60 are reserved

;	// channel data block
	note_num equ 0;						// index offset into note table
	midi_chan equ 1;					// MIDI channel assigned to string (0 to 15)
	chan_num equ 2;						// index position of string in PLAY command (0 to 7)
	octave equ 3;						// octave number (0 to 8)
	volume equ 4;						// volume (0 to 15) or with bit 4 set, use envelope
	duration equ 5;						// last note duration (0 to 9)
	str_pos equ 6;						// address current position in the string
	str_pos_h equ 7;					// 
	str_end equ 8;						// address byte after end of string
	str_end_h equ 9;					// 
	play_flag equ 10;					// PLAY flag
;										// bit 0:	set if single closing bracket found (repeat indefinitely)
;										// bit 1:	set if temporary octave increase
;										// bit 2-7: not used
	op_nst_lv equ 11;					// open bracket nesting level (0 to 4)
	op0_ret equ 12;						// open bracket nesting level 0 return address
	op0_ret_h equ 13;					// 
	op1_ret equ 14;						// open bracket nesting level 1 return address
	op1_ret_h equ 15;					// 
	op2_ret equ 16;						// open bracket nesting level 2 return address
	op2_ret_h equ 17;					// 
	op3_ret equ 18;						// open bracket nesting level 3 return address
	op3_ret_h equ 19;					// 
	op4_ret equ 20;						// open bracket nesting level 4 return address
	op4_ret_h equ 21;					// 
	cl_nst_lv equ 22;					// closing bracket nesting level (0 to 4)
	cl0_ret equ 23;						// 
	cl0_ret_h equ 24;					// closing bracket nesting level 0 return address
	cl1_ret equ 25;						// 
	cl1_ret_h equ 26;					// closing bracket nesting level 1 return address
	cl2_ret equ 27;						// 
	cl2_ret_h equ 28;					// closing bracket nesting level 2 return address
	cl3_ret equ 29;						// 
	cl3_ret_h equ 30;					// closing bracket nesting level 3 return address
	cl4_ret equ 31;						// 
	cl4_ret_h equ 32;					// closing bracket nesting level 4 return address
	tied_notes equ 33;					// 
	dur_len equ 34;						// duration length (in 96ths of a note)
	dur_len_h equ 35;					// 
	nxt_dur_len equ 36;					// next duration length (used with triplets)
	nxt_dur_len_h equ 37;				// 

;	// channel entries 38 to 54 are reserved

;;
; <code>PLAY</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#PLAY" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws Syntax error.
;;
c_play:
	res 0, (iy - _flagp);				// signal PSG
	rst get_char;						// get character
	cp '#';								// number sign?
	jr nz, L5192;						// jump if not
	rst next_char;						// next character
	call expt_1num;						// get parameter
	call syntax_z;						// checking syntax?
	jr z, L5191;						// jump if so
	call find_int1;						// parameter to A
	cp 2;								// in range (0 to 1)?
	jp nc, play_error;					// error if not
	and a;								// zero?
	jr z, L5191;						// jump if so
	set 0, (iy - _flagp);				// signal MIDI

L5191:
	rst get_char;						// get character
	cp ',';								// comma
	ret nz;								// return if not
	rst next_char;						// next character

L5192:
	ld b, 0;							// string index

L5193:
	push bc;							// stack BC
	call expt_exp;						// expect string expression
	pop bc;								// unstack BC
	inc b;								// increment B
	cp ',';								// another string?
	jr nz, L51A0;						// jump if not
	rst next_char;						// get next character
	jr L5193;							// loop until done

L51A0:
	ld a, b;							// check index
	cp 9;								// more than 8 strings?
	jr c, L51A8;						// jump if not
	jp play_error;						// else error

L51A8:
	call check_end;						// return if checking syntax
	di;									// interrupts off (FIXME: would be better to leave them on, but timing is tied to CPU speed)
	push bc;							// create workspade with channel string number (1 to 8) in B

	ld bc, uno_reg;						// Uno register select
	ld a, scandbl_ctrl;					// scan double and control register
	out (c), a;							// select it
	inc b;								// LD BC, uno_dat
	in a, (c);							// get current value
	and %00111111;						// 3.5MHz mode
	out (c), a;							// set it

	ld de, 55;							// channel block length
	ld hl, 60;							// command block length

L51B3:
	add hl, de;							// HL + (DE * B) to HL
	djnz L51B3;							// loop until done
	ld c, l;							// HL to BC
	ld b, h;							// space required (maximum 500 bytes)
	rst bc_spaces;						// make space
	push de;							// DE to IY
	pop iy;								// points to first new byte in command data block
	push hl;							// HL to IX
	pop ix;								// points to last new byte (after all channel info blocks)
	ld (iy + chan_bmp), 255;			// initialize channel bitmap (set zero strings)

L51C3:
	ld bc, -55;							// PLAY channel string info block size
	add ix, bc;							// IX points to start of space for last channel
	ld (ix + octave), 4;				// default octave
	ld (ix + midi_chan), 255;			// no MIDI channel assigned
	ld (ix + volume), 15;				// default volume
	ld (ix + duration), 5;				// default note duration (quarter note)
	ld (ix + tied_notes), 0;			// tied notes count
	ld (ix + play_flag), 0;				// clear play flag and signal don't repeat string indefinitely
	ld (ix + op_nst_lv), 0;				// no opening bracket nesting level
	ld (ix + cl_nst_lv), 255;			// no closing bracket nesting level
	ld (ix + cl0_ret), 0;				// return address for closing bracket nesting level 0
	ld (ix + cl0_ret_h), 0				// [FIXME: No need to initialise this since it is written to before it is ever tested]
	call stk_fetch;						// get string details from stack
	ld (ix + str_pos), e;				// current position in string (start)
	ld (ix + str_pos_h), d;				// 
	ld (ix + op0_ret), e;				// return position in string for closing bracket
	ld (ix + op0_ret_h), d;				// initially start of the string in case single closing bracket found
	ex de, hl;							// HL points to start of string, length of string to BC
	add hl, bc;							// HL points to address of byte after string
	ld (ix + str_end), l;				// address of character just after the string
	ld (ix + str_end_h), h;				// 
	pop bc;								// string index (1 to 8) to B
	push bc;							// restack it
	dec b;								// reduce range (0 to 7)
	ld c, b;							// BC to
	ld b, 0;							// B
	sla c;								// string index * 2 to BC
	push iy;							// IY to HL 
	pop hl;								// address of command data block to HL
	add hl, bc;							// skip 8 channel data pointer words
	push ix;							// IX to BC
	pop bc;								// address of current channel information block to BC
	ld (hl), c;							// store it in (HL)
	inc hl;								// 
	ld (hl), b;							// 
	or a;								// clear carry flag
	rl (iy + chan_bmp);					// rotate one zero-bit into the least significant bit of the channel bitmap
	;									// initially holds %11111111 but after the loop is over
	;									// a zero bit is set for each string parameter of the PLAY command
	pop bc;								// current string index (1 to 8) to B
	dec b;								// decrease ranges (0 to 7)
	push bc;							// stack it for future use on next iteration
	ld (ix + chan_num), b;				// store channel number
	jr nz, L51C3;						// loop until all channel strings processed
	pop bc;								// unstack item left on stack
	ld (iy + cur_tempo), $1a;			// set the initial tempo timing value (2842)
	ld (iy + cur_tempo_h), $0b;			// corresponds to a 'T' command value of 120
	ld d, 7;							// mixer register
	ld e, %11111000;					// I/O ports are inputs, noise output off, tone output on
	call L55FB;							// set register
	ld d, 11;							// envelope period (fine) register
	ld e, 255;							// set to max
	call L55FB;							// set register
	inc d;								// envelope period (coarse) register (12)
	call L55FB;							// set register
	call L5260;							// select channel data block pointers

L5244:
	rr (iy + chan_bmp_tmp);				// test if next string present
	jr c, L5250;						// jump if no string for channel
	call L5278;							// address of channel data block for current string to IX
	call L5345;							// Find the first note to play for this channel from its play string

L5250:
	sla (iy + chan_slct);				// Have all channels been processed?
	jr c, L528E;						// Jump ahead if so
	call L527F;							// Advance to the next channel data block pointer
	jr L5244;							// Jump back to process the next channel

;	// Select Channel Data Block Duration Pointers
L525B:
	ld bc, 17;							// Offset to the channel data block duration pointers table
	jr L5263;							// Jump ahead to continue

;	// Select Channel Data Block Pointers
L5260:
	ld bc, 0;							// Offset to the channel data block pointers table

L5263:
	push iy;							// 
	pop hl;								// HL=Point to the command data block
	add hl, bc;							// Point to the desired channel pointers table
	ld (iy + chan_ptrs_tmp), l;			// 
	ld (iy + chan_ptrs_tmp_h), h;		// Store the start address of channels pointer table
	ld a, (iy + chan_bmp);				// get channel bitmap
	ld (iy + chan_bmp_tmp), a;			// Initialise the working copy
	ld (iy + chan_slct), $01;			// Channel selector. Set the shift register to indicate the first channel
	ret;								// 

;	// Get Channel Data Block Address for Current String
L5278:
	ld e, (hl);							// 
	inc hl;								// 
	ld d, (hl);							// get address of the current channel data block
	push de;							// 
	pop ix;								// Return it in IX
	ret;								// 

;	// Next Channel Data Pointer
L527F:
	ld l, (iy + chan_ptrs_tmp);			// The address of current channel data pointer
	ld h, (iy + chan_ptrs_tmp_h);		// 
	inc hl;								// 
	inc hl;								// Advance to the next channel data pointer
	ld (iy + chan_ptrs_tmp), l;			// 
	ld (iy + chan_ptrs_tmp_h), h;		// The address of new channel data pointer
	ret;								// 

L528E:
	call L56EF;							// Find smallest duration length of the current notes across all channels
	push de;							// Save the smallest duration length
	call L56A4;							// Play a note on each channel
	pop de;								// DE=The smallest duration length

L5296:
	ld a, (iy + chan_bmp);				// Channel bitmap
	cp $FF;								// Is there anything to play?
	jr nz, L52A0;						// Jump if there is
	jp play_exit;						// max CPU speed, switch off all sound, restore IY and enable interrupts

L52A0:
	dec de;								// DE=Smallest channel duration length, i.e. duration until the next channel state change
	call L56D4;							// Perform a wait
	call L571F;							// Play a note on each channel and update the channel duration lengths
	call L56EF;							// Find smallest duration length of the current notes across all channels
	jr L5296;							// Jump back to see if there is more to process


;	// Get Play Character
L52AC:
	call L5675;							// Get the current character from the play string for this channel
	ret c;								// Return if no more characters
	inc (ix + str_pos);					// Increment the low byte of string pointer
	ret nz;								// Return if it has not overflowed
	inc (ix + str_pos_h);				// Else increment the high byte of string pointer
	ret;								// Returns with carry flag reset

;	// get next note
L52B8:
	push hl;							// stack HL
	ld c, 0;							// 

L52BB:
	call L52AC;							// get current character from PLAY string and advance position pointer
	jr nc, L52CB;						// jump unless at end of string
	ld a, (iy + chan_slct);				// get channel selector
	or (iy + chan_bmp);					// clear channel flag for this string
	ld (iy + chan_bmp), a;				// store the new channel bitmap

L52C9:
	pop hl;								// unstack HL
	ret;								// 

L52CB:
	cp '+';								// sharpen?
	jr z, L52D3;						// jump if so
	cp '#';								// sharpen?
	jr nz, L52D6;						// jump if not

L52D3:
	inc c;								// increase semitone
	jr L52BB;							// jump back to get next character

L52D6:
	cp '-';								// flatten?
	jr nz, L52DD;						// jump if not
	dec c;								// decrease semitone
	jr L52BB;							// jump back to get next character

L52DD:
	res 1, (ix + 10);					// clear flag to raise octave by one
	bit 5, a;							// lower case letter?
	jr nz, L52E5;						// jump if so
	set 1, (ix + 10);					// set a flag to raise octave by one

L52E5:
	and %11011111;						// make upper case
	cp 'R';								// is it a rest?
	jr nz, not_rest;					// jump if not
	ld a, 128;							// signal rest
	jr L52C9;							// restore HL and return
 
not_rest:
	sub 65;								// Reduce to range 'A'->0 .. 'G'->6
	jp c, play_error;					// Jump if below 'A' to produce error report "k Invalid note name"
	cp 7;								// Is it 7 or above?
	jp nc, play_error;					// Jump if so to produce error report "k Invalid note name"
	push bc;							// C=Number of semitones
	ld b, 0;							// 
	ld c, a;							// BC holds 0..6 for 'a'..'g'
	ld hl, semitones;					// Look up the number of semitones above note C for the note
	add hl, bc;							// 
	ld a, (hl);							// A=Number of semitones above note C
	pop bc;								// C=Number of semitones due to sharpen/flatten characters
	add a, c;							// Adjust number of semitones above note C for the sharpen/flatten characters
	pop hl;								// unstack HL
	ret;								// 

;	// Get Numeric Value from Play String
L5306:
	push hl;							// Save registers
	push de;							// 
	ld l, (ix + str_pos);				// Get the pointer into the PLAY string
	ld h, (ix + str_pos_h);				// 
	ld de, 0;							// Initialise result to 0

L5311:
	ld a, (hl);							// 
	call numeric;						//+++
	jr c, L532E;						//+++
	inc hl;								// Advance to the next character
	push hl;							// Save the pointer into the string
	call L5339;							// Multiply result so far by 10
	sub '0';							// $30. Convert ASCII digit to numeric value
	ld h, 0;							// 
	ld l, a;							// HL=Numeric digit value
	add hl, de;							// Add the numeric value to the result so far
	call c, test_65536;					// allow 65536 as substitute for zero
	ex de, hl;							// Transfer the result into DE
	pop hl;								// Retrieve the pointer into the string
	jr L5311;							// Loop back to handle any further numeric digits

test_65536
	ld a, l;							// test for
	or h;								// zero
	ret z;								// return if so
	jr play_error;						// else error

;	// The end of the numeric value was reached
L532E:
	ld (ix + str_pos), l;				// Store the new pointer position into the string
	ld (ix + str_pos_h), h;				// 
	push de;							// 
	pop bc;								// Return the result in BC
	pop de;								// Restore registers
	pop hl;								// 
	ret;								// 

;	// Multiply DE by 10
L5339:
	ld hl, 0;							// 
	ld b, 10;							// Add DE to HL ten times

L533E:
	add hl, de;							// 
	jr c, play_error;					// Jump ahead if an overflow to produce error report "l number too big"
	djnz L533E;							// 
	ex de, hl;							// Transfer the result into DE
	ret;								// 

;	// Find Next Note from Channel String
L5345:
	call break_key;						// Test for BREAK being pressed
	jr c, L534F;						// Jump ahead if not pressed
	call play_exit;						// max CPU speed, switch off all sound, restore IY and enable interrupts
	rst error;							// then
	defb msg_break;						// report

L534F:
	call L52AC;							// Get the current character from the PLAY string, and advance the position pointer
	jp c, L553B;						// Jump if at the end of the string
	call L5563;							// Find the handler routine for the PLAY command character
	ld b, 0;							// 
	sla c;								// Generate the offset into the
	ld hl, play_tab;					// command vector table
	add hl, bc;							// HL points to handler routine for this command character
	ld e, (hl);							// 
	inc hl;								// 
	ld d, (hl);							// get handler routine address
	ex de, hl;							// HL=Handler routine address for this command character
	call call_jump;						// Make an indirect call to the handler routine
	jr L5345;							// Jump back to handle the next character in the string

;	// PLAY command: L (separator)
play_scan:
	ret;								// just make a return. Required. DO NOT OPTIMIZE (FIXME: maybe ok to remove -- test scale and multi-chan)

;	// PLAY command: ' (comment)
play_comment:
	call L52AC;							// get current character from PLAY string and advance position pointer
	jp c, L553A;						// jump if end of string
	cp "'";								// end of comment?
	ret z;								// return if so
	jr play_comment;					// loop until end of comment

play_oct_dec:
	ld a, (ix + 3);						// get octave value
	dec a;								// reduce it
	jr play_oct_any;					// immedaite jump

play_oct_inc:
	ld a, (ix + 3);						// get octave value
	inc a;								// increase it

play_oct_any:
	cp 9;								// higher than octave 8?
	jr nc, play_error;					// error if so
	ld (ix + 3), a;						// store octave value
	ret;								// end of subtroutine

;	// test numeric values are below 256
play_lt_256:
	call L5306;							// get numeric value from string to BC
	ld a, b;							// high byte to A
	and a;								// test for zero
	ld a, c;							// low byte to A
	ret z;								// return if so else continue into error

;	// Produce Play Error Reports
play_error:
	call play_exit;						// max CPU speed, switch off all sound, restore IY and enable interrupts
	rst error;							// then
	defb illegal_function_call;			// error

;	// PLAY command: O (octae)
play_octave:
	call play_lt_256;					// get numeric value from string to A and test < 256
	and a;								// test for zero
	jr z, play_error;					// jump if so
	cp 9;								// 1 to 8?
	jr nc, play_error;					// jump if not
	ld (ix + octave), a;				// store octave
	ret;								// end of subroutine

;	// PLAY commmand: [ (start of repeat)
play_rep:
	ld a, (ix + op_nst_lv);				// current level of open bracket nesting to A
	inc a;								// increase count
	cp 5;								// only 4 levels supported
	jr z, play_error;					// error if fifth level
	ld (ix + op_nst_lv), a;				// store new open bracket nesting level
	ld de, 12;							// offset to bracket level return position store
	call L541C;							// address of pointer to store return location of bracket to HL
	ld a, (ix + str_pos);				// store current string position as return address of open bracket
	ld (hl), a;							// 
	inc hl;								// 
	ld a, (ix + str_pos_h);				// 
	ld (hl), a;							// 
	ret;								// end of subroutine

;	// PLAY commmand: ] (end of repeat)
play_rep_end:
	ld a, (ix + cl_nst_lv);				// get nesting level of closing brackets
	ld de, 23;							// offset to closing bracket return address
	or a;								// any bracket nesting?
	jp m, L53E9;						// jump if not

;	// re-reached the same position in the string as the closing bracket return address?
	call L541C;							// address of pointer to corresponding closing bracket return address to HL
	ld a, (ix + str_pos);				// get low byte of current address
	cp (hl);							// Re-reached the closing bracket?
	jr nz, L53E6;						// jump if not
	inc hl;								// point to high byte
	ld a, (ix + str_pos_h);				// get high byte address of the current address
	cp (hl);							// re-reached closing bracket?
	jr nz, L53E6;						// jump if not

;	// bracket level has been repeated so check if this was outer bracket level
	dec (ix + cl_nst_lv);				// decrese closing bracket nesting level since this level has been repeated
	ret p;								// Return if not the outer bracket nesting level such that the character
	;									// after the closing bracket is processed next

;	// The outer bracket level has been repeated
	bit 0, (ix + play_flag);			// Was this a single closing bracket?
	ret z;								// Return if it was not

;	// The repeat was caused by a single closing bracket so re-initialise the repeat
	ld (ix + cl_nst_lv), $00;			// Restore one level of closing bracket nesting
	xor a;								// Select closing bracket nesting level 0
	jr L5400;							// Jump ahead to continue

;	// A new level of closing bracket nesting
L53E6:
	ld a, (ix + cl_nst_lv);				// get nesting level of closing brackets

L53E9:
	inc a;								// Increment the count
	cp 5;								// Only 5 levels supported (4 to match up with opening brackets and a 5th to repeat indefinitely)
	jr z, play_error;					// Jump if this is the fifth to produce error report "d Too many brackets"
	ld (ix + cl_nst_lv), a;				// Store the new closing bracket nesting level
	call L541C;							// HL=Address of the pointer to the appropriate closing bracket return address store
	ld a, (ix + str_pos);				// Store the current string position as the return address for the closing bracket
	ld (hl), a;							// 
	inc hl;								// 
	ld a, (ix + str_pos_h);				// 
	ld (hl), a;							// 
	ld a, (ix + op_nst_lv);				// get nesting level of opening brackets

L5400:
	ld de, 12;							// 
	call L541C;							// HL=Address of the pointer to the opening bracket nesting level return address store
	ld a, (hl);							// Set the return address of the nesting level's opening bracket
	ld (ix + str_pos), a;				// as new current position within the string
	inc hl;								// 
	ld a, (hl);							// For a single closing bracket only, this will be the start address of the string
	ld (ix + str_pos_h), a;				// 
	dec (ix + op_nst_lv);				// Decrement level of open bracket nesting
	ret p;								// Return if the closing bracket matched an open bracket

;	// There is one more closing bracket then opening brackets, i.e. repeat string indefinitely
	ld (ix + op_nst_lv), $00;			// Set the opening brackets nesting level to 0
	set 0, (ix + play_flag);			// Signal a single closing bracket only, i.e. to repeat the string indefinitely
	ret;								// 

;	// Get Address of Bracket Pointer Store
L541C:
	push ix;							// 
	pop hl;								// HL=IX
	add hl, de;							// HL=IX+DE
	ld b, 0;							// 
	ld c, a;							// 
	sla c;								// 
	add hl, bc;							// HL=IX+DE+2*A
	ret;								// 

;	// PLAY command: T (tempo)
play_tempo:
	call play_lt_256;					// get numeric value from string to A and test < 256
	cp 32;								// 
	jp c, play_error;					// Jump if 31 or below to produce error report "n Out of range"
	ld a, (ix + chan_num);				// get channel number
	or a;								// Tempo 'T' commands have to be specified in the first string
	ret nz;								// If it is in a later string then ignore it
	push bc;							// C=Tempo value
	pop hl;								// 
	add hl, hl;							// 
	add hl, hl;							// HL=Tempo*4
	push hl;							// 
	pop bc;								// BC=Tempo*4. [Would have been quicker to use the combination LD B, H and LD C, L]
	push iy;							// Save the pointer to the play command data block
	call stack_bc;						// $2D2B. Place the contents of BC onto the stack. The call restores IY to $5C3A

;	// Calculate Timing Loop Counter
	fwait;								// enter calculator
	fstk10;								// x, 10
	fxch;								// 10, x
	fdiv;								// 10/x
	fstk;								// 10/x, 7.33e-6
	defb $df;							// exponent $6F (floating point number 7.33e-6)
	defb $75;							// mantissa byte 1 -80
	defb $f4;							// mantissa byte 2 -164
	defb $38;							// mantissa byte 3 -92
	defb $75;							// mantissa byte 4 -80
	fdiv;								// (10/x)/7.33e-6
	fce;								// exit calculator

;	// Tempo Command Return
;	// The calculator stack now holds the value (10/(Tempo*4))/7.33e-6 and this is stored as the tempo value.
;	// The result is used an inner loop counter in the wait routine at $0F28 (ROM 0). Each iteration of this loop
;	// takes 26 T-states. The time taken by 26 T-states is 7.33e-6 seconds. So the total time for the loop
;	// to execute is 2.5/TEMPO seconds
	call fp_to_bc;						// Fetch the value on the top of the calculator stack
	pop iy;								// Restore IY to point at the play command data block
	ld (iy + cur_tempo), c;				// Store tempo timing value
	ld (iy + cur_tempo_h), b;			// 
	ret;								// 

;	// PLAY command: V (volume)
play_volume:
	call play_lt_256;					// get numeric value from string to A and test < 256
	cp 16;								// 16 or above?
	jp nc, play_error;					// error if so
	ld (ix + volume), a;				// Store that the envelope is being used (along with the reset volume level)
	ret;								// end of subroutine

;	// PLAY command: S (envelope)
play_envelope:
	call play_lt_256;					// get numeric value from string to A and test < 256
	cp 16;							    // 16 or above?
	jp nc, play_error;					// error if so
	ld (iy + waveform), a;				// store new effect waveform value
	ld e, %00011111;					// enable envelopes and set max volume
	ld (ix + volume), e;				// store that the envelope is being used (along with the reset volume level)
	ret;								// end of subroutine

;	// PLAY command: M (modulation frequency)
play_envdur:
	call L5306;							// Get following numeric value from the string into BC
	ld d, 11;							// envelope period (fine) register
	ld e, c;							// 
	call L55E3;							// Write to sound generator register to set the envelope period (low byte)
	inc d;								// envelope period (caorse) register (12)
	ld e, b;							// 
	jp L55E3;							// Write to sound generator register to set the envelope period (high byte)

;	// PLAY command: H (MIDI Channel)
play_midi_chan:
	call play_lt_256;					// get numeric value from string to A and test < 256
	dec a;								// Is it 0?
	jp m, play_error;					// Jump if so to produce error report "n Out of range"
	cp 16;								// Is it 10 or above?
	jp nc, play_error;					// Jump if so to produce error report "n Out of range"
	ld (ix + midi_chan), a;				// Store MIDI channel number that this string is assigned to
	ret;								// 

;	// PLAY command: Z (MIDI code)
play_z:
	call play_lt_256;					// get numeric value from string to A and test < 256
	jp L5823;							// Write byte to MIDI device

;	// PLAY command: X (exit)
play_ret:
	ld (iy + chan_bmp), 255;			// Indicate no channels to play, thereby causing
	ret;								the play command to terminate

;	// PLAY commands: a to g, A to G, R and &
play_other:
	call numeric;						// Is the current character a number?
	jp c, L551F;						// Jump if not number digit

;	// The character is a number digit
	call L5545;							// HL=Address of the duration length within the channel data block
	call L554D;							// Store address of duration length in command data block's channel duration length pointer table
	xor a;								// 
	ld (ix + tied_notes), a;			// Set no tied notes
	call L565A;							// Get the previous character in the string, the note duration
	call L5306;							// Get following numeric value from the string into BC
	ld a, c;							// 
	cp 13;								// Is it 13 or above?
	jp nc, play_error;					// Jump if so to produce error report "n Out of range"
	cp 10;								// Is it below 10?
	jr c, L54D0;						// Jump if so

;	// It is a triplet semi-quaver (10), triplet quaver (11) or triplet crotchet (12)
	call L5573;							// DE=Note duration length for the duration value
	call L5512;							// Increment the tied notes counter
	ld (hl), e;							// HL=Address of the duration length within the channel data block
	inc hl;								// 
	ld (hl), d;							// Store the duration length

L54C6:
	call L5512;							// Increment the counter of tied notes

	inc hl;								// 
	ld (hl), e;							// 
	inc hl;								// Store the subsequent note duration length in the channel data block
	ld (hl), d;							// 
	inc hl;								// 
	jr L54D6;							// Jump ahead to continue

;	// The note duration was in the range 1 to 9
L54D0:
	ld (ix + duration), c;				// C=Note duration value (1..9)
	call L5573;							// DE=Duration length for this duration value

L54D6:
	call L5512;							// Increment the tied notes counter

L54D9:
	call L5675;							// Get the current character from the play string for this channel
	cp '&';								// Is it a tied note?
	jr nz, L550C;						// jump if not
	call L52AC;							// Get the current character from the PLAY string, and advance the position pointer
	call L5306;							// Get following numeric value from the string into BC
	ld a, c;							// Place the value into A
	cp 10;								// Is it below 10?
	jr c, L54FD;						// Jump ahead for 1 to 9 (semiquaver ... semibreve)

;	// A triplet note was found as part of a tied note
	push hl;							// HL=Address of the duration length within the channel data block
	push de;							// DE=First tied note duration length
	call L5573;							// DE=Note duration length for this new duration value
	pop hl;								// HL=Current tied note duration length
	add hl, de;							// HL=Current+new tied note duration lengths
	ld c, e;							// 
	ld b, d;							// BC=Note duration length for the duration value
	ex de, hl;							// DE=Current+new tied note duration lengths
	pop hl;								// HL=Address of the duration length within the channel data block
	ld (hl), e;							// 
	inc hl;								// 
	ld (hl), d;							// Store the combined note duration length in the channel data block
	ld e, c;							// 
	ld d, b;							// DE=Note duration length for the second duration value
	jr L54C6;							// Jump back

;	/  A non-triplet tied note
L54FD:
	ld (ix + duration), c;				// Store the note duration value
	push hl;							// HL=Address of the duration length within the channel data block
	push de;							// DE=First tied note duration length
	call L5573;							// DE=Note duration length for this new duration value
	pop hl;								// HL=Current tied note duration length
	add hl, de;							// HL=Current+new tied not duration lengths
	ex de, hl;							// DE=Current+new tied not duration lengths
	pop hl;								// HL=Address of the duration length within the channel data block
	jp L54D9;							// Jump back to process the next character in case it is also part of a tied note

;	// The number found was not part of a tied note, so store the duration value
L550C:
	ld (hl), e;							// HL=Address of the duration length within the channel data block
	inc hl;								// (For triplet notes this could be the address of the subsequent note duration length)
	ld (hl), d;							// Store the duration length
	jp L5535;							// Jump forward to make a return

; This subroutine is called to increment the tied notes counter

L5512:
	ld a, (ix + tied_notes);			// Increment counter of tied notes
	inc a;								// 
	cp 11;								// Has it reached 11?
	jp z, play_error;					// Jump if so to produce to error report "o too many tied notes"

	ld (ix + tied_notes), a;			// Store the new tied notes counter
	ret;								// 

;The character is not a number digit so is 'A'..'G', '&' or '_'

L551F:
	call L565A;							// Get the previous character from the string
	ld (ix + tied_notes), $01 ; Set the number of tied notes to 1

;	// Store a pointer to the channel data block's duration length into the command data block
	call L5545;							// HL=Address of the duration length within the channel data block
	call L554D;							// Store address of duration length in command data block's channel duration length pointer table
	ld c, (ix + duration);				// C=The duration value of the note (1 to 9)
	call L5573;							// Find the duration length for the note duration value
	ld (hl), e;							// Store it in the channel data block
	inc hl;								// 
	ld (hl), d;							// 

L5535:
	pop hl;								// 
	inc hl;								// 
	inc hl;								// Modify the return address to point to the RET instruction at $0B3D (ROM 0)
	push hl;							// 
	ret;								// [Over elaborate when a simple POP followed by RET would have sufficed, saving 3 bytes]

;	// End of String Found
L553A:
	pop hl;								// Drop the return address of the call to the comment command

;	// Enter here if the end of the string is found whilst processing a string.
L553B:
	ld a, (iy + chan_slct);				// get channel selector
	or (iy + chan_bmp);					// Clear the channel flag for this string
	ld (iy + chan_bmp), a;				// Store the new channel bitmap
	ret;								// 

;	// Point to Duration Length within Channel Data Block
L5545:
	push ix;							// 
	pop hl;								// HL=Address of the channel data block
	ld bc, 34;							// 
	add hl, bc;							// HL=Address of the store for the duration length
	ret;								// 

;	// Store Entry in Command Data Block's Channel Duration Length Pointer Table
L554D:
	push hl;							// Save the address of the duration length within the channel data block
	push iy;							// 
	pop hl;								// HL=Address of the command data block
	ld bc, 17;							// 
	add hl, bc;							// HL=Address within the command data block of the channel duration length pointer table
	ld b, 0;							// 
	ld c, (ix + chan_num);				// BC=Channel number
	sla c;								// BC=2*Index number
	add hl, bc;							// HL=Address within the command data block of the pointer to the current channel's data block duration length
	pop de;								// DE=Address of the duration length within the channel data block
	ld (hl), e;							// Store the pointer to the channel duration length in the command data block's channel duration pointer table
	inc hl;								// 
	ld (hl), d;							// 
	ex de, hl;							// 
	ret;								// 

;	// Identify Command Character
L5563:
	call alpha;							// test alpha
	jr nc, non_alpha;					// jump if non-alpha
	and %11011111;						// make upper case

non_alpha:
	ld bc, ttab_chars + 1;				// number of characters +1 in table
	ld hl, play_ttab;					// start of table
	cpir;								// search for a match
	ret;								// end of subroutine

;	// Find Note Duration Length
L5573:
	push hl;							// stack HL
	ld b, 0;							// 
	ld hl, durations;					// Note duration table
	add hl, bc;							// Index into the table
	ld d, 0;							// 
	ld e, (hl);							// get length from the table
	pop hl;								// unstack HL
	ret;								// 

;	// Play a Note On a Sound Chip Channel FIXME: test for note range. Should be 127 or less
L557F:
	ld c, a;							// C=Note number
	ld a, (ix + chan_num);				// Get the channel number
	or a;								// Is it the first channel?
	jr z, set_noise;					//
	cp 3;								// is it the fourth channel?
	jr nz, L5598;						// Jump ahead if not. 

;	// Only set the noise generator frequency on the first channel
set_noise:
	ld a, c;							// A=Note number (0..107), in ascending audio frequency
	cpl;								// Invert since noise register value is in descending audio frequency
	and %01111111;						// Mask off bit 7
	srl  a;								// 
	srl  a;								// Divide by 4 to reduce range to 0..31
	ld d, 6;							// Register 6 - Noise pitch
	ld e, a;							// 
	call L55E3;							// set register

L5598:
	ld (ix + note_num), c;				// Store the note number
	ld a, (ix + chan_num);				// Get the channel number
	cp 6;								// Is it channel 0 to 5, i.e. a sound chip channel?
	ret nc;								// Do not output anything for play strings 4 to 8

;	// Channel 0 to 5
	ld hl, notes;						// Start of note lookup table
	ld b, 0;							// BC=Note number
	sla c;								// Generate offset into the table
	add hl, bc;							// Point to the entry in the table
	ld e, (hl);							// 
	inc hl;								// 
	ld d, (hl);							// DE=Word to write to the sound chip registers to produce this note
	ex de, hl;							// HL=Register word value to produce the note
	ld b, (ix + 3);						// get octave
	bit 1, (ix + 10);					// up one octave?
	jr z, test_octave_zero;				//
	inc b;								//
	jr div2_16bit;						// immediate jump

test_octave_zero
	ld a, 0;							// 
	cp b;		  						// 
	jr z, octave_zero;     				// 

div2_16bit:
	or a;								// clear carry flag
	rr h;								// rotate right (bit 0 to carry)
	rr l;								// rotate right (carry to bit 7)
	djnz, div2_16bit;	 			    // 

octave_zero:
	call L560D;							// 
	ld d, a;							// 
	sla d;								// D=2*Channel number, to give the tone channel register (fine control) number 0, 2, or 4
	ld e, l;							// E=The low value byte
	call L55E3;							// set register
	inc d;								// D=Tone channel register (coarse control) number 1, 3, or 5
	ld e, h;							// E=The high value byte
	call L55E3;							// set register
	bit 4, (ix + volume);				// Is the envelope waveform being used?
	ret z;								// Return if it is not
	ld d, 13;							// Register 13 - Envelope Shape
	ld a, (iy + waveform);				// Get the effect waveform value
	ld e, a;							// 

;	// Set Sound Generator Register
L55E3:
	push bc;							// stack BC
	ld a, (ix + chan_num);				// get channel number
	cp 3;								// channels 1 to 3?
	ld a, $ff;							// use first AY
	jr c, set_ay;						// jump if matched
	dec a;								// else use second AY

set_ay:
	ld bc, ay_128reg;					// AY register select
	out (c), a;							// set AY (first or second)
	out (c), d;							// select register
	ld b, $bf; 							// select data port
	out (c), e;							// write value 
	pop bc; 							// unstack BC
	ret; 								// done

L55FB:
	ld a, $fe;							// do second AY first

ay_loop:
	ld bc, ay_128reg;					// register port
	out (c), a;							// select AY (first or second)
	out (c), d;							// set register
	ld b, $bf;							// data port
	out (c), e;							// write value
	inc a;								// set first AY or zero
	and a;								// test for zero
	jr nz, ay_loop;						// loop back and do first AY
	ret;								// done

;	// Read Sound Generator Register
L560D:
	ld a, (ix + chan_num);				// get channel number
	cp 3;								// channel 0 to 2
	ret c;								// return if so
	sub 3;								// reduce range
	ret;								// and return

;	// Turn Off All Sound
play_exit:
	ld bc, uno_reg;						// Uno register select
	ld a, scandbl_ctrl;					// scan double and control register
	out (c), a;							// select it
	inc b;								// LD BC, uno_dat
	in a, (c);							// get current value
	or %11100000;						// 28MHz
	out (c), a;							// set it

mute_psg_midi:
	ld d, 7;							// Register 7 - Mixer
	ld e, $FF;							// I/O ports are inputs, noise output off, tone output off
	call L55FB;							// set register

;	// Turn off the sound from the AY-3-8912
	ld d, 8;							// Register 8 - Channel A volume
	ld e, 0;							// Volume of 0
	call L55FB;							// Write to sound generator register to set the volume to 0
	inc d;								// Register 9 - Channel B volume
	call L55FB;							// Write to sound generator register to set the volume to 0
	inc d;								// Register 10 - Channel C volume
	call L55FB;							// Write to sound generator register to set the volume to 0
	call L5260;							// select channel data block pointers

;	// Now reset all MIDI channels in use
L563D:
	rr (iy + chan_bmp_tmp);				// Working copy of channel bitmap. Test if next string present
	jr c, L5649;						// jump if no string for channel
	call L5278;							// address of channel data block for current string to IX
	call L580E;							// Turn off the MIDI channel sound assigned to this play string

L5649:
	sla (iy + chan_slct);				// Have all channels been processed?
	jr c, L5654;						// Jump ahead if so
	call L527F;							// Advance to the next channel data block pointer
	jr L563D;							// Jump back to process the next channel

L5654:
	ld iy, $5C3A;						// Restore IY
	ei;	   							    // re-enable interrupts
	ret;								// 

;	// Get Previous Character from Play String
L565A:
	push hl;							// Save registers
	push de;							// 
	ld l, (ix + str_pos);				// Get the current pointer into the PLAY string
	ld h, (ix + str_pos_h);				// 

L5662:
	dec hl;								// Point to previous character
	ld a, (hl);							// get character
	cp ' ';								// $20. Is it a space?
	jr z, L5662;						// Jump back if a space
	cp 13;								// Is it an 'Enter'?
	jr z, L5662;						// Jump back if an 'Enter'
	ld (ix + str_pos), l;				// Store this as the new current pointer into the PLAY string
	ld (ix + str_pos_h), h;				// 
	pop de;								// Restore registers
	pop hl;								// 
	ret;								// 

;	// Get Current Character from Play String
L5675:
	push hl;							// Save registers
	push de;							// 
	push bc;							// 
	ld l, (ix + str_pos);				// HL=Pointer to next character to process within the PLAY string
	ld h, (ix + str_pos_h);				// 

L567E:
	ld a, h;							// 
	cp (ix + str_end_h);				// Reached end-of-string address high byte?
	jr nz, L568D;						// Jump forward if not
	ld a, l;							// 
	cp (ix + str_end);					// Reached end-of-string address low byte?
	jr nz, L568D;						// Jump forward if not
	scf;								// Indicate string all processed
	jr L5697;							// Jump forward to return

L568D:
	ld a, (hl);							// Get the next play character
	cp ' ';								// $20. Is it a space?
	jr z, L569B;						// Ignore the space by jumping ahead to process the next character
	cp 13;								// Is it 'Enter'?
	jr z, L569B;						// Ignore the 'Enter' by jumping ahead to process the next character
	or a;								// Clear the carry flag to indicate a new character has been returned

L5697:
	pop bc;								// Restore registers
	pop de;								// 
	pop hl;								// 
	ret;								// 

L569B:
	inc hl;								// Point to the next character
	ld (ix + str_pos), l;				// 
	ld (ix + str_pos_h), h;				// Update the pointer to the next character to process with the PLAY string
	jr L567E;							// Jump back to get the next character

;	// Play Note on Each Channel
L56A4:
	call L5260;							// select channel data block pointers

L56A7:
	rr (iy + chan_bmp_tmp);				// Working copy of channel bitmap. Test if next string present
	jr c, L56CA;						// jump if no string for channel
	call L5278;							// address of channel data block for current string to IX
	call L52B8;							// Get the next note in the string as number of semitones above note C
	cp 128;								// Is it a rest?
	jr z, L56CA;						// Jump ahead if so and do nothing to the channel
	call L557F;							// Play the note if a sound chip channel
	call L560D;							// 

;	// One of the 3 sound chip generator channels so set the channel's volume for the new note
	ld d, 8;							// 
	add a, d;							// A=0 to 2
	ld d, a;							// D=Register (8 + string index), i.e. channel A, B or C volume register
	ld e, (ix + volume);				// E=Volume for the current channel
	call L55E3;							// Write to sound generator register to set the output volume

;	// MIDI only
	call L57E6;							// Play a note and set the volume on the assigned MIDI channel

L56CA:
	sla (iy + chan_slct);				// Have all channels been processed?
	ret c;								// Return if so
	call L527F;							// Advance to the next channel data block pointer
	jr L56A7;							// Jump back to process the next channel

;	// Wait Note Duration
;	// Entry: DE=Note duration, where 96d represents a whole note.
;	// Enter a loop waiting for (135+ ((26*(tempo-100))-5) )*DE+5 T-states
L56D4:
	push hl;							// (11) Save HL
	ld l, (iy + cur_tempo);				// (19) Get the tempo timing value
	ld h, (iy + cur_tempo_h);			// (19)
	ld bc, 100;							// (10) BC=100
	or a;								// (4)
	sbc  hl, bc;						// (15) HL=tempo timing value - 100
	push hl;							// (11)
	pop bc;								// (10) BC=tempo timing value - 100
	pop hl;								// (10) Restore HL

L56E4:
	dec bc;								// (6)  Wait for tempo-100 loops
	ld a, b;							// (4)
	or c;								// (4)
	jr nz, L56E4;						// (12/7)
	dec de;								// (6) Repeat DE times
	ld a, d;							// (4)
	or e;								// (4)
	jr nz, L56D4;						// (12/7)
	ret;								// (10)

;	// Find Smallest Duration Length
L56EF:
	ld de, $FFFF;						// Set smallest duration length to 'maximum'
	call L525B;							// Select channel data block duration pointers

L56F5:
	rr (iy + chan_bmp_tmp);				// Working copy of channel bitmap. Test if next string present
	jr c, L570D;						// jump if no string for channel

;	// HL=Address of channel data pointer. DE holds the smallest duration length found so far
	push de;							// Save the smallest duration length
	ld e, (hl);							// 
	inc hl;								// 
	ld d, (hl);							// 
	ex de, hl;							// DE=Channel data block duration length
	ld e, (hl);							// 
	inc hl;								// 
	ld d, (hl);							// DE=Channel duration length
	push de;							// 
	pop hl;								// HL=Channel duration length
	pop bc;								// Last channel duration length
	or a;								// 
	sbc  hl, bc;						// Is current channel's duration length smaller than the smallest so far?
	jr c, L570D;						// Jump ahead if so, with the new smallest value in DE

;	// The current channel's duration was not smaller so restore the last smallest into DE
	push bc;							// 
	pop de;								// DE=Smallest duration length

L570D:
	sla (iy + chan_slct);				// Have all channel strings been processed?
	jr c, L5718;						// Jump ahead if so
	call L527F;							// Advance to the next channel data block duration pointer
	jr L56F5;							// Jump back to process the next channel

L5718:
	ld (iy + dur_min), e;				// 
	ld (iy + dur_min_h), d;				// Store the smallest channel duration length
	ret;								// 

;	// Play a Note on Each Channel and Update Channel Duration Lengths
L571F:
	xor a;								// 
	ld (iy + ct_temp), a;				// Holds a temporary channel bitmap
	call L5260;							// select channel data block pointers

L5726:
	rr (iy + chan_bmp_tmp);				// Working copy of channel bitmap. Test if next string present
	jp c, L57B4;						// jump if no string for channel
	call L5278;							// address of channel data block for current string to IX
	push iy;							// 
	pop hl;								// HL=Address of the command data block
	ld bc, 17;							// 
	add hl, bc;							// HL=Address of channel data block duration pointers
	ld b, 0;							// 
	ld c, (ix + chan_num);				// BC=Channel number
	sla c;								// BC=2*Channel number
	add hl, bc;							// HL=Address of channel data block duration pointer for this channel
	ld e, (hl);							// 
	inc hl;								// 
	ld d, (hl);							// DE=Address of duration length within the channel data block
	ex de, hl;							// HL=Address of duration length within the channel data block
	push hl;							// Save it
	ld e, (hl);							// 
	inc hl;								// 
	ld d, (hl);							// DE=Duration length for this channel
	ex de, hl;							// HL=Duration length for this channel
	ld e, (iy + dur_min);				// 
	ld d, (iy + dur_min_h);				// DE=Smallest duration length of all current channel notes
	or a;								// 
	sbc  hl, de;						// HL=Duration length - smallest duration length
	ex de, hl;							// DE=Duration length - smallest duration length
	pop hl;								// HL=Address of duration length within the channel data block
	jr z, L575A;						// Jump if this channel uses the smallest found duration length
	ld (hl), e;							// 
	inc hl;								// Update the duration length for this channel with the remaining length
	ld (hl), d;							// 
	jr L57B4;							// Jump ahead to update the next channel

;	// The current channel uses the smallest found duration length
L575A:
	call L560D;							//
	ld d, 8;							// 
	add a, d;							// 
	ld d, a;							// D=Register (8+channel number) - Channel volume
	ld e, 0;							// E=Volume level of 0
	call L55E3;							// Write to sound generator register to turn the volume off
	call L580E;							// Turn off the assigned MIDI channel sound
	push ix;							// 
	pop hl;								// HL=Address of channel data block
	ld bc, 33;							// 
	add hl, bc;							// HL=Points to the tied notes counter
	dec (hl);							// decrese tied notes counter. [This contains a value of 1 for a single note]
	jr nz, L5780;						// Jump ahead if there are more tied notes
	call L5345;							// Find the next note to play for this channel from its play string
	ld a, (iy + chan_slct);				// get channel selector
	and (iy + chan_bmp);				// Test whether this channel has further data in its play string
	jr nz, L57B4;						// Jump to process the next channel if this channel does not have a play string
	jr L5797;							// The channel has more data in its play string so jump ahead

;	// The channel has more tied notes
L5780:
	push iy;							// 
	pop hl;								// HL=Address of the command data block
	ld bc, 17;							// 
	add hl, bc;							// HL=Address of channel data block duration pointers
	ld b, 0;							// 
	ld c, (ix + chan_num);				// BC=Channel number
	sla c;								// BC=2*Channel number
	add hl, bc;							// HL=Address of channel data block duration pointer for this channel
	ld e, (hl);							// 
	inc hl;								// 
	ld d, (hl);							// DE=Address of duration length within the channel data block
	inc de;								// 
	inc de;								// Point to the subsequent note duration length
	ld (hl), d;							// 
	dec hl;								// 
	ld (hl), e;							// Store the new duration length

L5797:
	call L52B8;							// Get next note in the string as number of semitones above note C
	ld c, a;							// C=Number of semitones
	ld a, (iy + chan_slct);				// get channel selector
	and (iy + chan_bmp);				// Test whether this channel has a play string
	jr nz, L57B4;						// Jump to process the next channel if this channel does not have a play string
	ld a, c;							// A=Number of semitones
	cp 128;								// Is it a rest?
	jr z, L57B4;						// Jump to process the next channel if it is
	call L557F;							// Play the new note on this channel at the current volume if a sound chip channel, or simply store the note for play strings 4 to 8
	ld a, (iy + chan_slct);				// get channel selector
	or (iy + ct_temp);					// Insert a bit in the temporary channel bitmap to indicate this channel has more to play
	ld (iy + ct_temp), a;				// Store it

;	// Check whether another channel needs its duration length updated
L57B4:
	sla (iy + chan_slct);				// Have all channel strings been processed?
	jr c, L57C0;						// Jump ahead if so
	call L527F;							// Advance to the next channel data pointer
	jp L5726;							// Jump back to update the duration length for the next channel

L57C0:
	call L5260;							// select channel data block pointers

;	// All channel durations have been updated. Update the volume on each sound chip channel, and the volume and note on each MIDI channel
L57C3:
	rr (iy + ct_temp);					// Temporary channel bitmap. Test if next string present
	jr nc, L57DC;						// jump if no string for channel
	call L5278;							// address of channel data block for current string to IX
	call L560D;							// 
	ld d, 8;							// 
	add a, d;							// 
	ld d, a;							// D=Register (8+channel number) - Channel volume
	ld e, (ix + volume);				// Get the current volume
	call L55E3;							// Write to sound generator register to set the volume of the channel
	call L57E6;							// Play a note and set the volume on the assigned MIDI channel

L57DC:
	sla (iy + chan_slct);				// Have all channels been processed?
	ret c;								// Return if so
	call L527F;							// Advance to the next channel data pointer
	jr L57C3;							// Jump back to process the next channel

;	// Play Note on MIDI Channel
L57E6:
	ld a, (flagp)
	cp 1
	ret nz
;	call mute_psg;

	ld a, (ix + midi_chan);				// Is a MIDI channel assigned to this string?
	or a;								// 
	ret m;								// Return if not

;	// A holds the assigned channel number ($00..$0F)
	or %10010000;						// Set bits 4 and 7 of the channel number. A=$90..$9F
	call L5823;							// Write byte to MIDI device
	ld b, (ix + note_num);				// get note number
	dec b;								// adjust note for MIDI
	ld a, (ix + 3);						// get octave
	bit 1, (ix + 10);					// up one octave?
	jr z, adjust_octave;				//
	inc a;								//

adjust_octave:
	ld c, a;							// store in C
	add a, a;							// octave * 2
	add a, c;							// * 3
	add a, a;							// * 6
	add a, a;							// * 12
	add a, b;							// octave * 12 + note
	call L5823;							// Write byte to MIDI device
	ld a, (ix + volume);				// get channel's volume
	res 4, a;							// Ensure the 'using envelope' bit is reset so
	sla a;								// that A holds a value between $00 and $0F
	sla a;								// Multiply by 8 to increase the range to $00..$78
	sla a;								// A=Note velocity
	jp L5823;							// Write byte to MIDI device

;	// Turn MIDI Channel Off
L580E:
	ld a, (ix + midi_chan);				// Is a MIDI channel assigned to this string?
	or a;								// 
	ret m;								// Return if not

;	// A holds the assigned channel number ($00..$0F)
	or 128;								// Set bit 7 of the channel number. A=$80..$8F
	call L5823;							// Write byte to MIDI device
	ld a, (ix + note_num);				// The note number
	call L5823;							// Write byte to MIDI device
	ld a, 64;							// The note velocity
	jp L5823;							// Write byte to MIDI device

;	// Send byte to MIDI device
L5823:
	ld l, a;							// Store the byte to send
	ld bc, ay_128reg;					// 
	ld a, 14;							// 
	out (c), a;							// Select register 14 - I/O port
	ld b, $bf;							// LD BC, ay_128dat
	ld a, $fa;							// Set RS232 'RXD' transmit line to 0. (Keep KEYPAD 'CTS' output line low to prevent the keypad resetting)
	out  (c), a;						// Send out the START bit
	ld e, 3;							// (7) Introduce delays such that the next bit is output 113 T-states from now

L5834:
	dec e;								// (4)
	jr nz, L5834;						// (12/7)
	nop;								// (4)
	nop;								// (4)
	nop;								// (4)
	nop;								// (4)
	ld a, l;							// (4) Retrieve the byte to send
	ld d, 8;							// (7) There are 8 bits to send

L583E:
	rra;								// (4) Rotate the next bit to send into the carry
	ld l, a;							// (4) Store the remaining bits
	jp nc, L5849;						// (10) Jump if it is a 0 bit
	ld a, $FE;							// (7) Set RS232 'RXD' transmit line to 1. (Keep KEYPAD 'CTS' output line low to prevent the keypad resetting)
	out  (c), a;						// (11)
	jr L11AB;							// (12) Jump forward to process the next bit

L5849:
	ld a, $FA;							// (7) Set RS232 'RXD' transmit line to 0. (Keep KEYPAD 'CTS' output line low to prevent the keypad resetting)
	out  (c), a;						// (11)
	jr L11AB;							// (12) Jump forward to process the next bit

L11AB:
	ld e, 2;							// (7) Introduce delays such that the next data bit is output 113 T-states from now

L11AD:
	dec e;								// (4)
	jr nz, L11AD;						// (12/7)
	nop;								// (4)
	add a, 0;							// (7)
	ld a, l;							// (4) Retrieve the remaining bits to send
	dec d;								// (4) Decrement the bit counter
	jr nz, L583E;						// (12/7) Jump back if there are further bits to send
	nop;								// (4) Introduce delays such that the stop bit is output 113 T-states from now
	nop;								// (4)
	add a, 0;							// (7)
	nop;								// (4)
	nop;								// (4)
	ld a, $FE;							// (7) Set RS232 'RXD' transmit line to 0. (Keep KEYPAD 'CTS' output line low to prevent the keypad resetting)
	out  (c), a;						// (11) Send out the STOP bit
	ld e, 6;							// (7) Delay for 101 T-states (28.5us)

L11C3:
	dec e;								// (4)
	jr nz, L11C3;						// (12/7)
	ret;								// (10)
