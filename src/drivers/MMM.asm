;
; Musical Memory Mapper SN76489 DCSG driver
;
MMM_BASE_ADDRESS: equ 8000H
MMM_CONTROL: equ 3CH
MMM_SN76489: equ 3FH
MMM_PAGE0: equ 0FCH
MMM_PAGE1: equ 0FDH
MMM_PAGE2: equ 0FEH
MMM_PAGE3: equ 0FFH
MMM_FREQUENCY: equ 3579545

MMM: MACRO
	super: Driver Driver_PrintInfoImpl
	slot:
		db 0

	; a = value
	SafeWriteRegister:
	; a = value
	WriteRegister:
		out (MMM_SN76489),a
		ret
	ENDM

; a = slot
; ix = this
MMM_Construct:
	ld bc,MMM_name
	ld de,MMM_FREQUENCY >> 16
	ld hl,MMM_FREQUENCY
	call Driver_Construct
	call MMM_SetSlot
	call MMM_Enable
	call MMM_Reset
	ret

; ix = this
MMM_Destruct:
	call MMM_Reset
	call MMM_Disable
	ret

	SECTION TPA_PAGE0

; ix = this
MMM_Enable:
	ld a,080H
	out (MMM_CONTROL),a
	ld c,0C0H
	ld a,(ix + MMM.slot)
	ld hl,MMM_BASE_ADDRESS + MMM_CONTROL
	call Memory_WriteSlot
	ld a,0
	out (MMM_CONTROL),a
	ret

; ix = this
MMM_Disable:
	ld a,080H
	out (MMM_CONTROL),a
	ld c,080H
	ld a,(ix + MMM.slot)
	ld hl,MMM_BASE_ADDRESS + MMM_CONTROL
	call Memory_WriteSlot
	ld a,0
	out (MMM_CONTROL),a
	ret

	ENDS

; a = slot
; ix = this
MMM_SetSlot:
	ld (ix + MMM.slot),a
	ret

; a = value
; ix = this
MMM_WriteRegister:
	ld bc,MMM.WriteRegister
	jp Utils_JumpIXOffsetBC

; ix = this
MMM_Reset:
	ld a,9FH
	call MMM_WriteRegister
	ld a,0BFH
	call MMM_WriteRegister
	ld a,0DFH
	call MMM_WriteRegister
	ld a,0FFH
	call MMM_WriteRegister
	ret

; f <- c: found
; a <- slot
MMM_Detect:
	ld hl,MMM_MatchSlot
	call Memory_SearchSlots
	ret

	SECTION TPA_PAGE0

; a = slot id
; f <- c: found
MMM_MatchSlot: PROC
	ld hl,MMM_detectValues
	ld c,a
	ld b,4
Loop:
	ld a,(hl)
	push bc
	push hl
	call TestValue
	pop hl
	pop bc
	ret nc
	djnz Loop
	ret
TestValue:
	ld b,a
	call Mapper_instance.GetP2
	push af
	ld a,080H
	out (MMM_CONTROL),a
	ld a,b
	out (MMM_PAGE2),a
	ld a,c
	ld hl,MMM_BASE_ADDRESS + MMM_PAGE2
	push bc
	call Memory_ReadSlot
	pop bc
	ld c,a
	ld a,0
	out (MMM_CONTROL),a
	pop af
	call Mapper_instance.PutP2
	ld a,c
	and 00111111B
	cp b
	scf
	ret z
	ccf
	ret
	ENDP

	IF $ > 4000H
		ERROR "Must not be in pages 1-2."
	ENDIF

	ENDS

;
MMM_name:
	db "Musical Memory Mapper",0

	SECTION RAM_PAGE0

MMM_instance: MMM

MMM_detectValues:
	db 0CH, 13H, 2FH, 3DH

	IF $ > 4000H
		ERROR "Must not be in pages 1-2."
	ENDIF

	ENDS
