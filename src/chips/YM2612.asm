;
; VGM YM2612 chip
;
YM2612_PCM_REGISTER: equ 2AH

YM2612: MACRO
	super: Chip YM2612_ym2612Name, YM2612_Connect
	pcmDataStart:
		dd 0
	pcmDataPosition:
		dd 0

	; ix = player
	; iy = reader
	ProcessPort0Command: PROC
		call Reader_ReadWord_IY
		call System_Return
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP

	; ix = player
	; iy = reader
	ProcessPort1Command: PROC
		call Reader_ReadWord_IY
		call System_Return
	writeRegister: equ $ - 2
		jp Player_ProcessNext
		ENDP

	; ix = player
	; iy = reader
	ProcessPCMWrite: PROC
		ld a,(YM2612_pcmBuffer)
	position: equ $ - 2
		ld d,a
		ld e,YM2612_PCM_REGISTER
		call System_Return
	writeRegister: equ $ - 2
		ld hl,position
		inc (hl)
		ret nz
		ld a,(pcmDataPosition + 1)
		inc a
		ld (pcmDataPosition + 1),a
		jr nz,BufferPCMData
		ld de,(pcmDataPosition + 2)
		inc de
		ld (pcmDataPosition + 2),de
		jr BufferPCMData
		ENDP

	; ix = player
	; iy = reader
	ProcessPCMDataBlock:
		call Reader_ReadDoubleWord_IY
		push de
		push hl
		call MappedReader_GetPosition_IY
		ld (pcmDataStart),hl
		ld (pcmDataStart + 2),de
		ld a,l
		ld (ProcessPCMWrite.position),a
		ld a,h
		ld (pcmDataPosition + 1),a
		ld (pcmDataPosition + 2),de
		pop hl
		pop de
		call MappedReader_Skip_IY
		call BufferPCMData
		jp Player_ProcessNext

	; ix = player
	; iy = reader
	ProcessPCMDataSeek:
		call Reader_ReadDoubleWord_IY
		ld bc,(pcmDataStart)
		add hl,bc
		ld a,l
		ld (ProcessPCMWrite.position),a
		ld a,h
		ld (pcmDataPosition + 1),a
		ex de,hl
		ld bc,(pcmDataStart + 2)
		add hl,bc
		ld (pcmDataPosition + 2),hl
		call BufferPCMData
		jp Player_ProcessNext

	; ix = player
	; iy = reader
	BufferPCMData:
		call MappedReader_GetPosition_IY
		push de
		push hl
		ld hl,(pcmDataPosition)
		ld de,(pcmDataPosition + 2)
		ld l,0
		call MappedReader_SetPosition_IY
		ld de,YM2612_pcmBuffer
		ld bc,100H
		call MappedReader_ReadBlock_IY
		pop hl
		pop de
		call MappedReader_SetPosition_IY
		ret

	; ix = player
	; iy = reader
	ProcessPCMWriteWait0:
		call ProcessPCMWrite
		jp Player_ProcessNext
	ProcessPCMWriteWait1:
		call ProcessPCMWrite
		ld de,1
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait2:
		call ProcessPCMWrite
		ld de,2
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait3:
		call ProcessPCMWrite
		ld de,3
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait4:
		call ProcessPCMWrite
		ld de,4
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait5:
		call ProcessPCMWrite
		ld de,5
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait6:
		call ProcessPCMWrite
		ld de,6
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait7:
		call ProcessPCMWrite
		ld de,7
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait8:
		call ProcessPCMWrite
		ld de,8
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait9:
		call ProcessPCMWrite
		ld de,9
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait10:
		call ProcessPCMWrite
		ld de,10
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait11:
		call ProcessPCMWrite
		ld de,11
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait12:
		call ProcessPCMWrite
		ld de,12
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait13:
		call ProcessPCMWrite
		ld de,13
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait14:
		call ProcessPCMWrite
		ld de,14
		Player_Wait_JP_INLINE
	ProcessPCMWriteWait15:
		call ProcessPCMWrite
		ld de,15
		Player_Wait_JP_INLINE
	ENDM

; ix = this
; iy = header
YM2612_Construct:
	ld de,Header.ym2612Clock
	call Chip_Construct
	call YM2612_IsYM3438
	ret z
	ld hl,YM2612_ym3438Name
	call Chip_SetName
	ret

; ix = this
; f <- nz: YM3438
YM2612_IsYM3438:
	bit 7,(ix + YM2612.super.clock + 3)
	ret

; iy = drivers
; ix = this
YM2612_Connect: PROC
	call Drivers_TryCreateOPN2OnOPNATurboRPCM_IY
	jr nc,TryOPN2OnSFGTurboRPCM
	call Chip_SetDriver
	ld hl,OPN2OnOPNATurboRPCM.SafeWriteRegister
	add hl,de
	ld (ix + YM2612.ProcessPort0Command.writeRegister),l
	ld (ix + YM2612.ProcessPort0Command.writeRegister + 1),h
	ld (ix + YM2612.ProcessPCMWrite.writeRegister),l
	ld (ix + YM2612.ProcessPCMWrite.writeRegister + 1),h
	ld hl,OPN2OnOPNATurboRPCM.SafeWriteRegister2
	add hl,de
	ld (ix + YM2612.ProcessPort1Command.writeRegister),l
	ld (ix + YM2612.ProcessPort1Command.writeRegister + 1),h
	ret
TryOPN2OnSFGTurboRPCM:
	call Drivers_TryCreateOPN2OnSFGTurboRPCM_IY
	ret nc
	call Chip_SetDriver
	ld hl,OPN2OnSFGTurboRPCM.SafeWriteRegister
	add hl,de
	ld (ix + YM2612.ProcessPort0Command.writeRegister),l
	ld (ix + YM2612.ProcessPort0Command.writeRegister + 1),h
	ld (ix + YM2612.ProcessPCMWrite.writeRegister),l
	ld (ix + YM2612.ProcessPCMWrite.writeRegister + 1),h
	ld hl,OPN2OnSFGTurboRPCM.SafeWriteRegister2
	add hl,de
	ld (ix + YM2612.ProcessPort1Command.writeRegister),l
	ld (ix + YM2612.ProcessPort1Command.writeRegister + 1),h
	ret
	ENDP

;
	SECTION RAM

YM2612_instance: YM2612

	ENDS

	SECTION RAM_PAGE1_ALIGNED

	ALIGN 100H
YM2612_pcmBuffer: ds 100H

	ENDS

YM2612_ym2612Name:
	db "YM2612 (OPN2)",0

YM2612_ym3438Name:
	db "YM3438 (OPN2C)",0
