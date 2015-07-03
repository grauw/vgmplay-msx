;
; Driver manager
;

	INCLUDE "PSG.asm"
	INCLUDE "SFG.asm"
	INCLUDE "MSXMusic.asm"
	INCLUDE "MSXAudio.asm"
	INCLUDE "MoonSound.asm"
	INCLUDE "SCC.asm"
	INCLUDE "Franky.asm"
	INCLUDE "MMM.asm"

Drivers: MACRO
	psg:
		dw PSG_instance
	sfg:
		dw SFG_instance
	msxMusic:
		dw MSXMusic_instance
	msxAudio:
		dw MSXAudio_instance
	moonSound:
		dw MoonSound_instance
	scc:
		dw SCC_instance
	franky:
		dw Franky_instance
	mmm:
		dw MMM_instance
	size:
	ENDM

; ix = this
; ix <- this
Drivers_Constructor:
	push ix
	call Drivers_GetPSG
	call PSG_Constructor
	pop ix
	push ix
	call Drivers_GetSFG
	call SFG_Constructor
	pop ix
	push ix
	call Drivers_GetMSXMusic
	call MSXMusic_Constructor
	pop ix
	push ix
	call Drivers_GetMSXAudio
	call MSXAudio_Constructor
	pop ix
	push ix
	call Drivers_GetMoonSound
	call MoonSound_Constructor
	pop ix
	push ix
	call Drivers_GetSCC
	call SCC_Constructor
	pop ix
	push ix
	call Drivers_GetFranky
	call Franky_Constructor
	pop ix
	push ix
	call Drivers_GetMMM
	call MMM_Constructor
	pop ix
	ret

; ix = this
; ix <- this
Drivers_Destructor:
	push ix
	call Drivers_GetPSG
	call PSG_Destructor
	pop ix
	push ix
	call Drivers_GetSFG
	call SFG_Destructor
	pop ix
	push ix
	call Drivers_GetMSXMusic
	call MSXMusic_Destructor
	pop ix
	push ix
	call Drivers_GetMSXAudio
	call MSXAudio_Destructor
	pop ix
	push ix
	call Drivers_GetMoonSound
	call MoonSound_Destructor
	pop ix
	push ix
	call Drivers_GetSCC
	call SCC_Destructor
	pop ix
	push ix
	call Drivers_GetFranky
	call Franky_Destructor
	pop ix
	push ix
	call Drivers_GetMMM
	call MMM_Destructor
	pop ix
	ret

; ix = this
; iy = player
; ix <- this
Drivers_Install:
	push ix
	call Drivers_GetPSG
	call PSG_Install
	pop ix
	push ix
	call Drivers_GetSFG
	call SFG_Install
	pop ix
	push ix
	call Drivers_GetMSXMusic
	call MSXMusic_Install
	pop ix
	push ix
	call Drivers_GetMoonSound
	call MoonSound_Install
	pop ix
	push ix
	call Drivers_GetMSXAudio
	call MSXAudio_Install
	pop ix
	push ix
	call Drivers_GetSCC
	call SCC_Install
	pop ix
	push ix
	call Drivers_GetFranky
	call Franky_Install
	pop ix
	push ix
	call Drivers_GetMMM
	call MMM_Install
	pop ix
	ret

; ix = this
; de <- PSG driver
; ix <- PSG driver
Drivers_GetPSG:
	ld e,(ix + Drivers.psg)
	ld d,(ix + Drivers.psg + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- SFG driver
; ix <- SFG driver
Drivers_GetSFG:
	ld e,(ix + Drivers.sfg)
	ld d,(ix + Drivers.sfg + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- MSX-MUSIC driver
; ix <- MSX-MUSIC driver
Drivers_GetMSXMusic:
	ld e,(ix + Drivers.msxMusic)
	ld d,(ix + Drivers.msxMusic + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- MSX-AUDIO driver
; ix <- MSX-AUDIO driver
Drivers_GetMSXAudio:
	ld e,(ix + Drivers.msxAudio)
	ld d,(ix + Drivers.msxAudio + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- MoonSound driver
; ix <- MoonSound driver
Drivers_GetMoonSound:
	ld e,(ix + Drivers.moonSound)
	ld d,(ix + Drivers.moonSound + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- SCC driver
; ix <- SCC driver
Drivers_GetSCC:
	ld e,(ix + Drivers.scc)
	ld d,(ix + Drivers.scc + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- Franky driver
; ix <- Franky driver
Drivers_GetFranky:
	ld e,(ix + Drivers.franky)
	ld d,(ix + Drivers.franky + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; de <- Musical Memory Mapper driver
; ix <- Musical Memory Mapper driver
Drivers_GetMMM:
	ld e,(ix + Drivers.mmm)
	ld d,(ix + Drivers.mmm + 1)
	ld ixl,e
	ld ixh,d
	ret

;
	SECTION RAM

Drivers_instance: Drivers

	ENDS
