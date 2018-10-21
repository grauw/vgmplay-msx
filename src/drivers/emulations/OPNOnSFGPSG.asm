;
; OPN(A/B) on SFG + PSG driver
;
OPNOnSFGPSG_FREQUENCY: equ 3579545

OPNOnSFGPSG: MACRO
	super: Driver OPNOnSFGPSG_PrintInfoImpl
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

; bc = OPN FM on SFG driver
; de = PSG driver
; ix = this
OPNOnSFGPSG_Construct:
	push bc
	ld bc,OPNOnSFGPSG_name
	call Driver_Construct
	pop bc
	ld (ix + OPNOnSFGPSG.opnFMOnSFGDriver),c
	ld (ix + OPNOnSFGPSG.opnFMOnSFGDriver + 1),b
	ld (ix + OPNOnSFGPSG.psgDriver),e
	ld (ix + OPNOnSFGPSG.psgDriver + 1),d
	ld hl,PSG.SafeWriteRegister
	add hl,de
	ld (ix + OPNOnSFGPSG.WriteRegister.writePSGRegister),l
	ld (ix + OPNOnSFGPSG.WriteRegister.writePSGRegister + 1),h
	ld hl,OPNFMOnSFG.WriteRegister
	add hl,bc
	ld (ix + OPNOnSFGPSG.WriteRegister.writeFMRegister),l
	ld (ix + OPNOnSFGPSG.WriteRegister.writeFMRegister + 1),h
	ld hl,OPNFMOnSFG.WriteRegister2
	add hl,bc
	ld (ix + OPNOnSFGPSG.WriteRegister2.writeFMRegister),l
	ld (ix + OPNOnSFGPSG.WriteRegister2.writeFMRegister + 1),h
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
