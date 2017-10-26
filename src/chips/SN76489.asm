;
; VGM SN76489 chip
;
SN76489: MACRO
	super: Chip SN76489_name, SN76489_Connect

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_Read_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; ix = player
	; iy = reader
	ProcessCommandDual: PROC
		call Reader_Read_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = header
SN76489_Construct:
	ld de,Header.sn76489Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
SN76489_Connect: PROC
	call Drivers_TryCreateMMM_IY
	jr nc,TryPlaySoniq
	call Chip_SetDriver
	ld hl,MMM.SafeWriteRegister
	add hl,de
	ld (ix + SN76489.ProcessCommand.writeRegister),l
	ld (ix + SN76489.ProcessCommand.writeRegister + 1),h
	jr DualChip
TryPlaySoniq:
	call Drivers_TryCreatePlaySoniq_IY
	jr nc,TryFranky
	call Chip_SetDriver
	ld hl,PlaySoniq.SafeWriteRegister
	add hl,de
	ld (ix + SN76489.ProcessCommand.writeRegister),l
	ld (ix + SN76489.ProcessCommand.writeRegister + 1),h
	jr DualChip
TryFranky:
	call Drivers_TryCreateFranky_IY
	ret nc
	call Chip_SetDriver
	ld hl,Franky.SafeWriteRegister
	add hl,de
	ld (ix + SN76489.ProcessCommand.writeRegister),l
	ld (ix + SN76489.ProcessCommand.writeRegister + 1),h
	ret
DualChip:
	call Chip_IsDualChip
	ret z
	call Drivers_TryCreatePlaySoniq_IY
	jr nc,DualChipTryFranky
	call Chip_SetDriver2
	ld hl,PlaySoniq.SafeWriteRegister
	add hl,de
	ld (ix + SN76489.ProcessCommandDual.writeRegister),l
	ld (ix + SN76489.ProcessCommandDual.writeRegister + 1),h
	ret
DualChipTryFranky:
	call Drivers_TryCreateFranky_IY
	ret nc
	call Chip_SetDriver2
	ld hl,Franky.SafeWriteRegister
	add hl,de
	ld (ix + SN76489.ProcessCommandDual.writeRegister),l
	ld (ix + SN76489.ProcessCommandDual.writeRegister + 1),h
	ret
	ENDP

;
	SECTION RAM

SN76489_instance: SN76489

	ENDS

SN76489_name:
	db "SN76489 (DCSG)",0
