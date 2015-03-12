;
; Franky / Playsoniq SN76489 DCSG driver
;
Franky: MACRO
	DATA: equ 049H
	found:
		db -1

	; a = value
	SafeWriteRegister:
	; a = value
	WriteRegister:
		out (Franky.DATA),a
		ret
	ENDM

; ix = this
Franky_Install:
	ld a,0FFH
	out (40H),a  ; make sure no known switched I/O device is listening
	call Franky_Reset
	ret

; ix = this
Franky_Uninstall:
	call Franky_Reset
	ret

; a = value
; ix = this
Franky_WriteRegister:
	push ix
	pop hl
	ld bc,Franky.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; a = value
; ix = this
Franky_SafeWriteRegister:
	push ix
	pop hl
	ld bc,Franky.SafeWriteRegister
	add hl,bc
	jp hl

; ix = this
Franky_Reset:
	ret

;
; Workarea definition
;
	SECTION RAM

Franky_instance: Franky

	ENDS
