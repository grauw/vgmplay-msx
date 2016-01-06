;
; VGM YM2151 chip
;
YM2151: MACRO
	super: Chip YM2151_name, YM2151_Connect, YM2151_Install

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	ENDM

; ix = this
; iy = header
YM2151_Construct: PROC
	ld l,(iy + Header.version)
	ld h,(iy + Header.version + 1)
	ld bc,-102H
	add hl,bc
	jr nc,Pre1_02
	ld l,(iy + Header.ym2151Clock)
	ld h,(iy + Header.ym2151Clock + 1)
	ld e,(iy + Header.ym2151Clock + 2)
	ld d,(iy + Header.ym2151Clock + 3)
	jp Continue
Pre1_02:
	ld l,(iy + Header.ym2413Clock)
	ld h,(iy + Header.ym2413Clock + 1)
	ld e,(iy + Header.ym2413Clock + 2)
	ld d,(iy + Header.ym2413Clock + 3)
Continue:
	call Chip_Construct
	ret
	ENDP

; iy = drivers
; ix = this
YM2151_Connect:
	call Drivers_TryCreateSFG_IY
	ret nc
	call Chip_SetDriver
	ld hl,SFG.SafeWriteRegister
	add hl,de
	ld (ix + YM2151.ProcessCommand.writeRegister),l
	ld (ix + YM2151.ProcessCommand.writeRegister + 1),h
	ret

; iy = player
; ix = this
YM2151_Install:
	ld a,(ix + YM2151.ProcessCommand.writeRegister)
	or (ix + YM2151.ProcessCommand.writeRegister + 1)
	ret z
	ld hl,YM2151.ProcessCommand
	ld a,54H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
YM2151_instance: YM2151

YM2151_name:
	db "YM2151 (OPM)",0
