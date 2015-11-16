;
; Memory-mapped buffer
;
MappedBuffer: MACRO
	lastSegment:
		db 0
	segments:
		ds 256 * 2
	_size:
	ENDM

; ix = this
MappedBuffer_Construct:
	ret

; ix = this
MappedBuffer_Destruct:
	ret

; h = address space page
; a = segment index
; ix = this
; a <- segment
; Modifies: af
MappedBuffer_SelectSegment:
	push bc
	push de
	push hl
	push ix
	ld e,a
	ld d,0
	add ix,de
	add ix,de
	ld a,(ix + MappedBuffer.segments + 1)
	call Memory_SetSlot
	ld a,(ix + MappedBuffer.segments)
	call Mapper_instance.PutP2
	pop ix
	pop hl
	pop de
	pop bc
	ret

; ix = this
; a <- segment number
; b <- slot id
MappedBuffer_AllocateSegment:
	ld a,(Mapper_instance.primaryMapperSlot)
	and 10001111B
	or 00100000B  ; allocate primary slot, or another
	ld b,a
	ld a,0
	call Mapper_instance.Allocate
	ld hl,MappedBuffer_outOfMemoryError
	jp c,Application_TerminateWithError
	ret

; ix = this
; a = segment number
; b = slot id
; a <- new segment index
; Modifies: de, hl
MappedBuffer_AddSegment:
	ld e,(ix + MappedBuffer.lastSegment)
	ld d,0
	push de
	push ix
	add ix,de
	add ix,de
	ld (ix + MappedBuffer.segments),a
	ld (ix + MappedBuffer.segments + 1),b
	pop ix
	inc de
	ld (ix + MappedBuffer.lastSegment),e
	bit 0,d
	ld hl,MappedBuffer_outOfMemoryError
	jp nz,Application_TerminateWithError
	pop de
	ld a,e
	ret

;
	SECTION RAM

MappedBuffer_instance: MappedBuffer

	ENDS

MappedBuffer_outOfMemoryError:
	db "Not enough memory.",13,10,0
