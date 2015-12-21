;
; VGM SN76489 chip
;
SN76489: MACRO
	super: Chip SN76489_name, Chip_ConnectDefault, Chip_InstallDefault
	ENDM

; ix = this
; iy = header
SN76489_Construct:
	ld l,(iy + Header.sn76489Clock)
	ld h,(iy + Header.sn76489Clock + 1)
	ld e,(iy + Header.sn76489Clock + 2)
	ld d,(iy + Header.sn76489Clock + 3)
	call Chip_Construct
	ret

;
SN76489_instance: SN76489

SN76489_name:
	db "SN76489 (DCSG)",0
