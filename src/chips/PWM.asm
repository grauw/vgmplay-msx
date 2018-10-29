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

;
	SECTION RAM

PWM_instance: PWM

	ENDS

PWM_name:
	db "PWM",0
