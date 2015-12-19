;
; VGM YM3526 chip
;
YM3526: MACRO
	super: Chip YM3526_name
	ENDM

; ix = this
; iy = header
YM3526_Construct:
	ld l,(iy + Header.ym3526Clock)
	ld h,(iy + Header.ym3526Clock + 1)
	ld e,(iy + Header.ym3526Clock + 2)
	ld d,(iy + Header.ym3526Clock + 3)
	call Chip_Construct
	ret

;
YM3526_instance: YM3526

YM3526_name:
	db "YM3526 (OPL)",0
