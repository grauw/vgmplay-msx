;
; VGMPlay
;
; VGM music file format player
;

	INCLUDE "Macros.asm"

DEBUG: equ 0

HEAP: equ 0C000H
HEAP_SIZE: equ 1180H
STACK_SIZE: equ 100H
READBUFFER_SIZE: equ 0D00H

	org 100H

RAM_PAGE0: ds 3F00H
RAM_PAGE1: ds 4000H

TPA: equ RAM_PAGE0
TPA_PAGE0: equ RAM_PAGE0
RAM_RESIDENT: equ RAM_PAGE0
TPA_PAGE1: equ RAM_PAGE1
RAM: equ RAM_PAGE1

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
	INCLUDE "Mapper.asm"
	INCLUDE "Heap.asm"
	INCLUDE "Utils.asm"
	INCLUDE "Application.asm"
	INCLUDE "Math.asm"
	INCLUDE "MappedBuffer.asm"
	INCLUDE "MappedBufferLoader.asm"
	INCLUDE "MappedReader.asm"
	INCLUDE "MappedWriter.asm"
	INCLUDE "Mapped32KWriter.asm"

	; gunzip
	INCLUDE "GzipArchive.asm"
	INCLUDE "deflate/Inflate.asm"
	INCLUDE "deflate/Alphabet.asm"
	INCLUDE "deflate/Branch.asm"
	INCLUDE "deflate/FixedAlphabets.asm"
	INCLUDE "deflate/DynamicAlphabets.asm"
	INCLUDE "Reader.asm"
	INCLUDE "Writer.asm"
	INCLUDE "FileReader.asm"
	INCLUDE "CRC32Checker.asm"

CRC32Table:
	; not present

	ENDS

	SECTION RAM_PAGE0

Heap_main:
	Heap HEAP, HEAP_SIZE

	ALIGN 100H
RAM_PAGE0_ALIGNED: ds 100H + READBUFFER_SIZE

	ENDS

	SECTION RAM_PAGE0_ALIGNED

	ALIGN 100H
READBUFFER: ds READBUFFER_SIZE

	ENDS

	SECTION TPA_PAGE1

	INCLUDE "VDP.asm"
	INCLUDE "CLI.asm"
	INCLUDE "Interrupt.asm"
	INCLUDE "VGM.asm"
	INCLUDE "Header.asm"
	INCLUDE "GD3.asm"
	INCLUDE "Player.asm"
	INCLUDE "timers/Timer.asm"
	INCLUDE "drivers/Drivers.asm"
	INCLUDE "chips/Chips.asm"
	INCLUDE "MemoryTest.asm"
	INCLUDE "HeapTest.asm"

	ENDS

	SECTION RAM_PAGE1

	ALIGN 100H
RAM_PAGE1_ALIGNED: ds 500H

	ENDS
