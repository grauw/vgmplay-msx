;
; OPN2 on OPNA + turboR PCM driver
;
OPN2OnOPNATurboRPCM_FREQUENCY: equ 7670453
OPN2OnOPNATurboRPCM_FREQUENCY_RATIO: equ (OPN2OnOPNATurboRPCM_FREQUENCY << 8) / (OPNA_FREQUENCY >> 7)

OPN2OnOPNATurboRPCM: MACRO
	super: Driver OPN2OnOPNATurboRPCM_name, OPN2OnOPNATurboRPCM_PrintInfoImpl
	opnaDriver:
		dw 0
	turboRPCMDriver:
		dw 0
	frequencyMSBs:
		ds 12

	; e = register
	; d = value
	SafeWriteRegister: PROC
		ld a,e
		cp 2AH
		jp z,System_Return
	writePCMRegister: equ $ - 2
		cp 0A0H
		jr c,SafeWriteFMRegister
		cp 0A4H
		jr c,WriteFrequencyLSB
		cp 0A8H
		jr c,WriteFrequencyMSB
		cp 0ACH
		jr c,Write3chFrequencyLSB
		cp 0B0H
		jr c,Write3chFrequencyMSB
	SafeWriteFMRegister:
		jp System_Return
	safeWriteFMRegister: equ $ - 2
	WriteFrequencyMSB:
		ld c,a
		ld b,0
		ld hl,-0A4H + frequencyMSBs
		add hl,bc
		ld (hl),d
		ret
	WriteFrequencyLSB:
		push af
		ld c,a
		ld b,0
		ld hl,-0A0H + frequencyMSBs
		add hl,bc
		ld h,(hl)
		ld l,d
		ld bc,OPN2OnOPNATurboRPCM_FREQUENCY_RATIO
		call OPN2OnOPNATurboRPCM_AdjustFrequency
		pop af
		ld h,e
		ld l,a
		push hl
		add a,-0A0H + 0A4H
		call WriteFMRegister
		pop de
		ld a,e
	WriteFMRegister:
		jp System_Return
	writeFMRegister: equ $ - 2
	Write3chFrequencyMSB:
		ld c,a
		ld b,0
		ld hl,-0ACH + frequencyMSBs + 8
		add hl,bc
		ld (hl),d
		ret
	Write3chFrequencyLSB:
		push af
		ld c,a
		ld b,0
		ld hl,-0A8H + frequencyMSBs + 8
		add hl,bc
		ld h,(hl)
		ld l,d
		ld bc,OPN2OnOPNATurboRPCM_FREQUENCY_RATIO
		call OPN2OnOPNATurboRPCM_AdjustFrequency
		pop af
		ld h,e
		ld l,a
		push hl
		add a,-0A8H + 0ACH
		call WriteFMRegister
		pop de
		ld a,e
		jr WriteFMRegister
		ENDP

	; e = register
	; d = value
	SafeWriteRegister2: PROC
		ld a,e
		cp 0A0H
		jr c,SafeWriteFMRegister
		cp 0A4H
		jr c,WriteFrequencyLSB
		cp 0A8H
		jr c,WriteFrequencyMSB
	SafeWriteFMRegister:
		jp System_Return
	safeWriteFMRegister: equ $ - 2
	WriteFrequencyMSB:
		ld c,a
		ld b,0
		ld hl,-0A4H + frequencyMSBs + 4
		add hl,bc
		ld (hl),d
		ret
	WriteFrequencyLSB:
		push af
		ld c,a
		ld b,0
		ld hl,-0A0H + frequencyMSBs + 4
		add hl,bc
		ld h,(hl)
		ld l,d
		ld bc,OPN2OnOPNATurboRPCM_FREQUENCY_RATIO
		call OPN2OnOPNATurboRPCM_AdjustFrequency
		pop af
		ld h,e
		ld l,a
		push hl
		add a,-0A0H + 0A4H
		call WriteFMRegister
		pop de
		ld a,e
	WriteFMRegister:
		jp System_Return
	writeFMRegister: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = drivers
OPN2OnOPNATurboRPCM_Construct: PROC
	call Driver_Construct
	call Drivers_TryCreateOPNA_IY
	ret nc
	push de
	call Drivers_TryCreateTurboRPCM_IY
	pop bc
	jr c,FoundTurboRPCM
	ld de,0
FoundTurboRPCM:
	ld (ix + OPN2OnOPNATurboRPCM.opnaDriver),c
	ld (ix + OPN2OnOPNATurboRPCM.opnaDriver + 1),b
	ld (ix + OPN2OnOPNATurboRPCM.turboRPCMDriver),e
	ld (ix + OPN2OnOPNATurboRPCM.turboRPCMDriver + 1),d
	ld a,e
	or e
	jr z,NoTurboRPCM
	ld hl,TurboRPCM.SafeWriteRegister
	add hl,de
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.writePCMRegister),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.writePCMRegister + 1),h
NoTurboRPCM:
	ld hl,OPNA.SafeWriteRegister
	add hl,bc
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.safeWriteFMRegister),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.safeWriteFMRegister + 1),h
	ld hl,OPNA.WriteRegister
	add hl,bc
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.writeFMRegister),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.writeFMRegister + 1),h
	ld de,128
	add ix,de
	ld hl,OPNA.SafeWriteRegister2
	add hl,bc
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister2.safeWriteFMRegister - 128),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister2.safeWriteFMRegister - 128 + 1),h
	ld hl,OPNA.WriteRegister2
	add hl,bc
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister2.writeFMRegister - 128),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister2.writeFMRegister - 128 + 1),h
	ld de,-128
	add ix,de
	ld de,OPN2OnOPNATurboRPCM_FREQUENCY >> 16
	ld hl,OPN2OnOPNATurboRPCM_FREQUENCY
	jp Driver_SetClock
	ENDP

; ix = this
OPN2OnOPNATurboRPCM_Destruct:
	ret

; bc = multiplier
; hl = old block + fnum
; de <- new block + fnum
OPN2OnOPNATurboRPCM_AdjustFrequency: PROC
	ld a,h
	and 00111000B
	push af
	ld a,h
	and 00000111B
	ld h,a
	call Math_Multiply16x16
	pop af
	bit 2,d
	jr z,NoOverflow
	add a,8
	or d
	ld d,a
	bit 6,a
	ret z
	ld de,3FFFH
	ret
NoOverflow:
	rl h
	rl e
	rl d
	or d
	ld d,a
	ret
	ENDP

; ix = this
OPN2OnOPNATurboRPCM_PrintInfoImpl:
	push ix
	ld e,(ix + OPN2OnOPNATurboRPCM.opnaDriver)
	ld d,(ix + OPN2OnOPNATurboRPCM.opnaDriver + 1)
	ld ixl,e
	ld ixh,d
	call Driver_PrintInfo
	pop ix
	push ix
	ld e,(ix + OPN2OnOPNATurboRPCM.turboRPCMDriver)
	ld d,(ix + OPN2OnOPNATurboRPCM.turboRPCMDriver + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
	call nz,Driver_PrintInfo
	pop ix
	ret

;
OPN2OnOPNATurboRPCM_name:
	db "OPNA + turboR PCM",0

	SECTION RAM

OPN2OnOPNATurboRPCM_instance: OPN2OnOPNATurboRPCM

	ENDS
