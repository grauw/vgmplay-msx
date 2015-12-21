;
; VGM YMF271 chip
;
YMF271: MACRO
	super: Chip YMF271_name, Chip_ConnectDefault, Chip_InstallDefault
	ENDM

; ix = this
; iy = header
YMF271_Construct:
	ld l,(iy + Header.ymf271Clock)
	ld h,(iy + Header.ymf271Clock + 1)
	ld e,(iy + Header.ymf271Clock + 2)
	ld d,(iy + Header.ymf271Clock + 3)
	call Chip_Construct
	ret

;
YMF271_instance: YMF271

YMF271_name:
	db "YMF271 (OPX)",0
