;
; VGM NESAPU chip
;
NESAPU: MACRO
	super: Chip NESAPU_name
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
NESAPU_instance: NESAPU

NESAPU_name:
	db "2A03 (NES APU)",0
