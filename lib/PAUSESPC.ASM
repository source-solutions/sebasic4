;   // At 28MHz, reading a single keypress requires testing for a key up
;   // This routine returns after a specific delay but pauses indefinitely
;   // when space is held and return when it is released

	frame equ 23672;					// returns to zero every second
    delay equ 180;                      // frames / 2 to wait 

wait:
	ld a, (frame);						// get current frame value
	ld c, a;							// store it

wait2:
	ld a, (frame);						// get frame again
	cp c;								// has it changed?
	jr nz, wait2;						// loop until one frame passed
	halt;								// wait one more frame
	ret;								// return

space:
	ld b, delay;						// frames to wait

space2:
	ld a, $7f;							// high byte of I/O address
	in a, ($fe);						// read byte
	rra;								// set carry if space pressed
	jr c, space3;						// jump if not
	ld b, 2;							// change count

space3;
	call wait;							// wait 2 frames
	djnz space2;
	ret;								// done
