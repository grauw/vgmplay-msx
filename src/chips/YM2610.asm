;
; VGM YM2610 chip
;
YM2610: MACRO
	super: Chip YM2610_ym2610Name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
YM2610_Construct:
	ld l,(iy + Header.ym2610BClock)
	ld h,(iy + Header.ym2610BClock + 1)
	ld e,(iy + Header.ym2610BClock + 2)
	ld d,(iy + Header.ym2610BClock + 3)
	call Chip_Construct
	call YM2610_IsYM2610B
	ret z
	ld hl,YM2610_ym2610bName
	call Chip_SetName
	ret

; ix = this
; f <- nz: YM2610B
YM2610_IsYM2610B:
	bit 7,(ix + YM2610.super.clock + 3)
	ret

;
	SECTION RAM

YM2610_instance: YM2610

	ENDS

YM2610_ym2610Name:
	db "YM2610 (OPNB)",0

YM2610_ym2610bName:
	db "YM2610B (OPNB)",0
