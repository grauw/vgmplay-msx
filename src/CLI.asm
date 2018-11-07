;
; Command-line interface parser
;
CLI_BUFFER_SIZE: equ 255

CLI: MACRO
	path:
		dw 0
	loops:
		db 2
	blackout:
		db 0
	ocmWorkaround:
		db 0
	buffer:
		ds CLI_BUFFER_SIZE
	_size:
	ENDM

; ix = this
; ix <- this
CLI_Construct:
	ld e,ixl
	ld d,ixh
	ld hl,CLI.buffer
	add hl,de
	ex de,hl
	ld hl,CLI_parametersEnvName
	ld b,CLI_BUFFER_SIZE
	call DOS_GetEnvironmentItem
	jp CLI_Parse

; ix = this
; ix <- this
CLI_Destruct: equ System_Return
;	ret

; ix = this
; hl <- path
CLI_GetPath:
	ld l,(ix + CLI.path)
	ld h,(ix + CLI.path + 1)
	ret

; ix = this
; de = buffer
CLI_Parse: PROC
Loop:
	ld a,(de)
	and a
	ret z
	cp "/"
	jr z,Option
	cp " "
	jr nz,Path
	inc de
	jr Loop
Option:
	call CLI_ParseOption
	jr Loop
Path:
	call CLI_ParsePath
	jr Loop
	ENDP

; de = buffer position
; ix = this
CLI_ParseOption: PROC
	inc de
	ld a,(de)
	and 11011111B  ; upper-case
	cp "L"
	jr z,OptionLoops
	cp "B"
	jr z,OptionBlackout
	cp "O"
	jr z,OptionOCMWorkaround
	ld hl,CLI_unknownOptionError
	jp System_TerminateWithError
OptionLoops:
	inc de
	call CLI_ParseNumber
	ld (ix + CLI.loops),c
	jr Next
OptionBlackout:
	ld (ix + CLI.blackout),-1
	inc de
	jr Next
OptionOCMWorkaround:
	ld (ix + CLI.ocmWorkaround),-1
	inc de
	jr Next
Next:
	ld a,(de)
	and a
	ret z
	cp " "
	ret z
	ld hl,CLI_unknownOptionError
	jp System_TerminateWithError
	ENDP

; de = buffer position
; ix = this
CLI_ParsePath:
	ld a,(ix + CLI.path)
	or (ix + CLI.path + 1)
	ld hl,CLI_multiplePathsError
	jp nz,System_TerminateWithError
	ld (ix + CLI.path),e
	ld (ix + CLI.path + 1),d
	call DOS_ParsePathname
	ld a,(de)
	and a
	ret z
	ld a,0
	ld (de),a
	inc de
	ret

; de = buffer position
; ix = this
; c <- value
CLI_ParseNumber: PROC
	ld c,0
	ld hl,CLI_unknownOptionError
Loop:
	ld a,(de)
	and a
	ret z
	cp " "
	ret z
	sub "0"
	jp c,System_TerminateWithError
	cp 10
	jp nc,System_TerminateWithError
	call Multiply10AndAdd
	inc de
	jr Loop
Multiply10AndAdd:
	ld b,a
	ld a,c
	ld c,b
	add a,a
	jp c,System_TerminateWithError
	ld b,a
	add a,a
	jp c,System_TerminateWithError
	add a,a
	jp c,System_TerminateWithError
	add a,b
	jp c,System_TerminateWithError
	add a,c
	jp c,System_TerminateWithError
	ld c,a
	ret
	ENDP

;
CLI_parametersEnvName:
	db "PARAMETERS",0

CLI_unknownOptionError:
	db "Unknown command line option.",13,10,0

CLI_multiplePathsError:
	db "Can not specify more than one file path.",13,10,0
