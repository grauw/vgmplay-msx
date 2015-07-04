;
; Franky / Playsoniq SN76489 DCSG driver
;
Franky_DATA: equ 049H

Franky: MACRO
	DATA: equ 049H

	; a = value
	SafeWriteRegister:
	; a = value
	WriteRegister:
		out (Franky_DATA),a
		ret

	; ix = player
	ProcessSN76489Command:
		call Player_ReadByte
		call SafeWriteRegister
		jp Player_ProcessNext
	ENDM

; ix <- instance or null
; de <- instance or null
Franky_TryCreate:
	ld ix,Franky_instance
	call Franky_Constructor
	ld e,ixl
	ld d,ixh
	ret

; ix = this
Franky_Constructor:
	ld a,0FFH
	out (40H),a  ; make sure no known switched I/O device is listening
	call Franky_Reset
	ret

; ix = this
Franky_Destructor:
	call Franky_Reset
	ret

; ix = this
; iy = player
Franky_Install:
	ld hl,Franky.ProcessSN76489Command
	ld a,50H
	call Player_InstallCommandHandler_IXOffset
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
