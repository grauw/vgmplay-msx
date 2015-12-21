;
; VGM AY8910 chip
;
AY8910: MACRO
	super: Chip AY8910_ay8910Name
	chipType:
		db 0
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
	ld bc,AY8910_ym2149Name
	jp z,AY8910_SetName
	cp 11H
	ld bc,AY8910_ym3439Name
	jp z,AY8910_SetName
	cp 12H
	ld bc,AY8910_ymz284Name
	jp z,AY8910_SetName
	cp 13H
	ld bc,AY8910_ymz294Name
	jp z,AY8910_SetName
	cp 1H
	ld bc,AY8910_ay8912Name
	jp z,AY8910_SetName
	cp 2H
	ld bc,AY8910_ay8913Name
	jp z,AY8910_SetName
	cp 3H
	ld bc,AY8910_ay8930Name
	jp z,AY8910_SetName
	ret

; bc = name
; ix = this
AY8910_SetName:
	ld (ix + AY8910.super.name),c
	ld (ix + AY8910.super.name + 1),b
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

