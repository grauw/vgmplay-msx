;
; Top-level application program class
;
Application: MACRO
	cli:
		CLI
	loader:
		MappedBufferLoader
	reader:
		MappedReader
	drivers:
		Drivers
	vgm:
		VGM
	size:
	ENDM

;
Application_Main:
	call DOS_IsDOS2
	ld hl,Application_dos2RequiredError
	jp c,Application_TerminateWithError

	call Application_CheckStack

	call VDP_InitMirrorsOnVDPUpgrades

	ld hl,Application_welcome
	call System_Print

	call System_EnableTurbo
;	call System_DisableTurbo

	ld ix,Mapper_instance
	call Mapper_Construct
	ld ix,Heap_main
	call Heap_Construct

	call MemoryTest_Test
	call HeapTest_Test

	call Player_InitCommandsJumpTable

	ld ix,Application_instance
	call Application_Construct
	ld de,Application_Abort
	call DOS_DefineAbortExitRoutine
	call Application_EnterMainLoop
	call Application_Abort
	ret

; DOS error or abort handler
Application_Abort:
	push af
	push bc
	ld ix,Application_instance
	call Application_Destruct
	ld ix,Mapper_instance
	call Mapper_Destruct
	call Application_ExitBlackout
	pop bc
	pop af
	ret

; ix = this
; ix <- this
Application_Construct:
	push ix
	call Application_GetCLI
	call CLI_Construct
	pop ix
	push ix
	call Application_GetDrivers
	call Drivers_Construct
	pop ix
	ret

; ix = this
; ix <- this
Application_Destruct:
	push ix
	call Application_GetCLI
	call CLI_Destruct
	pop ix
	push ix
	call Application_GetDrivers
	call Drivers_Destruct
	pop ix
	ret

; ix = this
; ix <- Command-line interface
Application_GetCLI:
	ld de,Application.cli
	add ix,de
	ret

; ix = this
; ix <- loader
Application_GetLoader:
	ld de,Application.loader
	add ix,de
	ret

; ix = this
; ix <- reader
Application_GetReader:
	ld de,Application.reader
	add ix,de
	ret

; ix = this
; ix <- driver manager
Application_GetDrivers:
	ld de,Application.drivers
	add ix,de
	ret

; ix = this
; ix <- VGM
Application_GetVGM:
	ld de,Application.vgm
	add ix,de
	ret

; ix = this
Application_EnterMainLoop:
	call Application_ParseCLI
	call Application_LoadFile
	call Application_ConstructVGM
	call Application_EnterBlackout
	call Application_Play
	ret

; ix = this
Application_ParseCLI: PROC
	push ix
	call Application_GetCLI
	call CLI_Parse
	call CLI_GetPath
	ld a,l
	or h
	ld hl,Application_usageInstructions
	jp z,Application_TerminateWithError
	call Frequency
	pop ix
	ret
Frequency:
	call VDP_GetVersion
	ret z
	ld a,(ix + CLI.frequency)
	cp 50
	jp z,VDP_Enable50Hz
	jp VDP_Enable60Hz
	ENDP

; ix = this
Application_LoadFile: PROC
	push ix
	call Application_GetCLI
	call CLI_GetPath
	pop ix
	push ix
	push hl
	ld hl,Application_loadingFile
	call System_Print
	pop hl
	push hl
	call System_Print
	ld hl,Application_dotDotDot
	call System_Print
	call Application_GetLoader
	pop de
	ld hl,MappedBuffer_instance
	call MappedBufferLoader_Construct
	call MappedBufferLoader_Load
	call MappedBufferLoader_Destruct
	pop ix
	push ix
	call Application_GetReader
	ld hl,MappedBuffer_instance
	call MappedReader_Construct
	pop ix
	ret
	ENDP

; ix = this
Application_ConstructVGM:
	push ix
	push ix
	push ix
	call Application_GetDrivers
	ex (sp),ix
	pop hl
	call Application_GetReader
	ex (sp),ix
	call Application_GetVGM
	pop de
	call VGM_Construct
	call VGM_PrintInfo
	pop ix
	ret

; ix = this
Application_Play:
	ld hl,Application_playing
	call System_Print
	push ix
	call Application_GetCLI
	ld a,(ix + CLI.loops)
	pop ix
	push ix
	call Application_GetVGM
	call VGM_Play
	pop ix
	ret

; If enabled, blacks out the screen to minimise audio output interference.
; ix = this
Application_EnterBlackout:
	push ix
	call Application_GetCLI
	ld a,(ix + CLI.blackout)
	pop ix
	and a
	ret z
	ld a,00H
	call VDP_SetColor
	call VDP_EnableBlank
	ret

; ix = this
Application_ExitBlackout:
	ld a,(VDP_MIRROR_0 + 7)
	call VDP_SetColor
	call VDP_DisableBlank
	ret

; Check if the stack is well above the heap
Application_CheckStack:
	ld hl,-(HEAP + HEAP_SIZE + STACK_SIZE)
	add hl,sp
	ld hl,Application_insufficientTPAError
	jp nc,Application_TerminateWithError
	ret

; a <- DOS error code
Application_CheckDOSError:
	and a
	ret z
Application_TerminateWithDOSError:
	ld b,a
	ld de,Application_explainBuffer
	call DOS_ExplainErrorCode
	ld hl,Application_explainBuffer
	call System_Print
	call System_PrintCrLf
	jp DOS_Terminate

; hl <- message
Application_TerminateWithError:
	call System_Print
	jp DOS_Terminate

;
	SECTION RAM

Application_instance: Application

Application_explainBuffer:
	ds 64,0

	ENDS

Application_welcome:
	db "VGMPlay 1.1 by Grauw",13,10,10,0

Application_loadingFile:
	db "Loading ",0

Application_dotDotDot:
	db "...",13,10,0

Application_playing:
	db 13,10,"Playing...",13,10,0

Application_dos2RequiredError:
	db "MSX-DOS 2 is required.",13,10,0

Application_insufficientTPAError:
	db "Insufficient TPA space.",13,10,0

Application_usageInstructions:
	db "Usage: vgmplay [options] <file.vgm>",13,10
	db 13,10
	db "Options:",13,10
	db "  /l  Number of playback loops. Default: 2.",13,10
	db "  /5  50 Hz screen frequency (V9938 and up only).",13,10
	db "  /b  Enter blackout mode during playback.",13,10,0
