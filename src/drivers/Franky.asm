;
; Franky SN76489 DCSG driver
;
Franky_DATA: equ 049H
Franky_CLOCK: equ 3579545

Franky: MACRO
	super: Driver Franky_name, Franky_CLOCK, Driver_PrintInfoImpl

	; a = value
	SafeWriteRegister:
	; a = value
	WriteRegister:
		out (Franky_DATA),a
		ret
	ENDM

; ix = this
; iy = drivers
Franky_Construct:
	call Driver_Construct
	call Franky_Detect
	jp nc,Driver_NotFound
	ld a,0
	out (40H),a  ; make sure no known switched I/O device is listening
	jr Franky_Reset

; ix = this
Franky_Destruct:
	call Driver_IsFound
	ret nc
	jr Franky_Reset

; a = value
; ix = this
Franky_WriteRegister:
	ld bc,Franky.WriteRegister
	jp Utils_JumpIXOffsetBC

; ix = this
Franky_Reset:
	ld a,9FH
	call Franky_WriteRegister
	ld a,0BFH
	call Franky_WriteRegister
	ld a,0DFH
	call Franky_WriteRegister
	ld a,0FFH
	jr Franky_WriteRegister

; ix = this
; f <- c: found
Franky_Detect:
	scf
	ret

;
	SECTION RAM

Franky_instance: Franky

	ENDS

Franky_name:
	db "Franky",0
