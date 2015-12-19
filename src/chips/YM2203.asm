;
; VGM YM2203 chip
;
YM2203: MACRO
	super: Chip YM2203_name
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

;
YM2203_instance: YM2203

YM2203_name:
	db "YM2203 (OPN)",0
