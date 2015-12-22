;
; VGM SN76489 chip
;
SN76489: MACRO
	super: Chip SN76489_name, SN76489_Connect, SN76489_Install

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_Read_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	ENDM

; ix = this
; iy = header
SN76489_Construct:
	ld l,(iy + Header.sn76489Clock)
	ld h,(iy + Header.sn76489Clock + 1)
	ld e,(iy + Header.sn76489Clock + 2)
	ld d,(iy + Header.sn76489Clock + 3)
	call Chip_Construct
	ret

; iy = drivers
; ix = this
SN76489_Connect: PROC
	call Drivers_TryCreateMMM_IY
	jr nc,TryFranky
	ld hl,MMM.SafeWriteRegister
	add hl,de
	ld (ix + SN76489.ProcessCommand.writeRegister),l
	ld (ix + SN76489.ProcessCommand.writeRegister + 1),h
	ret
TryFranky:
	call Drivers_TryCreateFranky_IY
	ret nc
	ld hl,Franky.SafeWriteRegister
	add hl,de
	ld (ix + SN76489.ProcessCommand.writeRegister),l
	ld (ix + SN76489.ProcessCommand.writeRegister + 1),h
	ret
	ENDP

; iy = player
; ix = this
SN76489_Install:
	ld a,(ix + SN76489.ProcessCommand.writeRegister)
	or (ix + SN76489.ProcessCommand.writeRegister + 1)
	ret z
	ld hl,SN76489.ProcessCommand
	ld a,50H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
SN76489_instance: SN76489

SN76489_name:
	db "SN76489 (DCSG)",0
