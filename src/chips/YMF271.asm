;
; VGM YMF271 chip
;
YMF271: MACRO
	super: Chip YMF271_name, System_Return
	ENDM

; ix = this
; iy = header
YMF271_Construct:
	ld de,Header.ymf271Clock
	jp Chip_Construct

; ix = this
YMF271_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

;
	SECTION RAM

YMF271_instance: YMF271

	ENDS

YMF271_name:
	db "YMF271 (OPX)",0
