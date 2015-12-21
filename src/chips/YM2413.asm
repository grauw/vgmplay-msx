;
; VGM YM2413 chip
;
YM2413: MACRO
	super: Chip YM2413_name, YM2413_Connect, YM2413_Install

	; ix = player
	; iy = reader
	ProcessCommand:
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
	ENDM

; ix = this
; iy = header
YM2413_Construct:
	ld l,(iy + Header.ym2413Clock)
	ld h,(iy + Header.ym2413Clock + 1)
	ld e,(iy + Header.ym2413Clock + 2)
	ld d,(iy + Header.ym2413Clock + 3)
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM2413_Connect:
	call Drivers_TryCreateMSXMusic_IY
	ret nc
	ld hl,MSXMusic.SafeWriteRegister
	add hl,de
	ld (ix + YM2413.writeRegister),l
	ld (ix + YM2413.writeRegister + 1),h
	ret

; iy = player
; ix = this
YM2413_Install:
	ld a,(ix + YM2413.writeRegister)
	or (ix + YM2413.writeRegister + 1)
	ret z
	ld hl,YM2413.ProcessCommand
	ld a,51H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
YM2413_instance: YM2413

YM2413_name:
	db "YM2413 (OPLL)",0
