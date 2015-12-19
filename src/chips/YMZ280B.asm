;
; VGM YMZ280B chip
;
YMZ280B: MACRO
	super: Chip YMZ280B_name
	ENDM

; ix = this
; iy = header
YMZ280B_Construct:
	ld l,(iy + Header.ymz280bClock)
	ld h,(iy + Header.ymz280bClock + 1)
	ld e,(iy + Header.ymz280bClock + 2)
	ld d,(iy + Header.ymz280bClock + 3)
	call Chip_Construct
	ret

;
YMZ280B_instance: YMZ280B

YMZ280B_name:
	db "YMZ280B (PCMD8)",0
