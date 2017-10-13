;
; Y8950 MSX-AUDIO driver
;

; ports
MSXAudio_STATUS_PORT: equ 0C0H
MSXAudio_ADDRESS_PORT: equ 0C0H
MSXAudio_DATA_PORT: equ 0C1H
MSXAudio_FREQUENCY: equ 3579545

; registers
MSXAudio_TEST: equ 01H
MSXAudio_TIMER_1: equ 02H
MSXAudio_TIMER_2: equ 03H
MSXAudio_FLAG_CONTROL: equ 04H
MSXAudio_KEYBOARD_IN: equ 05H
MSXAudio_KEYBOARD_OUT: equ 06H
MSXAudio_ADPCM_CONTROL: equ 07H
MSXAudio_MISC_CONTROL: equ 08H
MSXAudio_START_ADDRESS_L: equ 09H
MSXAudio_START_ADDRESS_H: equ 0AH
MSXAudio_STOP_ADDRESS_L: equ 0BH
MSXAudio_STOP_ADDRESS_H: equ 0CH
MSXAudio_PRESCALE_L: equ 0DH
MSXAudio_PRESCALE_H: equ 0EH
MSXAudio_ADPCM_DATA: equ 0FH
MSXAudio_DELTA_N_L: equ 10H
MSXAudio_DELTA_N_H: equ 11H
MSXAudio_ENVELOPE_CONTROL: equ 12H
MSXAudio_DAC_DATA_L: equ 15H
MSXAudio_DAC_DATA_H: equ 16H
MSXAudio_DAC_DATA_SHIFT: equ 17H
MSXAudio_IO_CONTROL: equ 18H
MSXAudio_IO_DATA: equ 19H
MSXAudio_PCM_DATA: equ 1AH
MSXAudio_FM_BASE: equ 20H

MSXAudio: MACRO
	this:
	super: Driver
	safeControlMirror:
		ds MSXAudio_FM_BASE

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp MSXAudio_FM_BASE
		jr c,MaskControl
	; a = register
	; d = value
	WriteRegister:
		out (MSXAudio_ADDRESS_PORT),a
		in a,(MSXAudio_STATUS_PORT)  ; wait 12 cycles
		ld a,(hl)                    ;  "
		ld a,d
		out (MSXAudio_DATA_PORT),a
		in a,(09AH)  ; R800 wait: ~72 cycles
		in a,(09AH)
		ret
	MaskControl:
		ld hl,safeControlMirror
		ld c,a
		ld b,0
		add hl,bc
		ld (hl),d
		cp MSXAudio_FLAG_CONTROL
		jr z,MaskFlagControl
		cp MSXAudio_MISC_CONTROL
		jr z,MaskMiscControl
		jr c,WriteRegister
		cp MSXAudio_START_ADDRESS_H + 1
		jr c,WriteStartAddress
		cp MSXAudio_STOP_ADDRESS_H + 1
		jr c,WriteStopAddress
		jr WriteRegister
	MaskFlagControl:
		ld a,d
		and 00000111B
		or 01111000B
		ld d,a
		ld a,e
		jr WriteRegister
	MaskMiscControl:
		ld a,d
		and 11000100B
		ld d,a
		ld a,e
		jr WriteRegister
	WriteStartAddress:
		ld hl,safeControlMirror + MSXAudio_MISC_CONTROL
		bit 0,(hl)
		jr z,WriteRegister
		ld hl,(safeControlMirror + MSXAudio_START_ADDRESS_L)
		add hl,hl
		add hl,hl
		add hl,hl
		ld d,l
		ld a,MSXAudio_START_ADDRESS_L
		call WriteRegister
		ld d,h
		ld a,MSXAudio_START_ADDRESS_H
		jr WriteRegister
	WriteStopAddress:
		ld hl,safeControlMirror + MSXAudio_MISC_CONTROL
		bit 0,(hl)
		jr z,WriteRegister
		ld hl,(safeControlMirror + MSXAudio_STOP_ADDRESS_L)
		add hl,hl
		add hl,hl
		add hl,hl
		ld a,l
		or 00000111B
		ld d,a
		ld a,MSXAudio_STOP_ADDRESS_L
		call WriteRegister
		ld d,h
		ld a,MSXAudio_STOP_ADDRESS_H
		jr WriteRegister

	; bc = count
	; hl = source
	WriteADPCMData: PROC
		di
		ld d,70H
		ld a,MSXAudio_FLAG_CONTROL
		call WriteRegister
		dec bc
		inc b
		inc c
		ld e,b
		ld b,c
		ld c,MSXAudio_DATA_PORT
		ld a,MSXAudio_ADPCM_DATA
		out (MSXAudio_ADDRESS_PORT),a  ; wait 12 cycles after
		jr Wait
	Next:
		in a,(MSXAudio_STATUS_PORT)  ; wait 12 cycles
		ld a,MSXAudio_FLAG_CONTROL
		out (MSXAudio_ADDRESS_PORT),a
		in a,(MSXAudio_STATUS_PORT)  ; wait 12 cycles
		ld a,(hl)                    ;  "
		ld a,80H
		out (MSXAudio_DATA_PORT),a
		in a,(MSXAudio_STATUS_PORT)  ; wait 12 cycles
		ld a,(hl)                    ;  "
		ld a,MSXAudio_ADPCM_DATA
		out (MSXAudio_ADDRESS_PORT),a  ; wait 12 cycles after
	Wait:
		in a,(MSXAudio_STATUS_PORT)
		and 00001000B
		jr z,Wait
		outi
		jr nz,Next
		dec e
		jr nz,Next
		ld d,78H
		ld a,MSXAudio_FLAG_CONTROL
		call WriteRegister
		ei
		ret
		ENDP
	ENDM

; ix = this
MSXAudio_Construct:
	ld bc,MSXAudio_name
	ld de,MSXAudio_FREQUENCY >> 16
	ld hl,MSXAudio_FREQUENCY
	call Driver_Construct
	call MSXAudio_Reset
	ret

; ix = this
MSXAudio_Destruct:
	call MSXAudio_Mute
	call MSXAudio_Reset
	ret

; e = register
; d = value
; ix = this
MSXAudio_WriteRegister:
	ld a,e
	ld bc,MSXAudio.WriteRegister
	jp Utils_JumpIXOffsetBC

; e = register
; d = value
; ix = this
MSXAudio_SafeWriteRegister:
	ld bc,MSXAudio.SafeWriteRegister
	jp Utils_JumpIXOffsetBC

; b = count
; e = register base
; d = value
; ix = this
MSXAudio_FillRegisters:
	push bc
	push de
	call MSXAudio_SafeWriteRegister
	in a,(09AH)  ; R800 wait: ~62 cycles - 5 (ret)
	pop de
	pop bc
	inc e
	djnz MSXAudio_FillRegisters
	ret

; ix = this
MSXAudio_Mute:
	ld b,16H
	ld de,3F40H
	call MSXAudio_FillRegisters
	ret

; ix = this
MSXAudio_Reset:
	call MSXAudio_Mute
	ld b,040H
	ld de,0000H
	call MSXAudio_FillRegisters
	ld b,069H
	ld de,0060H
	call MSXAudio_FillRegisters
	ret

; ehl = write address
; ix = this
MSXAudio_SetADPCMWriteAddress:
	srl e
	rr h
	rr l
	jp c,System_ThrowException
	srl e
	rr h
	rr l
	jp c,System_ThrowException
	ld a,e
	or d
	jp nz,System_ThrowException
	push hl
	ld d,l
	ld e,MSXAudio_START_ADDRESS_L
	call MSXAudio_WriteRegister
	pop hl
	ld d,h
	ld e,MSXAudio_START_ADDRESS_H
	call MSXAudio_WriteRegister
	ld d,0FFH
	ld e,MSXAudio_STOP_ADDRESS_L
	call MSXAudio_WriteRegister
	ld d,07FH
	ld e,MSXAudio_STOP_ADDRESS_H
	call MSXAudio_WriteRegister
	ld d,01H
	ld e,MSXAudio_ADPCM_CONTROL
	call MSXAudio_WriteRegister
	ld d,60H
	ld e,MSXAudio_ADPCM_CONTROL
	call MSXAudio_WriteRegister
	ret

; bc = count
; hl = source
; ix = this
MSXAudio_WriteADPCMData:
	ld de,MSXAudio.WriteADPCMData
	jp Utils_JumpIXOffsetDE

; f <- c: found
MSXAudio_Detect:
	in a,(MSXAudio_STATUS_PORT)
	sub 06H
	and a
	ret nz
	scf
	ret

;
MSXAudio_name:
	db "MSX-AUDIO",0

	SECTION RAM

MSXAudio_instance: MSXAudio

	ENDS
