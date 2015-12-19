;
; VGM YMF262 chip
;
YMF262: MACRO
	super: Chip YMF262_name
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

;
YMF262_instance: YMF262

YMF262_name:
	db "YMF262 (OPL3)",0
