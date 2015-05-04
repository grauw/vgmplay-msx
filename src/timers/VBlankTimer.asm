;
; VDP VBlank timer
;
; 50 / 60 Hz resolution
;
VBlankTimer: MACRO
	super: Timer VBlankTimer_Start, VBlankTimer_Stop, VBlankTimer_Reset, VBlankTimer_Update
	SAMPLES_60HZ: equ 735
	SAMPLES_50HZ: equ 882
	SAMPLES_CAP: equ 1 << 10  ; 1024
	time:
		dw 0
	lastTimer:
		db 0
	ENDM

; hl = callback
; ix = this
VBlankTimer_Constructor:
	call Timer_Constructor;
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
	ld (ix + VBlankTimer.lastTimer),a
	ld (ix + VBlankTimer.time),0
	ld (ix + VBlankTimer.time + 1),0
	ret

; ix = this
VBlankTimer_Update:
	call VBlankTimer_UpdateTimePassed
	ld a,l
	or h
	ret z
	ex de,hl
	ld (ix + VBlankTimer.time),0
	ld (ix + VBlankTimer.time + 1),0
	jp Timer_Callback

; ix = this
; hl <- time passed
VBlankTimer_UpdateTimePassed: PROC
	ld b,(ix + VBlankTimer.lastTimer)
Wait:
	ld a,(JIFFY)
	cp b
	jp z,Wait
	ld (ix + VBlankTimer.lastTimer),a
	sub b
	ld b,a
	ld l,(ix + VBlankTimer.time)
	ld h,(ix + VBlankTimer.time + 1)
	call VDP_Is60Hz
	ld de,VBlankTimer.SAMPLES_60HZ
	jr z,Loop
	ld de,VBlankTimer.SAMPLES_50HZ
Loop:
	add hl,de
	djnz Loop
	ld (ix + VBlankTimer.time),l
	ld (ix + VBlankTimer.time + 1),h
	ld a,h
	and ~((VBlankTimer.SAMPLES_CAP - 1) >> 8)
	ret z
	ld hl,VBlankTimer.SAMPLES_CAP
	ld (ix + VBlankTimer.time),l
	ld (ix + VBlankTimer.time + 1),h
	ret
	ENDP
