;
; VGM K051649 chip
;
K051649: MACRO
	super: Chip K051649_k051649Name, K051649_Connect, K051649_Install

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_Read_IY
		cp 1
		jr c,Waveform
		jr z,Frequency
		cp 3
		jr c,Amplitude
		jr z,Mixer
		cp 5
		jr c,WaveformSCCPlus
		jr z,Deformation
		call Reader_ReadWord_IY
		jp Player_ProcessNext
	Waveform: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	Frequency: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	Amplitude: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	Mixer: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	WaveformSCCPlus: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	Deformation: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
		ENDP
	ENDM

; ix = this
; iy = header
K051649_Construct:
	ld de,Header.k051649Clock
	call Chip_Construct
	call K051649_IsSCCPlus
	ret z
	ld hl,K051649_k052539Name
	call Chip_SetName
	ret

; ix = this
; f <- nz: SCC+
K051649_IsSCCPlus:
	bit 7,(ix + K051649.super.clock + 3)
	ret

; iy = drivers
; ix = this
K051649_Connect: PROC
	call Drivers_TryCreateSCCPlus_IY
	jr nc,SCC
	call Chip_SetDriver
	ld hl,SCCPlus.WriteWaveformSCCCompatible
	add hl,de
	ld (ix + K051649.ProcessCommand.Waveform.writeRegister),l
	ld (ix + K051649.ProcessCommand.Waveform.writeRegister + 1),h
	ld hl,SCCPlus.WriteWaveform
	add hl,de
	ld (ix + K051649.ProcessCommand.WaveformSCCPlus.writeRegister),l
	ld (ix + K051649.ProcessCommand.WaveformSCCPlus.writeRegister + 1),h
	ld hl,SCCPlus.WriteFrequency
	add hl,de
	ld (ix + K051649.ProcessCommand.Frequency.writeRegister),l
	ld (ix + K051649.ProcessCommand.Frequency.writeRegister + 1),h
	ld hl,SCCPlus.WriteAmplitude
	add hl,de
	ld (ix + K051649.ProcessCommand.Amplitude.writeRegister),l
	ld (ix + K051649.ProcessCommand.Amplitude.writeRegister + 1),h
	ld hl,SCCPlus.WriteMixer
	add hl,de
	ld (ix + K051649.ProcessCommand.Mixer.writeRegister),l
	ld (ix + K051649.ProcessCommand.Mixer.writeRegister + 1),h
	ld hl,SCCPlus.WriteDeformation
	add hl,de
	ld (ix + K051649.ProcessCommand.Deformation.writeRegister),l
	ld (ix + K051649.ProcessCommand.Deformation.writeRegister + 1),h
	ret
SCC:
	call K051649_IsSCCPlus
	ret nz
	call Drivers_TryCreateSCC_IY
	ret nc
	call Chip_SetDriver
	ld hl,SCC.WriteWaveform
	add hl,de
	ld (ix + K051649.ProcessCommand.Waveform.writeRegister),l
	ld (ix + K051649.ProcessCommand.Waveform.writeRegister + 1),h
	ld (ix + K051649.ProcessCommand.WaveformSCCPlus.writeRegister),System_ThrowException
	ld (ix + K051649.ProcessCommand.WaveformSCCPlus.writeRegister + 1),System_ThrowException >> 8
	ld hl,SCC.WriteFrequency
	add hl,de
	ld (ix + K051649.ProcessCommand.Frequency.writeRegister),l
	ld (ix + K051649.ProcessCommand.Frequency.writeRegister + 1),h
	ld hl,SCC.WriteAmplitude
	add hl,de
	ld (ix + K051649.ProcessCommand.Amplitude.writeRegister),l
	ld (ix + K051649.ProcessCommand.Amplitude.writeRegister + 1),h
	ld hl,SCC.WriteMixer
	add hl,de
	ld (ix + K051649.ProcessCommand.Mixer.writeRegister),l
	ld (ix + K051649.ProcessCommand.Mixer.writeRegister + 1),h
	ld hl,SCC.WriteDeformation
	add hl,de
	ld (ix + K051649.ProcessCommand.Deformation.writeRegister),l
	ld (ix + K051649.ProcessCommand.Deformation.writeRegister + 1),h
	ret
	ENDP

; iy = player
; ix = this
K051649_Install:
	ld hl,K051649.ProcessCommand
	ld a,0D2H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
	SECTION RAM

K051649_instance: K051649

	ENDS

K051649_k051649Name:
	db "K051649 (SCC)",0

K051649_k052539Name:
	db "K052539 (SCC+)",0
