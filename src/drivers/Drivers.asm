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
; f <- c: succeeded
Drivers_TryCreatePSG_IY:
	ld a,(iy + Drivers.psg)
	or (iy + Drivers.psg + 1)
	ret nz
	call PSG_Detect
	ret nc
	push ix
	ld ix,PSG_instance
	call PSG_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.psg),e
	ld (iy + Drivers.psg + 1),d
	scf
	ret

; ix = this
; de <- SFG driver
; f <- c: succeeded
Drivers_TryCreateSFG_IY:
	ld a,(iy + Drivers.sfg)
	or (iy + Drivers.sfg + 1)
	ret nz
	call SFG_Detect
	ret nc
	push ix
	ld ix,SFG_instance
	call SFG_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.sfg),e
	ld (iy + Drivers.sfg + 1),d
	scf
	ret

; ix = this
; de <- MSX-MUSIC driver
; f <- c: succeeded
Drivers_TryCreateMSXMusic_IY:
	ld a,(iy + Drivers.msxMusic)
	or (iy + Drivers.msxMusic + 1)
	ret nz
	call MSXMusic_Detect
	ret nc
	push ix
	ld ix,MSXMusic_instance
	call MSXMusic_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.msxMusic),e
	ld (iy + Drivers.msxMusic + 1),d
	scf
	ret

; ix = this
; de <- MSX-AUDIO driver
; f <- c: succeeded
Drivers_TryCreateMSXAudio_IY:
	ld a,(iy + Drivers.msxAudio)
	or (iy + Drivers.msxAudio + 1)
	ret nz
	call MSXAudio_Detect
	ret nc
	push ix
	ld ix,MSXAudio_instance
	call MSXAudio_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.msxAudio),e
	ld (iy + Drivers.msxAudio + 1),d
	scf
	ret

; ix = this
; de <- MoonSound driver
; f <- c: succeeded
Drivers_TryCreateMoonSound_IY:
	ld a,(iy + Drivers.moonSound)
	or (iy + Drivers.moonSound + 1)
	ret nz
	call MoonSound_Detect
	ret nc
	push ix
	ld ix,MoonSound_instance
	call MoonSound_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.moonSound),e
	ld (iy + Drivers.moonSound + 1),d
	scf
	ret

; ix = this
; de <- SCC driver
; f <- c: succeeded
Drivers_TryCreateSCC_IY:
	ld a,(iy + Drivers.scc)
	or (iy + Drivers.scc + 1)
	ret nz
	call SCC_Detect
	ret nc
	push ix
	ld ix,SCC_instance
	call SCC_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.scc),e
	ld (iy + Drivers.scc + 1),d
	scf
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
