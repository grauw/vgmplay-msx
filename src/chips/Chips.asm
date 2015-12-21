;
; VGM chips support
;
	INCLUDE "Chip.asm"
	INCLUDE "SN76489.asm"
	INCLUDE "YM2413.asm"
	INCLUDE "YM2612.asm"
	INCLUDE "YM2151.asm"
	INCLUDE "SegaPCM.asm"
	INCLUDE "RF5C68.asm"
	INCLUDE "YM2203.asm"
	INCLUDE "YM2608.asm"
	INCLUDE "YM2610.asm"
	INCLUDE "YM3812.asm"
	INCLUDE "YM3526.asm"
	INCLUDE "Y8950.asm"
	INCLUDE "YMF262.asm"
	INCLUDE "YMF278B.asm"
	INCLUDE "YMF271.asm"
	INCLUDE "YMZ280B.asm"
	INCLUDE "RF5C164.asm"
	INCLUDE "PWM.asm"
	INCLUDE "AY8910.asm"
	INCLUDE "GameBoyDMG.asm"
	INCLUDE "NESAPU.asm"
	INCLUDE "MultiPCM.asm"
	INCLUDE "UPD7759.asm"
	INCLUDE "OKIM6258.asm"
	INCLUDE "OKIM6295.asm"
	INCLUDE "K051649.asm"
	INCLUDE "K054539.asm"
	INCLUDE "HuC6280.asm"
	INCLUDE "C140.asm"
	INCLUDE "K053260.asm"
	INCLUDE "Pokey.asm"
	INCLUDE "QSound.asm"

Chips: MACRO
	COUNT: equ (chipsEnd - chips) / ChipInstance._size
	chips:
		ChipInstance SN76489_instance, SN76489_Construct
		ChipInstance YM2413_instance, YM2413_Construct
		ChipInstance YM2612_instance, YM2612_Construct
		ChipInstance YM2151_instance, YM2151_Construct
		ChipInstance SegaPCM_instance, SegaPCM_Construct
		ChipInstance RF5C68_instance, RF5C68_Construct
		ChipInstance YM2203_instance, YM2203_Construct
		ChipInstance YM2608_instance, YM2608_Construct
		ChipInstance YM2610_instance, YM2610_Construct
		ChipInstance YM3812_instance, YM3812_Construct
		ChipInstance YM3526_instance, YM3526_Construct
		ChipInstance Y8950_instance, Y8950_Construct
		ChipInstance YMF262_instance, YMF262_Construct
		ChipInstance YMF278B_instance, YMF278B_Construct
		ChipInstance YMF271_instance, YMF271_Construct
		ChipInstance YMZ280B_instance, YMZ280B_Construct
		ChipInstance RF5C164_instance, RF5C164_Construct
		ChipInstance PWM_instance, PWM_Construct
		ChipInstance AY8910_instance, AY8910_Construct
		ChipInstance GameBoyDMG_instance, GameBoyDMG_Construct
		ChipInstance NESAPU_instance, NESAPU_Construct
		ChipInstance MultiPCM_instance, MultiPCM_Construct
		ChipInstance UPD7759_instance, UPD7759_Construct
		ChipInstance OKIM6258_instance, OKIM6258_Construct
		ChipInstance OKIM6295_instance, OKIM6295_Construct
		ChipInstance K051649_instance, K051649_Construct
		ChipInstance K054539_instance, K054539_Construct
		ChipInstance HuC6280_instance, HuC6280_Construct
		ChipInstance C140_instance, C140_Construct
		ChipInstance K053260_instance, K053260_Construct
		ChipInstance Pokey_instance, Pokey_Construct
		ChipInstance QSound_instance, QSound_Construct
	chipsEnd:
	ENDM

ChipInstance: MACRO ?instance, ?constructor
	instance:
		dw ?instance
	constructor:
		dw ?constructor
	_size:
	ENDM

; ix = this
; iy = header
Chips_Construct: PROC
	ld b,Chips.COUNT
	push ix
Loop:
	push bc
	ld e,(ix + Chips.chips + ChipInstance.instance)
	ld d,(ix + Chips.chips + ChipInstance.instance + 1)
	ld l,(ix + Chips.chips + ChipInstance.constructor)
	ld h,(ix + Chips.chips + ChipInstance.constructor + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call Construct
	pop ix
	pop bc
	REPT 4  ; ChipInstance._size
	inc ix
	ENDM
	djnz Loop
	pop ix
	ret
Construct:
	jp hl
	ENDP

; ix = this
Chips_PrintInfo: PROC
	ld b,Chips.COUNT
	push ix
Loop:
	push bc
	ld c,(ix + Chips.chips + ChipInstance.instance)
	ld b,(ix + Chips.chips + ChipInstance.instance + 1)
	push ix
	ld ixl,c
	ld ixh,b
	call Chip_PrintInfo
	pop ix
	pop bc
	REPT 4  ; ChipInstance._size
	inc ix
	ENDM
	djnz Loop
	pop ix
	ret
	ENDP
