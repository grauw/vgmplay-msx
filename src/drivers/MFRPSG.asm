;
; MegaFlashROM SCC+ AY-3-8910 PSG driver
;
MFRPSG_BASE_PORT: equ 010H
MFRPSG_MFRSD_ID_ADDRESS: equ 04010H
MFRPSG_TYPE_READWRITE: equ 0
MFRPSG_TYPE_WRITEONLY: equ 1
MFRPSG_TYPE_MFRSD: equ 2

MFRPSG: MACRO
	super: PSG MFRPSG_BASE_PORT, MFRPSG_nameReadWrite
	SafeWriteRegister: equ super.SafeWriteRegister
	type:
		db 0
	ENDM

; ix = this
; iy = drivers
MFRPSG_Construct:
	call Driver_Construct
	call MFRPSG_Detect
	ret nc
	ld (ix + MFRPSG.type),a
	call MFRPSG_GetName
	call Driver_SetName
	call PSG_Reset
	ld de,PSG_FREQUENCY >> 16
	ld hl,PSG_FREQUENCY
	jp Driver_SetClock

MFRPSG_Destruct: equ PSG_Destruct
;	jp PSG_Destruct

; ix = this
; bc <- name
MFRPSG_GetName:
	ld a,(ix + MFRPSG.type)
	ld bc,MFRPSG_nameReadWrite
	cp MFRPSG_TYPE_WRITEONLY
	ret c
	ld bc,MFRPSG_nameWriteOnly
	ret z
	ld bc,MFRPSG_nameMFRSD
	ret

; ix = this
; a <- type
; f <- c: found
MFRPSG_Detect:
	call PSG_Detect
	ld a,MFRPSG_TYPE_READWRITE
	ret c
	ld hl,MFRPSG_MatchMFRSDID
	call Memory_SearchSlots
	ld a,MFRPSG_TYPE_MFRSD
	ret c
	ld a,MFRPSG_TYPE_WRITEONLY
	scf
	ret

; a = slot id
; f <- c: found
MFRPSG_MatchMFRSDID:
	ld de,MFRPSG_mfrsdId
	ld hl,MFRPSG_MFRSD_ID_ADDRESS
	ld bc,5
	jp Memory_MatchSlotString

;
MFRPSG_nameReadWrite:
	db "External PSG",0

MFRPSG_nameWriteOnly:
	db "External PSG?",0

MFRPSG_nameMFRSD:
	db "MegaFlashROM SD PSG",0

MFRPSG_mfrsdId:
	db "MFRSD"

	SECTION RAM

MFRPSG_instance: MFRPSG

	ENDS
