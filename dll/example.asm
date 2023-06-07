;   // example DLL (dynamic linked library)
;   // Copyright (C) 2023 Source Solutions, Inc.

	dll_init equ $0563;							// vector to ROM DLL routine

;   // entry point
init:
	call dll_init;								// ROM routine to configure DLL

;   // header
	defw loop_1 - init, 1 + L0018 - init, 0;	// each label and each instruction that uses it, terminated with a zero word
	defw call_a - init, 1 + L0015 - init, 0;	// label, instance, [instance, ...] end of data for this label
	defw 0;										// terminating word (end of headder)

;   // actual start
start:
    ld a, 10;									// count

loop_1:
    dec a;										// decrement count
    and a										// zero?

L0015
    call z, call_a;								// jump if so

L0018
    jp loop_1;									// immediate jump

call_a:
    pop hl;										// drop return address
    ret;          								// and exit
