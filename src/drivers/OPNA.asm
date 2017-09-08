;
; OPNA YM2608
;
OPNA_BASE: equ 14H
OPNA_STATUS0: equ OPNA_BASE
OPNA_STATUS1: equ OPNA_BASE + 2
OPNA_FM1_ADDRESS: equ OPNA_BASE
OPNA_FM1_DATA: equ OPNA_BASE + 1
OPNA_FM2_ADDRESS: equ OPNA_BASE + 2
OPNA_FM2_DATA: equ OPNA_BASE + 3
OPNA_FREQUENCY: equ 8000000

; ADPCM registers
OPNA_ADPCM_CONTROL: equ 00H
OPNA_MISC_CONTROL: equ 01H
OPNA_START_ADDRESS_L: equ 02H
OPNA_START_ADDRESS_H: equ 03H
OPNA_STOP_ADDRESS_L: equ 04H
OPNA_STOP_ADDRESS_H: equ 05H
OPNA_PRESCALE_L: equ 06H
OPNA_PRESCALE_H: equ 07H
OPNA_ADPCM_DATA: equ 08H
OPNA_DELTA_N_L: equ 09H
OPNA_DELTA_N_H: equ 0AH
OPNA_ENVELOPE_CONTROL: equ 0BH
OPNA_LIMIT_L: equ 0CH
OPNA_LIMIT_H: equ 0DH
OPNA_DAC_DATA: equ 0EH
OPNA_PCM_DATA: equ 0FH
OPNA_FLAG_CONTROL: equ 10H
OPNA_ADPCM_END: equ 11H

OPNA: MACRO
	this:
	super: Driver
	safeControlMirror:
		ds OPNA_ADPCM_END

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp 12H
		ret z              ; block rhythm TEST register
		cp 21H
		ret z              ; block FM TEST register
		cp 27H
		jr z,TimerControl  ; mask timer control
		cp 29H
		ret z              ; mask IRQ control
		cp 2DH
		ret z              ; block access to the prescaler (8 MHz)
		cp 2EH
		ret z              ; block access to the prescaler (4 MHz)
		cp 2FH
		ret z              ; block access to the prescaler (2.6 MHz)
	; a = register
	; d = value
	WriteRegister: PROC
		out (OPNA_FM1_ADDRESS),a
		in a,(OPNA_STATUS0)  ; wait 17 cycles
		in a,(OPNA_STATUS0)
		or (hl)
		ld a,d
		out (OPNA_FM1_DATA),a
	Wait:
		in a,(OPNA_STATUS0)
		bit 7,a
		jr nz,Wait
		ret
		ENDP
	TimerControl:
		ld a,d
		and 11110011b
		ld d,a
		ld a,e
		jr WriteRegister

	; e = register
	; d = value
	SafeWriteRegister2:
		ld a,e
		cp OPNA_ADPCM_END
		jr c,MaskControl2
	; a = register
	; d = value
	WriteRegister2: PROC
		out (OPNA_FM2_ADDRESS),a
		in a,(OPNA_STATUS0)  ; wait 17 cycles
		in a,(OPNA_STATUS0)
		or (hl)
		ld a,d
		out (OPNA_FM2_DATA),a
	Wait:
		in a,(OPNA_STATUS0)
		bit 7,a
		jr nz,Wait
		ret
		ENDP
	MaskControl2:
		ld hl,safeControlMirror
		ld c,a
		ld b,0
		add hl,bc
		ld (hl),d
		cp OPNA_LIMIT_L
		ret z
		cp OPNA_LIMIT_H
		ret z
		cp OPNA_ADPCM_CONTROL
		jr z,MaskAdpcmControl
		cp OPNA_MISC_CONTROL
		jr z,MaskMiscControl
		jr c,WriteRegister2
		cp OPNA_FLAG_CONTROL
		jr z,MaskFlagControl
		cp OPNA_START_ADDRESS_H + 1
		jr c,WriteStartAddress
		cp OPNA_STOP_ADDRESS_H + 1
		jr c,WriteStopAddress
		jr WriteRegister2
	MaskAdpcmControl:
		ld a,d
		and 10110001b
		ld d,a
		ld a,e
		jr WriteRegister2
	MaskMiscControl:
		ld a,d
		and 11000100b  ; force x1 bit and DRAM mode
		ld d,a
		ld a,e
		jr WriteRegister2
	MaskFlagControl:
		ld a,d
		and 10001000b
		ld d,a
		ld a,e
		jr WriteRegister2
	WriteStartAddress:
		ld hl,safeControlMirror + OPNA_MISC_CONTROL
		bit 0,(hl)
		jr nz,ConvStart
		bit 1,(hl)
		jr z,WriteRegister2
	ConvStart:
		ld hl,(safeControlMirror + OPNA_START_ADDRESS_L)
		add hl,hl
		add hl,hl
		add hl,hl
		ld d,l
		ld a,OPNA_START_ADDRESS_L
		call WriteRegister2
		ld d,h
		ld a,OPNA_START_ADDRESS_H
		jr WriteRegister2
	WriteStopAddress:
		ld hl,safeControlMirror + OPNA_MISC_CONTROL
		bit 0,(hl)
		jr nz,ConvStop
		bit 1,(hl)
		jr z,WriteRegister2
	ConvStop:
		ld hl,(safeControlMirror + OPNA_STOP_ADDRESS_L)
		add hl,hl
		add hl,hl
		add hl,hl
		ld a,l
		or 00000111b
		ld d,a
		ld a,OPNA_STOP_ADDRESS_L
		call WriteRegister2
		ld d,h
		ld a,OPNA_STOP_ADDRESS_H
		jp WriteRegister2

	; bc = count
	; hl = source
	WriteADPCMData: PROC
		di
		ld d,17H
		ld a,OPNA_FLAG_CONTROL
		call WriteRegister2
		dec bc
		inc b
		inc c
		ld e,b
		ld b,c
		ld c,OPNA_FM2_DATA
		ld a,OPNA_ADPCM_DATA
		out (OPNA_FM2_ADDRESS),a  ; wait 12 cycles after
		jr Wait
	Next:
		in a,(OPNA_STATUS0)  ; wait 12 cycles
		ld a,OPNA_FLAG_CONTROL
		out (OPNA_FM2_ADDRESS),a
		in a,(OPNA_STATUS0)  ; wait 12 cycles
		ld a,(hl)            ;  "
		ld a,80H
		out (OPNA_FM2_DATA),a
		in a,(OPNA_STATUS0)  ; wait 12 cycles
		ld a,(hl)            ;  "
		ld a,OPNA_ADPCM_DATA
		out (OPNA_FM2_ADDRESS),a  ; wait 12 cycles after
	Wait:
		in a,(OPNA_STATUS1)
		and 00001000b
		jr z,Wait
		outi
		jr nz,Next
		dec e
		jr nz,Next
		ld d,1FH
		ld a,OPNA_FLAG_CONTROL
		call WriteRegister2
		ei
		ret
		ENDP
	ENDM

; ix = this
OPNA_Construct:
	ld bc,OPNA_name
	ld de,OPNA_FREQUENCY >> 16
	ld hl,OPNA_FREQUENCY
	call Driver_Construct
	call OPNA_Reset
	ret

; ix = this
OPNA_Destruct:
	call OPNA_Mute
	ret

; ix = this
; e = register
; d = value
OPNA_WriteRegister:
	push ix
	pop hl
	ld bc,OPNA.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
OPNA_SafeWriteRegister:
	push ix
	pop hl
	ld bc,OPNA.SafeWriteRegister
	add hl,bc
	jp hl

; ix = this
; e = register
; d = value
; ix = this
OPNA_WriteRegister2:
	push ix
	pop hl
	ld bc,OPNA.WriteRegister2
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
OPNA_SafeWriteRegister2:
	push ix
	pop hl
	ld bc,OPNA.SafeWriteRegister2
	add hl,bc
	jp hl

; b = count
; e = register base
; d = value
; ix = this
OPNA_FillRegisters:
	push bc
	push de
	call OPNA_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz OPNA_FillRegisters
	ret

; b = count
; e = register base
; d = value
; ix = this
OPNA_FillRegisters2:
	push bc
	push de
	call OPNA_SafeWriteRegister2
	pop de
	pop bc
	inc e
	djnz OPNA_FillRegisters2
	ret

; e = register
; d = value
; ix = this
OPNA_Mute:
	ld de,0008H
	call OPNA_WriteRegister
	ld de,0009H
	call OPNA_WriteRegister
	ld de,000AH
	call OPNA_WriteRegister
	ld b,0EH
	ld de,0000H
	call OPNA_FillRegisters  ; mute SSG

	ld de,00010H
	call OPNA_WriteRegister  ; rhythm key off

	ld d,001H
	ld e,OPNA_ADPCM_CONTROL
	call OPNA_WriteRegister2  ; stop ADPCM

	ld de,0028H
	call OPNA_WriteRegister
	ld de,0128H
	call OPNA_WriteRegister
	ld de,0228H
	call OPNA_WriteRegister
	ld de,0428H
	call OPNA_WriteRegister
	ld de,0528H
	call OPNA_WriteRegister
	ld de,0628H
	call OPNA_WriteRegister  ; key off FM 1-6
	ret

; ix = this
OPNA_Reset:
	call OPNA_Mute            ; key off all channels
	ld de,0021H
	call OPNA_WriteRegister   ; reset FM TEST register
	ld de,0022H
	call OPNA_WriteRegister   ; reset LFO
	ld de,0027H
	call OPNA_WriteRegister   ; disable CSM mode, reset and stop timers
	ld de,8029H
	call OPNA_WriteRegister   ; mark ADPCM and timer interrupts as disabled, set six voices mode
;	Prescaler
	ld de,012DH
	call OPNA_WriteRegister   ; setup prescaler for 8 MHz
;	Rhythm
	ld de,03F11H
	call OPNA_WriteRegister   ; set max volume rhythm global
	ld de,00012H
	call OPNA_WriteRegister   ; reset rythm TEST register
	ld b,006H
	ld de,0DF18H
	call OPNA_FillRegisters   ; set max volume / mono all tones.
;	ADPCM (DELTA-T)
	ld d,0F4H
	ld e,OPNA_PRESCALE_L
	call OPNA_WriteRegister2
	ld d,001H
	ld e,OPNA_PRESCALE_H
	call OPNA_WriteRegister2
	ld d,0FFH
	ld e,OPNA_LIMIT_L
	call OPNA_WriteRegister2
	ld d,0FFH
	ld e,OPNA_LIMIT_H
	call OPNA_WriteRegister2
	ld d,0FFH
	ld e,OPNA_FLAG_CONTROL
	call OPNA_WriteRegister2
	ld d,080H
	ld e,OPNA_FLAG_CONTROL
	call OPNA_WriteRegister2
	ld d,080H
	ld e,OPNA_MISC_CONTROL
	call OPNA_WriteRegister2  ; configure ADPCM 1bit / DRAM
;	FM 1-3
	ld b,00EH
	ld de,07F40H
	call OPNA_FillRegisters   ; total level = 127
	ld b,003H
	ld de,0C0B4H
	call OPNA_FillRegisters   ; restore panpots 0-3
;	FM 4-6
	ld b,00EH
	ld de,07F40H
	call OPNA_FillRegisters2  ; total level = 127
	ld b,003H
	ld de,0C0B4H
	call OPNA_FillRegisters2  ; restore panpots 4-6
	ret

; ehl = write address
; ix = this
OPNA_SetADPCMWriteAddress:
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
	ld e,OPNA_START_ADDRESS_L
	call OPNA_WriteRegister2
	pop hl
	ld d,h
	ld e,OPNA_START_ADDRESS_H
	call OPNA_WriteRegister2
	ld d,0FFH
	ld e,OPNA_STOP_ADDRESS_L
	call OPNA_WriteRegister2
	ld d,0FFH
	ld e,OPNA_STOP_ADDRESS_H
	call OPNA_WriteRegister2
	ld d,01H
	ld e,OPNA_ADPCM_CONTROL
	call OPNA_WriteRegister2
	ld d,60H
	ld e,OPNA_ADPCM_CONTROL
	call OPNA_WriteRegister2
	ret

; bc = count
; hl = source
; ix = this
OPNA_WriteADPCMData:
	push ix
	ld de,OPNA.WriteADPCMData
	add ix,de
	call System_JumpIX
	pop ix
	ret

; f <- c: Found
OPNA_Detect:
	ld a,255
	out (OPNA_FM1_ADDRESS),a
	in a,(OPNA_STATUS0)
	in a,(OPNA_STATUS0)
	or (hl)
	in a,(OPNA_FM1_DATA)
	sub 01H
	and a
	ret nz
	scf
	ret

;
OPNA_name:
	db "OPNA",0

	SECTION RAM

OPNA_instance: OPNA

	ENDS
