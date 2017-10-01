;
; OPN2 PCM on OPNA + turboR PCM driver
;
OPN2OnOPNATurboRPCM_FREQUENCY: equ 7670453

OPN2OnOPNATurboRPCM: MACRO
	super: Driver

	; e = register
	; d = value
	SafeWriteRegister: PROC
		ld a,e
		cp 2AH
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

; bc = OPNA driver
; de = TurboR PCM driver
; ix = this
OPN2OnOPNATurboRPCM_Construct:
	push bc
	push de
	ld bc,OPN2OnOPNATurboRPCM_name
	ld de,OPN2OnOPNATurboRPCM_FREQUENCY >> 16
	ld hl,OPN2OnOPNATurboRPCM_FREQUENCY
	call Driver_Construct
	pop de
	pop bc
	ld hl,TurboRPCM.SafeWriteRegister
	add hl,de
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.writePCMRegister),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.writePCMRegister + 1),h
	ld hl,OPNA.WriteRegister
	add hl,bc
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.writeFMRegister),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.writeFMRegister + 1),h
	ld hl,OPNA.WriteRegister2
	add hl,bc
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister2.writeFMRegister),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister2.writeFMRegister + 1),h
	ret

; ix = this
OPN2OnOPNATurboRPCM_Destruct:
	ret

;
OPN2OnOPNATurboRPCM_name:
	db "OPNA + turboR PCM",0

	SECTION RAM

OPN2OnOPNATurboRPCM_instance: OPN2OnOPNATurboRPCM

	ENDS
