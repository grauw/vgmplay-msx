;
; Top-level application program class
;
Application_VGMREADER_BASE_ADDRESS: equ 8000H

Application: MACRO
	vgmReference:
		dw 0
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
	ld hl,DOS_Terminate
	call System_SetTerminateHandler

	call DOS_IsDOS2
	ld hl,Application_dos2RequiredError
	jp c,System_TerminateWithError

	call Application_CheckStack

	call VDP_InitMirrorsOnVDPUpgrades

	ld hl,Application_welcome
	call System_Print

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
	ld ix,Mapper_instance
	call Mapper_RestoreInitialState
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
	call Application_GetVGMReference
	ld a,e
	or d
	call nz,VGM_Destruct
	pop ix
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
; ix <- VGM
Application_GetVGMReference:
	ld e,(ix + Application.vgmReference)
	ld d,(ix + Application.vgmReference + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
Application_EnterMainLoop:
	call Application_ParseCLI
	call Application_CheckOCM
	call Application_LoadFile
	call Application_ConstructVGM
	call Application_EnterBlackout
	call Application_Play
	ret

; ix = this
Application_ParseCLI:
	push ix
	call Application_GetCLI
	call CLI_Parse
	call CLI_GetPath
	ld a,l
	or h
	ld hl,Application_usageInstructions
	jp z,System_TerminateWithError
	pop ix
	ret

; ix = this
Application_LoadFile:
	call Application_PrintLoading
	call Application_ConstructMappedBuffer
	call Application_IsVGZ
	jp z,Application_InflateFile
	push ix
	call Application_GetCLI
	call CLI_GetPath
	pop ix
	push ix
	call Application_GetLoader
	ld de,MappedBuffer_instance
	call MappedBufferLoader_Construct
	call MappedBufferLoader_Load
	call MappedBufferLoader_Destruct
	pop ix
	ret

; ix = this
Application_ConstructMappedBuffer:
	push ix
	ld ix,MappedBuffer_instance
	call MappedBuffer_Construct
	ld h,80H
	call Memory_GetSlot
	ld b,a
	call Mapper_instance.GetP2
	call MappedBuffer_SetFreebie
	pop ix
	ret

; ix = this
; f <- z: is vgz
Application_IsVGZ:
	push ix
	call Application_GetCLI
	call CLI_GetPath
	pop ix
	ld a,0
	ld bc,256
	cpir
	dec hl
	dec hl
	ld a,(hl)
	and 11011111B  ; upper-case
	cp "Z"
	ret nz
	dec hl
	ld a,(hl)
	and 11011111B  ; upper-case
	cp "G"
	ret nz
	dec hl
	ld a,(hl)
	and 11011111B  ; upper-case
	cp "V"
	ret nz
	dec hl
	ld a,(hl)
	cp "."
	ret

; ix = this
Application_InflateFile:
	push ix
	call Application_GetCLI
	call CLI_GetPath
	pop ix
	ex de,hl
	ld hl,READBUFFER
	ld bc,READBUFFER_SIZE
	push ix
	call FileReader_class.New
	call FileReader_Construct
	push ix
	ld a,GZIP_CRC32 ? -1 : 0
	call GzipArchive_class.New
	call GzipArchive_Construct
	push ix
	call Mapped32KWriter_class.New
	ld de,MappedBuffer_instance
	call Mapped32KWriter_Construct
	ld e,ixl
	ld d,ixh
	ex (sp),ix
	call GzipArchive_Extract
	ex (sp),ix
	call Mapped32KWriter_Destruct
	call Mapped32KWriter_class.Delete
	pop ix
	call GzipArchive_Destruct
	call GzipArchive_class.Delete
	pop ix
	call FileReader_Destruct
	call FileReader_class.Delete
	pop ix
	ret

; ix = this
Application_PrintLoading:
	ld hl,Application_loadingFile
	call System_Print
	push ix
	call Application_GetCLI
	call CLI_GetPath
	pop ix
	call System_Print
	ld hl,Application_dotDotDot
	call System_Print
	ret

; ix = this
Application_ConstructVGM:
	push ix
	push ix
	call Application_GetDrivers
	ex (sp),ix
	push ix
	call Application_GetReader
	ld de,MappedBuffer_instance
	ld hl,Application_VGMREADER_BASE_ADDRESS
	call MappedReader_Construct
	ex (sp),ix
	call Application_GetVGM
	pop de
	pop hl
	call VGM_Construct
	call VGM_PrintInfo
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + Application.vgmReference),e
	ld (ix + Application.vgmReference + 1),d
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

; ix = this
Application_CheckOCM: PROC
	push ix
	call Application_GetCLI
	ld a,(ix + CLI.ocmWorkaround)
	pop ix
	and a
	jr nz,ActivateWorkaround
	in a,(40H)
	push af
	ld a,0D4H
	out (40H),a
	in a,(40H)
	cp ~0D4H
	jr nz,Return
	ld hl,Application_ocmWarning
	call System_Print
Return:
	pop af
	cpl
	out (40H),a
	ret
ActivateWorkaround:
	call ClearBottomLines
	ld a,(VDP_MIRROR_8 + 9)
	and 11111101B
	or 10000000B
	ld (VDP_MIRROR_8 + 9),a
	ld b,9
	call VDP_SetRegister
	ret
ClearBottomLines:
	call VDP_GetModeFlags
	cp VDP_MODE_GRAPHIC1
	jr z,Graphic1
	cp VDP_MODE_TEXT1
	jr z,Text1
	cp VDP_MODE_TEXT2
	jr z,Text2
	ret
Graphic1:
	ld a,0
	ld hl,(T32NAM)
	ld de,24 * 32
	add hl,de
	call VDP_SetWriteAddress
	ld a,0
	ld bc,3 * 32
	call VDP_Fill
	ret
Text1:
	ld a,0
	ld hl,(TXTNAM)
	ld de,24 * 40
	add hl,de
	call VDP_SetWriteAddress
	ld a,0
	ld bc,1024 - (24 * 40)  ; table address wraps at offset 1024
	call VDP_Fill
	ret
Text2:
	ld a,0
	ld hl,(TXTNAM)
	ld de,24 * 80
	add hl,de
	call VDP_SetWriteAddress
	ld a,0
	ld bc,3 * 80
	call VDP_Fill
	ret
	ENDP

; Check if the stack is well above the heap
Application_CheckStack:
	ld hl,-(HEAP + HEAP_SIZE + STACK_SIZE)
	add hl,sp
	ld hl,Application_insufficientTPAError
	jp nc,System_TerminateWithError
	ret

; a = DOS error code
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
	jp System_TerminateWithError

;
	SECTION RAM

Application_instance: Application

Application_explainBuffer:
	ds 64,0

	ENDS

Application_welcome:
	db "VGMPlay 1.2 by Grauw",13,10,10,0

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

Application_ocmWarning:
	db "Note: due to a 1chipMSX bug, the timing is incorrect. If music plays "
	db "too slowly, use the /o command line option to activate the "
	db "workaround.",13,10,10,0

Application_usageInstructions:
	db "Usage: vgmplay [options] <file.vgm>",13,10
	db 13,10
	db "Options:",13,10
	db "  /l  Number of playback loops. Default: 2.",13,10
	db "  /b  Enter blackout mode during playback.",13,10
	db "  /o  Activate 1chipMSX timing workaround.",13,10,0
