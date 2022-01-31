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
	defb 13;
	defb "In November 2019, Chloe Corporation launched a Patreon to rasie funds for the", 13;
	defb "development of the Chloe 280SE. To accompany the launch event, a short video was", 13;
	defb "produced parodying the open titles of Ridley Scott's Blade Runner, which is set", 13;
	defb "in an alternate 2019 (the idea being that the Chloe is from an alternate 1987).", 13;
	defb 13;
	defb "The video includes a version of the film's opening scroll, replacing Tyrell with", 13;
	defb "Intel, Replicants with Microcomputers, and Retirement with Emulation. The music", 13;
	defb "is 'If I Didn't Care' recorded by The Ink Spots in 1939, used in the workprint", 13;
	defb "cut of the film and the theatrical trailer. It is now in the public domain.", 13;
	defb 13;
	defb "Stills from the opening flight over Los Angelese are used as the backdrop to the", 13;
	defb "machine specifications: CPU, RAM, bus speed, palette, VRAM, display modes,", 13;
	defb "character sets, audio, co-processor, ROM, BASIC, file system and I/O devices.", 13;
	defb "Then a still from Scott's 1984 Apple advert, noting open [hard|firm|soft]ware.", 13;
	defb 13;
	defb "The final card also parodies the advert: You'll see why 2019 won't be like 2019.", 13;
	defb "The demo recreates the video, mainly using code from the slideshow app. The", 13;
	defb "scrolling text is done by streaming a BMP file directly to VRAM from disk. The", 13;
	defb "music was added later with the MID > Aria Maestosa > Arkos Tracker II workflow.", 13;
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
	defb "Bad Apple!! (Version 1.1)", 13;
 	defb "Copyright (C) 2018 Miguel Angel Rodriguez Jodar. ZX Projects. ZX-UNO Team.", 13;
	defb 13;
	defb "'Bad Apple!!' was originally the soundtrack to level 3 in the 1998 NEC PC-98", 13;
	defb "video game 'Lotus Land Story, episode 4 of the 'Touhou Project' by Jun'ya Ota.", 13;
	defb "In 2007 it was remixed by Masayoshi Minoshima with singer Nomico on an album", 13;
	defb "called 'Lovelight'. Fan videos (MADs) based on the song soen began to appear.", 13;
	defb 13;
	defb "In 1998 Nico Nico user Anira made a video featuring a storyboard with precise", 13;
	defb "details of what he considered would be the best video clip for the song. That", 13;
	defb "video has now had over a million views. In 2009 he released the finished video.", 13;
	defb "It has now had over 20 million combined views on Nico Nico and YouTube.", 13;
	defb 13;
	defb "Despite being rendered in 3D, the video uses a shadow puppet or silhouette style", 13;
	defb "of animation. It has spawned numerous fan versions and even featured on a CNN", 13;
	defb "news report in 2010. Interest spiked again in 2014 when the '8080 Domination'", 13;
	defb "demo for the IBM 5150 was released with 640x200 resolution at 30 FPS.", 13;
	defb 13;
	defb "This led to a string of ports to other systems including the C64, Vectrex, 2600", 13;
	defb "NES, Genesis, TI-84+ and Amiga. Many of these versions have PSG audio and a", 13;
	defb "lower frame rate. In 2018 ZX-UNO Team released a version using the DMA at 25 FPS", 13;
	defb "with 8-bit digital audio. This demo is a 30 FPS version of that release.", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;

;	// Take On Me
text:
	defb "Take On Me (Version 1.1)", 13;
 	defb "Copyright (C) 1985 Limehouse Productions, (P) 1985 Warner Bros. Records.", 13;
	defb 13;
	defb "Norwegian synth-pop band A-ha's hit record 'Take On Me' was not an instant", 13;
	defb "success. The original recording, produced by Tony Mansfield and released in 1984"
	defb "only reached #137 in the UK chart. This version is understated compared to the", 13;
	defb "more recognizable version, and has a video of the band performing the song.", 13;
	defb 13;
	defb "Mansfield produced most of the tracks on the band's debut album 'Hunting High", 13;
	defb "and Low', released in 1985. It was a huge success, going on to sell more than", 13;
	defb "11 million. And in 1986 A-ha was nominated for Best New Artist at the Grammys.", 13.
	defb 13;
	defb "In an unusual step, the record company gave the band a chance to re-record the", 13;
	defb "song, this time with Alan Tarney as producer. This was the version most people", 13;
	defb "are familar with, but it was released with another performance videa and once", 13;
	defb "again flopped. In an even more unusual step, a new video was commissioned.", 13;
	defb 13;
	defb "It was directed by Steve Barron, who had already made his name in music video,", 13;
	defb "using rotoscoped animation that took a team of artists six months to create.", 13;
	defb "It took siz prizes at the 1986 MTV Video Music Awards and has reached a billion", 13;
	defb "views on YouTube. It has been converted for the Bad Apple!! demo's DMA player.", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;

;	// Kayahara
text:
	defb "Kayahara (Version 1.2)", 13;
 	defb "Copyright (C) 2003 Nobuyuki Kayahara", 13;
	defb 13;
	defb "The 'Spinning Dancer', also known as the 'Silhouette Illusion', is a kinetic,", 13;
	defb "bistable, animated optical illusion originally distributed as a GIF animation.", 13;
	defb "Created in 2003 by web designer Nobuyuki Kayahara, the illusion derives from the", 13;
	defb "lack of visual clues for depth. The direction of spin depends on the observer.", 13;
	defb 13;
	defb "When facing left or right, the ponytail indicates the direction of travel, but", 13;
	defb "it is not obvious which leg is which. However, when not facing left or right,", 13;
	defb "the dancer can be seen as facing toward or away from the viewer. The dancer can", 13;
	defb "be percieved to rotate clockwise, counter-clockwise, or to pivot back and forth."", 13;
	defb 13;
	defb "Curiously, if you place a mirror vertically next to the image, both the original", 13;
	defb "and the reflection may be seen to spin in the same direction. From 2008 to 2009,", 13;
	defb "the animation appeared in the popular internet 'right brain-left brain test' to", 13;
	defb "determine the viewer's dominant hemisphere. The animation doesn't work this way.", 13;
	defb 13;
	defb "This demo was originally written as a memory test for an earlier version of the", 13;
	defb "Chloe hardware. Each frame is stored as a 4K image in RAM, for 136K in total.", 13;
	defb "All 128K of shadow RAM and part of the main RAM is used with paging between each", 13;
	defb "image. In this version the anamtion is synced to the interrupt at 30 FPS.", 13;
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;


;	// The Last V8
text:
	defb "The Last V8 (Version 1.2)", 13;
 	defb "Copyright (C) 1985 Rob Hubbard", 13;
	defb 13;
	defb "'The Last V8' was published by Mastertronic in 1985 on its M.A.D. label. It was", 13;
	defb "released on the C64, C128, Atari 8-bit and Amstrad CPC. It was designed and", 13;
	defb "programmed by brothers Ricahrd and David Darling who later founded Codemasters.", 13;
	defb "Graphics were by Jim Wilson, but the most memorable part is Rob Hubbard's music.", 13;
	defb 13;
	defb "The title is derived from a plot point in the 'Mad Max' series of films. Set in", 13;
	defb "a dystopian 2008, the world is devastated by nuclear war with few survivors.", 13;
	defb "Surviving for years in an underground bunker, the protagonist has built a V8-", 13;
	defb "engined car with radiation shiled capable of 250mp/h out of a 1980s vehicle.", 13'
	defb 13;
	defb "Unless you play the C128 version, in which case you start on a colony on Mars.", 13;
	defb "Either way, you have to drive around Earth looking for survivors of the war.", 13;
	defb "While on the surface you must avoid crashing, running out of fuel and radiation.", 13;
	defb "If a nuclear missile explodes, a digitized voice tells you to return to base.", 13;
	defb 13;
	defb "Although by all accounts the game is pretty terrible to play, the graphics were", 13;
	defb "praised by reviewers. But the music is consistently in the top 20 of all time", 13;
	defb "best SID tunes lists on the C64 where Rob Hubbard usually accounts for a quarter ", 13;
	defb "of all the entries. This 6-channel version is included with Arkos Tracker II.", 13;
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
	defb 13;
	defb "'Test Card F' was originally created at the BBC by George Hersee . The image", 13;
	defb "features his daughter Carole and her doll Bubbles the Clown, surrounded by color", 13;
	defb "and grayscale test signals to check the quality of the transmitted picture.", 13;
	defb "Carloe and Bubbles have now appeared in over 70,000 hours of television.", 13;
	defb 13;
	defb "'Left Bank Two' is a jazz piece composed by Wayne Hill for the De Wolfe music", 13;
	defb "library. Arranged for vibraphone, double bass, accoustic guitar and brushed", 13;
	defb "drums, it was performed by Dutch session group The Noveltones. In the UK, it was", 13;
	defb "used during the gallery sequence of children's art in Tony Hart's 'Vision On'.", 13;
	defb 13;
	defb "This demo was originally written as a video test for an earlier version of the", 13;
	defb "Chloe hardware. In that machine there were a total of four banks of video RAM", 13;
	defb "These could be used to store four 256x192 pixel images with 8x8 attributes, two", 13;
	defb "256x192 pixel images with 8x1 attributes or two mono 512x192 pixel images.", 13;
	defb 13;
;	defb "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	defb "The uncompressed images take up about 48K. They were originally stored in RAM,", 13;
	defb "but now they are loaded from disk. The older hardware only had eight primary", 13;
	defb "colors and a further eight bright colors. Therefore, the images have been", 13;
	defb "slightly recolored to take advanteage of the larger palette of the Chloe.", 13;
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
