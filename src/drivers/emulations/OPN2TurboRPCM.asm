;
; OPN2 PCM on SFG + turboR PCM driver
;
OPN2TurboRPCM_PCM_REGISTER: equ 2AH
OPN2TurboRPCM_FREQUENCY: equ 7670453

OPN2TurboRPCM: MACRO
	super: Driver

	; e = register
	; d = value
	SafeWriteRegister: PROC
		ld a,e
		cp OPN2TurboRPCM_PCM_REGISTER
		jp z,0
	writePCMRegister: equ $ - 2
		jp 0
	writeFMRegister: equ $ - 2
		ENDP

	; e = register
	; d = value
	SafeWriteRegister2: PROC
		ld a,e
		jp 0
	writeFMRegister: equ $ - 2
		ENDP
	ENDM

; bc = OPN on SFG driver
; de = TurboR PCM driver
; ix = this
OPN2TurboRPCM_Construct:
	push bc
	push de
	ld bc,OPN2TurboRPCM_name
	ld de,OPN2TurboRPCM_FREQUENCY >> 16
	ld hl,OPN2TurboRPCM_FREQUENCY
	call Driver_Construct
	pop de
	pop bc
	ld hl,TurboRPCM.SafeWriteRegister
	add hl,de
	ld (ix + OPN2TurboRPCM.SafeWriteRegister.writePCMRegister),l
	ld (ix + OPN2TurboRPCM.SafeWriteRegister.writePCMRegister + 1),h
	ld hl,OPNFMOnSFG.WriteRegister
	add hl,bc
	ld (ix + OPN2TurboRPCM.SafeWriteRegister.writeFMRegister),l
	ld (ix + OPN2TurboRPCM.SafeWriteRegister.writeFMRegister + 1),h
	ld hl,OPNFMOnSFG.WriteRegister2
	add hl,bc
	ld (ix + OPN2TurboRPCM.SafeWriteRegister2.writeFMRegister),l
	ld (ix + OPN2TurboRPCM.SafeWriteRegister2.writeFMRegister + 1),h
	push ix
	ld ixl,c
	ld ixh,b
	ld de,38464
	call OPNFMOnSFG_SetFrequencyOffset
	pop ix
	ret

; ix = this
OPN2TurboRPCM_Destruct:
	ret

;
OPN2TurboRPCM_name:
	db "SFG + turboR PCM (emu)",0

	SECTION RAM

OPN2TurboRPCM_instance: OPN2TurboRPCM

	ENDS
