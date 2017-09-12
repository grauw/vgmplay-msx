;
; VGM NESAPU chip
;
NESAPU: MACRO
	super: Chip NESAPU_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
NESAPU_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.nesAPUClock - 80H)
	ld h,(iy + Header.nesAPUClock - 80H + 1)
	ld e,(iy + Header.nesAPUClock - 80H + 2)
	ld d,(iy + Header.nesAPUClock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
	SECTION RAM

NESAPU_instance: NESAPU

	ENDS

NESAPU_name:
	db "2A03 (NES APU)",0
