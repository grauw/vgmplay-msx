;
; VGM YM2610 chip
;
YM2610: MACRO
	super: Chip YM2610_ym2610Name
	ENDM

; ix = this
; iy = header
YM2610_Construct:
	ld l,(iy + Header.ym2610BClock)
	ld h,(iy + Header.ym2610BClock + 1)
	ld e,(iy + Header.ym2610BClock + 2)
	ld d,(iy + Header.ym2610BClock + 3)
	call Chip_Construct
	bit 7,(ix + YM2610.super.clock)
	ret z
	ld (ix + YM2610.super.name),YM2610_ym2610bName
	ld (ix + YM2610.super.name + 1),YM2610_ym2610bName >> 8
	ret

;
YM2610_instance: YM2610

YM2610_ym2610Name:
	db "YM2610 (OPNB)",0

YM2610_ym2610bName:
	db "YM2610B (OPNB)",0
