;
; Writer backed by a mapped buffer
;
MappedWriter_BASE_ADDRESS: equ 8000H
MappedWriter_SEGMENT_SIZE: equ 4000H

MappedWriter: MACRO
	super: Writer
	buffer:
		dw 0
	size:
	ENDM

; de = mapped buffer
; ix = this
MappedWriter_Construct:
	ld (ix + MappedWriter.buffer),e
	ld (ix + MappedWriter.buffer + 1),d
	ld hl,MappedWriter_BASE_ADDRESS
	ld bc,MappedWriter_SEGMENT_SIZE
	ld de,MappedWriter_Flush
	call Writer_Construct
	call MappedWriter_AllocateNextSegment
	ret

; ix = this
MappedWriter_Destruct:
	call Writer_Destruct
	ret

; ix = this
; de <- buffer
; ix <- buffer
MappedWriter_GetBuffer:
	ld e,(ix + MappedWriter.buffer)
	ld d,(ix + MappedWriter.buffer + 1)
	ld ixl,e
	ld ixh,d
	ret

; bc = byte count
; de = buffer start
; ix = this
MappedWriter_Flush:
	push bc
	push de
	push ix
	call MappedWriter_GetBuffer
	call MappedBuffer_IncreaseSize
	pop ix
	pop de
	pop bc
	ld hl,MappedWriter_BASE_ADDRESS + MappedWriter_SEGMENT_SIZE
	and a
	sbc hl,de
	call c,System_ThrowException
	sbc hl,bc
	call c,System_ThrowException
	ret nz
	call MappedWriter_AllocateNextSegment
	ret

; ix = this
MappedWriter_AllocateNextSegment:
	push ix
	call MappedWriter_GetBuffer
	call MappedBuffer_AllocateAndAddSegment
	ld h,MappedWriter_BASE_ADDRESS >> 8
	call MappedBuffer_SelectSegment
	pop ix
	ret
