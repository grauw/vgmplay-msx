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
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM3812_Connect: PROC
	call Drivers_TryCreateMoonSound_IY
	jr nc,TryMoonSoundC0
	call Chip_SetDriver
	ld hl,MoonSound.SafeWriteRegister
	add hl,de
	ld (ix + YM3812.ProcessCommand.writeRegister),l
	ld (ix + YM3812.ProcessCommand.writeRegister + 1),h
	call Chip_IsDualChip
	ret z
TryMoonSoundC0:
	call Drivers_TryCreateMoonSoundC0_IY
	ret nc
	call Chip_SetDriver2
	ld hl,MoonSoundC0.SafeWriteRegister
	add hl,de
	ld (ix + YM3812.ProcessCommandDual.writeRegister),l
	ld (ix + YM3812.ProcessCommandDual.writeRegister + 1),h
	ret
	ENDP

;
	SECTION RAM

YM3812_instance: YM3812

	ENDS

YM3812_name:
	db "YM3812 (OPL2)",0
