;
; VGM MultiPCM chip
;
MultiPCM: MACRO
	super: Chip MultiPCM_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
MultiPCM_Construct:
	ld de,Header.multiPCMClock
	call Chip_Construct
	ret

;
	SECTION RAM

MultiPCM_instance: MultiPCM

	ENDS

MultiPCM_name:
	db "MultiPCM",0
