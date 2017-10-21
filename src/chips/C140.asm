;
; VGM C140 chip
;
C140: MACRO
	super: Chip C140_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
C140_Construct:
	ld de,Header.c140Clock
	call Chip_Construct
	ret

;
	SECTION RAM

C140_instance: C140

	ENDS

C140_name:
	db "C140",0
