;
; MSX-MUSIC YM2413 OPLL driver
;
MSXMusic: MACRO
	ADDRESS: equ 7CH
	DATA: equ 7DH
	ID_ADDRESS: equ 401CH
	ENABLE_ADDRESS: equ 7FF6H
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
		out (MSXMusic.ADDRESS),a
		push ix  ; wait 12 cycles
		pop ix
		ld a,d
		out (MSXMusic.DATA),a
		ret
	ENDM

; ix = this
MSXMusic_Install: PROC
	call MSXMusic_Detect
	jr nc,Disable
	di
	ld (ix + MSXMusic.slot),a
	ld (ix + MSXMusic.found),-1
	ei
	call MSXMusic_Enable
	call MSXMusic_Reset
	ret
Disable:
	ld (ix + MSXMusic.SafeWriteRegister),0C9H  ; ret
	ld (ix + MSXMusic.WriteRegister),0C9H  ; ret
	ret
	ENDP

; ix = this
MSXMusic_Uninstall:
	ld a,(ix + MSXMusic.found)
	and a
	ret z
	call MSXMusic_Reset
	call MSXMusic_Disable
	ret

; ix = this
; e = register
; d = value
MSXMusic_WriteRegister:
	push ix
	pop hl
	ld bc,MSXMusic.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
MSXMusic_SafeWriteRegister:
	push ix
	pop hl
	ld bc,MSXMusic.SafeWriteRegister
	add hl,bc
	jp hl

; ix = this
MSXMusic_Enable:
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic.ENABLE_ADDRESS
	call Memory_ReadSlot
	set 0,a
	ld c,a
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic.ENABLE_ADDRESS
	call Memory_WriteSlot
	ret

; ix = this
MSXMusic_Disable:
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic.ENABLE_ADDRESS
	call Memory_ReadSlot
	res 0,a
	ld c,a
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic.ENABLE_ADDRESS
	call Memory_WriteSlot
	ret

; b = count
; e = register base
; d = value
; ix = this
MSXMusic_FillRegisters: PROC
	push bc
	push de
	call MSXMusic_SafeWriteRegister
	call R800Wait
	pop de
	pop bc
	inc e
	djnz MSXMusic_FillRegisters
	ret
R800Wait:
	in a,(09AH)
	in a,(09AH)  ; ~54 cycles
	in a,(09AH)  ; ~54 cycles
	ret
	ENDP

; ix = this
MSXMusic_Mute:
	ld b,9
	ld de,0030H
	call MSXMusic_FillRegisters
	ret

; ix = this
MSXMusic_Reset:
	call MSXMusic_Mute
	ld b,3CH
	ld de,0000H
	call MSXMusic_FillRegisters
	ret

; ix = this
; f <- c: found
; a <- slot
MSXMusic_Detect:
	ld hl,MSXMusic_MatchID
	call Memory_SearchSlots
	ret

; a = slot id
; ix = this
; f <- c: found
MSXMusic_MatchID:
	ld de,MSXMusic_id
	ld hl,MSXMusic.ID_ADDRESS
	ld bc,4
	call Memory_MatchSlotString
	ret

MSXMusic_id:
	db "OPLL"

;
; Workarea definition
;
	SECTION RAM

MSXMusic_instance: MSXMusic

	ENDS
