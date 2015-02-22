;
; Top-level VGMPlay program class
;
VGMPlay: MACRO
	fileHandle:
		db 0
	header:
		dw Header_instance
	reader:
		dw DataReader_instance
	player:
		dw Player_instance
	sfg:
		dw SFG_instance
	size:
	ENDM

;
VGMPlay_Main:
	call DOS_IsDOS2
	ld hl,VGMPlay_dos2RequiredError
	call c,VGMPlay_TerminateWithError

	ld hl,VGMPlay_welcome
	call System_Print

;	call System_EnableTurbo

	ld ix,Mapper_instance
	call Mapper_Constructor
	ld ix,Heap_heap
	call Heap_Constructor
	ld ix,Heap_heapUpper
	call Heap_Constructor

	call Memory_UnitTest
	call Heap_UnitTest

	ld ix,VGMPlay_instance
	call VGMPlay_Constructor
	call VGMPlay_EnterMainLoop

	ld iy,(EXPTBL-1)
	ld ix,KILBUF
	call CALSLT
	ret

; ix = this
; ix <- this
VGMPlay_Constructor:
	push ix
	call VGMPlay_GetSFG
	call SFG_Install
	pop ix
	ret

; ix = this
; de <- VGM header
; ix <- VGM header
VGMPlay_GetHeader:
	ld e,(ix + VGMPlay.header)
	ld d,(ix + VGMPlay.header + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- VGM data reader
; ix <- VGM data reader
VGMPlay_GetReader:
	ld e,(ix + VGMPlay.reader)
	ld d,(ix + VGMPlay.reader + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- VGM data
; ix <- VGM data
VGMPlay_GetPlayer:
	ld e,(ix + VGMPlay.player)
	ld d,(ix + VGMPlay.player + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- VGM header
; ix <- VGM header
VGMPlay_GetSFG:
	ld e,(ix + VGMPlay.sfg)
	ld d,(ix + VGMPlay.sfg + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
VGMPlay_EnterMainLoop:
	call VGMPlay_OpenFile
	call VGMPlay_ReadHeader
	call VGMPlay_ShowInfo
	call VGMPlay_ReadData
	call VGMPlay_CloseFile
	call VGMPlay_Play
	ret

VGMPlay_OpenFile: PROC
	ld de,DTA
Loop:
	inc de
	ld a,(de)
	and a
	ld hl,VGMPlay_invalidFilenameError
	call z,VGMPlay_TerminateWithError
	cp " "
	jr z,Loop
	push de
	ld c,_PARSE
	call BDOS
	xor a
	ld (de),a
	ld hl,VGMPlay_loadingFile
	call System_Print
	pop de
	push de
	ex de,hl
	call System_Print
	ld hl,VGMPlay_dotDotDot
	call System_Print
	pop de
	ld a,00000001B  ; read-only
	ld c,_OPEN
	call BDOS
	call VGMPlay_CheckDOSError
	ld (ix + VGMPlay.fileHandle),b
	ret
	ENDP

VGMPlay_ReadHeader:
	ld b,(ix + VGMPlay.fileHandle)
	push ix
	call VGMPlay_GetHeader
	ld hl,256
	ld c,_READ
	call BDOS
	call VGMPlay_CheckDOSError
	call Header_Constructor
	pop ix
	ret

VGMPlay_ShowInfo:
	call System_PrintCrLf
	push ix
	call VGMPlay_GetHeader
	call Header_ShowInfo
	pop ix
	ret

VGMPlay_ReadData:
	push ix
	call VGMPlay_GetHeader
	call Header_GetDataOffset
	pop ix
	ld a,0
	ld b,(ix + VGMPlay.fileHandle)
	ld c,_SEEK
	call BDOS
	call VGMPlay_CheckDOSError
	ld hl,9000H
	ld de,DATA
	ld b,(ix + VGMPlay.fileHandle)
	ld c,_READ
	call BDOS
	call VGMPlay_CheckDOSError
	push ix
	call VGMPlay_GetReader
	ld c,l
	ld b,h
	ld hl,DATA
	call DataReader_Constructor
	pop ix
	ret

VGMPlay_CloseFile:
	ld b,(ix + VGMPlay.fileHandle)
	ld c,_CLOSE
	call BDOS
	call VGMPlay_CheckDOSError
	ret

VGMPlay_Play:
	ld hl,VGMPlay_playing
	call System_Print
	push ix
	call VGMPlay_GetPlayer
	ld de,DataReader_instance
	call Player_Constructor
	call Player_Play
	pop ix
	ret

; hl <- current timer value, in 14 cycle increments
; Modifies: af, hl
VGMPlay_GetHighResTimerValue:
	in a,(0E7H)
	ld h,a
	in a,(0E6H)
	ld l,a
	in a,(0E7H)
	cp h
	ret z
	bit 7,l
	ret nz
	ld h,a
	ret

; a <- DOS error code
VGMPlay_CheckDOSError:
	and a
	ret z
VGMPlay_TerminateWithDOSError:
	ld b,a
	ld c,_EXPLAIN
	ld de,VGMPlay_explainBuffer
	call BDOS
	ld hl,VGMPlay_explainBuffer
	jp VGMPlay_TerminateWithError

; hl <- message
VGMPlay_TerminateWithError:
	call System_Print
	jp REBOOT

;
	SECTION RAM

VGMPlay_instance: VGMPlay

VGMPlay_welcome:
	db "VGMPlay 0.1 by Grauw",13,10,10,0

VGMPlay_loadingFile:
	db "Loading ",0

VGMPlay_dotDotDot:
	db "...",13,10,0

VGMPlay_playing:
	db 13,10,"Playing...",13,10,0

VGMPlay_dos2RequiredError:
	db "MSX-DOS 2 is required.",13,10,0

VGMPlay_invalidFilenameError:
	db "Invalid file name.",13,10,0

VGMPlay_explainBuffer:
	ds 64,0

	ENDS
