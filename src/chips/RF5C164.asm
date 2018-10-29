;
; VGM RF5C164 chip
;
RF5C164: MACRO
	super: Chip RF5C164_name, System_Return
	ENDM

; ix = this
; iy = header
RF5C164_Construct:
	ld de,Header.rf5c164Clock
	jp Chip_Construct

;
	SECTION RAM

RF5C164_instance: RF5C164

	ENDS

RF5C164_name:
	db "RF5C164",0
