;
; OSC1N0 Supersoniqs Neotron
;
Neotron_BASE: equ 0BC00H
Neotron_STATUS0: equ Neotron_BASE
Neotron_STATUS1: equ Neotron_BASE + 2
Neotron_FM1_ADDRESS: equ Neotron_BASE
Neotron_FM1_DATA: equ Neotron_BASE + 1
Neotron_FM2_ADDRESS: equ Neotron_BASE + 2
Neotron_FM2_DATA: equ Neotron_BASE + 3
Neotron_ID_ADDRESS: equ 806CH
Neotron_FREQUENCY: equ 8000000

; ADPCM registers
Neotron_ADPCM_CONTROL: equ 10H
Neotron_MISC_CONTROL: equ 11H
Neotron_START_ADDRESS_L: equ 12H
Neotron_START_ADDRESS_H: equ 13H
Neotron_STOP_ADDRESS_L: equ 14H
Neotron_STOP_ADDRESS_H: equ 15H
Neotron_DELTA_N_L: equ 19H
Neotron_DELTA_N_H: equ 1AH
Neotron_ENVELOPE_CONTROL: equ 1BH
Neotron_FLAG_CONTROL: equ 1CH

; SIOS API
SIOS_ENABLE_IO: equ 801CH

Neotron: MACRO
	super: Driver Driver_PrintInfoImpl
	slot:
		db 0

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp 21H
		ret z              ; block FM TEST register
		cp 27H
		jr z,TimerControl  ; mask timer control
	; a = register
	; d = value
	WriteRegister: PROC
	begin: Memory_AccessPreparedSlot_BEGIN
		ld hl,Neotron_FM1_ADDRESS
		ld (hl),a
		ld a,(hl)  ; wait 17 cycles
		inc l
		ld (hl),d
		Memory_AccessPreparedSlot_END
		in a,(9AH)  ; wait 83 cycles
		in a,(9AH)
		ret
		ENDP
	TimerControl:
		ld a,d
		and 11000000B
		ld d,a
		ld a,e
		jr WriteRegister

	; e = register
	; d = value
	SafeWriteRegister2:
		ld a,e
		cp 02H
		ret z              ; block ADPCM-A TEST register
	; a = register
	; d = value
	WriteRegister2: PROC
	begin: Memory_AccessPreparedSlot_BEGIN
		ld hl,Neotron_FM2_ADDRESS
		ld (hl),a
		ld a,(hl)  ; wait 17 cycles
		inc l
		ld (hl),d
		Memory_AccessPreparedSlot_END
		in a,(9AH)  ; wait 83 cycles
		in a,(9AH)
		ret
		ENDP
	ENDM

; a = slot
; ix = this
Neotron_Construct:
	call Neotron_SetSlot
	ld bc,Neotron_name
	ld de,Neotron_FREQUENCY >> 16
	ld hl,Neotron_FREQUENCY
	call Driver_Construct
	call Neotron_Select
	call Neotron_Reset
	ret

; ix = this
Neotron_Destruct:
	call Neotron_Mute
	call Neotron_Deselect
	ret

; a = slot
; ix = this
Neotron_SetSlot:
	ld (ix + Neotron.slot),a
	ld h,80H
	call Memory_PrepareSlot
	ld (ix + Neotron.WriteRegister.begin.preparedSlot),d
	ld (ix + Neotron.WriteRegister.begin.preparedSubslot),e
	ld (ix + Neotron.WriteRegister2.begin.preparedSlot),d
	ld (ix + Neotron.WriteRegister2.begin.preparedSubslot),e
	ret

; ix = this
Neotron_Select:
	push ix
	push iy
	ld a,(ix + Neotron.slot)
	ld iyh,a
	ld ix,SIOS_ENABLE_IO
	and a
	call Memory_CallSlot
	pop iy
	pop ix
	ret

; ix = this
Neotron_Deselect:
	push ix
	push iy
	ld a,(ix + Neotron.slot)
	ld iyh,a
	ld ix,SIOS_ENABLE_IO
	scf
	call Memory_CallSlot
	pop iy
	pop ix
	ret

; e = register
; d = value
; ix = this
Neotron_WriteRegister:
	ld a,e
	ld bc,Neotron.WriteRegister
	jp Utils_JumpIXOffsetBC

; e = register
; d = value
; ix = this
Neotron_SafeWriteRegister:
	ld bc,Neotron.SafeWriteRegister
	jp Utils_JumpIXOffsetBC

; e = register
; d = value
; ix = this
Neotron_WriteRegister2:
	ld a,e
	ld bc,Neotron.WriteRegister2
	jp Utils_JumpIXOffsetBC

; e = register
; d = value
; ix = this
Neotron_SafeWriteRegister2:
	ld bc,Neotron.SafeWriteRegister2
	jp Utils_JumpIXOffsetBC

; b = count
; e = register base
; d = value
; ix = this
Neotron_FillRegisters:
	push bc
	push de
	call Neotron_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz Neotron_FillRegisters
	ret

; b = count
; e = register base
; d = value
; ix = this
Neotron_FillRegisterPairs:
	push bc
	push de
	call Neotron_SafeWriteRegister
	pop de
	push de
	call Neotron_SafeWriteRegister2
	pop de
	pop bc
	inc e
	djnz Neotron_FillRegisterPairs
	ret

; ix = this
Neotron_Mute: PROC
	ld b,3  ; mute SSG
	ld de,0008H
	call Neotron_FillRegisters
	ld b,14
	ld de,0000H
	call Neotron_FillRegisters
	ld de,0BFH << 8 | 0
	call Neotron_WriteRegister2  ; stop ADPCM-A
	ld de,01H << 8 | Neotron_ADPCM_CONTROL
	call Neotron_WriteRegister  ; stop ADPCM-B
	ld b,10H
	ld de,0F80H
	call Neotron_FillRegisterPairs  ; max release rate
	ld b,10H
	ld de,7F40H
	call Neotron_FillRegisterPairs  ; min total level
	ld b,08H
	ld de,0028H
KeyOffLoop:
	push bc
	push de
	call Neotron_WriteRegister
	pop de
	pop bc
	inc d
	djnz KeyOffLoop
	ret
	ENDP

; ix = this
Neotron_Reset:
	ld b,0B8H
	ld de,0000H
	call Neotron_FillRegisterPairs  ; zero all registers
	ld de,0C0H << 8 | Neotron_MISC_CONTROL
	call Neotron_WriteRegister      ; ADPCM-B panpot
	ld b,04H
	ld de,0C0B4H
	call Neotron_FillRegisterPairs  ; FM panpots
	ret

; f <- c: found
; a <- slot
Neotron_Detect:
	ld hl,Neotron_MatchID
	call Memory_SearchSlots
	ret

; a = slot id
; f <- c: found
Neotron_MatchID:
	ld de,Neotron_id
	ld hl,Neotron_ID_ADDRESS
	ld bc,12
	call Memory_MatchSlotString
	ret

;
Neotron_name:
	db "Neotron",0
Neotron_id:
	db "OSC YM  OPNB"

	SECTION RAM

Neotron_instance: Neotron

	ENDS
