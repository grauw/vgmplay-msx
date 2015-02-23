;
; SFG-01 / SFG-05 FM Sound Synthesizer Unit driver
;
; The SFG module uses the YM2151.
;
SFG: MACRO
	YM2151_STATUS: equ 3FF0H
	YM2151_ADDRESS: equ 3FF0H
	YM2151_DATA: equ 3FF1H
	ID_ADDRESS: equ 80H
	found:
		db 0
	slot:
		db 0
	preparedSlot:
		dw 0
	ENDM

; ix = this
SFG_Install:
	call SFG_Detect
	ret nc
	di
	call SFG_SetSlot
	ld (ix + SFG.found),-1
	ei
	ret

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
	ld (ix + SFG.preparedSlot),e
	ld (ix + SFG.preparedSlot + 1),d
	ret

; ix = this
; l = register
; h = value
SFG_WriteRegister:
	bit 0,(ix + SFG.found)
	ret z
	push hl
	ld c,l
	ld hl,SFG.YM2151_ADDRESS
	ld e,(ix + SFG.preparedSlot)
	ld d,(ix + SFG.preparedSlot + 1)
	call Memory_WritePreparedSlot
	pop hl
	ld c,h
	ld hl,SFG.YM2151_DATA
	ld e,(ix + SFG.preparedSlot)
	ld d,(ix + SFG.preparedSlot + 1)
	call Memory_WritePreparedSlot
	ret

; ix = this
; l = register
; h = value
SFG_SafeWriteRegister: PROC
	ld a,l
	cp 01H
	ret z
	cp 14H
	jr z,MaskIRQEN
	cp 1BH
	jr z,MaskCT
	jp SFG_WriteRegister
MaskIRQEN:
	ld a,h
	and 11110011B
	ld h,a
	jp SFG_WriteRegister
MaskCT:
	ld a,h
	and 00111111B
	ld h,a
	jp SFG_WriteRegister
	ret
	ENDP

; ix = this
SFG_Reset:
	call SFG_AllNotesOff
	call SFG_Mute
	ret

; ix = this
SFG_AllNotesOff: PROC
	ld b,8
	ld hl,0008H
Loop:
	push bc
	push hl
	call SFG_WriteRegister
	pop hl
	pop bc
	inc h
	djnz Loop
	ret
	ENDP

; ix = this
SFG_Mute: PROC
	ld b,32
	ld hl,7F60H
Loop:
	push bc
	push hl
	call SFG_WriteRegister
	pop hl
	pop bc
	inc l
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
	SECTION RAM

SFG_instance: SFG

	ENDS
