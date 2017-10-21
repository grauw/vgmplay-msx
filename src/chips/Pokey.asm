;
; VGM Pokey chip
;
Pokey: MACRO
	super: Chip Pokey_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
Pokey_Construct:
	ld de,Header.pokeyClock
	call Chip_Construct
	ret

;
	SECTION RAM

Pokey_instance: Pokey

	ENDS

Pokey_name:
	db "POKEY",0
