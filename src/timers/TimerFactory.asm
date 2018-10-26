;
; Timer factory
;
; Creates the highest-resolution timer suitable for the system.
;

; hl = callback
; ix <- timer
TimerFactory_CreateTimer:
	push hl
	call TurboRTimer_Detect
	pop hl
	jp c,TimerFactory_CreateTurboRTimer
	push hl
	call LineTimer_Detect
	pop hl
	jp c,TimerFactory_CreateLineTimer
	jp TimerFactory_CreateVBlankTimer

; hl = callback
; ix <- timer
TimerFactory_CreateVBlankTimer:
	ld ix,TimerFactory_vBlankTimer
	ld a,(ix + Timer.callback)
	or (ix + Timer.callback + 1)
	call nz,System_ThrowException
	call VBlankTimer_Construct
	ret

; hl = callback
; ix <- timer
TimerFactory_CreateLineTimer:
	call LineTimer_class.New
	call LineTimer_Construct
	ret

; hl = callback
; ix <- timer
TimerFactory_CreateTurboRTimer:
	ld ix,TimerFactory_turboRTimer
	ld a,(ix + Timer.callback)
	or (ix + Timer.callback + 1)
	call nz,System_ThrowException
	call TurboRTimer_Construct
	ret

;
TimerFactory_vBlankTimer: VBlankTimer
TimerFactory_turboRTimer: TurboRTimer
