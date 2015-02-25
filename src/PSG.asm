;
; AY-3-8910 / YM2149 PSG
;
PSG: MACRO
	ADDRESS: equ 0A0H
	DATA: equ 0A1H
	found:
		db -1
	ENDM

; ix = this
PSG_Install:
	ret

; ix = this
PSG_Uninstall:
	call PSG_Reset
	ret

; ix = this
; l = register
; h = value
PSG_WriteRegister:
	ld a,l
	di
	out (PSG.ADDRESS),a
	ld a,h
	ei
	out (PSG.DATA),a
	ret

; ix = this
; l = register
; h = value
PSG_SafeWriteRegister: PROC
	ld a,l
	cp 13
	ret nc
	cp 7
	jp nz,PSG_WriteRegister
MaskMixer:
	ld a,h
	and 3FH
	or 80H
	ld h,a
	jp PSG_WriteRegister
	ENDP

; ix = this
PSG_Reset:
	ld hl,0008H
	call PSG_WriteRegister
	ld hl,0009H
	call PSG_WriteRegister
	ld hl,000AH
	call PSG_WriteRegister
	ld hl,0B807H
	call PSG_WriteRegister
	ret

;
; Workarea definition
;
	SECTION RAM

PSG_instance: PSG

	ENDS
