;
; K051649 Konami SCC
;
SCC_REGISTER_BASE: equ 9800H
SCC_WAVEFORM: equ 9800H
SCC_FREQUENCY: equ 9880H
SCC_AMPLITUDE: equ 988AH
SCC_MIXER: equ 988FH
SCC_PLUS_WAVEFORM5: equ 98A0H
SCC_DEFORMATION: equ 98E0H
SCC_BANK_SELECT: equ 9000H
SCC_BANK: equ 3FH
SCC_BANK_DEFAULT: equ 02H
SCC_FREQUENCY_: equ 1789773

SCC: MACRO
	super: Driver Driver_PrintInfoImpl
	slot:
		db 0

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
	; a = register
	; d = value
	WriteRegister:
		ld c,0A8H
		ld hl,0FFFFH
		di
		in b,(c)
		ld e,0
	preparedSlot: equ $ - 1
		out (c),e
		ld e,(hl)
		ld (hl),0
	preparedSubslot: equ $ - 1
		ld h,SCC_REGISTER_BASE >> 8
		ld l,a
		ld (hl),d
		ld a,e
		cpl
		ld (0FFFFH),a
		ei
		out (c),b
		ret

	; e = channel * 20H + offset
	; d = value
	WriteWaveform:
		ld a,e
		jp WriteRegister

	; e = channel * 2 + offset
	; d = value
	WriteFrequency:
		ld a,SCC_FREQUENCY
		add a,e
		jp WriteRegister

	; e = channel
	; d = value
	WriteAmplitude:
		ld a,SCC_AMPLITUDE
		add a,e
		jp WriteRegister

	; d = value
	WriteMixer:
		ld a,SCC_MIXER
		jp WriteRegister

	; d = value
	WriteDeformation:
		ld a,SCC_DEFORMATION
		jp WriteRegister
	ENDM

; a = slot
; ix = this
SCC_Construct:
	call SCC_SetSlot
	ld bc,SCC_name
	ld de,SCC_FREQUENCY_ >> 16
	ld hl,SCC_FREQUENCY_
	call Driver_Construct
	call SCC_Select
	call SCC_Reset
	ret

; ix = this
SCC_Destruct:
	call SCC_Reset
	call SCC_Deselect
	ret

; a = slot
; ix = this
SCC_SetSlot:
	ld (ix + SCC.slot),a
	call Memory_PrepareSlotPage2
	ld (ix + SCC.preparedSlot),d
	ld (ix + SCC.preparedSubslot),e
	ret

; ix = this
SCC_Select:
	ld hl,SCC_BANK_SELECT
	ld c,SCC_BANK
	ld a,(ix + SCC.slot)
	call Memory_WriteSlot
	ret

; ix = this
SCC_Deselect:
	ld hl,SCC_BANK_SELECT
	ld c,SCC_BANK_DEFAULT
	ld a,(ix + SCC.slot)
	call Memory_WriteSlot
	ret

; e = register
; d = value
; ix = this
SCC_WriteRegister:
	ld a,e
	ld bc,SCC.WriteRegister
	jp Utils_JumpIXOffsetBC

; b = count
; e = register base
; d = value
; ix = this
SCC_FillRegisters:
	push bc
	push de
	call SCC_WriteRegister
	pop de
	pop bc
	inc e
	djnz SCC_FillRegisters
	ret

; ix = this
SCC_Reset:
	call SCC_Mute
	ld b,0
	ld de,0000H
	call SCC_FillRegisters
	ret

; ix = this
SCC_Mute:
	ld b,6
	ld de,0 << 8 | (SCC_AMPLITUDE & 0FFH)
	call SCC_FillRegisters
	ret

; f <- c: found
; a <- slot
SCC_Detect:
	ld hl,SCC_MatchSlot
	call Memory_SearchSlots
	ret

; a = slot id
; f <- c: found
SCC_MatchSlot: PROC
	ex af,af'
	call Memory_GetSlotPage2
	push af
	ex af,af'
	call Memory_SetSlotPage2
	ld a,(SCC_BANK_SELECT)
	ld d,a
	ld a,SCC_BANK
	ld (SCC_BANK_SELECT),a
	ld hl,SCC_REGISTER_BASE
	ld e,(hl)
	xor a
	ld (hl),a
	ld a,(hl)
	or a
	jr nz,NoSCC
	dec a
	ld (hl),a
	ld a,(hl)
	inc a
	jr nz,NoSCC
	ld a,(SCC_BANK_SELECT)
	cp SCC_BANK
	jr z,NoSCC
CheckSCCPlus:
	ld a,00H
	ld (SCC_WAVEFORM + 3 * 20H),a
	ld a,(SCC_PLUS_WAVEFORM5)
	cp 00H
	jr nz,Found
NoSCC:
	ld (hl),e
	ld a,d
	ld (SCC_BANK_SELECT),a
	pop af
	call Memory_SetSlotPage2
	and a
	ret
Found:
	ld a,SCC_BANK_DEFAULT
	ld (SCC_BANK_SELECT),a
	pop af
	call Memory_SetSlotPage2
	scf
	ret
	ENDP

;
SCC_name:
	db "Konami SCC",0

	SECTION RAM

SCC_instance: SCC

	ENDS
