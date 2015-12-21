;
; VGM AY8910 chip
;
AY8910: MACRO
	super: Chip AY8910_ay8910Name, AY8910_Connect, AY8910_Install
	chipType:
		db 0

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
AY8910_Construct:
	ld l,(iy + Header.ay8910Clock)
	ld h,(iy + Header.ay8910Clock + 1)
	ld e,(iy + Header.ay8910Clock + 2)
	ld d,(iy + Header.ay8910Clock + 3)
	call Chip_Construct
	ld a,(iy + Header.ay8910ChipType)
	ld (ix + AY8910.chipType),a
	cp 10H
	ld hl,AY8910_ym2149Name
	jp z,Chip_SetName
	cp 11H
	ld hl,AY8910_ym3439Name
	jp z,Chip_SetName
	cp 12H
	ld hl,AY8910_ymz284Name
	jp z,Chip_SetName
	cp 13H
	ld hl,AY8910_ymz294Name
	jp z,Chip_SetName
	cp 1H
	ld hl,AY8910_ay8912Name
	jp z,Chip_SetName
	cp 2H
	ld hl,AY8910_ay8913Name
	jp z,Chip_SetName
	cp 3H
	ld hl,AY8910_ay8930Name
	jp z,Chip_SetName
	ret

; iy = drivers
; ix = this
AY8910_Connect: PROC
	call Drivers_TryCreatePSG_IY
	jp nc,TryMFRPSG
	ld hl,PSG.SafeWriteRegister
	add hl,de
	ld (ix + AY8910.writeRegister),l
	ld (ix + AY8910.writeRegister + 1),h
	ret
TryMFRPSG:
	call Drivers_TryCreateMFRPSG_IY
	ret nc
	ld hl,MFRPSG.SafeWriteRegister
	add hl,de
	ld (ix + AY8910.writeRegister),l
	ld (ix + AY8910.writeRegister + 1),h
	ret
	ENDP

; iy = player
; ix = this
AY8910_Install:
	ld a,(ix + AY8910.writeRegister)
	or (ix + AY8910.writeRegister + 1)
	ret z
	ld hl,AY8910.ProcessCommand
	ld a,0A0H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
AY8910_instance: AY8910

AY8910_ay8910Name:
	db "AY-3-8910 (PSG)",0

AY8910_ay8912Name:
	db "AY-3-8912 (PSG)",0

AY8910_ay8913Name:
	db "AY-3-8913 (PSG)",0

AY8910_ay8930Name:
	db "AY8930 (EPSG)",0

AY8910_ym2149Name:
	db "YM2149 (SSG)",0

AY8910_ym3439Name:
	db "YM3439 (SSG)",0

AY8910_ymz284Name:
	db "YMZ284 (SSGL)",0

AY8910_ymz294Name:
	db "YMZ294 (SSG)",0

