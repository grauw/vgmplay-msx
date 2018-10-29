;
; VGM K053260 chip
;
K053260: MACRO
	super: Chip K053260_name, System_Return
	ENDM

; ix = this
; iy = header
K053260_Construct:
	ld de,Header.k053260Clock
	jp Chip_Construct

; ix = this
K053260_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

;
	SECTION RAM

K053260_instance: K053260

	ENDS

K053260_name:
	db "K053260",0
