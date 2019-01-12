;
; Sound device
;
Device: MACRO ?name
	name:
		dw ?name
	clock:
		dd 0
	ENDM

; ix = this
Device_Construct: equ System_Return
;	ret

; ix = this
; dehl <- clock (Hz)
; a <- 0: clock is zero
; f <- z: clock is zero
Device_GetClock:
	ld de,Device.clock
	call Utils_GetDoubleWordIXOffset
	res 7,d  ; clear flag bits
	res 6,d
	ret

; ix = this
; dehl <- clock (Hz)
Device_SetClock:
	ld (ix + Device.clock),l
	ld (ix + Device.clock + 1),h
	ld (ix + Device.clock + 2),e
	ld (ix + Device.clock + 3),d
	ret

; ix = this
; f <- nz: set
Device_GetFlagBit6:
	bit 6,(ix + Device.clock + 3)
	ret

; ix = this
; f <- nz: set
Device_GetFlagBit7:
	bit 7,(ix + Device.clock + 3)
	ret

; ix = this
; hl <- name
Device_GetName:
	ld l,(ix + Device.name)
	ld h,(ix + Device.name + 1)
	ret

; hl = name
; ix = this
Device_SetName:
	ld (ix + Device.name),l
	ld (ix + Device.name + 1),h
	ret

; ix = this
Device_PrintInfo:
	call Device_GetName
	call System_Print
	ld hl,Device_infix
	call System_Print
	call Device_GetClock
	call System_PrintDecDEHL
	ld hl,Device_hz
	jp System_Print

;
Device_infix:
	db ": ",0

Device_hz:
	db " Hz",13,10,0
