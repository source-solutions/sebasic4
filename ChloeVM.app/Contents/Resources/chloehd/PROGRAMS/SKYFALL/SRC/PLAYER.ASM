        ;Tests the AKY player, 6 channels, using the TurboSound extension, for SPECTRUM.
        ;This compiles with RASM. Please check the compatibility page on the website, you can convert these sources to ANY assembler!
        
        ;Tester code based on the one Grim/Arkos did for Arkos Tracker 1.

        org #8181
        
        ;Dummy interrupt service routine.
        ei
        ret
      
        ;The Program Counter MUST be set here when generating the SNA (#8183).
Start:

        ;Here comes the test program.
        ;Initializes IM2, gets rid of the system interrupt.
        di
        ld hl,#8000	;HL points to the IM2 Lookup table.
        ld a,h
        ld i,a		;Set I=#80.
        im 2		;Switch to vectorized interrupts.
        inc a
Im2FillLut: ld (hl),a	;Fills the IM2 LUT with #81.
        inc l		;All INT will jump to #8181.
        jr nz,Im2FillLut
        inc h
        ld (hl),a
	
        ld sp,$
        
        ;Initializes the music.
        ld hl,Music
        xor a                                   ;Subsong 0.
        call PLY_AKY_Init
        
        ei

        ;Waits for the ~50Hz interrupt.
MainLoop: halt

        ;Waits for the electron beam to be in the upper border.
        djnz $
        djnz $

        ;Changes the border color to white.
        ld bc,#fe
        ld a,7
        out (c),a

	;Plays one frame of the music.
        call PLY_AKY_Play
        
        ;Changes the border color to black.
        ld bc,#fe
        xor a
        out (c),a
        
        jr MainLoop


Player:
        ;Selects the hardware. Mandatory.
        PLY_AKY_HARDWARE_TURBOSOUND = 1
        
        ;Want a ROM player (a player without automodification)?
        ;PLY_AKY_Rom = 1                         ;Must be set BEFORE the player is included.

        ;Declares the buffer for the ROM player, if you're using it. You can declare it anywhere of course.
        ;IFDEF PLY_AKY_Rom
        ;        PLY_AKY_ROM_Buffer = $                  ;Can be set anywhere.
        ;        ds PLY_AKY_ROM_BufferSize, 0            ;Reserves the buffer for the ROM player (not mandatory, but cleaner).
        ;ENDIF
        
;       AKY Multi-PSG music player - V1.0.
;       By Julien Névo a.k.a. Targhan/Arkos.
;       CPC PSG sending optimization trick by Madram/Overlanders.
;       March 2019.
;
;       This compiles with RASM. Please check the compatibility page on Arkos Tracker 2 website, there is a Source Converter (Disark) for ANY assembler!
;
;       The player uses the stack for optimizations. Make sure the interruptions are disabled before it is called.
;       The stack pointer is saved at the beginning and restored at the end.
;
;       Multi-PSG
;       ----------------------
;       This player targets as many PSGs as you want! If you want to use a single PSG, it is better to use the PlayerAky.asm player, which is a bit faster/shorter.
;       However, this player allows you to use sound effects, which the single PSG source does not.
;
;       Sound effects
;       ----------------------
;       Sound effects are disabled by default. To enable them, two steps:
;       - Declare PLY_AKY_MANAGE_SOUND_EFFECTS to enable it:
;         PLY_AKY_MANAGE_SOUND_EFFECTS = 1
;       - Choose on what PSG the sound effects are played: (currently, only one PSG can have sound effects).
;         PLY_AKY_SFX_PSG_NUMBER = <psg number>    (>=1)
;         Example:
;         PLY_AKY_SFX_PSG_NUMBER = 1         for the first PSG to be the one where sound effects are played.
;
;       Check the sound effect tester for examples.
;       Note that the PRESENCE of this variable is tested, NOT its value.

;       Hardware target
;       ----------------------
;       This code targets specific hardware:
;
;       PlayCity (9 channels, Amstrad CPC)
;       TurboSound (6 channels, Spectrum)
;       SpecNext (9 channels, Spectrum)
;       FPGA Psg (6 channels, MSX)
;       Darky (6 channels, MSX)
;       All the 1-PSG usual hardware (once again, only use the current player if you need sound effects, else use "PlayerAky.asm" instead, it will be more efficient).
;       ... Or anything else if you fiddle with the constants (see below)!

;       Simply use one of the follow line (BEFORE this player):
;       PLY_AKY_HARDWARE_PLAYCITY = 1
;       PLY_AKY_HARDWARE_TURBOSOUND = 1
;       PLY_AKY_HARDWARE_SPECNEXT = 1
;       PLY_AKY_HARDWARE_FPGAPSG = 1
;       PLY_AKY_HARDWARE_DARKY = 1
;       Or the one-PSG hardware:
;       PLY_AKY_HARDWARE_CPC = 1
;       PLY_AKY_HARDWARE_MSX = 1
;       PLY_AKY_HARDWARE_SPECTRUM = 1
;       PLY_AKY_HARDWARE_PENTAGON = 1

;       Note that the PRESENCE of this variable is tested, NOT its value.
;
;       ROM
;       ----------------------
;       To use a ROM player (no automodification, use of a small buffer to put in RAM):
;       PLY_AKY_ROM = 1
;       PLY_AKY_ROM_Buffer = #4000 (or wherever). The buffer is PLY_AKY_ROM_BufferSize long.
;       This makes the player a tiny bit slower.
;
;       Optimizations
;       ----------------------
;       - Use the Player Configuration of Arkos Tracker 2 to generate a configuration file to be included at the beginning of this player.
;         It will disable useless features according to your songs! Check the manual for more details, or more simply the testers.
;       - SIZE: The JP hooks at the beginning can be removed if you include this code in yours directly (see the PLY_AKY_UseHooks flag below).
;       - SIZE: If you don't play a song twice, all the code in PLY_AKY_Init can be removed, except the first lines that skip the header.
;       - SIZE: The header is only needed for players that want to load any song. Most of the time, you don't need it. Erase both the init code and the header bytes in the song.
;
;       -------------------------------------------------------

PLY_AKY_Start:

        ;A nice trick to manage the offset using the same instructions, according to the player (ROM or not).
        IFDEF PLY_AKY_ROM
PLY_AKY_Offset1b: equ 0
        ELSE
PLY_AKY_Offset1b: equ 1
        ENDIF

        IFNDEF PLY_AKY_ROM
PLY_AKY_OPCODE_OR_A: equ #b7                        ;Opcode for "or a".
PLY_AKY_OPCODE_SCF: equ #37                         ;Opcode for "scf".
        ELSE
        ;Another trick for the ROM player. The original opcodes are converted to number, which will be multiplied by 2, provoking a carry or not.
PLY_AKY_OPCODE_OR_A: equ 0                          ;0 * 2 = 0, no carry.
PLY_AKY_OPCODE_SCF: equ #ff                         ;255 * 2 = carry.
        ENDIF

        ;Checks and sets up the basic hardware. Only one target must be selected.
        ;The "advanced" set up is at the end of the source, after the methods to send the registers to the PSGs are declared.
PLY_AKY_HardwareCounter = 0
        ;First, the 1-PSG hardware.
        IFDEF PLY_AKY_HARDWARE_CPC
                PLY_AKY_HardwareCounter = PLY_AKY_HardwareCounter + 1
                PLY_AKY_PsgCount = 1
                PLY_AKY_HARDWARE_PLAYCITY_OR_CPC = 1
        ENDIF
        IFDEF PLY_AKY_HARDWARE_MSX      ;Important to test it BEFORE the MSX related hardware, because the same constant is used!
                PLY_AKY_HardwareCounter = PLY_AKY_HardwareCounter + 1
                PLY_AKY_PsgCount = 1
                PLY_AKY_HARDWARE_MSX_VANILLA = 1 ;A special variable is used to make the difference with the other MSX hardware.
        ENDIF

        IFDEF PLY_AKY_HARDWARE_SPECTRUM
                PLY_AKY_HardwareCounter = PLY_AKY_HardwareCounter + 1
                PLY_AKY_PsgCount = 1
                PLY_AKG_HARDWARE_SPECTRUM_OR_PENTAGON = 1
                PLY_AKY_HARDWARE_SPECTRUM_RELATED = 1
        ENDIF        
        IFDEF PLY_AKY_HARDWARE_PENTAGON
                PLY_AKY_HardwareCounter = PLY_AKY_HardwareCounter + 1
                PLY_AKY_PsgCount = 1
                PLY_AKG_HARDWARE_SPECTRUM_OR_PENTAGON = 1
                PLY_AKY_HARDWARE_SPECTRUM_RELATED = 1
        ENDIF       


        IFDEF PLY_AKY_HARDWARE_PLAYCITY
                PLY_AKY_HardwareCounter = PLY_AKY_HardwareCounter + 1
                PLY_AKY_PsgCount = 3
                PLY_AKY_HARDWARE_PLAYCITY_OR_CPC = 1
        ENDIF
        IFDEF PLY_AKY_HARDWARE_TURBOSOUND
                PLY_AKY_HardwareCounter = PLY_AKY_HardwareCounter + 1
                PLY_AKY_HARDWARE_TURBOSOUND_OR_SPECNEXT = 1
                PLY_AKY_HARDWARE_SPECTRUM_RELATED = 1
                PLY_AKY_PsgCount = 2
        ENDIF
        IFDEF PLY_AKY_HARDWARE_SPECNEXT
                PLY_AKY_HardwareCounter = PLY_AKY_HardwareCounter + 1
                PLY_AKY_HARDWARE_TURBOSOUND_OR_SPECNEXT = 1
                PLY_AKY_HARDWARE_SPECTRUM_RELATED = 1
                PLY_AKY_PsgCount = 3
        ENDIF
        IFDEF PLY_AKY_HARDWARE_FPGAPSG
                PLY_AKY_HardwareCounter = PLY_AKY_HardwareCounter + 1
                PLY_AKY_HARDWARE_MSX = 1
                PLY_AKY_PsgCount = 2
        ENDIF
        IFDEF PLY_AKY_HARDWARE_DARKY
                PLY_AKY_HardwareCounter = PLY_AKY_HardwareCounter + 1
                PLY_AKY_HARDWARE_MSX = 1
                PLY_AKY_PsgCount = 2
        ENDIF
         
        
        IF PLY_AKY_HardwareCounter == 0
                FAIL 'One hardware must be selected!'
        ENDIF
        IF PLY_AKY_HardwareCounter > 1
                FAIL 'Only one hardware must be selected!'
        ENDIF
        ;Makes sure the PSG Number for SFX is defined if there are sound effects.
        IFDEF PLY_AKY_MANAGE_SOUND_EFFECTS
                IFNDEF PLY_AKY_SFX_PSG_NUMBER
                        FAIL 'If sound effects, the PSG number where to play them must be declared!'
                ELSE
                        ;Also validates its value.
                        IF PLY_AKY_SFX_PSG_NUMBER < 1
                                FAIL 'The SFX PSG number must be >=1!'
                        ENDIF
                        IF PLY_AKY_SFX_PSG_NUMBER > PLY_AKY_PsgCount
                                FAIL 'The SFX PSG number is superior to the PSG count!'
                        ENDIF
                ENDIF
        ELSE
                ;If no sound effects, we make the SFX PSG number unreachable, which makes testing easier (no need to check its presence).
                PLY_AKY_SFX_PSG_NUMBER = -1
        ENDIF

        PLY_AKY_ChannelCount = PLY_AKY_PsgCount * 3

PLY_AKY_PLAYCITY_SELECTWRITE_PORT_LSB_RIGHT: equ #84        ;The LSB of the PlayCity SELECT/WRITE port, for the right PSG.
PLY_AKY_PLAYCITY_SELECTWRITE_PORT_LSB_LEFT: equ #88         ;The LSB of the PlayCity SELECT/WRITE port, for the left PSG.
PLY_AKY_PLAYCITY_WRITE_PORT_MSB: equ #f8                    ;The MSB of the PlayCity WRITE port.
PLY_AKY_PLAYCITY_SELECT_PORT_MSB: equ #f9                   ;The MSB of the PlayCity SELECT port.

;See https://www.specnext.com/turbo-sound-next/ for how this is encoded.
PLY_AKY_SPECNEXT_PSG1_REGISTER: equ #ff                     ;Register to select to address the PSG1 later on, in the SpecNext.
PLY_AKY_SPECNEXT_PSG2_REGISTER: equ #fe                     ;Register to select to address the PSG2 later on, in the SpecNext.
PLY_AKY_SPECNEXT_PSG3_REGISTER: equ #fd                     ;Register to select to address the PSG3 later on, in the SpecNext.

PLY_AKY_TURBOSOUND_PSG1_REGISTER: equ #ff                   ;Register to select to address the PSG1 later on, for the TurboSound.
PLY_AKY_TURBOSOUND_PSG2_REGISTER: equ #fe                   ;Register to select to address the PSG2 later on, for the TurboSound.

PLY_AKY_UseHooks: equ 1                             ;Use hooks for external calls? 0 if the Init/Play methods are directly called, will save a few bytes.

        ;Is there a loaded Player Configuration source? If no, use a default configuration.
        IFNDEF PLY_CFG_ConfigurationIsPresent
                PLY_CFG_UseHardwareSounds = 1
                PLY_CFG_UseRetrig = 1
                PLY_CFG_NoSoftNoHard = 1
                PLY_CFG_NoSoftNoHard_Noise = 1
                PLY_CFG_SoftOnly = 1
                PLY_CFG_SoftOnly_Noise = 1
                PLY_CFG_SoftToHard = 1
                PLY_CFG_SoftToHard_Noise = 1
                PLY_CFG_SoftToHard_Retrig = 1
                PLY_CFG_HardOnly = 1
                PLY_CFG_HardOnly_Noise = 1
                PLY_CFG_HardOnly_Retrig = 1
                PLY_CFG_SoftAndHard = 1
                PLY_CFG_SoftAndHard_Noise = 1
                PLY_CFG_SoftAndHard_Retrig = 1
        ENDIF
        
        
        ;Agglomerates the hardware sound configuration flags, because they are treated the same in this player.
        ;-------------------------------------------------------
        IFDEF PLY_CFG_SoftToHard
                PLY_AKY_USE_SoftAndHard_Agglomerated = 1
        ENDIF
        IFDEF PLY_CFG_SoftAndHard
                PLY_AKY_USE_SoftAndHard_Agglomerated = 1
        ENDIF
        IFDEF PLY_CFG_HardToSoft
                PLY_AKY_USE_SoftAndHard_Agglomerated = 1
        ENDIF
        
        IFDEF PLY_CFG_SoftToHard_Noise
                PLY_AKY_USE_SoftAndHard_Noise_Agglomerated = 1
        ENDIF
        IFDEF PLY_CFG_SoftAndHard_Noise
                PLY_AKY_USE_SoftAndHard_Noise_Agglomerated = 1
        ENDIF
        IFDEF PLY_CFG_HardToSoft_Noise
                PLY_AKY_USE_SoftAndHard_Noise_Agglomerated = 1
        ENDIF
        
        ;Any noise?
        IFDEF PLY_AKY_USE_SoftAndHard_Noise_Agglomerated
                PLY_AKY_USE_Noise = 1
        ENDIF
        IFDEF PLY_CFG_NoSoftNoHard_Noise
                PLY_AKY_USE_Noise = 1
        ENDIF
        IFDEF PLY_CFG_SoftOnly_Noise
                PLY_AKY_USE_Noise = 1
        ENDIF
        
 
        ;Disark macro: Word region Start.
        disarkCounter = 0
        IFNDEF dkws
        MACRO dkws
PLY_AKY_DisarkWordRegionStart_{disarkCounter}
        ENDM
        ENDIF
        ;Disark macro: Word region End.
        IFNDEF dkwe
        MACRO dkwe
PLY_AKY_DisarkWordRegionEnd_{disarkCounter}:
        disarkCounter = disarkCounter + 1
        ENDM
        ENDIF
        
        ;Disark macro: Pointer region Start.
        disarkCounter = 0
        IFNDEF dkps
        MACRO dkps
PLY_AKY_DisarkPointerRegionStart_{disarkCounter}
        ENDM
        ENDIF
        ;Disark macro: Pointer region End.
        IFNDEF dkpe
        MACRO dkpe
PLY_AKY_DisarkPointerRegionEnd_{disarkCounter}:
        disarkCounter = disarkCounter + 1
        ENDM
        ENDIF
        
        ;Disark macro: Byte region Start.
        disarkCounter = 0
        IFNDEF dkbs
        MACRO dkbs
PLY_AKY_DisarkByteRegionStart_{disarkCounter}
        ENDM
        ENDIF
        ;Disark macro: Byte region End.
        IFNDEF dkbe
        MACRO dkbe
PLY_AKY_DisarkByteRegionEnd_{disarkCounter}:
        disarkCounter = disarkCounter + 1
        ENDM
        ENDIF

        ;Disark macro: Force "No Reference Area" for 3 bytes (ld hl,xxxx).
        IFNDEF dknr3
        MACRO dknr3
PLY_AKY_DisarkForceNonReferenceDuring3_{disarkCounter}:
        disarkCounter = disarkCounter + 1
        ENDM
        ENDIF
        
        ;-------------------------------------------------------

        ;Hooks for external calls. Can be removed if not needed.
        if PLY_AKY_UseHooks
                assert PLY_AKY_Start == $               ;Makes sure no byte has been added before the hooks.
                jp PLY_AKY_Init             ;Player + 0.
                jp PLY_AKY_Play             ;Player + 3.
        endif

        ;Includes the sound effects player, if wanted. Important to do it as soon as possible, so that
        ;its code can react to the Player Configuration and possibly alter it.
        IFDEF PLY_AKY_MANAGE_SOUND_EFFECTS

;       Player of sound effects, for AKY the player, format V2 (including speed).
;       This file is meant to be included to the AKY *MultiPsg* player, do not use it stand-alone.
;       If you want sound effects without music, there is a specific player for that.

        ;Is there a loaded Player Configuration source? If no, use a default configuration.
        
        IFNDEF PLY_CFG_SFX_ConfigurationIsPresent
                PLY_CFG_UseHardwareSounds = 1
                PLY_CFG_SFX_LoopTo = 1
                PLY_CFG_SFX_NoSoftNoHard = 1
                PLY_CFG_SFX_NoSoftNoHard_Noise = 1
                PLY_CFG_SFX_SoftOnly = 1
                PLY_CFG_SFX_SoftOnly_Noise = 1
                PLY_CFG_SFX_HardOnly = 1
                PLY_CFG_SFX_HardOnly_Noise = 1
                PLY_CFG_SFX_HardOnly_Retrig = 1
                PLY_CFG_SFX_SoftAndHard = 1
                PLY_CFG_SFX_SoftAndHard_Noise = 1
                PLY_CFG_SFX_SoftAndHard_Retrig = 1
        ENDIF
        
;       Agglomerates some Player Configuration flags.
;       --------------------------------------------
;       Mixes the Hardware flags into one.
        IFDEF PLY_CFG_SFX_HardOnly
                PLY_AKY_SE_HardwareSounds = 1
        ENDIF
        IFDEF PLY_CFG_SFX_SoftAndHard
                PLY_AKY_SE_HardwareSounds = 1
        ENDIF
;       Mixes the Hardware Noise flags into one.
        IFDEF PLY_CFG_SFX_HardOnly_Noise
                PLY_AKY_SE_HardwareNoise = 1
        ENDIF
        IFDEF PLY_CFG_SFX_SoftAndHard_Noise
                PLY_AKY_SE_HardwareNoise = 1
        ENDIF
;       Mixes the Noise flags into one.
        IFDEF PLY_AKY_SE_HardwareNoise
                PLY_AKY_SE_Noise = 1
        ENDIF
        IFDEF PLY_CFG_SFX_NoSoftNoHard_Noise
                PLY_AKY_SE_Noise = 1
        ENDIF
        IFDEF PLY_CFG_SFX_SoftOnly
                PLY_AKY_SE_Noise = 1
        ENDIF
;       If Noise, the R6 code in the music player must be compiled.
        IFDEF PLY_AKY_SE_Noise
                PLY_AKY_Use_NoiseRegister = 1
        ENDIF

;       Mixes the Software Volume flags into one.
        IFDEF PLY_CFG_SFX_NoSoftNoHard
                PLY_AKY_SE_VolumeSoft = 1
                PLY_AKY_SE_VolumeSoftOrHard = 1
        ENDIF
        IFDEF PLY_CFG_SFX_SoftOnly
                PLY_AKY_SE_VolumeSoft = 1
                PLY_AKY_SE_VolumeSoftOrHard = 1
        ENDIF
;       Mixes the volume (soft/hard) into one.
        IFDEF PLY_CFG_UseHardwareSounds
                PLY_AKY_SE_VolumeSoftOrHard = 1
        ENDIF
;       Mixes the retrig flags into one.
        IFDEF PLY_CFG_SFX_HardOnly_Retrig
                PLY_AKY_SE_Retrig = 1
        ENDIF
        IFDEF PLY_CFG_SFX_SoftAndHard_Retrig
                PLY_AKY_SE_Retrig = 1
        ENDIF
        

        ;Disark macro: Word region Start.
        disarkCounter = 0
        IFNDEF dkws
        MACRO dkws
PLY_AKY_DisarkWordRegionStart_{disarkCounter}
        ENDM
        ENDIF
        ;Disark macro: Word region End.
        IFNDEF dkwe
        MACRO dkwe
PLY_AKY_DisarkWordRegionEnd_{disarkCounter}:
        disarkCounter = disarkCounter + 1
        ENDM
        ENDIF
        
        ;Disark macro: Pointer region Start.
        disarkCounter = 0
        IFNDEF dkps
        MACRO dkps
PLY_AKY_DisarkPointerRegionStart_{disarkCounter}
        ENDM
        ENDIF
        ;Disark macro: Pointer region End.
        IFNDEF dkpe
        MACRO dkpe
PLY_AKY_DisarkPointerRegionEnd_{disarkCounter}:
        disarkCounter = disarkCounter + 1
        ENDM
        ENDIF
        
        ;Disark macro: Byte region Start.
        disarkCounter = 0
        IFNDEF dkbs
        MACRO dkbs
PLY_AKY_DisarkByteRegionStart_{disarkCounter}
        ENDM
        ENDIF
        ;Disark macro: Byte region End.
        IFNDEF dkbe
        MACRO dkbe
PLY_AKY_DisarkByteRegionEnd_{disarkCounter}:
        disarkCounter = disarkCounter + 1
        ENDM
        ENDIF

        ;Disark macro: Force "No Reference Area" for 3 bytes (ld hl,xxxx).
        IFNDEF dknr3
        MACRO dknr3
PLY_AKY_DisarkForceNonReferenceDuring3_{disarkCounter}:
        disarkCounter = disarkCounter + 1
        ENDM
        ENDIF



;Initializes the sound effects. It MUST be called at any times before a first sound effect is triggered.
;It doesn't matter whether the song is playing or not, or if it has been initialized or not.
;IN:    HL = Address to the sound effects data.
PLY_AKY_InitSoundEffectsDisarkGenerateExternalLabel
PLY_AKY_InitSoundEffects:
        ld (PLY_AKY_PtSoundEffectTable + PLY_AKY_Offset1b),hl
        ret


;Plays a sound effect. If a previous one was already playing on the same channel, it is replaced.
;This does not actually plays the sound effect, but programs its playing.
;The music player, when called, will call the PLY_AKY_PlaySoundEffectsStream method below.
;IN:    A = Sound effect number (>0!).
;       C = The channel where to play the sound effect (0, 1, 2).
;       B = Inverted volume (0 = full volume, 16 = no sound). Hardware sounds are also lowered.
PLY_AKY_PlaySoundEffectDisarkGenerateExternalLabel
PLY_AKY_PlaySoundEffect:

        ;Gets the address to the sound effect.
        dec a                   ;The 0th is not encoded.
        IFNDEF PLY_AKY_Rom
dknr3:
PLY_AKY_PtSoundEffectTable: ld hl,0
        ELSE
        ld hl,(PLY_AKY_PtSoundEffectTable)
        ENDIF
        ld e,a
        ld d,0
        add hl,de
        add hl,de
        ld e,(hl)
        inc hl
        ld d,(hl)
        ;Reads the header of the sound effect to get the speed.
        ld a,(de)
        inc de
        ex af,af'

        ld a,b

        ;Finds the pointer to the sound effect of the desired channel.
        ld hl,PLY_AKY_Channel1_SoundEffectData
        ld b,0
        sla c
        sla c
        sla c
        add hl,bc
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl        
        
        ;Now stores the inverted volume.
        ld (hl),a
        inc hl
        
        ;Resets the current speed, stores the instrument speed.
        ld (hl),0
        inc hl
        ex af,af'
        ld (hl),a

        ret

;Stops a sound effect. Nothing happens if there was no sound effect.
;IN:    A = The channel where to stop the sound effect (0, 1, 2).
PLY_AKY_StopSoundEffectFromChannelDisarkGenerateExternalLabel
PLY_AKY_StopSoundEffectFromChannel:
        ;Puts 0 to the pointer of the sound effect.
        add a,a
        add a,a
        add a,a
        ld e,a
        ld d,0
        ld hl,PLY_AKY_Channel1_SoundEffectData
        add hl,de
        ld (hl),d               ;0 means "no sound".
        inc hl
        ld (hl),d
        ret

;Plays the sound effects, if any has been triggered by the user.
;This does not actually send registers to the PSG, it only overwrite the required values of the registers of the player.
;The sound effects initialization method must have been called before!
;As R7 is required, this must be called after the music has been played, but BEFORE the registers are sent to the PSG.
;IN:    A = R7.
;OUT:   A = new R7.
PLY_AKY_PlaySoundEffectsStream:
        ;Shifts the R7 to the left twice, so that bit 2 and 5 only can be set for each track, below.
        rla
        rla

        ;Plays the sound effects on every channel.
        ld ix,PLY_AKY_Channel1_SoundEffectData
        ld iy,PLY_AKY_SfxReg8
        ld hl,PLY_AKY_SfxReg01
        exx
        ld c,a
        ;Channel 1.
        ;----------
        call PLY_AKY_PSES_Play
        ld ix,PLY_AKY_Channel2_SoundEffectData
        ld iy,PLY_AKY_SfxReg9
        exx
                ld hl,PLY_AKY_SfxReg23
        exx
        ;Channel 2.
        ;----------
        IFDEF PLY_AKY_HARDWARE_CPC
                srl c                                                   ;Not RR, to make sure bit 6 is 0 (else, no more keyboard on CPC!).
        ELSE
                IFDEF PLY_AKY_HARDWARE_MSX
                        srl c                                           ;R7 bit 6 on MSX must be 0.
                ELSE
                        rr c                                            ;On other platforms, we don't care.
                ENDIF
        ENDIF

        call PLY_AKY_PSES_Play
        ld ix,PLY_AKY_Channel3_SoundEffectData
        ld iy,PLY_AKY_SfxReg10
        exx
                ld hl,PLY_AKY_SfxReg45
        exx
        ;Channel 3.
        ;----------
        IFDEF PLY_AKY_HARDWARE_MSX
                scf                                                    ;R7 bit 7 on MSX must be 1.
        ENDIF
        rr c
        call PLY_AKY_PSES_Play

        ld a,c
        ret


;Plays the sound stream from the given pointer to the sound effect. If 0, no sound is played.
;The given R7 is given shift twice to the left, so that this code MUST set/reset the bit 2 (sound), and maybe reset bit 5 (noise).
;This code MUST overwrite these bits because sound effects have priority over the music.
;IN:    IX = Points on the sound effect pointer. If the sound effect pointer is 0, nothing must be played.
;       IY = Points on the address where to store the volume for this channel.
;       HL'= Points on the address where to store the software period for this channel.
;       C = R7, shifted twice to the left.
;OUT:   The pointed pointer by IX may be modified as the sound advances.
;       C = R7, MUST be modified if there is a sound effect.
PLY_AKY_PSES_Play:
        ;Reads the pointer pointed by IX.
        ld l,(ix + 0)
        ld h,(ix + 1)
        ld a,l
        or h
        ret z           ;No sound to be played? Returns immediately.

        ;Reads the first byte. What type of sound is it?
PLY_AKY_PSES_ReadFirstByte:
        ld a,(hl)
        inc hl
        ld b,a
        rra
        jr c,PLY_AKY_PSES_SoftwareOrSoftwareAndHardware
        rra
                        IFDEF PLY_CFG_SFX_HardOnly              ;CONFIG SPECIFIC
        jr c,PLY_AKY_PSES_HardwareOnly
                        ENDIF ;PLY_CFG_SFX_HardOnly

        ;No software, no hardware, or end/loop.
        ;-------------------------------------------
        ;End or loop?
        rra
                        IFDEF PLY_CFG_SFX_NoSoftNoHard         ;CONFIG SPECIFIC. If not present, the jump is not needed, the method is just below.
        jr c,PLY_AKY_PSES_S_EndOrLoop

        ;No software, no hardware.
        ;-------------------------------------------
        ;Gets the volume.
        call PLY_AKY_PSES_ManageVolumeFromA_Filter4Bits

        ;Noise?
                                        IFDEF PLY_CFG_SFX_NoSoftNoHard_Noise                ;CONFIG SPECIFIC
        rl b        
        call c,PLY_AKY_PSES_ReadNoiseAndOpenNoiseChannel
                                        ENDIF ;PLY_CFG_SFX_NoSoftNoHard_Noise

        jr PLY_AKY_PSES_SavePointerAndExit
                        ENDIF ;PLY_CFG_SFX_NoSoftNoHard

        ;**Warning!** Do not put any instruction between EndOrLoop and NoSoftNoHard.

PLY_AKY_PSES_S_EndOrLoop:
                        IFDEF PLY_CFG_SFX_LoopTo                ;CONFIG SPECIFIC. If no "loop to", the sounds always end, no need to test.
        ;Is it an end?
        rra
        jr c,PLY_AKY_PSES_S_Loop
                        ENDIF ;PLY_CFG_SFX_LoopTo
        ;End of the sound. Marks the sound pointer with 0, meaning "no sound".
        xor a
        ld (ix + 0),a
        ld (ix + 1),a
        ret
                        IFDEF PLY_CFG_SFX_LoopTo                ;CONFIG SPECIFIC.
PLY_AKY_PSES_S_Loop:
        ;Loops. Reads the pointer and directly uses it.
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        jr PLY_AKY_PSES_ReadFirstByte
                        ENDIF ;PLY_CFG_SFX_LoopTo
                        

;Saves HL into IX, and exits. This must be called at the end of each Cell.
;If the speed has not been reached, it is not saved.
PLY_AKY_PSES_SavePointerAndExit:
        ;Speed reached?
        ld a,(ix + PLY_AKY_SoundEffectData_OffsetCurrentStep)
        cp (ix + PLY_AKY_SoundEffectData_OffsetSpeed)
        jr c,PLY_AKY_PSES_NotReached
        ;The speed has been reached, so resets it and saves the pointer to the next cell to read.
        ld (ix + PLY_AKY_SoundEffectData_OffsetCurrentStep),0
        ld (ix + 0),l
        ld (ix + 1),h
        ret
PLY_AKY_PSES_NotReached:
        ;Speed not reached. Increases it, that's all. The same cell will be read next time.
        inc (ix + PLY_AKY_SoundEffectData_OffsetCurrentStep)
        ret

                        IFDEF PLY_CFG_SFX_HardOnly         ;CONFIG SPECIFIC
        ;Hardware only.
        ;-------------------------------------------
PLY_AKY_PSES_HardwareOnly:
        ;Calls the shared code that manages everything.
        call PLY_AKY_PSES_Shared_ReadRetrigHardwareEnvPeriodNoise
        ;Cuts the sound.
        set 2,c

        jr PLY_AKY_PSES_SavePointerAndExit
                        ENDIF ;PLY_CFG_SFX_HardOnly



PLY_AKY_PSES_SoftwareOrSoftwareAndHardware:
        ;Software only?
        rra
                        IFDEF PLY_CFG_SFX_SoftAndHard         ;CONFIG SPECIFIC
        jr c,PLY_AKY_PSES_SoftwareAndHardware
                        ENDIF ;PLY_CFG_SFX_SoftAndHard

        ;Software.
        ;-------------------------------------------
                        IFDEF PLY_CFG_SFX_SoftOnly          ;CONFIG SPECIFIC
        ;Volume.
        call PLY_AKY_PSES_ManageVolumeFromA_Filter4Bits

        ;Noise?
        rl b
                                IFDEF PLY_CFG_SFX_SoftOnly_Noise                ;CONFIG SPECIFIC
        call c,PLY_AKY_PSES_ReadNoiseAndOpenNoiseChannel
                                ENDIF ;PLY_CFG_SFX_SoftOnly_Noise
                                
        ;Opens the "sound" channel.
        res 2,c

        ;Reads the software period.
        call PLY_AKY_PSES_ReadSoftwarePeriod

        jr PLY_AKY_PSES_SavePointerAndExit
                        ENDIF ;PLY_CFG_SFX_SoftOnly
                        

        ;Software and Hardware.
        ;-------------------------------------------
                        IFDEF PLY_AKY_SE_HardwareSounds         ;CONFIG SPECIFIC
PLY_AKY_PSES_SoftwareAndHardware:
        ;Calls the shared code that manages everything.
        call PLY_AKY_PSES_Shared_ReadRetrigHardwareEnvPeriodNoise

        ;Reads the software period.
        call PLY_AKY_PSES_ReadSoftwarePeriod

        ;Opens the sound.
        res 2,c

        jr PLY_AKY_PSES_SavePointerAndExit
                        ENDIF ;PLY_AKY_SE_HardwareSounds


                        IFDEF PLY_CFG_UseHardwareSounds         ;CONFIG SPECIFIC
        ;Shared code used by the "hardware only" and "software and hardware" part.
        ;Reads the Retrig flag, the Hardware Envelope, the possible noise, the hardware period,
        ;and sets the volume to 16. The R7 sound channel is NOT modified.
PLY_AKY_PSES_Shared_ReadRetrigHardwareEnvPeriodNoise:
        ;Retrig?
        rra
                                IFDEF PLY_AKY_SE_Retrig                  ;CONFIG SPECIFIC
        jr nc,PLY_AKY_PSES_H_AfterRetrig
        ld d,a
        ld a,255
        ld (PLY_AKY_SfxRetrig),a
        ld a,d
PLY_AKY_PSES_H_AfterRetrig:
                                ENDIF ;PLY_AKY_SE_Retrig

        ;The hardware envelope can be set (8-15).
        and %111
        add a,8
        ld (PLY_AKY_SfxReg13),a

                                IFDEF PLY_AKY_SE_HardwareNoise           ;CONFIG SPECIFIC. B not needed after, we can put it in the condition too.
        ;Noise?
        rl b
        call c,PLY_AKY_PSES_ReadNoiseAndOpenNoiseChannel
                                ENDIF ;PLY_AKY_SE_HardwareNoise

        ;Reads the hardware period.
        call PLY_AKY_PSES_ReadHardwarePeriod

        ;Sets the volume to "hardware". It still may be decreased.
        ld a,16
        jp PLY_AKY_PSES_ManageVolumeFromA_Hard
                        ENDIF ;PLY_CFG_UseHardwareSounds
                        

                        IFDEF PLY_AKY_SE_Noise
;Reads the noise pointed by HL, increases HL, and opens the noise channel.
PLY_AKY_PSES_ReadNoiseAndOpenNoiseChannel:
        ;Reads the noise.
        ld a,(hl)
        ld (PLY_AKY_SfxReg6),a
        inc hl

        ;Opens noise channel.
        res 5,c
        ret
                        ENDIF ;PLY_AKY_SE_Noise

                        IFDEF PLY_CFG_UseHardwareSounds         ;CONFIG SPECIFIC
;Reads the hardware period from HL and sets the R11/R12 registers. HL is incremented of 2.
PLY_AKY_PSES_ReadHardwarePeriod:
        ld a,(hl)
        ld (PLY_AKY_SfxHardwarePeriod),a
        inc hl
        ld a,(hl)
        ld (PLY_AKY_SfxHardwarePeriod + 1),a
        inc hl
        ret
                        ENDIF ;PLY_CFG_UseHardwareSounds

;Reads the software period from HL and sets the period registers in HL'. HL is incremented of 2.
PLY_AKY_PSES_ReadSoftwarePeriod:
        ld a,(hl)
        inc hl
        exx
                ld (hl),a
                inc hl
        exx
        ld a,(hl)
        inc hl
        exx
                ld (hl),a
        exx
        ret

                        IFDEF PLY_AKY_SE_VolumeSoft      ;CONFIG SPECIFIC
;Reads the volume in A, decreases it from the inverted volume of the channel, and sets the volume via IY.
;IN:    A = volume, from 0 to 15 (no hardware envelope).
PLY_AKY_PSES_ManageVolumeFromA_Filter4Bits:
        and %1111
                        ENDIF ;PLY_AKY_SE_VolumeSoft
                        IFDEF PLY_AKY_SE_VolumeSoftOrHard        ;CONFIG SPECIFIC
;After the filtering. Useful for hardware sound (volume has been forced to 16).
PLY_AKY_PSES_ManageVolumeFromA_Hard:
        ;Decreases the volume, checks the limit.
        sub (ix + PLY_AKY_SoundEffectData_OffsetInvertedVolume)
        jr nc,PLY_AKY_PSES_MVFA_NoOverflow
        xor a
PLY_AKY_PSES_MVFA_NoOverflow:
        ld (iy + 0),a
        ret
                        ENDIF ;PLY_AKY_SE_VolumeSoftOrHard
                        

        ;The data for RAM player. For ROM player, it is declared in the main player.
        IFNDEF PLY_AKY_Rom
;The data of the Channels MUST be consecutive.
PLY_AKY_Channel1_SoundEffectData:
dkws
        dw 0                                            ;Points to the sound effect for the track 1, or 0 if not playing.
dkwe
dkbs
PLY_AKY_Channel1_SoundEffectInvertedVolume:
        db 0                                            ;Inverted volume.
PLY_AKY_Channel1_SoundEffectCurrentStep:
        db 0                                            ;Current step (>=0).
PLY_AKY_Channel1_SoundEffectSpeed:
        db 0                                            ;Speed (>=0).
        ds 3,0                                          ;Padding.
dkbe
PLY_AKY_Channel_SoundEffectDataSize: equ $ - PLY_AKY_Channel1_SoundEffectData
    
dkbs
PLY_AKY_Channel2_SoundEffectData:
        ds PLY_AKY_Channel_SoundEffectDataSize, 0
PLY_AKY_Channel3_SoundEffectData:
        ds PLY_AKY_Channel_SoundEffectDataSize, 0
dkbe

        ;Checks that the pointers are consecutive.
        assert (PLY_AKY_Channel1_SoundEffectData + PLY_AKY_Channel_SoundEffectDataSize) == PLY_AKY_Channel2_SoundEffectData
        assert (PLY_AKY_Channel2_SoundEffectData + PLY_AKY_Channel_SoundEffectDataSize) == PLY_AKY_Channel3_SoundEffectData
        
        ENDIF ;PLY_AKY_Rom

;Offset from the beginning of the data, to reach the inverted volume.
PLY_AKY_SoundEffectData_OffsetInvertedVolume: equ PLY_AKY_Channel1_SoundEffectInvertedVolume - PLY_AKY_Channel1_SoundEffectData
PLY_AKY_SoundEffectData_OffsetCurrentStep: equ PLY_AKY_Channel1_SoundEffectCurrentStep - PLY_AKY_Channel1_SoundEffectData
PLY_AKY_SoundEffectData_OffsetSpeed: equ PLY_AKY_Channel1_SoundEffectSpeed - PLY_AKY_Channel1_SoundEffectData


        ENDIF ;PLY_AKY_MANAGE_SOUND_EFFECTS
        ;[[INSERT_SOUND_EFFECT_SOURCE]]                 ;A tag for test units. Don't touch or you're dead.


;       Initializes the player.
;       HL = music address.
PLY_AKY_InitDisarkGenerateExternalLabel:
PLY_AKY_Init:
        ;Skips the header.
        inc hl                          ;Skips the format version.
        ld a,(hl)                       ;Channel count.
        inc hl
        
        ;Initializes the PlayCity with the frequencies of all the PSGs from the header.
        IFDEF PLY_AKY_HARDWARE_PLAYCITY
                ;Reads the first frequency, apply it to both PlayCity YMZ.
                ex de,hl
                call PLY_AKY_FindFrequencyAndSetYMZ
                ex de,hl
        ENDIF
        
        ;Skips the frequencies.
dknr3:  ld de,4 * PLY_AKY_PsgCount
        add hl,de
        ld (PLY_AKY_PtLinker + PLY_AKY_Offset1b),hl        ;HL now points on the Linker.

        ld a,PLY_AKY_OPCODE_OR_A
        REPEAT PLY_AKY_ChannelCount, channelNumber
                ld (PLY_AKY_Channel{channelNumber}_RegisterBlockLineState_Opcode),a
        REND
dknr3:  ld hl,1
        ld (PLY_AKY_PatternFrameCounter + PLY_AKY_Offset1b),hl
        ret


        ;--------------------------------------------------------------
        IFDEF PLY_AKY_HARDWARE_PLAYCITY         ;PlayCity-specific.
;Sets the YMZ frequency according to the one given. If not found, nothing is done (Atari ST is set by default, which is good, as it is the only way to select it).
;In all cases, the PlayCity is reset.
;IN:    DE = Points on the 32 bits little-endian PSG frequency that we want to set to the PlayCity.
;MOD:   DE is preserved.
PLY_AKY_FindFrequencyAndSetYMZ:
        ;Resets the PlayCity (= sets the frequencies to 2Mhz (Atari ST)).
dknr3:  ld bc,PLY_AKY_PLAYCITY_WRITE_PORT_MSB * 256 + #ff
        out (c),c

        ld a,PLY_AKY_PSGFrequenciesToYMZFlag_Count
        ex af,af'

        ;IX points on the frequency of the song.
        ld ixl,e
        ld ixh,d

        ;IY points on the frequency look-up table.
        ld iy,PLY_AKY_PSGFrequenciesToYMZFlag
PLY_AKY_FindFrequencyAndSetYMZ_Loop:
        ld a,(ix + 0)
        cp (iy + 0)
        jr nz,PLY_AKY_FindFrequencyAndSetYMZ_Next
        ld a,(ix + 1)
        cp (iy + 1)
        jr nz,PLY_AKY_FindFrequencyAndSetYMZ_Next
        ld a,(ix + 2)
        cp (iy + 2)
        jr nz,PLY_AKY_FindFrequencyAndSetYMZ_Next
        ld a,(ix + 3)
        cp (iy + 3)
        jr nz,PLY_AKY_FindFrequencyAndSetYMZ_Next
        ;Match!
        ld a,(iy + 4)           ;Gets the frequency index.
dknr3:  ld bc,PLY_AKY_PLAYCITY_WRITE_PORT_MSB * 256 + #80   ;#f880
        ld h,#7f
        out (c),h                                       ;Clock generator.
        out (c),a                                       ;Sends frequency index.

        ret

PLY_AKY_FindFrequencyAndSetYMZ_Next
        ex af,af'
        dec a
        ret z                                           ;No match! Returns (default to Atari ST).

        ex af,af'

        ;Next frequency!
dknr3:  ld bc,5
        add iy,bc
        jr PLY_AKY_FindFrequencyAndSetYMZ_Loop

;The frequencies (hz) to YMZ flag (index).
PLY_AKY_PSGFrequenciesToYMZFlag:
dkbs
        db #40, #42, #f, 0,             1               ;1000000        CPC
        db #60, #e3, #16, #0,           2               ;1500000
        db #70, #7b, #19, #0,           3               ;1670000
        db #f0, #b3, #1a, #0,           4               ;1750000        ZX
        db #40, #77, #1b, #0,           5               ;1800000        ~MSX
        db #70, #ec, #1b, #0,           6               ;1830000
        db #a0, #61, #1c, #0,           7               ;1860000
        db #c0, #af, #1c, #0,           8               ;1880000
        db #d0, #d6, #1c, #0,           9               ;1890000
        db #e0, #fd, #1c, #0,           10              ;1900000
        db #f0, #24, #1d, #0,           11              ;1910000
        db #00, #4c, #1d, #0,           12              ;1920000
        db #00, #4c, #1d, #0,           13              ;1920000        ;No change
        db #10, #73, #1d, #0,           14              ;1930000
        db #10, #73, #1d, #0,           15              ;1930000        ;No change
        db #70, #5d, #1e, #0,           0               ;1990000        ;~ST
dkbe
PLY_AKY_PSGFrequenciesToYMZFlag_End:

PLY_AKY_PSGFrequenciesToYMZFlag_Count: equ (PLY_AKY_PSGFrequenciesToYMZFlag_End - PLY_AKY_PSGFrequenciesToYMZFlag) / 5

        ENDIF ;PLY_AKY_HARDWARE_PLAYCITY
        ;-------------------------------------------------------------------------------




;       Plays the music. It must have been initialized before.
;       The interruption SHOULD be disabled (DI), as the stack is heavily used.
PLY_AKY_PlayDisarkGenerateExternalLabel:
PLY_AKY_Play:
        ld (PLY_AKY_SaveSp + PLY_AKY_Offset1b),sp

        ;Special case for Darky. Must be done once before messing with the PSGs.
        IFDEF PLY_AKY_HARDWARE_DARKY
                ld a,#aa
                out (#40),a
        ENDIF


;Linker.
;----------------------------------------
        IFNDEF PLY_AKY_ROM
dknr3:
PLY_AKY_PatternFrameCounter: ld hl,1                ;How many frames left before reading the next Pattern.
        ELSE
        ld hl,(PLY_AKY_PatternFrameCounter)
        ENDIF
        dec hl
        ld a,l
        or h
        jr z,PLY_AKY_PatternFrameCounter_Over
        ld (PLY_AKY_PatternFrameCounter + PLY_AKY_Offset1b),hl
        ;The pattern is not over.
        IFNDEF PLY_AKY_ROM
        jr PLY_AKY_Channel1_WaitBeforeNextRegisterBlock
        ELSE
        jr PLY_AKY_Channel1_WaitBeforeNextRegisterBlock_Start
        ENDIF

PLY_AKY_PatternFrameCounter_Over:

;The pattern is over. Reads the next one.
        IFNDEF PLY_AKY_ROM
dknr3:
PLY_AKY_PtLinker: ld sp,0                                   ;Points on the Pattern of the linker.
        ELSE
        ld sp,(PLY_AKY_PtLinker)                            ;Points on the Pattern of the linker.
        ENDIF
        pop hl                                          ;Gets the duration of the Pattern, or 0 if end of the song.
        ld a,l
        or h
        jr nz,PLY_AKY_LinkerNotEndSong
        ;End of the song. Where to loop?
        pop hl
        ;We directly point on the frame counter of the pattern to loop to.
        ld sp,hl
        ;Gets the duration again. No need to check the end of the song,
        ;we know it contains at least one pattern.
        pop hl
PLY_AKY_LinkerNotEndSong:
        ld (PLY_AKY_PatternFrameCounter + PLY_AKY_Offset1b),hl

        REPEAT PLY_AKY_ChannelCount, channelNumber
                pop hl
                ld (PLY_AKY_Channel{channelNumber}_PtTrack + PLY_AKY_Offset1b),hl
        REND
        ld (PLY_AKY_PtLinker + PLY_AKY_Offset1b),sp

        ;Resets the RegisterBlocks of the channel >1. The first one is skipped so there is no need to do so.
        ld a,1
        REPEAT PLY_AKY_ChannelCount - 1, channelNumber
                ld (PLY_AKY_Channel{channelNumber+1}_WaitBeforeNextRegisterBlock + PLY_AKY_Offset1b),a
        REND
        jr PLY_AKY_Channel1_WaitBeforeNextRegisterBlock_Over

;Reading the Tracks.
;----------------------------------------

        REPEAT PLY_AKY_ChannelCount, channelNumber                        ; ------------------------------------ REPEAT

        IFNDEF PLY_AKY_ROM
PLY_AKY_Channel{channelNumber}_WaitBeforeNextRegisterBlock: ld a,1        ;Frames to wait before reading the next RegisterBlock. 0 = finished.
        ELSE
PLY_AKY_Channel{channelNumber}_WaitBeforeNextRegisterBlock_Start:
        ld a,(PLY_AKY_Channel{channelNumber}_WaitBeforeNextRegisterBlock)
        ENDIF
        dec a
        jr nz,PLY_AKY_Channel{channelNumber}_RegisterBlock_Process
PLY_AKY_Channel{channelNumber}_WaitBeforeNextRegisterBlock_Over:
        ;This RegisterBlock is finished. Reads the next one from the Track.
        ;Obviously, starts at the initial state.
        ld a,PLY_AKY_OPCODE_OR_A
        ld (PLY_AKY_Channel{channelNumber}_RegisterBlockLineState_Opcode),a
        IFNDEF PLY_AKY_ROM
dknr3:
PLY_AKY_Channel{channelNumber}_PtTrack: ld sp,0                   ;Points on the Track.
        ELSE
        ld sp,(PLY_AKY_Channel{channelNumber}_PtTrack)
        ENDIF
        dec sp                                  ;Only one byte is read. Compensate.
        pop af                                  ;Gets the duration.
        pop hl                                  ;Reads the RegisterBlock address.

        ld (PLY_AKY_Channel{channelNumber}_PtTrack + PLY_AKY_Offset1b),sp
        ld (PLY_AKY_Channel{channelNumber}_PtRegisterBlock + PLY_AKY_Offset1b),hl

        ;A is the duration of the block.
PLY_AKY_Channel{channelNumber}_RegisterBlock_Process:
        ;Processes the RegisterBlock, whether it is the current one or a new one.
        ld (PLY_AKY_Channel{channelNumber}_WaitBeforeNextRegisterBlock + PLY_AKY_Offset1b),a
        
        REND                                                            ; ------------------------------------ REPEAT END













;Reading the RegisterBlock, for each channel of each PSG.
;-----------------------------------------------------------------

;This macro takes care of reading the RegisterBlock for one channel.        
        MACRO PLY_AKY_ReadRegisterBlockMacro, channelNumber          ;-------------------------------------------------

        ld ix,PLY_AKY_Channel{channelNumber}_RegisterBase

        IFNDEF PLY_AKY_ROM
dknr3:
PLY_AKY_Channel{channelNumber}_PtRegisterBlock: ld hl,0                   ;Points on the data of the RegisterBlock to read.
        ELSE
        ld hl,(PLY_AKY_Channel{channelNumber}_PtRegisterBlock)
        ENDIF

        IFNDEF PLY_AKY_ROM
PLY_AKY_Channel{channelNumber}_RegisterBlockLineState_Opcode: or a        ;"or a" if initial state, "scf" (#37) if non-initial state.
        ELSE
        ld a,(PLY_AKY_Channel{channelNumber}_RegisterBlockLineState_Opcode)
        add a,a                                             ;Carry is set according to the opcode.
        ENDIF
        jp PLY_AKY_ReadRegisterBlock
PLY_AKY_Channel{channelNumber}_RegisterBlock_Return:
        ld a,PLY_AKY_OPCODE_SCF
        ld (PLY_AKY_Channel{channelNumber}_RegisterBlockLineState_Opcode),a
        ld (PLY_AKY_Channel{channelNumber}_PtRegisterBlock + PLY_AKY_Offset1b),hl        ;This is new pointer on the RegisterBlock.
        
        ENDM                                                    ;--------------------------------------------------

        currentChannel = 1

        ld sp,PLY_AKY_RetTable_ReadRegisterBlock

        REPEAT PLY_AKY_PsgCount, psgNumber                              ;-------------------------------------- LOOP FOR EACH PSG.

        ld iy,PLY_AKY_Psg{psgNumber}HardwareRegisterArray

        ;Channel 1
        ;---------
        ;In B, R7 with default values: fully sound-open but noise-close.
        ;R7 has been shift twice to the left, it will be shifted back as the channels are treated.
        ld b,%11100000

        PLY_AKY_ReadRegisterBlockMacro {currentChannel}
        currentChannel = currentChannel + 1
        
        ;Channel 2
        ;---------
        ;Shifts the R7 for the next channels.
        srl b           ;Not RR, because we have to make sure the b6 is 0, else no more keyboard (on CPC)!
                        ;Also, on MSX, bit 6 must be 0.
        
        PLY_AKY_ReadRegisterBlockMacro {currentChannel}
        currentChannel = currentChannel + 1
        
        ;Channel 3
        ;---------
        ;Shifts the R7 for the next channels.
        IFDEF PLY_AKY_HARDWARE_MSX
                scf             ;On MSX, bit 7 must be 1.
                rr b
        ELSE
                rr b            ;Safe to use RR, we don't care if b7 of R7 is 0 or 1.
        ENDIF

        PLY_AKY_ReadRegisterBlockMacro {currentChannel}
        currentChannel = currentChannel + 1
        
        ;Sound effects?
        if PLY_AKY_SFX_PSG_NUMBER == psgNumber          ;If no SFX, the psg number is inaccessible, so nothing to worry about.
                ;If THIS PSG is the SFX PSG, we duplicate the data into a special buffer, which can be modified by the sound effects.
                ;This is necessary because AKY only updates the changing registers, so working on the primary buffers would create
                ;problems in sounds: the music wouldn't overwrite the SFX once they are finished, the next frames will be corrupted.
                ld a,b  ;Saves R7.
                ld hl,PLY_AKY_Psg{psgNumber}SoftwareRegisterArray
                ld de,PLY_AKY_SfxPsgRegisterArray
                ld bc,PLY_AKY_PsgRegisterArray_Size
                ldir

                ;Plays the sound effects.
                ;IN : A = R7
                ;OUT: A = R7, possibly modified.
                ;SP must be saved.
                ld (PLY_AKY_SaveSpTemp + PLY_AKY_Offset1b),sp
                ld sp,(PLY_AKY_SaveSp + PLY_AKY_Offset1b)       ;Gets a "normal" stack we can use.
                call PLY_AKY_PlaySoundEffectsStream
                ld b,a
                ;Restores the stack.
                IFNDEF PLY_AKY_ROM
dknr3:
PLY_AKY_SaveSpTemp: ld sp,0
                ELSE
                ld sp,(PLY_AKY_SaveSpTemp)
                ENDIF
        endif

        ;Before calling the PSG register sending code, a bit of set-up must be code according to the hardware!
        
        ;IFDEF PLY_AKG_HARDWARE_CPC             ;Nothing to do for CPC, the code doesn't need any parameter.
        
        IFDEF PLY_AKG_HARDWARE_SPECTRUM_OR_PENTAGON
                ;Sfx PSG or not? If yes, uses a special buffer.
                if PLY_AKY_SFX_PSG_NUMBER != psgNumber
                        ld hl,PLY_AKY_Psg{psgNumber}SoftwareRegisterArray
                else
                        ld hl,PLY_AKY_SfxPsgRegisterArray       ;SFX PSG. Uses a specific register array.
                endif
        ENDIF
        
        IFDEF PLY_AKY_HARDWARE_PLAYCITY
                ;Nothing to do for PlayCity PSG 2 (CPC PSG).
                if psgNumber != 2
                        ;PSG 1 or 3.
                        ;Sfx PSG or not? If yes, uses a special buffer.
                        if PLY_AKY_SFX_PSG_NUMBER != psgNumber
                                ld hl,PLY_AKY_Psg{psgNumber}SoftwareRegisterArray
                        else
                                ld hl,PLY_AKY_SfxPsgRegisterArray       ;SFX PSG. Uses a specific register array.
                        endif
                endif
                ;Selects the PlayCity PSG.
                if psgNumber == 1
                        ld c,PLY_AKY_PLAYCITY_SELECTWRITE_PORT_LSB_LEFT
                endif
                if psgNumber == 3
                        ld c,PLY_AKY_PLAYCITY_SELECTWRITE_PORT_LSB_RIGHT
                endif
        ENDIF
        
        IFDEF PLY_AKY_HARDWARE_SPECNEXT
                ;Sfx PSG or not? If yes, uses a special buffer.
                if PLY_AKY_SFX_PSG_NUMBER != psgNumber
                        ld hl,PLY_AKY_Psg{psgNumber}SoftwareRegisterArray
                else
                        ld hl,PLY_AKY_SfxPsgRegisterArray       ;SFX PSG. Uses a specific register array.
                endif
                ld d,PLY_AKY_SPECNEXT_PSG{psgNumber}_REGISTER
        ENDIF

        IFDEF PLY_AKY_HARDWARE_TURBOSOUND
                ;Sfx PSG or not? If yes, uses a special buffer.
                if PLY_AKY_SFX_PSG_NUMBER != psgNumber
                        ld hl,PLY_AKY_Psg{psgNumber}SoftwareRegisterArray
                else
                        ld hl,PLY_AKY_SfxPsgRegisterArray       ;SFX PSG. Uses a specific register array.
                endif
                ld d,PLY_AKY_TURBOSOUND_PSG{psgNumber}_REGISTER
        ENDIF
        
        ;Vanilla MSX, FPGA PSG or Darky.
        IFDEF PLY_AKY_HARDWARE_MSX
                ;Sfx PSG or not? If yes, uses a special buffer.
                if PLY_AKY_SFX_PSG_NUMBER != psgNumber
                        ld hl,PLY_AKY_Psg{psgNumber}SoftwareRegisterArray
                else
                        ld hl,PLY_AKY_SfxPsgRegisterArray       ;SFX PSG. Uses a specific register array.
                endif
        ENDIF
        

        ;Register 7 is B.
        ret                     ;Calls the PSG register sending, according to the RET table.
PLY_AKY_Psg{psgNumber}AfterSendingPsgRegisters:

        ;One last step if SFX, the PSG sending register code has probably modified the Retrig byte.
        ;This must be put back from the SFX byte array to the PSG byte array.
        if PLY_AKY_SFX_PSG_NUMBER == psgNumber          ;If no SFX, the psg number is inaccessible, so nothing to worry about.
                ld a,(PLY_AKY_SfxPsgRegisterArray + PLY_AKY_Psg1SoftwareRegisterArray_Size + PLY_AKY_PsgRegister_OffsetRetrig)  ;Skips the software array, the offset is related to the hardware array.
                ld (PLY_AKY_Psg{psgNumber}SoftwareRegisterArray + PLY_AKY_Psg1SoftwareRegisterArray_Size + PLY_AKY_PsgRegister_OffsetRetrig),a
        endif

        REND                                                         ;-------------------------------------- LOOP FOR EACH PSG.



        IFNDEF PLY_AKY_ROM
dknr3:
PLY_AKY_SaveSp: ld sp,0
        ELSE
        ld sp,(PLY_AKY_SaveSp)
        ENDIF
        ret









;Generic code interpreting the RegisterBlock
;IN:    HL = First byte.
;       Carry = 0 = initial state, 1 = non-initial state.
;----------------------------------------------------------------

PLY_AKY_ReadRegisterBlock:
        ;Gets the first byte of the line. What type? Jump to the matching code.
        ld a,(hl)
        inc hl
        jp c,PLY_AKY_RRB_NonInitialState
        ;Initial state.
        rra
        jr c,PLY_AKY_RRB_IS_SoftwareOnlyOrSoftwareAndHardware
        rra
                        IFDEF PLY_CFG_HardOnly  ;CONFIG SPECIFIC
        jr c,PLY_AKY_RRB_IS_HardwareOnly
                        ENDIF ;PLY_CFG_HardOnly
        ;jr PLY_AKY_RRB_IS_NoSoftwareNoHardware

;Generic code interpreting the RegisterBlock - Initial state.
;----------------------------------------------------------------
;IN:    HL = Points after the first byte.
;       A = First byte, twice shifted to the right (type removed).
;       B = Register 7. All sounds are open (0) by default, all noises closed (1). The code must put ONLY bit 2 and 5 for sound and noise respectively. NOT any other bits!
;       C = May be used as a temp.
;       DE = free to use.
;       IX = Points on the software registers array.
;       IY = Points on the hardware registers array.

;       A' = free to use (not used).
;       DE' = f4f6
;       BC' = f680
;       L' = Volume register.
;       H' = LSB frequency register.

;OUT:   HL MUST points after the structure.
;       B = updated (ONLY bit 2 and 5).
;       L' = Volume register increased of 1 (*** IMPORTANT! The code MUST increase it, even if not using it! ***)
;       H' = LSB frequency register, increased of 2 (see above).
;       DE' = unmodified (f4f6)
;       BC' = unmodified (f680)

PLY_AKY_RRB_NoiseChannelBit: equ 5          ;Bit to modify to set/reset the noise channel.
PLY_AKY_RRB_SoundChannelBit: equ 2          ;Bit to modify to set/reset the sound channel.

                        IFDEF PLY_CFG_NoSoftNoHard        ;CONFIG SPECIFIC
PLY_AKY_RRB_IS_NoSoftwareNoHardware:
        ;No software no hardware.
        rra                     ;Noise?
                                IFDEF PLY_CFG_NoSoftNoHard_Noise        ;CONFIG SPECIFIC
        jr nc,PLY_AKY_RRB_NIS_NoSoftwareNoHardware_ReadVolume
        ;There is a noise. Reads it.
        ld c,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterNoise),c

        ;Opens the noise channel.
        res PLY_AKY_RRB_NoiseChannelBit, b
PLY_AKY_RRB_NIS_NoSoftwareNoHardware_ReadVolume:
                                ENDIF ;PLY_CFG_NoSoftNoHard_Noise
        ;The volume is now in b0-b3.
        ;and %1111      ;No need, the bit 7 is 0.
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterVolume),a

        ;Closes the sound channel.
        set PLY_AKY_RRB_SoundChannelBit, b
        ret
                        ENDIF ;PLY_CFG_NoSoftNoHard


;---------------------
                        IFDEF PLY_CFG_HardOnly  ;CONFIG SPECIFIC
PLY_AKY_RRB_IS_HardwareOnly:
        ;Retrig?
        rra
                                IFDEF PLY_CFG_HardOnly_Retrig   ;CONFIG SPECIFIC
        jr nc,PLY_AKY_RRB_IS_HO_NoRetrig
        ld (iy + PLY_AKY_PsgRegister_OffsetRetrig),255
PLY_AKY_RRB_IS_HO_NoRetrig:
                                ENDIF ;PLY_CFG_HardOnly_Retrig
        ;Noise?
        rra
                                IFDEF PLY_CFG_HardOnly_Noise   ;CONFIG SPECIFIC
        jr nc,PLY_AKY_RRB_IS_HO_NoNoise
        ;Reads the noise.
        ld c,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterNoise),c

        ;Opens the noise channel.
        res PLY_AKY_RRB_NoiseChannelBit, b
PLY_AKY_RRB_IS_HO_NoNoise:
                                ENDIF ;PLY_CFG_HardOnly_Noise

        ;The envelope.
        and %1111
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwareEnvelope),a

        ;Copies the hardware period.
        ld a,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodLSB),a
        ld a,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodMSB),a

        ;Closes the sound channel.
        set PLY_AKY_RRB_SoundChannelBit, b

        ;Sends the hardware volume.
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterVolume),16
        ret
                        ENDIF ;PLY_CFG_HardOnly

;---------------------
PLY_AKY_RRB_IS_SoftwareOnlyOrSoftwareAndHardware:
        ;Another decision to make about the sound type.
        rra
                        IFDEF PLY_AKY_USE_SoftAndHard_Agglomerated      ;CONFIG SPECIFIC
        jr c,PLY_AKY_RRB_IS_SoftwareAndHardware
                        ENDIF ;PLY_AKY_USE_SoftAndHard_Agglomerated

        ;Software only. Structure: 0vvvvntt.
        ;Noise?
        rra
                        IFDEF PLY_CFG_SoftOnly_Noise    ;CONFIG SPECIFIC
        jr nc,PLY_AKY_RRB_IS_SoftwareOnly_NoNoise
        ;Noise. Reads it.
        ld c,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterNoise),c
        ;Opens the noise channel.
        res PLY_AKY_RRB_NoiseChannelBit, b
PLY_AKY_RRB_IS_SoftwareOnly_NoNoise:
                        ENDIF ;PLY_CFG_SoftOnly_Noise
        ;Reads the volume (now b0-b3).
        ;Note: we do NOT peform a "and %1111" because we know the bit 7 of the original byte is 0, so the bit 4 is currently 0. Else the hardware volume would be on!
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterVolume),a

        ;Reads the software period.
        ld a,(hl)
        inc hl
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodLSB),a
        ld a,(hl)
        inc hl
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodMSB),a
        ret





;---------------------
                        IFDEF PLY_AKY_USE_SoftAndHard_Agglomerated      ;CONFIG SPECIFIC
PLY_AKY_RRB_IS_SoftwareAndHardware:
        ;Retrig?
        rra
                                IFDEF PLY_CFG_UseRetrig      ;CONFIG SPECIFIC
        jr nc,PLY_AKY_RRB_IS_SAH_NoRetrig
        ld (iy + PLY_AKY_PsgRegister_OffsetRetrig),255
PLY_AKY_RRB_IS_SAH_NoRetrig:
                                ENDIF ;PLY_CFG_UseRetrig

        ;Noise?
        rra
                                IFDEF PLY_AKY_USE_SoftAndHard_Noise_Agglomerated
        jr nc,PLY_AKY_RRB_IS_SAH_NoNoise
        ;Reads the noise.
        ld c,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterNoise),c

        ;Opens the noise channel.
        res PLY_AKY_RRB_NoiseChannelBit, b
PLY_AKY_RRB_IS_SAH_NoNoise:
                                ENDIF ;PLY_AKY_USE_SoftAndHard_Noise_Agglomerated

        ;The envelope.
        and %1111
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwareEnvelope),a

        ;Reads the software period.
        ld a,(hl)
        inc hl
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodLSB),a
        ld a,(hl)
        inc hl
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodMSB),a

        ;Sends the hardware volume.
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterVolume),16

        ;Copies the hardware period.
        ld a,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodLSB),a
        ld a,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodMSB),a
        ret
                        ENDIF ;PLY_AKY_USE_SoftAndHard_Agglomerated







        ;Manages the loop. This code is put here so that no jump needs to be coded when its job is done.
PLY_AKY_RRB_NIS_NoSoftwareNoHardware_Loop
        ;Loops. Reads the next pointer to this RegisterBlock.
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a

        ;Makes another iteration to read the new data.
        ;Since we KNOW it is not an initial state (because no jump goes to an initial state), we can directly go to the right branching.
        ;Reads the first byte.
        ld a,(hl)
        inc hl
        ;jr PLY_AKY_RRB_NonInitialState

;Generic code interpreting the RegisterBlock - Non initial state. See comment about the Initial state for the registers ins/outs.
;----------------------------------------------------------------
PLY_AKY_RRB_NonInitialState:
        rra
        jr c,PLY_AKY_RRB_NIS_SoftwareOnlyOrSoftwareAndHardware
        rra
                        IFDEF PLY_CFG_HardOnly  ;CONFIG SPECIFIC
        jp c,PLY_AKY_RRB_NIS_HardwareOnly
                        ENDIF ;PLY_CFG_HardOnly

        ;No software, no hardware, OR loop.

        ld e,a
        and %11         ;Bit 3:loop?/volume bit 0, bit 2: volume?
        cp %10          ;If no volume, yet the volume is >0, it means loop.
        jr z,PLY_AKY_RRB_NIS_NoSoftwareNoHardware_Loop

        ;No loop: so "no software no hardware".
                        IFDEF PLY_CFG_NoSoftNoHard        ;CONFIG SPECIFIC

        ;Closes the sound channel.
        set PLY_AKY_RRB_SoundChannelBit, b

        ;Volume? bit 2 - 2.
        ld a,e
        rra
        jr nc,PLY_AKY_RRB_NIS_NoVolume
        and %1111
        ;Sends the volume.
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterVolume),a
PLY_AKY_RRB_NIS_NoVolume:

        ;Noise? Was on bit 7, but there has been two shifts. We can't use A, it may have been modified by the volume AND.
                                IFDEF PLY_CFG_NoSoftNoHard_Noise        ;CONFIG SPECIFIC
        bit 7 - 2, e
        ret z
        ;Noise.
        ld c,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterNoise),c
        ;Opens the noise channel.
        res PLY_AKY_RRB_NoiseChannelBit, b
                                ENDIF ;PLY_CFG_NoSoftNoHard_Noise
        ret
                        ENDIF ;PLY_CFG_NoSoftNoHard






PLY_AKY_RRB_NIS_SoftwareOnlyOrSoftwareAndHardware:
        ;Another decision to make about the sound type.
        rra
                        IFDEF PLY_AKY_USE_SoftAndHard_Agglomerated      ;CONFIG SPECIFIC
        jp c,PLY_AKY_RRB_NIS_SoftwareAndHardware
                        ENDIF
                        

;---------------------
                        IFDEF PLY_CFG_SoftOnly  ;CONFIG SPECIFIC
        ;Software only. Structure: mspnoise lsp v  v  v  v  (0  1).
        ld e,a
        ;Gets the volume (already shifted).
        and %1111
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterVolume),a

        ;LSP? (Least Significant byte of Period). Was bit 6, but now shifted.
        bit 6 - 2, e
        jr z,PLY_AKY_RRB_NIS_SoftwareOnly_NoLSP
        ld a,(hl)
        inc hl
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodLSB),a
PLY_AKY_RRB_NIS_SoftwareOnly_NoLSP:

        ;MSP AND/OR (Noise and/or new Noise)? (Most Significant byte of Period).
                                IFDEF PLY_CFG_SoftOnly_Noise  ;CONFIG SPECIFIC
        bit 7 - 2, e
        ret z

        ;MSP and noise?, in the next byte. nipppp (n = newNoise? i = isNoise? p = MSB period).
        ld a,(hl)       ;Useless bits at the end, not a problem.
        inc hl
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodMSB),a

        rla     ;Carry is isNoise?
        ret nc

        ;Opens the noise channel.
        res PLY_AKY_RRB_NoiseChannelBit, b

        ;Is there a new noise value? If yes, gets the noise.
        rla
        ret nc
        ;Gets the noise.
        ld c,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterNoise),c
                                ENDIF ;PLY_CFG_SoftOnly_Noise
        ret
                        ENDIF ;PLY_CFG_SoftOnly


;---------------------
                        IFDEF PLY_CFG_HardOnly  ;CONFIG SPECIFIC
PLY_AKY_RRB_NIS_HardwareOnly
        ;Gets the envelope (initially on b2-b4, but currently on b0-b2). It is on 3 bits, must be encoded on 4. Bit 0 must be 0.
        rla
        ld e,a
        and %1110
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwareEnvelope),a

        ;Closes the sound channel.
        set PLY_AKY_RRB_SoundChannelBit, b

        ;Hardware volume.
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterVolume),16

        ld a,e

        ;LSB for hardware period? Currently on b6.
        rla
        rla
        jr nc,PLY_AKY_RRB_NIS_HardwareOnly_NoLSB
        ld c,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodLSB),c
PLY_AKY_RRB_NIS_HardwareOnly_NoLSB:

        ;MSB for hardware period?
        rla
        jr nc,PLY_AKY_RRB_NIS_HardwareOnly_NoMSB
        ld c,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodMSB),c
PLY_AKY_RRB_NIS_HardwareOnly_NoMSB:

        ;Noise or retrig?
        rla
        jr c,PLY_AKY_RRB_NIS_Hardware_Shared_NoiseOrRetrig_AndStop          ;The retrig/noise code is shared.

        ret
                        ENDIF ;PLY_CFG_HardOnly


;---------------------
                        IFDEF PLY_AKY_USE_SoftAndHard_Agglomerated      ;CONFIG SPECIFIC
PLY_AKY_RRB_NIS_SoftwareAndHardware:
        ;Hardware volume.
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterVolume),16

        ;LSB of hardware period?
        rra
        jr nc,PLY_AKY_RRB_NIS_SAHH_AfterLSBH
        ld c,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodLSB),c
PLY_AKY_RRB_NIS_SAHH_AfterLSBH:
        ;MSB of hardware period?
        rra
        jr nc,PLY_AKY_RRB_NIS_SAHH_AfterMSBH
        ld c,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodMSB),c
PLY_AKY_RRB_NIS_SAHH_AfterMSBH:

        ;LSB of software period?
        rra
        jr nc,PLY_AKY_RRB_NIS_SAHH_AfterLSBS
        ld c,(hl)
        inc hl
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodLSB),c
PLY_AKY_RRB_NIS_SAHH_AfterLSBS:

        ;MSB of software period?
        rra
        jr nc,PLY_AKY_RRB_NIS_SAHH_AfterMSBS
        ld c,(hl)
        inc hl
        ld (ix + PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodMSB),c
PLY_AKY_RRB_NIS_SAHH_AfterMSBS:

        ;New hardware envelope?
        rra
        jr nc,PLY_AKY_RRB_NIS_SAHH_AfterEnvelope
        ld c,(hl)
        inc hl
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterHardwareEnvelope),c
PLY_AKY_RRB_NIS_SAHH_AfterEnvelope:

        ;Retrig and/or noise?
        rra
        ret nc
                        ENDIF ;PLY_AKY_USE_SoftAndHard_Agglomerated

                        IFDEF PLY_CFG_UseHardwareSounds         ;CONFIG SPECIFIC
        ;This code is shared with the HardwareOnly. It reads the Noise/Retrig byte, interprets it and exits.
        ;------------------------------------------
PLY_AKY_RRB_NIS_Hardware_Shared_NoiseOrRetrig_AndStop:
        ;Noise or retrig. Reads the next byte.
        ld a,(hl)
        inc hl

        ;Retrig?
        rra
                                IFDEF PLY_CFG_UseRetrig         ;CONFIG SPECIFIC
        jr nc,PLY_AKY_RRB_NIS_S_NOR_NoRetrig
        ld (iy + PLY_AKY_PsgRegister_OffsetRetrig),255
PLY_AKY_RRB_NIS_S_NOR_NoRetrig:
                                ENDIF ;PLY_CFG_UseRetrig

                                IFDEF PLY_AKY_USE_SoftAndHard_Noise_Agglomerated        ;CONFIG SPECIFIC
        ;Noise? If no, nothing more to do.
        rra
        ret nc
        ;Noise. Opens the noise channel.
        res PLY_AKY_RRB_NoiseChannelBit, b
        ;Is there a new noise value? If yes, gets the noise.
        rra
        ret nc
        ;Sets the noise.
        ld (iy + PLY_AKY_PsgRegister_OffsetRegisterNoise),a
                                ENDIF ;PLY_AKY_USE_SoftAndHard_Noise_Agglomerated
        ret
                        ENDIF ;PLY_CFG_UseHardwareSounds
        
        
        
        
        
        
        
        
;--------------------------------------------------------------------------
;Codes to send values to the PSG registers. Highly target dependent.
;IN:    B = register 7.
;       SP= points on where to return. Do not modify!
;--------------------------------------------------------------------------

        IFDEF PLY_AKY_HARDWARE_PLAYCITY_OR_CPC
        
;Targets only the PSG2 (CPC Playcity) or PSG1 (CPC) (no need to do more for now).
PLY_AKY_SendPsgRegisters_CPC
        ld a,b

dknr3:  ld de,#c080
        ld b,#f6
        out (c),d       ;#f6c0
        exx
        IFDEF PLY_AKY_HARDWARE_PLAYCITY
                IF PLY_AKY_SFX_PSG_NUMBER != 2
                        ld hl,PLY_AKY_Psg2SoftwareRegisterArray         ;Targets only the PSG2 if PlayCity (no need to be more flexible).
                ELSE
                        ld hl,PLY_AKY_SfxPsgRegisterArray       ;SFX PSG. Uses a specific register array.
                ENDIF
        ENDIF
        IFDEF PLY_AKY_HARDWARE_CPC
                IF PLY_AKY_SFX_PSG_NUMBER != 1
                        ld hl,PLY_AKY_Psg1SoftwareRegisterArray         ;Targets only the PSG1 if CPC (no need to be more flexible).
                ELSE
                        ld hl,PLY_AKY_SfxPsgRegisterArray       ;SFX PSG. Uses a specific register array.
                ENDIF        
        ENDIF
        ld e,#f6
dknr3:  ld bc,#f401

;Register 0
        out (c),0       ;#f400+Register
        ld b,e
        out (c),0       ;#f600
        dec b
        outi            ;#f400+value
        exx
        out (c),e       ;#f680
        out (c),d       ;#f6c0
        exx

;Register 1
        out (c),c
        ld b,e
        out (c),0
        dec b
        outi
        exx
        out (c),e
        out (c),d
        exx
        inc c

;Register 2
        out (c),c
        ld b,e
        out (c),0
        dec b
        outi
        exx
        out (c),e
        out (c),d
        exx
        inc c

;Register 3
        out (c),c
        ld b,e
        out (c),0
        dec b
        outi
        exx
        out (c),e
        out (c),d
        exx
        inc c

;Register 4
        out (c),c
        ld b,e
        out (c),0
        dec b
        outi
        exx
        out (c),e
        out (c),d
        exx
        inc c

;Register 5
        out (c),c
        ld b,e
        out (c),0
        dec b
        outi
        exx
        out (c),e
        out (c),d
        exx
        inc c
        inc c                           ;R6 is encoded later.

;Register 7
        out (c),c
        ld b,e
        out (c),0
        dec b
        dec b
        out (c),a                       ;Read A register instead of the list.
        exx
        out (c),e
        out (c),d
        exx
        inc c

;Register 8
        out (c),c
        ld b,e
        out (c),0
        dec b
        outi
        exx
        out (c),e
        out (c),d
        exx
        inc c
        inc hl                          ;Skip padding byte.

;Register 9
        out (c),c
        ld b,e
        out (c),0
        dec b
        outi
        exx
        out (c),e
        out (c),d
        exx
        inc c
        inc hl                          ;Skip padding byte.

;Register 10
        out (c),c
        ld b,e
        out (c),0
        dec b
        outi
        exx
        out (c),e
        out (c),d
        exx
        inc c

                        IFDEF PLY_CFG_UseHardwareSounds         ;CONFIG SPECIFIC
;Register 11
        out (c),c
        ld b,e
        out (c),0
        dec b
        outi
        exx
        out (c),e
        out (c),d
        exx
        inc c

;Register 12
        out (c),c
        ld b,e
        out (c),0
        dec b
        outi
        exx
        out (c),e
        out (c),d
        exx
        inc c

;Register 13
PLY_AKY_PsgRegister13_Code
        ld a,(hl)
        inc hl                          ;Goes to the "retrig" value, just after R13.
        cp (hl)                         ;If IsRetrig?, force the R13 to be triggered.
                IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
        jr z,PLY_AKY_PsgRegister13_End
                ELSE
        ret z
                ENDIF ;PLY_AKY_USE_Noise
        ld (hl),a                       ;The "retrig" value becomes the R13, so that it is not played again, unless the R13 value is modified.

        out (c),c
        ld b,e
        out (c),0
        dec b
        dec b
        out (c),a
        exx
        out (c),e
        out (c),d
        exx
PLY_AKY_PsgRegister13_End:
                ELSE
                        ;No hardware. But maybe noise?
                        IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
                inc hl          ;Skips R11/R12/R13 data.
                inc hl
                inc hl
                        ENDIF ;PLY_AKY_USE_Noise
                ENDIF ;PLY_CFG_UseHardwareSounds
                        
                IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
        inc hl

;Register 6
        ld c,6
        out (c),c
        ld b,e
        out (c),0
        dec b
        outi
        exx
        out (c),e
        out (c),d
                ENDIF ;PLY_AKY_USE_Noise
        ret
        
        ENDIF ;PLY_AKY_HARDWARE_PLAYCITY_OR_CPC


        IFDEF PLY_AKY_HARDWARE_PLAYCITY
        
;Sends the registers to the PlayCity.
;IN:    B = Register7 value.
;       HL = Register list, starting at register 0.
;       C = SELECT/WRITE LSB port of the PlayCity (#84 for right channels, #88 for left channels).
PLY_AKY_SendPsgRegisters_PlayCity:
        ld a,b

        ;Sends the register 7 first, to be able to use A later.
dknr3:  ld de,7 * 256 + PLY_AKY_PLAYCITY_SELECT_PORT_MSB
        ld b,e
        out (c),d               ;#f984/88 to select a register (7 here).
        dec b
        out (c),a

        ;Register 0.
        xor a                   ;A = register. We could use out (c),0, but we would need to set a to 1 after. The code is cleared this way.
        ld b,e
        out (c),a               ;#f984/88 to select a register.
        outi                    ;#f884/88 to select a value. Thanks to OUTI, no need to decrease B!

        ;Register 1.
        inc a
        ld b,e
        out (c),a
        outi

        ;Register 2.
        inc a
        ld b,e
        out (c),a
        outi

        ;Register 3.
        inc a
        ld b,e
        out (c),a
        outi

        ;Register 4.
        inc a
        ld b,e
        out (c),a
        outi

        ;Register 5.
        inc a
        ld b,e
        out (c),a
        outi

        ;Register 8.
        ld a,8
        ld b,e
        out (c),a
        outi
        inc hl                          ;Skips padding byte.

        ;Register 9.
        inc a
        ld b,e
        out (c),a
        outi
        inc hl                          ;Skips padding byte.

        ;Register 10.
        inc a
        ld b,e
        out (c),a
        outi

                        IFDEF PLY_CFG_UseHardwareSounds         ;CONFIG SPECIFIC
        ;Register 11.
        inc a
        ld b,e
        out (c),a
        outi

        ;Register 12.
        inc a
        ld b,e
        out (c),a
        outi

        ;Register 13.
        inc a
        ld b,e
        out (c),a       ;Selects the register even if it won't be used. Simpler this way.

        ld a,(hl)
        inc hl
        cp (hl)                         ;If IsRetrig?, force the R13 to be triggered.
                        IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
        jr z,PLY_AKY_PsgPlayCityRegister13_End
                        ELSE
        ret z
                        ENDIF ;PLY_AKY_USE_Noise
        ld (hl),a                       ;The R13 becomes the "retrig" value, so that it is not played again, unless Retrig value is modified.
        dec b
        out (c),a
PLY_AKY_PsgPlayCityRegister13_End:
                        ELSE
                              ;No hardware but maybe noise.
                              IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
                                inc hl          ;Skips R11/R12/R13 data.
                                inc hl
                                inc hl
                              ENDIF
                        ENDIF ;PLY_CFG_UseHardwareSounds

                        IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
        inc hl                          ;Go past the IsRetrig?.
        ;Register 6.
        ld a,6
        ld b,e
        out (c),a
        outi
                        ENDIF ;PLY_AKY_USE_Noise
        ret


        ENDIF ;PLY_AKY_HARDWARE_PLAYCITY
        
        
        
        ;Used by Vanilla MSX, or SpecNext or Turbosound.
        IFDEF PLY_AKY_HARDWARE_SPECTRUM_RELATED

;Sends the registers to one of the PSG, for the Vanilla Spectrum, SpecNext or TurboSound.
;IN:    B = Register7 value.
;       HL = Register list, starting at register 0.
;       D = If special hardware, register to reach the PSG to use, and the possible stereo bits. Else, ignore.
PLY_AKY_SendPsgRegisters_SpectrumRelated:
        ld a,b
        ex af,af'               ;A' is now R7.

dknr3:  ld bc,#fffd                             ;PSG ports.
        
        ;Special out for specific hardware.
        IFDEF PLY_AKY_HARDWARE_TURBOSOUND_OR_SPECNEXT
                ;Selects the PSG + stereo bits.
                out (c),d       ;#fffd + register.
        ENDIF

dknr3:  ld de,#c0ff     ;#bfff + value. Use #c0 because OUTI will decrease B first.
        
        ;Register 0.
        xor a
        out (c),a
        ld b,d
        outi
        ld b,e
        
        ;Register 1.
        inc a
        out (c),a
        ld b,d
        outi
        ld b,e
        
        ;Register 2.
        inc a
        out (c),a
        ld b,d
        outi
        ld b,e
        
        ;Register 3.
        inc a
        out (c),a
        ld b,d
        outi
        ld b,e
        
        ;Register 4.
        inc a
        out (c),a
        ld b,d
        outi
        ld b,e
        
        ;Register 5.
        inc a
        out (c),a
        ld b,d
        outi
        ld b,e
        
        ;Register 7.
        inc a                           ;Skips R6.
        inc a
        out (c),a
        ld b,d
        dec b                           ;#c0 to #bf.
        ex af,af'                       ;Restores R7.
        out (c),a
        ex af,af'
        ld b,e
        
        ;Register 8.
        inc a
        out (c),a
        ld b,d
        outi
        ld b,e
        inc hl                          ;Skips padding byte.
        
        ;Register 9.
        inc a
        out (c),a
        ld b,d
        outi
        ld b,e
        inc hl                          ;Skips padding byte.
        
        ;Register 10.
        inc a
        out (c),a
        ld b,d
        outi
        ld b,e
        
                        IFDEF PLY_CFG_UseHardwareSounds         ;CONFIG SPECIFIC
        ;Register 11.
        inc a
        out (c),a
        ld b,d
        outi
        ld b,e
        
        ;Register 12.
        inc a
        out (c),a
        ld b,d
        outi
        ld b,e
        
        ;Register 13.
        inc a
        out (c),a       ;Selects the register even if it won't be used. Simpler this way.

        ld a,(hl)
        inc hl
        cp (hl)                         ;If IsRetrig?, force the R13 to be triggered.
                        IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
        jr z,PLY_AKY_PsgSpectrumRelatedRegister13_End
                        ELSE
        ret z
                        ENDIF ;PLY_AKY_USE_Noise
        ld (hl),a                       ;The R13 becomes the "retrig" value, so that it is not played again, unless Retrig value is modified.
        ld b,d
        dec b                           ;#c0 to #bf.
        out (c),a
        ld b,e
PLY_AKY_PsgSpectrumRelatedRegister13_End
                        ELSE
                              ;No hardware but maybe noise.
                              IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
                                inc hl          ;Skips R11/R12/R13 data.
                                inc hl
                                inc hl
                              ENDIF
                        ENDIF ;PLY_CFG_UseHardwareSounds
                        
                        IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
        inc hl                          ;Go past the IsRetrig?.

        ;Register 6.
        ld a,6
        out (c),a
        ld b,d
        outi
                        ENDIF ;PLY_AKY_USE_Noise
        ret

   
        ENDIF ;PLY_AKY_HARDWARE_SPECTRUM_RELATED
   
   
   
   
   
        IFDEF PLY_AKY_HARDWARE_MSX
   
        ;This generates a method which targets specific MSX port for the register and value. These are also put in the method name.
        MACRO PLY_AKY_GenerateSendPsgRegistersMsx hexPortRegister,hexPortValue

;Sends the registers to one of the PSG, for any MSX based hardware.
;IN:    B = Register7 value.
;       HL = Register list, starting at register 0.
PLY_AKY_SendPsgRegisters_Msx_{hexPortRegister}_{hexPortValue}
        ;Register 7.
        ld a,7
        out (#{hexPortRegister}),a      ;Register.
        ld a,b
        out (#{hexPortValue}),a         ;Value.
        
        ;Register 0.
        xor a
        out (#{hexPortRegister}),a
        ld a,(hl)
        inc hl
        out (#{hexPortValue}),a
        
        ;Register 1.
        ld a,1
        out (#{hexPortRegister}),a
        ld a,(hl)
        inc hl
        out (#{hexPortValue}),a
        
        ;Register 2.
        ld a,2
        out (#{hexPortRegister}),a
        ld a,(hl)
        inc hl
        out (#{hexPortValue}),a
        
        ;Register 3.
        ld a,3
        out (#{hexPortRegister}),a
        ld a,(hl)
        inc hl
        out (#{hexPortValue}),a
        
        ;Register 4.
        ld a,4
        out (#{hexPortRegister}),a
        ld a,(hl)
        inc hl
        out (#{hexPortValue}),a
        
        ;Register 5.
        ld a,5
        out (#{hexPortRegister}),a
        ld a,(hl)
        inc hl
        out (#{hexPortValue}),a
        
        ;Register 8 (R6 is sent the last one, R7 has already been sent).
        ld a,8
        out (#{hexPortRegister}),a
        ld a,(hl)
        inc hl
        inc hl                          ;Skips padding byte.
        out (#{hexPortValue}),a
        
        ;Register 9.
        ld a,9
        out (#{hexPortRegister}),a
        ld a,(hl)
        inc hl
        inc hl                          ;Skips padding byte.
        out (#{hexPortValue}),a
        
        ;Register 10.
        ld a,10
        out (#{hexPortRegister}),a
        ld a,(hl)
        inc hl
        out (#{hexPortValue}),a
        
                        IFDEF PLY_CFG_UseHardwareSounds         ;CONFIG SPECIFIC
        ;Register 11.
        ld a,11
        out (#{hexPortRegister}),a
        ld a,(hl)
        inc hl
        out (#{hexPortValue}),a
        
        ;Register 12.
        ld a,12
        out (#{hexPortRegister}),a
        ld a,(hl)
        inc hl
        out (#{hexPortValue}),a
        
        ;Register 13.
        ld a,13
        out (#{hexPortRegister}),a       ;Selects the register even if it won't be used. Simpler this way.
        
        ld a,(hl)
        inc hl
        cp (hl)                         ;If IsRetrig?, force the R13 to be triggered.
                        IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
        jr z,PLY_AKY_SendPsgRegisters_Msx_{hexPortRegister}_{hexPortValue}_Register13_End
                        ELSE
        ret z
                        ENDIF ;PLY_AKY_USE_Noise
        out (#{hexPortValue}),a
PLY_AKY_SendPsgRegisters_Msx_{hexPortRegister}_{hexPortValue}_Register13_End
                        ELSE
                              ;No hardware but maybe noise.
                              IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
                                inc hl          ;Skips R11/R12/R13 data.
                                inc hl
                                inc hl
                              ENDIF
                        ENDIF ;PLY_CFG_UseHardwareSounds

                        IFDEF PLY_AKY_USE_Noise         ;CONFIG SPECIFIC
        inc hl                          ;Go past the IsRetrig?.
        
        ;Register 6.
        ld a,6
        out (#{hexPortRegister}),a
        ld a,(hl)
        out (#{hexPortValue}),a
                        ENDIF ;PLY_AKY_USE_Noise
        ret
        
        ENDM
        
        ;Generates the two "send PSG methods" according to the hardware (one for each PSG).
        IFDEF PLY_AKY_HARDWARE_FPGAPSG
                PLY_AKY_GenerateSendPsgRegistersMsx a0,a1
                PLY_AKY_GenerateSendPsgRegistersMsx 10,11
        ENDIF
        
        IFDEF PLY_AKY_HARDWARE_DARKY
                PLY_AKY_GenerateSendPsgRegistersMsx 44,45
                PLY_AKY_GenerateSendPsgRegistersMsx 4c,4d
        ENDIF
        
        ;The vanilla MSX has only one PSG.
        IFDEF PLY_AKY_HARDWARE_MSX_VANILLA
                PLY_AKY_GenerateSendPsgRegistersMsx a0,a1
        ENDIF
        
        ENDIF ;PLY_AKY_HARDWARE_MSX
   
   
   
   
        
        
;------------------------------------------------------
        
        ;Declares the PSG code to use for each PSG of each target.
        IFDEF PLY_AKY_HARDWARE_PLAYCITY
                ;Psg 1 is direct to CPC PSG.
                PLY_AKY_PSG1PLAYCODE = PLY_AKY_SendPsgRegisters_PlayCity
                PLY_AKY_PSG2PLAYCODE = PLY_AKY_SendPsgRegisters_CPC
                PLY_AKY_PSG3PLAYCODE = PLY_AKY_SendPsgRegisters_PlayCity
        ENDIF
        IFDEF PLY_AKY_HARDWARE_TURBOSOUND
                PLY_AKY_PSG1PLAYCODE = PLY_AKY_SendPsgRegisters_SpectrumRelated
                PLY_AKY_PSG2PLAYCODE = PLY_AKY_SendPsgRegisters_SpectrumRelated
        ENDIF
        IFDEF PLY_AKY_HARDWARE_SPECNEXT
                PLY_AKY_PSG1PLAYCODE = PLY_AKY_SendPsgRegisters_SpectrumRelated
                PLY_AKY_PSG2PLAYCODE = PLY_AKY_SendPsgRegisters_SpectrumRelated
                PLY_AKY_PSG3PLAYCODE = PLY_AKY_SendPsgRegisters_SpectrumRelated                
        ENDIF
        IFDEF PLY_AKY_HARDWARE_FPGAPSG
                PLY_AKY_PSG1PLAYCODE = PLY_AKY_SendPsgRegisters_Msx_a0_a1
                PLY_AKY_PSG2PLAYCODE = PLY_AKY_SendPsgRegisters_Msx_10_11
        ENDIF
        IFDEF PLY_AKY_HARDWARE_DARKY
                PLY_AKY_PSG1PLAYCODE = PLY_AKY_SendPsgRegisters_Msx_44_45
                PLY_AKY_PSG2PLAYCODE = PLY_AKY_SendPsgRegisters_Msx_4c_4d
        ENDIF
        
        IFDEF PLY_AKY_HARDWARE_CPC
                PLY_AKY_PSG1PLAYCODE = PLY_AKY_SendPsgRegisters_CPC
        ENDIF
        IFDEF PLY_AKY_HARDWARE_MSX_VANILLA
                PLY_AKY_PSG1PLAYCODE = PLY_AKY_SendPsgRegisters_Msx_a0_a1
        ENDIF
        IFDEF PLY_AKG_HARDWARE_SPECTRUM_OR_PENTAGON
                PLY_AKY_PSG1PLAYCODE = PLY_AKY_SendPsgRegisters_SpectrumRelated
        ENDIF


;RET table for the Read RegisterBlock code to know where to return, and then points
;to the PSG sending code.
PLY_AKY_RetTable_ReadRegisterBlock:
dkps:
        channelNumber = 1
        REPEAT PLY_AKY_PsgCount, psgNumber
                REPEAT 3
                        dw PLY_AKY_Channel{channelNumber}_RegisterBlock_Return
                        channelNumber = channelNumber + 1
                REND
                ;Plugs the Psg play code for this PSG. It has been set by the hardware declaration at the beginning.
                dw PLY_AKY_Psg{psgNumber}PlayCode
                dw PLY_AKY_Psg{psgNumber}AfterSendingPsgRegisters
        REND
dkpe:        



        IFNDEF PLY_AKY_ROM
dkbs:
;The PSG registers. Note than the Register 7 (mixer) is not present, because it is passed inside a register.
PLY_AKY_Psg1SoftwareRegisterArray:
PLY_AKY_Psg1Register0:      db 0    ;Register 0.
PLY_AKY_Psg1Register1:      db 0    ;Register 1.
PLY_AKY_Psg1Register2:      db 0    ;Register 2.
PLY_AKY_Psg1Register3:      db 0    ;Register 3.
PLY_AKY_Psg1Register4:      db 0    ;Register 4.
PLY_AKY_Psg1Register5:      db 0    ;Register 5.
;No Reg6 (noise)!
;No Reg7 (mix)!
PLY_AKY_Psg1Register8:      db 0    ;Register 8.
        db 0                    ;A byte to skip, needed to allow index registers when filling the register with a generic code.
PLY_AKY_Psg1Register9:      db 0    ;Register 9.
        db 0                    ;A byte to skip, same as above.
PLY_AKY_Psg1Register10:     db 0    ;Register 10.
PLY_AKY_Psg1SoftwareRegisterArray_End:
;The hardware register array MUST be stuck to the software register array.
PLY_AKY_Psg1HardwareRegisterArray
PLY_AKY_Psg1Register11:     db 0    ;Register 11.
PLY_AKY_Psg1Register12:     db 0    ;Register 12.
PLY_AKY_Psg1Register13:     db 0    ;Register 13.
PLY_AKY_Psg1Retrig:         db 0    ;Retrig value, must be just after Register13.
PLY_AKY_Psg1Noise:          db 0    ;Noise.
PLY_AKY_Psg1HardwareRegisterArray_End:
dkbe:
        ASSERT PLY_AKY_Psg1HardwareRegisterArray == PLY_AKY_Psg1SoftwareRegisterArray_End

        ELSE
        ;Rom buffer.
        ;Bytes first.
PLY_AKY_ROM_BufferSize = 0
PLY_AKY_Psg1Register0:                  equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Psg1SoftwareRegisterArray:      equ PLY_AKY_Psg1Register0
PLY_AKY_Psg1Register1:                  equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Psg1Register2:                  equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Psg1Register3:                  equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Psg1Register4:                  equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Psg1Register5:                  equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Psg1Register8:                  equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
        PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1     ;A byte to skip, see above as to why.
PLY_AKY_Psg1Register9:                  equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
        PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1     ;A byte to skip, see above as to why.
PLY_AKY_Psg1Register10:                 equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Psg1Register11:                 equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Psg1SoftwareRegisterArray_End:  equ PLY_AKY_Psg1Register11
PLY_AKY_Psg1HardwareRegisterArray:      equ PLY_AKY_Psg1SoftwareRegisterArray_End
PLY_AKY_Psg1Register12:                 equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Psg1Register13:                 equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Psg1Retrig:                     equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Psg1Noise:                      equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
        ;Words.
PLY_AKY_PtLinker:                       equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 2
PLY_AKY_Psg1HardwareRegisterArray_End:  equ PLY_AKY_PtLinker
PLY_AKY_SaveSp:                         equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 2
PLY_AKY_SaveSpTemp:                     equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 2
PLY_AKY_PatternFrameCounter:            equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 2
        REPEAT PLY_AKY_ChannelCount, ChannelNumber
PLY_AKY_Channel{ChannelNumber}_PtTrack: equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 2
        REND
        REPEAT PLY_AKY_ChannelCount, ChannelNumber
PLY_AKY_Channel{ChannelNumber}_PtRegisterBlock: equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 2
        REND
        ;More data...
        REPEAT PLY_AKY_ChannelCount, ChannelNumber
PLY_AKY_Channel{ChannelNumber}_WaitBeforeNextRegisterBlock:     equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
        REND
        REPEAT PLY_AKY_ChannelCount, ChannelNumber
PLY_AKY_Channel{ChannelNumber}_RegisterBlockLineState_Opcode:   equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
        REND
        
        ;The buffers for sound effects (if any), for each channel. They are treated apart, because they must be consecutive.
        IFDEF PLY_AKY_MANAGE_SOUND_EFFECTS
PLY_AKY_PtSoundEffectTable:                                     equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 2
                REPEAT 3, channelNumber
PLY_AKY_Channel{channelNumber}_SoundEffectData:                 equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 2
PLY_AKY_Channel{channelNumber}_SoundEffectInvertedVolume:       equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Channel{channelNumber}_SoundEffectCurrentStep:          equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
PLY_AKY_Channel{channelNumber}_SoundEffectSpeed:                equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 1
        if channelNumber != 3
               PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + 3 ;Padding of 3, but only necessary for channel 1 and 2.
        endif
                REND
        ENDIF
        
        ENDIF ;PLY_AKY_ROM


PLY_AKY_Psg1SoftwareRegisterArray_Size: equ PLY_AKY_Psg1SoftwareRegisterArray_End - PLY_AKY_Psg1SoftwareRegisterArray
PLY_AKY_Psg1HardwareRegisterArray_Size: equ PLY_AKY_Psg1HardwareRegisterArray_End - PLY_AKY_Psg1HardwareRegisterArray
PLY_AKY_PsgRegisterArray_Size = PLY_AKY_Psg1SoftwareRegisterArray_Size + PLY_AKY_Psg1HardwareRegisterArray_Size

;Offsets to reach the registers in a generic way with an offset, according to the channel.
PLY_AKY_PsgRegister_OffsetRegisterVolume: equ PLY_AKY_Psg1Register8 - PLY_AKY_Psg1SoftwareRegisterArray
PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodLSB: equ PLY_AKY_Psg1Register0 - PLY_AKY_Psg1SoftwareRegisterArray
PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodMSB: equ PLY_AKY_Psg1Register1 - PLY_AKY_Psg1SoftwareRegisterArray

PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodLSB: equ PLY_AKY_Psg1Register11 - PLY_AKY_Psg1HardwareRegisterArray
PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodMSB: equ PLY_AKY_Psg1Register12 - PLY_AKY_Psg1HardwareRegisterArray
PLY_AKY_PsgRegister_OffsetRegisterHardwareEnvelope: equ PLY_AKY_Psg1Register13 - PLY_AKY_Psg1HardwareRegisterArray
PLY_AKY_PsgRegister_OffsetRetrig: equ PLY_AKY_Psg1Retrig - PLY_AKY_Psg1HardwareRegisterArray
PLY_AKY_PsgRegister_OffsetRegisterNoise: equ PLY_AKY_Psg1Noise - PLY_AKY_Psg1HardwareRegisterArray

;The registers array for the **other** PSGs, and also the SFX buffer if needed.
dkbs:
        psgNumber = 2
        WHILE psgNumber <= PLY_AKY_PsgCount
        
                IFNDEF PLY_AKY_ROM        
PLY_AKY_Psg{psgNumber}SoftwareRegisterArray:
        ds PLY_AKY_Psg1SoftwareRegisterArray_Size, 0            ;The same size as for PSG 1.
PLY_AKY_Psg{psgNumber}HardwareRegisterArray:
        ds PLY_AKY_Psg1HardwareRegisterArray_Size, 0            ;The same size as for PSG 1.
                ELSE
                ;Rom
PLY_AKY_Psg{psgNumber}SoftwareRegisterArray: equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + PLY_AKY_Psg1SoftwareRegisterArray_Size
PLY_AKY_Psg{psgNumber}HardwareRegisterArray: equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + PLY_AKY_Psg1HardwareRegisterArray_Size
                ENDIF ;PLY_AKY_ROM
        psgNumber = psgNumber + 1
        WEND
        
        ;Declares a SFX register array, if SFXs are used.
        IFDEF PLY_AKY_MANAGE_SOUND_EFFECTS
                IFNDEF PLY_AKY_ROM
PLY_AKY_SfxPsgRegisterArray:
        ds PLY_AKY_Psg1SoftwareRegisterArray_Size, 0            ;The same size as for PSG 1.
        ds PLY_AKY_Psg1HardwareRegisterArray_Size, 0
                ELSE
PLY_AKY_SfxPsgRegisterArray: equ PLY_AKY_ROM_Buffer + PLY_AKY_ROM_BufferSize : PLY_AKY_ROM_BufferSize = PLY_AKY_ROM_BufferSize + PLY_AKY_Psg1SoftwareRegisterArray_Size + PLY_AKY_Psg1HardwareRegisterArray_Size
                ENDIF
                                
        ;Declares the SFX address to the SFX buffer.
PLY_AKY_SfxReg8: equ PLY_AKY_SfxPsgRegisterArray + PLY_AKY_PsgRegister_OffsetRegisterVolume + 0
PLY_AKY_SfxReg9: equ PLY_AKY_SfxPsgRegisterArray + PLY_AKY_PsgRegister_OffsetRegisterVolume + 2         ;One byte in between is padding!
PLY_AKY_SfxReg10: equ PLY_AKY_SfxPsgRegisterArray + PLY_AKY_PsgRegister_OffsetRegisterVolume + 4        ;One byte in between is padding!
PLY_AKY_SfxReg01: equ PLY_AKY_SfxPsgRegisterArray + PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodLSB + 0
        assert PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodLSB == (PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodMSB - 1) ;Makes sure the two regs are consecutive!
PLY_AKY_SfxReg23: equ PLY_AKY_SfxPsgRegisterArray + PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodLSB + 2
PLY_AKY_SfxReg45: equ PLY_AKY_SfxPsgRegisterArray + PLY_AKY_PsgRegister_OffsetRegisterSoftwarePeriodLSB + 4
        ;Hardware part. A "hardware part offset" must be added!
PLY_AKY_SfxReg6: equ PLY_AKY_SfxPsgRegisterArray + PLY_AKY_Psg1SoftwareRegisterArray_Size + PLY_AKY_PsgRegister_OffsetRegisterNoise
PLY_AKY_SfxHardwarePeriod: equ PLY_AKY_SfxPsgRegisterArray + PLY_AKY_Psg1SoftwareRegisterArray_Size + PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodLSB
        assert PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodLSB == (PLY_AKY_PsgRegister_OffsetRegisterHardwarePeriodMSB - 1) ;Makes sure the two regs are consecutive!
PLY_AKY_SfxReg13: equ PLY_AKY_SfxPsgRegisterArray + PLY_AKY_Psg1SoftwareRegisterArray_Size + PLY_AKY_PsgRegister_OffsetRegisterHardwareEnvelope
PLY_AKY_SfxRetrig: equ PLY_AKY_SfxPsgRegisterArray + PLY_AKY_Psg1SoftwareRegisterArray_Size + PLY_AKY_PsgRegister_OffsetRetrig

        ENDIF
dkbe:

;Declares the base pointer on the PSG structure for each channel.
        channelNumber = 1
        WHILE channelNumber <= PLY_AKY_ChannelCount
                psgNumber = floor(((channelNumber - 1) / 3) + 1)
                channelOffset = ((channelNumber - 1) % 3) * 2          ; 0, 2, 4 for channel 1, 2, 3 respectively.

PLY_AKY_Channel{channelNumber}_RegisterBase: equ PLY_AKY_Psg{psgNumber}SoftwareRegisterArray + channelOffset

        channelNumber = channelNumber + 1
        WEND

Music:
        ;What music to play?
        include "SKYFALL.AKY"

