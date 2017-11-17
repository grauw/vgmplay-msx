;
; Turbo R high res timer
;
; 4000 Hz resolution
;
; There is a slight deviation of +1 second every 5 minutes (+0.35%).
;
TurboRTimer_SAMPLES: equ 11  ; every 64 timer cycles = 11 samples
TurboRTimer_SAMPLES_CAP: equ 1 << 10  ; 1024

TurboRTimer: MACRO
	super: Timer TurboRTimer_Start, TurboRTimer_Stop, TurboRTimer_Reset, Update
	lastTimer:
		db 0

	; ix = this
	Update:
		call TurboRTimer_UpdateTimePassed
		ld a,l
		or h
		ret z
		ex de,hl
		jr super.Callback
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
; hl <- time passed
TurboRTimer_UpdateTimePassed: PROC
	ld b,(ix + TurboRTimer.lastTimer)
Wait:
	call TurboRTimer_GetTimerValue
	cp b
	jp z,Wait
	ld (ix + TurboRTimer.lastTimer),a
	sub b
	ld b,a
	ld hl,0
	ld de,TurboRTimer_SAMPLES
Loop:
	add hl,de
	djnz Loop
	ld a,h
	and ~((TurboRTimer_SAMPLES_CAP - 1) >> 8)
	ret z
	ld hl,TurboRTimer_SAMPLES_CAP
	ret
	ENDP

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
