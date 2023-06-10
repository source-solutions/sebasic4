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
;	// - before a note flattens it, + or # before a note sharpens it (FIXME: should go after the note )
;	// & indicates tied notes
;	// comments can be enclosed between single quote marks ( ' )
;	// O sets the octave (1 to 8)
;	// (optional ) L sets the note length (0 to 9) as classic MML,
;	//  10 to 12 for triplets (sixteenth, eighth or quarter note )
;	// phrases in square brackets ( [] ) are played twice
;	// brackets can be nested up to four levels
;	// a close bracket without a matching open bracket loops the
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

;	// SoftPLAY 2 supports up to 6 channels of music (with or without noise)
;	// and up to 8 channels of GM-MIDI music. (FIXME: enable selection of PSG or MIDI)
;	// PLAY command reserves space for a command block and data block for each channel

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
;										// 0 rotated in to left for each string parameter
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
;										// shifted to left until a carry occurs, indicating
;										// all eight possible channels were processed
	chan_bmp_tmp equ 34;				// working copy of channel bitmap
	chan_ptrs_tmp equ 35;				// address of channel data block pointers, or channel data block duration pointers
	chan_ptrs_tmp_h equ 36;				// 
	dur_min equ 37;						// smallest duration length of all currently playing channel notes
	dur_min_h equ 38;					// 
	cur_tempo equ 39;					// current tempo timing value (from tempo parameter 60 to 240 beats per minute)
	cur_tempo_h equ 40;					// 
	waveform equ 41;					// current effect waveform value
	ct_temp equ 42;						// temporary string counter selector

;	// command entries 43 to 60 are reserved

;	// channel data block
	note_num equ 0;						// index offset to note table
	midi_chan equ 1;					// MIDI channel assigned to string (0 to 15)
	chan_num equ 2;						// index position of string in PLAY command (0 to 7)
	octave equ 3;						// octave number (0 to 8)
	volume equ 4;						// volume (0 to 15) or with bit 4 set, use envelope
	duration equ 5;						// last note duration (0 to 9)
	str_pos equ 6;						// address current position in string
	str_pos_h equ 7;					// 
	str_end equ 8;						// address byte after end of string
	str_end_h equ 9;					// 
	play_flag equ 10;					// PLAY flag
;										// bit 0:	set if single close bracket found (repeat indefinitely)
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
	cl_nst_lv equ 22;					// close bracket nesting level (0 to 4)
	cl0_ret equ 23;						// 
	cl0_ret_h equ 24;					// close bracket nesting level 0 return address
	cl1_ret equ 25;						// 
	cl1_ret_h equ 26;					// close bracket nesting level 1 return address
	cl2_ret equ 27;						// 
	cl2_ret_h equ 28;					// close bracket nesting level 2 return address
	cl3_ret equ 29;						// 
	cl3_ret_h equ 30;					// close bracket nesting level 3 return address
	cl4_ret equ 31;						// 
	cl4_ret_h equ 32;					// close bracket nesting level 4 return address
	tied_notes equ 33;					// 
	dur_len equ 34;						// duration length (in 96ths of a note )
	dur_len_h equ 35;					// 
	nxt_dur_len equ 36;					// next duration length (used with triplets)
	nxt_dur_len_h equ 37;				// 

;	// channel entries 38 to 54 are reserved

	org $5192

;;
; <code>PLAY</code> command
; @see <a href="https://github.com/source-solutions/sebasic4/wiki/Language-reference#PLAY" target="_blank" rel="noopener noreferrer">Language reference</a>
; @throws Syntax error.
;;
c_play:
	res 0, (iy - _flagp);				// signal PSG
	rst get_char;						// get character
	cp '#';								// number sign?
	jr nz, L51B8;						// jump if not
	rst next_char;						// next character
	call expt_1num;						// get parameter
	call syntax_z;						// checking syntax?
	jr z, L51B3;						// jump if so
	call find_int1;						// parameter to A
	cp 2;								// in range (0 to 1)?
	jp nc, play_error;					// error if not
	and a;								// zero?
	jr z, L51B3;						// jump if so
	set 0, (iy - _flagp);				// signal MIDI

L51B3:
	rst get_char;						// get character
	cp ',';								// comma
	ret nz;								// return if not
	rst next_char;						// next character

L51B8:
	ld b, 0;							// string index

L51BA:
	push bc;							// stack BC
	call expt_exp;						// expect string expression
	pop bc;								// unstack BC
	inc b;								// increase B
	cp ',';								// another string?
	jr nz, L51C7;						// jump if not
	rst next_char;						// get next character
	jr L51BA;							// loop until done

L51C7:
	ld a, b;							// check index
	cp 9;								// more than 8 strings?
	jr c, L51CF;						// jump if not
	jp play_error;						// else error

L51CF:
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

L51E8:
	add hl, de;							// HL + (DE * B) to HL
	djnz L51E8;							// loop until done
	ld c, l;							// HL to BC
	ld b, h;							// space required (maximum 500 bytes)
	rst bc_spaces;						// make space
	push de;							// DE to IY
	pop iy;								// points to first new byte in command data block
	push hl;							// HL to IX
	pop ix;								// points to last new byte (after all channel info blocks)
	ld (iy + chan_bmp), 255;			// initialize channel bitmap (set zero strings)

L51F8:
	ld bc, -55;							// PLAY channel string info block size
	add ix, bc;							// IX points to start of space for last channel
	ld (ix + octave), 4;				// default octave
	ld (ix + midi_chan), 255;			// no MIDI channel assigned
	ld (ix + volume), 15;				// default volume
	ld (ix + duration), 5;				// default note duration (quarter note )
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
	jr nz, L51F8;						// loop until all channel strings processed
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

L5275:
	rr (iy + chan_bmp_tmp);				// test if next string present
	jr c, L5281;						// jump if no string for channel
	call L52A9;							// address of channel data block for current string to IX
	call L537A;							// find first note to play for channel from its string

L5281:
	sla (iy + chan_slct);				// all channels processed?
	jr c, L52BF;						// jump if so
	call L52B0;							// advance to next channel data block pointer
	jr L5275;							// jump back to process next channel

L528C:
	ld bc, 17;							// offset to channel data block duration pointers table
	jr L5294;							// immediate jump

L5291:
	ld bc, 0;							// offset to channel data block pointers table

L5294:
	push iy;							// stack IY
	pop hl;								// HL points to command data block
	add hl, bc;							// point to desired channel pointers table
	ld (iy + chan_ptrs_tmp), l;			// store start address of channels pointer table
	ld (iy + chan_ptrs_tmp_h), h;		// high byte
	ld a, (iy + chan_bmp);				// get channel bitmap
	ld (iy + chan_bmp_tmp), a;			// initialize working copy
	ld (iy + chan_slct), $01;			// set shift register to indicate first channel
	ret;								// end of subroutine

L52A9:
	ld e, (hl);							// get channel data block address for current string
	inc hl;								// increase HL
	ld d, (hl);							// get address of current channel data block
	push de;							// DE to 
	pop ix;								// IX
	ret;								// end of subroutine

L52B0:
	ld l, (iy + chan_ptrs_tmp);			// next channel data pointer
	ld h, (iy + chan_ptrs_tmp_h);		// address of current channel data pointer to HL
	inc hl;								// advance to next channel data pointer
	inc hl;								// increase HL
	ld (iy + chan_ptrs_tmp), l;			// address of new channel data pointer
	ld (iy + chan_ptrs_tmp_h), h;		// high byte
	ret;								// end of subroutine

L52BF:
	call L5720;							// find smallest duration length of current notes across all channels
	push de;							// stack smallest duration length
	call L56D5;							// play note on each channel
	pop de;								// DE is smallest duration length

L52C7:
	ld a, (iy + chan_bmp);				// channel bitmap
	cp $FF;								// anything to play?
	jr nz, L52D1;						// jump if so
	jp play_exit;						// max CPU speed, switch off all sound, restore IY and enable interrupts

L52D1:
	dec de;								// DE is duration until next channel state change
	call L5705;							// wait
	call L5750;							// play note on each channel and update channel duration lengths
	call L5720;							// find smallest duration length of current notes across all channels
	jr L52C7;							// jump back to see if there is more to process

L52DD:
	call L56A6;							// get current character from string for channel
	ret c;								// return if no more characters
	inc (ix + str_pos);					// increase low byte of string pointer
	ret nz;								// return if it hasn't overflowed
	inc (ix + str_pos_h);				// else increase high byte of string pointer
	ret;								// returns with carry flag reset

L52E9:
	push hl;							// stack HL
	ld c, 0;							// get next note 

L52EC:
	call L52DD;							// get current character from string and advance position pointer
	jr nc, L52FC;						// jump unless at end of string
	ld a, (iy + chan_slct);				// get channel selector
	or (iy + chan_bmp);					// clear channel flag for string
	ld (iy + chan_bmp), a;				// store new channel bitmap

L52FA:
	pop hl;								// unstack HL
	ret;								// end of subroutine

L52FC:
	cp '+';								// sharpen?
	jr z, L5304;						// jump if so
	cp '#';								// sharpen?
	jr nz, L5307;						// jump if not

L5304:
	inc c;								// increase semitone
	jr L52EC;							// jump back to get next character

L5307:
	cp '-';								// flatten?
	jr nz, L530E;						// jump if not
	dec c;								// decrease semitone
	jr L52EC;							// jump back to get next character

L530E:
	res 1, (ix + 10);					// clear flag to raise octave by one
	bit 5, a;							// lower case letter?
	jr nz, L531A;						// jump if so
	set 1, (ix + 10);					// set a flag to raise octave by one

L531A:
	and %11011111;						// make upper case
	cp 'R';								// rest?
	jr nz, not_rest;					// jump if not
	ld a, 128;							// signal rest
	jr L52FA;							// restore HL and return
 
not_rest:
	sub 'A';							// reduce range (0 to 6)
	jp c, play_error;					// error if below A
	cp 7;								// 7 or above?
	jp nc, play_error;					// error if so
	push bc;							// C is number of semitones
	ld c, a;							// BC holds note (0 to 6)
	ld b, 0;							// high byte
	ld hl, semitones;					// look up number of semitones above note C for note 
	add hl, bc;							// add offset
	ld a, (hl);							// A is number of semitones above note C
	pop bc;								// C is number of semitones due to sharpen/flatten characters
	add a, c;							// adjust number of semitones above note C for sharpen/flatten characters
	pop hl;								// unstack HL
	ret;								// end of subroutine

L533B:
	push hl;							// get numeric value from string
	push de;							// stack registers
	ld l, (ix + str_pos);				// get pointer to string
	ld h, (ix + str_pos_h);				// high byte
	ld de, 0;							// initialize result

L5346:
	ld a, (hl);							// ASCII code to A
	call numeric;						// digit (0 to 9)?
	jr c, L5363;						// jump if not
	inc hl;								// advance to next character
	push hl;							// stack pointer to string
	call L536E;							// total * 10
	sub '0';							// ASCII digit to numeric value
	ld l, a;							// HL is numeric digit value
	ld h, 0;							// high byte
	add hl, de;							// add to total
	call c, test_65536;					// allow 65536 as substitute for zero
	ex de, hl;							// result to DE
	pop hl;								// unstack pointer to string
	jr L5346;							// Loop back to handle any more digits

test_65536
	ld a, l;							// test for
	or h;								// zero
	ret z;								// return if so
	jr play_error;						// else error

L5363:
	ld (ix + str_pos), l;				// end of numeric value was reached
	ld (ix + str_pos_h), h;				// store new pointer position to string
	ld c, e;							// return result in BC
	ld b, d;							// high byte
	pop de;								// unstack DE 
	pop hl;								// unstack HL
	ret;								// end of subroutine

L536E:
	ld hl, 0;							// multiply DE by 10
	ld b, 10;							// B is count

L5373:
	add hl, de;							// add DE to HL
	jr c, play_error;					// error with overflow
	djnz L5373;							// loop until done
	ex de, hl;							// result to DE
	ret;								// end of subroutine

L537A:
	call esc_key;						// break?
	jr c, L5384;						// jump if not
	call play_exit;						// max CPU speed, switch off all sound, restore IY and enable interrupts
	rst error;							// then
	defb msg_break;						// report

L5384:
	call L52DD;							// get current character from string, and advance position pointer
	jp c, L5570;						// jump if at end of string
	call L5598;							// find handler routine for PLAY command character
	ld b, 0;							// generate offset to command vector table
	sla c;								// multiply by 2
	ld hl, play_tab;					// offest to tale
	add hl, bc;							// HL points to handler routine for command character
	ld e, (hl);							// get handler routine address for command character
	inc hl;								// increase HL
	ld d, (hl);							// high byte
	ex de, hl;							// to HL
	call call_jump;						// CALL HL
	jr L537A;							// jump back to handle next character in string

play_scan:
	ret;								// Required. DON'T OPTIMIZE

play_comment:
	call L52DD;							// get current character from string and advance position pointer
	jp c, L556F;						// jump if end of string
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

play_lt_256:
	call L533B;							// get numeric value from string to BC
	ld a, b;							// high byte to A
	and a;								// test for zero
	ld a, c;							// low byte to A
	ret z;								// return if so else continue to error

play_error:
	call play_exit;						// max CPU speed, switch off all sound, restore IY and enable interrupts
	rst error;							// then
	defb illegal_function_call;			// error

play_octave:
	call play_lt_256;					// get numeric value from string to A and test < 256
	and a;								// test for zero
	jr z, play_error;					// jump if so
	cp 9;								// 1 to 8?
	jr nc, play_error;					// jump if not
	ld (ix + octave), a;				// store octave
	ret;								// end of subroutine
play_rep:
	ld a, (ix + op_nst_lv);				// current level of open bracket nesting to A
	inc a;								// increase count
	cp 5;								// only 4 levels supported
	jr z, play_error;					// error if fifth level
	ld (ix + op_nst_lv), a;				// store new open bracket nesting level
	ld de, 12;							// offset to bracket level return position store
	call L5451;							// address of pointer to store return location of bracket to HL
	ld a, (ix + str_pos);				// store current string position as return address of open bracket
	ld (hl), a;							// get handler routine address for command character
	inc hl;								// increase HL
	ld a, (ix + str_pos_h);				// high byte
	ld (hl), a;							// store it in (HL)
	ret;								// end of subroutine

play_rep_end:
	ld a, (ix + cl_nst_lv);				// get nesting level of close brackets
	ld de, 23;							// offset to close bracket return address
	or a;								// any bracket nesting?
	jp m, L541E;						// jump if not
	call L5451;							// address of pointer to corresponding close bracket return address to HL
	ld a, (ix + str_pos);				// get low byte of current address
	cp (hl);							// reached close bracket again?
	jr nz, L541B;						// jump if not
	inc hl;								// point to high byte
	ld a, (ix + str_pos_h);				// get high byte address of current address
	cp (hl);							// reached close bracket again?
	jr nz, L541B;						// jump if not
	dec (ix + cl_nst_lv);				// decrese close bracket nesting level because level was repeated
	ret p;								// return if not outer bracket nesting level such that character
	;									// after close bracket is processed next
	bit 0, (ix + play_flag);			// outer bracket level was repeated (single close bracket)?
	ret z;								// return if it wasn't
	ld (ix + cl_nst_lv), $00;			// repeat was caused by single close bracket so re-initialise repeat (restore one level of close bracket nesting)
	xor a;								// select close bracket nesting level zero
	jr L5435;							// immediate jump

L541B:
	ld a, (ix + cl_nst_lv);				// get nesting level of close brackets for new level

L541E:
	inc a;								// increase count
	cp 5;								// only five levels supported (four to match up with open brackets and a fifth to repeat indefinitely)
	jr z, play_error;					// error if fifth
	ld (ix + cl_nst_lv), a;				// store new close bracket nesting level
	call L5451;							// HL is address of pointer to appropriate close bracket return address store
	ld a, (ix + str_pos);				// store current string position as return address for close bracket
	ld (hl), a;							// value to A
	inc hl;								// increase HL
	ld a, (ix + str_pos_h);				// high byte
	ld (hl), a;							// store it in (HL)
	ld a, (ix + op_nst_lv);				// get nesting level of open brackets

L5435:
	ld de, 12;							// if there is one more close bracket then open brackets, repeat string indefinitely
	call L5451;							// HL is address of pointer to open bracket nesting level return address store
	ld a, (hl);							// set return address of nesting level's open bracket
	ld (ix + str_pos), a;				// as new current position in string
	inc hl;								// increase HL
	ld a, (hl);							// for single close bracket only, is start address of string
	ld (ix + str_pos_h), a;				// high byte
	dec (ix + op_nst_lv);				// decrease level of open bracket nesting
	ret p;								// return if close bracket matched an open bracket
	ld (ix + op_nst_lv), $00;			// set open brackets nesting level to 0
	set 0, (ix + play_flag);			// signal single close bracket only (repeat string indefinitely)
	ret;								// end of subroutine

L5451:
	push ix;							// get address of bracket pointer store
	pop hl;								// IX to HL
	add hl, de;							// HL is IX + DE
	ld c, a;							// A to
	ld b, 0;							// BC
	sla c;								// multiply by 2
	add hl, bc;							// HL is IX + DE + 2 * A
	ret;								// end of subroutine

play_tempo:
	call play_lt_256;					// get numeric value from string to A and test < 256
	cp 32;								// less than 32?
	jp c, play_error;					// error if so
	ld a, (ix + chan_num);				// get channel number
	or a;								// tempo command must be specified in first string
	ret nz;								// if it's in a later string then ignore it
	ld l, c;							// C is tempo value
	ld h, b;							// high byte
	add hl, hl;							// tempo * 2
	add hl, hl;							// tempo * 4
	ld c, l;							// HL to
	ld b, h;							// BC
	push iy;							// stack pointer to play command data block
	call stack_bc;						// stack BC
	fwait;								// calculate timing loop counter
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
	call fp_to_bc;						// get value on top of calculator stack
	pop iy;								// unstack IY to point at play command data block
	ld (iy + cur_tempo), c;				// store tempo timing value
	ld (iy + cur_tempo_h), b;			// high byte
	ret;								// end of subroutine

play_volume:
	call play_lt_256;					// get numeric value from string to A and test < 256
	cp 16;								// 16 or above?
	jp nc, play_error;					// error if so
	ld (ix + volume), a;				// store that envelope is being used (along with reset volume level)
	ret;								// end of subroutine

play_envelope:
	call play_lt_256;					// get numeric value from string to A and test < 256
	cp 16;							    // 16 or above?
	jp nc, play_error;					// error if so
	ld (iy + waveform), a;				// store new effect waveform value
	ld e, %00011111;					// enable envelopes and set max volume
	ld (ix + volume), e;				// store that envelope is being used (along with reset volume level)
	ret;								// end of subroutine

play_envdur:
	call L533B;							// get following numeric value from string to BC
	ld e, c;							// low byte to E
	ld d, 11;							// envelope period (fine) register
	call L5614;							// write PSG register to set envelope period (low byte)
	inc d;								// envelope period (caorse) register (12)
	ld e, b;							// high byte to E
	jp L5614;							// write PSG register to set envelope period (high byte)

play_midi_chan:
	call play_lt_256;					// get numeric value from string to A and test < 256
	dec a;								// zero?
	jp m, play_error;					// error if so
	cp 16;								// 10 or above?
	jp nc, play_error;					// error if so
	ld (ix + midi_chan), a;				// store MIDI channel number that string is assigned to
	ret;								// end of subroutine

play_z:
	call play_lt_256;					// get numeric value from string to A and test < 256
	jp L5861;							// write byte to MIDI device

play_ret:
	ld (iy + chan_bmp), 255;			// set no channels to play, causing command to terminate
	ret;								// end of subroutine

play_other:
	call numeric;						// current character a number?
	jp c, L5554;						// jump if not number digit (a to g, A to G, R and &)
	call L557A;							// HL is address of duration length in channel data block
	call L5582;							// store address of duration length in command data block's channel duration length pointer table
	xor a;								// LD A, 0
	ld (ix + tied_notes), a;			// set no tied notes
	call L568B;							// get previous character in string, note duration
	call L533B;							// get following numeric value from string to BC
	ld a, c;							// BC to A
	cp 13;								// 13 or above?
	jp nc, play_error;					// error if so
	cp 10;								// below 10?
	jr c, L5505;						// jump if so, else it's a triplet semi-quaver (10), triplet quaver (11) or triplet crotchet (12)
	call L55A8;							// DE is note duration length for duration value
	call L5547;							// increase tied notes counter
	ld (hl), e;							// HL is address of duration length in channel data block
	inc hl;								// increase HL
	ld (hl), d;							// store duration length

L54FB:
	call L5547;							// increase counter of tied notes
	inc hl;								// increase HL
	ld (hl), e;							// store subsequent note duration length in channel data block
	inc hl;								// increase HL
	ld (hl), d;							// high byte
	inc hl;								// increase HL
	jr L550B;							// immediate jump

L5505:
	ld (ix + duration), c;				// note duration was in range (1 to 9)
	call L55A8;							// DE is duration length for duration value

L550B:
	call L5547;							// increase tied notes counter

L550E:
	call L56A6;							// get current character from string for channel
	cp '&';								// tied note ?
	jr nz, L5541;						// jump if not
	call L52DD;							// get current character from string, and advance position pointer
	call L533B;							// get following numeric value from string to BC
	ld a, c;							// store in A
	cp 10;								// below 10?
	jr c, L5532;						// jump for 0 to 9 (thirtysecond to whole note),
;										// else a triplet note was found as part of a tied note 
	push hl;							// HL is address of duration length in channel data block
	push de;							// DE is first tied note duration length
	call L55A8;							// DE is note duration length for new duration value
	pop hl;								// HL is current tied note duration length
	add hl, de;							// HL is current+new tied note duration lengths
	ld c, e;							// BC is note duration length for duration value
	ld b, d;							// high byte
	ex de, hl;							// DE is current+new tied note duration lengths
	pop hl;								// HL is address of duration length in channel data block
	ld (hl), e;							// store combined note duration length in channel data block
	inc hl;								// increase HL
	ld (hl), d;							// high byte
	ld e, c;							// DE is note duration length for second duration value
	ld d, b;							// high byte
	jr L54FB;							// jump back

L5532:
	ld (ix + duration), c;				// store note duration value for a non-triplet tied note 
	push hl;							// HL is address of duration length in channel data block
	push de;							// DE is first tied note duration length
	call L55A8;							// DE is note duration length for new duration value
	pop hl;								// HL is current tied note duration length
	add hl, de;							// HL is current + new tied note duration lengths
	ex de, hl;							// DE is current + new tied note duration lengths
	pop hl;								// HL is address of duration length in channel data block
	jp L550E;							// jump back to process next character in case it's also part of a tied note 

L5541:
	ld (hl), e;							// HL is address of duration length in channel data block
	inc hl;								// for triplet notes could be address of subsequent note duration length
	ld (hl), d;							// number found wasn't part of a tied note so store store duration length
	jp L556A;							// jump forward to make a return

L5547:
	ld a, (ix + tied_notes);			// counter of tied notes
	inc a;								// increase it
	cp 11;								// reached 11?
	jp z, play_error;					// error if so

	ld (ix + tied_notes), a;			// store new tied notes counter
	ret;								// end of subroutine

L5554:
	call L568B;							// character isn't a number digit so get previous character from string
	ld (ix + tied_notes), 1;			// set number of tied notes to one
	call L557A;							// HL is address of duration length in channel data block
	call L5582;							// store address of duration length in command data block's channel duration length pointer table
	ld c, (ix + duration);				// C is duration value of note (1 to 9)
	call L55A8;							// find duration length for note duration value
	ld (hl), e;							// store it in channel data block
	inc hl;								// increase HL
	ld (hl), d;							// high byte

L556A:
	pop hl;								// unstack HL
	inc hl;								// increase it
	inc hl;								// modify return address to point to RET instruction at PLAY_SCAN
	push hl;							// stack HL
	ret;								// end of subroutine

L556F:
	pop hl;								// end of string found so drop return address of call to comment command

L5570:
	ld a, (iy + chan_slct);				// end of string is found while processing string so get channel selector
	or (iy + chan_bmp);					// clear channel flag for string
	ld (iy + chan_bmp), a;				// store new channel bitmap
	ret;								// end of subroutine

L557A:
	push ix;							// point to duration length in channel data block
	pop hl;								// HL is address of channel data block
	ld bc, 34;							// byte count
	add hl, bc;							// HL is address of store for duration length
	ret;								// end of subroutine

L5582:
	push hl;							// stack address of duration length in channel data block
	push iy;							// stack IY
	pop hl;								// HL is address of command data block
	ld bc, 17;							// byte count
	add hl, bc;							// HL is address in command data block of channel duration length pointer table
	ld c, (ix + chan_num);				// channel number
	ld b, 0;							// to BC
	sla c;								// multiply by 2
	add hl, bc;							// HL is address in command data block of pointer to current channel's data block duration length
	pop de;								// DE is address of duration length in channel data block
	ld (hl), e;							// store pointer to channel duration length in command data block's channel duration pointer table
	inc hl;								// increase HL
	ld (hl), d;							// high byte
	ex de, hl;							// swap pointers
	ret;								// end of subroutine

L5598:
	call alpha;							// identify command character (is it a letter)
	jr nc, non_alpha;					// jump if non-alpha
	and %11011111;						// make upper case

non_alpha:
	ld bc, ttab_chars + 1;				// number of characters in table + 1
	ld hl, play_ttab;					// start of table
	cpir;								// search for a match
	ret;								// end of subroutine

L55A8:
	push hl;							// stack HL
	ld b, 0;							// find note duration length
	ld hl, durations;					// note duration table
	add hl, bc;							// index to table
	ld e, (hl);							// get length from table
	ld d, 0;							// to DE
	pop hl;								// unstack HL
	ret;								// end of subroutine

L55B4:
	ld c, a;							// C is note number FIXME: test for note range? (should be 127 or less)
	ld a, (ix + chan_num);				// get channel number
	or a;								// first channel?
	jr z, set_noise;					// jump if so
	cp 3;								// fourth channel?
	jr nz, L55CD;						// jump if not else set noise generator frequency on first channel

set_noise:
	ld a, c;							// A is note number (0 to 107) in ascending audio frequency
	cpl;								// invert because noise register value is in descending audio frequency
	and %01111111;						// mask bit 7
	srl  a;								// divide by four to reduce range
	srl  a;								// (0 to 31)
	ld e, a;							// result to E 
	ld d, 6;							// noise pitch
	call L5614;							// set register

L55CD:
	ld (ix + note_num), c;				// store note number
	ld a, (ix + chan_num);				// get channel number
	cp 6;								// channel 0 to 5, i.e. a PSG channel?
	ret nc;								// Don't output anything for strings 4 to 8
	ld hl, notes;						// Start of note lookup table (channel 0 to 5)
	ld b, 0;							// BC is note number
	sla c;								// generate offset to table (multiply by 2)
	add hl, bc;							// point to entry in table
	ld e, (hl);							// DE is word to write to PSG registers to produce note 
	inc hl;								// incerase HL
	ld d, (hl);							// high byte
	ex de, hl;							// HL is register word value to produce note 
	ld b, (ix + 3);						// get octave
	bit 1, (ix + 10);					// up one octave?
	jr z, test_octave_zero;				// jump if not
	inc b;								// else increase it
	jr div2_16bit;						// immediate jump

test_octave_zero
	ld a, 0;							// Set A to zero. FIXME: XOR A would save a byte
	cp b;		  						// compare with octave
	jr z, octave_zero;     				// jump if octave zero

div2_16bit:
	or a;								// clear carry flag
	rr h;								// rotate right (bit 0 to carry)
	rr l;								// rotate right (carry to bit 7)
	djnz, div2_16bit;	 			    // loop until done

octave_zero:
	call L563E;							// read PSG register
	ld d, a;							// store it in D
	sla d;								// Multiply by 2 to get tone channel register (fine) 0, 2 or 4
	ld e, l;							// E is low value byte
	call L5614;							// set register
	inc d;								// D is tone channel register (coarse) 1, 3 or 5
	ld e, h;							// E is high value byte
	call L5614;							// set register
	bit 4, (ix + volume);				// envelope waveform being used?
	ret z;								// return if not
	ld d, 13;							// envelope shape
	ld a, (iy + waveform);				// get effect waveform value
	ld e, a;							// store it in E

L5614:
	push bc;							// stack BC
	ld a, (ix + chan_num);				// get channel number
	cp 3;								// channels 1 to 3?
	ld a, $ff;							// use first chip
	jr c, set_psg;						// jump if matched
	dec a;								// else use second chip

set_psg:
	ld bc, psg_128reg;					// PSG register select
	out (c), a;							// set chip (first or second)
	out (c), d;							// select register
	ld b, $bf; 							// select data port
	out (c), e;							// write value 
	pop bc; 							// unstack BC
	ret; 								// end of subroutine

L562C:
	ld a, $fe;							// do second chip first

psg_loop:
	ld bc, psg_128reg;					// register port
	out (c), a;							// select chip (first or second)
	out (c), d;							// set register
	ld b, $bf;							// data port
	out (c), e;							// write value
	inc a;								// set first chip or zero
	and a;								// test for zero
	jr nz, psg_loop;					// loop back and do first chip
	ret;								// end of subroutine

L563E:
	ld a, (ix + chan_num);				// get channel number (to read PSG register)
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
	ld e, %11111111;					// I/O ports are inputs, noise output off, tone output off
	ld d, 7;							// mixer
	call L562C;							// set register
	ld e, 0;							// volume 0 (switch off sound from PSG)
	ld d, 8;							// channel A volume
	call L562C;							// write PSG register to set volume to 0
	inc d;								// 9 - channel B volume
	call L562C;							// write PSG register to set volume to 0
	inc d;								// 10 - channel C volume
	call L562C;							// write PSG register to set volume to 0
	call L5291;							// select channel data block pointers

L566E:
	rr (iy + chan_bmp_tmp);				// test if next string present (reset all MIDI channels in use)
	jr c, L567A;						// jump if no string for channel
	call L52A9;							// address of channel data block for current string to IX
	call L584C;							// switch off MIDI channel sound assigned to string

L567A:
	sla (iy + chan_slct);				// all channels processed?
	jr c, L5685;						// jump if so
	call L52B0;							// advance to next channel data block pointer
	jr L566E;							// jump back to process next channel

L5685:
	ld iy, $5C3A;						// restore IY
	ei;	   							    // re-enable interrupts
	ret;								// end of subroutine

L568B:
	push hl;							// get previous character from string
	push de;							// stack registers
	ld l, (ix + str_pos);				// get current pointer to string
	ld h, (ix + str_pos_h);				// high byte

L5693:
	dec hl;								// point to previous character
	ld a, (hl);							// get character
	cp ' ';								// <space>?
	jr z, L5693;						// jump back if so
	cp 13;								// <Return>?
	jr z, L5693;						// jump back if so
	ld (ix + str_pos), l;				// store as new current pointer to string
	ld (ix + str_pos_h), h;				// high byte
	pop de;								// unstack DE
	pop hl;								// unstack HL
	ret;								// end of subroutine

L56A6:
	push hl;							// get current character from string
	push de;							// stack HL, DE
	push bc;							// and BC
	ld l, (ix + str_pos);				// HL is ointer to next character to process in string
	ld h, (ix + str_pos_h);				// high byte

L56AF:
	ld a, h;							// high byte to A
	cp (ix + str_end_h);				// end-of-string address high byte?
	jr nz, L56BE;						// jump forward if not
	ld a, l;							// low byte to A
	cp (ix + str_end);					// end-of-string address low byte?
	jr nz, L56BE;						// jump forward if not
	scf;								// Indicate string all processed
	jr L56C8;							// jump forward to return

L56BE:
	ld a, (hl);							// get next play character
	cp ' ';								// space?
	jr z, L56CC;						// jump if so
	cp 13;								// <Return>?
	jr z, L56CC;						// ignore <Return> and jump to process next character
	or a;								// clear carry flag to indicate new character found

L56C8:
	pop bc;								// unstack BC 
	pop de;								// unstack DE
	pop hl;								// unstack HL
	ret;								// end of subroutine

L56CC:
	inc hl;								// point to next character
	ld (ix + str_pos), l;				// update pointer to next character to process with string 
	ld (ix + str_pos_h), h;				// high byte
	jr L56AF;							// jump back to get next character

L56D5:
	call L5291;							// play note on each channel

L56D8:
	rr (iy + chan_bmp_tmp);				// test if next string present
	jr c, L56FB;						// jump if no string for channel
	call L52A9;							// address of channel data block for current string to IX
	call L52E9;							// get next note in string as number of semitones above note C
	cp 128;								// rest?
	jr z, L56FB;						// jump if so and do nothing to channel
	call L55B4;							// Play note if a PSG channel
	call L563E;							// One of six PSG channels so set volume for new note 
	ld d, 8;							// base value
	add a, d;							// modify range in A (0 to 2)
	ld e, (ix + volume);				// E is current channel volume
	ld d, a;							// D is register 8 + string index (channel A, B or C volume register)
	call L5614;							// write PSG register to set output volume
	call L5817;							// play note and set volume on assigned MIDI channel

L56FB:
	sla (iy + chan_slct);				// all channels processed?
	ret c;								// return if so
	call L52B0;							// advance to next channel data block pointer
	jr L56D8;							// jump back to process next channel

;	// DE is note duration (96 is a whole note)
;	// enter loop waiting for (135+ ((26*(tempo-100))-5) )*DE+5 T-states (@ 3.5 MHz)
L5705:
	push hl;							// (11)	  stack HL
	ld l, (iy + cur_tempo);				// (19)	  Get tempo timing value
	ld h, (iy + cur_tempo_h);			// (19)	  high byte
	ld bc, 100;							// (10)	  BC=100
	or a;								// (4)	  time padding
	sbc hl, bc;							// (15)	  HL is tempo timing value - 100
	push hl;							// (11)	  NOTE: don't replace with LD L, C; LD H, B
	pop bc;								// (10)	  BC is tempo timing value - 100
	pop hl;								// (10)	  unstack HL

L5715:
	dec bc;								// (6)	  wait for tempo-100 loops
	ld a, c;							// (4)	  test for zero
	or b;								// (4)
	jr nz, L5715;						// (12/7) jump if so
	dec de;								// (6)	  repeat DE times
	ld a, e;							// (4)	  test for zero
	or d;								// (4)
	jr nz, L5705;						// (12/7) jump if so
	ret;								// (10)   end of subroutine

L5720:
	ld de, $FFFF;						// set smallest duration length to max
	call L528C;							// select channel data block duration pointers

L5726:
	rr (iy + chan_bmp_tmp);				// test if next string present
	jr c, L573E;						// jump if no string for channel
	push de;							// stack smallest duration length
	ld e, (hl);							// address of channel data pointer to DE
	inc hl;								// increase HL
	ld d, (hl);							// high byte
	ex de, hl;							// DE is channel data block duration length
	ld e, (hl);							// DE is channel duration length 
	inc hl;								// increase HL
	ld d, (hl);							// high byte
	ld l, e;							// HL is channel duration length
	ld h, d;							// high byte
	pop bc;								// Last channel duration length
	or a;								// clear flags
	sbc hl, bc;							// current channel's duration length smaller than smallest so far?
	jr c, L573E;						// jump if so, with new smallest value in DE
	ld e, c;							// current channel's duration wasn't smaller so restore last smallest to DE
	ld d, b;							// DE is smallest duration length

L573E:
	sla (iy + chan_slct);				// all channel strings processed?
	jr c, L5749;						// jump if so
	call L52B0;							// advance to next channel data block duration pointer
	jr L5726;							// jump back to process next channel

L5749:
	ld (iy + dur_min), e;				// store smallest channel duration length
	ld (iy + dur_min_h), d;				// high byte
	ret;								// end of subroutine

L5750:
	xor a;								// play note on each channel and update channel duration lengths
	ld (iy + ct_temp), a;				// temporary channel bitmap
	call L5291;							// select channel data block pointers

L5757:
	rr (iy + chan_bmp_tmp);				// test if next string present
	jp c, L57E5;						// jump if no string for channel
	call L52A9;							// address of channel data block for current string to IX
	push iy;							// stack IY
	pop hl;								// HL is address of command data block
	ld bc, 17;							// byte count
	add hl, bc;							// HL is address of channel data block duration pointers
	ld b, 0;							// clear B
	ld c, (ix + chan_num);				// BC is channel number
	sla c;								// multiply by 2
	add hl, bc;							// HL is address of channel data block duration pointer for channel
	ld e, (hl);							// DE is address of duration length in channel data block
	inc hl;								// increase HL
	ld d, (hl);							// high byte
	ex de, hl;							// HL is address of duration length in channel data block
	push hl;							// stack it
	ld e, (hl);							// DE is duration length for channel
	inc hl;								// increase HL
	ld d, (hl);							// high byte
	ex de, hl;							// swap pointers
	ld e, (iy + dur_min);				// DE is smallest duration length of all current channel notes
	ld d, (iy + dur_min_h);				// high byte
	or a;								// clear carry flag
	sbc hl, de;							// HL is smallest duration length
	ex de, hl;							// swap pointers
	pop hl;								// HL is address of duration length in channel data block
	jr z, L578B;						// jump if channel uses smallest found duration length
	ld (hl), e;							// update duration length for channel with remaining length
	inc hl;								// increase HL
	ld (hl), d;							// high byte
	jr L57E5;							// immediate jump to update next channel

L578B:
	call L563E;							// current channel uses smallest found duration length
	ld d, 8;							// add 8
	add a, d;							// to A
	ld e, 0;							// E is volume level zero
	ld d, a;							// D is register (8+channel number) - channel volume
	call L5614;							// write PSG register to turn volume off
	call L584C;							// switch off assigned MIDI channel sound
	push ix;							// IX to HL
	pop hl;								// HL is address of channel data block
	ld bc, 33;							// byte count
	add hl, bc;							// HL points to tied notes counter
	dec (hl);							// decrese tied notes counter (1 for a single note)
	jr nz, L57B1;						// jump if more tied notes
	call L537A;							// find next note to play for channel from string
	ld a, (iy + chan_slct);				// get channel selector
	and (iy + chan_bmp);				// Test whether channel has more data in string
	jr nz, L57E5;						// jump to process next channel if channel doesn't have a string
	jr L57C8;							// immediate jump as channel has more data in string

;	// channel has more tied notes
L57B1:
	push iy;							// IY to HL
	pop hl;								// HL is address of command data block
	ld bc, 17;							// byte count
	add hl, bc;							// HL is address of channel data block duration pointers
	ld c, (ix + chan_num);				// BC is channel number
	ld b, 0;							// clear B
	sla c;								// multiply by 2
	add hl, bc;							// HL is address of channel data block duration pointer for channel
	ld e, (hl);							// DE is address of duration length in channel data block
	inc hl;								// increase HL
	ld d, (hl);							// high byte
	inc de;								// point to subsequent note duration length
	inc de;								// increase DE
	ld (hl), d;							// store new duration length in (HL)
	dec hl;								// increase HL
	ld (hl), e;							// high byte

L57C8:
	call L52E9;							// get next note in string as number of semitones above note C
	ld c, a;							// C is number of semitones
	ld a, (iy + chan_slct);				// get channel selector
	and (iy + chan_bmp);				// channel has a string?
	jr nz, L57E5;						// jump to process next channel if not
	ld a, c;							// A is number of semitones
	cp 128;								// rest?
	jr z, L57E5;						// jump to process next channel if so
	call L55B4;							// play new note on channel at current volume if a PSG channel, or simply store note for strings 4 to 8
	ld a, (iy + chan_slct);				// get channel selector
	or (iy + ct_temp);					// Insert a bit in temporary channel bitmap to indicate channel has more to play
	ld (iy + ct_temp), a;				// store it then check if another channel needs its duration length updated

L57E5:
	sla (iy + chan_slct);				// all channel strings processed?
	jr c, L57F1;						// jump if so
	call L52B0;							// advance to next channel data pointer
	jp L5757;							// jump back to update duration length for next channel

L57F1:
	call L5291;							// select channel data block pointers

;	// all channel durations updated, update volume on each PSG channel and volume and note on each MIDI channel
L57F4:
	rr (iy + ct_temp);					// test if next string present
	jr nc, L580D;						// jump if no string for channel
	call L52A9;							// address of channel data block for current string to IX
	call L563E;							// get channel number
	ld d, 8;							// add 8
	add a, d;							// to A
	ld e, (ix + volume);				// get current volume
	ld d, a;							// D is register (8+channel number) - Channel volume
	call L5614;							// write PSG register to set volume of channel
	call L5817;							// play note and set volume on assigned MIDI channel

L580D:
	sla (iy + chan_slct);				// all channels processed?
	ret c;								// return if so
	call L52B0;							// advance to next channel data pointer
	jr L57F4;							// jump back to process next channel

;	// Play Note on MIDI channel
L5817:
	ld a, (flagp);						// play flag
	cp 1;								// MIDI device enabled?
	ret nz;								// return if not
	ld a, (ix + midi_chan);				// MIDI channel assigned to string?
	or a;								// test
	ret m;								// return if not
	or %10010000;						// set bits 4 and 7 of channel number. A=$90 to $9F
	call L5861;							// write byte to MIDI device
	ld b, (ix + note_num);				// get note number
	dec b;								// adjust note for MIDI
	ld a, (ix + 3);						// get octave
	bit 1, (ix + 10);					// up one octave?
	jr z, adjust_octave;				// jump if not
	inc a;								// else increase octave

adjust_octave:
	ld c, a;							// store in C
	add a, a;							// octave * 2
	add a, c;							// * 3
	add a, a;							// * 6
	add a, a;							// * 12
	add a, b;							// octave * 12 + note 
	call L5861;							// write byte to MIDI device
	ld a, (ix + volume);				// get channel's volume
	res 4, a;							// make sure using envelope bit is cleared so
	sla a;								// A holds value between 0 and 15
	sla a;								// multiply by eight to increase range (0 to 120)
	sla a;								// A is note velocity
	jp L5861;							// write byte to MIDI device

;	// switch off MIDI channel
L584C:
	ld a, (ix + midi_chan);				// MIDI channel assigned to string?
	or a;								// test
	ret m;								// return if not

;	// A holds assigned channel number ($00 to $0F)
	or 128;								// set bit 7 of channel number. A=$80 to $8F
	call L5861;							// write byte to MIDI device
	ld a, (ix + note_num);				// note number
	call L5861;							// write byte to MIDI device
	ld a, 64;							// note velocity
	jp L5861;							// write byte to MIDI device

;	// s to MIDI device
L5861:
	ld l, a;							// store byte to send
	ld bc, psg_128reg;					// register
	ld a, 14;							// I/O port
	out (c), a;							// write it
	ld b, $bf;							// LD BC, psg_128dat
	ld a, $fa;							// set RS232 RXD transmit line to 0
	out  (c), a;						// send START bit
	ld e, 3;							// (7)	  add delays so that next bit is output 113 T-states from now

L5871:
	dec e;								// (4)
	jr nz, L5871;						// (12/7)
	nop;								// (4)
	nop;								// (4)
	nop;								// (4)
	nop;								// (4)
	ld a, l;							// (4)	  get byte to send
	ld d, 8;							// (7)	  eight bits to send

L587B:
	rra;								// (4)	  rotate next bit to send to carry
	ld l, a;							// (4)	  store remaining bits
	jp nc, L5886;						// (10)	  jump if zero bit
	ld a, $FE;							// (7)	  set RS232 RXD transmit line to 1
	out  (c), a;						// (11)
	jr L588C;							// (12)	  jump to process next bit

L5886:
	ld a, $FA;							// (7)	  set RS232 RXD transmit line to 0
	out  (c), a;						// (11)
	jr L588C;							// (12)	  jump to process next bit

L588C:
	ld e, 2;							// (7)	  add delays such that next data bit is output 113 T-states from now

L588E:
	dec e;								// (4)
	jr nz, L588E;						// (12/7)
	nop;								// (4)
	add a, 0;							// (7)
	ld a, l;							// (4)	  get remaining bits to send
	dec d;								// (4)	  decrease bit counter
	jr nz, L587B;						// (12/7) jump if more bits to send
	nop;								// (4)	  add delays such that stop bit is output 113 T-states from now
	nop;								// (4)
	add a, 0;							// (7)
	nop;								// (4)
	nop;								// (4)
	ld a, $FE;							// (7)	  set RS232 RXD transmit line to 0
	out  (c), a;						// (11)	  send out STOP bit
	ld e, 6;							// (7)	  delay for 101 T-states (28.5µs)

L58A4:
	dec e;								// (4)
	jr nz, L58A4;						// (12/7)
	ret;								// (10)
