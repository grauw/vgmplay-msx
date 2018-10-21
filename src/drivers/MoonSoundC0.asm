;
; MoonSound YMF278B OPL4 in C0H I/O port base (configured DalSoRi R2)
;
MoonSoundC0_BASE_PORT: equ 0C0H

MoonSoundC0: equ MoonSound
MoonSoundC0_Destruct: equ MoonSound_Destruct
MoonSoundC0_SafeWriteRegister: equ MoonSound_SafeWriteRegister

; ix = this
; iy = drivers
MoonSoundC0_Construct:
	call MoonSound_Construct
	ld bc,MoonSoundC0_name
	call Driver_SetName
	ret

MoonSoundC0_name:
	db "MoonSound @ C0H",0

	SECTION RAM

MoonSoundC0_instance: MoonSound MoonSoundC0_BASE_PORT

	ENDS
