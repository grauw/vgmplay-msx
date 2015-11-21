;
; Buffers an entire file in memory.
;
MappedReader_BASE_ADDRESS: equ 8000H
MappedReader_SEGMENT_SIZE: equ 4000H

MappedReader: MACRO
	super: Reader
	buffer:
		dw MappedBuffer_instance
	positionSegmentIndex:
		db -1
	size:
	ENDM

; ix = this
; ix <- this
MappedReader_Construct:
	ld hl,MappedReader_BASE_ADDRESS
	ld bc,MappedReader_SEGMENT_SIZE
	ld de,MappedReader_Filler_IY
	call Reader_Construct
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
	ld (iy + MappedReader.super.bufferPosition),l
	ld (iy + MappedReader.super.bufferPosition + 1),a
	ld (iy + MappedReader.super.fillPending),0
	ld a,h
	rla
	rl e
	rla
	rl e
	ld (iy + MappedReader.positionSegmentIndex),e
	ld a,e
	ld h,(iy + MappedReader.super.bufferStart + 1)
	call MappedBuffer_SelectSegment
	pop ix
	ret

; iy = this
; dehl <- address
MappedReader_GetPosition_IY: PROC
	ld l,(iy + MappedReader.super.bufferPosition)
	ld h,(iy + MappedReader.super.bufferPosition + 1)
	ld a,(iy + MappedReader.positionSegmentIndex)
	bit 0,(iy + MappedReader.super.fillPending)
	call nz,FillPending
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
FillPending:
	ld l,(iy + MappedReader.super.bufferStart)
	ld h,(iy + MappedReader.super.bufferStart + 1)
	inc a
	ret
	ENDP

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
MappedReader_Read_IY: equ Reader_Read_IY

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
	call MappedReader_Read_IY
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
	call MappedReader_FillIfNeeded
Loop:
	push hl
	ld l,(iy + MappedReader.super.bufferEnd)
	ld h,(iy + MappedReader.super.bufferEnd + 1)
	ld c,(iy + MappedReader.super.bufferPosition)
	ld b,(iy + MappedReader.super.bufferPosition + 1)
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
	ld l,(iy + MappedReader.super.bufferPosition)
	ld h,(iy + MappedReader.super.bufferPosition + 1)
	push bc
	call CallIX
	pop bc
	call MappedReader_SkipBC_IY
	ret
CallIX:
	jp ix
	ENDP

; iy = this
MappedReader_FillIfNeeded:
	bit 0,(iy + MappedReader.super.fillPending)
	ret z
	inc (iy + MappedReader.super.bufferPosition)
	inc (iy + MappedReader.super.bufferPosition + 1)
	call Reader_FinishBlock_IY
	ret

; bc = byte count
; de = buffer start
; iy = this
; Modifies: af, hl
MappedReader_Filler_IY:
	push bc
	push de
	call MappedReader_SelectNextSegment_IY
	pop de
	pop bc
	ret

; iy = this
MappedReader_SelectNextSegment_IY:
	ld a,(iy + MappedReader.positionSegmentIndex)
	inc a
	ld (iy + MappedReader.positionSegmentIndex),a
	push ix
	push de
	call MappedReader_GetBuffer_IY
	ld h,(iy + MappedReader.super.bufferStart + 1)
	call MappedBuffer_SelectSegment
	pop de
	pop ix
	ret

MappedReader_ThrowAddressOutOfBounds:
	ld hl,MappedReader_addressOutOfBoundsError
	call System_ThrowExceptionWithMessage
	ret

;
MappedReader_addressOutOfBoundsError:
	db "Address out of bounds.",13,10,0
