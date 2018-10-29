;
; VGM Pokey chip
;
Pokey: MACRO
	super: Chip Pokey_name, System_Return
	ENDM

; ix = this
; iy = header
Pokey_Construct:
	ld de,Header.pokeyClock
	jp Chip_Construct

; ix = this
Pokey_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

;
	SECTION RAM

Pokey_instance: Pokey

	ENDS

Pokey_name:
	db "POKEY",0
