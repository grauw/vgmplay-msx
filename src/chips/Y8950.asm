;
; VGM Y8950 chip
;
Y8950: MACRO
	this:
	super: Chip Y8950_name, Y8950_Connect, Y8950_Install
	msxAudio:
		dw 0

	; ix = player
	; iy = reader
	ProcessCommand: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP

	; ix = player
	; iy = reader
	ProcessDataBlock: PROC
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
Y8950_Construct:
	ld l,(iy + Header.y8950Clock)
	ld h,(iy + Header.y8950Clock + 1)
	ld e,(iy + Header.y8950Clock + 2)
	ld d,(iy + Header.y8950Clock + 3)
	call Chip_Construct
	ret

; iy = drivers
; ix = this
Y8950_Connect:
	call Drivers_TryCreateMSXAudio_IY
	ret nc
	call Chip_SetDriver
	ld (ix + Y8950.msxAudio),e
	ld (ix + Y8950.msxAudio + 1),d
	ld hl,MSXAudio.SafeWriteRegister
	add hl,de
	ld (ix + Y8950.ProcessCommand.writeRegister),l
	ld (ix + Y8950.ProcessCommand.writeRegister + 1),h
	ld (ix + Y8950.ProcessDataBlock.process),Y8950_ProcessDataBlockMSXAudio
	ld (ix + Y8950.ProcessDataBlock.process + 1),Y8950_ProcessDataBlockMSXAudio >> 8
	ret

; iy = player
; ix = this
Y8950_Install:
	ld a,(ix + Y8950.ProcessCommand.writeRegister)
	or (ix + Y8950.ProcessCommand.writeRegister + 1)
	ret z
	ld hl,Y8950.ProcessCommand
	ld a,5CH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,Y8950.ProcessDataBlock
	ld a,88H
	call Player_InstallDataBlockHandler_IY_IXOffset
	ret

; ix = this
; iy = reader
Y8950_ProcessDataBlockMSXAudio: PROC
	ld e,(ix + Y8950.msxAudio)
	ld d,(ix + Y8950.msxAudio + 1)
	ld ixl,e
	ld ixh,d
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

;
	SECTION RAM

Y8950_instance: Y8950

	ENDS

Y8950_name:
	db "Y8950 (MSX-AUDIO)",0
