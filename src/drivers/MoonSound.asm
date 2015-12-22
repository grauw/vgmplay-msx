;
; MoonSound YMF278B OPL4
;
MoonSound_STATUS: equ 0C4H
MoonSound_FM_ADDRESS: equ 0C4H
MoonSound_FM_DATA: equ 0C5H
MoonSound_FM2_ADDRESS: equ 0C6H
MoonSound_FM2_DATA: equ 0C7H
MoonSound_WAVE_ADDRESS: equ 07EH
MoonSound_WAVE_DATA: equ 07FH
MoonSound_FM2_NEW: equ 05H
MoonSound_WAVE_MEMORY_CONTROL: equ 02H
MoonSound_WAVE_MEMORY_ADDRESS_E: equ 03H
MoonSound_WAVE_MEMORY_ADDRESS_H: equ 04H
MoonSound_WAVE_MEMORY_ADDRESS_L: equ 05H
MoonSound_WAVE_MEMORY_DATA: equ 06H

MoonSound: MACRO
	this:
	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp 20H
		jr c,MaskControl
	; a = register
	; d = value
	WriteRegister:
		out (MoonSound_FM_ADDRESS),a
		nop     ; wait 56 cycles (11.8 R800 cycles)
		ld a,d
		out (MoonSound_FM_DATA),a
		ret
	MaskControl:
		cp 8H
		jr z,WriteRegister
		ret

	; e = register
	; d = value
	SafeWriteRegister2:
		ld a,e
	; a = register
	; d = value
	WriteRegister2:
		out (MoonSound_FM2_ADDRESS),a
		nop     ; wait 56 cycles (11.8 R800 cycles)
		ld a,d
		out (MoonSound_FM2_DATA),a
		ret

	; e = register
	; d = value
	SafeWriteRegisterWave:
		ld a,e
		cp 20H
		jr c,WriteRegisterWave_Mask
	; a = register
	; d = value
	WriteRegisterWave:
		out (MoonSound_WAVE_ADDRESS),a
		cp (ix)  ; wait 88 cycles (18.6 R800 cycles, but 18 works)
		ld a,d
		out (MoonSound_WAVE_DATA),a
		ret
	WriteRegisterWave_Mask: PROC
		cp 8H
		ret c
	WaveTableNumberMSB:
	useYRW801ROM:
		scf
		jp c,WriteRegisterWave
		add a,18H
		out (MoonSound_WAVE_ADDRESS),a
		cp (ix)  ; wait 88 cycles (18.6 R800 cycles, but 18 works)
		nop
		in a,(MoonSound_WAVE_DATA)
		cp (ix)  ; wait 88 cycles (18.6 R800 cycles)
		or 1
		out (MoonSound_WAVE_DATA),a
		set 7,d
		ld a,e
		jp WriteRegisterWave
		ENDP

	; a = register
	; a <- value
	ReadRegisterWave:
		out (MoonSound_WAVE_ADDRESS),a
		cp (ix)  ; wait 88 cycles (18.6 R800 cycles, but 18 works)
		nop
		in a,(MoonSound_WAVE_DATA)
		ret

	; bc = count
	; hl = source
	WriteMemory: PROC
		ld d,00010001B
		ld a,MoonSound_WAVE_MEMORY_CONTROL
		call WriteRegisterWave
		ld a,MoonSound_WAVE_MEMORY_DATA
		out (MoonSound_WAVE_ADDRESS),a
		nop  ; wait 88 cycles (18.6 R800 cycles)
		dec bc
		inc b
		inc c
		ld e,b
		ld b,c
		ld c,MoonSound_WAVE_DATA
	Loop:
		otir
		dec e
		jr nz,Loop
		ld d,00010000B
		ld a,MoonSound_WAVE_MEMORY_CONTROL
		call WriteRegisterWave
		ret
		ENDP
	ENDM

; ix = this
MoonSound_Construct:
	call MoonSound_Reset
	ret

; ix = this
MoonSound_Destruct:
	call MoonSound_Reset
	ret

; ix = this
; e = register
; d = value
MoonSound_WriteRegister:
	push ix
	pop hl
	ld bc,MoonSound.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
MoonSound_SafeWriteRegister:
	push ix
	pop hl
	ld bc,MoonSound.SafeWriteRegister
	add hl,bc
	jp hl

; ix = this
; e = register
; d = value
MoonSound_WriteRegister2:
	push ix
	pop hl
	ld bc,MoonSound.WriteRegister2
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
MoonSound_SafeWriteRegister2:
	push ix
	pop hl
	ld bc,MoonSound.SafeWriteRegister2
	add hl,bc
	jp hl

; ix = this
; e = register
; d = value
MoonSound_WriteRegisterWave:
	push ix
	pop hl
	ld bc,MoonSound.WriteRegisterWave
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
MoonSound_SafeWriteRegisterWave:
	push ix
	pop hl
	ld bc,MoonSound.SafeWriteRegisterWave
	add hl,bc
	jp hl

; ix = this
; a = register
; a <- value
MoonSound_ReadRegisterWave:
	push ix
	pop hl
	ld bc,MoonSound.ReadRegisterWave
	add hl,bc
	jp hl

; bc = count
; hl = source
; ix = this
MoonSound_WriteMemory:
	push ix
	ld de,MoonSound.WriteMemory
	add ix,de
	call System_JumpIX
	pop ix
	ret

; ehl = memory address
; ix = this
; a <- value
MoonSound_ReadMemoryByte:
	push de
	push hl
	call MoonSound_SetMemoryAddress
	ld d,00010001B
	ld e,MoonSound_WAVE_MEMORY_CONTROL
	call MoonSound_WriteRegisterWave
	ld a,MoonSound_WAVE_MEMORY_DATA
	call MoonSound_ReadRegisterWave
	push af
	ld d,00010000B
	ld e,MoonSound_WAVE_MEMORY_CONTROL
	call MoonSound_WriteRegisterWave
	pop af
	pop hl
	pop de
	ret

; a = value
; ehl = memory address
; ix = this
MoonSound_WriteMemoryByte:
	push de
	push hl
	push af
	call MoonSound_SetMemoryAddress
	ld d,00010001B
	ld e,MoonSound_WAVE_MEMORY_CONTROL
	call MoonSound_WriteRegisterWave
	pop de
	ld e,MoonSound_WAVE_MEMORY_DATA
	call MoonSound_WriteRegisterWave
	ld d,00010000B
	ld e,MoonSound_WAVE_MEMORY_CONTROL
	call MoonSound_WriteRegisterWave
	pop hl
	pop de
	ret

; ehl = memory address
; ix = this
MoonSound_SetMemoryAddress:
	ld a,e
	and 0C0H
	jp nz,System_ThrowException
	ld a,d
	and a
	jp nz,System_ThrowException
	push hl
	ld d,e
	ld e,MoonSound_WAVE_MEMORY_ADDRESS_E
	call MoonSound_WriteRegisterWave
	pop hl
	push hl
	ld d,h
	ld e,MoonSound_WAVE_MEMORY_ADDRESS_H
	call MoonSound_WriteRegisterWave
	pop hl
	ld d,l
	ld e,MoonSound_WAVE_MEMORY_ADDRESS_L
	call MoonSound_WriteRegisterWave
	ret

; b = count
; e = register base
; d = value
; ix = this
MoonSound_FillRegisters:
	push bc
	push de
	call MoonSound_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz MoonSound_FillRegisters
	ret

; b = count
; e = register base
; d = value
; ix = this
MoonSound_FillRegisters2:
	push bc
	push de
	call MoonSound_SafeWriteRegister2
	pop de
	pop bc
	inc e
	djnz MoonSound_FillRegisters2
	ret

; b = count
; e = register base
; d = value
; ix = this
MoonSound_FillRegistersWave:
	push bc
	push de
	call MoonSound_SafeWriteRegisterWave
	pop de
	pop bc
	inc e
	djnz MoonSound_FillRegistersWave
	ret

; ix = this
MoonSound_Mute:
	ld b,16H
	ld de,3F40H
	call MoonSound_FillRegisters
	ld b,16H
	ld de,3F40H
	call MoonSound_FillRegisters2
	ld b,048H
	ld de,0FF98H
	call MoonSound_FillRegistersWave
	ld b,18H
	ld de,0FF50H
	call MoonSound_FillRegistersWave
	ret

; ix = this
MoonSound_Reset:
	call MoonSound_Mute
	ld b,0DAH
	ld de,0020H
	call MoonSound_FillRegistersWave
	ld de,1BF8H
	call MoonSound_SafeWriteRegisterWave
	ld b,020H
	ld de,0020H
	call MoonSound_FillRegisters
	ld b,020H
	ld de,0020H
	call MoonSound_FillRegisters2
	ld b,096H
	ld de,0060H
	call MoonSound_FillRegisters
	ld b,096H
	ld de,0060H
	call MoonSound_FillRegisters2
	ld b,020H
	ld de,0000H
	call MoonSound_FillRegisters
	ld b,020H
	ld de,0000H
	call MoonSound_FillRegisters2
	ret

; f <- c: Found
MoonSound_Detect:
	in a,(MoonSound_STATUS)
	and 11111101B  ; sometimes LD is set
	sub 00H
	and a
	ret nz
	scf
	ret

;
	SECTION RAM

MoonSound_instance: MoonSound

	ENDS
