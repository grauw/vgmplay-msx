;
; VGM OKIM6295 chip
;
OKIM6295: MACRO
	super: Chip OKIM6295_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
OKIM6295_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.okiM6295Clock - 80H)
	ld h,(iy + Header.okiM6295Clock - 80H + 1)
	ld e,(iy + Header.okiM6295Clock - 80H + 2)
	ld d,(iy + Header.okiM6295Clock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
	SECTION RAM

OKIM6295_instance: OKIM6295

	ENDS

OKIM6295_name:
	db "OKI M6295",0
