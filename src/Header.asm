;
; VGM file header
;
Header: MACRO
	identification:
		dd 0
	eofOffset:
		dd 0
	version:
		dd 0
	sn76489Clock:
		dd 0
	ym2413Clock:
		dd 0
	gd3Offset:
		dd 0
	totalSamples:
		dd 0
	loopOffset:
		dd 0
	loopSamples:
		dd 0
	rate:
		dd 0
	sn76489Feedback:
		dw 0
	sn76489ShiftWidth:
		db 0
	sn76489Flags:
		db 0
	ym2612Clock:
		dd 0
	ym2151Clock:
		dd 0
	vgmDataOffset:
		dd 0
	segaPCMClock:
		dd 0
	spcmInterface:
		dd 0
	rf5c68Clock:
		dd 0
	ym2203Clock:
		dd 0
	ym2608Clock:
		dd 0
	ym2610BClock:
		dd 0
	ym3812Clock:
		dd 0
	ym3526Clock:
		dd 0
	y8950Clock:
		dd 0
	ymf262Clock:
		dd 0
	ymf278bClock:
		dd 0
	ymf271Clock:
		dd 0
	ymz280bClock:
		dd 0
	rf5c164Clock:
		dd 0
	pwmClock:
		dd 0
	ay8910Clock:
		dd 0
	ay8910ChipType:
		db 0
	ay8910Flags:
		db 0
	ay8910Flags_YM2203:
		db 0
	ay8910Flags_YM2608:
		db 0
	volumeModifier:
		db 0
	reserved1:
		db 0
	loopBase:
		db 0
	loopModifier:
		db 0
	gameBoyDMGClock:
		dd 0
	nesAPUClock:
		dd 0
	multiPCMClock:
		dd 0
	uPD7759Clock:
		dd 0
	okiM6258Clock:
		dd 0
	okiM6258Flags:
		db 0
	k054539Flags:
		db 0
	c140ChipType:
		db 0
	reserved2:
		db 0
	okiM6295Clock:
		dd 0
	k051649Clock:
		dd 0
	k054539Clock:
		dd 0
	huC6280Clock:
		dd 0
	c140Clock:
		dd 0
	k053260Clock:
		dd 0
	pokeyClock:
		dd 0
	qSoundClock:
		dd 0
	reserved3:
		dd 0
	extraHeaderOffset:
		dd 0
	reserved:
		dd 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	size:
	ENDM

; ix = this
; ix <- this
Header_Construct:
	call Header_CheckGZIP
	ld hl,Header_gzippedFileError
	jp z,Application_TerminateWithError
	call Header_CheckID
	ld hl,Header_noVGMFileError
	jp nz,Application_TerminateWithError
	call Header_ClearPastDataOffset
	ret

; ix = this
Header_ClearPastDataOffset:
	call Header_GetDataOffset
	ld a,d
	or e
	or h
	ret nz
	ld a,l
	ld c,ixl
	ld b,ixh
	add hl,bc
	ld (hl),0
	neg
	dec a
	ret z
	ld c,a
	ld b,0
	ld e,l
	ld d,h
	inc de
	ldir
	ret

; ix = this
; dehl <- VGM data offset
Header_GetDataOffset: PROC
	ld l,(ix + Header.version)
	ld h,(ix + Header.version + 1)
	ld bc,-150H
	add hl,bc
	jp nc,Pre1_50
	ld l,(ix + Header.vgmDataOffset)
	ld h,(ix + Header.vgmDataOffset + 1)
	ld e,(ix + Header.vgmDataOffset + 2)
	ld d,(ix + Header.vgmDataOffset + 3)
	ld bc,34H
	add hl,bc
	ret nc
	inc de
	ret
Pre1_50:
	ld de,0
	ld hl,40H
	ret
	ENDP

; ix = this
; dehl <- loop offset
; f <- z: no loop
Header_GetLoopOffset:
	ld l,(ix + Header.loopOffset)
	ld h,(ix + Header.loopOffset + 1)
	ld e,(ix + Header.loopOffset + 2)
	ld d,(ix + Header.loopOffset + 3)
	ld a,d
	or e
	or h
	or l
	ret z
	ld bc,1CH
	add hl,bc
	ret nc
	inc de
	and a
	ret

; ix = this
; dehl <- loop offset
; f <- z: no loop
Header_GetGD3Offset:
	ld l,(ix + Header.gd3Offset)
	ld h,(ix + Header.gd3Offset + 1)
	ld e,(ix + Header.gd3Offset + 2)
	ld d,(ix + Header.gd3Offset + 3)
	ld a,d
	or e
	or h
	or l
	ret z
	ld bc,14H
	add hl,bc
	ret nc
	inc de
	and a
	ret

; ix = this
Header_ShowInfo:
	call Header_PrintVersion
	call Header_PrintSN76489Info
	call Header_PrintYM2413Info
	call Header_PrintYM2612Info
	call Header_PrintYM2151Info
	call Header_PrintSegaPCMInfo
	call Header_PrintRF5C68Info
	call Header_PrintYM2203Info
	call Header_PrintYM2608Info
	call Header_PrintYM2610Info
	call Header_PrintYM3812Info
	call Header_PrintYM3526Info
	call Header_PrintY8950Info
	call Header_PrintYMF262Info
	call Header_PrintYMF278BInfo
	call Header_PrintYMF271Info
	call Header_PrintYMZ280BInfo
	call Header_PrintRF5C164Info
	call Header_PrintPWMInfo
	call Header_PrintAY8910Info
	call Header_PrintGameBoyDMGInfo
	call Header_PrintNESAPUInfo
	call Header_PrintMultiPCMInfo
	call Header_PrintUPD7759Info
	call Header_PrintOKIM6258Info
	call Header_PrintOKIM6295Info
	call Header_PrintK051649Info
	call Header_PrintK054539Info
	call Header_PrintHuC6280Info
	call Header_PrintC140Info
	call Header_PrintK053260Info
	call Header_PrintPokeyInfo
	call Header_PrintQSoundInfo
	ret

Header_PrintVersion:
	ld hl,Header_versionLabel
	call System_Print
	ld a,(ix + Header.version + 1)
	call System_PrintHexANoLeading0
	ld a,"."
	call System_PrintChar
	ld a,(ix + Header.version)
	call System_PrintHexA
	call System_PrintCrLf
	ret

Header_PrintSN76489Info:
	ld l,(ix + Header.sn76489Clock)
	ld h,(ix + Header.sn76489Clock + 1)
	ld e,(ix + Header.sn76489Clock + 2)
	ld d,(ix + Header.sn76489Clock + 3)
	ld bc,Header_sn76489Name
	jp Header_PrintClock

Header_PrintYM2413Info:
	ld l,(ix + Header.ym2413Clock)
	ld h,(ix + Header.ym2413Clock + 1)
	ld e,(ix + Header.ym2413Clock + 2)
	ld d,(ix + Header.ym2413Clock + 3)
	ld bc,Header_ym2413Name
	jp Header_PrintClock

Header_PrintYM2612Info: PROC
	ld l,(ix + Header.version)
	ld h,(ix + Header.version + 1)
	ld bc,-102H
	add hl,bc
	jr nc,Pre1_02
	ld l,(ix + Header.ym2612Clock)
	ld h,(ix + Header.ym2612Clock + 1)
	ld e,(ix + Header.ym2612Clock + 2)
	ld d,(ix + Header.ym2612Clock + 3)
	jp Continue
Pre1_02:
	ld l,(ix + Header.ym2413Clock)
	ld h,(ix + Header.ym2413Clock + 1)
	ld e,(ix + Header.ym2413Clock + 2)
	ld d,(ix + Header.ym2413Clock + 3)
Continue:
	ld bc,Header_ym2612Name
	jp Header_PrintClock
	ENDP

Header_PrintYM2151Info: PROC
	ld l,(ix + Header.version)
	ld h,(ix + Header.version + 1)
	ld bc,-102H
	add hl,bc
	jr nc,Pre1_02
	ld l,(ix + Header.ym2151Clock)
	ld h,(ix + Header.ym2151Clock + 1)
	ld e,(ix + Header.ym2151Clock + 2)
	ld d,(ix + Header.ym2151Clock + 3)
	jp Continue
Pre1_02:
	ld l,(ix + Header.ym2413Clock)
	ld h,(ix + Header.ym2413Clock + 1)
	ld e,(ix + Header.ym2413Clock + 2)
	ld d,(ix + Header.ym2413Clock + 3)
Continue:
	ld bc,Header_ym2151Name
	jp Header_PrintClock
	ENDP

Header_PrintSegaPCMInfo:
	ld l,(ix + Header.segaPCMClock)
	ld h,(ix + Header.segaPCMClock + 1)
	ld e,(ix + Header.segaPCMClock + 2)
	ld d,(ix + Header.segaPCMClock + 3)
	ld bc,Header_segaPCMName
	jp Header_PrintClock

Header_PrintRF5C68Info:
	ld l,(ix + Header.rf5c68Clock)
	ld h,(ix + Header.rf5c68Clock + 1)
	ld e,(ix + Header.rf5c68Clock + 2)
	ld d,(ix + Header.rf5c68Clock + 3)
	ld bc,Header_rf5c68Name
	jp Header_PrintClock

Header_PrintYM2203Info:
	ld l,(ix + Header.ym2203Clock)
	ld h,(ix + Header.ym2203Clock + 1)
	ld e,(ix + Header.ym2203Clock + 2)
	ld d,(ix + Header.ym2203Clock + 3)
	ld bc,Header_ym2203Name
	jp Header_PrintClock

Header_PrintYM2608Info:
	ld l,(ix + Header.ym2608Clock)
	ld h,(ix + Header.ym2608Clock + 1)
	ld e,(ix + Header.ym2608Clock + 2)
	ld d,(ix + Header.ym2608Clock + 3)
	ld bc,Header_ym2608Name
	jp Header_PrintClock

Header_PrintYM2610Info:
	ld l,(ix + Header.ym2610BClock)
	ld h,(ix + Header.ym2610BClock + 1)
	ld e,(ix + Header.ym2610BClock + 2)
	ld d,(ix + Header.ym2610BClock + 3)
	bit 7,d
	ld bc,Header_ym2610Name
	jp z,Header_PrintClock
	ld bc,Header_ym2610bName
	jp Header_PrintClock

Header_PrintYM3812Info:
	ld l,(ix + Header.ym3812Clock)
	ld h,(ix + Header.ym3812Clock + 1)
	ld e,(ix + Header.ym3812Clock + 2)
	ld d,(ix + Header.ym3812Clock + 3)
	ld bc,Header_ym3812Name
	jp Header_PrintClock

Header_PrintYM3526Info:
	ld l,(ix + Header.ym3526Clock)
	ld h,(ix + Header.ym3526Clock + 1)
	ld e,(ix + Header.ym3526Clock + 2)
	ld d,(ix + Header.ym3526Clock + 3)
	ld bc,Header_ym3526Name
	jp Header_PrintClock

Header_PrintY8950Info:
	ld l,(ix + Header.y8950Clock)
	ld h,(ix + Header.y8950Clock + 1)
	ld e,(ix + Header.y8950Clock + 2)
	ld d,(ix + Header.y8950Clock + 3)
	ld bc,Header_y8950Name
	jp Header_PrintClock

Header_PrintYMF262Info:
	ld l,(ix + Header.ymf262Clock)
	ld h,(ix + Header.ymf262Clock + 1)
	ld e,(ix + Header.ymf262Clock + 2)
	ld d,(ix + Header.ymf262Clock + 3)
	ld bc,Header_ymf262Name
	jp Header_PrintClock

Header_PrintYMF278BInfo:
	ld l,(ix + Header.ymf278bClock)
	ld h,(ix + Header.ymf278bClock + 1)
	ld e,(ix + Header.ymf278bClock + 2)
	ld d,(ix + Header.ymf278bClock + 3)
	ld bc,Header_ymf278bName
	jp Header_PrintClock

Header_PrintYMF271Info:
	ld l,(ix + Header.ymf271Clock)
	ld h,(ix + Header.ymf271Clock + 1)
	ld e,(ix + Header.ymf271Clock + 2)
	ld d,(ix + Header.ymf271Clock + 3)
	ld bc,Header_ymf271Name
	jp Header_PrintClock

Header_PrintYMZ280BInfo:
	ld l,(ix + Header.ymz280bClock)
	ld h,(ix + Header.ymz280bClock + 1)
	ld e,(ix + Header.ymz280bClock + 2)
	ld d,(ix + Header.ymz280bClock + 3)
	ld bc,Header_ymz280bName
	jp Header_PrintClock

Header_PrintRF5C164Info:
	ld l,(ix + Header.rf5c164Clock)
	ld h,(ix + Header.rf5c164Clock + 1)
	ld e,(ix + Header.rf5c164Clock + 2)
	ld d,(ix + Header.rf5c164Clock + 3)
	ld bc,Header_rf5c164Name
	jp Header_PrintClock

Header_PrintPWMInfo:
	ld l,(ix + Header.pwmClock)
	ld h,(ix + Header.pwmClock + 1)
	ld e,(ix + Header.pwmClock + 2)
	ld d,(ix + Header.pwmClock + 3)
	ld bc,Header_pwmName
	jp Header_PrintClock

Header_PrintAY8910Info:
	ld l,(ix + Header.ay8910Clock)
	ld h,(ix + Header.ay8910Clock + 1)
	ld e,(ix + Header.ay8910Clock + 2)
	ld d,(ix + Header.ay8910Clock + 3)
	ld a,(ix + Header.ay8910ChipType)
	cp 10H
	ld bc,Header_ym2149Name
	jp z,Header_PrintClock
	cp 11H
	ld bc,Header_ym3439Name
	jp z,Header_PrintClock
	cp 12H
	ld bc,Header_ymz284Name
	jp z,Header_PrintClock
	cp 13H
	ld bc,Header_ymz294Name
	jp z,Header_PrintClock
	cp 1H
	ld bc,Header_ay8912Name
	jp z,Header_PrintClock
	cp 2H
	ld bc,Header_ay8913Name
	jp z,Header_PrintClock
	cp 3H
	ld bc,Header_ay8930Name
	jp z,Header_PrintClock
	ld bc,Header_ay8910Name
	jp Header_PrintClock

Header_PrintGameBoyDMGInfo:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.gameBoyDMGClock - 80H)
	ld h,(ix + Header.gameBoyDMGClock - 80H + 1)
	ld e,(ix + Header.gameBoyDMGClock - 80H + 2)
	ld d,(ix + Header.gameBoyDMGClock - 80H + 3)
	pop ix
	ld bc,Header_gameBoyDMGName
	jp Header_PrintClock

Header_PrintNESAPUInfo:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.nesAPUClock - 80H)
	ld h,(ix + Header.nesAPUClock - 80H + 1)
	ld e,(ix + Header.nesAPUClock - 80H + 2)
	ld d,(ix + Header.nesAPUClock - 80H + 3)
	pop ix
	ld bc,Header_nesAPUName
	jp Header_PrintClock

Header_PrintMultiPCMInfo:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.multiPCMClock - 80H)
	ld h,(ix + Header.multiPCMClock - 80H + 1)
	ld e,(ix + Header.multiPCMClock - 80H + 2)
	ld d,(ix + Header.multiPCMClock - 80H + 3)
	pop ix
	ld bc,Header_multiPCMName
	jp Header_PrintClock

Header_PrintUPD7759Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.uPD7759Clock - 80H)
	ld h,(ix + Header.uPD7759Clock - 80H + 1)
	ld e,(ix + Header.uPD7759Clock - 80H + 2)
	ld d,(ix + Header.uPD7759Clock - 80H + 3)
	pop ix
	ld bc,Header_uPD7759Name
	jp Header_PrintClock

Header_PrintOKIM6258Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.okiM6258Clock - 80H)
	ld h,(ix + Header.okiM6258Clock - 80H + 1)
	ld e,(ix + Header.okiM6258Clock - 80H + 2)
	ld d,(ix + Header.okiM6258Clock - 80H + 3)
	pop ix
	ld bc,Header_okiM6258Name
	jp Header_PrintClock

Header_PrintOKIM6295Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.okiM6295Clock - 80H)
	ld h,(ix + Header.okiM6295Clock - 80H + 1)
	ld e,(ix + Header.okiM6295Clock - 80H + 2)
	ld d,(ix + Header.okiM6295Clock - 80H + 3)
	pop ix
	ld bc,Header_okiM6295Name
	jp Header_PrintClock

Header_PrintK051649Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.k051649Clock - 80H)
	ld h,(ix + Header.k051649Clock - 80H + 1)
	ld e,(ix + Header.k051649Clock - 80H + 2)
	ld d,(ix + Header.k051649Clock - 80H + 3)
	pop ix
	ld bc,Header_k051649Name
	jp Header_PrintClock

Header_PrintK054539Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.k054539Clock - 80H)
	ld h,(ix + Header.k054539Clock - 80H + 1)
	ld e,(ix + Header.k054539Clock - 80H + 2)
	ld d,(ix + Header.k054539Clock - 80H + 3)
	pop ix
	ld bc,Header_k054539Name
	jp Header_PrintClock

Header_PrintHuC6280Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.huC6280Clock - 80H)
	ld h,(ix + Header.huC6280Clock - 80H + 1)
	ld e,(ix + Header.huC6280Clock - 80H + 2)
	ld d,(ix + Header.huC6280Clock - 80H + 3)
	pop ix
	ld bc,Header_huC6280Name
	jp Header_PrintClock

Header_PrintC140Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.c140Clock - 80H)
	ld h,(ix + Header.c140Clock - 80H + 1)
	ld e,(ix + Header.c140Clock - 80H + 2)
	ld d,(ix + Header.c140Clock - 80H + 3)
	pop ix
	ld bc,Header_c140Name
	jp Header_PrintClock

Header_PrintK053260Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.k053260Clock - 80H)
	ld h,(ix + Header.k053260Clock - 80H + 1)
	ld e,(ix + Header.k053260Clock - 80H + 2)
	ld d,(ix + Header.k053260Clock - 80H + 3)
	pop ix
	ld bc,Header_k053260Name
	jp Header_PrintClock

Header_PrintPokeyInfo:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.pokeyClock - 80H)
	ld h,(ix + Header.pokeyClock - 80H + 1)
	ld e,(ix + Header.pokeyClock - 80H + 2)
	ld d,(ix + Header.pokeyClock - 80H + 3)
	pop ix
	ld bc,Header_pokeyName
	jp Header_PrintClock

Header_PrintQSoundInfo:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + Header.qSoundClock - 80H)
	ld h,(ix + Header.qSoundClock - 80H + 1)
	ld e,(ix + Header.qSoundClock - 80H + 2)
	ld d,(ix + Header.qSoundClock - 80H + 3)
	pop ix
	ld bc,Header_qSoundName
	jp Header_PrintClock

Header_PrintClock: PROC
	ld a,d
	or e
	or h
	or l
	ret z
	push hl
	ld l,c
	ld h,b
	call System_Print
	bit 6,d
	ld hl,Header_clockLabelInfix
	jr z,Single
	ld hl,Header_clockDualLabelInfix
Single:
	call System_Print
	pop hl
	res 7,d  ; clear flag bits
	res 6,d
	call System_PrintDecDEHL
	ld hl,Header_hz
	call System_Print
	ret
	ENDP

; ix = this
; f <- nz: invalid identification
Header_CheckID:
	ld a,(ix + Header.identification)
	cp "V"
	ret nz
	ld a,(ix + Header.identification + 1)
	cp "g"
	ret nz
	ld a,(ix + Header.identification + 2)
	cp "m"
	ret nz
	ld a,(ix + Header.identification + 3)
	cp " "
	ret

; ix = this
; f <- z: gzipped
Header_CheckGZIP:
	ld a,(ix + Header.identification)
	cp 31
	ret nz
	ld a,(ix + Header.identification + 1)
	cp 139
	ret

;
	SECTION RAM

Header_instance: Header

	ENDS

Header_versionLabel:
	db "VGM version: ",0

Header_sn76489Name:
	db "SN76489 (DCSG)",0

Header_ym2413Name:
	db "YM2413 (OPLL)",0

Header_ym2612Name:
	db "YM2612 (OPN2)",0

Header_ym2151Name:
	db "YM2151 (OPM)",0

Header_segaPCMName:
	db "Sega PCM",0

Header_rf5c68Name:
	db "RF5C68",0

Header_ym2203Name:
	db "YM2203 (OPN)",0

Header_ym2608Name:
	db "YM2608 (OPNA)",0

Header_ym2610Name:
	db "YM2610 (OPNB)",0

Header_ym2610bName:
	db "YM2610B (OPNB)",0

Header_ym3812Name:
	db "YM3812 (OPL2)",0

Header_ym3526Name:
	db "YM3526 (OPL)",0

Header_y8950Name:
	db "Y8950 (MSX-AUDIO)",0

Header_ymf262Name:
	db "YMF262 (OPL3)",0

Header_ymf278bName:
	db "YMF278B (OPL4)",0

Header_ymf271Name:
	db "YMF271 (OPX)",0

Header_ymz280bName:
	db "YMZ280B (PCMD8)",0

Header_rf5c164Name:
	db "RF5C164",0

Header_pwmName:
	db "PWM",0

Header_ay8910Name:
	db "AY-3-8910 (PSG)",0

Header_ay8912Name:
	db "AY-3-8912 (PSG)",0

Header_ay8913Name:
	db "AY-3-8913 (PSG)",0

Header_ay8930Name:
	db "AY8930 (EPSG)",0

Header_ym2149Name:
	db "YM2149 (SSG)",0

Header_ym3439Name:
	db "YM3439 (SSG)",0

Header_ymz284Name:
	db "YMZ284 (SSGL)",0

Header_ymz294Name:
	db "YMZ294 (SSG)",0

Header_gameBoyDMGName:
	db "Game Boy DMG",0

Header_nesAPUName:
	db "2A03 (NES APU)",0

Header_multiPCMName:
	db "MultiPCM",0

Header_uPD7759Name:
	db "uPD7759",0

Header_okiM6258Name:
	db "OKI M6258",0

Header_okiM6295Name:
	db "OKI M6295",0

Header_k051649Name:
	db "K051649 (SCC)",0

Header_k054539Name:
	db "K054539",0

Header_huC6280Name:
	db "HuC6280",0

Header_c140Name:
	db "C140",0

Header_k053260Name:
	db "K053260",0

Header_pokeyName:
	db "POKEY",0

Header_qSoundName:
	db "QSound",0

Header_clockLabelInfix:
	db ": ",0

Header_clockDualLabelInfix:
	db " x2: ",0

Header_hz:
	db " Hz",13,10,0

Header_noVGMFileError:
	db "Not a VGM file.",13,10,0

Header_gzippedFileError:
	db "File is gzipped, please extract before playback.",13,10,0
