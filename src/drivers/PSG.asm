;
; AY-3-8910 PSG / YM2149 SSG driver
;
PSG_ADDRESS: equ 0A0H
PSG_DATA: equ 0A1H

PSG: MACRO
	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp 14
		ret nc
		cp 7
		jr z,MaskMixer
	; a = register
	; d = value
	WriteRegister:
		di
		out (PSG_ADDRESS),a
		ld a,d
		ei
		out (PSG_DATA),a
		ret
	MaskMixer:
		ld a,d
		and 3FH
		or 80H
		ld d,a
		ld a,e
		jr WriteRegister

	; ix = player
	; iy = reader
	ProcessAY8910Command:
		call MappedReader_ReadWord_IY
		call SafeWriteRegister
		jp Player_ProcessNext
	ENDM

; ix <- instance or null
; de <- instance or null
PSG_TryCreate:
	ld ix,PSG_instance
	call PSG_Construct
	ld e,ixl
	ld d,ixh
	ret

; ix = this
PSG_Construct:
	call PSG_Reset
	ret

; ix = this
PSG_Destruct:
	call PSG_Reset
	ret

; ix = this
; iy = player
PSG_Install:
	ld hl,PSG.ProcessAY8910Command
	ld a,0A0H
	call Player_InstallCommandHandler_IY_IXOffset
	ret

; ix = this
; e = register
; d = value
PSG_WriteRegister:
	push ix
	pop hl
	ld bc,PSG.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
PSG_SafeWriteRegister:
	push ix
	pop hl
	ld bc,PSG.SafeWriteRegister
	add hl,bc
	jp hl

; ix = this
PSG_Reset: PROC
	ld de,0008H
	call PSG_WriteRegister
	ld de,0009H
	call PSG_WriteRegister
	ld de,000AH
	call PSG_WriteRegister
	ld b,14
	ld de,0000H
Loop:
	push bc
	push de
	call PSG_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz Loop
	ret
	ENDP

;
	SECTION RAM

PSG_instance: PSG

	ENDS
