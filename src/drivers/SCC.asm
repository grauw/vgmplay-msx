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

	; ix = player
	ProcessK051649Command: PROC
		call Player_ReadByte
		cp 1
		jr c,Waveform
		jr z,Frequency
		cp 3
		jr c,Amplitude
		jr z,Mixer
		cp 5
		jr c,WaveformSCCPlus
		jr z,Deformation
		call Player_ReadWord
		jp Player_ProcessNext
	Waveform:
		call Player_ReadWord
		ld a,e
		call WriteRegister
		jp Player_ProcessNext
	Frequency:
		call Player_ReadWord
		ld a,SCC_FREQUENCY
		add a,e
		call WriteRegister
		jp Player_ProcessNext
	Amplitude:
		call Player_ReadWord
		ld a,SCC_AMPLITUDE
		add a,e
		call WriteRegister
		jp Player_ProcessNext
	Mixer:
		call Player_ReadWord
		ld a,SCC_MIXER
		call WriteRegister
		jp Player_ProcessNext
	WaveformSCCPlus:
		call Player_ReadWord
		jp Player_ProcessNext
	Deformation:
		call Player_ReadWord
		ld a,SCC_DEFORMATION
		call WriteRegister
		jp Player_ProcessNext
		ENDP
	ENDM

; ix <- instance or null
; de <- instance or null
SCC_TryCreate:
	call SCC_Detect
	ld ix,0
	ld de,0
	ret nc
	ld ix,SCC_instance
	call SCC_Construct
	ld e,ixl
	ld d,ixh
	ret

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
; iy = player
SCC_Install:
	ld hl,SCC.ProcessK051649Command
	ld a,0D2H
	call Player_InstallCommandHandler_IXOffset
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
	SECTION PAGE1

SCC_instance: SCC

	ENDS
