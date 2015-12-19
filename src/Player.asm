;
; Play back VGM data
;
; Time and wait codes are in units of 44100 Hz samples
;
Player_SAMPLES_60HZ: equ 735
Player_SAMPLES_50HZ: equ 882

Player: MACRO
	this:

	; de = wait period
	; ix = this
	Wait:
		ld hl,0
	time: equ $ - 2
		and a
		sbc hl,de
		ld (time),hl
		jp nc,Player_ProcessNext
	Yield:
		ex de,hl
		ld hl,0
		ld (time),hl
		and a
		sbc hl,de
		ld (wait),hl
		ret

	reader:
		dw 0
	header:
		dw 0
	timer:
		dw 0
	wait:
		dw 0
	wait60th:
		dw Player_SAMPLES_60HZ
	wait50th:
		dw Player_SAMPLES_50HZ
	loopCount:
		db 0
	maxLoops:
		db 2  ; 0: loop infinitely
	lastJiffy:
		db 0
	ended:
		db 0

	; de = time passed
	; ix = this
	Update:
		IF DEBUG
		ld a,0F6H
		call VDP_SetColor
		ENDIF
		ld ix,this
		ld (time),de
		ld de,(wait)
		IF DEBUG
		call Wait
		ld a,(VDP_MIRROR_0 + 7)
		call VDP_SetColor
		ret
		ELSE
		jp Wait
		ENDIF

	size:
	ENDM

; a = max loops
; de = reader
; hl = header
; ix = this
; ix <- this
Player_Construct:
	ld (ix + Player.reader),e
	ld (ix + Player.reader + 1),d
	ld (ix + Player.header),l
	ld (ix + Player.header + 1),h
	ld (ix + Player.maxLoops),a
	push ix
	ld e,ixl
	ld d,ixh
	ld hl,Player.Update
	add hl,de
	call TimerFactory_CreateTimer
	pop ix
	ld (ix + Player.timer),e
	ld (ix + Player.timer + 1),d
	ret

; ix = this
; de <- reader
; iy <- reader
Player_GetReaderIY:
	ld e,(ix + Player.reader)
	ld d,(ix + Player.reader + 1)
	ld iyl,e
	ld iyh,d
	ret

; ix = this
; de <- header
; ix <- header
Player_GetHeader:
	ld e,(ix + Player.header)
	ld d,(ix + Player.header + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- timer
; ix <- timer
Player_GetTimer:
	ld e,(ix + Player.timer)
	ld d,(ix + Player.timer + 1)
	ld ixl,e
	ld ixh,d
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

; a = command number
; de = handler address
; iy = this
Player_InstallCommandHandler_IY:
	ld l,a
	ld h,Player_commandsJumpTable >> 8
	ld (hl),e
	inc h
	ld (hl),d
	ret

; a = command number
; ix = handler object
; hl = handler offset
; iy = this
Player_InstallCommandHandler_IY_IXOffset:
	ld e,ixl
	ld d,ixh
	add hl,de
	ex de,hl
	call Player_InstallCommandHandler_IY
	ret

; a = command number
; de = handler address
; iy = this
Player_InstallDataBlockHandler_IY:
	ld l,a
	ld h,Player_dataBlockJumpTable >> 8
	ld (hl),e
	inc h
	ld (hl),d
	ret

; a = command number
; ix = handler object
; hl = handler offset
; iy = this
Player_InstallDataBlockHandler_IY_IXOffset:
	ld e,ixl
	ld d,ixh
	add hl,de
	ex de,hl
	call Player_InstallDataBlockHandler_IY
	ret

; ix = this
Player_Play: PROC
	call Player_GetReaderIY
	call Player_ResetPosition
	push ix
	call Player_GetTimer
	call Timer_Start
	pop ix
Loop:
	push ix
	call Player_GetTimer
	call Timer_Update
	pop ix
	call Player_CheckExitCondition
	jp z,Loop
	push ix
	call Player_GetTimer
	call Timer_Stop
	pop ix
	ret
	ENDP

Player_Wait_JP_INLINE: MACRO
	jp ix
	ENDM

; ix = this
; iy = reader
Player_ProcessNext:
	call Reader_Read_IY
	ld l,a
	ld h,Player_commandsJumpTable >> 8
	ld e,(hl)
	inc h
	ld d,(hl)
	ex de,hl
	jp hl

; ix = this
; iy = reader
Player_ResetPosition:
	push ix
	call Player_GetHeader
	call Header_GetDataOffset
	pop ix
	call MappedReader_SetPosition_IY
	ret

; f <- nz: exit condition occurred
Player_CheckExitCondition:
	bit 0,(ix + Player.ended)
	ret nz
	ld a,(JIFFY)
	cp (ix + Player.lastJiffy)
	ret z
	ld (ix + Player.lastJiffy),a
	ld c,_CONST
	call BDOS
	and a
	ret z
	ld c,_INNOE
	call BDOS
	and a
	ret

; ix = this
; iy = reader
Player_DataBlock:
	call Reader_Read_IY
	cp 66H
	jp nz,Player_UnsupportedCommand
	call Reader_Read_IY
	ld l,a
	ld h,Player_dataBlockJumpTable >> 8
	ld e,(hl)
	inc h
	ld d,(hl)
	ex de,hl
	jp hl

; ix = this
; iy = reader
Player_SkipDataBlock:
	call Reader_ReadDoubleWord_IY
	call MappedReader_Skip_IY
	jp Player_ProcessNext

; ix = this
; iy = reader
Player_EndOfSoundData: PROC
	push ix
	call Player_GetHeader
	call Header_GetLoopOffset
	pop ix
	jr z,NoLoop
	call MappedReader_SetPosition_IY
	inc (ix + Player.loopCount)
	ld a,(ix + Player.maxLoops)
	and a
	jp z,Player_ProcessNext
	cp (ix + Player.loopCount)
	jp nz,Player_ProcessNext
NoLoop:
	ld (ix + Player.ended),-1
	ret
	ENDP

; ix = this
; iy = reader
Player_SetWait: PROC
	call Reader_Read_IY
	cp 62H
	jp z,Set60th
	cp 63H
	jp z,Set50th
	call System_ThrowException
Set60th:
	call Reader_ReadWord_IY
	ld (ix + Player.wait60th),e
	ld (ix + Player.wait60th + 1),d
	jp Player_ProcessNext
Set50th:
	call Reader_ReadWord_IY
	ld (ix + Player.wait50th),e
	ld (ix + Player.wait50th + 1),d
	jp Player_ProcessNext
	ENDP

; ix = this
; iy = reader
Player_Wait0Samples:
	jp Player_ProcessNext
Player_Wait1Samples:
	ld de,1
	Player_Wait_JP_INLINE
Player_Wait2Samples:
	ld de,2
	Player_Wait_JP_INLINE
Player_Wait3Samples:
	ld de,3
	Player_Wait_JP_INLINE
Player_Wait4Samples:
	ld de,4
	Player_Wait_JP_INLINE
Player_Wait5Samples:
	ld de,5
	Player_Wait_JP_INLINE
Player_Wait6Samples:
	ld de,6
	Player_Wait_JP_INLINE
Player_Wait7Samples:
	ld de,7
	Player_Wait_JP_INLINE
Player_Wait8Samples:
	ld de,8
	Player_Wait_JP_INLINE
Player_Wait9Samples:
	ld de,9
	Player_Wait_JP_INLINE
Player_Wait10Samples:
	ld de,10
	Player_Wait_JP_INLINE
Player_Wait11Samples:
	ld de,11
	Player_Wait_JP_INLINE
Player_Wait12Samples:
	ld de,12
	Player_Wait_JP_INLINE
Player_Wait13Samples:
	ld de,13
	Player_Wait_JP_INLINE
Player_Wait14Samples:
	ld de,14
	Player_Wait_JP_INLINE
Player_Wait15Samples:
	ld de,15
	Player_Wait_JP_INLINE
Player_Wait16Samples:
	ld de,16
	Player_Wait_JP_INLINE
Player_Wait735Samples:
	ld e,(ix + Player.wait60th)
	ld d,(ix + Player.wait60th + 1)
	Player_Wait_JP_INLINE
Player_Wait882Samples:
	ld e,(ix + Player.wait50th)
	ld d,(ix + Player.wait50th + 1)
	Player_Wait_JP_INLINE
Player_WaitNSamples:
	call Reader_ReadWord_IY
	Player_Wait_JP_INLINE

; ix = this
; iy = reader
Player_Skip11:
	call Reader_Read_IY
	call Reader_Read_IY
	call Reader_Read_IY
	call Reader_Read_IY
	call Reader_Read_IY
Player_Skip6:
	call Reader_Read_IY
Player_Skip5:
	call Reader_Read_IY
Player_Skip4:
	call Reader_Read_IY
Player_Skip3:
	call Reader_Read_IY
Player_Skip2:
	call Reader_Read_IY
Player_Skip1:
	jp Player_ProcessNext

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
	dw Player_Skip2               ; 50H
	dw Player_Skip3               ; 51H
	dw Player_Skip3               ; 52H
	dw Player_Skip3               ; 53H
	dw Player_Skip3               ; 54H
	dw Player_Skip3               ; 55H
	dw Player_Skip3               ; 56H
	dw Player_Skip3               ; 57H
	dw Player_Skip3               ; 58H
	dw Player_Skip3               ; 59H
	dw Player_Skip3               ; 5AH
	dw Player_Skip3               ; 5BH
	dw Player_Skip3               ; 5CH
	dw Player_Skip3               ; 5DH
	dw Player_Skip3               ; 5EH
	dw Player_Skip3               ; 5FH
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
	dw Player_Skip3               ; A0H
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
	dw Player_Skip4               ; D0H
	dw Player_Skip4               ; D1H
	dw Player_Skip4               ; D2H
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

	ALIGN 256
Player_dataBlockJumpTable:
	REPT 256
	db Player_SkipDataBlock & 0FFH
	ENDM
	REPT 256
	db Player_SkipDataBlock >> 8
	ENDM

Player_scratch:
	ds 256

	ENDS

Player_unsupportedCommandError:
	db "Unsupported command: ",0
