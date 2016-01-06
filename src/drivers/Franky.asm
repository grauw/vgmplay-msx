;
; Franky / Playsoniq SN76489 DCSG driver
;
Franky_DATA: equ 049H
Franky_FREQUENCY: equ 3579545

Franky: MACRO
	super: Driver

	; a = value
	SafeWriteRegister:
	; a = value
	WriteRegister:
		out (Franky_DATA),a
		ret
	ENDM

; ix = this
Franky_Construct:
	ld bc,Franky_name
	ld de,Franky_FREQUENCY >> 16
	ld hl,Franky_FREQUENCY
	call Driver_Construct
	ld a,0FFH
	out (40H),a  ; make sure no known switched I/O device is listening
	call Franky_Reset
	ret

; ix = this
Franky_Destruct:
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

; f <- c: found
Franky_Detect:
	scf
	ret

;
Franky_name:
	db "Franky",0

	SECTION RAM

Franky_instance: Franky

	ENDS
