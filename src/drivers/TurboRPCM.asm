;
; turboR PCM driver
;
TurboRPCM_DATA: equ 0A4H
TurboRPCM_CONTROL: equ 0A5H
TurboRPCM_FREQUENCY: equ 3579545

TurboRPCM: MACRO
	super: Driver

	; d = value
	SafeWriteRegister:
		ld a,d
	; a = value
	WriteRegister:
		out (TurboRPCM_DATA),a
		ret
	ENDM

; ix = this
TurboRPCM_Construct:
	ld bc,TurboRPCM_name
	ld de,TurboRPCM_FREQUENCY >> 16
	ld hl,TurboRPCM_FREQUENCY
	call Driver_Construct
	call TurboRPCM_Enable
	ret

; ix = this
TurboRPCM_Destruct:
	call TurboRPCM_Disable
	ret

; ix = this
; d = value
TurboRPCM_WriteRegister:
	push ix
	pop hl
	ld bc,TurboRPCM.WriteRegister
	add hl,bc
	ld a,d
	jp hl

; ix = this
; d = value
TurboRPCM_SafeWriteRegister:
	push ix
	pop hl
	ld bc,TurboRPCM.SafeWriteRegister
	add hl,bc
	jp hl

; ix = this
TurboRPCM_Enable:
	ld a,80H
	out (TurboRPCM_DATA),a
	ld a,00000011B
	out (TurboRPCM_CONTROL),a
	ret

; ix = this
TurboRPCM_Disable:
	ld a,00000010B
	out (TurboRPCM_CONTROL),a
	ld a,80H
	out (TurboRPCM_DATA),a
	ret

; f <- c: found
TurboRPCM_Detect:
	call System_IsTurboR
	ccf
	ret

;
TurboRPCM_name:
	db "TurboR PCM",0

	SECTION RAM

TurboRPCM_instance: TurboRPCM

	ENDS
