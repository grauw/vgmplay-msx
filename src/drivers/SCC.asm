;
; K051649 Konami SCC
;
SCC: MACRO
	REGISTER_BASE: equ 9800H
	WAVEFORM: equ 00H
	FREQUENCY: equ 80H
	AMPLITUDE: equ 8AH
	MIXER: equ 8FH
	DEFORMATION: equ 0E0H
	BANK_SELECT: equ 9000H
	BANK: equ 3FH
	found:
		db 0
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
		ld h,REGISTER_BASE >> 8
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
		ld a,SCC.FREQUENCY
		add a,e
		call WriteRegister
		jp Player_ProcessNext
	Amplitude:
		call Player_ReadWord
		ld a,SCC.AMPLITUDE
		add a,e
		call WriteRegister
		jp Player_ProcessNext
	Mixer:
		call Player_ReadWord
		ld a,SCC.MIXER
		call WriteRegister
		jp Player_ProcessNext
	WaveformSCCPlus:
		call Player_ReadWord
		jp Player_ProcessNext
	Deformation:
		call Player_ReadWord
		ld a,SCC.DEFORMATION
		call WriteRegister
		jp Player_ProcessNext
		ENDP
	ENDM

; ix = this
SCC_Constructor: PROC
	call SCC_Detect
	jr nc,Disable
	call SCC_SetSlot
	call SCC_SelectBank
	ld (ix + SCC.found),-1
	call SCC_Reset
	ret
Disable:
	ld (ix + SCC.SafeWriteRegister),0C9H  ; ret
	ld (ix + SCC.WriteRegister),0C9H  ; ret
	ret
	ENDP

; ix = this
SCC_Destructor:
	ld a,(ix + SCC.found)
	and a
	ret z
	call SCC_Reset
	ret

; ix = this
; iy = player
SCC_Install:
	ld a,(ix + SCC.found)
	and a
	ret z
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
	ld hl,SCC.BANK_SELECT
	ld c,SCC.BANK
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
	ld de,0 << 8 | (SCC.AMPLITUDE & 0FFH)
	call SCC_FillRegisters
	ret

; ix = this
; f <- c: found
; a <- slot
SCC_Detect:
	ld hl,SCC_MatchSlot
	call Memory_SearchSlots
	ret

; a = slot id
; ix = this
; f <- c: found
SCC_MatchSlot: PROC
	ex af,af'
	call Memory_GetSlotPage2
	push af
	ex af,af'
	ld h,80H
	call Memory_SetSlot
	ld a,(SCC.BANK_SELECT)
	ld d,a
	ld a,SCC.BANK
	ld (SCC.BANK_SELECT),a
	ld hl,SCC.REGISTER_BASE
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
	ld a,(SCC.BANK_SELECT)
	cp SCC.BANK
	jr z,NoSCC
	xor a
	jr Found
NoSCC:
	ld (hl),e
	ld a,d
	ld (SCC.BANK_SELECT),a
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
; Workarea definition
;
	SECTION PAGE1

SCC_instance: SCC

	ENDS
