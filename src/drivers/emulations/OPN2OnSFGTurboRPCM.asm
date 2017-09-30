;
; OPN2 PCM on SFG + turboR PCM driver
;
OPN2OnSFGTurboRPCM_PCM_REGISTER: equ 2AH
OPN2OnSFGTurboRPCM_FREQUENCY: equ 7670453

OPN2OnSFGTurboRPCM: MACRO
	super: Driver

	; e = register
	; d = value
	SafeWriteRegister: PROC
		ld a,e
		cp OPN2OnSFGTurboRPCM_PCM_REGISTER
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
OPN2OnSFGTurboRPCM_Construct:
	push bc
	push de
	ld bc,OPN2OnSFGTurboRPCM_name
	ld de,OPN2OnSFGTurboRPCM_FREQUENCY >> 16
	ld hl,OPN2OnSFGTurboRPCM_FREQUENCY
	call Driver_Construct
	pop de
	pop bc
	ld hl,TurboRPCM.SafeWriteRegister
	add hl,de
	ld (ix + OPN2OnSFGTurboRPCM.SafeWriteRegister.writePCMRegister),l
	ld (ix + OPN2OnSFGTurboRPCM.SafeWriteRegister.writePCMRegister + 1),h
	ld hl,OPNFMOnSFG.WriteRegister
	add hl,bc
	ld (ix + OPN2OnSFGTurboRPCM.SafeWriteRegister.writeFMRegister),l
	ld (ix + OPN2OnSFGTurboRPCM.SafeWriteRegister.writeFMRegister + 1),h
	ld hl,OPNFMOnSFG.WriteRegister2
	add hl,bc
	ld (ix + OPN2OnSFGTurboRPCM.SafeWriteRegister2.writeFMRegister),l
	ld (ix + OPN2OnSFGTurboRPCM.SafeWriteRegister2.writeFMRegister + 1),h
	push ix
	ld ixl,c
	ld ixh,b
	ld de,38464
	call OPNFMOnSFG_SetFrequencyOffset
	pop ix
	ret

; ix = this
OPN2OnSFGTurboRPCM_Destruct:
	ret

;
OPN2OnSFGTurboRPCM_name:
	db "SFG + turboR PCM (emu)",0

	SECTION RAM

OPN2OnSFGTurboRPCM_instance: OPN2OnSFGTurboRPCM

	ENDS
