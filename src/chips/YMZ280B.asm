;
; VGM YMZ280B chip
;
YMZ280B: MACRO
	super: Chip YMZ280B_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
YMZ280B_Construct:
	ld de,Header.ymz280bClock
	call Chip_Construct
	ret

;
	SECTION RAM

YMZ280B_instance: YMZ280B

	ENDS

YMZ280B_name:
	db "YMZ280B (PCMD8)",0
