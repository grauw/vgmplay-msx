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
		StaticFactory SN76489_instance, SN76489_Construct, System_Return
		StaticFactory YM2413_instance, YM2413_Construct, System_Return
		StaticFactory YM2151_instance, YM2151_Construct, System_Return
		StaticFactory SegaPCM_instance, SegaPCM_Construct, System_Return
		StaticFactory RF5C68_instance, RF5C68_Construct, System_Return
		StaticFactory YM2203_instance, YM2203_Construct, System_Return
		StaticFactory YM2608_instance, YM2608_Construct, System_Return
		StaticFactory YM2610_instance, YM2610_Construct, System_Return
	ym2612:
		StaticFactory YM2612_instance, YM2612_Construct, System_Return
		StaticFactory YM3812_instance, YM3812_Construct, System_Return
		StaticFactory Y8950_instance, Y8950_Construct, System_Return
		StaticFactory YM3526_instance, YM3526_Construct, System_Return
		StaticFactory YMF262_instance, YMF262_Construct, System_Return
		StaticFactory YMF278B_instance, YMF278B_Construct, System_Return
		StaticFactory YMF271_instance, YMF271_Construct, System_Return
		StaticFactory YMZ280B_instance, YMZ280B_Construct, System_Return
		StaticFactory RF5C164_instance, RF5C164_Construct, System_Return
		StaticFactory PWM_instance, PWM_Construct, System_Return
		StaticFactory AY8910_instance, AY8910_Construct, System_Return
		StaticFactory GameBoyDMG_instance, GameBoyDMG_Construct, System_Return
		StaticFactory NESAPU_instance, NESAPU_Construct, System_Return
		StaticFactory MultiPCM_instance, MultiPCM_Construct, System_Return
		StaticFactory UPD7759_instance, UPD7759_Construct, System_Return
		StaticFactory OKIM6258_instance, OKIM6258_Construct, System_Return
		StaticFactory OKIM6295_instance, OKIM6295_Construct, System_Return
		StaticFactory K051649_instance, K051649_Construct, System_Return
		StaticFactory K054539_instance, K054539_Construct, System_Return
		StaticFactory HuC6280_instance, HuC6280_Construct, System_Return
		StaticFactory C140_instance, C140_Construct, System_Return
		StaticFactory K053260_instance, K053260_Construct, System_Return
		StaticFactory Pokey_instance, Pokey_Construct, System_Return
		StaticFactory QSound_instance, QSound_Construct, System_Return
	COUNT: equ ($ - chips) / StaticFactory._size
	ENDM

; ix = this
; iy = header
Chips_Construct: PROC
	push ix
	ld bc,Chips.chips
	add ix,bc
	ld b,Chips.COUNT
Loop:
	push bc
	push ix
	call StaticFactory_Create
	pop ix
	ld bc,StaticFactory._size
	add ix,bc
	pop bc
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Chips_Destruct:
	push ix
	ld de,Chips.ym2612
	add ix,de
	call StaticFactory_GetInstance
	call YM2612_Destruct
	pop ix
	ret

; hl = callback (ix = chip)
; ix = this
Chips_ForEachActiveChip: PROC
	push ix
	ld bc,Chips.chips
	add ix,bc
	ld b,Chips.COUNT
Loop:
	push bc
	push ix
	push hl
	call StaticFactory_GetInstance
	call Chip_IsActive
	call nz,System_JumpHL
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
