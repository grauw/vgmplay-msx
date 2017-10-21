;
; VGM YM2608 chip
;
YM2608: MACRO
	this:
	super: Chip YM2608_name, YM2608_Connect, YM2608_Install
	OPNA:
		dw 0

	; ix = player
	; iy = reader
	ProcessPort0Command: PROC
		call Reader_ReadWord_IY
		call 0
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP

	; ix = player
	; iy = reader
	ProcessPort1Command: PROC
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
YM2608_Construct:
	ld de,Header.ym2608Clock
	call Chip_Construct
	ret

; iy = drivers
; ix = this
YM2608_Connect: PROC
	call Drivers_TryCreateOPNA_IY
	jr nc,TryOPNOnSFGPSG
	call Chip_SetDriver
	ld (ix + YM2608.OPNA),e
	ld (ix + YM2608.OPNA + 1),d
	ld hl,OPNA.SafeWriteRegister
	add hl,de
	ld (ix + YM2608.ProcessPort0Command.writeRegister),l
	ld (ix + YM2608.ProcessPort0Command.writeRegister + 1),h
	ld hl,OPNA.SafeWriteRegister2
	add hl,de
	ld (ix + YM2608.ProcessPort1Command.writeRegister),l
	ld (ix + YM2608.ProcessPort1Command.writeRegister + 1),h
	ld (ix + YM2608.ProcessDataBlock.process),YM2608_ProcessDataBlockOPNA
	ld (ix + YM2608.ProcessDataBlock.process + 1),YM2608_ProcessDataBlockOPNA >> 8
	ret
TryOPNOnSFGPSG:
	call Drivers_TryCreateOPNOnSFGPSG_IY
	ret nc
	call Chip_SetDriver
	ld hl,OPNOnSFGPSG.SafeWriteRegister
	add hl,de
	ld (ix + YM2608.ProcessPort0Command.writeRegister),l
	ld (ix + YM2608.ProcessPort0Command.writeRegister + 1),h
	ld hl,OPNOnSFGPSG.SafeWriteRegister2
	add hl,de
	ld (ix + YM2608.ProcessPort1Command.writeRegister),l
	ld (ix + YM2608.ProcessPort1Command.writeRegister + 1),h
	ld (ix + YM2608.ProcessDataBlock.process),YM2608_SkipDataBlock
	ld (ix + YM2608.ProcessDataBlock.process + 1),YM2608_SkipDataBlock >> 8
	ret
	ENDP

; iy = player
; ix = this
YM2608_Install:
	ld hl,YM2608.ProcessPort0Command
	ld a,56H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2608.ProcessPort1Command
	ld a,57H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2608.ProcessDataBlock
	ld a,81H
	call Player_InstallDataBlockHandler_IY_IXOffset
	ret

; ix = this
; iy = reader
YM2608_ProcessDataBlockOPNA: PROC
	ld e,(ix + YM2608.OPNA)
	ld d,(ix + YM2608.OPNA + 1)
	ld ixl,e
	ld ixh,d
	call Reader_ReadDoubleWord_IY  ; block size
	push de
	push hl
	call Reader_ReadDoubleWord_IY  ; total rom size
	call Reader_ReadDoubleWord_IY  ; start address
	call OPNA_SetADPCMWriteAddress
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
	call OPNA_WriteADPCMData
	pop bc
	pop hl
	pop de
	jp Loop
Finish:
	ld d,01H
	ld e,OPNA_ADPCM_CONTROL
	call OPNA_WriteRegister2
	ret
	ENDP

YM2608_SkipDataBlock:
	call Reader_ReadDoubleWord_IY
	call MappedReader_Skip_IY
	ret

;
	SECTION RAM

YM2608_instance: YM2608

	ENDS

YM2608_name:
	db "YM2608 (OPNA)",0
