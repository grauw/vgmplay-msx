;
; VGM QSound chip
;
QSound: MACRO
	super: Chip QSound_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
QSound_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.qSoundClock - 80H)
	ld h,(iy + Header.qSoundClock - 80H + 1)
	ld e,(iy + Header.qSoundClock - 80H + 2)
	ld d,(iy + Header.qSoundClock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
	SECTION RAM

QSound_instance: QSound

	ENDS

QSound_name:
	db "QSound",0
