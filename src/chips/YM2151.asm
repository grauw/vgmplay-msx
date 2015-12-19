;
; VGM YM2151 chip
;
YM2151: MACRO
	super: Chip YM2151_name
	ENDM

; ix = this
; iy = header
YM2151_Construct: PROC
	ld l,(iy + Header.version)
	ld h,(iy + Header.version + 1)
	ld bc,-102H
	add hl,bc
	jr nc,Pre1_02
	ld l,(iy + Header.ym2151Clock)
	ld h,(iy + Header.ym2151Clock + 1)
	ld e,(iy + Header.ym2151Clock + 2)
	ld d,(iy + Header.ym2151Clock + 3)
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
YM2151_instance: YM2151

YM2151_name:
	db "YM2151 (OPM)",0
