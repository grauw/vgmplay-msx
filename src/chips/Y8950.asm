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
Y8950_Connect:
	call Y8950_TryCreate
	ret nc
	call Chip_SetDriver
	add hl,de
	ld (ix + Y8950.ProcessCommand.writeRegister),l
	ld (ix + Y8950.ProcessCommand.writeRegister + 1),h
	ld l,c
	ld h,b
	add hl,de
	ret c
	ld (ix + Y8950.ProcessDataBlock.process),l
	ld (ix + Y8950.ProcessDataBlock.process + 1),h
	ret

; iy = drivers
; ix = this
; de <- driver
; hl <- safe write register offset
; bc <- process data block offset or -1
; f <- c: succeeded
Y8950_TryCreate:
	call Drivers_TryCreateMSXAudio_IY
	ld hl,MSXAudio.SafeWriteRegister
	ld bc,MSXAudio.ProcessDataBlock
	ret c
	call Drivers_TryCreateOPL3_IY
	ld hl,OPL3.SafeWriteRegister
	ld bc,-1
	ret c
	call Drivers_TryCreateMoonSound_IY
	ld hl,MoonSound.SafeWriteRegister
	ld bc,-1
	ret

;
	SECTION RAM

Y8950_instance: Y8950

	ENDS

Y8950_name:
	db "Y8950 (MSX-AUDIO)",0
