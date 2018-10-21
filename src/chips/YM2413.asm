;
; VGM YM2413 chip
;
YM2413: MACRO
	super: Chip YM2413_name, YM2413_Connect

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = header
YM2413_Construct:
	ld de,Header.ym2413Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM2413_Connect:
	call YM2413_TryCreate
	ret nc
	call Chip_SetDriver
	add hl,de
	ld (ix + YM2413.ProcessCommand.writeRegister),l
	ld (ix + YM2413.ProcessCommand.writeRegister + 1),h
	ret

; iy = drivers
; ix = this
; de <- driver
; hl <- safe write register offset
; f <- c: succeeded
YM2413_TryCreate:
	call Drivers_TryCreateMSXMusic_IY
	ld hl,MSXMusic.SafeWriteRegister
	ret

;
	SECTION RAM

YM2413_instance: YM2413

	ENDS

YM2413_name:
	db "YM2413 (OPLL)",0
