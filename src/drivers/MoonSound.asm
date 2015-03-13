;
; MoonSound YMF278B OPL4
;
MoonSound: MACRO
	STATUS: equ 0C4H
	FM_ADDRESS: equ 0C4H
	FM_DATA: equ 0C5H
	FM2_ADDRESS: equ 0C6H
	FM2_DATA: equ 0C7H
	WAVE_ADDRESS: equ 07EH
	WAVE_DATA: equ 07FH
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
		out (MoonSound.FM_ADDRESS),a
		nop     ; wait 56 cycles (11.8 R800 cycles)
		ld a,d
		out (MoonSound.FM_DATA),a
		ret
	MaskControl:
		cp 8H
		jr z,WriteRegister
		ret

	; e = register
	; d = value
	SafeWriteRegister2:
		ld a,e
	; a = register
	; d = value
	WriteRegister2:
		out (MoonSound.FM2_ADDRESS),a
		nop     ; wait 56 cycles (11.8 R800 cycles)
		ld a,d
		out (MoonSound.FM2_DATA),a
		ret

	; e = register
	; d = value
	SafeWriteRegisterWave:
		ld a,e
		cp 8H
		ret c
	; a = register
	; d = value
	WriteRegisterWave:
		out (MoonSound.WAVE_ADDRESS),a
		cp (ix)  ; wait 88 cycles (18.6 R800 cycles, but 18 works)
		ld a,d
		out (MoonSound.WAVE_DATA),a
		ret
	ENDM

; ix = this
MoonSound_Install: PROC
	call MoonSound_Detect
	jr nc,Disable
	ld (ix + MoonSound.found),-1
	call MoonSound_Reset
	ret
Disable:
	ld (ix + MoonSound.SafeWriteRegister),0C9H  ; ret
	ld (ix + MoonSound.WriteRegister),0C9H  ; ret
	ld (ix + MoonSound.SafeWriteRegister2),0C9H  ; ret
	ld (ix + MoonSound.WriteRegister2),0C9H  ; ret
	ld (ix + MoonSound.SafeWriteRegisterWave),0C9H  ; ret
	ld (ix + MoonSound.WriteRegisterWave),0C9H  ; ret
	ret
	ENDP

; ix = this
MoonSound_Uninstall:
	ld a,(ix + MoonSound.found)
	and a
	ret z
	call MoonSound_Reset
	ret

; ix = this
; e = register
; d = value
MoonSound_WriteRegister:
	push ix
	pop hl
	ld bc,MoonSound.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
MoonSound_SafeWriteRegister:
	push ix
	pop hl
	ld bc,MoonSound.SafeWriteRegister
	add hl,bc
	jp hl

; ix = this
; e = register
; d = value
MoonSound_WriteRegister2:
	push ix
	pop hl
	ld bc,MoonSound.WriteRegister2
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
MoonSound_SafeWriteRegister2:
	push ix
	pop hl
	ld bc,MoonSound.SafeWriteRegister2
	add hl,bc
	jp hl

; ix = this
; e = register
; d = value
MoonSound_WriteRegisterWave:
	push ix
	pop hl
	ld bc,MoonSound.WriteRegisterWave
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
MoonSound_SafeWriteRegisterWave:
	push ix
	pop hl
	ld bc,MoonSound.SafeWriteRegisterWave
	add hl,bc
	jp hl

; b = count
; e = register base
; d = value
; ix = this
MoonSound_FillRegisters:
	push bc
	push de
	call MoonSound_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz MoonSound_FillRegisters
	ret

; b = count
; e = register base
; d = value
; ix = this
MoonSound_FillRegisters2:
	push bc
	push de
	call MoonSound_SafeWriteRegister2
	pop de
	pop bc
	inc e
	djnz MoonSound_FillRegisters2
	ret

; b = count
; e = register base
; d = value
; ix = this
MoonSound_FillRegistersWave:
	push bc
	push de
	call MoonSound_SafeWriteRegisterWave
	pop de
	pop bc
	inc e
	djnz MoonSound_FillRegistersWave
	ret

; ix = this
MoonSound_Mute:
	ld b,16H
	ld de,3F40H
	call MoonSound_FillRegisters
	ld b,16H
	ld de,3F40H
	call MoonSound_FillRegisters2
	ld b,048H
	ld de,0FF98H
	call MoonSound_FillRegistersWave
	ld b,18H
	ld de,0FF50H
	call MoonSound_FillRegistersWave
	ret

; ix = this
MoonSound_Reset:
	call MoonSound_Mute
	ld b,0DAH
	ld de,0020H
	call MoonSound_FillRegistersWave
	ld de,1BF8H
	call MoonSound_SafeWriteRegisterWave
	ld b,020H
	ld de,0020H
	call MoonSound_FillRegisters
	ld b,020H
	ld de,0020H
	call MoonSound_FillRegisters2
	ld b,096H
	ld de,0060H
	call MoonSound_FillRegisters
	ld b,096H
	ld de,0060H
	call MoonSound_FillRegisters2
	ld b,020H
	ld de,0000H
	call MoonSound_FillRegisters
	ld b,020H
	ld de,0000H
	call MoonSound_FillRegisters2
	ret

; ix = this
; f <- c: Found
MoonSound_Detect:
	in a,(MoonSound.STATUS)
	and 11111101B  ; sometimes LD is set
	sub 00H
	and a
	ret nz
	scf
	ret

;
; Workarea definition
;
	SECTION RAM

MoonSound_instance: MoonSound

	ENDS
