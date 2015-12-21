;
; VGM YMF262 chip
;
YMF262: MACRO
	super: Chip YMF262_name, YMF262_Connect, YMF262_Install

	; ix = player
	; iy = reader
	ProcessPort0Command:
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext

	; ix = player
	; iy = reader
	ProcessPort1Command:
		call Reader_ReadWord_IY
		call 0
	writeRegister2: equ $ - 2
		jp Player_ProcessNext
	ENDM

; ix = this
; iy = header
YMF262_Construct:
	ld l,(iy + Header.ymf262Clock)
	ld h,(iy + Header.ymf262Clock + 1)
	ld e,(iy + Header.ymf262Clock + 2)
	ld d,(iy + Header.ymf262Clock + 3)
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YMF262_Connect:
	call Drivers_TryCreateMoonSound_IY
	ret nc
	ld hl,MoonSound.SafeWriteRegister
	add hl,de
	ld (ix + YMF262.writeRegister),l
	ld (ix + YMF262.writeRegister + 1),h
	ld hl,MoonSound.SafeWriteRegister2
	add hl,de
	ld (ix + YMF262.writeRegister2),l
	ld (ix + YMF262.writeRegister2 + 1),h
	ret

; iy = player
; ix = this
YMF262_Install:
	ld a,(ix + YMF262.writeRegister)
	or (ix + YMF262.writeRegister + 1)
	ret z
	ld hl,YMF262.ProcessPort0Command
	ld a,5EH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YMF262.ProcessPort1Command
	ld a,5FH
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
YMF262_instance: YMF262

YMF262_name:
	db "YMF262 (OPL3)",0
