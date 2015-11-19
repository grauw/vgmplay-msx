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

MoonSound: MACRO
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
		cp 8H
		ret c
	; a = register
	; d = value
	WriteRegisterWave:
		out (MoonSound_WAVE_ADDRESS),a
		cp (ix)  ; wait 88 cycles (18.6 R800 cycles, but 18 works)
		ld a,d
		out (MoonSound_WAVE_DATA),a
		ret

	; ix = player
	ProcessYMF278BCommand: PROC
		call Player_ReadByte
		cp 1
		jr c,FM1
		jp z,FM2
	Wave:
		call Player_ReadWord
		call SafeWriteRegisterWave
		jp Player_ProcessNext
	FM1:
		call Player_ReadWord
		call SafeWriteRegister
		jp Player_ProcessNext
	FM2:
		call Player_ReadWord
		call SafeWriteRegister2
		jp Player_ProcessNext
		ENDP

	; ix = player
	ProcessYMF262Port0Command:
		call Player_ReadWord
		call SafeWriteRegister
		jp Player_ProcessNext

	; ix = player
	ProcessYMF262Port1Command:
		call Player_ReadWord
		call SafeWriteRegister2
		jp Player_ProcessNext

	; ix = player
	ProcessYM3812Command:
		call Player_ReadWord
		call SafeWriteRegister
		jp Player_ProcessNext

	; ix = player
	ProcessYM3526Command:
		call Player_ReadWord
		call SafeWriteRegister
		jp Player_ProcessNext
	ENDM

; ix <- instance or null
; de <- instance or null
MoonSound_TryCreate:
	call MoonSound_Detect
	ld ix,0
	ld de,0
	ret nc
	ld ix,MoonSound_instance
	call MoonSound_Construct
	ld e,ixl
	ld d,ixh
	ret

; ix = this
MoonSound_Construct:
	call MoonSound_Reset
	ret

; ix = this
MoonSound_Destruct:
	call MoonSound_Reset
	ret

; ix = this
; iy = player
MoonSound_Install:
	ld hl,MoonSound.ProcessYMF278BCommand
	ld a,0D0H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,MoonSound.ProcessYMF262Port0Command
	ld a,5EH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,MoonSound.ProcessYMF262Port1Command
	ld a,5FH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,MoonSound.ProcessYM3812Command
	ld a,5AH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,MoonSound.ProcessYM3526Command
	ld a,5BH
	call Player_InstallCommandHandler_IY_IXOffset
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
