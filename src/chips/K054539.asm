;
; VGM K054539 chip
;
K054539: MACRO
	super: Chip K054539_name
	ENDM

; ix = this
; iy = header
K054539_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.k054539Clock - 80H)
	ld h,(iy + Header.k054539Clock - 80H + 1)
	ld e,(iy + Header.k054539Clock - 80H + 2)
	ld d,(iy + Header.k054539Clock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
K054539_instance: K054539

K054539_name:
	db "K054539",0
