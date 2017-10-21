;
; VGM YMF278B chip
;
YMF278B: MACRO
	this:
	super: Chip YMF278B_name, YMF278B_Connect, YMF278B_Install
	moonSound:
		dw 0
	waveNumberMap:
		dw 0
	waveNumberMSB:
		ds 24

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_Read_IY
		dec a
		jr z,FM2
		jp p,Wave
	FM1: PROC
		call Reader_ReadWord_IY
		call System_Return
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	FM2: PROC
		call Reader_ReadWord_IY
		call System_Return
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	Wave: PROC
		call Reader_ReadWord_IY
		call System_Return
	mapWaveNumber: equ $ - 2
		call System_Return
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
		ENDP

	; ix = player
	; iy = reader
	ProcessROMDataBlock: PROC
		push ix
		ld ix,this
		call System_ThrowException
	process: equ $ - 2
		pop ix
		push ix
		call Player_GetTimer
		call Timer_Reset
		pop ix
		jp Player_ProcessNext
		ENDP

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
; iy = header
YMF278B_Construct:
	ld de,Header.ymf278bClock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YMF278B_Connect:
	call Drivers_TryCreateMoonSound_IY
	ret nc
	call Chip_SetDriver
	ld (ix + YMF278B.moonSound),e
	ld (ix + YMF278B.moonSound + 1),d
	ld hl,MoonSound.SafeWriteRegister
	add hl,de
	ld (ix + YMF278B.ProcessCommand.FM1.writeRegister),l
	ld (ix + YMF278B.ProcessCommand.FM1.writeRegister + 1),h
	ld hl,MoonSound.SafeWriteRegister2
	add hl,de
	ld (ix + YMF278B.ProcessCommand.FM2.writeRegister),l
	ld (ix + YMF278B.ProcessCommand.FM2.writeRegister + 1),h
	ld hl,MoonSound.SafeWriteRegisterWave
	add hl,de
	ld (ix + YMF278B.ProcessCommand.Wave.writeRegister),l
	ld (ix + YMF278B.ProcessCommand.Wave.writeRegister + 1),h
	ld (ix + YMF278B.ProcessROMDataBlock.process),YMF278B_ProcessROMDataBlock
	ld (ix + YMF278B.ProcessROMDataBlock.process + 1),YMF278B_ProcessROMDataBlock >> 8
	ret

; ix = this
; ix <- moonsound
YMF278B_GetMoonSound:
	ld e,(ix + YMF278B.moonSound)
	ld d,(ix + YMF278B.moonSound + 1)
	ld ixl,e
	ld ixh,d
	ret

; iy = player
; ix = this
YMF278B_Install:
	ld hl,YMF278B.ProcessCommand
	ld a,0D0H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YMF278B.ProcessROMDataBlock
	ld a,84H
	call Player_InstallDataBlockHandler_IY_IXOffset
	ret

; ix = this
; iy = reader
YMF278B_ProcessROMDataBlock:
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
	call YMF278B_SubEHL_BC
	call c,System_ThrowException
	ret z
	exx
	call YMF278B_LoadSampleFromReader
	ret

; ehl = sample start address
; ehl' = sample size
; ix = this
; iy = reader
YMF278B_LoadSampleFromReader: PROC
	push ix
	push de
	push hl
	call YMF278B_GetMoonSound
	ld d,00000011B
	ld e,MoonSound_FM2_NEW
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
	call YMF278B_SubEHL_BC
	call c,System_ThrowException
	jr nz,Loop
	pop ix
	call YMF278B_FixUpWaveHeaders
	ret
	ENDP

; ehl = minuend
; bc = subtrahend
; f <- c: carry (negative result), z: zero
YMF278B_SubEHL_BC: PROC
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
YMF278B_FixUpWaveHeaders: PROC
	push ix
	call YMF278B_GetMoonSound
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
	pop ix
	call YMF278B_EnableWaveNumberMapping
	ret
	ENDP

; ix = this
YMF278B_EnableWaveNumberMapping:
	call YMF278B_InitialiseWaveNumberMap
	ld e,ixl
	ld d,ixh
	ld hl,YMF278B.MapWaveNumber
	add hl,de
	ld (ix + YMF278B.ProcessCommand.Wave.mapWaveNumber),l
	ld (ix + YMF278B.ProcessCommand.Wave.mapWaveNumber + 1),h
	ret

; ix = this
YMF278B_InitialiseWaveNumberMap: PROC
	ld e,(ix + YMF278B.waveNumberMap)
	ld d,(ix + YMF278B.waveNumberMap + 1)
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
	ld (ix + YMF278B.waveNumberMap),e
	ld (ix + YMF278B.waveNumberMap + 1),d
	ret
	ENDP

;
	SECTION RAM

YMF278B_instance: YMF278B

	ENDS

YMF278B_name:
	db "YMF278B (OPL4)",0
