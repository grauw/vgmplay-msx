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
	ENDM

; ix = this
; iy = header
YM2203_Construct:
	ld de,Header.ym2203Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM2203_Connect: PROC
	call Drivers_TryCreateOPN_IY
	jr nc,TryOPNA
	call Chip_SetDriver
	ld hl,OPN.SafeWriteRegister
	add hl,de
	ld (ix + YM2203.ProcessCommand.writeRegister),l
	ld (ix + YM2203.ProcessCommand.writeRegister + 1),h
	ret
TryOPNA:
	call Drivers_TryCreateOPNA_IY
	jr nc,TryNeotron
	call Chip_SetDriver
	ld hl,OPNA.SafeWriteRegister
	add hl,de
	ld (ix + YM2203.ProcessCommand.writeRegister),l
	ld (ix + YM2203.ProcessCommand.writeRegister + 1),h
	ret
TryNeotron:
	call Drivers_TryCreateNeotron_IY
	jr nc,TryOPNOnSFGPSG
	call Chip_SetDriver
	ld hl,Neotron.SafeWriteRegisterOPN
	add hl,de
	ld (ix + YM2203.ProcessCommand.writeRegister),l
	ld (ix + YM2203.ProcessCommand.writeRegister + 1),h
	ret
TryOPNOnSFGPSG:
	call Drivers_TryCreateOPNOnSFGPSG_IY
	ret nc
	call Chip_SetDriver
	ld hl,OPNOnSFGPSG.SafeWriteRegister
	add hl,de
	ld (ix + YM2203.ProcessCommand.writeRegister),l
	ld (ix + YM2203.ProcessCommand.writeRegister + 1),h
	ret
	ENDP

;
	SECTION RAM

YM2203_instance: YM2203

	ENDS

YM2203_name:
	db "YM2203 (OPN)",0
