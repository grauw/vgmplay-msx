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
	player:
		Player
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
	ld bc,256
	call VGM_GetHeaderHL
	call VGM_GetReaderIY
	ex de,hl
	call MappedReader_ReadBlock_IY
	push ix
	call VGM_GetHeader
	call Header_Construct
	push ix
	pop iy
	call Chips_Construct
	pop ix
	ret

; ix = this
; iy <- reader
VGM_GetReaderIY:
	ld e,(ix + VGM.reader)
	ld d,(ix + VGM.reader + 1)
	ld iyl,e
	ld iyh,d
	ret

; ix = this
; iy <- reader
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
; hl <- header
VGM_GetHeaderHL:
	ld e,ixl
	ld d,ixh
	ld hl,VGM.header
	add hl,de
	ret

; ix = this
; ix <- player
VGM_GetPlayer:
	ld de,VGM.player
	add ix,de
	ret

; ix = this
VGM_PrintInfo:
	push ix
	call VGM_GetHeader
	call Header_GetGD3Offset
	pop ix
	push de
	call VGM_GetReaderIY
	pop de
	call nz,System_PrintCrLf
	call nz,GD3_PrintInfoEnglish
	push ix
	call VGM_GetHeader
	call System_PrintCrLf
	call Header_PrintInfo
	call Chips_PrintInfo
	pop ix
	ret

; a = nr of loops
; ix = this
VGM_Play:
	call VGM_GetHeaderHL
	call VGM_GetReaderIY
	push ix
	call VGM_GetPlayer
	ld e,iyl
	ld d,iyh
	call Player_Construct
	ex (sp),ix
	pop iy
	push ix
	call VGM_GetDrivers
	call Drivers_Install
	pop ix
	push ix
	call VGM_GetPlayer
	call Player_Play
	pop ix
	ret
