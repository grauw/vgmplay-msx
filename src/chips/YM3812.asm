;
; VGM YM3812 chip
;
YM3812: MACRO
	super: Chip YM3812_name, YM3812_Connect, YM3812_Install

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
YM3812_Construct:
	ld l,(iy + Header.ym3812Clock)
	ld h,(iy + Header.ym3812Clock + 1)
	ld e,(iy + Header.ym3812Clock + 2)
	ld d,(iy + Header.ym3812Clock + 3)
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM3812_Connect:
	call Drivers_TryCreateMoonSound_IY
	ret nc
	call Chip_SetDriver
	ld hl,MoonSound.SafeWriteRegister
	add hl,de
	ld (ix + YM3812.ProcessCommand.writeRegister),l
	ld (ix + YM3812.ProcessCommand.writeRegister + 1),h
	ret

; iy = player
; ix = this
YM3812_Install:
	ld a,(ix + YM3812.ProcessCommand.writeRegister)
	or (ix + YM3812.ProcessCommand.writeRegister + 1)
	ret z
	ld hl,YM3812.ProcessCommand
	ld a,5AH
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
	SECTION RAM

YM3812_instance: YM3812

	ENDS

YM3812_name:
	db "YM3812 (OPL2)",0
