;
; Timer base class
;
; There can be two types of timers, interrupt-driven ones and polling ones.
; Interrupt-driven timers run by themselves; polling timers rely on Update calls
; from the main loop.
;
; Time is in units of 44100 Hz samples
;
	INCLUDE "VBlankTimer.asm"

Timer: MACRO ?start, ?stop, ?reset, ?update
	start:
		dw ?start
	stop:
		dw ?stop
	reset:
		dw ?reset
	update:
		dw ?update
	callback:
		dw 0
	ENDM

; hl = callback
; ix = this
Timer_Constructor:
	ld (ix + Timer.callback),l
	ld (ix + Timer.callback + 1),h
	ret

; ix = this
Timer_Start:
	ld l,(ix + Timer.start)
	ld h,(ix + Timer.start + 1)
	jp hl

; ix = this
Timer_Stop:
	ld l,(ix + Timer.stop)
	ld h,(ix + Timer.stop + 1)
	jp hl

; ix = this
Timer_Reset:
	ld l,(ix + Timer.reset)
	ld h,(ix + Timer.reset + 1)
	jp hl

; ix = this
Timer_Update:
	ld l,(ix + Timer.update)
	ld h,(ix + Timer.update + 1)
	jp hl

; ix = this
Timer_Callback:
	ld l,(ix + Timer.callback)
	ld h,(ix + Timer.callback + 1)
	jp hl
