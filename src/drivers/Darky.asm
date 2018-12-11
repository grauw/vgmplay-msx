;
; Supersoniqs Darky AY8930 EPSG x2
;
Darky_BASE_PORT_1: equ 44H
Darky_BASE_PORT_2: equ 4CH
Darky_ADDRESS: equ 00H
Darky_DATA: equ 01H
Darky_DEVICE_ID: equ 0AAH
Darky_FREQUENCY: equ 1789773

Darky: MACRO ?base, ?name = Darky_name
	super: Driver ?name, Driver_PrintInfoImpl

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
	; a = register
	; d = value
	WriteRegister:
		ld bc,Darky_DEVICE_ID << 8 | 40H
		in e,(c)
		out (c),b
		out (?base + Darky_ADDRESS),a
		ld a,d
		out (?base + Darky_DATA),a
		ld a,e
		cpl
		out (c),a
		ret
	ENDM

; ix = this
; iy = drivers
Darky_Construct:
	call Driver_Construct
	call Darky_Detect
	ret nc
	call Darky_Enable
	call Darky_Reset
	ld de,Darky_FREQUENCY >> 16
	ld hl,Darky_FREQUENCY
	jp Driver_SetClock

; ix = this
Darky_Destruct:
	call Driver_IsFound
	ret nc
	call Darky_Reset
	call Darky_Disable
	ret

; ix = this
Darky_Enable:
	ld bc,Darky_DEVICE_ID << 8 | 40H
	in e,(c)
	out (c),b
	ld a,40H | 80H
	call Darky_WriteMicrocontrollerRegister
	ld a,00000000B
	call Darky_WriteMicrocontrollerRegister
	ld a,e
	cpl
	out (c),a
	ret

; ix = this
Darky_Disable:
	ld bc,Darky_DEVICE_ID << 8 | 40H
	in e,(c)
	out (c),b
	ld a,40H | 80H
	call Darky_WriteMicrocontrollerRegister
	ld a,00000111B
	call Darky_WriteMicrocontrollerRegister
	ld a,e
	cpl
	out (c),a
	ret

; a = value
; ix = this
Darky_WriteMicrocontrollerRegister:
	out (42H),a
	ex (sp),ix  ; wait 7 µs
	ex (sp),ix
	ex (sp),ix
	ex (sp),ix
	ret

; e = register
; d = value
; ix = this
Darky_SafeWriteRegister:
	ld bc,PSG.SafeWriteRegister
	jp Utils_JumpIXOffsetBC

; b = count
; e = register
; d = value
; ix = this
Darky_FillRegisters:
	push bc
	push de
	call Darky_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz Darky_FillRegisters
	ret

; ix = this
Darky_Reset:
	ld b,3
	ld de,0008H
	call Darky_FillRegisters
	ld b,14
	ld de,0000H
	call Darky_FillRegisters
	ret

; ix = this
; f <- c: found
Darky_Detect: PROC
	in a,(40H)
	cpl
	push af
	ld a,Darky_DEVICE_ID
	out (40H),a
	in a,(40H)
	cpl
	cp Darky_DEVICE_ID
	jr z,Found
	pop af
	out (40H),a
	and a
	ret
Found:
	pop af
	out (40H),a
	scf
	ret
	ENDP

;
Darky_name:
	db "Darky",0

	SECTION RAM

Darky_instance: Darky Darky_BASE_PORT_1
Darky_instance2: Darky Darky_BASE_PORT_2

	ENDS
