# RIFF File Format

RIFF (Resource Interchange File Format) is a generic file container format used for storing multimedia data in tagged chunks. It is commonly used for audio (WAV) and video (AVI) files.

## Structure

A RIFF file consists of the following structure:

1. File header:
   - "RIFF" identifier (4 bytes)
   - File size minus 8 (4 bytes, little-endian)
   - File type identifier (4 bytes, e.g., "WAVE")

2. Chunks, each containing:
   - Chunk ID (4 bytes, e.g., "fmt " or "data")
   - Chunk size (4 bytes, little-endian)
   - Chunk data (variable size)

## SE BASIC RIFF Support

SE BASIC provides support for RIFF files through the SE/OS API. The following functions are available:

### SERIFFOpen
Opens a RIFF file and validates its header.
- Input: Pointer to ASCIIZ file path
- Output: File handle in A, Z flag set if valid RIFF file

### SERIFFReadChunk
Finds and reads a specific chunk in a RIFF file.
- Input: 
  - File handle in A
  - Buffer for chunk data in IX
  - Chunk ID to find in DE (e.g., "fmt ")
- Output: 
  - Chunk size in BC
  - Z flag set if chunk found

### SERIFFCreate
Creates a new RIFF file.
- Input:
  - Pointer to ASCIIZ file path in IX
  - RIFF type in DE (e.g., "WAVE")
- Output: File handle in A

### SERIFFWriteChunk
Writes a chunk to a RIFF file.
- Input:
  - File handle in A
  - Chunk ID in DE (e.g., "fmt " or "data")
  - Pointer to chunk data in HL
  - Chunk data size in BC

## Common RIFF Types

### WAVE (Audio)
- "WAVE" RIFF type
- "fmt " chunk: Contains format information
- "data" chunk: Contains the actual audio samples

### AVI (Video)
- "AVI " RIFF type
- "hdrl" chunk: Contains file header information
- "movi" chunk: Contains the actual audio/video data

## Example Usage

```basic
10 REM Create a WAVE file
20 IX = "SAMPLE.WAV"    ' File path
30 DE = "WAVE"          ' RIFF type
40 CALL SERIFFCreate    ' Create RIFF file
50 A = result           ' Get file handle

60 REM Add format chunk
70 DE = "fmt "          ' Chunk ID
80 HL = format_buffer   ' Pointer to format data
90 BC = 16              ' Format chunk size
100 CALL SERIFFWriteChunk

110 REM Add data chunk
120 DE = "data"         ' Chunk ID
130 HL = audio_buffer   ' Pointer to audio data
140 BC = audio_size     ' Audio data size
150 CALL SERIFFWriteChunk

160 REM Close file
170 CALL SEFileClose
```

## Notes

- All RIFF operations use little-endian byte order
- Chunk sizes do not include the 8-byte chunk header
- The file size in the RIFF header is the total file size minus 8 bytes