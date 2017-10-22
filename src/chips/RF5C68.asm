;
; VGM RF5C68 chip
;
RF5C68: MACRO
	super: Chip RF5C68_name, System_Return
	ENDM

; ix = this
; iy = header
RF5C68_Construct:
	ld de,Header.rf5c68Clock
	call Chip_Construct
	ret

;
	SECTION RAM

RF5C68_instance: RF5C68

	ENDS

RF5C68_name:
	db "RF5C68",0
