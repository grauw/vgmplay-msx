;
; VGM HuC6280 chip
;
HuC6280: MACRO
	super: Chip HuC6280_name
	ENDM

; ix = this
; iy = header
HuC6280_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.huC6280Clock - 80H)
	ld h,(iy + Header.huC6280Clock - 80H + 1)
	ld e,(iy + Header.huC6280Clock - 80H + 2)
	ld d,(iy + Header.huC6280Clock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
HuC6280_instance: HuC6280

HuC6280_name:
	db "HuC6280",0
