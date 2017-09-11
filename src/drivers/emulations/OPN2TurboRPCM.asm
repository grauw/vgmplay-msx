;
; OPN2 PCM on turboR PCM driver
;
OPN2TurboRPCM_PCM_REGISTER: equ 2AH
OPN2TurboRPCM_FREQUENCY: equ 3579545

OPN2TurboRPCM: MACRO
	super: Driver

	; e = register
	; d = value
	SafeWriteRegister: PROC
		ld a,e
		cp OPN2TurboRPCM_PCM_REGISTER
		jp z,0
	writePCMRegister: equ $ - 2
		ret
		ENDP

	; e = register
	; d = value
	SafeWriteRegister2:
		ret
	ENDM

; de = TurboR PCM driver
; ix = this
OPN2TurboRPCM_Construct:
	push de
	ld bc,OPN2TurboRPCM_name
	ld de,OPN2TurboRPCM_FREQUENCY >> 16
	ld hl,OPN2TurboRPCM_FREQUENCY
	call Driver_Construct
	pop de
	ld hl,TurboRPCM.SafeWriteRegister
	add hl,de
	ld (ix + OPN2TurboRPCM.SafeWriteRegister.writePCMRegister),l
	ld (ix + OPN2TurboRPCM.SafeWriteRegister.writePCMRegister + 1),h
	ret

; ix = this
OPN2TurboRPCM_Destruct:
	ret

;
OPN2TurboRPCM_name:
	db "OPN2 -> turboR PCM",0

	SECTION RAM

OPN2TurboRPCM_instance: OPN2TurboRPCM

	ENDS
