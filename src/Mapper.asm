;
; Mapper support class
;
Mapper: MACRO
	primaryMapperSlot:
		db 0
	initialPage0:
		db 0
	initialPage1:
		db 0
	initialPage2:
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
	ld e,ixl
	ld d,ixh
	ld bc,Mapper.Allocate
	ex de,hl
	add hl,bc
	ex de,hl
	ld bc,16 * 3
	ldir
	call Mapper_instance.GetP0
	ld (ix + Mapper.initialPage0),a
	call Mapper_instance.GetP1
	ld (ix + Mapper.initialPage1),a
	call Mapper_instance.GetP2
	ld (ix + Mapper.initialPage2),a
	ret

; ix = this
; ix <- this
Mapper_Destructor:
	ld a,(ix + Mapper.primaryMapperSlot)
	ld h,00H
	call Memory_SetSlot
	ld a,(ix + Mapper.primaryMapperSlot)
	ld h,40H
	call Memory_SetSlot
	ld a,(ix + Mapper.primaryMapperSlot)
	ld h,80H
	call Memory_SetSlot
	ld a,(ix + Mapper.initialPage0)
	call Mapper_instance.PutP0
	ld a,(ix + Mapper.initialPage1)
	call Mapper_instance.PutP1
	ld a,(ix + Mapper.initialPage2)
	call Mapper_instance.PutP2
	ret

;
	SECTION RAM

Mapper_instance: Mapper

Mapper_noMapperSupportError:
	db "No mapper support routines available.",13,10,0

	ENDS
