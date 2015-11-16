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
		dw 0
	sfg:
		dw 0
	msxMusic:
		dw 0
	msxAudio:
		dw 0
	moonSound:
		dw 0
	scc:
		dw 0
	franky:
		dw 0
	mmm:
		dw 0
	size:
	ENDM

; ix = this
; ix <- this
Drivers_Construct:
	push ix
	call PSG_TryCreate
	pop ix
	ld (ix + Drivers.psg),e
	ld (ix + Drivers.psg + 1),d
	push ix
	call SFG_TryCreate
	pop ix
	ld (ix + Drivers.sfg),e
	ld (ix + Drivers.sfg + 1),d
	push ix
	call MSXMusic_TryCreate
	pop ix
	ld (ix + Drivers.msxMusic),e
	ld (ix + Drivers.msxMusic + 1),d
	push ix
	call MSXAudio_TryCreate
	pop ix
	ld (ix + Drivers.msxAudio),e
	ld (ix + Drivers.msxAudio + 1),d
	push ix
	call MoonSound_TryCreate
	pop ix
	ld (ix + Drivers.moonSound),e
	ld (ix + Drivers.moonSound + 1),d
	push ix
	call SCC_TryCreate
	pop ix
	ld (ix + Drivers.scc),e
	ld (ix + Drivers.scc + 1),d
	push ix
	call Franky_TryCreate
	pop ix
	ld (ix + Drivers.franky),e
	ld (ix + Drivers.franky + 1),d
	push ix
	call MMM_TryCreate
	pop ix
	ld (ix + Drivers.mmm),e
	ld (ix + Drivers.mmm + 1),d
	ret

; ix = this
; ix <- this
Drivers_Destruct:
	push ix
	call Drivers_GetPSG
	call nz,PSG_Destruct
	pop ix
	push ix
	call Drivers_GetSFG
	call nz,SFG_Destruct
	pop ix
	push ix
	call Drivers_GetMSXMusic
	call nz,MSXMusic_Destruct
	pop ix
	push ix
	call Drivers_GetMSXAudio
	call nz,MSXAudio_Destruct
	pop ix
	push ix
	call Drivers_GetMoonSound
	call nz,MoonSound_Destruct
	pop ix
	push ix
	call Drivers_GetSCC
	call nz,SCC_Destruct
	pop ix
	push ix
	call Drivers_GetFranky
	call nz,Franky_Destruct
	pop ix
	push ix
	call Drivers_GetMMM
	call nz,MMM_Destruct
	pop ix
	ret

; ix = this
; iy = player
; ix <- this
Drivers_Install:
	push ix
	call Drivers_GetPSG
	call nz,PSG_Install
	pop ix
	push ix
	call Drivers_GetSFG
	call nz,SFG_Install
	pop ix
	push ix
	call Drivers_GetMSXMusic
	call nz,MSXMusic_Install
	pop ix
	push ix
	call Drivers_GetMoonSound
	call nz,MoonSound_Install
	pop ix
	push ix
	call Drivers_GetMSXAudio
	call nz,MSXAudio_Install
	pop ix
	push ix
	call Drivers_GetSCC
	call nz,SCC_Install
	pop ix
	push ix
	call Drivers_GetFranky
	call nz,Franky_Install
	pop ix
	push ix
	call Drivers_GetMMM
	call nz,MMM_Install
	pop ix
	ret

; ix = this
; de <- PSG driver
; ix <- PSG driver
; f <- z: not set
Drivers_GetPSG:
	ld e,(ix + Drivers.psg)
	ld d,(ix + Drivers.psg + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
	ret

; ix = this
; de <- SFG driver
; ix <- SFG driver
; f <- z: not set
Drivers_GetSFG:
	ld e,(ix + Drivers.sfg)
	ld d,(ix + Drivers.sfg + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
	ret

; ix = this
; de <- MSX-MUSIC driver
; ix <- MSX-MUSIC driver
; f <- z: not set
Drivers_GetMSXMusic:
	ld e,(ix + Drivers.msxMusic)
	ld d,(ix + Drivers.msxMusic + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
	ret

; ix = this
; de <- MSX-AUDIO driver
; ix <- MSX-AUDIO driver
; f <- z: not set
Drivers_GetMSXAudio:
	ld e,(ix + Drivers.msxAudio)
	ld d,(ix + Drivers.msxAudio + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
	ret

; ix = this
; de <- MoonSound driver
; ix <- MoonSound driver
; f <- z: not set
Drivers_GetMoonSound:
	ld e,(ix + Drivers.moonSound)
	ld d,(ix + Drivers.moonSound + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
	ret

; ix = this
; de <- SCC driver
; ix <- SCC driver
; f <- z: not set
Drivers_GetSCC:
	ld e,(ix + Drivers.scc)
	ld d,(ix + Drivers.scc + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
	ret

; ix = this
; de <- Franky driver
; ix <- Franky driver
; f <- z: not set
Drivers_GetFranky:
	ld e,(ix + Drivers.franky)
	ld d,(ix + Drivers.franky + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
	ret

; ix = this
; de <- Musical Memory Mapper driver
; ix <- Musical Memory Mapper driver
; f <- z: not set
Drivers_GetMMM:
	ld e,(ix + Drivers.mmm)
	ld d,(ix + Drivers.mmm + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
	ret

;
	SECTION RAM

Drivers_instance: Drivers

	ENDS
