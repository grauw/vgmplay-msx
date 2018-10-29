;
; VGM YM3812 chip
;
YM3812: MACRO
	super: Chip YM3812_name, YM3812_Connect

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; ix = player
	; iy = reader
	ProcessCommandDual: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = header
YM3812_Construct:
	ld de,Header.ym3812Clock
	jp Chip_Construct

; iy = drivers
; ix = this
YM3812_Connect:
	call YM3812_TryCreate
	ret nc
	call Chip_SetDriver
	add hl,de
	ld (ix + YM3812.ProcessCommand.writeRegister),l
	ld (ix + YM3812.ProcessCommand.writeRegister + 1),h
	call Chip_IsDualChip
	ret z
	call YM3812_TryCreate
	ret nc
	call Chip_SetDriver2
	add hl,de
	ld (ix + YM3812.ProcessCommandDual.writeRegister),l
	ld (ix + YM3812.ProcessCommandDual.writeRegister + 1),h
	ret

; iy = drivers
; ix = this
; de <- driver
; hl <- safe write register offset
; f <- c: succeeded
YM3812_TryCreate:
	call Drivers_TryCreateMoonSound_IY
	ld hl,MoonSound.SafeWriteRegister
	ret c
	call Drivers_TryCreateMoonSoundC0_IY
	ld hl,MoonSoundC0.SafeWriteRegister
	ret

;
	SECTION RAM

YM3812_instance: YM3812

	ENDS

YM3812_name:
	db "YM3812 (OPL2)",0
