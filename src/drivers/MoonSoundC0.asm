;
; MoonSound YMF278B OPL4 in C0H I/O port base (configured DalSoRi R2)
;
MoonSoundC0_BASE_PORT: equ 0C0H

MoonSoundC0: equ MoonSound
MoonSoundC0_Destruct: equ MoonSound_Destruct
MoonSoundC0_SafeWriteRegister: equ MoonSound_SafeWriteRegister

; ix = this
MoonSoundC0_Construct:
	call MoonSound_Construct
	ld bc,MoonSoundC0_name
	ld (ix + Driver.name),c
	ld (ix + Driver.name + 1),b
	ret

; f <- c: Found
MoonSoundC0_Detect:
	in a,(MoonSoundC0_BASE_PORT + MoonSound_STATUS)
	and 11111101B  ; sometimes LD is set
	sub 00H
	and a
	ret nz
	scf
	ret

MoonSoundC0_name:
	db "MoonSound @ C0H",0

	SECTION RAM

MoonSoundC0_instance: MoonSound MoonSoundC0_BASE_PORT

	ENDS
