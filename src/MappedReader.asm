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
	push ix
	ex (sp),iy
	call MappedReader_SetPosition_IY
	ex (sp),iy
	pop ix
	ret

; iy = this
; de <- buffer
; ix <- buffer
MappedReader_GetBuffer_IY:
	ld e,(iy + MappedReader.buffer)
	ld d,(iy + MappedReader.buffer + 1)
	ld ixl,e
	ld ixh,d
	ret

; ehl = address
; iy = this
MappedReader_SetPosition_IY:
	push ix
	ld a,e
	call MappedReader_GetBuffer_IY
	ld e,a
	call MappedBuffer_IsValidPosition
	jp nc,MappedReader_ThrowAddressOutOfBounds
	ld a,h
	and 3FH
	or 80H
	ld (iy + MappedReader.position),l
	ld (iy + MappedReader.position + 1),a
	ld a,h
	rla
	rl e
	rla
	rl e
	ld (iy + MappedReader.positionSegmentIndex),e
	ld a,e
	ld h,MappedReader_BASE_ADDRESS >> 8
	call MappedBuffer_SelectSegment
	pop ix
	ret

; iy = this
; dehl <- address
MappedReader_GetPosition_IY:
	ld l,(iy + MappedReader.position)
	ld h,(iy + MappedReader.position + 1)
	ld a,(iy + MappedReader.positionSegmentIndex)
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
; iy = this
MappedReader_Skip_IY:
	ld a,d
	and a
	jp nz,MappedReader_ThrowAddressOutOfBounds
	push de
	push hl
	call MappedReader_GetPosition_IY
	pop bc
	add hl,bc
	pop bc
	ex de,hl
	adc hl,bc
	ex de,hl
	jp c,MappedReader_ThrowAddressOutOfBounds
	call MappedReader_SetPosition_IY
	ret

; bc = nr of bytes to skip
; iy = this
; Modifies: af, bc, de, hl
MappedReader_SkipBC_IY:
	call MappedReader_GetPosition_IY
	add hl,bc
	ex de,hl
	ld bc,0
	adc hl,bc
	ex de,hl
	jp c,MappedReader_ThrowAddressOutOfBounds
	call MappedReader_SetPosition_IY
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
	call MappedReader_SelectNextSegment_IY
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

; de = destination address
; bc = bytes count
; iy = this
MappedReader_ReadBlock_IY: PROC
Loop:
	push bc
	push de
	call MappedReader_Read_IY
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
; ix = processing callback (hl = source, bc = bytes)
; iy = this
MappedReader_ReadAndProcessBlock_IY: PROC
Loop:
	push hl
	ld hl,MappedReader_BASE_ADDRESS + 4000H
	ld c,(iy + MappedReader.position)
	ld b,(iy + MappedReader.position + 1)
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
; bc = bytes, ix = processing callback, iy = this
Process:
	ld l,(iy + MappedReader.position)
	ld h,(iy + MappedReader.position + 1)
	push bc
	call CallIX
	pop bc
	call MappedReader_SkipBC_IY
	ret
CallIX:
	jp ix
	ENDP

; iy = this
MappedReader_SelectNextSegment_IY:
	ld a,(iy + MappedReader.positionSegmentIndex)
	inc a
	ld (iy + MappedReader.positionSegmentIndex),a
	push ix
	push de
	call MappedReader_GetBuffer_IY
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
