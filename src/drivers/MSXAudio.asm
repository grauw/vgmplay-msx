;
; Y8950 MSX-AUDIO driver
;

; ports
MSXAudio_STATUS_PORT: equ 0C0H
MSXAudio_ADDRESS_PORT: equ 0C0H
MSXAudio_DATA_PORT: equ 0C1H

; registers
MSXAudio_TEST: equ 01H
MSXAudio_TIMER_1: equ 02H
MSXAudio_TIMER_2: equ 03H
MSXAudio_FLAG_CONTROL: equ 04H
MSXAudio_KEYBOARD_IN: equ 05H
MSXAudio_KEYBOARD_OUT: equ 06H
MSXAudio_ADPCM_CONTROL: equ 07H
MSXAudio_MISC_CONTROL: equ 08H
MSXAudio_START_ADDRESS_L: equ 09H
MSXAudio_START_ADDRESS_H: equ 0AH
MSXAudio_STOP_ADDRESS_L: equ 0BH
MSXAudio_STOP_ADDRESS_H: equ 0CH
MSXAudio_PRESCALE_L: equ 0DH
MSXAudio_PRESCALE_H: equ 0EH
MSXAudio_ADPCM_DATA: equ 0FH
MSXAudio_DELTA_N_L: equ 10H
MSXAudio_DELTA_N_H: equ 11H
MSXAudio_ENVELOPE_CONTROL: equ 12H
MSXAudio_DAC_DATA_L: equ 15H
MSXAudio_DAC_DATA_H: equ 16H
MSXAudio_DAC_DATA_SHIFT: equ 17H
MSXAudio_IO_CONTROL: equ 18H
MSXAudio_IO_DATA: equ 19H
MSXAudio_PCM_DATA: equ 1AH
MSXAudio_FM_BASE: equ 20H

MSXAudio: MACRO
	found:
		db 0
	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp MSXAudio_FM_BASE
		jr c,MaskControl
	; a = register
	; d = value
	WriteRegister:
		di
		out (MSXAudio_ADDRESS_PORT),a
		ex (sp),hl  ; wait 12 cycles
		ex (sp),hl
		ld a,d
		ei
		out (MSXAudio_DATA_PORT),a
		ret
	MaskControl:
		cp MSXAudio_FLAG_CONTROL
		jr z,MaskFlagControl
		cp MSXAudio_MISC_CONTROL
		jr z,MaskMiscControl
		ret
	MaskFlagControl:
		ld a,d
		and 00000111B
		or 01111000B
		ld d,a
		ld a,e
		jr WriteRegister
	MaskMiscControl:
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

; b = count
; e = register base
; d = value
; ix = this
MSXAudio_FillRegisters:
	push bc
	push de
	call MSXAudio_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz MSXAudio_FillRegisters
	ret

; ix = this
MSXAudio_Mute:
	ld b,16H
	ld de,3F40H
	call MSXAudio_FillRegisters
	ret

; ix = this
MSXAudio_Reset:
	call MSXAudio_Mute
	ld b,040H
	ld de,0000H
	call MSXAudio_FillRegisters
	ld b,069H
	ld de,0060H
	call MSXAudio_FillRegisters
	ret

; ix = this
; f <- c: Found
MSXAudio_Detect:
	in a,(MSXAudio_STATUS_PORT)
	sub 06H
	and a
	ret nz
	scf
	ret

;
; Workarea definition
;
	SECTION RAM

MSXAudio_instance: MSXAudio

	ENDS
