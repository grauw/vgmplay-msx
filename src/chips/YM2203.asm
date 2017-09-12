;
; VGM YM2203 chip
;
YM2203: MACRO
	super: Chip YM2203_name, YM2203_Connect, YM2203_Install

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
	Continue:
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	ENDM

; ix = this
; iy = header
YM2203_Construct:
	ld l,(iy + Header.ym2203Clock)
	ld h,(iy + Header.ym2203Clock + 1)
	ld e,(iy + Header.ym2203Clock + 2)
	ld d,(iy + Header.ym2203Clock + 3)
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM2203_Connect:
	call Drivers_TryCreateOPN_IY
	ret nc
	ld hl,OPN.SafeWriteRegister
	add hl,de
	ld (ix + YM2203.ProcessCommand.writeRegister),l
	ld (ix + YM2203.ProcessCommand.writeRegister + 1),h
	ret

; iy = player
; ix = this
YM2203_Install:
	ld a,(ix + YM2203.ProcessCommand.writeRegister)
	or (ix + YM2203.ProcessCommand.writeRegister + 1)
	ret z
	ld hl,YM2203.ProcessCommand
	ld a,55H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
	SECTION RAM

YM2203_instance: YM2203

	ENDS

YM2203_name:
	db "YM2203 (OPN)",0
