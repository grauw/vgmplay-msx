;
; Timer factory
;
; Creates the highest-resolution timer suitable for the system.
;

; hl = callback
; de <- timer
; ix <- timer
TimerFactory_CreateTimer:
	push hl
	call TurboRTimer_Detect
	pop hl
	jp c,TimerFactory_CreateTurboRTimer
	jp TimerFactory_CreateVBlankTimer

; hl = callback
; de <- timer
; ix <- timer
TimerFactory_CreateVBlankTimer:
	ld ix,TimerFactory_vBlankTimer
	ld a,(ix + Timer.callback)
	or (ix + Timer.callback + 1)
	call nz,System_ThrowException
	call VBlankTimer_Constructor
	ld e,ixl
	ld d,ixh
	ret

; hl = callback
; de <- timer
; ix <- timer
TimerFactory_CreateTurboRTimer:
	ld ix,TimerFactory_turboRTimer
	ld a,(ix + Timer.callback)
	or (ix + Timer.callback + 1)
	call nz,System_ThrowException
	call TurboRTimer_Constructor
	ld e,ixl
	ld d,ixh
	ret

;
TimerFactory_vBlankTimer: VBlankTimer
TimerFactory_turboRTimer: TurboRTimer
