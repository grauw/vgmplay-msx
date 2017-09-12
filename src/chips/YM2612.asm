;
; VGM YM2612 chip
;
YM2612: MACRO
	super: Chip YM2612_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
YM2612_Construct: PROC
	ld l,(iy + Header.version)
	ld h,(iy + Header.version + 1)
	ld bc,-102H
	add hl,bc
	jr nc,Pre1_02
	ld l,(iy + Header.ym2612Clock)
	ld h,(iy + Header.ym2612Clock + 1)
	ld e,(iy + Header.ym2612Clock + 2)
	ld d,(iy + Header.ym2612Clock + 3)
	jp Continue
Pre1_02:
	ld l,(iy + Header.ym2413Clock)
	ld h,(iy + Header.ym2413Clock + 1)
	ld e,(iy + Header.ym2413Clock + 2)
	ld d,(iy + Header.ym2413Clock + 3)
Continue:
	call Chip_Construct
	ret
	ENDP

;
	SECTION RAM

YM2612_instance: YM2612

	ENDS

YM2612_name:
	db "YM2612 (OPN2)",0
