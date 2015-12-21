;
; VGM K051649 chip
;
K051649: MACRO
	super: Chip K051649_name, K051649_Connect, K051649_Install

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
	Waveform:
		call Reader_ReadWord_IY
		ld a,e
		call 0
	writeRegisterWaveform: equ $ - 2
		jp Player_ProcessNext
	Frequency:
		call Reader_ReadWord_IY
		ld a,SCC_FREQUENCY
		add a,e
		call 0
	writeRegisterFrequency: equ $ - 2
		jp Player_ProcessNext
	Amplitude:
		call Reader_ReadWord_IY
		ld a,SCC_AMPLITUDE
		add a,e
		call 0
	writeRegisterAmplitude: equ $ - 2
		jp Player_ProcessNext
	Mixer:
		call Reader_ReadWord_IY
		ld a,SCC_MIXER
		call 0
	writeRegisterMixer: equ $ - 2
		jp Player_ProcessNext
	WaveformSCCPlus:
		call Reader_ReadWord_IY
		jp Player_ProcessNext
	Deformation:
		call Reader_ReadWord_IY
		ld a,SCC_DEFORMATION
		call 0
	writeRegisterDeformation: equ $ - 2
		jp Player_ProcessNext
		ENDP
	ENDM

; ix = this
; iy = header
K051649_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.k051649Clock - 80H)
	ld h,(iy + Header.k051649Clock - 80H + 1)
	ld e,(iy + Header.k051649Clock - 80H + 2)
	ld d,(iy + Header.k051649Clock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

; iy = drivers
; ix = this
K051649_Connect:
	call Drivers_TryCreateSCC_IY
	ret nc
	ld hl,SCC.WriteRegister
	add hl,de
	ld (ix + K051649.ProcessCommand.writeRegisterWaveform),l
	ld (ix + K051649.ProcessCommand.writeRegisterWaveform + 1),h
	ld (ix + K051649.ProcessCommand.writeRegisterFrequency),l
	ld (ix + K051649.ProcessCommand.writeRegisterFrequency + 1),h
	ld (ix + K051649.ProcessCommand.writeRegisterAmplitude),l
	ld (ix + K051649.ProcessCommand.writeRegisterAmplitude + 1),h
	ld (ix + K051649.ProcessCommand.writeRegisterMixer),l
	ld (ix + K051649.ProcessCommand.writeRegisterMixer + 1),h
	ld (ix + K051649.ProcessCommand.writeRegisterDeformation),l
	ld (ix + K051649.ProcessCommand.writeRegisterDeformation + 1),h
	ret

; iy = player
; ix = this
K051649_Install:
	ld a,(ix + K051649.ProcessCommand.writeRegisterWaveform)
	or (ix + K051649.ProcessCommand.writeRegisterWaveform + 1)
	ret z
	ld hl,K051649.ProcessCommand
	ld a,0D2H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

;
K051649_instance: K051649

K051649_name:
	db "K051649 (SCC)",0
