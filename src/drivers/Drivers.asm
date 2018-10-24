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
	INCLUDE "emulations/OPNAOnSFGPSGMSXAudio.asm"
	INCLUDE "emulations/OPN2OnSFGTurboRPCM.asm"
	INCLUDE "emulations/OPN2OnOPNATurboRPCM.asm"
	INCLUDE "emulations/OPN2OnTurboRPCM.asm"

Drivers: MACRO
	drivers:
	psg:
		StaticFactory PSG_instance, PSG_Construct, PSG_Destruct
	mfrPSG:
		StaticFactory MFRPSG_instance, MFRPSG_Construct, MFRPSG_Destruct
	sfg:
		StaticFactory SFG_instance, SFG_Construct, SFG_Destruct
	msxMusic:
		StaticFactory MSXMusic_instance, MSXMusic_Construct, MSXMusic_Destruct
	msxAudio:
		StaticFactory MSXAudio_instance, MSXAudio_Construct, MSXAudio_Destruct
	moonSound:
		StaticFactory MoonSound_instance, MoonSound_Construct, MoonSound_Destruct
	moonSoundC0:
		StaticFactory MoonSoundC0_instance, MoonSoundC0_Construct, MoonSoundC0_Destruct
	scc:
		StaticFactory SCC_instance, SCC_Construct, SCC_Destruct
	sccPlus:
		StaticFactory SCCPlus_instance, SCCPlus_Construct, SCCPlus_Destruct
	franky:
		StaticFactory Franky_instance, Franky_Construct, Franky_Destruct
	playSoniq:
		StaticFactory PlaySoniq_instance, PlaySoniq_Construct, PlaySoniq_Destruct
	mmm:
		StaticFactory MMM_instance, MMM_Construct, MMM_Destruct
	turboRPCM:
		StaticFactory TurboRPCM_instance, TurboRPCM_Construct, TurboRPCM_Destruct
	opn:
		StaticFactory OPN_instance, OPN_Construct, OPN_Destruct
	opna:
		StaticFactory OPNA_instance, OPNA_Construct, OPNA_Destruct
	neotron:
		StaticFactory Neotron_instance, Neotron_Construct, Neotron_Destruct
	opnFMOnSFG:
		StaticFactory OPNFMOnSFG_instance, OPNFMOnSFG_Construct, OPNFMOnSFG_Destruct
	opnOnSFGPSG:
		StaticFactory OPNOnSFGPSG_instance, OPNOnSFGPSG_Construct, OPNOnSFGPSG_Destruct
	opnaOnSFGPSGMSXAudio:
		StaticFactory OPNAOnSFGPSGMSXAudio_instance, OPNAOnSFGPSGMSXAudio_Construct, OPNAOnSFGPSGMSXAudio_Destruct
	opn2OnSFGTurboRPCM:
		StaticFactory OPN2OnSFGTurboRPCM_instance, OPN2OnSFGTurboRPCM_Construct, OPN2OnSFGTurboRPCM_Destruct
	opn2OnOPNATurboRPCM:
		StaticFactory OPN2OnOPNATurboRPCM_instance, OPN2OnOPNATurboRPCM_Construct, OPN2OnOPNATurboRPCM_Destruct
	opn2OnTurboRPCM:
		StaticFactory OPN2OnTurboRPCM_instance, OPN2OnTurboRPCM_Construct, OPN2OnTurboRPCM_Destruct
	COUNT: equ ($ - drivers) / StaticFactory._size
	size:
	ENDM

; ix = this
; ix <- this
Drivers_Construct:
	ret

; ix = this
; ix <- this
Drivers_Destruct: PROC
	push ix
	ld bc,Drivers.drivers
	add ix,bc
	ld b,Drivers.COUNT
Loop:
	push bc
	push ix
	call StaticFactory_Destroy
	pop ix
	ld bc,StaticFactory._size
	add ix,bc
	pop bc
	djnz Loop
	pop ix
	ret
	ENDP

; iy = this
; de <- PSG driver
; f <- c: succeeded
Drivers_TryCreatePSG_IY:
	ld de,Drivers.psg
	jr Drivers_TryCreate_IY

; iy = this
; de <- MegaFlashROM SCC+ SD PSG driver
; f <- c: succeeded
Drivers_TryCreateMFRPSG_IY:
	ld de,Drivers.mfrPSG
	jr Drivers_TryCreate_IY

; iy = this
; de <- SFG driver
; f <- c: succeeded
Drivers_TryCreateSFG_IY:
	ld de,Drivers.sfg
	jr Drivers_TryCreate_IY

; iy = this
; de <- MSX-MUSIC driver
; f <- c: succeeded
Drivers_TryCreateMSXMusic_IY:
	ld de,Drivers.msxMusic
	jr Drivers_TryCreate_IY

; iy = this
; de <- MSX-AUDIO driver
; f <- c: succeeded
Drivers_TryCreateMSXAudio_IY:
	ld de,Drivers.msxAudio
	jr Drivers_TryCreate_IY

; iy = this
; de <- MoonSound driver
; f <- c: succeeded
Drivers_TryCreateMoonSound_IY:
	ld de,Drivers.moonSound
	jr Drivers_TryCreate_IY

; iy = this
; de <- MoonSound at C0 driver
; f <- c: succeeded
Drivers_TryCreateMoonSoundC0_IY:
	ld de,Drivers.moonSoundC0
	jr Drivers_TryCreate_IY

; iy = this
; de <- SCC driver
; f <- c: succeeded
Drivers_TryCreateSCC_IY:
	ld de,Drivers.scc
	jr Drivers_TryCreate_IY

; iy = this
; de <- SCC+ driver
; f <- c: succeeded
Drivers_TryCreateSCCPlus_IY:
	ld de,Drivers.sccPlus
	jr Drivers_TryCreate_IY

; iy = this
; de <- Franky driver
; f <- c: succeeded
Drivers_TryCreateFranky_IY:
	ld de,Drivers.franky
	jr Drivers_TryCreate_IY

; iy = this
; de <- PlaySoniq driver
; f <- c: succeeded
Drivers_TryCreatePlaySoniq_IY:
	ld de,Drivers.playSoniq
	jr Drivers_TryCreate_IY

; iy = this
; de <- Musical Memory Mapper driver
; f <- c: succeeded
Drivers_TryCreateMMM_IY:
	ld de,Drivers.mmm
	jr Drivers_TryCreate_IY

; iy = this
; de <- turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateTurboRPCM_IY:
	ld de,Drivers.turboRPCM
	jr Drivers_TryCreate_IY

; iy = this
; de <- OPN driver
; f <- c: succeeded
Drivers_TryCreateOPN_IY:
	ld de,Drivers.opn
	jr Drivers_TryCreate_IY

; iy = this
; de <- OPNA driver
; f <- c: succeeded
Drivers_TryCreateOPNA_IY:
	ld de,Drivers.opna
	jr Drivers_TryCreate_IY

; iy = this
; de <- Neotron driver
; f <- c: succeeded
Drivers_TryCreateNeotron_IY:
	ld de,Drivers.neotron
	jr Drivers_TryCreate_IY

; iy = this
; de <- OPN FM on SFG driver
; f <- c: succeeded
Drivers_TryCreateOPNFMOnSFG_IY:
	ld de,Drivers.opnFMOnSFG
	jr Drivers_TryCreate_IY

; iy = this
; de <- OPN on SFG + PSG driver
; f <- c: succeeded
Drivers_TryCreateOPNOnSFGPSG_IY:
	ld de,Drivers.opnOnSFGPSG
	jr Drivers_TryCreate_IY

; iy = this
; de <- OPNA on SFG + PSG + MSX-AUDIO driver
; f <- c: succeeded
Drivers_TryCreateOPNAOnSFGPSGMSXAudio_IY:
	ld de,Drivers.opnaOnSFGPSGMSXAudio
	jr Drivers_TryCreate_IY

; iy = this
; de <- OPN2 on SFG + turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateOPN2OnSFGTurboRPCM_IY:
	ld de,Drivers.opn2OnSFGTurboRPCM
	jr Drivers_TryCreate_IY

; iy = this
; de <- OPN2 on OPNA + turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateOPN2OnOPNATurboRPCM_IY:
	ld de,Drivers.opn2OnOPNATurboRPCM
	jr Drivers_TryCreate_IY

; iy = this
; de <- OPN2 on turboR PCM driver
; f <- c: succeeded
Drivers_TryCreateOPN2OnTurboRPCM_IY:
	ld de,Drivers.opn2OnTurboRPCM
	jr Drivers_TryCreate_IY

; de = driver factory offset
; iy = this
; de <- driver
; f <- c: succeeded
Drivers_TryCreate_IY:
	push ix
	push iy
	pop ix
	add ix,de
	call StaticFactory_Create
	call c,Driver_IsFound
	ld e,ixl
	ld d,ixh
	pop ix
	ret
