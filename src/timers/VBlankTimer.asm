;
; VDP VBlank timer
;
; 50 / 60 Hz resolution
;
VBlankTimer_SAMPLES_60HZ: equ 735
VBlankTimer_SAMPLES_50HZ: equ 882
VBlankTimer_SAMPLES_CAP: equ 1 << 10  ; 1024

VBlankTimer: MACRO
	super: Timer VBlankTimer_Start, VBlankTimer_Stop, VBlankTimer_Reset, Update
	lastJiffy:
		db 0

	; ix = this
	Update:
		call VBlankTimer_UpdateTimePassed
		ex de,hl
		jr super.Callback
	ENDM

; hl = callback
; ix = this
VBlankTimer_Construct:
	call Timer_Construct
	ret

; ix = this
VBlankTimer_Start:
	call VBlankTimer_Reset
	ret

; ix = this
VBlankTimer_Stop:
	ret

; ix = this
VBlankTimer_Reset:
	ld a,(JIFFY)
	ld (ix + VBlankTimer.lastJiffy),a
	ret

; ix = this
; hl <- time passed
VBlankTimer_UpdateTimePassed: PROC
	ld b,(ix + VBlankTimer.lastJiffy)
Wait:
	ld a,(JIFFY)
	cp b
	jp z,Wait
	ld (ix + VBlankTimer.lastJiffy),a
	sub b
	ld b,a
	ld hl,0
	call VDP_Is60Hz
	ld de,VBlankTimer_SAMPLES_60HZ
	jr z,Loop
	ld de,VBlankTimer_SAMPLES_50HZ
Loop:
	add hl,de
	djnz Loop
	ld a,h
	and ~((VBlankTimer_SAMPLES_CAP - 1) >> 8)
	ret z
	ld hl,VBlankTimer_SAMPLES_CAP
	ret
	ENDP
