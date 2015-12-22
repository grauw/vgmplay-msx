;
; VGM K053260 chip
;
K053260: MACRO
	super: Chip K053260_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
K053260_Construct:
	push iy
	ld de,80H
	add iy,de
	ld l,(iy + Header.k053260Clock - 80H)
	ld h,(iy + Header.k053260Clock - 80H + 1)
	ld e,(iy + Header.k053260Clock - 80H + 2)
	ld d,(iy + Header.k053260Clock - 80H + 3)
	pop iy
	call Chip_Construct
	ret

;
K053260_instance: K053260

K053260_name:
	db "K053260",0
