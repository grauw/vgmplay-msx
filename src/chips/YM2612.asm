;
; VGM YM2612 chip
;
YM2612_PCM_REGISTER: equ 2AH

YM2612: MACRO
	super: Chip YM2612_name, YM2612_Connect, YM2612_Install
	pcmDataStart:
		dd 0
	pcmDataPosition:
		dd 0

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
	ProcessPCMWrite: PROC
		ld a,(YM2612_pcmBuffer)
	position: equ $ - 2
		ld d,a
		ld e,YM2612_PCM_REGISTER
		call 0
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
YM2612_Construct: PROC
	ld l,(iy + Header.version)
	ld h,(iy + Header.version + 1)
	ld bc,-102H
	add hl,bc
	jr nc,Pre1_02
	ld l,(iy + Header.ym2612Clock)
	ld h,(iy + Header.ym2612Clock + 1)
	ld e,(iy + Header.ym2612Clock + 2)
	ld d,(iy + Header.ym2612Clock + 3)
	jp Continue
Pre1_02:
	ld l,(iy + Header.ym2413Clock)
	ld h,(iy + Header.ym2413Clock + 1)
	ld e,(iy + Header.ym2413Clock + 2)
	ld d,(iy + Header.ym2413Clock + 3)
Continue:
	call Chip_Construct
	ret
	ENDP

; iy = drivers
; ix = this
YM2612_Connect:
	call Drivers_TryCreateOPN2TurboRPCM_IY
	ret nc
	call Chip_SetDriver
	ld hl,OPN2TurboRPCM.SafeWriteRegister
	add hl,de
	ld (ix + YM2612.ProcessPort0Command.writeRegister),l
	ld (ix + YM2612.ProcessPort0Command.writeRegister + 1),h
	ld (ix + YM2612.ProcessPCMWrite.writeRegister),l
	ld (ix + YM2612.ProcessPCMWrite.writeRegister + 1),h
	ld hl,OPN2TurboRPCM.SafeWriteRegister2
	add hl,de
	ld (ix + YM2612.ProcessPort1Command.writeRegister),l
	ld (ix + YM2612.ProcessPort1Command.writeRegister + 1),h
	ret

; iy = player
; ix = this
YM2612_Install:
	ld a,(ix + YM2612.ProcessPort0Command.writeRegister)
	or (ix + YM2612.ProcessPort0Command.writeRegister + 1)
	ret z
	ld hl,YM2612.ProcessPort0Command
	ld a,52H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPort1Command
	ld a,53H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait0
	ld a,80H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait1
	ld a,81H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait2
	ld a,82H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait3
	ld a,83H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait4
	ld a,84H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait5
	ld a,85H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait6
	ld a,86H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait7
	ld a,87H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait8
	ld a,88H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait9
	ld a,89H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait10
	ld a,8AH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait11
	ld a,8BH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait12
	ld a,8CH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait13
	ld a,8DH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait14
	ld a,8EH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMWriteWait15
	ld a,8FH
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMDataSeek
	ld a,0E0H
	call Player_InstallCommandHandler_IY_IXOffset
	ld hl,YM2612.ProcessPCMDataBlock
	ld a,00H
	call Player_InstallDataBlockHandler_IY_IXOffset
	ret

;
	SECTION RAM

YM2612_instance: YM2612

	ALIGN 100H
YM2612_pcmBuffer: ds 100H

	ENDS

YM2612_name:
	db "YM2612 (OPN2)",0
