# Goals for SE Basic 4.3 Drusilla

* Native RIFF support.
* DLLs (Arkos Player as the example).
* Extended BASIC commands.
* Soft Blitter (through the API).
* A more thorough SE/OS API.
* Support for loading SE/OS extensions at boot.
* User defined commands (`_PLAY` as the example).
* Complete the unfinished BASIC commands.
* Remove support for MS BASIC conversion (it's not being used).
* Remove the `PLAY` command.
* UTF-8 fonts (using BitsNPicas format).
* Assign all tokens and make tokenized BASIC the default (in a RIFF wrapper)

## Supported RIFF files

* `.RMI` - MIDI
* `.WAV` - 8-bit PCM audio
* `.ANI` - Animated cursors
* `.PAL` - Palette
* `.AVI` - Audio/Video (8-bit/1-bit)

## Platform specific RIFF files

* `.ARC` - compressed file
* `.EXT` - system extension
* `.` - 
* `.` - 

## IFF file types (for inspiration)

* ILBM - images
* 8SVX - audio
* ANIM - animation
* SMUS - musical score
* FORM - data wrapper
* LIST - collection of chunks
* CAT - catalog of chunks
* AIFF - audio
* IFF - image

Looking at your SE Basic IV project, I can see it's a Z80 BASIC interpreter with SE/OS integration. To add generic RIFF handling to SE/OS using .PAL palette files as an example, here's how I'd approach it:

## RIFF Structure Overview
RIFF (Resource Interchange File Format) files have a standard structure:

* 4-byte "RIFF" signature
* 4-byte file size (little-endian)
* 4-byte format type (e.g., "PAL " for palette)
* Chunks with 4-byte ID + 4-byte size + data

## Implementation Approach

; RIFF File Format Handler for SE/OS
; Supports generic RIFF parsing with .PAL palette example

RIFF_SIGNATURE equ $46464952    ; "RIFF" in little-endian
PAL_FORMAT equ $204C4150        ; "PAL " format identifier

; RIFF file header structure (12 bytes)
riff_header:
    defs 4      ; signature "RIFF"
    defs 4      ; file size - 8
    defs 4      ; format type

; Generic RIFF chunk header (8 bytes)  
chunk_header:
    defs 4      ; chunk ID
    defs 4      ; chunk size

; Load and validate RIFF file
; Input: IX = filename
; Output: A = error code (0 = success), HL = file handle
load_riff_file:
    call open_file              ; SE/OS file open
    ret nz                      ; return if error
    
    ; Read RIFF header
    ld de, riff_header
    ld bc, 12
    call read_file
    ret nz
    
    ; Validate RIFF signature
    ld hl, riff_header
    ld de, riff_sig_text
    ld bc, 4
    call compare_memory
    jr nz, invalid_riff
    
    ; File size validation could go here
    xor a                       ; success
    ret

invalid_riff:
    ld a, $FF                   ; error code
    ret

riff_sig_text: db "RIFF"

; Parse .PAL palette file specifically
; Input: file handle in A
; Output: palette data loaded to memory
parse_pal_file:
    push af
    
    ; Verify PAL format
    ld hl, riff_header + 8
    ld de, pal_format_text
    ld bc, 4
    call compare_memory
    jr nz, not_pal_format
    
    ; Look for data chunk
find_data_chunk:
    call read_chunk_header
    ret nz                      ; error reading
    
    ; Check if this is data chunk
    ld hl, chunk_header
    ld de, data_chunk_text
    ld bc, 4
    call compare_memory
    jr z, found_data_chunk
    
    ; Skip this chunk
    call skip_chunk_data
    jr find_data_chunk

found_data_chunk:
    ; Read palette data (typically 256 * 3 bytes RGB)
    ld hl, (chunk_header + 4)   ; get chunk size
    ld de, palette_buffer
    pop af                      ; restore file handle
    call read_file
    ret

not_pal_format:
    pop af
    ld a, $FE                   ; format error
    ret

pal_format_text: db "PAL "
data_chunk_text: db "data"

; Read chunk header
read_chunk_header:
    ld de, chunk_header
    ld bc, 8
    call read_file
    ret

; Skip chunk data based on size in header
skip_chunk_data:
    ld hl, (chunk_header + 4)   ; get chunk size
    ; Align to word boundary
    ld a, l
    and 1
    jr z, skip_aligned
    inc hl                      ; add padding byte
skip_aligned:
    call seek_relative          ; SE/OS seek function
    ret

; Generic RIFF chunk iterator
; Input: A = file handle, IX = callback function
; Callback receives: HL = chunk ID, DE = chunk size, BC = data offset
iterate_riff_chunks:
    push af
    push ix
    
next_chunk:
    call read_chunk_header
    jr nz, end_iteration
    
    ; Call user callback
    ld hl, (chunk_header)       ; chunk ID
    ld de, (chunk_header + 4)   ; chunk size
    call get_file_position
    ld bc, hl                   ; current position
    
    push ix
    pop hl
    call call_hl                ; call callback
    
    ; Skip to next chunk
    call skip_chunk_data
    jr next_chunk
    
end_iteration:
    pop ix
    pop af
    ret

; Palette buffer (768 bytes for 256 RGB entries)
palette_buffer: defs 768

; SE/OS integration functions would include:
; - open_file, read_file, close_file
; - compare_memory, seek_relative, get_file_position
; - Memory management for large RIFF files

## SE/OS Integration Points

You'd need to integrate this with SE/OS by:

1. Adding to the DOS command set: A LOADPAL command
2. File type registration: Register .PAL extension
3. Memory management: Use SE/OS heap for large files
4. Error handling: Integrate with SE/OS error codes

// Add to modules/09_command.asm
; LOADPAL command handler
cmd_loadpal:
    call get_filename           ; parse filename from command line
    call load_riff_file
    ret nz                      ; return on error
    call parse_pal_file
    call apply_palette          ; apply to screen/hardware
    ret

The key advantage of this approach is that the generic RIFF parser can handle other formats (like WAV audio files) by just changing the format validation and chunk processing callbacks.