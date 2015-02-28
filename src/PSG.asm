;
; AY-3-8910 / YM2149 PSG
;
PSG: MACRO
	ADDRESS: equ 0A0H
	DATA: equ 0A1H
	found:
		db -1
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
		out (PSG.ADDRESS),a
		ld a,d
		ei
		out (PSG.DATA),a
		ret
	MaskMixer:
		ld a,d
		and 3FH
		or 80H
		ld d,a
		ld a,e
		jr WriteRegister
	ENDM

; ix = this
PSG_Install:
	call PSG_Reset
	ret

; ix = this
PSG_Uninstall:
	call PSG_Reset
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
; Workarea definition
;
	SECTION RAM

PSG_instance: PSG

	ENDS
