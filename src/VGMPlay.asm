;
; Top-level VGMPlay program class
;
VGMPlay: MACRO
	header:
		dw Header_instance
	reader:
		dw Reader_instance
	player:
		dw Player_instance
	psg:
		dw PSG_instance
	sfg:
		dw SFG_instance
	msxMusic:
		dw MSXMusic_instance
	msxAudio:
		dw MSXAudio_instance
	size:
	ENDM

;
VGMPlay_Main:
	call DOS_IsDOS2
	ld hl,VGMPlay_dos2RequiredError
	call c,VGMPlay_TerminateWithError

	call VDP_InitMirrorsOnVDPUpgrades
	call VDP_GetVersion
	call nz,VDP_Enable60Hz

	ld hl,VGMPlay_welcome
	call System_Print

	call System_EnableTurbo
;	call System_DisableTurbo

	ld ix,Mapper_instance
	call Mapper_Constructor
	ld ix,Heap_heap
	call Heap_Constructor
	ld ix,Heap_heapUpper
	call Heap_Constructor

	call Memory_UnitTest
	call Heap_UnitTest

	call Player_InitCommandsJumpTable

	ld ix,VGMPlay_instance
	call VGMPlay_Constructor
	ld de,VGMPlay_Abort
	call VGMPlay_SetAbortHandler
	call VGMPlay_EnterMainLoop
	call VGMPlay_Abort
	ret

; DOS error or abort handler
VGMPlay_Abort:
	push af
	push bc
	ld ix,VGMPlay_instance
	call VGMPlay_Destructor
	ld ix,Mapper_instance
	call Mapper_Destructor
	pop bc
	pop af
	ret

; de = abort handler
; ix = this
VGMPlay_SetAbortHandler:
	ld c,_DEFAB
	call BDOS
	ret

; ix = this
; ix <- this
VGMPlay_Constructor:
	push ix
	call VGMPlay_GetPSG
	call PSG_Install
	pop ix
	push ix
	call VGMPlay_GetSFG
	call SFG_Install
	pop ix
	push ix
	call VGMPlay_GetMSXMusic
	call MSXMusic_Install
	pop ix
	push ix
	call VGMPlay_GetMSXAudio
	call MSXAudio_Install
	pop ix
	ret

; ix = this
; ix <- this
VGMPlay_Destructor:
	push ix
	call VGMPlay_GetPSG
	call PSG_Uninstall
	pop ix
	push ix
	call VGMPlay_GetSFG
	call SFG_Uninstall
	pop ix
	push ix
	call VGMPlay_GetMSXMusic
	call MSXMusic_Uninstall
	pop ix
	push ix
	call VGMPlay_GetMSXAudio
	call MSXAudio_Uninstall
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
; de <- PSG driver
; ix <- PSG driver
VGMPlay_GetPSG:
	ld e,(ix + VGMPlay.psg)
	ld d,(ix + VGMPlay.psg + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- SFG driver
; ix <- SFG driver
VGMPlay_GetSFG:
	ld e,(ix + VGMPlay.sfg)
	ld d,(ix + VGMPlay.sfg + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- MSX-MUSIC driver
; ix <- MSX-MUSIC driver
VGMPlay_GetMSXMusic:
	ld e,(ix + VGMPlay.msxMusic)
	ld d,(ix + VGMPlay.msxMusic + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- MSX-AUDIO driver
; ix <- MSX-AUDIO driver
VGMPlay_GetMSXAudio:
	ld e,(ix + VGMPlay.msxAudio)
	ld d,(ix + VGMPlay.msxAudio + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
VGMPlay_EnterMainLoop:
	call VGMPlay_LoadFile
	call VGMPlay_ReadHeader
	call VGMPlay_ShowInfo
	call VGMPlay_Play
	ret

; ix = this
VGMPlay_LoadFile: PROC
	push ix
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
	pop hl
	push hl
	call System_Print
	ld hl,VGMPlay_dotDotDot
	call System_Print
	call VGMPlay_GetReader
	pop hl
	call Reader_Constructor
	pop ix
	ret
	ENDP

; ix = this
VGMPlay_ReadHeader:
	push ix
	ld bc,256
	ld l,(ix + VGMPlay.header)
	ld h,(ix + VGMPlay.header + 1)
	call VGMPlay_GetReader
	ex de,hl
	call Reader_ReadBlock
	pop ix
	push ix
	call VGMPlay_GetHeader
	call Header_Constructor
	pop ix
	ret

; ix = this
VGMPlay_ShowInfo:
	push ix
	call VGMPlay_GetHeader
	call Header_GetGD3Offset
	pop ix
	push ix
	push de
	call VGMPlay_GetReader
	pop de
	call nz,System_PrintCrLf
	call nz,GD3_ShowTagInfoEnglish
	pop ix
	push ix
	call VGMPlay_GetHeader
	call System_PrintCrLf
	call Header_ShowInfo
	pop ix
	ret

; ix = this
VGMPlay_Play:
	ld hl,VGMPlay_playing
	call System_Print
	push ix
	ld e,(ix + VGMPlay.reader)
	ld d,(ix + VGMPlay.reader + 1)
	ld l,(ix + VGMPlay.header)
	ld h,(ix + VGMPlay.header + 1)
	push de
	call VGMPlay_GetPlayer
	pop de
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
	call System_Print
	call System_PrintCrLf
	ld b,1
	ld c,_TERM
	call BDOS

; hl <- message
VGMPlay_TerminateWithError:
	call System_Print
	ld b,1
	ld c,_TERM
	call BDOS

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
