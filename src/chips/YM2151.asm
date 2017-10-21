;
; VGM YM2151 chip
;
YM2151: MACRO
	super: Chip YM2151_name, YM2151_Connect, YM2151_Install

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
YM2151_Construct:
	ld de,Header.ym2151Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM2151_Connect:
	call Drivers_TryCreateSFG_IY
	ret nc
	call Chip_SetDriver
	ld hl,SFG.SafeWriteRegister
	add hl,de
	ld (ix + YM2151.ProcessCommand.writeRegister),l
	ld (ix + YM2151.ProcessCommand.writeRegister + 1),h
	ret

; iy = player
; ix = this
YM2151_Install:
	ld hl,YM2151.ProcessCommand
	ld a,54H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
	SECTION RAM

YM2151_instance: YM2151

	ENDS

YM2151_name:
	db "YM2151 (OPM)",0
