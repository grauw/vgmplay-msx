;
; Command-line interface parser
;
CLI: MACRO
	path:
		dw 0
	buffer:
		ds 255
	size:
	ENDM

; hl = input buffer
; ix = this
; ix <- this
CLI_Constructor:
	call CLI_GetBuffer
	ld hl,CLI_parametersEnvName
	ld b,255
	ld c,_GENV
	call BDOS
	ret

; ix = this
; ix <- this
CLI_Destructor:
	ret

; ix = this
; de <- buffer
; Modifies: bc
CLI_GetBuffer:
	push ix
	pop de
	ld bc,CLI.buffer
	ex de,hl
	add hl,bc
	ex de,hl
	ret

; ix = this
CLI_Parse: PROC
	call CLI_GetBuffer
Loop:
	ld a,(de)
	and a
	ret z
	cp " "
	jr nz,Path
	inc de
	jp Loop
Path:
	call CLI_ParsePath
	jp Loop
	ENDP

; de = buffer position
; ix = this
CLI_ParsePath:
	ld a,(ix + CLI.path)
	or (ix + CLI.path + 1)
	ld hl,CLI_multiplePathsError
	call nz,VGMPlay_TerminateWithError
	ld (ix + CLI.path),e
	ld (ix + CLI.path + 1),d
	ld c,_PARSE
	call BDOS
	ld a,(de)
	and a
	ret z
	ld a,0
	ld (de),a
	inc de
	ret

;
	SECTION RAM

CLI_instance: CLI

CLI_parametersEnvName:
	db "PARAMETERS",0

CLI_multiplePathsError:
	db "Can not specify more than one file path.",13,10,0

	ENDS
