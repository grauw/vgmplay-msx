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
	ret

; ix = this
VGMHeader_Process:
	call VGMHeader_CheckID
	jp nz,VGMHeader_ThrowNoVGMFileError
	call VGMHeader_PrintVersion
	call VGMHeader_PrintAY8910Clock
	ret

VGMHeader_PrintVersion:
	ld hl,VGMHeader_infoVersion
	call System_Print
	ld a,(ix + VGMHeader.version + 1)
	call System_PrintHexANoLeading0
	ld a,"."
	call System_PrintChar
	ld a,(ix + VGMHeader.version)
	call System_PrintHexANoLeading0
	call System_PrintCrLf
	ret

VGMHeader_PrintAY8910Clock:
	ld hl,VGMHeader_infoAY8910Clock
	call System_Print
	ld l,(ix + VGMHeader.ay8910Clock)
	ld h,(ix + VGMHeader.ay8910Clock + 1)
	ld e,(ix + VGMHeader.ay8910Clock + 2)
	ld d,(ix + VGMHeader.ay8910Clock + 3)
	call System_PrintHexDEHL
	ld hl,VGMHeader_hz
	call System_Print
	ret

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

VGMHeader_infoVersion:
	db "Version: ",0

VGMHeader_infoAY8910Clock:
	db "AY-3-8910 clock: ",0

VGMHeader_noVGMFile:
	db "Not a VGM file.",13,10,0

VGMHeader_hz:
	db " Hz",13,10,0

	ENDS
