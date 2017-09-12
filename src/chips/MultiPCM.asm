;
; VGM MultiPCM chip
;
MultiPCM: MACRO
	super: Chip MultiPCM_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
MultiPCM_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.multiPCMClock - 80H)
	ld h,(iy + Header.multiPCMClock - 80H + 1)
	ld e,(iy + Header.multiPCMClock - 80H + 2)
	ld d,(iy + Header.multiPCMClock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
	SECTION RAM

MultiPCM_instance: MultiPCM

	ENDS

MultiPCM_name:
	db "MultiPCM",0
