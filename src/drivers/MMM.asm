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
	super: Driver MMM_name, Driver_PrintInfoImpl
	slot:
		db 0

	; a = value
	SafeWriteRegister:
	; a = value
	WriteRegister:
		out (MMM_SN76489),a
		ret
	ENDM

; ix = this
; iy = drivers
MMM_Construct:
	call Driver_Construct
	call MMM_Detect
	ret nc
	call MMM_SetSlot
	call MMM_Enable
	call MMM_Reset
	ld de,MMM_FREQUENCY >> 16
	ld hl,MMM_FREQUENCY
	jp Driver_SetClock

; ix = this
MMM_Destruct:
	call Driver_IsFound
	ret nc
	call MMM_Reset
	jp MMM_Disable

	SECTION TPA_PAGE0

; ix = this
MMM_Enable:
	ld d,(ix + MMM.slot)
	ld e,0C0H
	ld hl,MMM_BASE_ADDRESS + MMM_CONTROL
	ld a,080H
	di
	out (MMM_CONTROL),a
	ld a,d
	call Memory_WriteSlot
	ld a,0
	ei
	out (MMM_CONTROL),a
	ret

; ix = this
MMM_Disable:
	ld d,(ix + MMM.slot)
	ld e,080H
	ld hl,MMM_BASE_ADDRESS + MMM_CONTROL
	ld a,080H
	di
	out (MMM_CONTROL),a
	ld a,d
	call Memory_WriteSlot
	ld a,0
	ei
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
	jr MMM_WriteRegister

; ix = this
; f <- c: found
; a <- slot
MMM_Detect:
	ld hl,MMM_MatchSlot
	jp Memory_SearchSlots

	SECTION TPA_PAGE0

; a = slot id
; f <- c: found
MMM_MatchSlot: PROC
	ld c,a
	ld b,0CH
	call TestValue
	ld b,13H
	call c,TestValue
	ld b,2FH
	call c,TestValue
	ld b,3DH
	call c,TestValue
	ret
TestValue:
	call Mapper_instance.GetP1
	push af
	ld a,080H
	di
	out (MMM_CONTROL),a
	ld a,b
	out (MMM_PAGE1),a
	ld a,c
	ld hl,MMM_BASE_ADDRESS + MMM_PAGE1
	push bc
	call RDSLT
	pop bc
	ld e,a
	ld a,0
	out (MMM_CONTROL),a
	pop af
	call Mapper_instance.PutP1
	ei
	ld a,e
	and 00111111B
	xor b
	ret nz
	scf
	ret
	ENDP

	IF $ > 4000H
		ERROR "Must not be in pages 1-2."
	ENDIF

	ENDS

;
MMM_name:
	db "Musical Memory Mapper",0

MMM_instance: MMM
