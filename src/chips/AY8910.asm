;
; VGM AY8910 chip
;
AY8910: MACRO
	super: Chip AY8910_ay8910Name, AY8910_Connect, AY8910_Install
	chipType:
		db 0

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
	Continue:
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP

	; ix = player
	; iy = reader
	ProcessCommandDual: PROC
		call Reader_ReadWord_IY
		bit 7,e
		jr z,ProcessCommand.Continue
		res 7,e
		call System_Return
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	ENDM

; ix = this
; iy = header
AY8910_Construct:
	ld de,Header.ay8910Clock
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
	call Chip_SetDriver
	ld hl,PSG.SafeWriteRegister
	add hl,de
	ld (ix + AY8910.ProcessCommand.writeRegister),l
	ld (ix + AY8910.ProcessCommand.writeRegister + 1),h
	jr DualChip
TryMFRPSG:
	call Drivers_TryCreateMFRPSG_IY
	ret nc
	call Chip_SetDriver
	ld hl,MFRPSG.SafeWriteRegister
	add hl,de
	ld (ix + AY8910.ProcessCommand.writeRegister),l
	ld (ix + AY8910.ProcessCommand.writeRegister + 1),h
	ret
DualChip:
	call Chip_IsDualChip
	ret z
	call Drivers_TryCreateMFRPSG_IY
	ret nc
	call Chip_SetDriver2
	ld hl,MFRPSG.SafeWriteRegister
	add hl,de
	ld (ix + AY8910.ProcessCommandDual.writeRegister),l
	ld (ix + AY8910.ProcessCommandDual.writeRegister + 1),h
	ret
	ENDP

; iy = player
; ix = this
AY8910_Install: PROC
	call Chip_IsDualChip
	jr nz,DualChip
	ld hl,AY8910.ProcessCommand
	ld a,0A0H
	call Player_InstallCommandHandler_IY_IXOffset
	ret
DualChip:
	ld hl,AY8910.ProcessCommandDual
	ld a,0A0H
	call Player_InstallCommandHandler_IY_IXOffset
	ret
	ENDP

;
	SECTION RAM

AY8910_instance: AY8910

	ENDS

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
