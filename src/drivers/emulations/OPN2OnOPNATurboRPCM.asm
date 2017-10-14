;
; OPN2 PCM on OPNA + turboR PCM driver
;
OPN2OnOPNATurboRPCM_FREQUENCY: equ 7670453
OPN2OnOPNATurboRPCM_FREQUENCY_RATIO: equ (OPN2OnOPNATurboRPCM_FREQUENCY << 8) / (OPNA_FREQUENCY >> 7)

OPN2OnOPNATurboRPCM: MACRO
	super: Driver
	frequencyMSBs:
		ds 8

	; e = register
	; d = value
	SafeWriteRegister: PROC
		ld a,e
		cp 2AH
		jp z,0
	writePCMRegister: equ $ - 2
		cp 0A0H
		jr c,SafeWriteFMRegister
		cp 0A4H
		jr c,WriteFrequencyLSB
		cp 0A8H
		jr c,WriteFrequencyMSB
	SafeWriteFMRegister:
		jp 0
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
		ld l,e
		ld h,a
		push hl
		add a,-0A0H + 0A4H
		call WriteFMRegister
		pop hl
		ld d,l
		ld a,h
	WriteFMRegister:
		jp 0
	writeFMRegister: equ $ - 2
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
		jp 0
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
		ld l,e
		ld h,a
		push hl
		add a,-0A0H + 0A4H
		call WriteFMRegister
		pop hl
		ld d,l
		ld a,h
	WriteFMRegister:
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
	ld hl,OPNA.SafeWriteRegister
	add hl,bc
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.safeWriteFMRegister),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.safeWriteFMRegister + 1),h
	ld hl,OPNA.WriteRegister
	add hl,bc
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.writeFMRegister),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister.writeFMRegister + 1),h
	ld hl,OPNA.SafeWriteRegister2
	add hl,bc
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister2.safeWriteFMRegister),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister2.safeWriteFMRegister + 1),h
	ld hl,OPNA.WriteRegister2
	add hl,bc
	ld bc,128
	add ix,bc
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister2.writeFMRegister - 128),l
	ld (ix + OPN2OnOPNATurboRPCM.SafeWriteRegister2.writeFMRegister - 128 + 1),h
	ld bc,-128
	add ix,bc
	ret

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

;
OPN2OnOPNATurboRPCM_name:
	db "OPNA + turboR PCM",0

	SECTION RAM

OPN2OnOPNATurboRPCM_instance: OPN2OnOPNATurboRPCM

	ENDS
