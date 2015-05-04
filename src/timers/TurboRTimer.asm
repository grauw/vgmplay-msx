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
	super: Timer TurboRTimer_Start, TurboRTimer_Stop, TurboRTimer_Reset, TurboRTimer_Update
	time:
		dw 0
	lastTimer:
		db 0
	ENDM

; hl = callback
; ix = this
TurboRTimer_Constructor:
	call Timer_Constructor;
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
	ld (ix + TurboRTimer.time),0
	ld (ix + TurboRTimer.time + 1),0
	ret

; ix = this
TurboRTimer_Update:
	call TurboRTimer_UpdateTimePassed
	ld a,l
	or h
	ret z
	ex de,hl
	ld (ix + TurboRTimer.time),0
	ld (ix + TurboRTimer.time + 1),0
	jp Timer_Callback

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
	ld l,(ix + TurboRTimer.time)
	ld h,(ix + TurboRTimer.time + 1)
	ld de,TurboRTimer_SAMPLES
Loop:
	add hl,de
	djnz Loop
	ld (ix + TurboRTimer.time),l
	ld (ix + TurboRTimer.time + 1),h
	ld a,h
	and ~((TurboRTimer_SAMPLES_CAP - 1) >> 8)
	ret z
	ld hl,TurboRTimer_SAMPLES_CAP
	ld (ix + TurboRTimer.time),l
	ld (ix + TurboRTimer.time + 1),h
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
