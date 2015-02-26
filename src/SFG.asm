;
; SFG-01 / SFG-05 FM Sound Synthesizer Unit driver
;
; The SFG module uses the YM2151.
;
SFG: MACRO
	YM2151_STATUS: equ 3FF1H
	YM2151_ADDRESS: equ 3FF0H
	YM2151_DATA: equ 3FF1H
	ID_ADDRESS: equ 80H
	found:
		db 0
	slot:
		db 0
	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp 01H
		ret z
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
		ld (SFG.YM2151_ADDRESS),a
		ld a,d
		ld (SFG.YM2151_DATA),a
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
	ENDM

; ix = this
SFG_Install: PROC
	call SFG_Detect
	jr nc,Disable
	di
	call SFG_SetSlot
	ld (ix + SFG.found),-1
	ei
	ret
Disable:
	ld (ix + SFG.WriteRegister),0C9H  ; ret
	ret
	ENDP

; ix = this
SFG_Uninstall:
	ld a,(ix + SFG.found)
	and a
	ret z
	call SFG_Reset
	ret

; ix = this
; a = slot
SFG_SetSlot:
	ld (ix + SFG.slot),a

	call Memory_PrepareSlotPage0
	ld (ix + SFG.preparedSlot),d
	ld (ix + SFG.preparedSubslot),e
	ret

	SECTION PAGE1

; ix = this
; e = register
; d = value
SFG_WriteRegister:
	bit 0,(ix + SFG.found)
	ret z
	ld a,d
	ex af,af'
	ld a,e
	ld d,(ix + SFG.preparedSlot)
	ld e,(ix + SFG.preparedSubslot)
	ld c,0A8H
	ld hl,0FFFFH
	di
	in b,(c)
	out (c),d
	ld d,(hl)
	ld (hl),e
	ld (SFG.YM2151_ADDRESS),a
;Wait:
;	ld a,(SFG.YM2151_STATUS)
;	rla
;	jr c,Wait
	ex af,af'
	ld (SFG.YM2151_DATA),a
	ld a,d
	cpl
	ld (hl),a
	ei
	out (c),b
	ret

	ENDS

; ix = this
; e = register
; d = value
SFG_SafeWriteRegister: PROC
	ld a,e
	cp 01H
	ret z
	cp 14H
	jr z,MaskIRQEN
	cp 1BH
	jp nz,SFG_WriteRegister
MaskCT:
	ld a,d
	and 00111111B
	ld d,a
	jp SFG_WriteRegister
MaskIRQEN:
	ld a,d
	and 11110011B
	ld d,a
	jp SFG_WriteRegister
	ENDP

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

;
; Detect MIDI interface
;
; ix = this
; f <- c: found
; a <- slot
;
SFG_Detect:
	ld hl,SFG_MatchID
	call Memory_SearchSlots
	ret

;
; Check slot for MIDI ID
;
; ix = this
; a = slot id
; f <- c: found
;
SFG_MatchID:
	ld de,SFG_id
	ld hl,SFG.ID_ADDRESS
	ld bc,6
	call Memory_MatchSlotString
	ret

SFG_id:
	db "MCHFM0"

;
; Workarea definition
;
	SECTION PAGE1

SFG_instance: SFG

	ENDS
