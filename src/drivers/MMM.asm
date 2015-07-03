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

MMM: MACRO
	found:
		db 0
	slot:
		db 0

	; a = value
	SafeWriteRegister:
	; a = value
	WriteRegister:
		out (MMM_SN76489),a
		ret

	; ix = player
	ProcessSN76489Command:
		call Player_ReadByte
		call SafeWriteRegister
		jp Player_ProcessNext
	ENDM

; ix = this
MMM_Constructor: PROC
	call MMM_Detect
	jr nc,Disable
	call MMM_SetSlot
	call MMM_Enable
	call MMM_Reset
	ld (ix + MMM.found),-1
	ret
Disable:
	ld (ix + MMM.SafeWriteRegister),0C9H  ; ret
	ld (ix + MMM.WriteRegister),0C9H  ; ret
	ret
	ENDP

; ix = this
MMM_Destructor:
	call MMM_Reset
	call MMM_Disable
	ret

; ix = this
; iy = player
MMM_Install:
	ld a,(ix + MMM.found)
	and a
	ret z
	ld hl,MMM.ProcessSN76489Command
	ld a,50H
	call Player_InstallCommandHandler_IXOffset
	ret

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

; ix = this
; a = slot
MMM_SetSlot:
	ld (ix + MMM.slot),a
	ret

; a = value
; ix = this
MMM_WriteRegister:
	push ix
	pop hl
	ld bc,MMM.WriteRegister
	add hl,bc
	jp hl

; a = value
; ix = this
MMM_SafeWriteRegister:
	push ix
	pop hl
	ld bc,MMM.SafeWriteRegister
	add hl,bc
	jp hl

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

; ix = this
; f <- c: found
; a <- slot
MMM_Detect:
	ld hl,MMM_MatchSlot
	call Memory_SearchSlots
	ret

; a = slot id
; ix = this
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

;
; Workarea definition
;
	SECTION RAM

MMM_instance: MMM

MMM_detectValues:
	db 0CH, 13H, 2FH, 3DH

	IF $ > 4000H
		ERROR "Must not be in pages 1-2."
	ENDIF

	ENDS

	IF $ > 4000H
		ERROR "Must not be in pages 1-2."
	ENDIF
