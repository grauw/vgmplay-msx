;
; Play back VGM data
;
; Time and wait codes are in units of 44100 Hz samples
;
Player: MACRO
	SAMPLES_60HZ: equ 735
	SAMPLES_50HZ: equ 882
	SAMPLES_CAP: equ 1000
	reader:
		dw 0
	header:
		dw 0
	wait:
		dw 0
	lastJiffy:
		db 0
	wait60th:
		dw SAMPLES_60HZ
	wait50th:
		dw SAMPLES_50HZ
	loopCount:
		db 0
	maxLoops:
		db 2  ; 0: loop infinitely
	ended:
		db 0

	; ix = this
	; de = wait period
	Wait:
		ld hl,0
	time: equ $ - 2
		and a
		sbc hl,de
		ld (time),hl
		jp nc,Player_ProcessNext.NoWait
	Yield:
		ex de,hl
		ld hl,0
		ld (time),hl
		and a
		sbc hl,de
		ld (wait),hl
		ret

	size:
	ENDM

; c = max loops
; de = data reader
; hl = VGM header
; ix = this
; ix <- this
Player_Constructor:
	ld (ix + Player.reader),e
	ld (ix + Player.reader + 1),d
	ld (ix + Player.header),l
	ld (ix + Player.header + 1),h
	ld (ix + Player.maxLoops),c
	ret

; Shuffles the commands jump table so that the LSB and MSB are separated.
; This allows faster table value lookups.
Player_InitCommandsJumpTable: PROC
	ld bc,256
	ld hl,Player_commandsJumpTable + 1
	ld de,Player_scratch
MSBExtractionLoop:
	ldi
	inc hl
	jp pe,MSBExtractionLoop
	ld bc,255
	ld hl,Player_commandsJumpTable + 2
	ld de,Player_commandsJumpTable + 1
LSBExtractionLoop:
	ldi
	inc hl
	jp pe,LSBExtractionLoop
	ld bc,256
	ld hl,Player_scratch
	ld de,Player_commandsJumpTable + 256
	call System_FastLDIR
	ret
	ENDP

; ix = this
Player_Play: PROC
	call Player_ResetPosition
	call Player_InitialiseTimer
Loop:
	call Player_ProcessNext
	call Player_CheckExitCondition
	ret nz
	call Player_UpdateTimer
	jp Loop
	ENDP

; ix = this
Player_ProcessNext: PROC
	call Player_CheckWait
	ret c
NoWait:
	call Player_ReadByte
	ld l,a
	ld h,Player_commandsJumpTable >> 8
	ld e,(hl)
	inc h
	ld d,(hl)
	ex de,hl
	jp hl
	ENDP

; ix = this
; f <- c: waiting
Player_CheckWait: PROC
	ld e,(ix + Player.wait)
	ld d,(ix + Player.wait + 1)
	ld l,(ix + Player.time)
	ld h,(ix + Player.time + 1)
	and a
	sbc hl,de
	jp nc,Done
	ex de,hl
	ld hl,0
	ld (ix + Player.time),l
	ld (ix + Player.time + 1),h
	and a
	sbc hl,de
	ld (ix + Player.wait),l
	ld (ix + Player.wait + 1),h
	ret
Done:
	ld (ix + Player.time),l
	ld (ix + Player.time + 1),h
	ld (ix + Player.wait),0
	ld (ix + Player.wait + 1),0
	ret
	ENDP

; ix = this
Player_UpdateTimer: PROC
	ld b,(ix + Player.lastJiffy)
Wait:
	ld a,(JIFFY)
	cp b
	jp z,Wait
	ld (ix + Player.lastJiffy),a
	sub b
	ld b,a
	ld l,(ix + Player.time)
	ld h,(ix + Player.time + 1)
	call VDP_Is60Hz
	ld de,Player.SAMPLES_60HZ
	jr z,Loop
	ld de,Player.SAMPLES_50HZ
Loop:
	add hl,de
	djnz Loop
	ld (ix + Player.time),l
	ld (ix + Player.time + 1),h
	ld de,Player.SAMPLES_CAP
	sbc hl,de
	ret c
	ld (ix + Player.time),Player.SAMPLES_CAP & 0FFH
	ld (ix + Player.time + 1),Player.SAMPLES_CAP >> 8
	ret
	ENDP

; Waits for timer interrupt to maximise the time available in the first frame.
; ix = this
Player_InitialiseTimer: PROC
	ld hl,JIFFY
	ld a,(hl)
SyncWait:
	halt
	cp (hl)
	jp z,SyncWait
	ld a,(hl)
	ld (ix + Player.lastJiffy),a
	ret
	ENDP

; ix = this
Player_ResetTimer:
	ld a,(JIFFY)
	ld (ix + Player.lastJiffy),a
	ret

; ix = this
; de <- VGM data reader
; ix <- VGM data reader
Player_GetReader:
	ld e,(ix + Player.reader)
	ld d,(ix + Player.reader + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- VGM header
; ix <- VGM header
Player_GetHeader:
	ld e,(ix + Player.header)
	ld d,(ix + Player.header + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
Player_ResetPosition:
	push ix
	call Player_GetHeader
	call Header_GetDataOffset
	pop ix
	call Player_SetPosition
	ret

; ix = this
Player_SetPosition:
	push ix
	push de
	call Player_GetReader
	pop de
	call Reader_SetPosition
	pop ix
	ret

; ix = this
; a <- value
; Modifies: af, hl
Player_ReadByte: equ Reader_instance.ReadByte

; ix = this
; de <- value
Player_ReadWord:
	call Player_ReadByte
	ld e,a
	call Player_ReadByte
	ld d,a
	ret

; ix = this
; dehl <- value
Player_ReadDoubleWord:
	call Player_ReadWord
	push de
	call Player_ReadWord
	pop hl
	ret

; f <- nz: exit condition occurred
Player_CheckExitCondition:
	bit 0,(ix + Player.ended)
	ret nz
	ld c,_CONST
	call BDOS
	and a
	ret z
	ld c,_INNOE
	call BDOS
	and a
	ret

; ix = this
Player_DataBlock:
	call Player_ReadByte
	cp 66H
	jp nz,Player_UnsupportedCommand
	call Player_ReadByte
	cp 88h
	jp z,Player_Y8950DataBlock
	push ix
	call Player_GetReader
	call Player_ReadDoubleWord
	call Reader_Skip
	pop ix
	jp Player_ProcessNext.NoWait

; Y8950 DELTA-T ROM data
Player_Y8950DataBlock: PROC
	call Player_ReadDoubleWord  ; block size
	push de
	push hl
	call Player_ReadDoubleWord  ; total rom size
	call Player_ReadDoubleWord  ; start address
	push ix
	ld ix,MSXAudio_instance
	call MSXAudio_SetADPCMWriteAddress
	pop ix
	pop hl
	pop de
	ld bc,8  ; subtract header from block size
	and a
	sbc hl,bc
	ld bc,0
	ex de,hl
	sbc hl,bc
	ex de,hl
	jp c,System_ThrowException
	ld a,h
	or l
	or e
	or d
	ret z
	push ix
	push de
	call Player_GetReader
	pop de
	ld iy,MSXAudio_instance.WriteADPCMData
	call Reader_ReadAndProcessBlock
	pop ix
	ld a,01H
	ld a,MSXAudio_ADPCM_CONTROL
	call MSXAudio_instance.WriteRegister
	call Player_ResetTimer
	jp Player_ProcessNext.NoWait
	ENDP

; ix = this
Player_SN76489Write: PROC
	call Player_ReadByte
	ex af,af'
	ld a,(MMM_instance.found)
	and a
	jr z,Franky
	ex af,af'
	call MMM_instance.SafeWriteRegister
	jp Player_ProcessNext.NoWait
Franky:
	ex af,af'
	call Franky_instance.SafeWriteRegister
	jp Player_ProcessNext.NoWait
	ENDP

; ix = this
Player_YM2413Write:
	call Player_ReadWord
	call MSXMusic_instance.SafeWriteRegister
	jp Player_ProcessNext.NoWait

; ix = this
Player_YM2151Write:
	call Player_ReadWord
	call SFG_instance.SafeWriteRegister
	jp Player_ProcessNext.NoWait

; ix = this
Player_YM3812Write:
	call Player_ReadWord
	call MoonSound_instance.SafeWriteRegister
	jp Player_ProcessNext.NoWait

; ix = this
Player_YM3526Write: PROC
	call Player_ReadWord
	ld a,(MSXAudio_instance.found)
	and a
	jr z,MoonSound
	call MSXAudio_instance.SafeWriteRegister
	jp Player_ProcessNext.NoWait
MoonSound:
	call MoonSound_instance.SafeWriteRegister
	jp Player_ProcessNext.NoWait
	ENDP

; ix = this
Player_Y8950Write:
	call Player_ReadWord
	call MSXAudio_instance.SafeWriteRegister
	jp Player_ProcessNext.NoWait

; ix = this
Player_YMF262WritePort0:
	call Player_ReadWord
	call MoonSound_instance.SafeWriteRegister
	jp Player_ProcessNext.NoWait

; ix = this
Player_YMF262WritePort1:
	call Player_ReadWord
	call MoonSound_instance.SafeWriteRegister2
	jp Player_ProcessNext.NoWait

; ix = this
Player_YMF278BWrite: PROC
	call Player_ReadByte
	cp 1
	jr c,FM1
	jp z,FM2
Wave:
	call Player_ReadWord
	call MoonSound_instance.SafeWriteRegisterWave
	jp Player_ProcessNext.NoWait
FM1:
	call Player_ReadWord
	call MoonSound_instance.SafeWriteRegister
	jp Player_ProcessNext.NoWait
FM2:
	call Player_ReadWord
	call MoonSound_instance.SafeWriteRegister2
	jp Player_ProcessNext.NoWait
	ENDP

; ix = this
Player_AY8910Write:
	call Player_ReadWord
	call PSG_instance.SafeWriteRegister
	jp Player_ProcessNext.NoWait

; ix = this
Player_K051649Write: PROC
	call Player_ReadByte
	cp 1
	jr c,Waveform
	jr z,Frequency
	cp 3
	jr c,Amplitude
	jr z,Mixer
	cp 5
	jr c,WaveformSCCPlus
	jr z,Deformation
	call Player_ReadWord
	jp Player_ProcessNext.NoWait
Waveform:
	call Player_ReadWord
	ld a,e
	call SCC_instance.WriteRegister
	jp Player_ProcessNext.NoWait
Frequency:
	call Player_ReadWord
	ld a,SCC.FREQUENCY
	add a,e
	call SCC_instance.WriteRegister
	jp Player_ProcessNext.NoWait
Amplitude:
	call Player_ReadWord
	ld a,SCC.AMPLITUDE
	add a,e
	call SCC_instance.WriteRegister
	jp Player_ProcessNext.NoWait
Mixer:
	call Player_ReadWord
	ld a,SCC.MIXER
	call SCC_instance.WriteRegister
	jp Player_ProcessNext.NoWait
WaveformSCCPlus:
	call Player_ReadWord
	jp Player_ProcessNext.NoWait
Deformation:
	call Player_ReadWord
	ld a,SCC.DEFORMATION
	call SCC_instance.WriteRegister
	jp Player_ProcessNext.NoWait
	ENDP

; ix = this
Player_EndOfSoundData: PROC
	push ix
	call Player_GetHeader
	call Header_GetLoopOffset
	pop ix
	jr z,NoLoop
	call Player_SetPosition
	inc (ix + Player.loopCount)
	ld a,(ix + Player.maxLoops)
	and a
	jp z,Player_ProcessNext.NoWait
	cp (ix + Player.loopCount)
	jp nz,Player_ProcessNext.NoWait
NoLoop:
	ld (ix + Player.ended),-1
	ret
	ENDP

; ix = this
Player_SetWait: PROC
	call Player_ReadByte
	cp 62H
	jp z,Set60th
	cp 63H
	jp z,Set50th
	call System_ThrowException
Set60th:
	call Player_ReadWord
	ld (ix + Player.wait60th),e
	ld (ix + Player.wait60th + 1),d
	jp Player_ProcessNext.NoWait
Set50th:
	call Player_ReadWord
	ld (ix + Player.wait50th),e
	ld (ix + Player.wait50th + 1),d
	jp Player_ProcessNext.NoWait
	ENDP

; ix = this
Player_Wait0Samples:
	jp Player_ProcessNext.NoWait
Player_Wait1Samples:
	ld de,1
	jp Player_instance.Wait
Player_Wait2Samples:
	ld de,2
	jp Player_instance.Wait
Player_Wait3Samples:
	ld de,3
	jp Player_instance.Wait
Player_Wait4Samples:
	ld de,4
	jp Player_instance.Wait
Player_Wait5Samples:
	ld de,5
	jp Player_instance.Wait
Player_Wait6Samples:
	ld de,6
	jp Player_instance.Wait
Player_Wait7Samples:
	ld de,7
	jp Player_instance.Wait
Player_Wait8Samples:
	ld de,8
	jp Player_instance.Wait
Player_Wait9Samples:
	ld de,9
	jp Player_instance.Wait
Player_Wait10Samples:
	ld de,10
	jp Player_instance.Wait
Player_Wait11Samples:
	ld de,11
	jp Player_instance.Wait
Player_Wait12Samples:
	ld de,12
	jp Player_instance.Wait
Player_Wait13Samples:
	ld de,13
	jp Player_instance.Wait
Player_Wait14Samples:
	ld de,14
	jp Player_instance.Wait
Player_Wait15Samples:
	ld de,15
	jp Player_instance.Wait
Player_Wait16Samples:
	ld de,16
	jp Player_instance.Wait
Player_Wait735Samples:
	ld e,(ix + Player.wait60th)
	ld d,(ix + Player.wait60th + 1)
	jp Player_instance.Wait
Player_Wait882Samples:
	ld e,(ix + Player.wait50th)
	ld d,(ix + Player.wait50th + 1)
	jp Player_instance.Wait
Player_WaitNSamples:
	call Player_ReadWord
	jp Player_instance.Wait

; ix = this
Player_Skip11:
	call Player_ReadByte
	call Player_ReadByte
	call Player_ReadByte
	call Player_ReadByte
	call Player_ReadByte
Player_Skip6:
	call Player_ReadByte
Player_Skip5:
	call Player_ReadByte
Player_Skip4:
	call Player_ReadByte
Player_Skip3:
	call Player_ReadByte
Player_Skip2:
	call Player_ReadByte
Player_Skip1:
	jp Player_ProcessNext.NoWait

; ix = this
Player_UnsupportedCommand:
	push af
	in a,(2EH)
	ld hl,Player_unsupportedCommandError
	call System_Print
	pop af
	call System_PrintHexA
	call System_PrintCrLf
	ld b,1
	ld c,_TERM
	call BDOS

;
	SECTION RAM

Player_instance: Player

Player_unsupportedCommandError:
	db "Unsupported command: ",0

	ALIGN 256
Player_commandsJumpTable:
	dw Player_UnsupportedCommand  ; 00H
	dw Player_UnsupportedCommand  ; 01H
	dw Player_UnsupportedCommand  ; 02H
	dw Player_UnsupportedCommand  ; 03H
	dw Player_UnsupportedCommand  ; 04H
	dw Player_UnsupportedCommand  ; 05H
	dw Player_UnsupportedCommand  ; 06H
	dw Player_UnsupportedCommand  ; 07H
	dw Player_UnsupportedCommand  ; 08H
	dw Player_UnsupportedCommand  ; 09H
	dw Player_UnsupportedCommand  ; 0AH
	dw Player_UnsupportedCommand  ; 0BH
	dw Player_UnsupportedCommand  ; 0CH
	dw Player_UnsupportedCommand  ; 0DH
	dw Player_UnsupportedCommand  ; 0EH
	dw Player_UnsupportedCommand  ; 0FH
	dw Player_UnsupportedCommand  ; 10H
	dw Player_UnsupportedCommand  ; 11H
	dw Player_UnsupportedCommand  ; 12H
	dw Player_UnsupportedCommand  ; 13H
	dw Player_UnsupportedCommand  ; 14H
	dw Player_UnsupportedCommand  ; 15H
	dw Player_UnsupportedCommand  ; 16H
	dw Player_UnsupportedCommand  ; 17H
	dw Player_UnsupportedCommand  ; 18H
	dw Player_UnsupportedCommand  ; 19H
	dw Player_UnsupportedCommand  ; 1AH
	dw Player_UnsupportedCommand  ; 1BH
	dw Player_UnsupportedCommand  ; 1CH
	dw Player_UnsupportedCommand  ; 1DH
	dw Player_UnsupportedCommand  ; 1EH
	dw Player_UnsupportedCommand  ; 1FH
	dw Player_UnsupportedCommand  ; 20H
	dw Player_UnsupportedCommand  ; 21H
	dw Player_UnsupportedCommand  ; 22H
	dw Player_UnsupportedCommand  ; 23H
	dw Player_UnsupportedCommand  ; 24H
	dw Player_UnsupportedCommand  ; 25H
	dw Player_UnsupportedCommand  ; 26H
	dw Player_UnsupportedCommand  ; 27H
	dw Player_UnsupportedCommand  ; 28H
	dw Player_UnsupportedCommand  ; 29H
	dw Player_UnsupportedCommand  ; 2AH
	dw Player_UnsupportedCommand  ; 2BH
	dw Player_UnsupportedCommand  ; 2CH
	dw Player_UnsupportedCommand  ; 2DH
	dw Player_UnsupportedCommand  ; 2EH
	dw Player_UnsupportedCommand  ; 2FH
	dw Player_Skip2               ; 30H
	dw Player_Skip2               ; 31H
	dw Player_Skip2               ; 32H
	dw Player_Skip2               ; 33H
	dw Player_Skip2               ; 34H
	dw Player_Skip2               ; 35H
	dw Player_Skip2               ; 36H
	dw Player_Skip2               ; 37H
	dw Player_Skip2               ; 38H
	dw Player_Skip2               ; 39H
	dw Player_Skip2               ; 3AH
	dw Player_Skip2               ; 3BH
	dw Player_Skip2               ; 3CH
	dw Player_Skip2               ; 3DH
	dw Player_Skip2               ; 3EH
	dw Player_Skip2               ; 3FH
	dw Player_Skip3               ; 40H
	dw Player_Skip3               ; 41H
	dw Player_Skip3               ; 42H
	dw Player_Skip3               ; 43H
	dw Player_Skip3               ; 44H
	dw Player_Skip3               ; 45H
	dw Player_Skip3               ; 46H
	dw Player_Skip3               ; 47H
	dw Player_Skip3               ; 48H
	dw Player_Skip3               ; 49H
	dw Player_Skip3               ; 4AH
	dw Player_Skip3               ; 4BH
	dw Player_Skip3               ; 4CH
	dw Player_Skip3               ; 4DH
	dw Player_Skip3               ; 4EH
	dw Player_Skip2               ; 4FH
	dw Player_SN76489Write        ; 50H
	dw Player_YM2413Write         ; 51H
	dw Player_Skip3               ; 52H
	dw Player_Skip3               ; 53H
	dw Player_YM2151Write         ; 54H
	dw Player_Skip3               ; 55H
	dw Player_Skip3               ; 56H
	dw Player_Skip3               ; 57H
	dw Player_Skip3               ; 58H
	dw Player_Skip3               ; 59H
	dw Player_YM3812Write         ; 5AH
	dw Player_YM3526Write         ; 5BH
	dw Player_Y8950Write          ; 5CH
	dw Player_Skip3               ; 5DH
	dw Player_YMF262WritePort0    ; 5EH
	dw Player_YMF262WritePort1    ; 5FH
	dw Player_UnsupportedCommand  ; 60H
	dw Player_WaitNSamples        ; 61H
	dw Player_Wait735Samples      ; 62H
	dw Player_Wait882Samples      ; 63H
	dw Player_SetWait             ; 64H
	dw Player_UnsupportedCommand  ; 65H
	dw Player_EndOfSoundData      ; 66H
	dw Player_DataBlock           ; 67H
	dw Player_UnsupportedCommand  ; 68H
	dw Player_UnsupportedCommand  ; 69H
	dw Player_UnsupportedCommand  ; 6AH
	dw Player_UnsupportedCommand  ; 6BH
	dw Player_UnsupportedCommand  ; 6CH
	dw Player_UnsupportedCommand  ; 6DH
	dw Player_UnsupportedCommand  ; 6EH
	dw Player_UnsupportedCommand  ; 6FH
	dw Player_Wait1Samples        ; 70H
	dw Player_Wait2Samples        ; 71H
	dw Player_Wait3Samples        ; 72H
	dw Player_Wait4Samples        ; 73H
	dw Player_Wait5Samples        ; 74H
	dw Player_Wait6Samples        ; 75H
	dw Player_Wait7Samples        ; 76H
	dw Player_Wait8Samples        ; 77H
	dw Player_Wait9Samples        ; 78H
	dw Player_Wait10Samples       ; 79H
	dw Player_Wait11Samples       ; 7AH
	dw Player_Wait12Samples       ; 7BH
	dw Player_Wait13Samples       ; 7CH
	dw Player_Wait14Samples       ; 7DH
	dw Player_Wait15Samples       ; 7EH
	dw Player_Wait16Samples       ; 7FH
	dw Player_Wait0Samples        ; 80H
	dw Player_Wait1Samples        ; 81H
	dw Player_Wait2Samples        ; 82H
	dw Player_Wait3Samples        ; 83H
	dw Player_Wait4Samples        ; 84H
	dw Player_Wait5Samples        ; 85H
	dw Player_Wait6Samples        ; 86H
	dw Player_Wait7Samples        ; 87H
	dw Player_Wait8Samples        ; 88H
	dw Player_Wait9Samples        ; 89H
	dw Player_Wait10Samples       ; 8AH
	dw Player_Wait11Samples       ; 8BH
	dw Player_Wait12Samples       ; 8CH
	dw Player_Wait13Samples       ; 8DH
	dw Player_Wait14Samples       ; 8EH
	dw Player_Wait15Samples       ; 8FH
	dw Player_Skip5               ; 90H
	dw Player_Skip5               ; 91H
	dw Player_Skip6               ; 92H
	dw Player_Skip11              ; 93H
	dw Player_Skip2               ; 94H
	dw Player_Skip5               ; 95H
	dw Player_UnsupportedCommand  ; 96H
	dw Player_UnsupportedCommand  ; 97H
	dw Player_UnsupportedCommand  ; 98H
	dw Player_UnsupportedCommand  ; 99H
	dw Player_UnsupportedCommand  ; 9AH
	dw Player_UnsupportedCommand  ; 9BH
	dw Player_UnsupportedCommand  ; 9CH
	dw Player_UnsupportedCommand  ; 9DH
	dw Player_UnsupportedCommand  ; 9EH
	dw Player_UnsupportedCommand  ; 9FH
	dw Player_AY8910Write         ; A0H
	dw Player_Skip3               ; A1H
	dw Player_Skip3               ; A2H
	dw Player_Skip3               ; A3H
	dw Player_Skip3               ; A4H
	dw Player_Skip3               ; A5H
	dw Player_Skip3               ; A6H
	dw Player_Skip3               ; A7H
	dw Player_Skip3               ; A8H
	dw Player_Skip3               ; A9H
	dw Player_Skip3               ; AAH
	dw Player_Skip3               ; ABH
	dw Player_Skip3               ; ACH
	dw Player_Skip3               ; ADH
	dw Player_Skip3               ; AEH
	dw Player_Skip3               ; AFH
	dw Player_Skip3               ; B0H
	dw Player_Skip3               ; B1H
	dw Player_Skip3               ; B2H
	dw Player_Skip3               ; B3H
	dw Player_Skip3               ; B4H
	dw Player_Skip3               ; B5H
	dw Player_Skip3               ; B6H
	dw Player_Skip3               ; B7H
	dw Player_Skip3               ; B8H
	dw Player_Skip3               ; B9H
	dw Player_Skip3               ; BAH
	dw Player_Skip3               ; BBH
	dw Player_Skip3               ; BCH
	dw Player_Skip3               ; BDH
	dw Player_Skip3               ; BEH
	dw Player_Skip3               ; BFH
	dw Player_Skip4               ; C0H
	dw Player_Skip4               ; C1H
	dw Player_Skip4               ; C2H
	dw Player_Skip4               ; C3H
	dw Player_Skip4               ; C4H
	dw Player_Skip4               ; C5H
	dw Player_Skip4               ; C6H
	dw Player_Skip4               ; C7H
	dw Player_Skip4               ; C8H
	dw Player_Skip4               ; C9H
	dw Player_Skip4               ; CAH
	dw Player_Skip4               ; CBH
	dw Player_Skip4               ; CCH
	dw Player_Skip4               ; CDH
	dw Player_Skip4               ; CEH
	dw Player_Skip4               ; CFH
	dw Player_YMF278BWrite        ; D0H
	dw Player_Skip4               ; D1H
	dw Player_K051649Write        ; D2H
	dw Player_Skip4               ; D3H
	dw Player_Skip4               ; D4H
	dw Player_Skip4               ; D5H
	dw Player_Skip4               ; D6H
	dw Player_Skip4               ; D7H
	dw Player_Skip4               ; D8H
	dw Player_Skip4               ; D9H
	dw Player_Skip4               ; DAH
	dw Player_Skip4               ; DBH
	dw Player_Skip4               ; DCH
	dw Player_Skip4               ; DDH
	dw Player_Skip4               ; DEH
	dw Player_Skip4               ; DFH
	dw Player_Skip5               ; E0H
	dw Player_Skip5               ; E1H
	dw Player_Skip5               ; E2H
	dw Player_Skip5               ; E3H
	dw Player_Skip5               ; E4H
	dw Player_Skip5               ; E5H
	dw Player_Skip5               ; E6H
	dw Player_Skip5               ; E7H
	dw Player_Skip5               ; E8H
	dw Player_Skip5               ; E9H
	dw Player_Skip5               ; EAH
	dw Player_Skip5               ; EBH
	dw Player_Skip5               ; ECH
	dw Player_Skip5               ; EDH
	dw Player_Skip5               ; EEH
	dw Player_Skip5               ; EFH
	dw Player_Skip5               ; F0H
	dw Player_Skip5               ; F1H
	dw Player_Skip5               ; F2H
	dw Player_Skip5               ; F3H
	dw Player_Skip5               ; F4H
	dw Player_Skip5               ; F5H
	dw Player_Skip5               ; F6H
	dw Player_Skip5               ; F7H
	dw Player_Skip5               ; F8H
	dw Player_Skip5               ; F9H
	dw Player_Skip5               ; FAH
	dw Player_Skip5               ; FBH
	dw Player_Skip5               ; FCH
	dw Player_Skip5               ; FDH
	dw Player_Skip5               ; FEH
	dw Player_Skip5               ; FFH

Player_scratch:
	ds 256

	ENDS
