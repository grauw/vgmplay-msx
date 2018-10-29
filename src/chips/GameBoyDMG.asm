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

; ix = this
GameBoyDMG_Destruct: equ Chip_Destruct
;	jp Chip_Destruct

;
	SECTION RAM

GameBoyDMG_instance: GameBoyDMG

	ENDS

GameBoyDMG_name:
	db "Game Boy DMG",0
