;
; VGM YM3526 chip
;
YM3526: MACRO
	super: Chip YM3526_name, YM3526_Connect, YM3526_Install

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
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
YM3526_Connect: PROC
	call Drivers_TryCreateMSXAudio_IY
	jr nc,TryMoonSound
	call Chip_SetDriver
	ld hl,MSXAudio.SafeWriteRegister
	add hl,de
	ld (ix + YM3526.ProcessCommand.writeRegister),l
	ld (ix + YM3526.ProcessCommand.writeRegister + 1),h
	ret
TryMoonSound:
	call Drivers_TryCreateMoonSound_IY
	ret nc
	call Chip_SetDriver
	ld hl,MoonSound.SafeWriteRegister
	add hl,de
	ld (ix + YM3526.ProcessCommand.writeRegister),l
	ld (ix + YM3526.ProcessCommand.writeRegister + 1),h
	ret
	ENDP

; iy = player
; ix = this
YM3526_Install:
	ld a,(ix + YM3526.ProcessCommand.writeRegister)
	or (ix + YM3526.ProcessCommand.writeRegister + 1)
	ret z
	ld hl,YM3526.ProcessCommand
	ld a,5BH
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
	SECTION RAM

YM3526_instance: YM3526

	ENDS

YM3526_name:
	db "YM3526 (OPL)",0
