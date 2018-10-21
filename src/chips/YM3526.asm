;
; VGM YM3526 chip
;
YM3526: MACRO
	super: Chip YM3526_name, YM3526_Connect

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
YM3526_Construct:
	ld de,Header.ym3526Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM3526_Connect:
	call YM3526_TryCreate
	ret nc
	call Chip_SetDriver
	add hl,de
	ld (ix + YM3526.ProcessCommand.writeRegister),l
	ld (ix + YM3526.ProcessCommand.writeRegister + 1),h
	call Chip_IsDualChip
	ret z
	call YM3526_TryCreate
	ret nc
	call Chip_SetDriver2
	add hl,de
	ld (ix + YM3526.ProcessCommandDual.writeRegister),l
	ld (ix + YM3526.ProcessCommandDual.writeRegister + 1),h
	ret

; iy = drivers
; ix = this
; de <- driver
; hl <- safe write register offset
; f <- c: succeeded
YM3526_TryCreate:
	call Drivers_TryCreateMSXAudio_IY
	ld hl,MSXAudio.SafeWriteRegister
	ret c
	call Drivers_TryCreateMoonSound_IY
	ld hl,MoonSound.SafeWriteRegister
	ret c
	call Drivers_TryCreateMoonSoundC0_IY
	ld hl,MoonSoundC0.SafeWriteRegister
	ret

;
	SECTION RAM

YM3526_instance: YM3526

	ENDS

YM3526_name:
	db "YM3526 (OPL)",0
