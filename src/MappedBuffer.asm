;
; Memory-mapped buffer
;
MappedBuffer: MACRO
	size:
		dd 0
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
	inc e
	ld hl,MappedBuffer_outOfMemoryError
	jp z,Application_TerminateWithError
	ld (ix + MappedBuffer.lastSegment),e
	dec e
	ld d,0
	push ix
	add ix,de
	add ix,de
	ld (ix + MappedBuffer.segments),a
	ld (ix + MappedBuffer.segments + 1),b
	pop ix
	ld a,e
	ret

; ehl = size
; ix = this
MappedBuffer_SetSize:
	ld (ix + MappedBuffer.size),l
	ld (ix + MappedBuffer.size + 1),h
	ld (ix + MappedBuffer.size + 2),e
	ret

; ehl = position
; ix = this
; f <- nc: position points past the end
; Modifies: af
MappedBuffer_IsValidPosition:
	ld a,e
	cp (ix + MappedBuffer.size + 2)
	ret c
	ld a,h
	cp (ix + MappedBuffer.size + 1)
	ret c
	ld a,l
	cp (ix + MappedBuffer.size)
	ret

;
	SECTION RAM

MappedBuffer_instance: MappedBuffer

	ENDS

MappedBuffer_outOfMemoryError:
	db "Not enough memory.",13,10,0
