;
; VGM YM2413 chip
;
YM2413: MACRO
	super: Chip YM2413_name, YM2413_Connect, YM2413_Install

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
YM2413_Construct:
	ld de,Header.ym2413Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM2413_Connect:
	call Drivers_TryCreateMSXMusic_IY
	ret nc
	call Chip_SetDriver
	ld hl,MSXMusic.SafeWriteRegister
	add hl,de
	ld (ix + YM2413.ProcessCommand.writeRegister),l
	ld (ix + YM2413.ProcessCommand.writeRegister + 1),h
	ret

; iy = player
; ix = this
YM2413_Install:
	ld hl,YM2413.ProcessCommand
	ld a,51H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
	SECTION RAM

YM2413_instance: YM2413

	ENDS

YM2413_name:
	db "YM2413 (OPLL)",0
