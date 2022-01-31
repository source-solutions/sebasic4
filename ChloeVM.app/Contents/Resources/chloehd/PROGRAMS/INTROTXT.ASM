;	// print intro text
pr_text:
	ld a, 12;							// FF
	rst print_a;						// clear screen
	ld a, 2;							// select main screen
	call chan_open;						// select channel
	ld hl, text;						// point to text

pr_loop:
	ld a, (hl);							// get character
	and a;								// terminating byte?
	jr z, pr_lower;						// jump if so;
	rst print_a;						// print character
	inc hl;								// point to next character
	jr pr_loop;							// loop until done

pr_lower
	inc hl;								// next position
	push hl;							// stack pointer
	ld a, 1;							// select lower screen
	call chan_open;						// select channel
	pop hl;								// unstack pointer

pr_l_loop:
	ld a, (hl);							// get character
	and a;								// terminating byte?
	jr z, pr_key;						// jump if so;
	rst print_a;						// print character
	inc hl;								// point to next character
	jr pr_l_loop;						// loop until done

pr_key:
	ld a, $7f;							// high byte of I/O address
	in a, ($fe);						// read byte
	rra;								// set carry if space pressed
	jp c, pr_key;						// loop until space pressed


;	// 2019
text:
	defb "2019 (Version 1.1)", 13;
 	defb "Copyright (C) 2020 Source Solutions, Inc.", 13;
;	defb "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;


;	// Aardman
text:
	defb "Aardman (Version 1.1)", 13;
 	defb "Copyright (C) 1987 Aardman Animations, (P) 1958 Bethlehem Records.", 13;
	defb 13;
	defb "Nina Simone's 'My Baby Just Cares For Me' originally appeared on the 1958 album", 13;
	defb "'Little Girl Blue'. Nearly three decades later in 1987 it became a hit after it", 13;
	defb "was featured in a Chanel No. 5 perfume advert with Bond girl Carole Bouquet", 13;
	defb "directed by Ridley Scott. Re-released, the song reached #5 in the UK chart.", 13;
	defb 13;
	defb "Aardman Animations was commissioned to produce a video to accompany the single.", 13;
	defb "Previously known mainly for the clay animation character Morph from television", 13;
	defb "programs hosted by Tony Hart, in 1986 the studio produced the video for Peter", 13;
	defb "Gabriel's number one single 'Sledgehammer' from his fifth studio album 'So'.", 13;
	defb 13;
	defb "This video is set in a nightclub with anthropomorphic cats. Simone is the singer,", 13;
	defb "and the object of her affection is a clumsy cat who the bouncers try to prevent", 13;
	defb "from entering the nightclub. Directed by Peter Lord, it won the Best Promotional", 13;
	defb "Material Under 5 Minutes award at the Ottawa International Animation festival.", 13;
	defb 13;
	defb "Besides the clay animation, the video also uses close-ups of the band's", 13;
	defb "instruments and includes a memorable sequence featuring the piano keyboard.", 13;
	defb "The monochromatic tones of the video made it a good candidate for conversion to", 13;
	defb "the DMA player format previously used in the 'Bad Apple !!' demo.", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;


;	// Bad Apple !!
text:
	defb "Bad Apple !! (Version 1.1)", 13;
 	defb "Copyright (C) 2018 Miguel Angel Rodriguez Jodar. ZX Projects. ZX-UNO Team.", 13;
;	defb "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;


;	// Take On Me
text:
	defb "Take On Me (Version 1.1)", 13;
 	defb "Copyright (C) 1985 Limehouse Productions, (P) 1985 Warner Bros. Records.", 13;
;	defb "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;

;	// Kayahara
text:
	defb "Kayahara [Spinning Dancer] (Version 1.2)", 13;
 	defb "Copyright (C) 2003 Nobuyuki Kayahara", 13;
;	defb "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;


;	// The Last V8
text:
	defb "The Last V8 (Version 1.2)", 13;
 	defb "Copyright (C) 1985 Rob Hubbard", 13;
;	defb "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;

;	// Slideshow
text:
	defb "Slideshow (Version 1.1)", 13;
 	defb "Copyright (C) 2019 Source Solutions, Inc.", 13;
;	defb "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE SHOW", 0;


;	// Skyfall
text:
	defb "Skyfall (Version 1.1)", 13;
 	defb "Copyright (C) 2012 Adele Adkins & Paul Epworth", 13;
;	defb "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;

;	// VDP Test
text:
	defb "VDP Test (Version 1.1)", 13;
 	defb "Copyright (C) 1963 Wayne Hill, (C) 1967 George Hersee.", 13;
;	defb "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb "", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;


;	// Boing Ball
text:
	defb "Boing Ball (Version 1.1)", 13;
 	defb "Copyright (C) 2021 Source Solutions, Inc.", 13;
	defb 13;
	defb "The original version of this demo was created by Robert J. Mical and Dale Luck", 13;
	defb "for the 1984 Consumer Electronics Show (CES) in Las Vegas. It was designed to", 13;
	defb "show off the custom chips in the prototype Amiga. Written in a single night,", 13;
	defb "aided only by warm beer, it originally lacked horizontal movement and sound.", 13;
	defb 13;
	defb "The effect was created using palette cycling and bit planes to move a static", 13;
	defb "image around the screen with the appearance of rotation. The entire 32 color", 13;
	defb "palette was required, despite the image using only seven unique colors.", 13;
	defb "The sound effect was created by hitting a garage door with a foam bat.", 13;
	defb 13;
	defb "The final design for the Chloe 280SE hardware would be able to produce an", 13;
	defb "exact copy of the original demo. But since that's not ready yet, this demo", 13;
	defb "uses 61 images, streamed from disk at 30 frames per second. Each images was", 13;
	defb "created by hand in Photoshop. They were then combined into an animated GIF.", 13;
	defb 13;
	defb "The individual images were converted by Image2ULAplus to 8x1 attribute format.", 13;
	defb "The player loops backwards and forwards between the images to give the", 13 ;
	defb "appearance of perpetual movement. As with the original demo, the sound effect", 13;
	defb "was added at a later date. Instead of a sample, it uses the PSG noise channel.";
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;

; 	// Juggler
text:
	defb " Juggler (Version 1.2)", 13;
 	defb " Copyright (C) 1986 Eric Graham", 13;
	defb 13;
	defb " The images were generated with a standard Amiga with 512K memory. A ray", 13;
	defb " tracing method was used, which simulates rays of light reflecting within", 13;
	defb " a mathematically defined scene. Each image requires the calculation of", 13;
	defb " 64,000 light rays and takes approximately 1 hour to generate.", 13;
	defb 13;
	defb " The images were cropped to 256 x 192 pixels and combined into a single", 13;
	defb " 1024 x 1152 pixel image. The color palette was reduced from 4096 colors", 13;
	defb " to 64 colors using Photoshop's selective algorithm. These colors were", 13;
	defb " then converted to the G3R3B2 color space to provide a uniform palette.", 13;
	defb 13;
	defb " Taking the three most significant bits for green and red, and the two", 13;
	defb " most significant bits for blue resulted in 50 unique colors. These were", 13;
	defb " then order sorted and distributed across the four CLUTs to provide an", 13;
	defb " optimal palette. The individual images were converted in Image2ULAplus.", 13;
	defb 13
	defb " An image uses 12K bytes for storage. Images are loaded in less than 30", 13;
	defb " milliseconds. A fixed palette is used to avoid having to set the", 13;
	defb " palette registers on each frame. This enables a constant frame rate of", 13;
	defb " 30 frames per second.";
	defb 0;
	defb " NOW PRESS SPACE TO START THE DEMO", 0;
