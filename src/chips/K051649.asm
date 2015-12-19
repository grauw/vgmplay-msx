;
; VGM K051649 chip
;
K051649: MACRO
	super: Chip K051649_name
	ENDM

; ix = this
; iy = header
K051649_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.k051649Clock - 80H)
	ld h,(iy + Header.k051649Clock - 80H + 1)
	ld e,(iy + Header.k051649Clock - 80H + 2)
	ld d,(iy + Header.k051649Clock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
K051649_instance: K051649

K051649_name:
	db "K051649 (SCC)",0
