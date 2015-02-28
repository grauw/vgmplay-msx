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

	SECTION TPA

;
; Program entry point
;
COM_Main:
	jp VGMPlay_Main

	INCLUDE "DOS.asm"
	INCLUDE "BIOS.asm"
	INCLUDE "System.asm"
	INCLUDE "Mapper.asm"
	INCLUDE "VDP.asm"
	INCLUDE "Heap.asm"
	INCLUDE "Class.asm"
	INCLUDE "VGMPlay.asm"
	INCLUDE "Header.asm"
	INCLUDE "GD3.asm"
	INCLUDE "Reader.asm"
	INCLUDE "Player.asm"
	INCLUDE "PSG.asm"
	INCLUDE "SFG.asm"
	INCLUDE "MSXMusic.asm"
	INCLUDE "MSXAudio.asm"

	ENDS

	SECTION PAGE1

	INCLUDE "Memory.asm"

	ENDS
