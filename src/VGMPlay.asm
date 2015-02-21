;
; Top-level VGMPlay program class
;
VGMPlay: MACRO
	fileHandle:
		db 0
	sfg:
		dw 0
	ENDM

;
VGMPlay_Main:
	call DOS_IsDOS2
	jp c,VGMPlay_ThrowDOS2RequiredError

	ld hl,VGMPlay_welcome
	call System_Print

;	call System_EnableTurbo

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
	ret

; ix = this
VGMPlay_EnterMainLoop:
	call VGMPlay_OpenFile
	call VGMPlay_ReadHeader
	call VGMPlay_ShowInfo
	call VGMPlay_CloseFile

	call VGMPlay_MainLoop
	ret

VGMPlay_OpenFile: PROC
	ld de,DTA
Loop:
	inc de
	ld a,(de)
	and a
	jp z,VGMPlay_ThrowInvalidFilenameError
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
	ld de,VGMHeader_instance
	ld hl,256
	ld c,_READ
	call BDOS
	call VGMPlay_CheckDOSError
	push ix
	ld ix,VGMHeader_instance
	call VGMHeader_Constructor
	pop ix
	ret

VGMPlay_ShowInfo:
	call System_PrintCrLf
	push ix
	ld ix,VGMHeader_instance
	call VGMHeader_ShowInfo
	pop ix
	ret

VGMPlay_CloseFile:
	ld b,(ix + VGMPlay.fileHandle)
	ld c,_CLOSE
	call BDOS
	call VGMPlay_CheckDOSError
	ret

VGMPlay_MainLoop:
	; ...
;	ld b,8
;	call VGMPlay_GetKeyRow
;	and 00000001B
;	jp nz,VGMPlay_MainLoop
	ret

; b = row number
; a <- row bits
VGMPlay_GetKeyRow:
	di
	in a,(PPI_PORT_C)
	and 11110000B
	or b
	out (PPI_PORT_C),a
	ei
	in a,(PPI_PORT_B)
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

VGMPlay_ThrowDOS2RequiredError:
	ld hl,VGMPlay_dos2Required
	call System_Print
	jp REBOOT

VGMPlay_ThrowInvalidFilenameError:
	ld hl,VGMPlay_invalidFilename
	call System_Print
	jp REBOOT

; a <- DOS error code
VGMPlay_CheckDOSError:
	and a
	ret z
VGMPlay_ThrowDOSError:
	ld b,a
	ld c,_EXPLAIN
	ld de,VGMPlay_explainBuffer
	call BDOS
	ld hl,VGMPlay_explainBuffer
	call System_Print
	jp REBOOT

;
	SECTION RAM

VGMPlay_instance: VGMPlay

VGMPlay_welcome:
	db "VGMPlay 0.1",13,10,10,0

VGMPlay_loadingFile:
	db "Loading ",0

VGMPlay_dotDotDot:
	db "...",13,10,0

VGMPlay_dos2Required:
	db "MSX-DOS 2 is required.",13,10,0

VGMPlay_invalidFilename:
	db "Invalid file name.",13,10,0

VGMPlay_explainBuffer:
	ds 64,0

	ENDS
