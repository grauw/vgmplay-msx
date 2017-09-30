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
	SafeWriteRegister:
		ld a,e
	; a = register
	; d = value
	WriteRegister: PROC
		cp 20H
		jp c,0
	writePSGRegister: equ $ - 2
		jp 0
	writeFMRegister: equ $ - 2
		ENDP
	ENDM

; bc = OPN FM on SFG driver
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
	ld (ix + OPNOnSFGPSG.WriteRegister.writePSGRegister),l
	ld (ix + OPNOnSFGPSG.WriteRegister.writePSGRegister + 1),h
	ld hl,OPNFMOnSFG.WriteRegister
	add hl,bc
	ld (ix + OPNOnSFGPSG.WriteRegister.writeFMRegister),l
	ld (ix + OPNOnSFGPSG.WriteRegister.writeFMRegister + 1),h
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
