;
; VGM file data
;
Player: MACRO
	SAMPLES_60HZ: equ 735
	SAMPLES_50HZ: equ 882
	reader:
		dw 0
	time:
		dw 0
	wait:
		dw 0
	lastJiffy:
		db 0
	wait60th:
		dw SAMPLES_60HZ
	wait50th:
		dw SAMPLES_50HZ
	ended:
		db 0
	size:
	ENDM

; de = data reader
; ix = this
; ix <- this
Player_Constructor:
	ld (ix + Player.reader),e
	ld (ix + Player.reader + 1),d
	ret

; ix = this
Player_Play: PROC
	ld a,(JIFFY)
	ld (ix + Player.lastJiffy),a
Loop:
	call Player_ProcessNext
	call Player_CheckExitCondition
	ret nz
	call Player_UpdateTime
	jp Loop
	ENDP

; ix = this
Player_ProcessNext: PROC
	call Player_CheckWait
	ret c
NoWait:
	call Player_ReadByte
	ld e,a
	ld d,0
	ld hl,Player_commandsJumpTable
	add hl,de
	add hl,de
	ld d,(hl)
	inc hl
	ld h,(hl)
	ld l,d
	jp hl
	ENDP

; ix = this
; f <- c: waiting
Player_CheckWait: PROC
	ld l,(ix + Player.wait)
	ld h,(ix + Player.wait + 1)
	ld a,l
	or h
	ret z
	ld e,(ix + Player.time)
	ld d,(ix + Player.time + 1)
	and a
	sbc hl,de
	jp c,Done
	jr z,Done
	ld (ix + Player.wait),l
	ld (ix + Player.wait + 1),h
	ld (ix + Player.time),0
	ld (ix + Player.time + 1),0
	scf
	ret
Done:
	ld (ix + Player.wait),0
	ld (ix + Player.wait + 1),0
	dec hl
	ld a,l
	cpl
	ld (ix + Player.time),a
	ld a,h
	cpl
	ld (ix + Player.time + 1),a
	and a
	ret
	ENDP

; ix = this
Player_UpdateTime: PROC
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
	ret
	ENDP

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
; a <- value
Player_ReadByte:
	push de
	push hl
	push ix
	call Player_GetReader
	call Reader_ReadByte
	pop ix
	pop hl
	pop de
	ret

; ix = this
; hl <- value
Player_ReadWord:
	push af
	call Player_ReadByte
	ld l,a
	call Player_ReadByte
	ld h,a
	pop af
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
Player_YM2151Write:
	call Player_ReadWord
	push ix
	ld ix,SFG_instance
	call SFG_SafeWriteRegister
	pop ix
	jp Player_ProcessNext.NoWait

; ix = this
Player_AY8910Write:
	call Player_ReadWord
	push ix
	ld ix,PSG_instance
	call PSG_SafeWriteRegister
	pop ix
	jp Player_ProcessNext.NoWait

; ix = this
Player_EndOfSoundData:
	ld (ix + Player.ended),-1
	ret

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
	ld (ix + Player.wait60th),l
	ld (ix + Player.wait60th + 1),h
	jp Player_ProcessNext.NoWait
Set50th:
	call Player_ReadWord
	ld (ix + Player.wait50th),l
	ld (ix + Player.wait50th + 1),h
	jp Player_ProcessNext.NoWait
	ENDP

; ix = this
Player_Wait1Samples:
	ld hl,1
	jp Player_WaitSamples
Player_Wait2Samples:
	ld hl,2
	jp Player_WaitSamples
Player_Wait3Samples:
	ld hl,3
	jp Player_WaitSamples
Player_Wait4Samples:
	ld hl,4
	jp Player_WaitSamples
Player_Wait5Samples:
	ld hl,5
	jp Player_WaitSamples
Player_Wait6Samples:
	ld hl,6
	jp Player_WaitSamples
Player_Wait7Samples:
	ld hl,7
	jp Player_WaitSamples
Player_Wait8Samples:
	ld hl,8
	jp Player_WaitSamples
Player_Wait9Samples:
	ld hl,9
	jp Player_WaitSamples
Player_Wait10Samples:
	ld hl,10
	jp Player_WaitSamples
Player_Wait11Samples:
	ld hl,11
	jp Player_WaitSamples
Player_Wait12Samples:
	ld hl,12
	jp Player_WaitSamples
Player_Wait13Samples:
	ld hl,13
	jp Player_WaitSamples
Player_Wait14Samples:
	ld hl,14
	jp Player_WaitSamples
Player_Wait15Samples:
	ld hl,15
	jp Player_WaitSamples
Player_Wait16Samples:
	ld hl,16
	jp Player_WaitSamples
Player_Wait735Samples:
	ld l,(ix + Player.wait60th)
	ld h,(ix + Player.wait60th + 1)
	jp Player_WaitSamples
Player_Wait882Samples:
	ld l,(ix + Player.wait50th)
	ld h,(ix + Player.wait50th + 1)
	jp Player_WaitSamples
Player_WaitNSamples:
	call Player_ReadWord
Player_WaitSamples:
	ld (ix + Player.wait),l
	ld (ix + Player.wait + 1),h
	jp Player_ProcessNext

; ix = this
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
	jp REBOOT

;
	SECTION RAM

Player_instance: Player

Player_unsupportedCommandError:
	db "Unsupported command: ",0

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
	dw Player_UnsupportedCommand  ; 4FH
	dw Player_UnsupportedCommand  ; 50H
	dw Player_UnsupportedCommand  ; 51H
	dw Player_UnsupportedCommand  ; 52H
	dw Player_UnsupportedCommand  ; 53H
	dw Player_YM2151Write         ; 54H
	dw Player_UnsupportedCommand  ; 55H
	dw Player_UnsupportedCommand  ; 56H
	dw Player_UnsupportedCommand  ; 57H
	dw Player_UnsupportedCommand  ; 58H
	dw Player_UnsupportedCommand  ; 59H
	dw Player_UnsupportedCommand  ; 5AH
	dw Player_UnsupportedCommand  ; 5BH
	dw Player_UnsupportedCommand  ; 5CH
	dw Player_UnsupportedCommand  ; 5DH
	dw Player_UnsupportedCommand  ; 5EH
	dw Player_UnsupportedCommand  ; 5FH
	dw Player_UnsupportedCommand  ; 60H
	dw Player_WaitNSamples        ; 61H
	dw Player_Wait735Samples      ; 62H
	dw Player_Wait882Samples      ; 63H
	dw Player_SetWait             ; 64H
	dw Player_UnsupportedCommand  ; 65H
	dw Player_EndOfSoundData      ; 66H
	dw Player_UnsupportedCommand  ; 67H
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
	dw Player_UnsupportedCommand  ; 80H
	dw Player_UnsupportedCommand  ; 81H
	dw Player_UnsupportedCommand  ; 82H
	dw Player_UnsupportedCommand  ; 83H
	dw Player_UnsupportedCommand  ; 84H
	dw Player_UnsupportedCommand  ; 85H
	dw Player_UnsupportedCommand  ; 86H
	dw Player_UnsupportedCommand  ; 87H
	dw Player_UnsupportedCommand  ; 88H
	dw Player_UnsupportedCommand  ; 89H
	dw Player_UnsupportedCommand  ; 8AH
	dw Player_UnsupportedCommand  ; 8BH
	dw Player_UnsupportedCommand  ; 8CH
	dw Player_UnsupportedCommand  ; 8DH
	dw Player_UnsupportedCommand  ; 8EH
	dw Player_UnsupportedCommand  ; 8FH
	dw Player_UnsupportedCommand  ; 90H
	dw Player_UnsupportedCommand  ; 91H
	dw Player_UnsupportedCommand  ; 92H
	dw Player_UnsupportedCommand  ; 93H
	dw Player_UnsupportedCommand  ; 94H
	dw Player_UnsupportedCommand  ; 95H
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
	dw Player_UnsupportedCommand  ; B0H
	dw Player_UnsupportedCommand  ; B1H
	dw Player_UnsupportedCommand  ; B2H
	dw Player_UnsupportedCommand  ; B3H
	dw Player_UnsupportedCommand  ; B4H
	dw Player_UnsupportedCommand  ; B5H
	dw Player_UnsupportedCommand  ; B6H
	dw Player_UnsupportedCommand  ; B7H
	dw Player_UnsupportedCommand  ; B8H
	dw Player_UnsupportedCommand  ; B9H
	dw Player_UnsupportedCommand  ; BAH
	dw Player_UnsupportedCommand  ; BBH
	dw Player_Skip3               ; BCH
	dw Player_Skip3               ; BDH
	dw Player_Skip3               ; BEH
	dw Player_Skip3               ; BFH
	dw Player_UnsupportedCommand  ; C0H
	dw Player_UnsupportedCommand  ; C1H
	dw Player_UnsupportedCommand  ; C2H
	dw Player_UnsupportedCommand  ; C3H
	dw Player_UnsupportedCommand  ; C4H
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
	dw Player_UnsupportedCommand  ; D0H
	dw Player_UnsupportedCommand  ; D1H
	dw Player_UnsupportedCommand  ; D2H
	dw Player_UnsupportedCommand  ; D3H
	dw Player_UnsupportedCommand  ; D4H
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
	dw Player_UnsupportedCommand  ; E0H
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

	ENDS
