;
; VGM YM3812 chip
;
YM3812: MACRO
	super: Chip YM3812_name, Header.ym3812Clock, YM3812_Connect

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; hl' = time remaining
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
YM3812_Construct: equ Chip_Construct
;	jp Chip_Construct

; ix = this
YM3812_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

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
	call Drivers_TryCreateOPL3_IY
	ld hl,OPL3.SafeWriteRegister
	ret c
	call Drivers_TryCreateMoonSound_IY
	ld hl,MoonSound.SafeWriteRegister
	ret

;
	SECTION RAM

YM3812_instance: YM3812

	ENDS

YM3812_name:
	db "YM3812 (OPL2)",0
