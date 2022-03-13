;	// RUNBASIC - A wrapper for launching BASIC programs as apps
;	// Copyright (c) 2022 Source Solutions, Inc.

;	// change all instances of RUNBASIC in the source and folder names to the name of your app

	oldsp equ $5bba;        			// (iy - $80)
    k_head equ 23550;
	_k_head equ $3c;
	k_buff_sz equ %01111111;            // 128 bytes

    org $6000
    ld sp, (oldsp);                     // restore BASIC stack pointer
    ld hl, string;                      // string to inject

loop_f_keys:
	ld a, (hl);							// get character
	and a;								// test for zero
	ret z;								// return if end of string reached
	inc hl;								// next character
	push hl;							// stack next character address
	ld hl, k_head;						// get address of head pointer
	ld l, (hl);							// to HL
	ld (hl), a;							// code to keyboard buffer
	inc l;								// HL contains next addres in buffer
	ld a, l;							// low byte to A
	and k_buff_sz;						// 128 bytes in circular buffer
	ld (iy - _k_head), a;				// new head pointer to sysvar
	pop hl;								// unstack next character address
	jr loop_f_keys;						// loop until done

string:
    defb "LOAD", '"', "/PROGRAMS/HELP/RSC/HELP.BAS", '"', ",", '"', 'T', '"', ":RUN", 13, 0;
