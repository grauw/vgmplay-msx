;
; Turbo R high res timer
;
; 1000 Hz resolution
;
; There is a slight deviation of +1 second every 5 minutes (+0.35%).
;
TurboRTimer_LSB_PORT: equ 0E6H
TurboRTimer_MSB_PORT: equ 0E7H
TurboRTimer_SAMPLES: equ 44  ; every 256 timer cycles = 44 samples
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
	in a,(TurboRTimer_MSB_PORT)
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
	in a,(TurboRTimer_MSB_PORT)
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
