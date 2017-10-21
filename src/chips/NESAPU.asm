;
; VGM NESAPU chip
;
NESAPU: MACRO
	super: Chip NESAPU_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
NESAPU_Construct:
	ld de,Header.nesAPUClock
	call Chip_Construct
	ret

;
	SECTION RAM

NESAPU_instance: NESAPU

	ENDS

NESAPU_name:
	db "2A03 (NES APU)",0
