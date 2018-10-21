;
; VGM YM2203 chip
;
YM2203: MACRO
	super: Chip YM2203_name, YM2203_Connect

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

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
YM2203_Construct:
	ld de,Header.ym2203Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM2203_Connect:
	call YM2203_TryCreate
	ret nc
	call Chip_SetDriver
	add hl,de
	ld (ix + YM2203.ProcessCommand.writeRegister),l
	ld (ix + YM2203.ProcessCommand.writeRegister + 1),h
	call Chip_IsDualChip
	ret z
	call YM2203_TryCreate
	ret nc
	call Chip_SetDriver2
	add hl,de
	ld (ix + YM2203.ProcessCommandDual.writeRegister),l
	ld (ix + YM2203.ProcessCommandDual.writeRegister + 1),h
	ret

; iy = drivers
; ix = this
; de <- driver
; hl <- safe write register offset
; f <- c: succeeded
YM2203_TryCreate:
	call Drivers_TryCreateOPN_IY
	ld hl,OPN.SafeWriteRegister
	ret c
	call Drivers_TryCreateOPNA_IY
	ld hl,OPNA.SafeWriteRegister
	ret c
	call Drivers_TryCreateNeotron_IY
	ld hl,Neotron.SafeWriteRegisterOPN
	ret c
	call Drivers_TryCreateOPNOnSFGPSG_IY
	ld hl,OPNOnSFGPSG.SafeWriteRegister
	ret

;
	SECTION RAM

YM2203_instance: YM2203

	ENDS

YM2203_name:
	db "YM2203 (OPN)",0
