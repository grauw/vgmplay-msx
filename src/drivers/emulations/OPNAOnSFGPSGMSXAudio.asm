;
; OPNA on SFG + PSG + MSX-AUDIO driver
;
OPNAOnSFGPSGMSXAudio_CLOCK: equ 3579545

OPNAOnSFGPSGMSXAudio: MACRO
	super: Driver OPNAOnSFGPSGMSXAudio_name, OPNAOnSFGPSGMSXAudio_PrintInfoImpl
	opnOnSFGPSGDriver:
		dw 0
	msxAudioDriver:
		dw 0

	; e = register
	; d = value
	SafeWriteRegister: PROC
		jp System_Return
	safeWriteRegister: equ $ - 2
		ENDP

	; e = register
	; d = value
	SafeWriteRegister2: PROC
		ld a,e
		cp 0CH
		jp nc,System_Return
	safeWriteRegister: equ $ - 2
	ADPCM:
		cp 01H
		call z,MaskMiscControl
		add a,07H
		ld e,a
		jp System_Return
	safeWriteADPCMRegister: equ $ - 2
	MaskMiscControl:
		ld a,d
		and 00001111B
		bit 0,a
		jr nz,No8bitRAM
		bit 1,a
		jr z,No8bitRAM
		res 1,a
		set 0,a
	No8bitRAM:
		ld d,a
		ld a,e
		ret
		ENDP

	; dehl = size
	; ix = player
	; iy = reader
	ProcessDataBlock: PROC
		jp Player_SkipDataBlock
	process: equ $ - 2
		ENDP
	ENDM

; ix = this
; iy = drivers
OPNAOnSFGPSGMSXAudio_Construct: PROC
	call Driver_Construct
	call Drivers_TryCreateOPNOnSFGPSG_IY
	ret nc
	ld (ix + OPNAOnSFGPSGMSXAudio.opnOnSFGPSGDriver),e
	ld (ix + OPNAOnSFGPSGMSXAudio.opnOnSFGPSGDriver + 1),d
	ld hl,OPNOnSFGPSG.SafeWriteRegister
	add hl,de
	ld (ix + OPNAOnSFGPSGMSXAudio.SafeWriteRegister.safeWriteRegister),l
	ld (ix + OPNAOnSFGPSGMSXAudio.SafeWriteRegister.safeWriteRegister + 1),h
	ld hl,OPNOnSFGPSG.SafeWriteRegister2
	add hl,de
	ld (ix + OPNAOnSFGPSGMSXAudio.SafeWriteRegister2.safeWriteRegister),l
	ld (ix + OPNAOnSFGPSGMSXAudio.SafeWriteRegister2.safeWriteRegister + 1),h
	call Drivers_TryCreateMSXAudio_IY
	jr nc,NoMSXAudio
	ld (ix + OPNAOnSFGPSGMSXAudio.msxAudioDriver),e
	ld (ix + OPNAOnSFGPSGMSXAudio.msxAudioDriver + 1),d
	ld hl,MSXAudio.SafeWriteRegister
	add hl,de
	ld (ix + OPNAOnSFGPSGMSXAudio.SafeWriteRegister2.safeWriteADPCMRegister),l
	ld (ix + OPNAOnSFGPSGMSXAudio.SafeWriteRegister2.safeWriteADPCMRegister + 1),h
	ld hl,MSXAudio.ProcessDataBlock
	add hl,de
	ld (ix + OPNAOnSFGPSGMSXAudio.ProcessDataBlock.process),l
	ld (ix + OPNAOnSFGPSGMSXAudio.ProcessDataBlock.process + 1),h
NoMSXAudio:
	ld de,OPNAOnSFGPSGMSXAudio_CLOCK >> 16
	ld hl,OPNAOnSFGPSGMSXAudio_CLOCK
	jp Driver_SetClock
	ENDP

; ix = this
OPNAOnSFGPSGMSXAudio_Destruct: equ System_Return
;	ret

; ix = this
OPNAOnSFGPSGMSXAudio_PrintInfoImpl:
	ld de,OPNAOnSFGPSGMSXAudio.opnOnSFGPSGDriver
	call Driver_PrintInfoIXOffset
	ld de,OPNAOnSFGPSGMSXAudio.msxAudioDriver
	jp Driver_PrintInfoIXOffset

;
OPNAOnSFGPSGMSXAudio_name:
	db "SFG + PSG + MSX-AUDIO (emu)",0

	SECTION RAM

OPNAOnSFGPSGMSXAudio_instance: OPNAOnSFGPSGMSXAudio

	ENDS
