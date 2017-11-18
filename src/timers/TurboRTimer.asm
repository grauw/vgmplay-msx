;
; Turbo R high res timer
;
; 4000 Hz resolution
;
; There is a slight deviation of +1 second every 5 minutes (+0.35%).
;
TurboRTimer_SAMPLES: equ 11  ; every 64 timer cycles = 11 samples

TurboRTimer: MACRO
	super: Timer TurboRTimer_Start, TurboRTimer_Stop, TurboRTimer_Reset, Update
	lastTimer:
		db 0

	; ix = this
	Update: PROC
		ld b,(ix + TurboRTimer.lastTimer)
	Wait:
		call TurboRTimer_GetTimerValue
		cp b
		jr z,Wait
		ld (ix + TurboRTimer.lastTimer),a
		sub b
		ld b,a
		ld hl,0
		ld de,TurboRTimer_SAMPLES
	Loop:
		add hl,de
		djnz Loop
		ex de,hl
		jr super.Callback
		ENDP
	ENDM

; hl = callback
; ix = this
TurboRTimer_Construct:
	call Timer_Construct
	ret

; ix = this
TurboRTimer_Start:
	call TurboRTimer_Reset
	ret

; ix = this
TurboRTimer_Stop:
	ret

; ix = this
TurboRTimer_Reset:
	call TurboRTimer_GetTimerValue
	ld (ix + TurboRTimer.lastTimer),a
	ret

; ix = this
; a <- 3995 Hz timer value
TurboRTimer_GetTimerValue:
	call System_GetHighResTimerValue
	ld a,h
	rl l
	rla
	rl l
	rla
	ret

; f <- c: found
TurboRTimer_Detect:
	call System_IsTurboR
	ccf
	ret
