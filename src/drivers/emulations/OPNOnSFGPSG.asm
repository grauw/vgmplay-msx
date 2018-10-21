;
; OPN(A/B) on SFG + PSG driver
;
OPNOnSFGPSG_FREQUENCY: equ 3579545

OPNOnSFGPSG: MACRO
	super: Driver OPNOnSFGPSG_name, OPNOnSFGPSG_PrintInfoImpl
	opnFMOnSFGDriver:
		dw 0
	psgDriver:
		dw 0

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
	; a = register
	; d = value
	WriteRegister: PROC
		cp 10H
		jp c,System_Return
	writePSGRegister: equ $ - 2
		jp System_Return
	writeFMRegister: equ $ - 2
		ENDP

	; e = register
	; d = value
	SafeWriteRegister2:
		ld a,e
	; a = register
	; d = value
	WriteRegister2: PROC
		jp System_Return
	writeFMRegister: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = drivers
OPNOnSFGPSG_Construct:
	call Driver_Construct
	call Drivers_TryCreateOPNFMOnSFG_IY
	ret nc
	ld (ix + OPNOnSFGPSG.opnFMOnSFGDriver),e
	ld (ix + OPNOnSFGPSG.opnFMOnSFGDriver + 1),d
	ld hl,OPNFMOnSFG.WriteRegister
	add hl,de
	ld (ix + OPNOnSFGPSG.WriteRegister.writeFMRegister),l
	ld (ix + OPNOnSFGPSG.WriteRegister.writeFMRegister + 1),h
	ld hl,OPNFMOnSFG.WriteRegister2
	add hl,de
	ld (ix + OPNOnSFGPSG.WriteRegister2.writeFMRegister),l
	ld (ix + OPNOnSFGPSG.WriteRegister2.writeFMRegister + 1),h
	call Drivers_TryCreatePSG_IY
	ret nc
	ld (ix + OPNOnSFGPSG.psgDriver),e
	ld (ix + OPNOnSFGPSG.psgDriver + 1),d
	ld hl,PSG.SafeWriteRegister
	add hl,de
	ld (ix + OPNOnSFGPSG.WriteRegister.writePSGRegister),l
	ld (ix + OPNOnSFGPSG.WriteRegister.writePSGRegister + 1),h
	ld de,OPNOnSFGPSG_FREQUENCY >> 16
	ld hl,OPNOnSFGPSG_FREQUENCY
	jp Driver_SetClock

; ix = this
OPNOnSFGPSG_Destruct:
	ret

; ix = this
OPNOnSFGPSG_PrintInfoImpl:
	push ix
	ld e,(ix + OPNOnSFGPSG.opnFMOnSFGDriver)
	ld d,(ix + OPNOnSFGPSG.opnFMOnSFGDriver + 1)
	ld ixl,e
	ld ixh,d
	call Driver_PrintInfo
	pop ix
	push ix
	ld e,(ix + OPNOnSFGPSG.psgDriver)
	ld d,(ix + OPNOnSFGPSG.psgDriver + 1)
	ld ixl,e
	ld ixh,d
	call Driver_PrintInfo
	pop ix
	ret

;
OPNOnSFGPSG_name:
	db "SFG + PSG (emu)",0

	SECTION RAM

OPNOnSFGPSG_instance: OPNOnSFGPSG

	ENDS
