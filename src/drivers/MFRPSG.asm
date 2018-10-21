;
; MegaFlashROM SCC+ AY-3-8910 PSG driver
;
MFRPSG_ADDRESS: equ 010H
MFRPSG_DATA: equ 011H

MFRPSG: equ PSG

; ix = this
MFRPSG_Destruct: equ PSG_Destruct
MFRPSG_WriteRegister: equ PSG_WriteRegister
MFRPSG_SafeWriteRegister: equ PSG_SafeWriteRegister
MFRPSG_Reset: equ PSG_Reset

; ix = this
; iy = drivers
MFRPSG_Construct:
	call PSG_Construct
	ld bc,MFRPSG_name
	call Driver_SetName
	ret

;
MFRPSG_name:
	db "MegaFlashROM PSG",0

	SECTION RAM

MFRPSG_instance: PSG MFRPSG_ADDRESS, MFRPSG_DATA

	ENDS
