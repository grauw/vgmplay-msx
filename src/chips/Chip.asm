;
; VGM chip
;
Chip: MACRO ?name
	clock:
		dd 0
	name:
		dw ?name
	ENDM

; dehl = clock
; ix = this
Chip_Construct:
	ld (ix + Chip.clock),l
	ld (ix + Chip.clock + 1),h
	ld (ix + Chip.clock + 2),e
	ld (ix + Chip.clock + 3),d
	ret

; ix = this
; f <- z: not active
; Modifies: a
Chip_IsActive:
	ld a,(ix + Chip.clock)
	or (ix + Chip.clock + 1)
	or (ix + Chip.clock + 2)
	or (ix + Chip.clock + 3)
	ret

; ix = this
; dehl <- clock (MHz)
Chip_GetClock:
	ld l,(ix + Chip.clock)
	ld h,(ix + Chip.clock + 1)
	ld e,(ix + Chip.clock + 2)
	ld d,(ix + Chip.clock + 3)
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
	ret
	ENDP

;
Chip_clockLabelInfix:
	db ": ",0

Chip_clockDualLabelInfix:
	db " x2: ",0

Chip_hz:
	db " Hz",13,10,0
