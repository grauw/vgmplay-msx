;
; VGM YMF278B chip
;
YMF278B: MACRO
	super: Chip YMF278B_name
	ENDM

; ix = this
; iy = header
YMF278B_Construct:
	ld l,(iy + Header.ymf278bClock)
	ld h,(iy + Header.ymf278bClock + 1)
	ld e,(iy + Header.ymf278bClock + 2)
	ld d,(iy + Header.ymf278bClock + 3)
	call Chip_Construct
	ret

;
YMF278B_instance: YMF278B

YMF278B_name:
	db "YMF278B (OPL4)",0
