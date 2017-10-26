;
; VGM YMF262 chip
;
YMF262: MACRO
	super: Chip YMF262_name, YMF262_Connect

	; ix = player
	; iy = reader
	ProcessPort0Command: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; ix = player
	; iy = reader
	ProcessPort1Command: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
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

;
	SECTION RAM

YMF262_instance: YMF262

	ENDS

YMF262_name:
	db "YMF262 (OPL3)",0
