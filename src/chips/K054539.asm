;
; VGM K054539 chip
;
K054539: MACRO
	super: Chip K054539_name, System_Return
	ENDM

; ix = this
; iy = header
K054539_Construct:
	ld de,Header.k054539Clock
	call Chip_Construct
	ret

;
	SECTION RAM

K054539_instance: K054539

	ENDS

K054539_name:
	db "K054539",0
