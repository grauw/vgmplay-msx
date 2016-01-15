;
; OPN YM2203
;
OPN_ADDRESS: equ 12H
OPN_DATA: equ 13H
OPN_FREQUENCY: equ 3579545

OPN: MACRO
	super: Driver

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp 27H
		jr z,MaskControl
	; a = register
	; d = value
	WriteRegister: PROC
		out (OPN_ADDRESS),a
		in a,(OPN_ADDRESS)  ; wait 17 cycles
		in a,(OPN_ADDRESS)
		or (hl)
		ld a,d
		out (OPN_DATA),a
		ld c,OPN_ADDRESS
	Wait:
		in a,(c)
		ret p
		jp Wait
		ENDP
	MaskControl:
		ld a,d
		and 11110011B
		ld d,a
		ld a,e
		jr WriteRegister
	ENDM

; ix = this
OPN_Construct:
	ld bc,OPN_name
	ld de,OPN_FREQUENCY >> 16
	ld hl,OPN_FREQUENCY
	call Driver_Construct
	call OPN_Reset
	ret

; ix = this
OPN_Destruct:
	call OPN_Mute
	ret

; ix = this
; e = register
; d = value
OPN_WriteRegister:
	push ix
	pop hl
	ld bc,OPN.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; ix = this
; e = register
; d = value
OPN_SafeWriteRegister:
	push ix
	pop hl
	ld bc,OPN.SafeWriteRegister
	add hl,bc
	jp hl

; b = count
; e = register base
; d = value
; ix = this
OPN_FillRegisters:
	push bc
	push de
	call OPN_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz OPN_FillRegisters
	ret

; ix = this
OPN_Mute: PROC
	ld b,0EH
	ld de,07F40H
	call OPN_FillRegisters		; TL
	ld de,0022H					; Reset LFO
	call OPN_WriteRegister
	ld de,0027H					; Disable CSM/Timers
	call OPN_WriteRegister
	ld de,0028H					; KEY-OFF 1
	call OPN_WriteRegister
	ld de,0128H					; KEY-OFF 2
	call OPN_WriteRegister
	ld de,0228H					; KEY-OFF 3
	call OPN_WriteRegister
	ld de,0428H					; KEY-OFF 4
	call OPN_WriteRegister
	ld de,0528H					; KEY-OFF 5
	call OPN_WriteRegister
	ld de,0628H					; KEY-OFF 6
	call OPN_WriteRegister
	ld de,002BH					; Toggle DAC off
	call OPN_WriteRegister
	ld de,0008H
	call OPN_WriteRegister
	ld de,0009H
	call OPN_WriteRegister
	ld de,000AH
	call OPN_WriteRegister
	ld b,14
	ld de,0000H
PSGLoop:
	push bc
	push de
	call OPN_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz PSGLoop
	ret
	ENDP

; ix = this
OPN_Reset:
	ld b,83H
	ld de,0030H
	call OPN_FillRegisters		; Zero fill registers
	ld b,03H
	ld de,0C0B4H
	call OPN_FillRegisters		; Reset the PANPOTs to middle (monaural)
	ret

; ix = this
; f <- c: Found
OPN_Detect:
;	in a,(OPN_ADDRESS)
	and a
;	ret nz
;	scf
	ret

;
OPN_name:
	db "OPN",0

	SECTION RAM

OPN_instance: OPN

	ENDS
