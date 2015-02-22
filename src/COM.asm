;
; VGMPlay
;
; VGM music file format player
;

	INCLUDE "Macros.asm"

DEBUG: equ 1

	org 100H

TPA: ds 02F00H
RAM: ds 1000H
PAGE1: ds 0400H
DATA:

	SECTION TPA

;
; Program entry point
;
COM_Main:
	jp VGMPlay_Main

	INCLUDE "DOS.asm"
	INCLUDE "BIOS.asm"
	INCLUDE "VGMPlay.asm"
	INCLUDE "Header.asm"
	INCLUDE "DataReader.asm"
	INCLUDE "Player.asm"
	INCLUDE "System.asm"
	INCLUDE "Memory.asm"
	INCLUDE "Heap.asm"
	INCLUDE "Class.asm"
	INCLUDE "SFG01.asm"

	ENDS
