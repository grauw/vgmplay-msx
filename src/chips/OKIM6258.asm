;
; VGM OKIM6258 chip
;
OKIM6258: MACRO
	super: Chip OKIM6258_name, System_Return
	ENDM

; ix = this
; iy = header
OKIM6258_Construct:
	ld de,Header.okiM6258Clock
	jp Chip_Construct

;
	SECTION RAM

OKIM6258_instance: OKIM6258

	ENDS

OKIM6258_name:
	db "OKI M6258",0
