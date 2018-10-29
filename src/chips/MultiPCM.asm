;
; VGM MultiPCM chip
;
MultiPCM: MACRO
	super: Chip MultiPCM_name, System_Return
	ENDM

; ix = this
; iy = header
MultiPCM_Construct:
	ld de,Header.multiPCMClock
	jp Chip_Construct

;
	SECTION RAM

MultiPCM_instance: MultiPCM

	ENDS

MultiPCM_name:
	db "MultiPCM",0
