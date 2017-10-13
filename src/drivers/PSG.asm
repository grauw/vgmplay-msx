;
; AY-3-8910 PSG / YM2149 SSG driver
;
PSG_ADDRESS: equ 0A0H
PSG_DATA: equ 0A1H
PSG_FREQUENCY: equ 1789773

PSG: MACRO ?address, ?data
	super: Driver

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp 14
		ret nc
		cp 7
		jr z,MaskMixer
	; a = register
	; d = value
	WriteRegister:
		di
		out (?address),a
		ld a,d
		ei
		out (?data),a
		ret
	MaskMixer:
		ld a,d
		and 3FH
		or 80H
		ld d,a
		ld a,e
		jr WriteRegister
	ENDM

; ix = this
PSG_Construct:
	ld bc,PSG_name
	ld de,PSG_FREQUENCY >> 16
	ld hl,PSG_FREQUENCY
	call Driver_Construct
	call PSG_Reset
	ret

; ix = this
PSG_Destruct:
	call PSG_Reset
	ret

; e = register
; d = value
; ix = this
PSG_WriteRegister:
	ld a,e
	ld bc,PSG.WriteRegister
	jp Utils_JumpIXOffsetBC

; e = register
; d = value
; ix = this
PSG_SafeWriteRegister:
	ld bc,PSG.SafeWriteRegister
	jp Utils_JumpIXOffsetBC

; ix = this
PSG_Reset: PROC
	ld de,0008H
	call PSG_WriteRegister
	ld de,0009H
	call PSG_WriteRegister
	ld de,000AH
	call PSG_WriteRegister
	ld b,14
	ld de,0000H
Loop:
	push bc
	push de
	call PSG_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz Loop
	ret
	ENDP

; f <- c: found
PSG_Detect:
	scf
	ret

;
PSG_name:
	db "Internal PSG",0

	SECTION RAM

PSG_instance: PSG PSG_ADDRESS, PSG_DATA

	ENDS
