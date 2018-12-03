;
; VGM YMF278B chip
;
YMF278B: MACRO
	this:
	super: Chip YMF278B_name, YMF278B_Connect

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_Read_IY
		dec a
		jr z,FM2
		jp p,Wave
	FM1: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP
	FM2: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP
	Wave: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP
		ENDP

	; dehl = size
	; ix = player
	; iy = reader
	ProcessROMDataBlock: PROC
		jp Player_SkipDataBlock
	process: equ $ - 2
		ENDP

	; dehl = size
	; ix = player
	; iy = reader
	ProcessRAMDataBlock: PROC
		jp Player_SkipDataBlock
	process: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = header
YMF278B_Construct:
	ld de,Header.ymf278bClock
	jp Chip_Construct

; ix = this
YMF278B_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

; iy = drivers
; ix = this
YMF278B_Connect:
	call Drivers_TryCreateMoonSound_IY
	ret nc
	call Chip_SetDriver
	ld hl,MoonSound.SafeWriteRegister
	add hl,de
	ld (ix + YMF278B.ProcessCommand.FM1.writeRegister),l
	ld (ix + YMF278B.ProcessCommand.FM1.writeRegister + 1),h
	ld hl,MoonSound.SafeWriteRegister2
	add hl,de
	ld (ix + YMF278B.ProcessCommand.FM2.writeRegister),l
	ld (ix + YMF278B.ProcessCommand.FM2.writeRegister + 1),h
	ld hl,MoonSound.SafeWriteRegisterWave
	add hl,de
	ld (ix + YMF278B.ProcessCommand.Wave.writeRegister),l
	ld (ix + YMF278B.ProcessCommand.Wave.writeRegister + 1),h
	ld hl,MoonSound.ProcessROMDataBlock
	add hl,de
	ld (ix + YMF278B.ProcessROMDataBlock.process),l
	ld (ix + YMF278B.ProcessROMDataBlock.process + 1),h
	ld hl,MoonSound.ProcessRAMDataBlock
	add hl,de
	ld (ix + YMF278B.ProcessRAMDataBlock.process),l
	ld (ix + YMF278B.ProcessRAMDataBlock.process + 1),h
	ret

;
	SECTION RAM

YMF278B_instance: YMF278B

	ENDS

YMF278B_name:
	db "YMF278B (OPL4)",0
