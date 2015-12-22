;
; VGM PWM chip
;
PWM: MACRO
	super: Chip PWM_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
PWM_Construct:
	ld l,(iy + Header.pwmClock)
	ld h,(iy + Header.pwmClock + 1)
	ld e,(iy + Header.pwmClock + 2)
	ld d,(iy + Header.pwmClock + 3)
	call Chip_Construct
	ret

;
PWM_instance: PWM

PWM_name:
	db "PWM",0
