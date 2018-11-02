;
; MegaFlashROM SCC+ AY-3-8910 PSG driver
;
MFRPSG_BASE_PORT: equ 010H

MFRPSG: equ PSG
MFRPSG_Construct: equ PSG_Construct
MFRPSG_Destruct: equ PSG_Destruct

;
MFRPSG_name:
	db "MegaFlashROM PSG",0

	SECTION RAM

MFRPSG_instance: PSG MFRPSG_BASE_PORT, MFRPSG_name

	ENDS
