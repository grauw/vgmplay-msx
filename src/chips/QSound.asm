;
; VGM QSound chip
;
QSound: MACRO
	super: Chip QSound_name, System_Return
	ENDM

; ix = this
; iy = header
QSound_Construct:
	ld de,Header.qSoundClock
	jp Chip_Construct

;
	SECTION RAM

QSound_instance: QSound

	ENDS

QSound_name:
	db "QSound",0
