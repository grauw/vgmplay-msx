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
	SAMPLES_CAP: equ 1000
	callback:
		dw 0
	time:
		dw 0
	lastJiffy:
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
	call Timer_Initialise
	ret

; ix = this
Timer_Stop:
	ret

; ix = this
Timer_Update:
	call Timer_UpdateTimePassed
	ld e,(ix + Timer.time)
	ld d,(ix + Timer.time + 1)
	ld l,(ix + Timer.callback)
	ld h,(ix + Timer.callback + 1)
	ld (ix + Timer.time),0
	ld (ix + Timer.time + 1),0
	jp hl

; ix = this
Timer_UpdateTimePassed: PROC
	ld b,(ix + Timer.lastJiffy)
Wait:
	ld a,(JIFFY)
	cp b
	jp z,Wait
	ld (ix + Timer.lastJiffy),a
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
	ld de,Timer.SAMPLES_CAP
	sbc hl,de
	ret c
	ld (ix + Timer.time),e
	ld (ix + Timer.time + 1),d
	ret
	ENDP

; Waits for timer interrupt to maximise the time available in the first frame.
; ix = this
Timer_Initialise: PROC
	ld hl,JIFFY
	ld a,(hl)
SyncWait:
	halt
	cp (hl)
	jp z,SyncWait
	ld a,(hl)
	ld (ix + Timer.lastJiffy),a
	ret
	ENDP

; ix = this
Timer_Reset:
	ld a,(JIFFY)
	ld (ix + Timer.lastJiffy),a
	ret
