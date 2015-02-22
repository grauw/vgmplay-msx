;
; Mapper support class
;
Mapper: MACRO
	primaryMapperSlot:
		db 0
	Allocate: equ $ + 1
		jp 0
	Free: equ $ + 1
		jp 0
	Read: equ $ + 1
		jp 0
	Write: equ $ + 1
		jp 0
	Call: equ $ + 1
		jp 0
	Calls: equ $ + 1
		jp 0
	PutPH: equ $ + 1
		jp 0
	GetPH: equ $ + 1
		jp 0
	PutP0: equ $ + 1
		jp 0
	GetP0: equ $ + 1
		jp 0
	PutP1: equ $ + 1
		jp 0
	GetP1: equ $ + 1
		jp 0
	PutP2: equ $ + 1
		jp 0
	GetP2: equ $ + 1
		jp 0
	PutP3: equ $ + 1
		jp 0
	GetP3: equ $ + 1
		jp 0
	ENDM

; ix = this
; ix <- this
Mapper_Constructor:
	ld a,(HOKVLD)
	bit 0,a
	ld hl,Mapper_noMapperSupportError
	call z,VGMPlay_TerminateWithError
	push ix
	ld a,0
	ld de,0402H
	call EXTBIO
	pop ix
	push hl
	and a
	ld hl,Mapper_noMapperSupportError
	call z,VGMPlay_TerminateWithError
	pop hl
	ld (ix + Mapper.primaryMapperSlot),b
	ld de,3
	ld (ix + Mapper.Allocate),l
	ld (ix + Mapper.Allocate + 1),h
	add hl,de
	ld (ix + Mapper.Free),l
	ld (ix + Mapper.Free + 1),h
	add hl,de
	ld (ix + Mapper.Read),l
	ld (ix + Mapper.Read + 1),h
	add hl,de
	ld (ix + Mapper.Write),l
	ld (ix + Mapper.Write + 1),h
	add hl,de
	ld (ix + Mapper.Call),l
	ld (ix + Mapper.Call + 1),h
	add hl,de
	ld (ix + Mapper.Calls),l
	ld (ix + Mapper.Calls + 1),h
	add hl,de
	ld (ix + Mapper.PutPH),l
	ld (ix + Mapper.PutPH + 1),h
	add hl,de
	ld (ix + Mapper.GetPH),l
	ld (ix + Mapper.GetPH + 1),h
	add hl,de
	ld (ix + Mapper.PutP0),l
	ld (ix + Mapper.PutP0 + 1),h
	add hl,de
	ld (ix + Mapper.GetP0),l
	ld (ix + Mapper.GetP0 + 1),h
	add hl,de
	ld (ix + Mapper.PutP1),l
	ld (ix + Mapper.PutP1 + 1),h
	add hl,de
	ld (ix + Mapper.GetP1),l
	ld (ix + Mapper.GetP1 + 1),h
	add hl,de
	ld (ix + Mapper.PutP2),l
	ld (ix + Mapper.PutP2 + 1),h
	add hl,de
	ld (ix + Mapper.GetP2),l
	ld (ix + Mapper.GetP2 + 1),h
	add hl,de
	ld (ix + Mapper.PutP3),l
	ld (ix + Mapper.PutP3 + 1),h
	add hl,de
	ld (ix + Mapper.GetP3),l
	ld (ix + Mapper.GetP3 + 1),h
	ret

;
	SECTION RAM

Mapper_instance: Mapper

Mapper_noMapperSupportError:
	db "No mapper support routines available.",13,10,0

	ENDS
