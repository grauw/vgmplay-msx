;
; Timer factory
;
; Creates the highest-resolution timer suitable for the system.
;

; hl = callback
; ix <- timer
; f <- c: succeeded
TimerFactory_CreateTimer:
	call TimerFactory_CreateTurboRTimer
	call nc,TimerFactory_CreateLineTimer
	call nc,TimerFactory_CreateVBlankTimer
	ret

; hl = callback
; ix <- timer
; f <- c: succeeded
TimerFactory_CreateVBlankTimer:
	ld ix,TimerFactory_vBlankTimer
	ld a,(ix + Timer.callback)
	or (ix + Timer.callback + 1)
	call nz,System_ThrowException
	call VBlankTimer_Construct
	scf
	ret

; hl = callback
; ix <- timer
; f <- c: succeeded
TimerFactory_CreateLineTimer:
	push hl
	call LineTimer_Detect
	pop hl
	ret nc
	call LineTimer_class.New
	call LineTimer_Construct
	scf
	ret

; hl = callback
; ix <- timer
; f <- c: succeeded
TimerFactory_CreateTurboRTimer:
	push hl
	call TurboRTimer_Detect
	pop hl
	ret nc
	ld ix,TimerFactory_turboRTimer
	ld a,(ix + Timer.callback)
	or (ix + Timer.callback + 1)
	call nz,System_ThrowException
	call TurboRTimer_Construct
	scf
	ret

;
TimerFactory_vBlankTimer: VBlankTimer
TimerFactory_turboRTimer: TurboRTimer
