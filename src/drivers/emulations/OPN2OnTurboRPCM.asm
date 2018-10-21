;
; OPN2 PCM on turboR PCM driver
;
OPN2OnTurboRPCM_FREQUENCY: equ 7670453

OPN2OnTurboRPCM: MACRO
	super: Driver OPN2OnTurboRPCM_PrintInfoImpl
	turboRPCMDriver:
		dw 0

	; e = register
	; d = value
	SafeWriteRegister: PROC
		ld a,e
		cp 2AH
		jp z,System_Return
	writePCMRegister: equ $ - 2
		ret
		ENDP

	; e = register
	; d = value
	SafeWriteRegister2:
		ret
	ENDM

; ix = this
; iy = drivers
OPN2OnTurboRPCM_Construct:
	ld bc,OPN2OnTurboRPCM_name
	call Driver_Construct
	call Drivers_TryCreateTurboRPCM_IY
	ret nc
	ld (ix + OPN2OnTurboRPCM.turboRPCMDriver),e
	ld (ix + OPN2OnTurboRPCM.turboRPCMDriver + 1),d
	ld hl,TurboRPCM.SafeWriteRegister
	add hl,de
	ld (ix + OPN2OnTurboRPCM.SafeWriteRegister.writePCMRegister),l
	ld (ix + OPN2OnTurboRPCM.SafeWriteRegister.writePCMRegister + 1),h
	ld de,OPN2OnTurboRPCM_FREQUENCY >> 16
	ld hl,OPN2OnTurboRPCM_FREQUENCY
	jp Driver_SetClock

; ix = this
OPN2OnTurboRPCM_Destruct:
	ret

; ix = this
OPN2OnTurboRPCM_PrintInfoImpl:
	push ix
	ld e,(ix + OPN2OnTurboRPCM.turboRPCMDriver)
	ld d,(ix + OPN2OnTurboRPCM.turboRPCMDriver + 1)
	ld ixl,e
	ld ixh,d
	call Driver_PrintInfo
	pop ix
	ret

;
OPN2OnTurboRPCM_name:
	db "turboR PCM (emu)",0

	SECTION RAM

OPN2OnTurboRPCM_instance: OPN2OnTurboRPCM

	ENDS
