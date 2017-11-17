;
; VDP line interrupt timer
;
; 300 Hz resolution
;
LineTimer_SAMPLES: equ 147
LineTimer_SAMPLES_CAP: equ 1 << 10  ; 1024
LineTimer_LINESTEP_60HZ: equ 52
LineTimer_LINESTEP_50HZ: equ 51
LineTimer_IE1: equ 00010000B

LineTimer: MACRO
	super: Timer LineTimer_Start, LineTimer_Stop, LineTimer_Reset, Update
	time:
		dw 0
	liffy: equ LineInterruptHandler.liffy
	lastLiffy:
		db 0

	; ix = this
	Update:
		call LineTimer_UpdateTimePassed
		ld a,l
		or h
		ret z
		ex de,hl
		ld (ix + LineTimer.time),0
		ld (ix + LineTimer.time + 1),0
		jr super.Callback

	InterruptHandler: PROC
		push af
		ld a,1
		out (VDP_PORT_1),a
		ld a,15 | VDP_REGISTER
		out (VDP_PORT_1),a
		in a,(VDP_PORT_1)
		rrca
		jr c,LineInterruptHandler
		xor a
		out (VDP_PORT_1),a
		ld a,15 | VDP_REGISTER
		out (VDP_PORT_1),a
		pop af
	oldHook:
		ds Interrupt_HOOK_SIZE,0C9H
		ENDP

	LineInterruptHandler: PROC
		ld a,0
	liffy: equ $ - 1
		inc a
		ld (liffy),a
	liffyReference: equ $ - 2
		ld a,0
	line: equ $ - 1
		add a,0
	lineStep: equ $ - 1
		jr nc,NoReset
		xor a
	NoReset:
		ld (line),a
	lineReference: equ $ - 2
		out (VDP_PORT_1),a
		ld a,19 | VDP_REGISTER
		out (VDP_PORT_1),a
		xor a
		out (VDP_PORT_1),a
		ld a,15 | VDP_REGISTER
		out (VDP_PORT_1),a
		pop af
		ei
		ret
		ENDP
	_size:
	ENDM

LineTimer_class: Class LineTimer, LineTimer_template, Heap_main
LineTimer_template: LineTimer

; hl = callback
; ix = this
LineTimer_Construct:
	call Timer_Construct
	ld e,ixl
	ld d,ixh
	ld hl,LineTimer.LineInterruptHandler.liffy
	add hl,de
	ld (ix + LineTimer.LineInterruptHandler.liffyReference),l
	ld (ix + LineTimer.LineInterruptHandler.liffyReference + 1),h
	ld hl,LineTimer.LineInterruptHandler.line
	add hl,de
	ld (ix + LineTimer.LineInterruptHandler.lineReference),l
	ld (ix + LineTimer.LineInterruptHandler.lineReference + 1),h
	ret

; ix = this
LineTimer_Start: PROC
	call LineTimer_Reset
	ld a,0
	ld (ix + LineTimer.LineInterruptHandler.line),a
	ld b,19
	call VDP_SetRegister
	call VDP_Is60Hz
	ld (ix + LineTimer.LineInterruptHandler.lineStep),LineTimer_LINESTEP_60HZ
	jr z,Is60Hz
	ld (ix + LineTimer.LineInterruptHandler.lineStep),LineTimer_LINESTEP_50HZ
Is60Hz:
	call LineTimer_InstallInterruptHandler
	ld a,(VDP_MIRROR_0)
	or LineTimer_IE1
	ld (VDP_MIRROR_0),a
	ld b,0
	call VDP_SetRegister
	ret
	ENDP

; ix = this
LineTimer_Stop:
	ld a,(VDP_MIRROR_0)
	and ~LineTimer_IE1
	ld (VDP_MIRROR_0),a
	ld b,0
	call VDP_SetRegister
	call LineTimer_UninstallInterruptHandler
	ret

; ix = this
LineTimer_InstallInterruptHandler:
	push ix
	ld ix,Interrupt_instance
	call Interrupt_Construct
	pop ix
	ld c,ixl
	ld b,ixh
	ld hl,LineTimer.InterruptHandler.oldHook
	add hl,bc
	ex de,hl
	ld hl,LineTimer.InterruptHandler
	add hl,bc
	push ix
	ld ix,Interrupt_instance
	call Interrupt_Hook
	pop ix
	ret

; ix = this
LineTimer_UninstallInterruptHandler:
	push ix
	ld ix,Interrupt_instance
	call Interrupt_Destruct
	pop ix
	ret

; ix = this
LineTimer_Reset:
	ld a,(ix + LineTimer.liffy)
	ld (ix + LineTimer.lastLiffy),a
	ld (ix + LineTimer.time),0
	ld (ix + LineTimer.time + 1),0
	ret

; ix = this
; hl <- time passed
LineTimer_UpdateTimePassed: PROC
	ld b,(ix + LineTimer.lastLiffy)
Wait:
	ld a,(ix + LineTimer.liffy)
	cp b
	jp z,Wait
	ld (ix + LineTimer.lastLiffy),a
	sub b
	ld b,a
	ld l,(ix + LineTimer.time)
	ld h,(ix + LineTimer.time + 1)
	ld de,LineTimer_SAMPLES
Loop:
	add hl,de
	djnz Loop
	ld (ix + LineTimer.time),l
	ld (ix + LineTimer.time + 1),h
	ld a,h
	and ~((LineTimer_SAMPLES_CAP - 1) >> 8)
	ret z
	ld hl,LineTimer_SAMPLES_CAP
	ld (ix + LineTimer.time),l
	ld (ix + LineTimer.time + 1),h
	ret
	ENDP

; f <- c: found
LineTimer_Detect:
	call VDP_IsTMS9918A
	scf
	ret nz
	ccf
	ret
