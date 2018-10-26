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
	chips:
		StaticFactory SN76489_instance, SN76489_Construct, Chip_Destruct
		StaticFactory YM2413_instance, YM2413_Construct, Chip_Destruct
		StaticFactory YM2151_instance, YM2151_Construct, Chip_Destruct
		StaticFactory SegaPCM_instance, SegaPCM_Construct, Chip_Destruct
		StaticFactory RF5C68_instance, RF5C68_Construct, Chip_Destruct
		StaticFactory YM2203_instance, YM2203_Construct, Chip_Destruct
		StaticFactory YM2608_instance, YM2608_Construct, Chip_Destruct
		StaticFactory YM2610_instance, YM2610_Construct, Chip_Destruct
		StaticFactory YM2612_instance, YM2612_Construct, YM2612_Destruct
		StaticFactory YM3812_instance, YM3812_Construct, Chip_Destruct
		StaticFactory Y8950_instance, Y8950_Construct, Chip_Destruct
		StaticFactory YM3526_instance, YM3526_Construct, Chip_Destruct
		StaticFactory YMF262_instance, YMF262_Construct, Chip_Destruct
		StaticFactory YMF278B_instance, YMF278B_Construct, Chip_Destruct
		StaticFactory YMF271_instance, YMF271_Construct, Chip_Destruct
		StaticFactory YMZ280B_instance, YMZ280B_Construct, Chip_Destruct
		StaticFactory RF5C164_instance, RF5C164_Construct, Chip_Destruct
		StaticFactory PWM_instance, PWM_Construct, Chip_Destruct
		StaticFactory AY8910_instance, AY8910_Construct, Chip_Destruct
		StaticFactory GameBoyDMG_instance, GameBoyDMG_Construct, Chip_Destruct
		StaticFactory NESAPU_instance, NESAPU_Construct, Chip_Destruct
		StaticFactory MultiPCM_instance, MultiPCM_Construct, Chip_Destruct
		StaticFactory UPD7759_instance, UPD7759_Construct, Chip_Destruct
		StaticFactory OKIM6258_instance, OKIM6258_Construct, Chip_Destruct
		StaticFactory OKIM6295_instance, OKIM6295_Construct, Chip_Destruct
		StaticFactory K051649_instance, K051649_Construct, Chip_Destruct
		StaticFactory K054539_instance, K054539_Construct, Chip_Destruct
		StaticFactory HuC6280_instance, HuC6280_Construct, Chip_Destruct
		StaticFactory C140_instance, C140_Construct, Chip_Destruct
		StaticFactory K053260_instance, K053260_Construct, Chip_Destruct
		StaticFactory Pokey_instance, Pokey_Construct, Chip_Destruct
		StaticFactory QSound_instance, QSound_Construct, Chip_Destruct
	COUNT: equ ($ - chips) / StaticFactory._size
	ENDM

; ix = this
; iy = header
Chips_Construct:
	ld hl,StaticFactory_Create
	jr Chips_ForEachChipFactory

; ix = this
Chips_Destruct:
	ld hl,StaticFactory_Destroy
	jr Chips_ForEachChipFactory

; hl = callback (ix = chip factory)
; ix = this
Chips_ForEachChipFactory: PROC
	push ix
	ld bc,Chips.chips
	add ix,bc
	ld b,Chips.COUNT
Loop:
	push bc
	push ix
	push hl
	call System_JumpHL
	pop hl
	pop ix
	ld bc,StaticFactory._size
	add ix,bc
	pop bc
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Chips_PrintInfo: PROC
	ld hl,Callback
	jr Chips_ForEachChipFactory
Callback:
	call StaticFactory_GetInstance
	call Chip_IsActive
	call nz,Chip_PrintInfo
	ret
	ENDP

; iy = drivers
; ix = this
Chips_Connect: PROC
	ld hl,Callback
	jr Chips_ForEachChipFactory
Callback:
	call StaticFactory_GetInstance
	call Chip_IsActive
	call nz,Chip_Connect
	ret
	ENDP
