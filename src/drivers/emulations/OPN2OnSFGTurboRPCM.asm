;
; OPN2 on SFG + turboR PCM driver
;
OPN2OnSFGTurboRPCM_FREQUENCY: equ 7670453

OPN2OnSFGTurboRPCM: MACRO
	super: Driver OPN2OnSFGTurboRPCM_PrintInfoImpl
	opnFMOnSFGDriver:
		dw 0
	turboRPCMDriver:
		dw 0

	; e = register
	; d = value
	SafeWriteRegister: PROC
		ld a,e
		cp 2AH
		jp z,System_Return
	writePCMRegister: equ $ - 2
		jp System_Return
	writeFMRegister: equ $ - 2
		ENDP

	; e = register
	; d = value
	SafeWriteRegister2: PROC
		ld a,e
		jp System_Return
	writeFMRegister: equ $ - 2
		ENDP
	ENDM

; bc = OPN on SFG driver
; de = TurboR PCM driver
; ix = this
OPN2OnSFGTurboRPCM_Construct: PROC
	push bc
	ld bc,OPN2OnSFGTurboRPCM_name
	call Driver_Construct
	pop bc
	ld (ix + OPN2OnSFGTurboRPCM.opnFMOnSFGDriver),c
	ld (ix + OPN2OnSFGTurboRPCM.opnFMOnSFGDriver + 1),b
	ld (ix + OPN2OnSFGTurboRPCM.turboRPCMDriver),e
	ld (ix + OPN2OnSFGTurboRPCM.turboRPCMDriver + 1),d
	ld a,e
	or d
	jr z,NoTurboRPCM
	ld hl,TurboRPCM.SafeWriteRegister
	add hl,de
	ld (ix + OPN2OnSFGTurboRPCM.SafeWriteRegister.writePCMRegister),l
	ld (ix + OPN2OnSFGTurboRPCM.SafeWriteRegister.writePCMRegister + 1),h
NoTurboRPCM:
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
	ld de,OPN2OnSFGTurboRPCM_FREQUENCY >> 16
	ld hl,OPN2OnSFGTurboRPCM_FREQUENCY
	jp Driver_SetClock
	ENDP

; ix = this
OPN2OnSFGTurboRPCM_Destruct:
	ret

; ix = this
OPN2OnSFGTurboRPCM_PrintInfoImpl:
	push ix
	ld e,(ix + OPN2OnSFGTurboRPCM.opnFMOnSFGDriver)
	ld d,(ix + OPN2OnSFGTurboRPCM.opnFMOnSFGDriver + 1)
	ld ixl,e
	ld ixh,d
	call Driver_PrintInfo
	pop ix
	push ix
	ld e,(ix + OPN2OnSFGTurboRPCM.turboRPCMDriver)
	ld d,(ix + OPN2OnSFGTurboRPCM.turboRPCMDriver + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
	call nz,Driver_PrintInfo
	pop ix
	ret

;
OPN2OnSFGTurboRPCM_name:
	db "SFG + turboR PCM (emu)",0

	SECTION RAM

OPN2OnSFGTurboRPCM_instance: OPN2OnSFGTurboRPCM

	ENDS
