;
; VGMPlay
;
; VGM music file format player
;

	INCLUDE "Macros.asm"

DEBUG: equ 1

HEAP: equ 0C000H
HEAP_SIZE: equ 1000H
STACK_SIZE: equ 100H
READBUFFER_SIZE: equ 2000H

	org 100H

TPA: ds 2E00H
RAM: ds 0F00H
TPA_PAGE0: ds 0100H
RAM_PAGE0: ds 0100H
TPA_PAGE1: ds 0300H
RAM_PAGE1: ds 0100H
READBUFFER: ds VIRTUAL READBUFFER_SIZE

	SECTION TPA

;
; Program entry point
;
COM_Main:
	jp Application_Main

	INCLUDE "DOS.asm"
	INCLUDE "BIOS.asm"
	INCLUDE "Class.asm"
	INCLUDE "System.asm"
	INCLUDE "Memory.asm"
	INCLUDE "MemoryTest.asm"
	INCLUDE "Mapper.asm"
	INCLUDE "VDP.asm"
	INCLUDE "Heap.asm"
	INCLUDE "HeapTest.asm"
	INCLUDE "Application.asm"
	INCLUDE "CLI.asm"
	INCLUDE "VGM.asm"
	INCLUDE "Header.asm"
	INCLUDE "GD3.asm"
	INCLUDE "MappedBuffer.asm"
	INCLUDE "MappedBufferLoader.asm"
	INCLUDE "deflate/Reader.asm"
	INCLUDE "deflate/Writer.asm"
	INCLUDE "MappedReader.asm"
	INCLUDE "MappedWriter.asm"
	INCLUDE "Player.asm"
	INCLUDE "timers/Timer.asm"
	INCLUDE "drivers/Drivers.asm"
	INCLUDE "chips/Chips.asm"

	ENDS

	SECTION TPA_PAGE1

	ENDS

	SECTION RAM

Heap_main:
	Heap HEAP, HEAP_SIZE

	ENDS
