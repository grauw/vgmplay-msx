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

	; ix = player
	; iy = reader
	ProcessPort0CommandDual: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; ix = player
	; iy = reader
	ProcessPort1CommandDual: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = header
YMF262_Construct:
	ld de,Header.ymf262Clock
	jp Chip_Construct

; ix = this
YMF262_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

; iy = drivers
; ix = this
YMF262_Connect:
	call YMF262_TryCreate
	ret nc
	call Chip_SetDriver
	add hl,de
	ld (ix + YMF262.ProcessPort0Command.writeRegister),l
	ld (ix + YMF262.ProcessPort0Command.writeRegister + 1),h
	ld l,c
	ld h,b
	add hl,de
	ld (ix + YMF262.ProcessPort1Command.writeRegister),l
	ld (ix + YMF262.ProcessPort1Command.writeRegister + 1),h
	call Chip_IsDualChip
	ret z
	call YMF262_TryCreate
	ret nc
	call Chip_SetDriver2
	add hl,de
	ld (ix + YMF262.ProcessPort0CommandDual.writeRegister),l
	ld (ix + YMF262.ProcessPort0CommandDual.writeRegister + 1),h
	ld l,c
	ld h,b
	add hl,de
	ld (ix + YMF262.ProcessPort1CommandDual.writeRegister),l
	ld (ix + YMF262.ProcessPort1CommandDual.writeRegister + 1),h
	ret

; iy = drivers
; ix = this
; bc <- safe write register 2 offset
; de <- driver
; hl <- safe write register offset
; f <- c: succeeded
YMF262_TryCreate:
	call Drivers_TryCreateMoonSound_IY
	ld hl,MoonSound.SafeWriteRegister
	ld bc,MoonSound.SafeWriteRegister2
	ret c
	call Drivers_TryCreateMoonSoundC0_IY
	ld hl,MoonSoundC0.SafeWriteRegister
	ld bc,MoonSoundC0.SafeWriteRegister2
	ret

;
	SECTION RAM

YMF262_instance: YMF262

	ENDS

YMF262_name:
	db "YMF262 (OPL3)",0
