;
; Sound module driver
;
Driver: MACRO
	name:
		dw 0
	clock:
		dd 0
	ENDM

; bc = name
; dehl = clock
; ix = this
Driver_Construct:
	ld (ix + Driver.name),c
	ld (ix + Driver.name + 1),b
	ld (ix + Driver.clock),l
	ld (ix + Driver.clock + 1),h
	ld (ix + Driver.clock + 2),e
	ld (ix + Driver.clock + 3),d
	ret

; ix = this
; dehl <- clock (MHz)
Driver_GetClock:
	ld l,(ix + Driver.clock)
	ld h,(ix + Driver.clock + 1)
	ld e,(ix + Driver.clock + 2)
	ld d,(ix + Driver.clock + 3)
	ret

; ix = this
; hl <- name
Driver_GetName:
	ld l,(ix + Driver.name)
	ld h,(ix + Driver.name + 1)
	ret

; ix = this
Driver_PrintInfo:
	ld hl,Driver_prefix
	call System_Print
	call Driver_GetName
	call System_Print
	ld hl,Driver_infix
	call System_Print
	call Driver_GetClock
	call System_PrintDecDEHL
	ld hl,Driver_hz
	call System_Print
	ret

;
Driver_prefix:
	db "-> ",0

Driver_infix:
	db ": ",0

Driver_hz:
	db " Hz",13,10,0
