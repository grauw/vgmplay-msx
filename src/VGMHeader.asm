;
; VGM file header
;
VGMHeader: MACRO
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
VGMHeader_Constructor:
	call VGMHeader_CheckID
	jp nz,VGMHeader_ThrowNoVGMFileError
	call VGMHeader_ClearPastDataOffset
	ret

; ix = this
VGMHeader_ClearPastDataOffset:
	call VGMHeader_GetDataOffset
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
VGMHeader_GetDataOffset: PROC
	ld h,(ix + VGMHeader.version + 1)
	ld l,(ix + VGMHeader.version)
	ld bc,-150H
	add hl,bc
	jp nc,Pre1_50
	ld l,(ix + VGMHeader.vgmDataOffset)
	ld h,(ix + VGMHeader.vgmDataOffset + 1)
	ld e,(ix + VGMHeader.vgmDataOffset + 2)
	ld d,(ix + VGMHeader.vgmDataOffset + 3)
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
VGMHeader_ShowInfo:
	call VGMHeader_PrintVersion
	call VGMHeader_PrintSN76489Info
	call VGMHeader_PrintYM2413Info
	call VGMHeader_PrintYM2612Info
	call VGMHeader_PrintYM2151Info
	call VGMHeader_PrintSegaPCMInfo
	call VGMHeader_PrintRF5C68Info
	call VGMHeader_PrintYM2203Info
	call VGMHeader_PrintYM2608Info
	call VGMHeader_PrintYM2610Info
	call VGMHeader_PrintYM3812Info
	call VGMHeader_PrintYM3526Info
	call VGMHeader_PrintY8950Info
	call VGMHeader_PrintYMF262Info
	call VGMHeader_PrintYMF278BInfo
	call VGMHeader_PrintYMF271Info
	call VGMHeader_PrintYMZ280BInfo
	call VGMHeader_PrintRF5C164Info
	call VGMHeader_PrintPWMInfo
	call VGMHeader_PrintAY8910Info
	call VGMHeader_PrintGameBoyDMGInfo
	call VGMHeader_PrintNESAPUInfo
	call VGMHeader_PrintMultiPCMInfo
	call VGMHeader_PrintUPD7759Info
	call VGMHeader_PrintOKIM6258Info
	call VGMHeader_PrintOKIM6295Info
	call VGMHeader_PrintK051649Info
	call VGMHeader_PrintK054539Info
	call VGMHeader_PrintHuC6280Info
	call VGMHeader_PrintC140Info
	call VGMHeader_PrintK053260Info
	call VGMHeader_PrintPokeyInfo
	call VGMHeader_PrintQSoundInfo
	ret

VGMHeader_PrintVersion:
	ld hl,VGMHeader_versionLabel
	call System_Print
	ld a,(ix + VGMHeader.version + 1)
	call System_PrintHexANoLeading0
	ld a,"."
	call System_PrintChar
	ld a,(ix + VGMHeader.version)
	call System_PrintHexA
	call System_PrintCrLf
	ret

VGMHeader_PrintSN76489Info:
	ld l,(ix + VGMHeader.sn76489Clock)
	ld h,(ix + VGMHeader.sn76489Clock + 1)
	ld e,(ix + VGMHeader.sn76489Clock + 2)
	ld d,(ix + VGMHeader.sn76489Clock + 3)
	ld bc,VGMHeader_sn76489Name
	jp VGMHeader_PrintClock

VGMHeader_PrintYM2413Info:
	ld l,(ix + VGMHeader.ym2413Clock)
	ld h,(ix + VGMHeader.ym2413Clock + 1)
	ld e,(ix + VGMHeader.ym2413Clock + 2)
	ld d,(ix + VGMHeader.ym2413Clock + 3)
	ld bc,VGMHeader_ym2413Name
	jp VGMHeader_PrintClock

VGMHeader_PrintYM2612Info:
	ld l,(ix + VGMHeader.ym2612Clock)
	ld h,(ix + VGMHeader.ym2612Clock + 1)
	ld e,(ix + VGMHeader.ym2612Clock + 2)
	ld d,(ix + VGMHeader.ym2612Clock + 3)
	ld bc,VGMHeader_ym2612Name
	jp VGMHeader_PrintClock

VGMHeader_PrintYM2151Info:
	ld l,(ix + VGMHeader.ym2151Clock)
	ld h,(ix + VGMHeader.ym2151Clock + 1)
	ld e,(ix + VGMHeader.ym2151Clock + 2)
	ld d,(ix + VGMHeader.ym2151Clock + 3)
	ld bc,VGMHeader_ym2151Name
	jp VGMHeader_PrintClock

VGMHeader_PrintSegaPCMInfo:
	ld l,(ix + VGMHeader.segaPCMClock)
	ld h,(ix + VGMHeader.segaPCMClock + 1)
	ld e,(ix + VGMHeader.segaPCMClock + 2)
	ld d,(ix + VGMHeader.segaPCMClock + 3)
	ld bc,VGMHeader_segaPCMName
	jp VGMHeader_PrintClock

VGMHeader_PrintRF5C68Info:
	ld l,(ix + VGMHeader.rf5c68Clock)
	ld h,(ix + VGMHeader.rf5c68Clock + 1)
	ld e,(ix + VGMHeader.rf5c68Clock + 2)
	ld d,(ix + VGMHeader.rf5c68Clock + 3)
	ld bc,VGMHeader_rf5c68Name
	jp VGMHeader_PrintClock

VGMHeader_PrintYM2203Info:
	ld l,(ix + VGMHeader.ym2203Clock)
	ld h,(ix + VGMHeader.ym2203Clock + 1)
	ld e,(ix + VGMHeader.ym2203Clock + 2)
	ld d,(ix + VGMHeader.ym2203Clock + 3)
	ld bc,VGMHeader_ym2203Name
	jp VGMHeader_PrintClock

VGMHeader_PrintYM2608Info:
	ld l,(ix + VGMHeader.ym2608Clock)
	ld h,(ix + VGMHeader.ym2608Clock + 1)
	ld e,(ix + VGMHeader.ym2608Clock + 2)
	ld d,(ix + VGMHeader.ym2608Clock + 3)
	ld bc,VGMHeader_ym2608Name
	jp VGMHeader_PrintClock

VGMHeader_PrintYM2610Info:
	ld l,(ix + VGMHeader.ym2610BClock)
	ld h,(ix + VGMHeader.ym2610BClock + 1)
	ld e,(ix + VGMHeader.ym2610BClock + 2)
	ld d,(ix + VGMHeader.ym2610BClock + 3)
	bit 7,d
	ld bc,VGMHeader_ym2610Name
	jp z,VGMHeader_PrintClock
	ld bc,VGMHeader_ym2610bName
	jp VGMHeader_PrintClock

VGMHeader_PrintYM3812Info:
	ld l,(ix + VGMHeader.ym3812Clock)
	ld h,(ix + VGMHeader.ym3812Clock + 1)
	ld e,(ix + VGMHeader.ym3812Clock + 2)
	ld d,(ix + VGMHeader.ym3812Clock + 3)
	ld bc,VGMHeader_ym3812Name
	jp VGMHeader_PrintClock

VGMHeader_PrintYM3526Info:
	ld l,(ix + VGMHeader.ym3526Clock)
	ld h,(ix + VGMHeader.ym3526Clock + 1)
	ld e,(ix + VGMHeader.ym3526Clock + 2)
	ld d,(ix + VGMHeader.ym3526Clock + 3)
	ld bc,VGMHeader_ym3526Name
	jp VGMHeader_PrintClock

VGMHeader_PrintY8950Info:
	ld l,(ix + VGMHeader.y8950Clock)
	ld h,(ix + VGMHeader.y8950Clock + 1)
	ld e,(ix + VGMHeader.y8950Clock + 2)
	ld d,(ix + VGMHeader.y8950Clock + 3)
	ld bc,VGMHeader_y8950Name
	jp VGMHeader_PrintClock

VGMHeader_PrintYMF262Info:
	ld l,(ix + VGMHeader.ymf262Clock)
	ld h,(ix + VGMHeader.ymf262Clock + 1)
	ld e,(ix + VGMHeader.ymf262Clock + 2)
	ld d,(ix + VGMHeader.ymf262Clock + 3)
	ld bc,VGMHeader_ymf262Name
	jp VGMHeader_PrintClock

VGMHeader_PrintYMF278BInfo:
	ld l,(ix + VGMHeader.ymf278bClock)
	ld h,(ix + VGMHeader.ymf278bClock + 1)
	ld e,(ix + VGMHeader.ymf278bClock + 2)
	ld d,(ix + VGMHeader.ymf278bClock + 3)
	ld bc,VGMHeader_ymf278bName
	jp VGMHeader_PrintClock

VGMHeader_PrintYMF271Info:
	ld l,(ix + VGMHeader.ymf271Clock)
	ld h,(ix + VGMHeader.ymf271Clock + 1)
	ld e,(ix + VGMHeader.ymf271Clock + 2)
	ld d,(ix + VGMHeader.ymf271Clock + 3)
	ld bc,VGMHeader_ymf271Name
	jp VGMHeader_PrintClock

VGMHeader_PrintYMZ280BInfo:
	ld l,(ix + VGMHeader.ymz280bClock)
	ld h,(ix + VGMHeader.ymz280bClock + 1)
	ld e,(ix + VGMHeader.ymz280bClock + 2)
	ld d,(ix + VGMHeader.ymz280bClock + 3)
	ld bc,VGMHeader_ymz280bName
	jp VGMHeader_PrintClock

VGMHeader_PrintRF5C164Info:
	ld l,(ix + VGMHeader.rf5c164Clock)
	ld h,(ix + VGMHeader.rf5c164Clock + 1)
	ld e,(ix + VGMHeader.rf5c164Clock + 2)
	ld d,(ix + VGMHeader.rf5c164Clock + 3)
	ld bc,VGMHeader_rf5c164Name
	jp VGMHeader_PrintClock

VGMHeader_PrintPWMInfo:
	ld l,(ix + VGMHeader.pwmClock)
	ld h,(ix + VGMHeader.pwmClock + 1)
	ld e,(ix + VGMHeader.pwmClock + 2)
	ld d,(ix + VGMHeader.pwmClock + 3)
	ld bc,VGMHeader_pwmName
	jp VGMHeader_PrintClock

VGMHeader_PrintAY8910Info:
	ld l,(ix + VGMHeader.ay8910Clock)
	ld h,(ix + VGMHeader.ay8910Clock + 1)
	ld e,(ix + VGMHeader.ay8910Clock + 2)
	ld d,(ix + VGMHeader.ay8910Clock + 3)
	ld a,(ix + VGMHeader.ay8910ChipType)
	cp 10H
	ld bc,VGMHeader_ym2149Name
	jp z,VGMHeader_PrintClock
	cp 11H
	ld bc,VGMHeader_ym3439Name
	jp z,VGMHeader_PrintClock
	cp 12H
	ld bc,VGMHeader_ymz284Name
	jp z,VGMHeader_PrintClock
	cp 13H
	ld bc,VGMHeader_ymz294Name
	jp z,VGMHeader_PrintClock
	cp 1H
	ld bc,VGMHeader_ay8912Name
	jp z,VGMHeader_PrintClock
	cp 2H
	ld bc,VGMHeader_ay8913Name
	jp z,VGMHeader_PrintClock
	cp 3H
	ld bc,VGMHeader_ay8930Name
	jp z,VGMHeader_PrintClock
	ld bc,VGMHeader_ay8910Name
	jp VGMHeader_PrintClock

VGMHeader_PrintGameBoyDMGInfo:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.gameBoyDMGClock - 80H)
	ld h,(ix + VGMHeader.gameBoyDMGClock - 80H + 1)
	ld e,(ix + VGMHeader.gameBoyDMGClock - 80H + 2)
	ld d,(ix + VGMHeader.gameBoyDMGClock - 80H + 3)
	pop ix
	ld bc,VGMHeader_gameBoyDMGName
	jp VGMHeader_PrintClock

VGMHeader_PrintNESAPUInfo:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.nesAPUClock - 80H)
	ld h,(ix + VGMHeader.nesAPUClock - 80H + 1)
	ld e,(ix + VGMHeader.nesAPUClock - 80H + 2)
	ld d,(ix + VGMHeader.nesAPUClock - 80H + 3)
	pop ix
	ld bc,VGMHeader_nesAPUName
	jp VGMHeader_PrintClock

VGMHeader_PrintMultiPCMInfo:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.multiPCMClock - 80H)
	ld h,(ix + VGMHeader.multiPCMClock - 80H + 1)
	ld e,(ix + VGMHeader.multiPCMClock - 80H + 2)
	ld d,(ix + VGMHeader.multiPCMClock - 80H + 3)
	pop ix
	ld bc,VGMHeader_multiPCMName
	jp VGMHeader_PrintClock

VGMHeader_PrintUPD7759Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.uPD7759Clock - 80H)
	ld h,(ix + VGMHeader.uPD7759Clock - 80H + 1)
	ld e,(ix + VGMHeader.uPD7759Clock - 80H + 2)
	ld d,(ix + VGMHeader.uPD7759Clock - 80H + 3)
	pop ix
	ld bc,VGMHeader_uPD7759Name
	jp VGMHeader_PrintClock

VGMHeader_PrintOKIM6258Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.okiM6258Clock - 80H)
	ld h,(ix + VGMHeader.okiM6258Clock - 80H + 1)
	ld e,(ix + VGMHeader.okiM6258Clock - 80H + 2)
	ld d,(ix + VGMHeader.okiM6258Clock - 80H + 3)
	pop ix
	ld bc,VGMHeader_okiM6258Name
	jp VGMHeader_PrintClock

VGMHeader_PrintOKIM6295Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.okiM6295Clock - 80H)
	ld h,(ix + VGMHeader.okiM6295Clock - 80H + 1)
	ld e,(ix + VGMHeader.okiM6295Clock - 80H + 2)
	ld d,(ix + VGMHeader.okiM6295Clock - 80H + 3)
	pop ix
	ld bc,VGMHeader_okiM6295Name
	jp VGMHeader_PrintClock

VGMHeader_PrintK051649Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.k051649Clock - 80H)
	ld h,(ix + VGMHeader.k051649Clock - 80H + 1)
	ld e,(ix + VGMHeader.k051649Clock - 80H + 2)
	ld d,(ix + VGMHeader.k051649Clock - 80H + 3)
	pop ix
	ld bc,VGMHeader_k051649Name
	jp VGMHeader_PrintClock

VGMHeader_PrintK054539Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.k054539Clock - 80H)
	ld h,(ix + VGMHeader.k054539Clock - 80H + 1)
	ld e,(ix + VGMHeader.k054539Clock - 80H + 2)
	ld d,(ix + VGMHeader.k054539Clock - 80H + 3)
	pop ix
	ld bc,VGMHeader_k054539Name
	jp VGMHeader_PrintClock

VGMHeader_PrintHuC6280Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.huC6280Clock - 80H)
	ld h,(ix + VGMHeader.huC6280Clock - 80H + 1)
	ld e,(ix + VGMHeader.huC6280Clock - 80H + 2)
	ld d,(ix + VGMHeader.huC6280Clock - 80H + 3)
	pop ix
	ld bc,VGMHeader_huC6280Name
	jp VGMHeader_PrintClock

VGMHeader_PrintC140Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.c140Clock - 80H)
	ld h,(ix + VGMHeader.c140Clock - 80H + 1)
	ld e,(ix + VGMHeader.c140Clock - 80H + 2)
	ld d,(ix + VGMHeader.c140Clock - 80H + 3)
	pop ix
	ld bc,VGMHeader_c140Name
	jp VGMHeader_PrintClock

VGMHeader_PrintK053260Info:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.k053260Clock - 80H)
	ld h,(ix + VGMHeader.k053260Clock - 80H + 1)
	ld e,(ix + VGMHeader.k053260Clock - 80H + 2)
	ld d,(ix + VGMHeader.k053260Clock - 80H + 3)
	pop ix
	ld bc,VGMHeader_k053260Name
	jp VGMHeader_PrintClock

VGMHeader_PrintPokeyInfo:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.pokeyClock - 80H)
	ld h,(ix + VGMHeader.pokeyClock - 80H + 1)
	ld e,(ix + VGMHeader.pokeyClock - 80H + 2)
	ld d,(ix + VGMHeader.pokeyClock - 80H + 3)
	pop ix
	ld bc,VGMHeader_pokeyName
	jp VGMHeader_PrintClock

VGMHeader_PrintQSoundInfo:
	push ix
	ld de,80H
	add ix,de
	ld l,(ix + VGMHeader.qSoundClock - 80H)
	ld h,(ix + VGMHeader.qSoundClock - 80H + 1)
	ld e,(ix + VGMHeader.qSoundClock - 80H + 2)
	ld d,(ix + VGMHeader.qSoundClock - 80H + 3)
	pop ix
	ld bc,VGMHeader_qSoundName
	jp VGMHeader_PrintClock

VGMHeader_PrintClock: PROC
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
	ld hl,VGMHeader_clockLabelInfix
	jr z,Single
	ld hl,VGMHeader_clockDualLabelInfix
Single:
	call System_Print
	pop hl
	res 7,d  ; clear flag bits
	res 6,d
	call System_PrintDecDEHL
	ld hl,VGMHeader_hz
	call System_Print
	ret
	ENDP

; ix = this
; f <- nz: invalid identification
VGMHeader_CheckID:
	ld a,(ix + VGMHeader.identification)
	cp "V"
	ret nz
	ld a,(ix + VGMHeader.identification + 1)
	cp "g"
	ret nz
	ld a,(ix + VGMHeader.identification + 2)
	cp "m"
	ret nz
	ld a,(ix + VGMHeader.identification + 3)
	cp " "
	ret

VGMHeader_ThrowNoVGMFileError:
	ld hl,VGMHeader_noVGMFile
	call System_Print
	jp REBOOT

;
	SECTION RAM

VGMHeader_instance: VGMHeader

VGMHeader_versionLabel:
	db "Version: ",0

VGMHeader_sn76489Name:
	db "SN76489 (DCSG)",0

VGMHeader_ym2413Name:
	db "YM2413 (OPLL)",0

VGMHeader_ym2612Name:
	db "YM2612 (OPN2)",0

VGMHeader_ym2151Name:
	db "YM2151 (OPM)",0

VGMHeader_segaPCMName:
	db "Sega PCM",0

VGMHeader_rf5c68Name:
	db "RF5C68",0

VGMHeader_ym2203Name:
	db "YM2203 (OPN)",0

VGMHeader_ym2608Name:
	db "YM2608 (OPNA)",0

VGMHeader_ym2610Name:
	db "YM2610 (OPNB)",0

VGMHeader_ym2610bName:
	db "YM2610B (OPNB)",0

VGMHeader_ym3812Name:
	db "YM3812 (OPL2)",0

VGMHeader_ym3526Name:
	db "YM3526 (OPL)",0

VGMHeader_y8950Name:
	db "Y8950 (MSX-AUDIO)",0

VGMHeader_ymf262Name:
	db "YMF262 (OPL3)",0

VGMHeader_ymf278bName:
	db "YMF278B (OPL4)",0

VGMHeader_ymf271Name:
	db "YMF271 (OPX)",0

VGMHeader_ymz280bName:
	db "YMZ280B (PCMD8)",0

VGMHeader_rf5c164Name:
	db "RF5C164",0

VGMHeader_pwmName:
	db "PWM",0

VGMHeader_ay8910Name:
	db "AY-3-8910 (PSG)",0

VGMHeader_ay8912Name:
	db "AY-3-8912 (PSG)",0

VGMHeader_ay8913Name:
	db "AY-3-8913 (PSG)",0

VGMHeader_ay8930Name:
	db "AY8930 (EPSG)",0

VGMHeader_ym2149Name:
	db "YM2149 (SSG)",0

VGMHeader_ym3439Name:
	db "YM3439 (SSG)",0

VGMHeader_ymz284Name:
	db "YMZ284 (SSGL)",0

VGMHeader_ymz294Name:
	db "YMZ294 (SSG)",0

VGMHeader_gameBoyDMGName:
	db "Game Boy DMG",0

VGMHeader_nesAPUName:
	db "2A03 (NES APU)",0

VGMHeader_multiPCMName:
	db "MultiPCM",0

VGMHeader_uPD7759Name:
	db "uPD7759",0

VGMHeader_okiM6258Name:
	db "OKI M6258",0

VGMHeader_okiM6295Name:
	db "OKI M6295",0

VGMHeader_k051649Name:
	db "K051649 (SCC)",0

VGMHeader_k054539Name:
	db "K054539",0

VGMHeader_huC6280Name:
	db "HuC6280",0

VGMHeader_c140Name:
	db "C140",0

VGMHeader_k053260Name:
	db "K053260",0

VGMHeader_pokeyName:
	db "POKEY",0

VGMHeader_qSoundName:
	db "QSound",0

VGMHeader_clockLabelInfix:
	db ": ",0

VGMHeader_clockDualLabelInfix:
	db " x2: ",0

VGMHeader_hz:
	db " Hz",13,10,0

VGMHeader_noVGMFile:
	db "Not a VGM file.",13,10,0

	ENDS
