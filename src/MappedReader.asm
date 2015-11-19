;
; Buffers an entire file in memory.
;
MappedReader_BASE_ADDRESS: equ 8000H

MappedReader: MACRO
	; iy = this
	; a <- value
	Read_IY:
		ld a,(0)
	position: equ $ - 2
		inc (iy + MappedReader.position)
		ret nz
		jp MappedReader_Read_IY.Continue

	buffer:
		dw MappedBuffer_instance
	positionSegmentIndex:
		db 0
	size:
	ENDM

; ix = this
; ix <- this
MappedReader_Construct:
	ld de,0
	ld hl,0
	call MappedReader_SetPosition
	ret

; ix = this
; de <- buffer
; ix <- buffer
MappedReader_GetBuffer:
	ld e,(ix + MappedReader.buffer)
	ld d,(ix + MappedReader.buffer + 1)
	ld ixl,e
	ld ixh,d
	ret

; ehl = address
; ix = this
MappedReader_SetPosition:
	push ix
	ld a,e
	call MappedReader_GetBuffer
	ld e,a
	call MappedBuffer_IsValidPosition
	pop ix
	jp nc,MappedReader_ThrowAddressOutOfBounds
	ld a,h
	and 3FH
	or 80H
	ld (ix + MappedReader.position),l
	ld (ix + MappedReader.position + 1),a
	ld a,h
	rla
	rl e
	rla
	rl e
	ld (ix + MappedReader.positionSegmentIndex),e
	ld a,e
	push ix
	call MappedReader_GetBuffer
	ld h,MappedReader_BASE_ADDRESS >> 8
	call MappedBuffer_SelectSegment
	pop ix
	ret

; ix = this
; dehl <- address
MappedReader_GetPosition:
	ld l,(ix + MappedReader.position)
	ld h,(ix + MappedReader.position + 1)
	ld a,(ix + MappedReader.positionSegmentIndex)
	rlc h
	rlc h
	rrca
	rr h
	rrca
	rr h
	and 3FH
	ld e,a
	ld d,0
	ret

; ehl = nr of bytes to skip
; ix = this
MappedReader_Skip:
	ld a,d
	and a
	jp nz,MappedReader_ThrowAddressOutOfBounds
	push de
	push hl
	call MappedReader_GetPosition
	pop bc
	add hl,bc
	pop bc
	ex de,hl
	adc hl,bc
	ex de,hl
	jp c,MappedReader_ThrowAddressOutOfBounds
	call MappedReader_SetPosition
	ret

; bc = nr of bytes to skip
; ix = this
; Modifies: af, bc, de, hl
MappedReader_SkipBC:
	call MappedReader_GetPosition
	add hl,bc
	ex de,hl
	ld bc,0
	adc hl,bc
	ex de,hl
	jp c,MappedReader_ThrowAddressOutOfBounds
	call MappedReader_SetPosition
	ret

; iy = this
; a <- value
; Modifies: f
MappedReader_Read_IY: PROC
	jp iy
Continue:
	push af
	ld a,(iy + MappedReader.position + 1)
	inc a
	ld (iy + MappedReader.position + 1),a
	cp (MappedReader_BASE_ADDRESS + 4000H) >> 8
	jr z,FinishBlock
	pop af
	ret
FinishBlock:
	ld (iy + MappedReader.position + 1),MappedReader_BASE_ADDRESS >> 8
	push iy
	ex (sp),ix
	call MappedReader_SelectNextSegment
	ex (sp),ix
	pop iy
	pop af
	ret
	ENDP

; iy = this
; de <- value
MappedReader_ReadWord_IY:
	call MappedReader_Read_IY
	ld e,a
	call MappedReader_Read_IY
	ld d,a
	ret

; iy = this
; dehl <- value
MappedReader_ReadDoubleWord_IY:
	call MappedReader_Read_IY
	ld l,a
	call MappedReader_Read_IY
	ld h,a
	call MappedReader_Read_IY
	ld e,a
	call MappedReader_Read_IY
	ld d,a
	ret

; Reads a byte from the current position.
; No bounds checks are performed.
;
; ix = this
; a <- value
; Modifies: af, hl
MappedReader_Read:
	ld l,(ix + MappedReader.position)
	ld h,(ix + MappedReader.position + 1)
	ld a,(hl)
	inc hl
	ld (ix + MappedReader.position),l
	ld (ix + MappedReader.position + 1),h
	bit 6,h
	ret z
	res 6,h
	ld (ix + MappedReader.position + 1),h
	push af
	ld a,(ix + MappedReader.positionSegmentIndex)
	inc a
	ld (ix + MappedReader.positionSegmentIndex),a
	push ix
	push de
	call MappedReader_GetBuffer
	ld h,MappedReader_BASE_ADDRESS >> 8
	call MappedBuffer_SelectSegment
	pop de
	pop ix
	pop af
	ret

; de = destination address
; bc = bytes count
; ix = this
MappedReader_ReadBlock: PROC
Loop:
	push bc
	push de
	call MappedReader_Read
	pop de
	pop bc
	ld (de),a
	inc de
	dec bc
	ld a,b
	or c
	jp nz,Loop
	ret
	ENDP

; ehl = bytes count
; iy = processing callback (hl = source, bc = bytes)
; ix = this
MappedReader_ReadAndProcessBlock: PROC
Loop:
	push hl
	ld hl,MappedReader_BASE_ADDRESS + 4000H
	ld c,(ix + MappedReader.position)
	ld b,(ix + MappedReader.position + 1)
	and a
	sbc hl,bc
	ex (sp),hl
	pop bc
	sbc hl,bc
	jr z,Process
	jp nc,Continue
	dec e
	jp m,FinalLap
Continue:
	push de
	push hl
	call Process
	pop hl
	pop de
	jp Loop
FinalLap:
	add hl,bc
	ret z
	ld c,l
	ld b,h
	jp Process
; bc = bytes, iy = processing callback, ix = this
Process:
	ld l,(ix + MappedReader.position)
	ld h,(ix + MappedReader.position + 1)
	push bc
	call CallIY
	pop bc
	call MappedReader_SkipBC
	ret
CallIY:
	jp iy
	ENDP

; ix = this
MappedReader_SelectNextSegment:
	ld a,(ix + MappedReader.positionSegmentIndex)
	inc a
	ld (ix + MappedReader.positionSegmentIndex),a
	push ix
	push de
	call MappedReader_GetBuffer
	ld h,MappedReader_BASE_ADDRESS >> 8
	call MappedBuffer_SelectSegment
	pop de
	pop ix
	ret

MappedReader_ThrowAddressOutOfBounds:
	ld hl,MappedReader_addressOutOfBoundsError
	call System_ThrowExceptionWithMessage
	ret

;
	SECTION RAM

MappedReader_instance: MappedReader

	ENDS

MappedReader_addressOutOfBoundsError:
	db "Address out of bounds.",13,10,0
