;
; VGM GameBoyDMG chip
;
GameBoyDMG: MACRO
	super: Chip GameBoyDMG_name, System_Return
	ENDM

; ix = this
; iy = header
GameBoyDMG_Construct:
	ld de,Header.gameBoyDMGClock
	jp Chip_Construct

;
	SECTION RAM

GameBoyDMG_instance: GameBoyDMG

	ENDS

GameBoyDMG_name:
	db "Game Boy DMG",0
