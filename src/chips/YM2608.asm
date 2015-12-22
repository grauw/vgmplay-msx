;
; VGM YM2608 chip
;
YM2608: MACRO
	super: Chip YM2608_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
YM2608_Construct:
	ld l,(iy + Header.ym2608Clock)
	ld h,(iy + Header.ym2608Clock + 1)
	ld e,(iy + Header.ym2608Clock + 2)
	ld d,(iy + Header.ym2608Clock + 3)
	call Chip_Construct
	ret

;
YM2608_instance: YM2608

YM2608_name:
	db "YM2608 (OPNA)",0
