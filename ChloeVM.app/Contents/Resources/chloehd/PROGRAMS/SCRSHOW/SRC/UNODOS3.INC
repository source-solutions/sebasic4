;	// vector table address

	vector equ $04c4;

;	// SE Basic IV DOS API

	SEFileAppend equ vector;			// $00
	SEFileClose equ vector + 3;			// $01
	SEFileCreate equ vector + 6;		// $02
	SEFileLoad equ vector + 9;			// $03
	SEFileOpen equ vector + 12;			// $04
	SEFileOpenExists equ vector + 15;	// $05
	SEFileRead equ vector + 18;			// $06
	SEFileReadOne equ vector + 21;		// $07
	SEFileRemove equ vector + 24;		// $08
	SEFileRename equ vector + 27;		// $09
	SEFileSave equ vector + 30;			// $0a
	SEFileWrite equ vector + 33;		// $0b
	SEFileWriteOne equ vector + 36;		// $0c
	SEFolderCreate equ vector + 39;		// $0d
	SEFolderOpen equ vector + 42;		// $0e
	SEFolderRead equ vector + 45;		// $0f
	SEFolderRemove equ vector + 48;		// $10
	SEFolderSet equ vector + 51; 		// $11


;	// UnoDOS 3 hook codes

	divmmc equ 8;
	hook_base equ 128;
	misc_base equ hook_base + 8;
	fsys_base equ misc_base + 16;
	disk_status equ hook_base + 0;
	disk_read equ hook_base + 1;
	disk_write equ hook_base + 2;
	disk_ioctl equ hook_base + 3;
	disk_info equ hook_base + 4;
	m_dosversion equ misc_base + 0;
	m_getsetdrv equ misc_base + 1;
	m_driveinfo	 equ misc_base + 2;
	m_tapein equ misc_base + 3;
	m_tapeout equ misc_base + 4;
	m_gethandle equ misc_base + 5;
	m_getdate equ misc_base + 6;
	f_mount equ fsys_base + 0;
	f_umount equ fsys_base + 1;
	f_open equ fsys_base + 2;
	f_close equ fsys_base + 3;
	f_sync equ fsys_base + 4;
	f_read equ fsys_base + 5;
	f_write equ fsys_base + 6;
	f_seek equ fsys_base + 7;
	f_fgetpos equ fsys_base + 8;
	f_fstat equ fsys_base + 9;
	f_ftruncate equ fsys_base + 10;
	f_opendir equ fsys_base + 11;
	f_readdir equ fsys_base + 12;
	f_telldir equ fsys_base + 13;
	f_seekdir equ fsys_base + 14;
	f_rewinddir equ fsys_base + 15;
	f_getcwd equ fsys_base + 16;
	f_chdir equ fsys_base + 17;
	f_mkdir equ fsys_base + 18;
	f_rmdir equ fsys_base + 19;
	f_stat equ fsys_base + 20;
	f_unlink equ fsys_base + 21;
	f_truncate equ fsys_base + 22;
	f_attrib equ fsys_base + 23;
	f_rename equ fsys_base + 24;
	f_getfree equ fsys_base + 25;
	fa_read equ %00000001;
	fa_write equ %00000010;
	fa_open_ex equ %00000000;
	fa_open_al equ %00001000;
	fa_create_new equ %00000100;
	fa_create_al equ %00001100;
	fa_use_header equ %01000000;
