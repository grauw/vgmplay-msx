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
		DriverInstance PSG_instance
	mfrPSG:
		DriverInstance MFRPSG_instance
	sfg:
		DriverInstance SFG_instance
	msxMusic:
		DriverInstance MSXMusic_instance
	msxAudio:
		DriverInstance MSXAudio_instance
	moonSound:
		DriverInstance MoonSound_instance
	moonSoundC0:
		DriverInstance MoonSoundC0_instance
	scc:
		DriverInstance SCC_instance
	sccPlus:
		DriverInstance SCCPlus_instance
	franky:
		DriverInstance Franky_instance
	playSoniq:
		DriverInstance PlaySoniq_instance
	mmm:
		DriverInstance MMM_instance
	turboRPCM:
		DriverInstance TurboRPCM_instance
	opn:
		DriverInstance OPN_instance
	opna:
		DriverInstance OPNA_instance
	neotron:
		DriverInstance Neotron_instance
	opnFMOnSFG:
		DriverInstance OPNFMOnSFG_instance
	opnOnSFGPSG:
		DriverInstance OPNOnSFGPSG_instance
	opn2OnSFGTurboRPCM:
		DriverInstance OPN2OnSFGTurboRPCM_instance
	opn2OnOPNATurboRPCM:
		DriverInstance OPN2OnOPNATurboRPCM_instance
	opn2OnTurboRPCM:
		DriverInstance OPN2OnTurboRPCM_instance
	size:
	ENDM

DriverInstance: MACRO ?instance
	instance:
		dw ?instance
	constructed:
		db 0
	_size:
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

; de = driver instance offset
; ix = this
; de <- driver
; ix <- driver
; f <- z: not set
Drivers_GetDriver:
	add ix,de
	ld e,(ix + DriverInstance.instance)
	ld d,(ix + DriverInstance.instance + 1)
	bit 0,(ix + DriverInstance.constructed)
	ld ixl,e
	ld ixh,d
	ret

; iy = this
; de <- PSG driver
; f <- c: succeeded
Drivers_TryCreatePSG_IY:
	ld a,(iy + Drivers.psg + DriverInstance.constructed)
	and a
	ret nz
	call PSG_Detect
	ret nc
	push ix
	ld ix,PSG_instance
	call PSG_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.psg + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- MegaFlashROM SCC+ SD PSG driver
; f <- c: succeeded
Drivers_TryCreateMFRPSG_IY:
	ld a,(iy + Drivers.mfrPSG + DriverInstance.constructed)
	and a
	ret nz
	call MFRPSG_Detect
	ret nc
	push ix
	ld ix,MFRPSG_instance
	call MFRPSG_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.mfrPSG + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- SFG driver
; f <- c: succeeded
Drivers_TryCreateSFG_IY:
	ld a,(iy + Drivers.sfg + DriverInstance.constructed)
	and a
	ret nz
	call SFG_Detect
	ret nc
	push ix
	ld ix,SFG_instance
	call SFG_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.sfg + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- MSX-MUSIC driver
; f <- c: succeeded
Drivers_TryCreateMSXMusic_IY:
	ld a,(iy + Drivers.msxMusic + DriverInstance.constructed)
	and a
	ret nz
	call MSXMusic_Detect
	ret nc
	push ix
	ld ix,MSXMusic_instance
	call MSXMusic_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.msxMusic + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- MSX-AUDIO driver
; f <- c: succeeded
Drivers_TryCreateMSXAudio_IY:
	ld a,(iy + Drivers.msxAudio + DriverInstance.constructed)
	and a
	ret nz
	call MSXAudio_Detect
	ret nc
	push ix
	ld ix,MSXAudio_instance
	call MSXAudio_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.msxAudio + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- MoonSound driver
; f <- c: succeeded
Drivers_TryCreateMoonSound_IY:
	ld a,(iy + Drivers.moonSound + DriverInstance.constructed)
	and a
	ret nz
	call MoonSound_Detect
	ret nc
	push ix
	ld ix,MoonSound_instance
	call MoonSound_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.moonSound + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- MoonSound at C0 driver
; f <- c: succeeded
Drivers_TryCreateMoonSoundC0_IY:
	ld a,(iy + Drivers.moonSoundC0 + DriverInstance.constructed)
	and a
	ret nz
	call MoonSoundC0_Detect
	ret nc
	push ix
	ld ix,MoonSoundC0_instance
	call MoonSoundC0_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.moonSoundC0 + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- SCC driver
; f <- c: succeeded
Drivers_TryCreateSCC_IY:
	ld a,(iy + Drivers.scc + DriverInstance.constructed)
	and a
	ret nz
	call SCC_Detect
	ret nc
	push ix
	ld ix,SCC_instance
	call SCC_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.scc + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- SCC+ driver
; f <- c: succeeded
Drivers_TryCreateSCCPlus_IY:
	ld a,(iy + Drivers.sccPlus + DriverInstance.constructed)
	and a
	ret nz
	call SCCPlus_Detect
	ret nc
	push ix
	ld ix,SCCPlus_instance
	call SCCPlus_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.sccPlus + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- Franky driver
; f <- c: succeeded
Drivers_TryCreateFranky_IY:
	ld a,(iy + Drivers.franky + DriverInstance.constructed)
	and a
	ret nz
	call Franky_Detect
	ret nc
	push ix
	ld ix,Franky_instance
	call Franky_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.franky + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- PlaySoniq driver
; f <- c: succeeded
Drivers_TryCreatePlaySoniq_IY:
	ld a,(iy + Drivers.playSoniq + DriverInstance.constructed)
	and a
	ret nz
	call PlaySoniq_Detect
	ret nc
	push ix
	ld ix,PlaySoniq_instance
	call PlaySoniq_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.playSoniq + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- Musical Memory Mapper driver
; f <- c: succeeded
Drivers_TryCreateMMM_IY:
	ld a,(iy + Drivers.mmm + DriverInstance.constructed)
	and a
	ret nz
	call MMM_Detect
	ret nc
	push ix
	ld ix,MMM_instance
	call MMM_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.mmm + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateTurboRPCM_IY:
	ld a,(iy + Drivers.turboRPCM + DriverInstance.constructed)
	and a
	ret nz
	call TurboRPCM_Detect
	ret nc
	push ix
	ld ix,TurboRPCM_instance
	call TurboRPCM_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.turboRPCM + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- OPN driver
; f <- c: succeeded
Drivers_TryCreateOPN_IY:
	ld a,(iy + Drivers.opn + DriverInstance.constructed)
	and a
	ret nz
	call OPN_Detect
	ret nc
	push ix
	ld ix,OPN_instance
	call OPN_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.opn + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- OPNA driver
; f <- c: succeeded
Drivers_TryCreateOPNA_IY:
	ld a,(iy + Drivers.opna + DriverInstance.constructed)
	and a
	ret nz
	call OPNA_Detect
	ret nc
	push ix
	ld ix,OPNA_instance
	call OPNA_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.opna + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- Neotron driver
; f <- c: succeeded
Drivers_TryCreateNeotron_IY:
	ld a,(iy + Drivers.neotron + DriverInstance.constructed)
	and a
	ret nz
	call Neotron_Detect
	ret nc
	push ix
	ld ix,Neotron_instance
	call Neotron_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.neotron + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- OPN FM on SFG driver
; f <- c: succeeded
Drivers_TryCreateOPNFMOnSFG_IY:
	ld a,(iy + Drivers.opnFMOnSFG + DriverInstance.constructed)
	and a
	ret nz
	call Drivers_TryCreateSFG_IY
	ret nc
	push ix
	ld ix,OPNFMOnSFG_instance
	call OPNFMOnSFG_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.opnFMOnSFG + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- OPN on SFG + PSG driver
; f <- c: succeeded
Drivers_TryCreateOPNOnSFGPSG_IY:
	ld a,(iy + Drivers.opnOnSFGPSG + DriverInstance.constructed)
	and a
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
	ld (iy + Drivers.opnOnSFGPSG + DriverInstance.constructed),1
	scf
	ret

; iy = this
; de <- OPN2 on SFG + turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateOPN2OnSFGTurboRPCM_IY: PROC
	ld a,(iy + Drivers.opn2OnSFGTurboRPCM + DriverInstance.constructed)
	and a
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
	ld (iy + Drivers.opn2OnSFGTurboRPCM + DriverInstance.constructed),1
	scf
	ret
	ENDP

; iy = this
; de <- OPN2 on OPNA + turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateOPN2OnOPNATurboRPCM_IY: PROC
	ld a,(iy + Drivers.opn2OnOPNATurboRPCM + DriverInstance.constructed)
	and a
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
	ld (iy + Drivers.opn2OnOPNATurboRPCM + DriverInstance.constructed),1
	scf
	ret
	ENDP

; iy = this
; de <- OPN2 on turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateOPN2OnTurboRPCM_IY:
	ld a,(iy + Drivers.opn2OnTurboRPCM + DriverInstance.constructed)
	and a
	ret nz
	call Drivers_TryCreateTurboRPCM_IY
	ret nc
	push ix
	ld ix,OPN2OnTurboRPCM_instance
	call OPN2OnTurboRPCM_Construct
	ld e,ixl
	ld d,ixh
	pop ix
	ld (iy + Drivers.opn2OnTurboRPCM + DriverInstance.constructed),1
	scf
	ret
