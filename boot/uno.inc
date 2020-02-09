;	// SE Basic IV 4.2 Cordelia - A classic BASIC interpreter for the Z80 architecture.
;	// Copyright (c) 1999-2019 Source Solutions, Inc.

;	// SE Basic IV is free software: you can redistribute it and/or modify
;	// it under the terms of the GNU General Public License as published by
;	// the Free Software Foundation, either version 3 of the License, or
;	// (at your option) any later version.
;	// 
;	// SE Basic IV is distributed in the hope that it will be useful,
;	// but WITHOUT ANY WARRANTY; without even the implied warranty o;
;	// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;	// GNU General Public License for more details.
;	// 
;	// You should have received a copy of the GNU General Public License
;	// along with SE Basic IV. If not, see <http://www.gnu.org/licenses/>.

	uno_reg equ $fc3b
	uno_dat equ $fd3b
 
	master_conf equ 0
	master_mapper equ 1
	flash_spi equ 2
	flash_cs equ 3
	scan_code equ 4
	key_stat equ 5
	joy_conf equ 6
	key_map equ 7
	nmi_event equ 8
	mouse_data equ 9
	mouse_status equ 10
	scandbl_ctrl equ 11
	raster_line equ 12
	raster_ctrl equ 13
	dev_control equ 14
	core_addr equ $fc
	core_boot equ $fd
	cold_boot equ $fe
	core_id equ $ff

	SPI_PORT equ $eb
	OUT_PORT equ $e7
	MMC_0 equ $fe ; D0 LOW = SLOT0 active
	CMD0 equ $40
	CMD1 equ $41
	CMD8 equ $48
	SET_BLOCKLEN equ $50
	READ_SINGLE equ $51
	CMD41 equ $69
	CMD55 equ $77
	CMD58 equ $7a
