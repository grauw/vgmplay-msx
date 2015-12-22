;
; VGM GameBoyDMG chip
;
GameBoyDMG: MACRO
	super: Chip GameBoyDMG_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
GameBoyDMG_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.gameBoyDMGClock - 80H)
	ld h,(iy + Header.gameBoyDMGClock - 80H + 1)
	ld e,(iy + Header.gameBoyDMGClock - 80H + 2)
	ld d,(iy + Header.gameBoyDMGClock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
GameBoyDMG_instance: GameBoyDMG

GameBoyDMG_name:
	db "Game Boy DMG",0
