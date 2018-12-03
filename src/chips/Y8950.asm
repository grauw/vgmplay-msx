;
; VGM Y8950 chip
;
Y8950: MACRO
	this:
	super: Chip Y8950_name, Y8950_Connect

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; b = bit 7: dual chip number
	; dehl = size
	; ix = player
	; iy = reader
	ProcessDataBlock: PROC
		bit 7,b
		jp z,Player_SkipDataBlock
	process: equ $ - 2
		jp Player_SkipDataBlock
	processDual: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = header
Y8950_Construct:
	ld de,Header.y8950Clock
	jp Chip_Construct

; ix = this
Y8950_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

; iy = drivers
; ix = this
Y8950_Connect: PROC
	call Drivers_TryCreateMSXAudio_IY
	jr nc,TryOPL3
	call Chip_SetDriver
	ld hl,MSXAudio.SafeWriteRegister
	add hl,de
	ld (ix + Y8950.ProcessCommand.writeRegister),l
	ld (ix + Y8950.ProcessCommand.writeRegister + 1),h
	ld hl,MSXAudio.ProcessDataBlock
	add hl,de
	ld (ix + Y8950.ProcessDataBlock.process),l
	ld (ix + Y8950.ProcessDataBlock.process + 1),h
	ret
TryOPL3:
	call Drivers_TryCreateOPL3_IY
	jr nc,TryMoonSound
	call Chip_SetDriver
	ld hl,OPL3.SafeWriteRegister
	add hl,de
	ld (ix + Y8950.ProcessCommand.writeRegister),l
	ld (ix + Y8950.ProcessCommand.writeRegister + 1),h
	ret
TryMoonSound:
	call Drivers_TryCreateMoonSound_IY
	ret nc
	call Chip_SetDriver
	ld hl,MoonSound.SafeWriteRegister
	add hl,de
	ld (ix + Y8950.ProcessCommand.writeRegister),l
	ld (ix + Y8950.ProcessCommand.writeRegister + 1),h
	ret
	ENDP

;
	SECTION RAM

Y8950_instance: Y8950

	ENDS

Y8950_name:
	db "Y8950 (MSX-AUDIO)",0
