;
; K051649 Konami SCC
;
SCC_REGISTER_BASE: equ 9800H
SCC_WAVEFORM: equ 00H
SCC_FREQUENCY: equ 80H
SCC_AMPLITUDE: equ 8AH
SCC_MIXER: equ 8FH
SCC_DEFORMATION: equ 0E0H
SCC_BANK_SELECT: equ 9000H
SCC_BANK: equ 3FH

SCC: MACRO
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
	ENDM

; a = slot
; ix = this
SCC_Construct:
	call SCC_SetSlot
	call SCC_SelectBank
	call SCC_Reset
	ret

; ix = this
SCC_Destruct:
	call SCC_Reset
	ret

; ix = this
; a = slot
SCC_SetSlot:
	ld (ix + SCC.slot),a
	call Memory_PrepareSlotPage2
	ld (ix + SCC.preparedSlot),d
	ld (ix + SCC.preparedSubslot),e
	ret

; ix = this
SCC_SelectBank:
	ld hl,SCC_BANK_SELECT
	ld c,SCC_BANK
	ld a,(ix + SCC.slot)
	call Memory_WriteSlot
	ret

; ix = this
; e = register
; d = value
SCC_WriteRegister:
	push ix
	pop hl
	ld bc,SCC.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
SCC_SafeWriteRegister:
	push ix
	pop hl
	ld bc,SCC.SafeWriteRegister
	add hl,bc
	jp hl

; b = count
; e = register base
; d = value
; ix = this
SCC_FillRegisters:
	push bc
	push de
	call SCC_SafeWriteRegister
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
	ld h,80H
	call Memory_SetSlot
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
	xor a
	jr Found
NoSCC:
	ld (hl),e
	ld a,d
	ld (SCC_BANK_SELECT),a
	pop af
	ld h,80H
	call Memory_SetSlot
	and a
	ret
Found:
	pop af
	ld h,80H
	call Memory_SetSlot
	scf
	ret
	ENDP

;
	SECTION RAM

SCC_instance: SCC

	ENDS
