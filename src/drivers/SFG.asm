;
; SFG-01 / SFG-05 FM Sound Synthesizer Unit driver
;
; The SFG module uses the YM2151.
;
SFG_YM2151_STATUS: equ 3FF1H
SFG_YM2151_ADDRESS: equ 3FF0H
SFG_YM2151_DATA: equ 3FF1H
SFG_ID_ADDRESS: equ 80H

SFG: MACRO
	slot:
		db 0

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp 14H
		jr z,MaskIRQEN
		cp 1BH
		jr z,MaskCT
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
		ld (SFG_YM2151_ADDRESS),a
		cp (hl)  ; R800 wait: ~4 bus cycles
		ld a,d
		ld (SFG_YM2151_DATA),a
		ld a,e
		cpl
		ld (hl),a
		ei
		out (c),b
		ret
	MaskCT:
		ld a,d
		and 00111111B
		ld d,a
		ld a,e
		jr WriteRegister
	MaskIRQEN:
		ld a,d
		and 11110011B
		ld d,a
		ld a,e
		jr WriteRegister

	; ix = player
	; iy = reader
	ProcessYM2151Command:
		call Reader_ReadWord_IY
		call SafeWriteRegister
		jp Player_ProcessNext
	ENDM

; ix <- instance or null
; de <- instance or null
SFG_TryCreate:
	call SFG_Detect
	ld ix,0
	ld de,0
	ret nc
	ld ix,SFG_instance
	call SFG_Construct
	ld e,ixl
	ld d,ixh
	ret

; a = slot
; ix = this
SFG_Construct:
	call SFG_SetSlot
	call SFG_Reset
	ret

; ix = this
SFG_Destruct:
	call SFG_Reset
	ret

; ix = this
; iy = player
SFG_Install:
	ld hl,SFG.ProcessYM2151Command
	ld a,54H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

; ix = this
; a = slot
SFG_SetSlot:
	ld (ix + SFG.slot),a
	call Memory_PrepareSlotPage0
	ld (ix + SFG.preparedSlot),d
	ld (ix + SFG.preparedSubslot),e
	ret

; ix = this
; e = register
; d = value
SFG_WriteRegister:
	push ix
	pop hl
	ld bc,SFG.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
SFG_SafeWriteRegister:
	push ix
	pop hl
	ld bc,SFG.SafeWriteRegister
	add hl,bc
	jp hl

; ix = this
SFG_Reset:
	call SFG_AllNotesOff
	call SFG_Mute
	ret

; ix = this
SFG_AllNotesOff: PROC
	ld b,8
	ld de,0008H
Loop:
	push bc
	push de
	call SFG_WriteRegister
	pop de
	pop bc
	inc d
	djnz Loop
	ret
	ENDP

; ix = this
SFG_Mute: PROC
	ld b,32
	ld de,7F60H
Loop:
	push bc
	push de
	call SFG_WriteRegister
	pop de
	pop bc
	inc e
	djnz Loop
	ret
	ENDP

; f <- c: found
; a <- slot
SFG_Detect:
	ld hl,SFG_MatchID
	call Memory_SearchSlots
	ret

; a = slot id
; f <- c: found
SFG_MatchID:
	ld de,SFG_id
	ld hl,SFG_ID_ADDRESS
	ld bc,6
	call Memory_MatchSlotString
	ret

SFG_id:
	db "MCHFM0"

;
	SECTION RAM_PAGE1

SFG_instance: SFG

	ENDS
