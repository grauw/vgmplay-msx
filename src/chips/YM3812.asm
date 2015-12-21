;
; VGM YM3812 chip
;
YM3812: MACRO
	super: Chip YM3812_name, Chip_ConnectDefault, Chip_InstallDefault
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

;
YM3812_instance: YM3812

YM3812_name:
	db "YM3812 (OPL2)",0
