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
	COUNT: equ (chipsEnd - chips) / ChipFactory._size
	chips:
		ChipFactory SN76489_instance, SN76489_Construct
		ChipFactory YM2413_instance, YM2413_Construct
		ChipFactory YM2151_instance, YM2151_Construct
		ChipFactory SegaPCM_instance, SegaPCM_Construct
		ChipFactory RF5C68_instance, RF5C68_Construct
		ChipFactory YM2203_instance, YM2203_Construct
		ChipFactory YM2608_instance, YM2608_Construct
		ChipFactory YM2610_instance, YM2610_Construct
	ym2612:
		ChipFactory YM2612_instance, YM2612_Construct
		ChipFactory YM3812_instance, YM3812_Construct
		ChipFactory Y8950_instance, Y8950_Construct
		ChipFactory YM3526_instance, YM3526_Construct
		ChipFactory YMF262_instance, YMF262_Construct
		ChipFactory YMF278B_instance, YMF278B_Construct
		ChipFactory YMF271_instance, YMF271_Construct
		ChipFactory YMZ280B_instance, YMZ280B_Construct
		ChipFactory RF5C164_instance, RF5C164_Construct
		ChipFactory PWM_instance, PWM_Construct
		ChipFactory AY8910_instance, AY8910_Construct
		ChipFactory GameBoyDMG_instance, GameBoyDMG_Construct
		ChipFactory NESAPU_instance, NESAPU_Construct
		ChipFactory MultiPCM_instance, MultiPCM_Construct
		ChipFactory UPD7759_instance, UPD7759_Construct
		ChipFactory OKIM6258_instance, OKIM6258_Construct
		ChipFactory OKIM6295_instance, OKIM6295_Construct
		ChipFactory K051649_instance, K051649_Construct
		ChipFactory K054539_instance, K054539_Construct
		ChipFactory HuC6280_instance, HuC6280_Construct
		ChipFactory C140_instance, C140_Construct
		ChipFactory K053260_instance, K053260_Construct
		ChipFactory Pokey_instance, Pokey_Construct
		ChipFactory QSound_instance, QSound_Construct
	chipsEnd:
	ENDM

ChipFactory: MACRO ?instance, ?constructor
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
	ld e,(ix + Chips.chips + ChipFactory.instance)
	ld d,(ix + Chips.chips + ChipFactory.instance + 1)
	ld l,(ix + Chips.chips + ChipFactory.constructor)
	ld h,(ix + Chips.chips + ChipFactory.constructor + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call System_JumpHL
	pop ix
	ld bc,ChipFactory._size
	add ix,bc
	pop bc
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Chips_Destruct:
	push ix
	ld e,(ix + Chips.ym2612 + ChipFactory.instance)
	ld d,(ix + Chips.ym2612 + ChipFactory.instance + 1)
	ld ixl,e
	ld ixh,d
	call YM2612_Destruct
	pop ix
	ret

; hl = callback (ix = chip)
; ix = this
Chips_ForEachActiveChip: PROC
	ld b,Chips.COUNT
	push ix
Loop:
	push bc
	ld c,(ix + Chips.chips + ChipFactory.instance)
	ld b,(ix + Chips.chips + ChipFactory.instance + 1)
	push ix
	ld ixl,c
	ld ixh,b
	call Chip_IsActive
	push hl
	call nz,System_JumpHL
	pop hl
	pop ix
	ld bc,ChipFactory._size
	add ix,bc
	pop bc
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Chips_PrintInfo:
	ld hl,Chip_PrintInfo
	call Chips_ForEachActiveChip
	ret

; iy = drivers
; ix = this
Chips_Connect:
	ld hl,Chip_Connect
	call Chips_ForEachActiveChip
	ret
