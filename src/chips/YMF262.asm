;
; VGM YMF262 chip
;
YMF262: MACRO
	super: Chip YMF262_name, YMF262_Connect, YMF262_Install

	; ix = player
	; iy = reader
	ProcessPort0Command: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP

	; ix = player
	; iy = reader
	ProcessPort1Command: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	ENDM

; ix = this
; iy = header
YMF262_Construct:
	ld de,Header.ymf262Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YMF262_Connect:
	call Drivers_TryCreateMoonSound_IY
	ret nc
	call Chip_SetDriver
	ld hl,MoonSound.SafeWriteRegister
	add hl,de
	ld (ix + YMF262.ProcessPort0Command.writeRegister),l
	ld (ix + YMF262.ProcessPort0Command.writeRegister + 1),h
	ld hl,MoonSound.SafeWriteRegister2
	add hl,de
	ld (ix + YMF262.ProcessPort1Command.writeRegister),l
	ld (ix + YMF262.ProcessPort1Command.writeRegister + 1),h
	ret

; iy = player
; ix = this
YMF262_Install:
	ld hl,YMF262.ProcessPort0Command
	ld a,5EH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YMF262.ProcessPort1Command
	ld a,5FH
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
	SECTION RAM

YMF262_instance: YMF262

	ENDS

YMF262_name:
	db "YMF262 (OPL3)",0
