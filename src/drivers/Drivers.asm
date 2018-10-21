;
; Driver manager
;
	INCLUDE "Driver.asm"
	INCLUDE "PSG.asm"
	INCLUDE "MFRPSG.asm"
	INCLUDE "SFG.asm"
	INCLUDE "MSXMusic.asm"
	INCLUDE "MSXAudio.asm"
	INCLUDE "MoonSound.asm"
	INCLUDE "MoonSoundC0.asm"
	INCLUDE "SCC.asm"
	INCLUDE "SCCPlus.asm"
	INCLUDE "Franky.asm"
	INCLUDE "PlaySoniq.asm"
	INCLUDE "MMM.asm"
	INCLUDE "TurboRPCM.asm"
	INCLUDE "OPN.asm"
	INCLUDE "OPNA.asm"
	INCLUDE "Neotron.asm"
	INCLUDE "emulations/OPNFMOnSFG.asm"
	INCLUDE "emulations/OPNOnSFGPSG.asm"
	INCLUDE "emulations/OPN2OnSFGTurboRPCM.asm"
	INCLUDE "emulations/OPN2OnOPNATurboRPCM.asm"
	INCLUDE "emulations/OPN2OnTurboRPCM.asm"

Drivers: MACRO
	psg:
		dw 0
	mfrPSG:
		dw 0
	sfg:
		dw 0
	msxMusic:
		dw 0
	msxAudio:
		dw 0
	moonSound:
		dw 0
	moonSoundC0:
		dw 0
	scc:
		dw 0
	sccPlus:
		dw 0
	franky:
		dw 0
	playSoniq:
		dw 0
	mmm:
		dw 0
	turboRPCM:
		dw 0
	opn:
		dw 0
	opna:
		dw 0
	neotron:
		dw 0
	opnFMOnSFG:
		dw 0
	opnOnSFGPSG:
		dw 0
	opn2OnSFGTurboRPCM:
		dw 0
	opn2OnOPNATurboRPCM:
		dw 0
	opn2OnTurboRPCM:
		dw 0
	size:
	ENDM

; ix = this
; ix <- this
Drivers_Construct:
	ret

; ix = this
; ix <- this
Drivers_Destruct:
	push ix
	ld de,Drivers.psg
	call Drivers_GetDriver
	call nz,PSG_Destruct
	pop ix
	push ix
	ld de,Drivers.mfrPSG
	call Drivers_GetDriver
	call nz,MFRPSG_Destruct
	pop ix
	push ix
	ld de,Drivers.sfg
	call Drivers_GetDriver
	call nz,SFG_Destruct
	pop ix
	push ix
	ld de,Drivers.msxMusic
	call Drivers_GetDriver
	call nz,MSXMusic_Destruct
	pop ix
	push ix
	ld de,Drivers.msxAudio
	call Drivers_GetDriver
	call nz,MSXAudio_Destruct
	pop ix
	push ix
	ld de,Drivers.moonSound
	call Drivers_GetDriver
	call nz,MoonSound_Destruct
	pop ix
	push ix
	ld de,Drivers.moonSoundC0
	call Drivers_GetDriver
	call nz,MoonSoundC0_Destruct
	pop ix
	push ix
	ld de,Drivers.scc
	call Drivers_GetDriver
	call nz,SCC_Destruct
	pop ix
	push ix
	ld de,Drivers.sccPlus
	call Drivers_GetDriver
	call nz,SCCPlus_Destruct
	pop ix
	push ix
	ld de,Drivers.franky
	call Drivers_GetDriver
	call nz,Franky_Destruct
	pop ix
	push ix
	ld de,Drivers.playSoniq
	call Drivers_GetDriver
	call nz,PlaySoniq_Destruct
	pop ix
	push ix
	ld de,Drivers.mmm
	call Drivers_GetDriver
	call nz,MMM_Destruct
	pop ix
	push ix
	ld de,Drivers.turboRPCM
	call Drivers_GetDriver
	call nz,TurboRPCM_Destruct
	pop ix
	push ix
	ld de,Drivers.opn
	call Drivers_GetDriver
	call nz,OPN_Destruct
	pop ix
	push ix
	ld de,Drivers.opna
	call Drivers_GetDriver
	call nz,OPNA_Destruct
	pop ix
	push ix
	ld de,Drivers.neotron
	call Drivers_GetDriver
	call nz,Neotron_Destruct
	pop ix
	push ix
	ld de,Drivers.opnFMOnSFG
	call Drivers_GetDriver
	call nz,OPNFMOnSFG_Destruct
	pop ix
	push ix
	ld de,Drivers.opnOnSFGPSG
	call Drivers_GetDriver
	call nz,OPNOnSFGPSG_Destruct
	pop ix
	push ix
	ld de,Drivers.opn2OnSFGTurboRPCM
	call Drivers_GetDriver
	call nz,OPN2OnSFGTurboRPCM_Destruct
	pop ix
	push ix
	ld de,Drivers.opn2OnOPNATurboRPCM
	call Drivers_GetDriver
	call nz,OPN2OnOPNATurboRPCM_Destruct
	pop ix
	push ix
	ld de,Drivers.opn2OnTurboRPCM
	call Drivers_GetDriver
	call nz,OPN2OnTurboRPCM_Destruct
	pop ix
	ret

; de = offset
; ix = this
; de <- driver
; ix <- driver
; f <- z: not set
Drivers_GetDriver:
	add ix,de
	ld e,(ix)
	ld d,(ix + 1)
	ld ixl,e
	ld ixh,d
	ld a,e
	or d
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
; de <- MegaFlashROM SCC+ SD PSG driver
; f <- c: succeeded
Drivers_TryCreateMFRPSG_IY:
	ld a,(iy + Drivers.mfrPSG)
	or (iy + Drivers.mfrPSG + 1)
	ret nz
	call MFRPSG_Detect
	ret nc
	push ix
	ld ix,MFRPSG_instance
	call MFRPSG_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.mfrPSG),e
	ld (iy + Drivers.mfrPSG + 1),d
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
; de <- MoonSound at C0 driver
; f <- c: succeeded
Drivers_TryCreateMoonSoundC0_IY:
	ld a,(iy + Drivers.moonSoundC0)
	or (iy + Drivers.moonSoundC0 + 1)
	ret nz
	call MoonSoundC0_Detect
	ret nc
	push ix
	ld ix,MoonSoundC0_instance
	call MoonSoundC0_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.moonSoundC0),e
	ld (iy + Drivers.moonSoundC0 + 1),d
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
; de <- SCC+ driver
; f <- c: succeeded
Drivers_TryCreateSCCPlus_IY:
	ld a,(iy + Drivers.sccPlus)
	or (iy + Drivers.sccPlus + 1)
	ret nz
	call SCCPlus_Detect
	ret nc
	push ix
	ld ix,SCCPlus_instance
	call SCCPlus_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.sccPlus),e
	ld (iy + Drivers.sccPlus + 1),d
	scf
	ret

; ix = this
; de <- Franky driver
; f <- c: succeeded
Drivers_TryCreateFranky_IY:
	ld a,(iy + Drivers.franky)
	or (iy + Drivers.franky + 1)
	ret nz
	call Franky_Detect
	ret nc
	push ix
	ld ix,Franky_instance
	call Franky_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.franky),e
	ld (iy + Drivers.franky + 1),d
	scf
	ret

; ix = this
; de <- PlaySoniq driver
; f <- c: succeeded
Drivers_TryCreatePlaySoniq_IY:
	ld a,(iy + Drivers.playSoniq)
	or (iy + Drivers.playSoniq + 1)
	ret nz
	call PlaySoniq_Detect
	ret nc
	push ix
	ld ix,PlaySoniq_instance
	call PlaySoniq_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.playSoniq),e
	ld (iy + Drivers.playSoniq + 1),d
	scf
	ret

; ix = this
; de <- Musical Memory Mapper driver
; f <- c: succeeded
Drivers_TryCreateMMM_IY:
	ld a,(iy + Drivers.mmm)
	or (iy + Drivers.mmm + 1)
	ret nz
	call MMM_Detect
	ret nc
	push ix
	ld ix,MMM_instance
	call MMM_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.mmm),e
	ld (iy + Drivers.mmm + 1),d
	scf
	ret

; ix = this
; de <- turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateTurboRPCM_IY:
	ld a,(iy + Drivers.turboRPCM)
	or (iy + Drivers.turboRPCM + 1)
	ret nz
	call TurboRPCM_Detect
	ret nc
	push ix
	ld ix,TurboRPCM_instance
	call TurboRPCM_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.turboRPCM),e
	ld (iy + Drivers.turboRPCM + 1),d
	scf
	ret

; ix = this
; de <- OPN driver
; f <- c: succeeded
Drivers_TryCreateOPN_IY:
	ld a,(iy + Drivers.opn)
	or (iy + Drivers.opn + 1)
	ret nz
	call OPN_Detect
	ret nc
	push ix
	ld ix,OPN_instance
	call OPN_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.opn),e
	ld (iy + Drivers.opn + 1),d
	scf
	ret

; ix = this
; de <- OPNA driver
; f <- c: succeeded
Drivers_TryCreateOPNA_IY:
	ld a,(iy + Drivers.opna)
	or (iy + Drivers.opna + 1)
	ret nz
	call OPNA_Detect
	ret nc
	push ix
	ld ix,OPNA_instance
	call OPNA_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.opna),e
	ld (iy + Drivers.opna + 1),d
	scf
	ret

; ix = this
; de <- Neotron driver
; f <- c: succeeded
Drivers_TryCreateNeotron_IY:
	ld a,(iy + Drivers.neotron)
	or (iy + Drivers.neotron + 1)
	ret nz
	call Neotron_Detect
	ret nc
	push ix
	ld ix,Neotron_instance
	call Neotron_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.neotron),e
	ld (iy + Drivers.neotron + 1),d
	scf
	ret

; ix = this
; de <- OPN FM on SFG driver
; f <- c: succeeded
Drivers_TryCreateOPNFMOnSFG_IY:
	ld a,(iy + Drivers.opnFMOnSFG)
	or (iy + Drivers.opnFMOnSFG + 1)
	ret nz
	call Drivers_TryCreateSFG_IY
	ret nc
	push ix
	ld ix,OPNFMOnSFG_instance
	call OPNFMOnSFG_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.opnFMOnSFG),e
	ld (iy + Drivers.opnFMOnSFG + 1),d
	scf
	ret

; ix = this
; de <- OPN on SFG + PSG driver
; f <- c: succeeded
Drivers_TryCreateOPNOnSFGPSG_IY:
	ld a,(iy + Drivers.opnOnSFGPSG)
	or (iy + Drivers.opnOnSFGPSG + 1)
	ret nz
	call Drivers_TryCreateOPNFMOnSFG_IY
	ret nc
	push de
	call Drivers_TryCreatePSG_IY
	pop bc
	ret nc
	push ix
	ld ix,OPNOnSFGPSG_instance
	call OPNOnSFGPSG_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.opnOnSFGPSG),e
	ld (iy + Drivers.opnOnSFGPSG + 1),d
	scf
	ret

; ix = this
; de <- OPN2 on SFG + turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateOPN2OnSFGTurboRPCM_IY: PROC
	ld a,(iy + Drivers.opn2OnSFGTurboRPCM)
	or (iy + Drivers.opn2OnSFGTurboRPCM + 1)
	ret nz
	call Drivers_TryCreateOPNFMOnSFG_IY
	ret nc
	push de
	call Drivers_TryCreateTurboRPCM_IY
	pop bc
	jr c,FoundTurboRPCM
	ld de,0
FoundTurboRPCM:
	push ix
	ld ix,OPN2OnSFGTurboRPCM_instance
	call OPN2OnSFGTurboRPCM_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.opn2OnSFGTurboRPCM),e
	ld (iy + Drivers.opn2OnSFGTurboRPCM + 1),d
	scf
	ret
	ENDP

; ix = this
; de <- OPN2 on OPNA + turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateOPN2OnOPNATurboRPCM_IY: PROC
	ld a,(iy + Drivers.opn2OnOPNATurboRPCM)
	or (iy + Drivers.opn2OnOPNATurboRPCM + 1)
	ret nz
	call Drivers_TryCreateOPNA_IY
	ret nc
	push de
	call Drivers_TryCreateTurboRPCM_IY
	pop bc
	jr c,FoundTurboRPCM
	ld de,0
FoundTurboRPCM:
	push ix
	ld ix,OPN2OnOPNATurboRPCM_instance
	call OPN2OnOPNATurboRPCM_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.opn2OnOPNATurboRPCM),e
	ld (iy + Drivers.opn2OnOPNATurboRPCM + 1),d
	scf
	ret
	ENDP

; ix = this
; de <- OPN2 on turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateOPN2OnTurboRPCM_IY:
	ld a,(iy + Drivers.opn2OnTurboRPCM)
	or (iy + Drivers.opn2OnTurboRPCM + 1)
	ret nz
	call Drivers_TryCreateTurboRPCM_IY
	ret nc
	push ix
	ld ix,OPN2OnTurboRPCM_instance
	call OPN2OnTurboRPCM_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.opn2OnTurboRPCM),e
	ld (iy + Drivers.opn2OnTurboRPCM + 1),d
	scf
	ret
