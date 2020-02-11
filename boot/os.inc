;	// UnoDOS 3 - An operating system for the divMMC SD card interface.
;	// Copyright (c) 2017-2020 Source Solutions, Inc.

;	// UnoDOS 3 is free software: you can redistribute it and/or modify
;	// it under the terms of the GNU General Public License as published by
;	// the Free Software Foundation, either version 3 of the License, or
;	// (at your option) any later version.
;	// 
;	// UnoDOS 3 is distributed in the hope that it will be useful,
;	// but WITHOUT ANY WARRANTY; without even the implied warranty o;
;	// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;	// GNU General Public License for more details.
;	// 
;	// You should have received a copy of the GNU General Public License
;	// along with UnoDOS 3. If not, see <http://www.gnu.org/licenses/>.

; 	// This source is compatible with Zeus
;	// (http://www.desdes.com/products/oldfiles)


;	// VERSION
	version equ "UnoDOS 3 [Version 3.0.90625]"


;	// divIDE / divMMC trap addresses
;	//
;	// $0000			: initialization
;	// $0008			: hook codes
;	// $0038			: maskable interrupt
;	// $0066			: non-maskable interrupt
;	// $04C6			: LOAD routine
;	// $0562			: SAVE routine
;	// $1FF8 - $1FFF	: map off area
;	// $3D00 - $3FFF	: TR-DOS traps


;	// EXTERNAL COMMANDS
;	// Execute at $2000. Maximum size 7168 bytes.
;	// ON ENTRY: HL is a pointer to the arguments or zero if no arguments.
;	//           Typically entry is using a BASIC line so valid end markers
;	//           include $0d, ':' and zero.
;	// ON EXIT:  SCF and A=error number - Print BASIC error.
;	//           SCF, A=0, HL=pointer   - Print custom message.
;	//									  Set bit 7 of last character as
;	//									  terminator.
;	//           CCF                    - Return cleanly to BASIC.
;	//           RET C                  - Use UnoDOS error handler.
;	// Note:     You should avoid leaving handles open when returning to BASIC.
;	//           Known bug: custom message handling can cause crashes.       


;	// RESTARTS
;	// RST $08:	 Syscall entry point. When running in main RAM (instead of 
;	//			 divMMC RAM), parameters use IX in place of HL.
;	// RST $10:	 Print character in A at current cursor position.
;	// RST $18:	 Call routine in BASIC ROM. Followed by DEFW addr.
;	// RST $30:	 Internal UnoDOS call.


;	// I/O PORTS
	mmcram equ $e3;						// divMMC RAM page (write only?)
	mmcdev equ $e7;						// divMMC device (write only?)	
	mmcspi equ $eb;						// divMMC SPI (read/write)


;	// UNODOS3 ROM ROUTINES
	v_rst10 equ $0010;					// vector to RST $10
	v_rst20 equ $0020;					// vector to RST $20
	v_pr_str equ $1fd0;					// vector to pr_str
	v_pr_msg equ $1fee;					// vector to L0C90
	V0297 equ $1ff1;					// vector to L0297
	V0861 equ $1fd3;					// vector to L0861
	V089A equ $1fd6;					// vector to L089A
	V0DEB equ $1fd9;					// vector to L0DEB
	V2488 equ $1fdc;					// vector to L2488
	V24A6 equ $1fdf;					// vector to L24A6
	V24C1 equ $1fe2;					// vector to L24C1
	V24CD equ $1fe5;					// vector to L24CD
	V24E6 equ $1fcd;					// vector to L24E6
	V24F2 equ $1fca;					// vector to L24F2
	V24F5 equ $1fe8;					// vector to L24F5
	V2502 equ $1feb;					// vector to L2502
	V1FFA equ $1ffa;					// vector to L1FFA


;	// UNODOS3 VARIABLES
;	// (stored in divMMC page 0)
	mmc_1 equ $2e7a;					// if SP is $3d00 - #3dff, automapper
;										// pages in
	mmc_sp equ $3dee;					// ? location of stack
	mmc_2 equ $3df4;					// ?
	call_num equ $3df8;					// syscall number
	mmc_3 equ $3df9;					// ? store memory page at one point
	cur_drive equ $3df3;				// ? current SD card selected


;	// UNODOS3 DYNAMIC ROUTINES AND VARIABLES
;	// (stored in divMMC RAM page 3)
	ext_cmd equ $2000;					// current external command


;	// UNODOS3 HOOK CODES
;	// Passed using RST $08 followed by the code
;	// If carry is set the error code in A is printed.

	hook_base equ 128;
	misc_base equ hook_base + 8;
	fsys_base equ misc_base + 16;

	disk_status equ hook_base + 0;		// $80	add a,b

	disk_read equ hook_base + 1;		// $81	add a,c
;										// Read one block of data from device A,
;										// at position BCDE at address HL

	disk_write equ hook_base + 2;		// $82	add a,d
;										// Write one block of data from device
;										//  A, at position BCDE at address HL

	disk_ioctl equ hook_base + 3;		// $83	add a,e

	disk_info equ hook_base + 4;		// $84	add a,h
;										// If A = 0 get a buffer at address HL
;										// filled with a list of available block
;										// devices. If A <> 0 get info for a
;										// specific device.
;										//
;										// Buffer format:
;										// <byte>  Device Path (see below)
;										// <byte>  Device Flags (block size, )
;										// <dword> Device size in blocks
;										//
;										// The buffer is over when you read a 
;										// Device Path and you get a 0.
;										// Does not currently return number of
;										// devices in A.
;										//
;										// Device Entry Description:
;										// [BYTE] DEVICE PATH
;										// +-------------------+-----------+
;										// |       MAJOR       |  MINOR    |
;										// +---+---+---+---+---+---+---+---+
;										// | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
;										// +---+---+---+---+---+---+---+---+
;										// | E | D | C | B   B | A   A   A |
;										// +---+---+---+---+---+---+---+---+
;										//
;										// A: MINOR
;										// 000 : RAW (whole device)
;										// 001 : 0	 (first partition/session)
;										// 010 : 1	 (second partition/session)
;										// 011 : 2	 (...)
;										// 100 : 3
;										// 101 : 4
;										// 110 : 5
;										// 111 : 6
;										//
;										// B:
;										// 00 : RESERVED
;										// 01 : IDE
;										// 10 : FLOPPY
;										// 11 : VIRTUAL
;										//
;										// C:
;										//  0 : PRIMARY
;										//  1 : SECONDARY
;										//
;										// D:
;										//  0 : MASTER
;										//  1 : SLAVE
;										//
;										// E:
;										//  0 : ATA
;										//  1 : ATAPI
;										//
;										// Needs changing for virtual devices.

	m_dosversion equ misc_base + 0;		// $88	adc a,b

	m_getsetdrv equ misc_base + 1;		// $89	adc a,c
;										// If A=0 get default drive in A.
;										// Else set default drive passed in A.
;										//
;										// LOGICAL DRIVES
;										// ---+--------------------------------
;										// BIT| 7-3            | 2-0
;										// ---+----------------+---------------
;										//    | Drv letter A-Z | Drv number 0-7
;										// ---+----------------+---------------
;										//
;										// Programs that need to print all 
;										// availabledrives must:
;										// 1. Use high 5 bits to print letter.
;										// 2. Print 'd'.
;										// 3. Use low 3 bits to print number.

	m_driveinfo	 equ misc_base + 2;		// $8a	adc a,d

	m_tapein equ misc_base + 3;			// $8b	adc a,e

	m_tapeout equ misc_base + 4;		// $8c	adc a,h

	m_gethandle equ misc_base + 5;		// $8d	adc a,l
;										// Get file handle of just loaded BASIC
;										// program in A. For use with single-
;										// file loaders.

	m_getdate equ misc_base + 6;		// $8e	adc a,(hl)
;										// Get current date/time in MS-DOS
;										// format. Drops the fifth byte so that
;										// it is only four bytes in length (only
;										// two seconds precision.
;										// Default: midnight 1982-04-23).

	f_mount equ fsys_base + 0;			// $98	sbc a,b

	f_umount equ fsys_base + 1;			// $99	sbc a,c

	f_open equ fsys_base + 2;			// $9a	sbc a,d
;										// Open file. A = drive. HL = Pointer to
;										// null-terminated string containing
;										// path and/or filename. B = file access
;										// mode. DE = Pointer to BASIC header
;										// data/buffer to be filled with 8 byte
;										// PLUS3DOS BASIC header. If you open a
;										// headerless file, the BASIC type is 
;										// $ff. Only used when specified in B.
;										// On return without error, A = file
;										// handle.

	f_close equ fsys_base + 3;			// $9b	sbc a,e
;										// Close a file or folder handle.
;										// A = handle.

	f_sync equ fsys_base + 4;			// $9c	sbc a,h
;										// For files that have been written to,
;										// syncs the file folder entry. Does not
;										// currently flush the write cache.
;										// A = handle

	f_read equ fsys_base + 5;			// $9d	sbc a,l
; 										// Read BC bytes at HL from file handle
;										// A. On return BC = number of bytes
;										// successfully read. File pointer is
;										// updated.

	f_write equ fsys_base + 6;			// $9e	sbc a,(hl)
;										// Write BC bytes from HL to file handle
;										// A. On return BC = number of bytes
;										// successfully written. File pointer is
;										// updated.

	f_seek equ fsys_base + 7;			// $9f	sbc a,a
;										// Seek BCDE bytes. A=handle. L = mode:
;										//	0: From start of file.
;										//	1: Forward from current position.
; 										//	2: Back from current position.
;										// On return BCDE=current file pointer.
;										// Does not currently return bytes
;										// successfully sought.
;										// NOTE: bug report - you must read/write
;										//       at least one byte after opening
;										//       a file before you do a seek.

	f_fgetpos equ fsys_base + 8;		// $a0	and b
;										// Get current file pointer. A = handle.

	f_fstat equ fsys_base + 9;			// $a1	and c
;										// Get file info/status to buffer at HL.
;										// A=handle. Buffer format:
;										// <byte>  drive
;										// <byte>  device
;										// <byte>  file attributes (MS-DOS frmt)
;										// <dword> date
;										// <dword> file size

	f_ftruncate equ fsys_base + 10;		// $a2	and d

	f_opendir equ fsys_base + 11;		// $a3	and e
;										// Open folder. A = drive. HL = Pointer
;										// to zero-terminated string with path
;										// to folder. B = folder access mode.
;										// Only the BASIC header bit matters,
;										// whether you want to read header
;										// information or not. On return without
;										// error, A = folder handle.

	f_readdir equ fsys_base + 12;		// $a4	and h
;										// Read a folder entry to a buffer
;										// pointed to by HL. A = handle.
;										// Buffer format:
;										//   <byte>   attributes (MS-DOS format)
;										//   <ASCIZ>  file/dirname
;										//   <dword>  date
;										//   <dword>  filesize
;										// If opened with BASIC header bit, the
;										// BASIC header follows the normal entry
;										// (with type = $ff if headerless).
;										// On return, if A = 1 there are more
;										// entries. If A = 0 then it is the end
;										// of the folder. Does not currently
;										// return the size of an entry, or zero
;										// if end of folder reached.

	f_telldir equ fsys_base + 13;		// $a5	and l

	f_seekdir equ fsys_base + 14;		// $a6	and (hl)

	f_rewinddir equ fsys_base + 15;		// $a7	and a

	f_getcwd equ fsys_base + 16;		// $a8	xor b
;										// Get current folder path (null-
;										// terminated) to buffer.
;										// A = drive. HL = pointer to buffer.

	f_chdir equ fsys_base + 17;			// $a9	xor c
;										// Change current directory path
;										// A = drive. HL = pointer to ASCIZ
;										// folder/path.

	f_mkdir equ fsys_base + 18;			// $aa	xor d

	f_rmdir equ fsys_base + 19;			// $ab	xor e

	f_stat equ fsys_base + 20;			// $ac	xor h

	f_unlink equ fsys_base + 21;		// $ad	xor l
;										// Delete a file. A=drive. HL=pointer to
;										// ASCIZ file/path.

	f_truncate equ fsys_base + 22;		// $ae	xor (hl)

	f_attrib equ fsys_base + 23;		// $af	xor a	

	f_rename equ fsys_base + 24;		// $b0	or b

	f_getfree equ fsys_base + 25;		// $b1	or c

	fa_read equ %00000001;				// $01	ld bc, nn	read access

	fa_write equ %00000010;				// $02	ld (bc), a	write access

	fa_open_ex equ %00000000;			// $00	nop			open if exists, else 
;										//					error

	fa_open_al equ %00001000;			// $08	ex af, af'	open if exists, else
;										//					create

	fa_create_new equ %00000100;		// $04	inc b		create if does not
;										//					exist, else error

	fa_create_al equ %00001100;			// $0c	inc c		create if does not
;										//					exist, else open
;										//					and truncate

	fa_use_header equ %01000000;		// $40	ld b, b		use plus3dos header
;										//					(passed in de)


;	// UNODOS ERRORS
;	// Error text is read from an external file. 
	EOK equ 1;							// OK
	EGENERAL equ 2;						// Syntax error
	ESTEND equ 3;						// Statement lost
	EWRTYPE equ 4;						// Wrong file type
	ENOENT equ 5;						// No such file or folder
	EIO equ 6;							// I/O error
	EBADFN equ 7;						// Bad filename
	EACCES equ 8;						// Access denied
	ENOSPC equ 9;						// Disk full
	ENXIO equ 10;						// Bad I/O request
	ENODRV equ 11;						// No such drive
	ENFILE equ 12;						// Too many open files
	EBADF equ 13;						// Bad file descriptor
	ENODEV equ 14;						// No such device
	EOVERFLOW equ 15;					// File pointer overflow
	EISDIR equ 16;						// Is a folder
	ENOTDIR equ 17;						// Is not a folder
	EEXIST equ 18;						// File exists
	EPATH equ 19;						// Bad path
	ENOSYS equ 20;						// Missing SYS
	ENAMETOOLONG equ 21;				// Path too long
	ENOCMD equ 22;						// No such command
	EINUSE equ 23;						// File in use
	ERDONLY equ 24;						// File is read only
	EVFAIL equ 25;						// Verify failed
	EIOFAIL equ 26;						// Loading .IO failed
	ENOTEMPTY equ 27;					// Folder not empty
	EMAPRAM equ 28;						// MAPRAM active
	EDRVBUSY equ 29;					// Drive busy
	EBADFS equ 30;						// Unknown file system
	EDEVBUSY equ 31;					// Device is BUSY
