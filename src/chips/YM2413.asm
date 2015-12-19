;
; VGM YM2413 chip
;
YM2413: MACRO
	super: Chip YM2413_name
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

;
YM2413_instance: YM2413

YM2413_name:
	db "YM2413 (OPLL)",0
