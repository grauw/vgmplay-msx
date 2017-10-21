;
; VGM Y8950 chip
;
Y8950: MACRO
	this:
	super: Chip Y8950_name, Y8950_Connect, Y8950_Install

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
		call System_Return
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP

	; ix = player
	; iy = reader
	ProcessDataBlock: PROC
		jp Player_SkipDataBlock
	process: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = header
Y8950_Construct:
	ld de,Header.y8950Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
Y8950_Connect:
	call Drivers_TryCreateMSXAudio_IY
	ret nc
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

; iy = player
; ix = this
Y8950_Install:
	ld hl,Y8950.ProcessCommand
	ld a,5CH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,Y8950.ProcessDataBlock
	ld a,88H
	call Player_InstallDataBlockHandler_IY_IXOffset
	ret

;
	SECTION RAM

Y8950_instance: Y8950

	ENDS

Y8950_name:
	db "Y8950 (MSX-AUDIO)",0
