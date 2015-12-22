;
; VGM C140 chip
;
C140: MACRO
	super: Chip C140_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
C140_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.c140Clock - 80H)
	ld h,(iy + Header.c140Clock - 80H + 1)
	ld e,(iy + Header.c140Clock - 80H + 2)
	ld d,(iy + Header.c140Clock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
C140_instance: C140

C140_name:
	db "C140",0
