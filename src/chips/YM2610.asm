;
; VGM YM2610 chip
;
YM2610: MACRO
	super: Chip YM2610_ym2610Name, YM2610_Connect, YM2610_Install

	; ix = player
	; iy = reader
	ProcessPort0Command: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP

	; ix = player
	; iy = reader
	ProcessPort1Command: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	ENDM

; ix = this
; iy = header
YM2610_Construct:
	ld de,Header.ym2610BClock
	call Chip_Construct
	call YM2610_IsYM2610B
	ret z
	ld hl,YM2610_ym2610bName
	call Chip_SetName
	ret

; ix = this
; f <- nz: YM2610B
YM2610_IsYM2610B:
	bit 7,(ix + YM2610.super.clock + 3)
	ret

; iy = drivers
; ix = this
YM2610_Connect: PROC
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

; iy = player
; ix = this
YM2610_Install:
	ld a,(ix + YM2610.ProcessPort0Command.writeRegister)
	or (ix + YM2610.ProcessPort0Command.writeRegister + 1)
	ret z
	ld hl,YM2610.ProcessPort0Command
	ld a,58H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2610.ProcessPort1Command
	ld a,59H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
	SECTION RAM

YM2610_instance: YM2610

	ENDS

YM2610_ym2610Name:
	db "YM2610 (OPNB)",0

YM2610_ym2610bName:
	db "YM2610B (OPNB)",0
