;
; OPN FM on SFG driver
;
; The FM part is common to all chips in the OPN family.
;
OPNFMOnSFG_FREQUENCY: equ 3579545

OPNFMOnSFG: MACRO
	super: Driver
	frequencyMSBs:
		ds 4
	rlFBConnects:
		ds 4

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
	; a = register
	; d = value
	WriteRegister: PROC
		cp 21H
		jr z,WriteTest
		cp 28H
		jr z,WriteKeyOnOff
		cp 30H
		ret c
		cp 090H
		jr c,WriteSlots
		cp 0A0H
		jr nc,WriteChannels
		ret
	WriteTest:
		add a,-20H
		jr WriteSFGRegister
	WriteKeyOnOff:
		ld a,d
		and 07H
		ld b,a
		ld a,d
		and 0F0H
		rrca
		or b
		ld d,a
		ld a,8
		jr WriteSFGRegister
	WriteSFGRegister:
		jp 0
	writeSFGRegister: equ $ - 2
	WriteSlots:
		and 03H
		ld b,a
		ld a,e
		add a,-30H
		and 0FCH
		add a,a
		or b
		add a,40H
		jr WriteSFGRegister
	WriteChannels:
		cp 0A4H
		jr c,WriteFrequencyLSB
		cp 0A8H
		jr c,WriteFrequencyMSB
		cp 0B0H
		ret c
		cp 0B4H
		jr c,WriteFBConnect
		cp 0B8H
		jr c,WritePMSAMSLR
		ret
	WriteFrequencyMSB:
		ld c,a
		ld b,0
		ld hl,-0A4H + frequencyMSBs
		add hl,bc
		ld (hl),d
		ret
	WriteFrequencyLSB:
		push af
		ld c,a
		ld b,0
		ld hl,-0A0H + frequencyMSBs
		add hl,bc
		ld h,(hl)
		ld l,d
		call OPNFMOnSFG_FrequencyToKey
		pop af
		ld d,c
		ld c,a
		push bc
		add a,-0A0H + 30H
		call WriteSFGRegister
		pop bc
		ld d,b
		ld a,c
		add a,-0A0H + 28H
		jr WriteSFGRegister
	WriteFBConnect:
		ld c,a
		ld b,0
		ld hl,-0B0H + rlFBConnects
		add hl,bc
		ld a,(hl)
		and 11000000B
		ld b,a
		ld a,d
		and 00111111B
		or b
		ld (hl),a
		ld d,a
		ld a,e
		add a,-0B0H + 20H
		jr WriteSFGRegister
	WritePMSAMSLR:
		ld c,a
		ld b,0
		ld hl,-0B4H + rlFBConnects
		add hl,bc
		ld a,(hl)
		rla
		rla
		sla d  ; swap l & r
		rra
		sla d
		rra
		ld (hl),a
		push af
		rra
		rl d
		rra
		rl d
		ld a,e
		push af
		add a,-0B4H + 38H
		call WriteSFGRegister
		pop af
		pop de
		add a,-0B4H + 20H
		jp WriteSFGRegister
		ENDP
	ENDM

; de = SFG driver
; ix = this
OPNFMOnSFG_Construct:
	push de
	ld bc,OPNFMOnSFG_name
	ld de,OPNFMOnSFG_FREQUENCY >> 16
	ld hl,OPNFMOnSFG_FREQUENCY
	call Driver_Construct
	pop de
	ld hl,SFG.WriteRegister
	add hl,de
	ld (ix + OPNFMOnSFG.WriteRegister.writeSFGRegister),l
	ld (ix + OPNFMOnSFG.WriteRegister.writeSFGRegister + 1),h
	call OPNFMOnSFG_Initialize
	ret

; ix = this
OPNFMOnSFG_Destruct:
	ret

; ix = this
; e = register
; d = value
OPNFMOnSFG_Initialize:
	ld de,0C0B4H
	call OPNFMOnSFG_WriteRegister
	ld de,0C0B5H
	call OPNFMOnSFG_WriteRegister
	ld de,0C0B6H
	call OPNFMOnSFG_WriteRegister
	ret

; ix = this
; e = register
; d = value
OPNFMOnSFG_WriteRegister:
	push ix
	pop hl
	ld bc,OPNFMOnSFG.WriteRegister
	add hl,bc
	ld a,e
	jp hl

; l = f-number LSB
; h = block + f-number MSB
; b <- key code
; c <- key fraction
OPNFMOnSFG_FrequencyToKey:
	call OPNFMOnSFG_BlockFNumToFloat
	call Math_Log2
	call OPNFMOnSFG_OffsetOPNToOPM
	call OPNFMOnSFG_ToKeyCodeFraction
	ret

; l = f-number LSB
; h = block + f-number MSB
; b <- exponent (octave)
; hl <- significand (fnum * 32)
OPNFMOnSFG_BlockFNumToFloat:
	xor a
	add hl,hl
	add hl,hl
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	ld b,a
	ret

; b.hl = octave.fraction (OPN)
; b.hl <- octave.fraction (OPM)
OPNFMOnSFG_OffsetOPNToOPM:
	ld de,31941  ; 65536 * (log2((7159090 / 2^11 / 144) / 27.5) + 8/12 + 0.5/12/64)
	add hl,de    ;                frequency               A0      A-C#   rounding
	ret nc
	inc b
	ret

; b.hl = octave.fraction
; b <- key code
; c <- key fraction
OPNFMOnSFG_ToKeyCodeFraction: PROC
	ld a,b
	cp 8
	jr nc,OutOfRange
	ld e,l
	ld d,h
	srl d
	rr e
	srl d
	rr e
	sbc hl,de  ; * 3/4
	add hl,hl
	rl b
	add hl,hl
	rl b
	add hl,hl
	rl b
	add hl,hl
	rl b
	ld c,h
	ld a,b  ; remap
	and 0FH
	cp 3
	ret c
	inc b
	cp 6
	ret c
	inc b
	cp 9
	ret c
	inc b
	ret
OutOfRange:
	jp p,Overflow
Underflow:
	ld bc,0
	ret
Overflow:
	ld bc,7EFCH
	ret
	ENDP

;
OPNFMOnSFG_name:
	db "SFG (emu)",0

	SECTION RAM

OPNFMOnSFG_instance: OPNFMOnSFG

	ENDS
