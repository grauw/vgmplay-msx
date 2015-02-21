;
; SFG-01 / SFG-05 FM Sound Synthesizer Unit driver
;
; The SFG module uses the YM2151.
;
SFG01_DATA: equ 3FF5H
SFG01_STATUS: equ 3FF6H
SFG01_COMMAND: equ 3FF6H
SFG01_ID_ADDRESS: equ 80H

SFG01: MACRO
	found:
		db 0
	slot:
		db 0
	preparedSlot:
		dw 0
	ENDM

; ix = this
SFG01_Install:
	call SFG01_Detect
	ret nc
	di
	call SFG01_SetSlot
	ld (ix + SFG01.found),-1
	ei
	ret

; ix = this
SFG01_Uninstall:
	ld a,(ix + SFG01.found)
	and a
	ret z
	ret

; ix = this
; a = slot
SFG01_SetSlot:
	ld (ix + SFG01.slot),a

	call Memory_PrepareSlotPage0
	ld (ix + SFG01.preparedSlot),e
	ld (ix + SFG01.preparedSlot + 1),d
	ret

;
; Detect MIDI interface
;
; ix = this
; f <- c: found
; a <- slot
;
SFG01_Detect:
	ld hl,MSXMidi_MatchID
	call Memory_SearchSlots
	ret

;
; Check slot for MIDI ID
;
; ix = this
; a = slot id
; f <- c: found
;
MSXMidi_MatchID:
	ld de,SFG01_id
	ld hl,SFG01_ID_ADDRESS
	ld bc,6
	call Memory_MatchSlotString
	ret

SFG01_id:
	db "MCHFM0"

;
; Workarea definition
;
	SECTION RAM

SFG01_instance: SFG01

	ENDS
