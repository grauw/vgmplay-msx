;
; VGM UPD7759 chip
;
UPD7759: MACRO
	super: Chip UPD7759_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
UPD7759_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.uPD7759Clock - 80H)
	ld h,(iy + Header.uPD7759Clock - 80H + 1)
	ld e,(iy + Header.uPD7759Clock - 80H + 2)
	ld d,(iy + Header.uPD7759Clock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
	SECTION RAM

UPD7759_instance: UPD7759

	ENDS

UPD7759_name:
	db "uPD7759",0
