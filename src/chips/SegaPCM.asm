;
; VGM SegaPCM chip
;
SegaPCM: MACRO
	super: Chip SegaPCM_name, System_Return, System_Return
	ENDM

; ix = this
; iy = header
SegaPCM_Construct:
	ld l,(iy + Header.segaPCMClock)
	ld h,(iy + Header.segaPCMClock + 1)
	ld e,(iy + Header.segaPCMClock + 2)
	ld d,(iy + Header.segaPCMClock + 3)
	call Chip_Construct
	ret

;
SegaPCM_instance: SegaPCM

SegaPCM_name:
	db "Sega PCM",0
