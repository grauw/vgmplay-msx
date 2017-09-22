;
; OPN on SFG + PSG driver
;
OPNOnSFGPSG_PCM_REGISTER: equ 2AH
OPNOnSFGPSG_FREQUENCY: equ 3579545

OPNOnSFGPSG: MACRO
	super: Driver
	frequencies:
		ds 7
	alignedFrequencies: equ (frequencies + 3) & 0FFFCH

	; e = register
	; d = value
	SafeWriteRegister: PROC
		ld a,e
		cp 20H
		jp c,0
	writePSGRegister: equ $ - 2
		cp 21H
		jr z,WriteTest
		cp 28H
		jr z,WriteKeyOnOff
		cp 30H
		ret c
		cp 090H
		jr c,WriteSlots
		cp 0A0H
		jr nc,WriteChannels
		ret
	WriteSFGRegister:
		jp 0
	writeSFGRegister: equ $ - 2
	WriteTest:
		add a,-20H
		jr WriteSFGRegister
	WriteKeyOnOff:
		ld a,d
		and 07H
		ld b,a
		ld a,d
		and 0F0H
		rrca
		or b
		ld d,a
		ld a,8
		jr WriteSFGRegister
	WriteSlots:
		and 03H
		ld b,a
		ld a,e
		add a,-30H
		and 0FCH
		add a,a
		or b
		add a,40H
		jr WriteSFGRegister
	WriteChannels:
		cp 0A4H
		jr c,WriteFrequencyLSB
		cp 0A8H
		jr c,WriteFrequencyMSB
		cp 0B0H
		ret c
		cp 0B4H
		jr c,WriteFBConnect
		cp 0B8H
		jr c,WritePMSAMSLR
		ret
	WriteFrequencyMSB:
		add a,-0A4H + alignedFrequencies
		ld l,a
		ld h,alignedFrequencies >> 8
		ld (hl),d
		ret
	WriteFrequencyLSB:
		add a,-0A0H + alignedFrequencies
		ld l,a
		ld h,alignedFrequencies >> 8
		ld e,(hl)
		call OPNOnSFGPSG_FrequencyToKey
		ld d,c
		ld a,l
		and 03H
		ld c,a
		push bc
		or 30H
		call WriteSFGRegister
		pop bc
		ld d,b
		ld a,c
		or 28H
		jr WriteSFGRegister
	WriteFBConnect:
		add a,-0B0H + 20H
		set 6,d
		set 7,d
		jr WriteSFGRegister
	WritePMSAMSLR:
		add a,-0B4H + 38H
		jr WriteSFGRegister
		ENDP
	ENDM

; bc = SFG driver
; de = PSG driver
; ix = this
OPNOnSFGPSG_Construct:
	push bc
	push de
	ld bc,OPNOnSFGPSG_name
	ld de,OPNOnSFGPSG_FREQUENCY >> 16
	ld hl,OPNOnSFGPSG_FREQUENCY
	call Driver_Construct
	pop de
	pop bc
	ld hl,PSG.SafeWriteRegister
	add hl,de
	ld (ix + OPNOnSFGPSG.SafeWriteRegister.writePSGRegister),l
	ld (ix + OPNOnSFGPSG.SafeWriteRegister.writePSGRegister + 1),h
	ld hl,SFG.WriteRegister
	add hl,bc
	ld (ix + OPNOnSFGPSG.SafeWriteRegister.writeSFGRegister),l
	ld (ix + OPNOnSFGPSG.SafeWriteRegister.writeSFGRegister + 1),h
	ret

; d = f-number LSB
; e = block + f-number MSB
; b <- key code
; c <- key fraction
OPNOnSFGPSG_FrequencyToKey:
	ld c,d
	ld b,e
	rl c
	sla b
	ret

; ix = this
OPNOnSFGPSG_Destruct:
	ret

;
OPNOnSFGPSG_name:
	db "SFG + PSG (emu)",0

	SECTION RAM

OPNOnSFGPSG_instance: OPNOnSFGPSG

	ENDS
