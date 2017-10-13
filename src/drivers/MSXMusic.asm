;
; MSX-MUSIC YM2413 OPLL driver
;
MSXMusic_ADDRESS: equ 7CH
MSXMusic_DATA: equ 7DH
MSXMusic_ID_ADDRESS: equ 4018H
MSXMusic_ENABLE_ADDRESS: equ 7FF6H
MSXMusic_FREQUENCY: equ 3579545

MSXMusic: MACRO
	super: Driver
	slot:
		db 0
	internal:
		db 0

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
	; a = register
	; d = value
	WriteRegister:
		out (MSXMusic_ADDRESS),a
		in a,(MSXMusic_ADDRESS)  ; wait 12 cycles
		ld a,(hl)                ;  "
		ld a,d
		out (MSXMusic_DATA),a
		in a,(09AH)  ; R800 wait: ~72 cycles
		in a,(09AH)
		ret
	ENDM

; a = slot
; b = internal
; ix = this
MSXMusic_Construct:
	ld (ix + MSXMusic.slot),a
	ld (ix + MSXMusic.internal),b
	ld bc,MSXMusic_name
	ld de,MSXMusic_FREQUENCY >> 16
	ld hl,MSXMusic_FREQUENCY
	call Driver_Construct
	call MSXMusic_Enable
	call MSXMusic_Reset
	ret

; ix = this
MSXMusic_Destruct:
	call MSXMusic_Mute
	call MSXMusic_Disable
	ret

; e = register
; d = value
; ix = this
MSXMusic_WriteRegister:
	push ix
	pop hl
	ld bc,MSXMusic.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; e = register
; d = value
; ix = this
MSXMusic_SafeWriteRegister:
	push ix
	pop hl
	ld bc,MSXMusic.SafeWriteRegister
	add hl,bc
	jp hl

; ix = this
MSXMusic_Enable:
	bit 0,(ix + MSXMusic.internal)
	ret nz
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	call Memory_ReadSlot
	set 0,a
	ld c,a
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	call Memory_WriteSlot
	ret

; ix = this
MSXMusic_Disable:
	bit 0,(ix + MSXMusic.internal)
	ret nz
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	call Memory_ReadSlot
	res 0,a
	ld c,a
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	call Memory_WriteSlot
	ret

; b = count
; e = register base
; d = value
; ix = this
MSXMusic_FillRegisters:
	push bc
	push de
	call MSXMusic_SafeWriteRegister
	in a,(09AH)  ; R800 wait: ~62 cycles - 5 (ret)
	pop de
	pop bc
	inc e
	djnz MSXMusic_FillRegisters
	ret

; ix = this
MSXMusic_Mute:
	ld de,000EH
	call MSXMusic_SafeWriteRegister
	ld b,4
	ld de,0FF04H
	call MSXMusic_FillRegisters
	ld b,9
	ld de,0030H
	call MSXMusic_FillRegisters
	ld b,9
	ld de,0010H
	call MSXMusic_FillRegisters
	ld b,9
	ld de,0020H
	call MSXMusic_FillRegisters
	ret

; ix = this
MSXMusic_Reset:
	ld b,39H
	ld de,0000H
	call MSXMusic_FillRegisters
	ret

; f <- c: found
; a <- slot
; b <- 0: external, -1: internal
MSXMusic_Detect:
	ld hl,MSXMusic_MatchInternalID
	call Memory_SearchSlots
	ld b,-1
	ret c
	ld hl,MSXMusic_MatchExternalID
	call Memory_SearchSlots
	ld b,0
	ret

; a = slot id
; f <- c: found
MSXMusic_MatchInternalID:
	ld de,MSXMusic_internalId
	ld hl,MSXMusic_ID_ADDRESS
	ld bc,8
	call Memory_MatchSlotString
	ret

; a = slot id
; ix = this
; f <- c: found
MSXMusic_MatchExternalID:
	ld de,MSXMusic_externalId
	ld hl,MSXMusic_ID_ADDRESS + 4
	ld bc,4
	call Memory_MatchSlotString
	ret

MSXMusic_internalId:
	db "APRLOPLL"

MSXMusic_externalId:
	db "OPLL"

;
MSXMusic_name:
	db "MSX-MUSIC",0

	SECTION RAM

MSXMusic_instance: MSXMusic

	ENDS
