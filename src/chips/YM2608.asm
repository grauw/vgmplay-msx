;
; VGM YM2608 chip
;
YM2608: MACRO
	this:
	super: Chip YM2608_name, Header.ym2608Clock, YM2608_Connect

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessPort0Command: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessPort1Command: PROC
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
YM2608_Construct: equ Chip_Construct
;	jp Chip_Construct

; ix = this
YM2608_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

; iy = drivers
; ix = this
YM2608_Connect: PROC
	call Drivers_TryCreateOPNA_IY
	jr nc,TryOPNAOnSFGPSGMSXAudio
	call Chip_SetDriver
	ld hl,OPNA.SafeWriteRegister
	add hl,de
	ld (ix + YM2608.ProcessPort0Command.writeRegister),l
	ld (ix + YM2608.ProcessPort0Command.writeRegister + 1),h
	ld hl,OPNA.SafeWriteRegister2
	add hl,de
	ld (ix + YM2608.ProcessPort1Command.writeRegister),l
	ld (ix + YM2608.ProcessPort1Command.writeRegister + 1),h
	ld hl,OPNA.ProcessDataBlock
	add hl,de
	ld (ix + YM2608.ProcessDataBlock.process),l
	ld (ix + YM2608.ProcessDataBlock.process + 1),h
	ret
TryOPNAOnSFGPSGMSXAudio:
	call Drivers_TryCreateOPNAOnSFGPSGMSXAudio_IY
	ret nc
	call Chip_SetDriver
	ld hl,OPNAOnSFGPSGMSXAudio.SafeWriteRegister
	add hl,de
	ld (ix + YM2608.ProcessPort0Command.writeRegister),l
	ld (ix + YM2608.ProcessPort0Command.writeRegister + 1),h
	ld hl,OPNAOnSFGPSGMSXAudio.SafeWriteRegister2
	add hl,de
	ld (ix + YM2608.ProcessPort1Command.writeRegister),l
	ld (ix + YM2608.ProcessPort1Command.writeRegister + 1),h
	ld hl,OPNAOnSFGPSGMSXAudio.ProcessDataBlock
	add hl,de
	ld (ix + YM2608.ProcessDataBlock.process),l
	ld (ix + YM2608.ProcessDataBlock.process + 1),h
	ret
	ENDP

;
	SECTION RAM

YM2608_instance: YM2608

	ENDS

YM2608_name:
	db "YM2608 (OPNA)",0
