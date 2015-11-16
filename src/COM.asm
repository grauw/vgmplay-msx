;
; VGMPlay
;
; VGM music file format player
;

	INCLUDE "Macros.asm"

DEBUG: equ 0

HEAP: equ 0C000H
HEAP_SIZE: equ 1000H

	org 100H

TPA: ds 3000H
RAM: ds 0F00H
PAGE1: ds 0400H
SCRATCH: ds VIRTUAL 2000H

	SECTION TPA

;
; Program entry point
;
COM_Main:
	jp Application_Main

	INCLUDE "DOS.asm"
	INCLUDE "BIOS.asm"
	INCLUDE "System.asm"
	INCLUDE "Mapper.asm"
	INCLUDE "VDP.asm"
	INCLUDE "Heap.asm"
	INCLUDE "HeapTest.asm"
	INCLUDE "Class.asm"
	INCLUDE "Application.asm"
	INCLUDE "CLI.asm"
	INCLUDE "Header.asm"
	INCLUDE "GD3.asm"
	INCLUDE "MappedBuffer.asm"
	INCLUDE "MappedReader.asm"
	INCLUDE "Player.asm"
	INCLUDE "timers/Timer.asm"
	INCLUDE "drivers/Drivers.asm"

	ENDS

	SECTION PAGE1

	INCLUDE "Memory.asm"
	INCLUDE "MemoryTest.asm"

	ENDS

	SECTION RAM

Heap_main:
	Heap HEAP, HEAP_SIZE

	ENDS
