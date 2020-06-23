;   // NTSC mode enables a 60Hz interrupt but forces the CPU to 3.5MHz.
;   // This is the only way to ensure that music encoded for the ZX core will still work on the
;   // Chloe core.
;   //
;   // The actual interrupt is 28000000 / 4 / 448 / 262 = 59.637404580152671755725190839695 Hz
;   //
;   // To configure Arkos Tracker 2 for playback in this mode:
;   // * Set the `replay rate` to: 59.64
;   // * Set the `PSG type` to AY
;   // * Set the `Master clock` to 1750000 Hz (Pentagon 128)
;   // * Set the `Reference frequency` to 440Hz
;   // * Set the `Sample player frequency` to 11025

 Until there is a dedicated Chloe core, forcing NTSC mode is the best way to write music code
;   // now that will still work in future

;	// set 60Hz mode
	ld bc, uno_reg;						// Uno register port
	xor a;								// master config
	out (c), a;							// set register
	inc b;								// Uno data port
	ld a, %00100110;					// bit 0 - 0: don't use boot mode (cannot access all RAM)
;										//     1 - 1: enable divMMC
;										//     2 - 1: disblae divMMC NMI
;										//     3 - 0: Port #FE behaves as issue 3
;										//     4 - 1: 262 scanlines per frame
;										//     5 - 1: Disable video contention
;										//     6 - 1: 262 scanlines per frame
;										//     7 - 0: unlock SPI (necessary to switch to boot mode)
	out (c), a;							// write data