;
; VGM YMF278B chip
;
YMF278B: MACRO
	this:
	super: Chip YMF278B_name, YMF278B_Connect, YMF278B_Install
	moonSound:
		dw 0

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_Read_IY
		cp 1
		jr c,FM1
		jp z,FM2
	Wave: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	FM1: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
	FM2: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP
		ENDP

	; ix = player
	; iy = reader
	ProcessROMDataBlock: PROC
		push ix
		ld ix,this
		call 0
	process: equ $ - 2
		pop ix
		push ix
		call Player_GetTimer
		call Timer_Reset
		pop ix
		jp Player_ProcessNext
		ENDP
	ENDM

; ix = this
; iy = header
YMF278B_Construct:
	ld l,(iy + Header.ymf278bClock)
	ld h,(iy + Header.ymf278bClock + 1)
	ld e,(iy + Header.ymf278bClock + 2)
	ld d,(iy + Header.ymf278bClock + 3)
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YMF278B_Connect:
	call Drivers_TryCreateMoonSound_IY
	ret nc
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
	ld (ix + YMF278B.ProcessROMDataBlock.process),YMF278B_ProcessROMDataBlockMoonSound
	ld (ix + YMF278B.ProcessROMDataBlock.process + 1),YMF278B_ProcessROMDataBlockMoonSound >> 8
	ret

; iy = player
; ix = this
YMF278B_Install:
	ld a,(ix + YMF278B.ProcessCommand.FM1.writeRegister)
	or (ix + YMF278B.ProcessCommand.FM1.writeRegister + 1)
	ret z
	ld hl,YMF278B.ProcessCommand
	ld a,0D0H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YMF278B.ProcessROMDataBlock
	ld a,84H
	call Player_InstallDataBlockHandler_IY_IXOffset
	ret

; ix = this
; iy = reader
YMF278B_ProcessROMDataBlockMoonSound: PROC
	ld e,(ix + YMF278B.moonSound)
	ld d,(ix + YMF278B.moonSound + 1)
	ld ixl,e
	ld ixh,d
	ld (ix + MoonSound.WriteRegisterWave_Mask.useYRW801ROM),0
	ld d,00000011B
	ld e,MoonSound_FM2_NEW
	call MoonSound_WriteRegister2
	call Reader_ReadDoubleWord_IY  ; block size
	push de
	push hl
	call Reader_ReadDoubleWord_IY  ; total rom size
	call Reader_ReadDoubleWord_IY  ; start address
	set 5,e
	call MoonSound_SetMemoryAddress
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
	call MoonSound_WriteMemory
	pop bc
	pop hl
	pop de
	jp Loop
Finish:
	call YMF278B_FixUpWaveHeaders
	ret
	ENDP

; ix = moonsound
YMF278B_FixUpWaveHeaders: PROC
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
	ret
	ENDP

;
YMF278B_instance: YMF278B

YMF278B_name:
	db "YMF278B (OPL4)",0
