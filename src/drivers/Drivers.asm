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
		DriverInstance PSG_instance, PSG_Construct
	mfrPSG:
		DriverInstance MFRPSG_instance, MFRPSG_Construct
	sfg:
		DriverInstance SFG_instance, SFG_Construct
	msxMusic:
		DriverInstance MSXMusic_instance, MSXMusic_Construct
	msxAudio:
		DriverInstance MSXAudio_instance, MSXAudio_Construct
	moonSound:
		DriverInstance MoonSound_instance, MoonSound_Construct
	moonSoundC0:
		DriverInstance MoonSoundC0_instance, MoonSoundC0_Construct
	scc:
		DriverInstance SCC_instance, SCC_Construct
	sccPlus:
		DriverInstance SCCPlus_instance, SCCPlus_Construct
	franky:
		DriverInstance Franky_instance, Franky_Construct
	playSoniq:
		DriverInstance PlaySoniq_instance, PlaySoniq_Construct
	mmm:
		DriverInstance MMM_instance, MMM_Construct
	turboRPCM:
		DriverInstance TurboRPCM_instance, TurboRPCM_Construct
	opn:
		DriverInstance OPN_instance, OPN_Construct
	opna:
		DriverInstance OPNA_instance, OPNA_Construct
	neotron:
		DriverInstance Neotron_instance, Neotron_Construct
	opnFMOnSFG:
		DriverInstance OPNFMOnSFG_instance, OPNFMOnSFG_Construct
	opnOnSFGPSG:
		DriverInstance OPNOnSFGPSG_instance, OPNOnSFGPSG_Construct
	opn2OnSFGTurboRPCM:
		DriverInstance OPN2OnSFGTurboRPCM_instance, OPN2OnSFGTurboRPCM_Construct
	opn2OnOPNATurboRPCM:
		DriverInstance OPN2OnOPNATurboRPCM_instance, OPN2OnOPNATurboRPCM_Construct
	opn2OnTurboRPCM:
		DriverInstance OPN2OnTurboRPCM_instance, OPN2OnTurboRPCM_Construct
	size:
	ENDM

DriverInstance: MACRO ?instance, ?constructor
	instance:
		dw ?instance
	constructor:
		dw ?constructor
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

; de = driver instance offset
; iy = this
; de <- PSG driver
; f <- c: succeeded
Drivers_TryCreate_IY:
	push iy
	add iy,de
	ld e,(iy + DriverInstance.instance)
	ld d,(iy + DriverInstance.instance + 1)
	ld l,(iy + DriverInstance.constructor)
	ld h,(iy + DriverInstance.constructor + 1)
	ld a,(iy + DriverInstance.constructed)
	ld (iy + DriverInstance.constructed),1
	pop iy
	and a
	ret nz
	push ix
	ld ixl,e
	ld ixh,d
	call System_JumpHL
	call Driver_IsFound
	ld e,ixl
	ld d,ixh
	pop ix
	ret
