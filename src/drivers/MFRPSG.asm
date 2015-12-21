;
; MegaFlashROM SCC+ SD AY-3-8910 PSG driver
;
MFRPSG_ADDRESS: equ 010H
MFRPSG_DATA: equ 011H

MFRPSG: equ PSG

; ix = this
MFRPSG_Construct: equ PSG_Construct
MFRPSG_Destruct: equ PSG_Destruct
MFRPSG_WriteRegister: equ PSG_WriteRegister
MFRPSG_SafeWriteRegister: equ PSG_SafeWriteRegister
MFRPSG_Reset: equ PSG_SafeWriteRegister

; f <- c: found
MFRPSG_Detect:
	scf
	ret

;
	SECTION RAM

MFRPSG_instance: PSG MFRPSG_ADDRESS, MFRPSG_DATA

	ENDS
