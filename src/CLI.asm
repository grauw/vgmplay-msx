;
; Command-line interface parser
;
CLI: MACRO
	path:
		dw 0
	buffer:
		ds 128
	size:
	ENDM

; hl = input buffer
; ix = this
; ix <- this
CLI_Constructor:
	call CLI_GetBuffer
	ld bc,128
	ldir
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
	inc de
	ld a,(de)
	and a
	ld hl,CLI_invalidFilenameError
	call z,VGMPlay_TerminateWithError
	cp " "
	jr z,Loop
	ld (ix + CLI.path),e
	ld (ix + CLI.path + 1),d
	ld c,_PARSE
	call BDOS
	xor a
	ld (de),a
	ret
	ENDP

;
	SECTION RAM

CLI_instance: CLI

CLI_invalidFilenameError:
	db "Invalid file name.",13,10,0

	ENDS
