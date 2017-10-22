;
; VGM YM2608 chip
;
YM2608: MACRO
	this:
	super: Chip YM2608_name, YM2608_Connect

	; ix = player
	; iy = reader
	ProcessPort0Command: PROC
		call Reader_ReadWord_IY
		call System_Return
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP

	; ix = player
	; iy = reader
	ProcessPort1Command: PROC
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
YM2608_Construct:
	ld de,Header.ym2608Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM2608_Connect: PROC
	call Drivers_TryCreateOPNA_IY
	jr nc,TryOPNOnSFGPSG
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
TryOPNOnSFGPSG:
	call Drivers_TryCreateOPNOnSFGPSG_IY
	ret nc
	call Chip_SetDriver
	ld hl,OPNOnSFGPSG.SafeWriteRegister
	add hl,de
	ld (ix + YM2608.ProcessPort0Command.writeRegister),l
	ld (ix + YM2608.ProcessPort0Command.writeRegister + 1),h
	ld hl,OPNOnSFGPSG.SafeWriteRegister2
	add hl,de
	ld (ix + YM2608.ProcessPort1Command.writeRegister),l
	ld (ix + YM2608.ProcessPort1Command.writeRegister + 1),h
	ret
	ENDP

;
	SECTION RAM

YM2608_instance: YM2608

	ENDS

YM2608_name:
	db "YM2608 (OPNA)",0
