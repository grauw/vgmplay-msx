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
	super: Driver Driver_PrintInfoImpl
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
		ret z
		cp MSXAudio_MISC_CONTROL
		jr z,MaskMiscControl
		jr c,WriteRegister
		cp MSXAudio_START_ADDRESS_H + 1
		jr c,WriteStartAddress
		cp MSXAudio_STOP_ADDRESS_H + 1
		jr c,WriteStopAddress
		cp MSXAudio_IO_CONTROL
		jr c,WriteRegister
		cp MSXAudio_PCM_DATA
		jr nc,WriteRegister
		ret
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

	; iy = reader
	ProcessDataBlock:
		ld ix,this
		jp MSXAudio_ProcessDataBlock
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
	ld de,01H << 8 | MSXAudio_ADPCM_CONTROL
	call MSXAudio_WriteRegister  ; reset ADPCM
	ld de,00BDH
	call MSXAudio_WriteRegister  ; rhythm off
	ld b,16H
	ld de,0F80H
	call MSXAudio_FillRegisters  ; max release rate
	ld b,16H
	ld de,3F40H
	call MSXAudio_FillRegisters  ; min total level
	ld b,09H
	ld de,00A0H
	call MSXAudio_FillRegisters  ; frequency 0
	ld b,09H
	ld de,00A0H
	call MSXAudio_FillRegisters  ; key off
	ret

; ix = this
MSXAudio_Reset:
	ld b,0C9H
	ld de,0000H
	call MSXAudio_FillRegisters
	ret

; ix = this
; iy = reader
MSXAudio_ProcessDataBlock: PROC
	call Reader_ReadDoubleWord_IY  ; block size
	push de
	push hl
	call Reader_ReadDoubleWord_IY  ; total rom size
	call Reader_ReadDoubleWord_IY  ; start address
	call MSXAudio_SetADPCMWriteAddress
	pop hl
	pop de
	ld bc,8  ; subtract header from block size
Loop:
	and a
	sbc hl,bc
	ld bc,0
	ex de,hl
	sbc hl,bc
	ex de,hl
	call c,System_ThrowException
	ld a,h
	or l
	or e
	or d
	jr z,Finish
	push de
	push hl
	ld a,d
	or e
	jr z,LessThan64K
	ld hl,0FFFFH
LessThan64K:
	ld c,l
	ld b,h
	call Reader_ReadBlockDirect_IY
	push bc
	call MSXAudio_WriteADPCMData
	pop bc
	pop hl
	pop de
	jp Loop
Finish:
	ld d,01H
	ld e,MSXAudio_ADPCM_CONTROL
	call MSXAudio_WriteRegister
	ret
	ENDP

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
MSXAudio_Detect: PROC
	in a,(MSXAudio_STATUS_PORT)
	and 11111001B
	ret nz
	di
	ld de,10000000B << 8 | MSXAudio_FLAG_CONTROL
	call WriteRegister
	ld de,0FFH << 8 | MSXAudio_TIMER_1
	call WriteRegister
	ld de,00111001B << 8 | MSXAudio_FLAG_CONTROL
	call WriteRegister
	ld b,0  ; wait >80 µs
	djnz $
	in a,(MSXAudio_STATUS_PORT)
	and 11111001B
	push af
	ld de,01111000B << 8 | MSXAudio_FLAG_CONTROL
	call WriteRegister
	ei
	pop af
	sub 11000000B
	and a
	ret nz
	scf
	ret
WriteRegister:
	ld a,e
	out (MSXAudio_ADDRESS_PORT),a
	ld b,8  ; wait 12 cycles
	djnz $
	ld a,d
	out (MSXAudio_DATA_PORT),a
	ld b,8  ; wait 12 cycles
	djnz $
	ret
	ENDP

;
MSXAudio_name:
	db "MSX-AUDIO",0

	SECTION RAM

MSXAudio_instance: MSXAudio

	ENDS
