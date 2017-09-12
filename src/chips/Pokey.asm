;
; VGM Pokey chip
;
Pokey: MACRO
	super: Chip Pokey_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
Pokey_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.pokeyClock - 80H)
	ld h,(iy + Header.pokeyClock - 80H + 1)
	ld e,(iy + Header.pokeyClock - 80H + 2)
	ld d,(iy + Header.pokeyClock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
	SECTION RAM

Pokey_instance: Pokey

	ENDS

Pokey_name:
	db "POKEY",0
