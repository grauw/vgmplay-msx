;
; VGM OKIM6258 chip
;
OKIM6258: MACRO
	super: Chip OKIM6258_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
OKIM6258_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.okiM6258Clock - 80H)
	ld h,(iy + Header.okiM6258Clock - 80H + 1)
	ld e,(iy + Header.okiM6258Clock - 80H + 2)
	ld d,(iy + Header.okiM6258Clock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
	SECTION RAM

OKIM6258_instance: OKIM6258

	ENDS

OKIM6258_name:
	db "OKI M6258",0
