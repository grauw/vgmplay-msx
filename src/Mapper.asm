;
; Mapper support class
;
Mapper: MACRO
	primaryMapperSlot:
		db 0
	Allocate:
		jp 0
	Free:
		jp 0
	Read:
		jp 0
	Write:
		jp 0
	Call:
		jp 0
	Calls:
		jp 0
	PutPH:
		jp 0
	GetPH:
		jp 0
	PutP0:
		jp 0
	GetP0:
		jp 0
	PutP1:
		jp 0
	GetP1:
		jp 0
	PutP2:
		jp 0
	GetP2:
		jp 0
	PutP3:
		jp 0
	GetP3:
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
	ld (ix + Mapper.Allocate + 1),l
	ld (ix + Mapper.Allocate + 2),h
	add hl,de
	ld (ix + Mapper.Free + 1),l
	ld (ix + Mapper.Free + 2),h
	add hl,de
	ld (ix + Mapper.Read + 1),l
	ld (ix + Mapper.Read + 2),h
	add hl,de
	ld (ix + Mapper.Write + 1),l
	ld (ix + Mapper.Write + 2),h
	add hl,de
	ld (ix + Mapper.Call + 1),l
	ld (ix + Mapper.Call + 2),h
	add hl,de
	ld (ix + Mapper.Calls + 1),l
	ld (ix + Mapper.Calls + 2),h
	add hl,de
	ld (ix + Mapper.PutPH + 1),l
	ld (ix + Mapper.PutPH + 2),h
	add hl,de
	ld (ix + Mapper.GetPH + 1),l
	ld (ix + Mapper.GetPH + 2),h
	add hl,de
	ld (ix + Mapper.PutP0 + 1),l
	ld (ix + Mapper.PutP0 + 2),h
	add hl,de
	ld (ix + Mapper.GetP0 + 1),l
	ld (ix + Mapper.GetP0 + 2),h
	add hl,de
	ld (ix + Mapper.PutP1 + 1),l
	ld (ix + Mapper.PutP1 + 2),h
	add hl,de
	ld (ix + Mapper.GetP1 + 1),l
	ld (ix + Mapper.GetP1 + 2),h
	add hl,de
	ld (ix + Mapper.PutP2 + 1),l
	ld (ix + Mapper.PutP2 + 2),h
	add hl,de
	ld (ix + Mapper.GetP2 + 1),l
	ld (ix + Mapper.GetP2 + 2),h
	add hl,de
	ld (ix + Mapper.PutP3 + 1),l
	ld (ix + Mapper.PutP3 + 2),h
	add hl,de
	ld (ix + Mapper.GetP3 + 1),l
	ld (ix + Mapper.GetP3 + 2),h
	ret

;
	SECTION RAM

Mapper_instance: Mapper

Mapper_noMapperSupportError:
	db "No mapper support routines available.",13,10,0

	ENDS
