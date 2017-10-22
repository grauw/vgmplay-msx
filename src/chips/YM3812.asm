;
; VGM YM3812 chip
;
YM3812: MACRO
	super: Chip YM3812_name, YM3812_Connect

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
		call System_Return
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	ENDM

; ix = this
; iy = header
YM3812_Construct:
	ld de,Header.ym3812Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM3812_Connect:
	call Drivers_TryCreateMoonSound_IY
	ret nc
	call Chip_SetDriver
	ld hl,MoonSound.SafeWriteRegister
	add hl,de
	ld (ix + YM3812.ProcessCommand.writeRegister),l
	ld (ix + YM3812.ProcessCommand.writeRegister + 1),h
	ret

;
	SECTION RAM

YM3812_instance: YM3812

	ENDS

YM3812_name:
	db "YM3812 (OPL2)",0
