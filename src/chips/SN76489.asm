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
SN76489_Connect:
	call SN76489_TryCreate
	ret nc
	call Chip_SetDriver
	add hl,de
	ld (ix + SN76489.ProcessCommand.writeRegister),l
	ld (ix + SN76489.ProcessCommand.writeRegister + 1),h
	call Chip_IsDualChip
	ret z
	call SN76489_TryCreate
	ret nc
	call Chip_SetDriver2
	add hl,de
	ld (ix + SN76489.ProcessCommandDual.writeRegister),l
	ld (ix + SN76489.ProcessCommandDual.writeRegister + 1),h
	ret

; iy = drivers
; ix = this
; de <- driver
; hl <- safe write register offset
; f <- c: succeeded
SN76489_TryCreate:
	call Drivers_TryCreateMMM_IY
	ld hl,MMM.SafeWriteRegister
	ret c
	call Drivers_TryCreatePlaySoniq_IY
	ld hl,PlaySoniq.SafeWriteRegister
	ret c
	call Drivers_TryCreateFranky_IY
	ld hl,Franky.SafeWriteRegister
	ret

;
	SECTION RAM

SN76489_instance: SN76489

	ENDS

SN76489_name:
	db "SN76489 (DCSG)",0
