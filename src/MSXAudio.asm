;
; Y8950 MSX-AUDIO driver
;
MSXAudio: MACRO
	STATUS: equ 0C0H
	ADDRESS: equ 0C0H
	DATA: equ 0C1H
	found:
		db 0
	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp 20H
		jr c,MaskControl
	; a = register
	; d = value
	WriteRegister:
		di
		out (MSXAudio.ADDRESS),a
		ex (sp),hl  ; wait 12 cycles
		ex (sp),hl
		ld a,d
		ei
		out (MSXAudio.DATA),a
		ret
	MaskControl:
		cp 8H
		jr z,MaskROM_64K_DAAD_SAMPLE
		ret
	MaskROM_64K_DAAD_SAMPLE:
		ld a,d
		and 11000100B
		ld d,a
		ld a,e
		jr WriteRegister
	ENDM

; ix = this
MSXAudio_Install: PROC
	call MSXAudio_Detect
	jr nc,Disable
	di
	ld (ix + MSXAudio.found),-1
	ei
	ret
Disable:
	ld (ix + MSXAudio.SafeWriteRegister),0C9H  ; ret
	ld (ix + MSXAudio.WriteRegister),0C9H  ; ret
	ret
	ENDP

; ix = this
MSXAudio_Uninstall:
	ld a,(ix + MSXAudio.found)
	and a
	ret z
	call MSXAudio_Mute
	call MSXAudio_Reset
	ret

; ix = this
; e = register
; d = value
MSXAudio_WriteRegister:
	push ix
	pop hl
	ld bc,MSXAudio.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
MSXAudio_SafeWriteRegister:
	push ix
	pop hl
	ld bc,MSXAudio.SafeWriteRegister
	add hl,bc
	jp hl

; ix = this
MSXAudio_Mute: PROC
	ld b,22
	ld de,3F40H
Loop:
	push bc
	push de
	call MSXAudio_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz Loop
	ret
	ENDP

; ix = this
MSXAudio_Reset: PROC
	ld b,0C9H
	ld de,0000H
Loop:
	push bc
	push de
	call MSXAudio_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz Loop
	ret
	ENDP

; ix = this
; f <- c: Found
MSXAudio_Detect:
	in a,(MSXAudio.STATUS)
	cp 06H
	ret nz
	scf
	ret

;
; Workarea definition
;
	SECTION RAM

MSXAudio_instance: MSXAudio

	ENDS
