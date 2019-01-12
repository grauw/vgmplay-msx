;
; VGM chip
;
Chip: MACRO ?name, ?headerClockOffset, ?connecter
	clock:
		dd 0
	name:
		dw ?name
	driver:
		dw 0
	driver2:
		dw 0
	headerClockOffset:
		dw ?headerClockOffset
	connecter:
		dw ?connecter
	ENDM

; de = header clock offset
; ix = this
; iy = header
Chip_Construct:
	ld e,(ix + Chip.headerClockOffset)
	ld d,(ix + Chip.headerClockOffset + 1)
	call Utils_GetDoubleWordIYOffset
	ld (ix + Chip.clock),l
	ld (ix + Chip.clock + 1),h
	ld (ix + Chip.clock + 2),e
	ld (ix + Chip.clock + 3),d
	ret

; ix = this
Chip_Destruct: equ System_Return
;	ret

; ix = this
; f <- z: not active
; Modifies: af, de, hl
Chip_IsActive: equ Chip_GetClock

; ix = this
; dehl <- clock (MHz)
; f <- z: not active
Chip_GetClock:
	ld de,Chip.clock
	call Utils_GetDoubleWordIXOffset
	res 7,d  ; clear flag bits
	res 6,d
	ret

; ix = this
; f <- nz: dual chip
Chip_IsDualChip:
	bit 6,(ix + Chip.clock + 3)
	ret

; ix = this
; hl <- name
Chip_GetName:
	ld l,(ix + Chip.name)
	ld h,(ix + Chip.name + 1)
	ret

; hl = name
; ix = this
Chip_SetName:
	ld (ix + Chip.name),l
	ld (ix + Chip.name + 1),h
	ret

; de = driver
; ix = this
Chip_SetDriver:
	ld (ix + Chip.driver),e
	ld (ix + Chip.driver + 1),d
	ret

; de = driver
; ix = this
Chip_SetDriver2:
	ld (ix + Chip.driver2),e
	ld (ix + Chip.driver2 + 1),d
	ret

; iy = drivers
; ix = this
Chip_Connect:
	ld l,(ix + Chip.connecter)
	ld h,(ix + Chip.connecter + 1)
	jp hl

; ix = this
Chip_PrintInfo: PROC
	call Chip_GetName
	call System_Print
	call Chip_IsDualChip
	ld hl,Chip_clockLabelInfix
	jr z,Single
	ld hl,Chip_clockDualLabelInfix
Single:
	call System_Print
	call Chip_GetClock
	call System_PrintDecDEHL
	ld hl,Chip_hz
	call System_Print
	ld e,(ix + Chip.driver)
	ld d,(ix + Chip.driver + 1)
	ld a,e
	or d
	ret z
	push ix
	ld ixl,e
	ld ixh,d
	call Driver_PrintInfo
	pop ix
	ld e,(ix + Chip.driver2)
	ld d,(ix + Chip.driver2 + 1)
	ld a,e
	or d
	ret z
	push ix
	ld ixl,e
	ld ixh,d
	call Driver_PrintInfo
	pop ix
	ret
	ENDP

;
Chip_clockLabelInfix:
	db ": ",0

Chip_clockDualLabelInfix:
	db " x2: ",0

Chip_hz:
	db " Hz",13,10,0
