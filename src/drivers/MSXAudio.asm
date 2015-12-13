;
; Y8950 MSX-AUDIO driver
;

; ports
MSXAudio_STATUS_PORT: equ 0C0H
MSXAudio_ADDRESS_PORT: equ 0C0H
MSXAudio_DATA_PORT: equ 0C1H

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
		push hl  ; wait 11 cycles (12 officially)
		pop hl
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
		ld d,00H
		ld a,MSXAudio_FLAG_CONTROL
		call WriteRegister
		dec bc
		inc b
		inc c
		ld e,b
		ld b,c
		ld c,MSXAudio_DATA_PORT
		jr Wait
	Next:
		ld d,80H
		ld a,MSXAudio_FLAG_CONTROL
		call WriteRegister
	Wait:
		in a,(MSXAudio_STATUS_PORT)
		bit 3,a
		jr z,Wait
		ld a,MSXAudio_ADPCM_DATA
		out (MSXAudio_ADDRESS_PORT),a
		push hl  ; wait 12 cycles
		pop hl
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

	; ix = player
	; iy = reader
	ProcessY8950Command:
		call Reader_ReadWord_IY
		call SafeWriteRegister
		jp Player_ProcessNext

	; ix = player
	; iy = reader
	ProcessYM3526Command:
		call Reader_ReadWord_IY
		call SafeWriteRegister
		jp Player_ProcessNext

	; ix = player
	; iy = reader
	ProcessY8950DataBlock:
		push ix
		ld ix,this
		call MSXAudio_ProcessY8950DataBlock
		pop ix
		push ix
		call Player_GetTimer
		call Timer_Reset
		pop ix
		jp Player_ProcessNext
	ENDM

; ix <- instance or null
; de <- instance or null
MSXAudio_TryCreate:
	call MSXAudio_Detect
	ld ix,0
	ld de,0
	ret nc
	ld ix,MSXAudio_instance
	call MSXAudio_Construct
	ld e,ixl
	ld d,ixh
	ret

; ix = this
MSXAudio_Construct:
	call MSXAudio_Reset
	ret

; ix = this
MSXAudio_Destruct:
	call MSXAudio_Mute
	call MSXAudio_Reset
	ret

; ix = this
; iy = player
MSXAudio_Install:
	ld hl,MSXAudio.ProcessY8950Command
	ld a,5CH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,MSXAudio.ProcessY8950DataBlock
	ld a,88H
	call Player_InstallDataBlockHandler_IY_IXOffset
	ld hl,MSXAudio.ProcessYM3526Command
	ld a,5BH
	call Player_InstallCommandHandler_IY_IXOffset
	ret

; ix = this
; e = register
; d = value
MSXAudio_WriteRegister:
	push ix
	pop hl
	ld bc,MSXAudio.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
MSXAudio_SafeWriteRegister:
	push ix
	pop hl
	ld bc,MSXAudio.SafeWriteRegister
	add hl,bc
	jp hl

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

; ix = this
; iy = reader
MSXAudio_ProcessY8950DataBlock: PROC
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
	call Reader_ReadBlockFromBuffer_IY
	push bc
	call MSXAudio_WriteADPCMData
	pop bc
	pop hl
	pop de
	jp Loop
Finish:
	ld d,01H
	ld a,MSXAudio_ADPCM_CONTROL
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
MSXAudio_WriteADPCMData: PROC
	push ix
	ld de,MSXAudio.WriteADPCMData
	add ix,de
	call JumpIX
	pop ix
	ret
JumpIX:
	jp ix
	ENDP

; f <- c: Found
MSXAudio_Detect:
	in a,(MSXAudio_STATUS_PORT)
	sub 06H
	and a
	ret nz
	scf
	ret

;
	SECTION RAM

MSXAudio_instance: MSXAudio

	ENDS
