;
; K052539 Konami SCC+
;
SCCPlus_REGISTER_BASE: equ 9800H
SCCPlus_WAVEFORM: equ 9800H
SCCPlus_FREQUENCY: equ 9880H
SCCPlus_AMPLITUDE: equ 988AH
SCCPlus_MIXER: equ 988FH
SCCPlus_DEFORMATION: equ 98C0H
SCCPlus_BANK_SELECT: equ 9000H
SCCPlus_BANK: equ 3FH
SCCPlus_MODE: equ 0BFFFH
SCCPlus_MODE_SCC: equ 00H
SCCPlus_MODE_SCCPLUS: equ 20H
SCCPlus_FREQUENCY_: equ 1789773

SCCPlus: MACRO
	super: Driver
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
		ld h,SCCPlus_REGISTER_BASE >> 8
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
SCCPlus_Construct:
	call SCCPlus_SetSlot
	ld bc,SCCPlus_name
	ld de,SCCPlus_FREQUENCY_ >> 16
	ld hl,SCCPlus_FREQUENCY_
	call Driver_Construct
	call SCCPlus_SelectBank
	call SCCPlus_Reset
	ret

; ix = this
SCCPlus_Destruct:
	call SCCPlus_Reset
	ret

; ix = this
; a = slot
SCCPlus_SetSlot:
	ld (ix + SCCPlus.slot),a
	call Memory_PrepareSlotPage2
	ld (ix + SCCPlus.preparedSlot),d
	ld (ix + SCCPlus.preparedSubslot),e
	ret

; ix = this
SCCPlus_SelectBank:
	ld hl,SCCPlus_BANK_SELECT
	ld c,SCCPlus_BANK
	ld a,(ix + SCCPlus.slot)
	call Memory_WriteSlot
	ret

; ix = this
; e = register
; d = value
SCCPlus_WriteRegister:
	push ix
	pop hl
	ld bc,SCCPlus.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
SCCPlus_SafeWriteRegister:
	push ix
	pop hl
	ld bc,SCCPlus.SafeWriteRegister
	add hl,bc
	jp hl

; b = count
; e = register base
; d = value
; ix = this
SCCPlus_FillRegisters:
	push bc
	push de
	call SCCPlus_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz SCCPlus_FillRegisters
	ret

; ix = this
SCCPlus_Reset:
	call SCCPlus_Mute
	ld b,0
	ld de,0000H
	call SCCPlus_FillRegisters
	ret

; ix = this
SCCPlus_Mute:
	ld b,6
	ld de,0 << 8 | (SCCPlus_AMPLITUDE & 0FFH)
	call SCCPlus_FillRegisters
	ret

; f <- c: found
; a <- slot
SCCPlus_Detect:
	ld hl,SCCPlus_MatchSlot
	call Memory_SearchSlots
	ret

; a = slot id
; f <- c: found
SCCPlus_MatchSlot: PROC
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
	ld a,SCCPlus_MODE_SCC
	ld (SCCPlus_MODE),a
	ld a,47H
	ld (SCC_WAVEFORM + 3 * 20H),a
	ld a,(SCC_PLUS_WAVEFORM5)
	cp 47H
	jr nz,NoSCC
	ld a,01H
	ld (SCC_WAVEFORM + 3 * 20H),a
	ld a,(SCC_PLUS_WAVEFORM5)
	cp 01H
	jr z,Found
NoSCC:
	ld (hl),e
	ld a,d
	ld (SCC_BANK_SELECT),a
	pop af
	call Memory_SetSlotPage2
	and a
	ret
Found:
	pop af
	call Memory_SetSlotPage2
	scf
	ret
	ENDP

;
SCCPlus_name:
	db "Konami SCC+",0

	SECTION RAM

SCCPlus_instance: SCCPlus

	ENDS
