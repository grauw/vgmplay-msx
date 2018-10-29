;
; VGM OKIM6295 chip
;
OKIM6295: MACRO
	super: Chip OKIM6295_name, System_Return
	ENDM

; ix = this
; iy = header
OKIM6295_Construct:
	ld de,Header.okiM6295Clock
	jp Chip_Construct

;
	SECTION RAM

OKIM6295_instance: OKIM6295

	ENDS

OKIM6295_name:
	db "OKI M6295",0
