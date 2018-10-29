;
; VGM SegaPCM chip
;
SegaPCM: MACRO
	super: Chip SegaPCM_name, System_Return
	ENDM

; ix = this
; iy = header
SegaPCM_Construct:
	ld de,Header.segaPCMClock
	jp Chip_Construct

; ix = this
SegaPCM_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

;
	SECTION RAM

SegaPCM_instance: SegaPCM

	ENDS

SegaPCM_name:
	db "Sega PCM",0
