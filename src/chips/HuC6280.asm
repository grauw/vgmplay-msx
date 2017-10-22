;
; VGM HuC6280 chip
;
HuC6280: MACRO
	super: Chip HuC6280_name, System_Return
	ENDM

; ix = this
; iy = header
HuC6280_Construct:
	ld de,Header.huC6280Clock
	call Chip_Construct
	ret

;
	SECTION RAM

HuC6280_instance: HuC6280

	ENDS

HuC6280_name:
	db "HuC6280",0
