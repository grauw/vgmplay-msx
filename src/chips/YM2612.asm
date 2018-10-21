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
	pcmBuffer:
		dw 0

	; ix = player
	; iy = reader
	ProcessPort0Command: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; ix = player
	; iy = reader
	ProcessPort1Command: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; ix = player
	; iy = reader
	ProcessPort0CommandDual: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

	; ix = player
	; iy = reader
	ProcessPort1CommandDual: PROC
		call Reader_ReadWord_IY
		jp System_Return
	writeRegister: equ $ - 2
		ENDP

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

	; ix = player
	; iy = reader
	ProcessPCMDataBlock:
		call Reader_ReadDoubleWord_IY
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
		call MappedReader_SetPosition_IY
		ret

	; ix = player
	; iy = reader
	ProcessPCMWriteWait1:
		call ProcessPCMWrite
		ld de,1
		Player_WAIT
	ProcessPCMWriteWait2:
		call ProcessPCMWrite
		ld de,2
		Player_WAIT
	ProcessPCMWriteWait3:
		call ProcessPCMWrite
		ld de,3
		Player_WAIT
	ProcessPCMWriteWait4:
		call ProcessPCMWrite
		ld de,4
		Player_WAIT
	ProcessPCMWriteWait5:
		call ProcessPCMWrite
		ld de,5
		Player_WAIT
	ProcessPCMWriteWait6:
		call ProcessPCMWrite
		ld de,6
		Player_WAIT
	ProcessPCMWriteWait7:
		call ProcessPCMWrite
		ld de,7
		Player_WAIT
	ProcessPCMWriteWait8:
		call ProcessPCMWrite
		ld de,8
		Player_WAIT
	ProcessPCMWriteWait9:
		call ProcessPCMWrite
		ld de,9
		Player_WAIT
	ProcessPCMWriteWait10:
		call ProcessPCMWrite
		ld de,10
		Player_WAIT
	ProcessPCMWriteWait11:
		call ProcessPCMWrite
		ld de,11
		Player_WAIT
	ProcessPCMWriteWait12:
		call ProcessPCMWrite
		ld de,12
		Player_WAIT
	ProcessPCMWriteWait13:
		call ProcessPCMWrite
		ld de,13
		Player_WAIT
	ProcessPCMWriteWait14:
		call ProcessPCMWrite
		ld de,14
		Player_WAIT
	ProcessPCMWriteWait15:
		call ProcessPCMWrite
		ld de,15
		Player_WAIT
	ENDM

; ix = this
; iy = header
YM2612_Construct:
	ld de,Header.ym2612Clock
	call Chip_Construct
	push ix
	ld bc,100H
	ld ix,Heap_main
	call Heap_AllocateAligned
	pop ix
	ld (ix + YM2612.pcmBuffer),e
	ld (ix + YM2612.pcmBuffer + 1),d
	ld (ix + YM2612.ProcessPCMWrite.position),e
	ld (ix + YM2612.ProcessPCMWrite.position + 1),d
	call YM2612_IsYM3438
	ret z
	ld hl,YM2612_ym3438Name
	call Chip_SetName
	ret

; ix = this
YM2612_Destruct:
	push ix
	ld e,(ix + YM2612.pcmBuffer)
	ld d,(ix + YM2612.pcmBuffer + 1)
	ld bc,100H
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

;
	SECTION RAM

YM2612_instance: YM2612

	ENDS

YM2612_ym2612Name:
	db "YM2612 (OPN2)",0

YM2612_ym3438Name:
	db "YM3438 (OPN2C)",0
