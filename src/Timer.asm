;
; Timer base class
;
; There can be two types of timers, interrupt-driven ones and polling ones.
; Interrupt-driven timers run by themselves; polling timers rely on Update calls
; from the main loop.
;
; Time is in units of 44100 Hz samples
;
Timer: MACRO
	SAMPLES_60HZ: equ 735
	SAMPLES_50HZ: equ 882
	SAMPLES_CAP: equ 1 << 10  ; 1024
	callback:
		dw 0
	time:
		dw 0
	lastTimer:
		db 0
	ENDM

; hl = callback
; ix = this
Timer_Constructor:
	ld (ix + Timer.callback),l
	ld (ix + Timer.callback + 1),h
	ret

; ix = this
Timer_Start:
	call Timer_Reset
	ret

; ix = this
Timer_Stop:
	ret

; ix = this
Timer_Reset:
	ld a,(JIFFY)
	ld (ix + Timer.lastTimer),a
	ld (ix + Timer.time),0
	ld (ix + Timer.time + 1),0
	ret

; ix = this
Timer_Update:
	call Timer_UpdateTimePassed
	ld a,l
	or h
	ret z
	ex de,hl
	ld (ix + Timer.time),0
	ld (ix + Timer.time + 1),0
	ld l,(ix + Timer.callback)
	ld h,(ix + Timer.callback + 1)
	jp hl

; ix = this
; hl <- time passed
Timer_UpdateTimePassed: PROC
	ld b,(ix + Timer.lastTimer)
Wait:
	ld a,(JIFFY)
	cp b
	jp z,Wait
	ld (ix + Timer.lastTimer),a
	sub b
	ld b,a
	ld l,(ix + Timer.time)
	ld h,(ix + Timer.time + 1)
	call VDP_Is60Hz
	ld de,Timer.SAMPLES_60HZ
	jr z,Loop
	ld de,Timer.SAMPLES_50HZ
Loop:
	add hl,de
	djnz Loop
	ld (ix + Timer.time),l
	ld (ix + Timer.time + 1),h
	ld a,h
	and ~((Timer.SAMPLES_CAP - 1) >> 8)
	ret z
	ld hl,Timer.SAMPLES_CAP
	ld (ix + Timer.time),l
	ld (ix + Timer.time + 1),h
	ret
	ENDP
