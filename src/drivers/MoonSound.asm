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
MoonSound_FREQUENCY: equ 33868800

MoonSound: MACRO
	this:
	super: Driver Driver_PrintInfoImpl
	waveNumberMap:
		dw 0
	waveNumberMSB:
		ds 24

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
		nop     ; wait 56 cycles (5.9 bus cycles)
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
		nop     ; wait 56 cycles (5.9 bus cycles)
		ld a,d
		out (MoonSound_FM2_DATA),a
		ret

	; e = register
	; d = value
	SafeWriteRegisterWave:
		call System_Return
	mapWaveNumber: equ $ - 2
		ld a,e
		cp 8H
		ret c
	; a = register
	; d = value
	WriteRegisterWave:
		out (MoonSound_WAVE_ADDRESS),a
		cp (ix)  ; wait 88 cycles (9.3 bus cycles, but 9 works)
		ld a,d
		out (MoonSound_WAVE_DATA),a
		ret

	; a = register
	; a <- value
	ReadRegisterWave:
		out (MoonSound_WAVE_ADDRESS),a
		cp (ix)  ; wait 88 cycles (9.3 bus cycles, but 9 works)
		nop
		in a,(MoonSound_WAVE_DATA)
		ret

	; bc = count
	; hl = source
	WriteMemory: PROC
		ld d,00010001B
		ld a,MoonSound_WAVE_MEMORY_CONTROL
		call WriteRegisterWave
		or 0  ; wait 88 cycles (9.3 bus cycles)
		ld a,MoonSound_WAVE_MEMORY_DATA
		out (MoonSound_WAVE_ADDRESS),a
		nop  ; wait 88 cycles (9.3 bus cycles)
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

	; ix = player
	; iy = reader
	ProcessROMDataBlock:
		ld ix,this
		jp MoonSound_ProcessROMDataBlock

	; e = register
	; d = value
	MapWaveNumber: PROC
		ld a,e
		cp 38H
		ret nc
		cp 20H
		jr c,LSB
	MSB:
		ld c,a
		ld b,0
		ld hl,waveNumberMSB - 20H
		add hl,bc
		ld (hl),d
		set 0,d
		ret
	LSB:
		cp 8H
		ret c
		ld c,a
		ld b,0
		ld hl,waveNumberMSB - 8H
		add hl,bc
		ld a,(hl)
		and 1
		ld c,d
		ld b,a
		ld hl,(waveNumberMap)
		add hl,bc
		ld d,(hl)
		ret
		ENDP
	ENDM

; ix = this
MoonSound_Construct:
	ld bc,MoonSound_name
	ld de,MoonSound_FREQUENCY >> 16
	ld hl,MoonSound_FREQUENCY
	call Driver_Construct
	call MoonSound_Reset
	ret

; ix = this
MoonSound_Destruct:
	call MoonSound_Mute
	ret

; e = register
; d = value
; ix = this
MoonSound_WriteRegister:
	ld a,e
	ld bc,MoonSound.WriteRegister
	jp Utils_JumpIXOffsetBC

; e = register
; d = value
; ix = this
MoonSound_WriteRegister2:
	ld a,e
	ld bc,MoonSound.WriteRegister2
	jp Utils_JumpIXOffsetBC

; e = register
; d = value
; ix = this
MoonSound_WriteRegisterWave:
	ld a,e
	ld bc,MoonSound.WriteRegisterWave
	jp Utils_JumpIXOffsetBC

; a = register
; ix = this
; a <- value
MoonSound_ReadRegisterWave:
	ld bc,MoonSound.ReadRegisterWave
	jp Utils_JumpIXOffsetBC

; ix = this
; iy = reader
MoonSound_ProcessROMDataBlock:
	call Reader_ReadDoubleWord_IY  ; block size
	ld a,d
	and a
	call nz,System_ThrowException
	exx
	call Reader_ReadDoubleWord_IY  ; total rom size
	call Reader_ReadDoubleWord_IY  ; start address
	ld a,d
	and a
	call nz,System_ThrowException
	set 5,e
	exx
	ld bc,8  ; subtract header from block size
	call MoonSound_SubEHL_BC
	call c,System_ThrowException
	ret z
	exx
	call MoonSound_LoadSampleFromReader
	exx
	ret

; ehl = sample start address
; ehl' = sample size
; ix = this
; iy = reader
MoonSound_LoadSampleFromReader: PROC
	push de
	push hl
	ld de,00000011B << 8 | MoonSound_FM2_NEW
	call MoonSound_WriteRegister2
	pop hl
	pop de
	call MoonSound_SetMemoryAddress
	exx
Loop:
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
	call MoonSound_WriteMemory
	pop bc
	pop hl
	pop de
	call MoonSound_SubEHL_BC
	call c,System_ThrowException
	jr nz,Loop
	call MoonSound_FixUpWaveHeaders
	ret
	ENDP

; ehl = minuend
; bc = subtrahend
; f <- c: carry (negative result), z: zero
MoonSound_SubEHL_BC: PROC
	and a
	sbc hl,bc
	jr c,Carry
	ret nz
	ld a,e
	and a
	ret
Carry:
	ld a,e
	sbc a,0
	ld e,a
	ret nz
	ld a,l
	or h
	ret
	ENDP

; ix = this
MoonSound_FixUpWaveHeaders: PROC
	ld b,128
	ld de,0020H
	ld hl,0000H
Loop:
	push bc
	call MoonSound_ReadMemoryByte
	or 20H
	call MoonSound_WriteMemoryByte
	ld bc,000CH
	add hl,bc
	pop bc
	djnz Loop
	call MoonSound_EnableWaveNumberMapping
	ret
	ENDP

; ix = this
MoonSound_EnableWaveNumberMapping:
	call MoonSound_InitialiseWaveNumberMap
	ld e,ixl
	ld d,ixh
	ld hl,MoonSound.MapWaveNumber
	add hl,de
	ld (ix + MoonSound.mapWaveNumber),l
	ld (ix + MoonSound.mapWaveNumber + 1),h
	ret

; ix = this
MoonSound_InitialiseWaveNumberMap: PROC
	ld e,(ix + MoonSound.waveNumberMap)
	ld d,(ix + MoonSound.waveNumberMap + 1)
	ld a,e
	or d
	call z,Allocate
	ld bc,2 | 00 << 8  ; 512
	ld a,0
Loop:
	or 80H
	ld (de),a
	inc a
	inc de
	djnz Loop
	dec c
	jr nz,Loop
	ret
Allocate:
	push ix
	ld bc,512
	ld ix,Heap_main
	call Heap_Allocate
	pop ix
	ld (ix + MoonSound.waveNumberMap),e
	ld (ix + MoonSound.waveNumberMap + 1),d
	ret
	ENDP

; bc = count
; hl = source
; ix = this
MoonSound_WriteMemory:
	ld de,MoonSound.WriteMemory
	jp Utils_JumpIXOffsetDE

; ehl = memory address
; ix = this
; a <- value
MoonSound_ReadMemoryByte:
	push de
	push hl
	call MoonSound_SetMemoryAddress
	ld de,00010001B << 8 | MoonSound_WAVE_MEMORY_CONTROL
	call MoonSound_WriteRegisterWave
	ld a,MoonSound_WAVE_MEMORY_DATA
	call MoonSound_ReadRegisterWave
	push af
	ld de,00010000B << 8 | MoonSound_WAVE_MEMORY_CONTROL
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
	ld de,00010001B << 8 | MoonSound_WAVE_MEMORY_CONTROL
	call MoonSound_WriteRegisterWave
	pop de
	ld e,MoonSound_WAVE_MEMORY_DATA
	call MoonSound_WriteRegisterWave
	ld de,00010000B << 8 | MoonSound_WAVE_MEMORY_CONTROL
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
MoonSound_FillRegisterPairs:
	push bc
	push de
	call MoonSound_WriteRegister
	pop de
	push de
	call MoonSound_WriteRegister2
	pop de
	pop bc
	inc e
	djnz MoonSound_FillRegisterPairs
	ret

; b = count
; e = register base
; d = value
; ix = this
MoonSound_FillRegistersWave:
	push bc
	push de
	call MoonSound_WriteRegisterWave
	pop de
	pop bc
	inc e
	djnz MoonSound_FillRegistersWave
	ret

; ix = this
MoonSound_Mute:
	ld de,00BDH
	call MoonSound_WriteRegister  ; rhythm off
	ld b,16H
	ld de,0F80H
	call MoonSound_FillRegisterPairs  ; max release rate
	ld b,16H
	ld de,3F40H
	call MoonSound_FillRegisterPairs  ; min total level
	ld b,09H
	ld de,00A0H
	call MoonSound_FillRegisterPairs  ; frequency 0
	ld b,09H
	ld de,00B0H
	call MoonSound_FillRegisterPairs  ; key off
	ld b,18H
	ld de,4068H
	call MoonSound_FillRegistersWave  ; key off, damp
	ret

; ix = this
MoonSound_Reset:
	ld de,00000011B << 8 | MoonSound_FM2_NEW
	call MoonSound_WriteRegister2
	ld b,0DAH
	ld de,0020H
	call MoonSound_FillRegistersWave
	ld de,1BF8H
	call MoonSound_WriteRegisterWave
	ld b,0D6H
	ld de,0020H
	call MoonSound_FillRegisterPairs
	ld de,0008H
	call MoonSound_WriteRegister
	ld de,0004H
	call MoonSound_WriteRegister2
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
MoonSound_name:
	db "MoonSound",0

	SECTION RAM

MoonSound_instance: MoonSound

	ENDS
