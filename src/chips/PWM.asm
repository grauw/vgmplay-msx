;
; VGM PWM chip
;
PWM: MACRO
	super: Chip PWM_name, System_Return
	ENDM

; ix = this
; iy = header
PWM_Construct:
	ld de,Header.pwmClock
	jp Chip_Construct

; ix = this
PWM_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

;
	SECTION RAM

PWM_instance: PWM

	ENDS

PWM_name:
	db "PWM",0
