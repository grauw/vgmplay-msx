;
; VGM RF5C164 chip
;
RF5C164: MACRO
	super: Chip RF5C164_name
	ENDM

; ix = this
; iy = header
RF5C164_Construct:
	ld l,(iy + Header.rf5c164Clock)
	ld h,(iy + Header.rf5c164Clock + 1)
	ld e,(iy + Header.rf5c164Clock + 2)
	ld d,(iy + Header.rf5c164Clock + 3)
	call Chip_Construct
	ret

;
RF5C164_instance: RF5C164

RF5C164_name:
	db "RF5C164",0
