;
; OPNB-B on Neotron + OPNA driver
;
OPNBBOnNeotronOPNA_FREQUENCY: equ 8000000

OPNBBOnNeotronOPNA: MACRO
	super: Driver OPNBBOnNeotronOPNA_name, OPNBBOnNeotronOPNA_PrintInfoImpl
	neotronDriver:
		dw 0
	opnaDriver:
		dw 0

	; e = register
	; d = value
	SafeWriteRegister: PROC
		ld a,e
		cp 20H
		jp c,System_Return
	safeWriteADPCMRegister: equ $ - 2
		jp System_Return
	safeWriteFMRegister: equ $ - 2
		ENDP

	; e = register
	; d = value
	SafeWriteRegister2: PROC
		ld a,e
		cp 30H
		jp c,System_Return
	safeWriteADPCMRegister: equ $ - 2
	ADPCM:
		jp System_Return
	safeWriteFMRegister: equ $ - 2
		ENDP

	; dehl = size
	; ix = player
	; iy = reader
	ProcessDataBlockA: PROC
		jp Player_SkipDataBlock
	process: equ $ - 2
		ENDP

	; dehl = size
	; ix = player
	; iy = reader
	ProcessDataBlockB: PROC
		jp Player_SkipDataBlock
	process: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = drivers
OPNBBOnNeotronOPNA_Construct: PROC
	call Driver_Construct
	call Drivers_TryCreateNeotron_IY
	ret nc
	ld (ix + OPNBBOnNeotronOPNA.neotronDriver),e
	ld (ix + OPNBBOnNeotronOPNA.neotronDriver + 1),d
	ld hl,Neotron.SafeWriteRegister
	add hl,de
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister.safeWriteADPCMRegister),l
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister.safeWriteADPCMRegister + 1),h
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister.safeWriteFMRegister),l
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister.safeWriteFMRegister + 1),h
	ld hl,Neotron.SafeWriteRegister2
	add hl,de
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister2.safeWriteADPCMRegister),l
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister2.safeWriteADPCMRegister + 1),h
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister2.safeWriteFMRegister),l
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister2.safeWriteFMRegister + 1),h
	ld hl,Neotron.ProcessDataBlockA
	add hl,de
	ld (ix + OPNBBOnNeotronOPNA.ProcessDataBlockA.process),l
	ld (ix + OPNBBOnNeotronOPNA.ProcessDataBlockA.process + 1),h
	ld hl,Neotron.ProcessDataBlockB
	add hl,de
	ld (ix + OPNBBOnNeotronOPNA.ProcessDataBlockB.process),l
	ld (ix + OPNBBOnNeotronOPNA.ProcessDataBlockB.process + 1),h
	call Drivers_TryCreateOPNA_IY
	jr nc,NoOPNA
	ld (ix + OPNBBOnNeotronOPNA.opnaDriver),e
	ld (ix + OPNBBOnNeotronOPNA.opnaDriver + 1),d
	ld hl,OPNA.SafeWriteRegister
	add hl,de
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister.safeWriteFMRegister),l
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister.safeWriteFMRegister + 1),h
	ld hl,OPNA.SafeWriteRegister2
	add hl,de
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister2.safeWriteFMRegister),l
	ld (ix + OPNBBOnNeotronOPNA.SafeWriteRegister2.safeWriteFMRegister + 1),h
NoOPNA:
	ld de,OPNBBOnNeotronOPNA_FREQUENCY >> 16
	ld hl,OPNBBOnNeotronOPNA_FREQUENCY
	jp Driver_SetClock
	ENDP

; ix = this
OPNBBOnNeotronOPNA_Destruct: equ System_Return
;	ret

; ix = this
OPNBBOnNeotronOPNA_PrintInfoImpl:
	push ix
	ld e,(ix + OPNBBOnNeotronOPNA.neotronDriver)
	ld d,(ix + OPNBBOnNeotronOPNA.neotronDriver + 1)
	ld ixl,e
	ld ixh,d
	call Driver_PrintInfo
	pop ix
	push ix
	ld e,(ix + OPNBBOnNeotronOPNA.opnaDriver)
	ld d,(ix + OPNBBOnNeotronOPNA.opnaDriver + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
	call nz,Driver_PrintInfo
	pop ix
	ret

;
OPNBBOnNeotronOPNA_name:
	db "Neotron + OPNA (emu)",0

	SECTION RAM

OPNBBOnNeotronOPNA_instance: OPNBBOnNeotronOPNA

	ENDS
