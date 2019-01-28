;
; Franky SN76489 DCSG driver
;
Franky_DATA: equ 48H
Franky_VDP_BASE: equ 88H
Franky_VDP_REGISTER: equ Franky_VDP_BASE + 1
Franky_VDP_STATUS: equ Franky_VDP_BASE + 1
Franky_VDP_V_COUNTER: equ 48H

Franky: MACRO
	super: DCSG Franky_DATA, Franky_nameNTSC
	ntsc:
		db 0
	ENDM

; ix = this
; iy = drivers
Franky_Construct:
	call DCSG_Construct
	call Franky_Detect
	jp nc,Driver_NotFound
	ld (ix + Franky.ntsc),a
	call Franky_GetName
	call Driver_SetName
	xor a
	out (40H),a  ; make sure no known switched I/O device is listening
	jp DCSG_Reset

; ix = this
Franky_Destruct:
	call Driver_IsFound
	ret nc
	jr DCSG_Mute

; ix = this
; hl <- name
Franky_GetName:
	bit 0,(ix + Franky.ntsc)
	ld hl,Franky_namePAL
	ret z
	ld hl,Franky_nameNTSC
	ret

; ix = this
; a <- 0: PAL, -1: NTSC
; f <- c: found
Franky_Detect: PROC
	xor a
	out (40H),a    ; make sure no known switched I/O device is responding
	ld c,Franky_VDP_REGISTER
	ld de,(1 | 80H) << 8 | 00H
	call WriteVDP  ; VDP mode select 256x192
	ld de,(0 | 80H) << 8 | 01H
	call WriteVDP  ; VDP mode select 256x192 + EXTVID
	ld b,40H
	djnz $         ; wait 20 µs for it to desync (+margin)
	in a,(Franky_VDP_V_COUNTER)
	ld de,(0 | 80H) << 8 | 00H
	call WriteVDP  ; VDP disable EXTVID
	cp -43         ; NTSC sync start line
	jr z,Found
	xor -70        ; PAL sync start line
	jr z,Found
	ret
Found:
	neg
	sbc a,a
	scf
	ret
WriteVDP:
	out (c),e
	out (c),d
	ret
	ENDP

;
	SECTION RAM

Franky_instance: Franky

	ENDS

Franky_interface: equ DCSG_interface

Franky_namePAL:
	db "Franky PAL",0

Franky_nameNTSC:
	db "Franky NTSC",0
