;
; Franky / Playsoniq SN76489 DCSG driver
;
Franky: MACRO
	DATA: equ 049H
	found:
		db 0

	; a = value
	SafeWriteRegister:
	; a = value
	WriteRegister:
		out (Franky.DATA),a
		ret
	ENDM

; ix = this
Franky_Constructor:
	ld (ix + Franky.found),-1
	ld a,0FFH
	out (40H),a  ; make sure no known switched I/O device is listening
	call Franky_Reset
	ret

; ix = this
Franky_Destructor:
	call Franky_Reset
	ret

; a = value
; ix = this
Franky_WriteRegister:
	push ix
	pop hl
	ld bc,Franky.WriteRegister
	add hl,bc
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
	ld a,9FH
	call Franky_WriteRegister
	ld a,0BFH
	call Franky_WriteRegister
	ld a,0DFH
	call Franky_WriteRegister
	ld a,0FFH
	call Franky_WriteRegister
	ret

;
; Workarea definition
;
	SECTION RAM

Franky_instance: Franky

	ENDS
