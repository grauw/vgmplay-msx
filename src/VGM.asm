;
; A VGM track
;
VGM: MACRO
	reader:
		dw 0
	drivers:
		dw 0
	header:
		Header
	chips:
		Chips
	size:
	ENDM

; de = mapped reader
; hl = drivers
; ix = this
VGM_Construct:
	ld (ix + VGM.reader),e
	ld (ix + VGM.reader + 1),d
	ld (ix + VGM.drivers),l
	ld (ix + VGM.drivers + 1),h
	call VGM_GetReader_IY
	push ix
	call VGM_GetHeader
	call Header_Construct
	ex (sp),ix
	pop iy
	push ix
	call VGM_GetChips
	call Chips_Construct
	pop ix
	push ix
	push ix
	call VGM_GetDrivers
	ex (sp),ix
	pop iy
	call VGM_GetChips
	call Chips_Connect
	pop ix
	ret

; ix = this
VGM_Destruct:
	push ix
	call VGM_GetChips
	call Chips_Destruct
	pop ix
	ret

; ix = this
; iy <- reader
VGM_GetReader_IY:
	ld e,(ix + VGM.reader)
	ld d,(ix + VGM.reader + 1)
	ld iyl,e
	ld iyh,d
	ret

; ix = this
; ix <- drivers
VGM_GetDrivers:
	ld e,(ix + VGM.drivers)
	ld d,(ix + VGM.drivers + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; ix <- header
VGM_GetHeader:
	ld de,VGM.header
	add ix,de
	ret

; ix = this
; ix <- chips
VGM_GetChips:
	ld de,VGM.chips
	add ix,de
	ret

; ix = this
VGM_PrintInfo:
	push ix
	call VGM_GetHeader
	call Header_GetGD3Offset
	pop ix
	push de
	call VGM_GetReader_IY
	pop de
	call nz,System_PrintCrLf
	call nz,GD3_PrintInfoEnglish
	call System_PrintCrLf
	push ix
	call VGM_GetHeader
	call Header_PrintInfo
	pop ix
	push ix
	call VGM_GetChips
	call Chips_PrintInfo
	pop ix
	ret
