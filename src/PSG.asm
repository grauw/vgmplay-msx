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
	; h = value
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
	ld a,e
	di
	out (PSG.ADDRESS),a
	ld a,d
	ei
	out (PSG.DATA),a
	ret

; ix = this
; e = register
; d = value
PSG_SafeWriteRegister: PROC
	ld a,e
	cp 13
	ret nc
	cp 7
	jp nz,PSG_WriteRegister
MaskMixer:
	ld a,d
	and 3FH
	or 80H
	ld d,a
	jp PSG_WriteRegister
	ENDP

; ix = this
PSG_Reset: PROC
	ld de,0008H
	call PSG_WriteRegister
	ld de,0009H
	call PSG_WriteRegister
	ld de,000AH
	call PSG_WriteRegister
	ld bc,13
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
