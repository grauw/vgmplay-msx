;
; Sound module driver
;
Driver: MACRO ?name, ?printInfo
	name:
		dw ?name
	clock:
		dd 0
	printInfo:
		dw ?printInfo
	ENDM

; ix = this
Driver_Construct:
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
; dehl <- clock (MHz)
Driver_SetClock:
	ld (ix + Driver.clock),l
	ld (ix + Driver.clock + 1),h
	ld (ix + Driver.clock + 2),e
	ld (ix + Driver.clock + 3),d
	ret

; ix = this
; f <- c: found
Driver_IsFound:
	ld a,(ix + Driver.clock)
	or (ix + Driver.clock + 1)
	or (ix + Driver.clock + 2)
	or (ix + Driver.clock + 3)
	neg
	ret

; ix = this
; hl <- name
Driver_GetName:
	ld l,(ix + Driver.name)
	ld h,(ix + Driver.name + 1)
	ret

; bc = name
; ix = this
Driver_SetName:
	ld (ix + Driver.name),c
	ld (ix + Driver.name + 1),b
	ret

; ix = this
Driver_PrintInfo:
	ld l,(ix + Driver.printInfo)
	ld h,(ix + Driver.printInfo + 1)
	jp hl

; ix = this
Driver_PrintInfoImpl:
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
