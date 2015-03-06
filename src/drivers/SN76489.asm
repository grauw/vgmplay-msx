;
; SN76489 DCSG driver
;
SN76489: MACRO
	DATA: equ 048H
	found:
		db -1

	; a = value
	SafeWriteRegister:
	; a = value
	WriteRegister:
		out (SN76489.DATA),a
		ret
	ENDM

; ix = this
SN76489_Install:
	call SN76489_Reset
	ret

; ix = this
SN76489_Uninstall:
	call SN76489_Reset
	ret

; a = value
; ix = this
SN76489_WriteRegister:
	push ix
	pop hl
	ld bc,SN76489.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; a = value
; ix = this
SN76489_SafeWriteRegister:
	push ix
	pop hl
	ld bc,SN76489.SafeWriteRegister
	add hl,bc
	jp hl

; ix = this
SN76489_Reset:
	ret

;
; Workarea definition
;
	SECTION RAM

SN76489_instance: SN76489

	ENDS
