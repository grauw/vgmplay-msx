;
; VGM YM2610 chip
;
YM2610: MACRO
	super: Chip YM2610_ym2610Name, YM2610_Connect

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
	ProcessDataBlockA: PROC
		bit 7,b
		jp z,Player_SkipDataBlock
	process: equ $ - 2
		jp Player_SkipDataBlock
	processDual: equ $ - 2
		ENDP

	; b = bit 7: dual chip number
	; dehl = size
	; ix = player
	; iy = reader
	ProcessDataBlockB: PROC
		bit 7,b
		jp z,Player_SkipDataBlock
	process: equ $ - 2
		jp Player_SkipDataBlock
	processDual: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = header
YM2610_Construct:
	ld de,Header.ym2610BClock
	call Chip_Construct
	call YM2610_GetName
	jp Chip_SetName

; ix = this
YM2610_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

; ix = this
; f <- nz: YM2610B
YM2610_IsYM2610B:
	bit 7,(ix + YM2610.super.clock + 3)
	ret

; iy = drivers
; ix = this
YM2610_Connect: PROC
	call YM2610_IsYM2610B
	jr z,TryNeotron
	call Drivers_TryCreateOPNBBOnNeotronOPNA_IY
	jr nc,TryNeotron
	call Chip_SetDriver
	ld hl,OPNBBOnNeotronOPNA.SafeWriteRegister
	add hl,de
	ld (ix + YM2610.ProcessPort0Command.writeRegister),l
	ld (ix + YM2610.ProcessPort0Command.writeRegister + 1),h
	ld hl,OPNBBOnNeotronOPNA.SafeWriteRegister2
	add hl,de
	ld (ix + YM2610.ProcessPort1Command.writeRegister),l
	ld (ix + YM2610.ProcessPort1Command.writeRegister + 1),h
	ld hl,OPNBBOnNeotronOPNA.ProcessDataBlockA
	add hl,de
	ld (ix + YM2610.ProcessDataBlockA.process),l
	ld (ix + YM2610.ProcessDataBlockA.process + 1),h
	ld hl,OPNBBOnNeotronOPNA.ProcessDataBlockB
	add hl,de
	ld (ix + YM2610.ProcessDataBlockB.process),l
	ld (ix + YM2610.ProcessDataBlockB.process + 1),h
	ret
TryNeotron:
	call Drivers_TryCreateNeotron_IY
	jr nc,TryOPNA
	call Chip_SetDriver
	ld hl,Neotron.SafeWriteRegister
	add hl,de
	ld (ix + YM2610.ProcessPort0Command.writeRegister),l
	ld (ix + YM2610.ProcessPort0Command.writeRegister + 1),h
	ld hl,Neotron.SafeWriteRegister2
	add hl,de
	ld (ix + YM2610.ProcessPort1Command.writeRegister),l
	ld (ix + YM2610.ProcessPort1Command.writeRegister + 1),h
	ld hl,Neotron.ProcessDataBlockA
	add hl,de
	ld (ix + YM2610.ProcessDataBlockA.process),l
	ld (ix + YM2610.ProcessDataBlockA.process + 1),h
	ld hl,Neotron.ProcessDataBlockB
	add hl,de
	ld (ix + YM2610.ProcessDataBlockB.process),l
	ld (ix + YM2610.ProcessDataBlockB.process + 1),h
	ret
TryOPNA:
	call Drivers_TryCreateOPNA_IY
	jr nc,TryOPNOnSFGPSG
	call Chip_SetDriver
	ld hl,OPNA.SafeWriteRegister
	add hl,de
	ld (ix + YM2610.ProcessPort0Command.writeRegister),l
	ld (ix + YM2610.ProcessPort0Command.writeRegister + 1),h
	ld hl,OPNA.SafeWriteRegister2
	add hl,de
	ld (ix + YM2610.ProcessPort1Command.writeRegister),l
	ld (ix + YM2610.ProcessPort1Command.writeRegister + 1),h
	ret
TryOPNOnSFGPSG:
	call Drivers_TryCreateOPNOnSFGPSG_IY
	ret nc
	call Chip_SetDriver
	ld hl,OPNOnSFGPSG.SafeWriteRegister
	add hl,de
	ld (ix + YM2610.ProcessPort0Command.writeRegister),l
	ld (ix + YM2610.ProcessPort0Command.writeRegister + 1),h
	ld hl,OPNOnSFGPSG.SafeWriteRegister2
	add hl,de
	ld (ix + YM2610.ProcessPort1Command.writeRegister),l
	ld (ix + YM2610.ProcessPort1Command.writeRegister + 1),h
	ret
	ENDP

; ix = this
; hl <- name
YM2610_GetName:
	call YM2610_IsYM2610B
	ld hl,YM2610_ym2610Name
	ret z
	ld hl,YM2610_ym2610bName
	ret

;
	SECTION RAM

YM2610_instance: YM2610

	ENDS

YM2610_ym2610Name:
	db "YM2610 (OPNB)",0

YM2610_ym2610bName:
	db "YM2610B (OPNB)",0
