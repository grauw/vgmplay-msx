;
; VGM Y8950 chip
;
Y8950: MACRO
	super: Chip Y8950_name, Chip_ConnectDefault, Chip_InstallDefault
	ENDM

; ix = this
; iy = header
Y8950_Construct:
	ld l,(iy + Header.y8950Clock)
	ld h,(iy + Header.y8950Clock + 1)
	ld e,(iy + Header.y8950Clock + 2)
	ld d,(iy + Header.y8950Clock + 3)
	call Chip_Construct
	ret

;
Y8950_instance: Y8950

Y8950_name:
	db "Y8950 (MSX-AUDIO)",0
