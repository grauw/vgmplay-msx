;
; VGM YM2612 chip
;
YM2612_PCM_REGISTER: equ 2AH
YM2612_PCMBUFFER_SIZE: equ 100H

YM2612: MACRO
	super: Chip YM2612_ym2612Name, YM2612_Connect
	pcmDataStart:
		dd 0
	pcmDataPosition:
		dd 0
	pcmBuffer:
		dw 0

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessPort0Command: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessPort1Command: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessPort0CommandDual: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessPort1CommandDual: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessPCMWrite: PROC
		ld a,(0)
	position: equ $ - 2
		ld d,a
		ld e,YM2612_PCM_REGISTER
		call System_Return
	writeRegister: equ $ - 2
		ld hl,position
		inc (hl)
		ret nz
		ld hl,pcmDataPosition + 1
		inc (hl)
		jr nz,BufferPCMData
		inc hl
		inc (hl)
		jr nz,BufferPCMData
		inc hl
		inc (hl)
		jr BufferPCMData
		ENDP

	; dehl = size
	; ix = player
	; iy = reader
	ProcessPCMDataBlock:
		push de
		push hl
		call MappedReader_GetPosition_IY
		ld (pcmDataStartLSW),hl
		ld (pcmDataStartMSW),de
		xor a
		ld (ProcessPCMWrite.position),a
		ld (pcmDataPosition + 1),a
		ld (pcmDataPosition + 2),a
		ld (pcmDataPosition + 3),a
		pop hl
		pop de
		call MappedReader_Skip_IY
		jr BufferPCMData

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessPCMDataSeek: PROC
		call Reader_ReadDoubleWord_IY
		ld a,l
		ld (ProcessPCMWrite.position),a
		ld a,(pcmDataPosition + 1)
		cp h
		ld a,h
		jr nz,Buffer
		ld hl,(pcmDataPosition + 2)
		sbc hl,de
		ret z  ; buffer block position didn’t change
	Buffer:
		ld (pcmDataPosition + 1),a
		ld (pcmDataPosition + 2),de
		jr BufferPCMData
		ENDP

	; ix = player
	; iy = reader
	BufferPCMData:
		call MappedReader_GetPosition_IY
		push de
		push hl
		ld hl,(pcmDataPosition)
		ld de,(pcmDataPosition + 2)
		ld bc,0
	pcmDataStartLSW: equ $ - 2
		add hl,bc
		ld bc,0
	pcmDataStartMSW: equ $ - 2
		ex de,hl
		adc hl,bc
		ex de,hl
		call MappedReader_SetPosition_IY
		ld de,(pcmBuffer)
		ld bc,100H
		call MappedReader_ReadBlock_IY
		pop hl
		pop de
		jp MappedReader_SetPosition_IY

	; hl' = time remaining
	; ix = player
	; iy = reader
	ProcessPCMWriteWait1:
		call ProcessPCMWrite
		Player_Wait_M 1
	ProcessPCMWriteWait2:
		call ProcessPCMWrite
		Player_Wait_M 2
	ProcessPCMWriteWait3:
		call ProcessPCMWrite
		Player_Wait_M 3
	ProcessPCMWriteWait4:
		call ProcessPCMWrite
		Player_Wait_M 4
	ProcessPCMWriteWait5:
		call ProcessPCMWrite
		Player_Wait_M 5
	ProcessPCMWriteWait6:
		call ProcessPCMWrite
		Player_Wait_M 6
	ProcessPCMWriteWait7:
		call ProcessPCMWrite
		Player_Wait_M 7
	ProcessPCMWriteWait8:
		call ProcessPCMWrite
		Player_Wait_M 8
	ProcessPCMWriteWait9:
		call ProcessPCMWrite
		Player_Wait_M 9
	ProcessPCMWriteWait10:
		call ProcessPCMWrite
		Player_Wait_M 10
	ProcessPCMWriteWait11:
		call ProcessPCMWrite
		Player_Wait_M 11
	ProcessPCMWriteWait12:
		call ProcessPCMWrite
		Player_Wait_M 12
	ProcessPCMWriteWait13:
		call ProcessPCMWrite
		Player_Wait_M 13
	ProcessPCMWriteWait14:
		call ProcessPCMWrite
		Player_Wait_M 14
	ProcessPCMWriteWait15:
		call ProcessPCMWrite
		Player_Wait_M 15
	ENDM

; ix = this
; iy = header
YM2612_Construct:
	ld de,Header.ym2612Clock
	call Chip_Construct
	push ix
	ld bc,YM2612_PCMBUFFER_SIZE
	ld ix,Heap_main
	call Heap_AllocateAligned
	pop ix
	ld (ix + YM2612.pcmBuffer),e
	ld (ix + YM2612.pcmBuffer + 1),d
	ld (ix + YM2612.ProcessPCMWrite.position),e
	ld (ix + YM2612.ProcessPCMWrite.position + 1),d
	call YM2612_GetName
	jp Chip_SetName

; ix = this
YM2612_Destruct:
	push ix
	ld e,(ix + YM2612.pcmBuffer)
	ld d,(ix + YM2612.pcmBuffer + 1)
	ld bc,YM2612_PCMBUFFER_SIZE
	ld ix,Heap_main
	call Heap_Free
	pop ix
	ret

; ix = this
; f <- nz: YM3438
YM2612_IsYM3438:
	bit 7,(ix + YM2612.super.clock + 3)
	ret

; iy = drivers
; ix = this
YM2612_Connect:
	call YM2612_TryCreate
	ret nc
	call Chip_SetDriver
	add hl,de
	ld (ix + YM2612.ProcessPort0Command.writeRegister),l
	ld (ix + YM2612.ProcessPort0Command.writeRegister + 1),h
	ld (ix + YM2612.ProcessPCMWrite.writeRegister),l
	ld (ix + YM2612.ProcessPCMWrite.writeRegister + 1),h
	ld l,c
	ld h,b
	add hl,de
	ld (ix + YM2612.ProcessPort1Command.writeRegister),l
	ld (ix + YM2612.ProcessPort1Command.writeRegister + 1),h
	call Chip_IsDualChip
	ret z
	call YM2612_TryCreate
	ret nc
	call Chip_SetDriver2
	add hl,de
	ld (ix + YM2612.ProcessPort0CommandDual.writeRegister),l
	ld (ix + YM2612.ProcessPort0CommandDual.writeRegister + 1),h
	ld l,c
	ld h,b
	add hl,de
	ld (ix + YM2612.ProcessPort1CommandDual.writeRegister),l
	ld (ix + YM2612.ProcessPort1CommandDual.writeRegister + 1),h
	ret

; iy = drivers
; ix = this
; de <- OPN driver
; hl <- entry offset
; f <- c: succeeded
YM2612_TryCreate:
	call Drivers_TryCreateOPN2OnOPNATurboRPCM_IY
	ld hl,OPN2OnOPNATurboRPCM.SafeWriteRegister
	ld bc,OPN2OnOPNATurboRPCM.SafeWriteRegister2
	ret c
	call Drivers_TryCreateOPN2OnSFGTurboRPCM_IY
	ld hl,OPN2OnSFGTurboRPCM.SafeWriteRegister
	ld bc,OPN2OnSFGTurboRPCM.SafeWriteRegister2
	ret c
	call Drivers_TryCreateOPN2OnTurboRPCM_IY
	ld hl,OPN2OnTurboRPCM.SafeWriteRegister
	ld bc,OPN2OnTurboRPCM.SafeWriteRegister2
	ret

; ix = this
; hl <- name
YM2612_GetName:
	call YM2612_IsYM3438
	ld hl,YM2612_ym2612Name
	ret z
	ld hl,YM2612_ym3438Name
	ret

;
	SECTION RAM

YM2612_instance: YM2612

	ENDS

YM2612_ym2612Name:
	db "YM2612 (OPN2)",0

YM2612_ym3438Name:
	db "YM3438 (OPN2C)",0
