;
; VGM RF5C68 chip
;
RF5C68: MACRO
	super: Chip RF5C68_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
RF5C68_Construct:
	ld l,(iy + Header.rf5c68Clock)
	ld h,(iy + Header.rf5c68Clock + 1)
	ld e,(iy + Header.rf5c68Clock + 2)
	ld d,(iy + Header.rf5c68Clock + 3)
	call Chip_Construct
	ret

;
RF5C68_instance: RF5C68

RF5C68_name:
	db "RF5C68",0
