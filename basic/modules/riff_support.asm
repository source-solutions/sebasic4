;	// SE Basic IV - RIFF Format Support
;	// Copyright (c) 2024 Source Solutions, Inc.

;	// SE Basic IV is free software: you can redistribute it and/or modify
;	// it under the terms of the GNU General Public License as published by
;	// the Free Software Foundation, either version 3 of the License, or
;	// (at your option) any later version.
;	// 
;	// SE Basic IV is distributed in the hope that it will be useful,
;	// but WITHOUT ANY WARRANTY; without even the implied warranty of
;	// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;	// GNU General Public License for more details.
;	// 
;	// You should have received a copy of the GNU General Public License
;	// along with SE Basic IV. If not, see <http://www.gnu.org/licenses/>.

;;
;	// --- RIFF FILE FORMAT SUPPORT ROUTINES ----------------------------------
;;
:

;	// RIFF Format constants and variables
	riff_signature  equ $52494646;     // "RIFF" in ASCII (byte-reversed for little-endian)
	riff_buffer     equ mem_0_1 + 256; // Use some memory for temporary RIFF operations
	riff_chunk_id   equ riff_buffer;   // 4 bytes for chunk ID
	riff_chunk_size equ riff_buffer+4; // 4 bytes for chunk size
	riff_data       equ riff_buffer+8; // Buffer for RIFF data

;;
; Open a RIFF file and validate its header
; @param IX - pointer to ASCIIZ file path
; @return A - file handle
; @return Z flag set if valid RIFF file, clear otherwise
; @throws sets carry flag on error
;;
RIFFOpen:
	call v_open_r_exists;               // Open file for reading
	ret c;                              // Return if error
	ld (handle), a;                     // Store file handle
	
	; Read RIFF header (12 bytes)
	ld bc, 12;                          // Read 12 bytes
	ld ix, riff_buffer;                 // Buffer for header
	call v_read;                        // Read header
	ret c;                              // Return if error
	
	; Validate RIFF signature
	ld hl, riff_buffer;                 // Point to buffer
	ld de, riff_signature;              // "RIFF" signature
	ld b, 4;                            // Compare 4 bytes
validate_sig:
	ld a, (hl);                         // Get byte from buffer
	cp e;                               // Compare with signature
	jr nz, invalid_riff;                // Not a RIFF file
	inc hl;                             // Next byte
	srl d;                              // Shift signature
	srl d;                              // to get
	srl d;                              // next
	srl d;                              // byte
	ld e, d;                            // Move to E
	djnz validate_sig;                  // Loop until done
	
	; Valid RIFF file
	xor a;                              // Set Z flag
	ret;                                // Return
	
invalid_riff:
	or 1;                               // Clear Z flag
	ret;                                // Return

;;
; Find and read a specific chunk in a RIFF file
; @param A - file handle
; @param IX - Buffer for chunk data
; @param DE - Chunk ID to find (e.g. "fmt " or "data")
; @return BC - chunk size in bytes
; @return Z flag set if chunk found, clear otherwise
; @throws sets carry flag on error
;;
RIFFReadChunk:
	ld (handle), a;                     // Store file handle
	push ix;                            // Save destination buffer
	push de;                            // Save chunk ID
	
	; Seek to position 12 (after RIFF header)
	ld ixl, 0;                          // Seek from start
	ld bc, 0;                           // Set high bytes to 0
	ld de, 12;                          // Seek to byte 12
	rst divmmc;                         // Issue a hookcode
	defb f_seek;                        // Seek to position
	pop de;                             // Restore chunk ID
	pop ix;                             // Restore destination buffer
	ret c;                              // Return if error
	
chunk_loop:
	; Read chunk header (8 bytes)
	ld a, (handle);                     // Get file handle
	ld bc, 8;                           // Read 8 bytes
	push ix;                            // Save destination buffer
	ld ix, riff_chunk_id;               // Buffer for chunk header
	call v_read;                        // Read chunk header
	pop ix;                             // Restore destination buffer
	ret c;                              // Return if error
	
	; Check if we've reached the end of the file
	ld a, c;                            // Check bytes read
	or b;                               // Is it zero?
	jr z, chunk_not_found;              // End of file, chunk not found
	
	; Compare chunk ID
	ld hl, riff_chunk_id;               // Point to chunk ID
	ld a, (hl);                         // First byte
	cp e;                               // Compare
	jr nz, skip_chunk;                  // Not a match
	inc hl;
	ld a, (hl);                         // Second byte
	cp d;                               // Compare
	jr nz, skip_chunk;                  // Not a match
	inc hl;
	ld a, (hl);                         // Third byte
	cp e;                               // Compare
	srl e;                              // Shift to get
	srl e;                              // next byte
	srl e;                              // from the
	srl e;                              // chunk ID
	jr nz, skip_chunk;                  // Not a match
	inc hl;
	ld a, (hl);                         // Fourth byte
	cp e;                               // Compare
	jr nz, skip_chunk;                  // Not a match
	
	; Chunk found - read its data
	ld hl, (riff_chunk_size);           // Get chunk size
	ld b, h;                            // Copy to BC
	ld c, l;                            // for return value
	push bc;                            // Save chunk size
	ld a, (handle);                     // Get file handle
	call v_read;                        // Read chunk data
	pop bc;                             // Restore chunk size
	ret c;                              // Return if error
	
	xor a;                              // Set Z flag (chunk found)
	ret;                                // Return with chunk size in BC
	
skip_chunk:
	; Skip to the next chunk
	ld bc, (riff_chunk_size);           // Get chunk size
	ld a, (handle);                     // Get file handle
	ld ixl, 1;                          // Seek from current position
	ld de, 0;                           // High bytes of offset
	rst divmmc;                         // Issue a hookcode
	defb f_seek;                        // Seek to next chunk
	ret c;                              // Return if error
	jr chunk_loop;                      // Continue searching
	
chunk_not_found:
	or 1;                               // Clear Z flag
	ret;                                // Return

;;
; Create a new RIFF file
; @param IX - pointer to ASCIIZ file path
; @param DE - RIFF type (e.g. "WAVE")
; @return A - file handle
; @throws sets carry flag on error
;;
RIFFCreate:
	call v_open_w_create;               // Create file
	ret c;                              // Return if error
	ld (handle), a;                     // Store file handle
	
	; Write RIFF header
	ld hl, riff_buffer;                 // Buffer for header
	
	; Write "RIFF" signature
	ld (hl), 'R';                       // "R"
	inc hl;
	ld (hl), 'I';                       // "I"
	inc hl;
	ld (hl), 'F';                       // "F"
	inc hl;
	ld (hl), 'F';                       // "F"
	inc hl;
	
	; Write file size (initially 4, will be updated later)
	ld (hl), 4;                         // Size = 4 (just the format type)
	inc hl;
	ld (hl), 0;                         // 
	inc hl;
	ld (hl), 0;                         // 
	inc hl;
	ld (hl), 0;                         // 
	inc hl;
	
	; Write RIFF type
	ld (hl), e;                         // First byte of type
	inc hl;
	ld (hl), d;                         // Second byte of type
	inc hl;
	srl d;                              // Shift to get
	srl d;                              // next byte
	srl d;                              // from the
	srl d;                              // type
	ld (hl), d;                         // Third byte of type
	inc hl;
	srl d;                              // Shift to get
	srl d;                              // last byte
	srl d;                              // from the
	srl d;                              // type
	ld (hl), d;                         // Fourth byte of type
	
	; Write header to file
	ld a, (handle);                     // Get file handle
	ld bc, 12;                          // 12 bytes
	ld ix, riff_buffer;                 // RIFF header data
	call v_write;                       // Write header
	
	ld a, (handle);                     // Return file handle in A
	ret;                                // Return

;;
; Write a chunk to a RIFF file
; @param A - file handle
; @param DE - Chunk ID (e.g. "fmt " or "data")
; @param HL - Pointer to chunk data
; @param BC - Chunk data size
; @throws sets carry flag on error
;;
RIFFWriteChunk:
	ld (handle), a;                     // Store file handle
	push hl;                            // Save data pointer
	push bc;                            // Save data size
	
	; Seek to end of file
	ld ixl, 2;                          // Seek from end
	ld bc, 0;                           // Zero offset
	ld de, 0;                           // 
	rst divmmc;                         // Issue a hookcode
	defb f_seek;                        // Seek to end
	pop bc;                             // Restore data size
	pop hl;                             // Restore data pointer
	ret c;                              // Return if error
	
	; Write chunk header (ID and size)
	push hl;                            // Save data pointer
	push bc;                            // Save data size
	ld hl, riff_buffer;                 // Buffer for chunk header
	
	; Write chunk ID
	ld (hl), e;                         // First byte of chunk ID
	inc hl;
	ld (hl), d;                         // Second byte of chunk ID
	inc hl;
	srl d;                              // Shift to get
	srl d;                              // next byte
	srl d;                              // from the
	srl d;                              // chunk ID
	ld (hl), d;                         // Third byte of chunk ID
	inc hl;
	srl d;                              // Shift to get
	srl d;                              // last byte
	srl d;                              // from the
	srl d;                              // chunk ID
	ld (hl), d;                         // Fourth byte of chunk ID
	inc hl;
	
	; Write chunk size
	pop de;                             // Restore data size to DE
	push de;                            // Save it again
	ld (hl), e;                         // Low byte of size
	inc hl;
	ld (hl), d;                         // High byte of size
	inc hl;
	ld (hl), 0;                         // Size is 16-bit for now
	inc hl;
	ld (hl), 0;                         // 
	
	; Write chunk header
	ld a, (handle);                     // Get file handle
	ld bc, 8;                           // 8 bytes
	ld ix, riff_buffer;                 // Chunk header
	call v_write;                       // Write header
	pop bc;                             // Restore data size
	pop ix;                             // Restore data pointer to IX
	ret c;                              // Return if error
	
	; Write chunk data
	ld a, (handle);                     // Get file handle
	call v_write;                       // Write chunk data
	ret c;                              // Return if error
	
	; Update RIFF file size
	; First get current file size
	ld a, (handle);                     // Get file handle
	ld ixl, 2;                          // Seek from end
	ld bc, 0;                           // Zero offset
	ld de, 0;                           // 
	rst divmmc;                         // Issue a hookcode
	defb f_seek;                        // Get file size
	ret c;                              // Return if error
	
	; Subtract 8 from total size to get RIFF data size
	ld hl, 8;                           // RIFF header is 8 bytes
	scf;                                // Set carry for subtraction
	ccf;                                // Clear carry for SBC
	sbc hl, de;                         // Calculate size
	sbc hl, bc;                         // (file size - 8)
	
	; Seek to file size position (offset 4)
	ld a, (handle);                     // Get file handle
	ld ixl, 0;                          // Seek from start
	ld bc, 0;                           // Position 4
	ld de, 4;                           // 
	rst divmmc;                         // Issue a hookcode
	defb f_seek;                        // Seek to size field
	ret c;                              // Return if error
	
	; Write updated size
	ld (riff_buffer), hl;               // Store size in buffer
	ld a, (handle);                     // Get file handle
	ld bc, 4;                           // 4 bytes
	ld ix, riff_buffer;                 // Size value
	call v_write;                       // Write size
	ret;                                // Return