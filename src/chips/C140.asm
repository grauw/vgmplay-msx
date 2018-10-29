;
; VGM C140 chip
;
C140: MACRO
	super: Chip C140_name, System_Return
	ENDM

; ix = this
; iy = header
C140_Construct:
	ld de,Header.c140Clock
	jp Chip_Construct

;
	SECTION RAM

C140_instance: C140

	ENDS

C140_name:
	db "C140",0
