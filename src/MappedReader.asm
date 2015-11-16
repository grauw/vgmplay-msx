;
; Buffers an entire file in memory.
;
MappedReader: MACRO
	BASE_ADDRESS: equ 8000H
	this:
	end:
		dd 0
	positionSegmentIndex:
		db 0
	lastSegment:
		db 0
	; a <- value
	; Modifies: af, hl
	ReadByte:
		ld hl,BASE_ADDRESS
	position: equ $ - 2
		ld a,(hl)
		inc l
		ld (position),hl
		ret nz
		inc h
		ld (position),hl
		bit 6,h
		ret z
		ld h,BASE_ADDRESS >> 8
		ld (position),hl
		push af
		push ix
		ld ix,this
		call MappedReader_SelectNextSegment
		pop ix
		pop af
		ret
	segments:
		ds 256 * 2
	size:
	ENDM

; hl = filename
; ix = this
; ix <- this
MappedReader_Constructor:
	call MappedReader_LoadFile
	ret

; ehl = address
; ix = this
MappedReader_SetPosition:
	call MappedReader_IsValidAddress
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
	call MappedReader_SelectSegment
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

; Reads a byte from the current position.
; No bounds checks are performed.
;
; ix = this
; a <- value
; Modifies: af, hl
MappedReader_ReadByte:
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
	call MappedReader_SelectSegment
	pop af
	ret

; de = destination address
; bc = bytes count
; ix = this
MappedReader_ReadBlock: PROC
Loop:
	push bc
	push de
	call MappedReader_ReadByte
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
	ld hl,MappedReader.BASE_ADDRESS + 4000H
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

; ehl = address
; ix = this
; f <- nc: address points past the end
; Modifies: af
MappedReader_IsValidAddress:
	ld a,e
	cp (ix + MappedReader.end + 2)
	ret c
	ld a,h
	cp (ix + MappedReader.end + 1)
	ret c
	ld a,l
	cp (ix + MappedReader.end)
	ret

; a = segment index
; ix = this
; a <- segment
; Modifies: af
MappedReader_SelectSegment:
	push bc
	push de
	push hl
	push ix
	ld e,a
	ld d,0
	add ix,de
	add ix,de
	ld a,(ix + MappedReader.segments + 1)
	ld h,MappedReader.BASE_ADDRESS >> 8
	call Memory_SetSlot
	ld a,(ix + MappedReader.segments)
	call Mapper_instance.PutP2
	pop ix
	pop hl
	pop de
	pop bc
	ret

; ix = this
MappedReader_SelectNextSegment:
	ld a,(ix + MappedReader.positionSegmentIndex)
	inc a
	ld (ix + MappedReader.positionSegmentIndex),a
	call MappedReader_SelectSegment
	ret

; ix = this
; a <- segment number
; b <- slot id
MappedReader_AllocateSegment:
	ld a,(Mapper_instance.primaryMapperSlot)
	and 10001111B
	or 00100000B  ; allocate primary slot, or another
	ld b,a
	ld a,0
	call Mapper_instance.Allocate
	ld hl,MappedReader_outOfMemoryError
	jp c,Application_TerminateWithError
	ret

; ix = this
; a = segment number
; b = slot id
; a <- new segment index
; Modifies: de, hl
MappedReader_AddSegment:
	ld e,(ix + MappedReader.lastSegment)
	ld d,0
	push de
	push ix
	add ix,de
	add ix,de
	ld (ix + MappedReader.segments),a
	ld (ix + MappedReader.segments + 1),b
	pop ix
	inc de
	ld (ix + MappedReader.lastSegment),e
	bit 0,d
	ld hl,MappedReader_outOfMemoryError
	jp nz,Application_TerminateWithError
	pop de
	ld a,e
	ret

; hl = filename
; ix = this
; ix <- this
MappedReader_LoadFile:
	ex de,hl
	ld a,00000001B  ; read-only
	ld c,_OPEN
	call BDOS
	call Application_CheckDOSError
	push bc
	call MappedReader_LoadAllData
	pop bc
	ld c,_CLOSE
	call BDOS
	call Application_CheckDOSError
	ld de,0
	ld hl,0
	call MappedReader_SetPosition
	ret

; b = file handle
; ix = this
MappedReader_LoadAllData: PROC
	ld c,0
	ld hl,0
	push hl
	push bc
	ld a,(Mapper_instance.primaryMapperSlot)
	ld b,a
	call Mapper_instance.GetP2
	jp FirstSegment
Loop:
	push hl
	push bc
	call MappedReader_AllocateSegment
FirstSegment:
	call MappedReader_AddSegment
	pop bc
	push bc
	call MappedReader_LoadSegment
	ex de,hl
	pop bc
	pop hl
	add hl,de
	jr nc,NoCarry
	inc c
NoCarry:
	ld a,d
	cp 40H
	jp z,Loop
Done:
	ld (ix + MappedReader.end),l
	ld (ix + MappedReader.end + 1),h
	ld (ix + MappedReader.end + 2),c
	ret
	ENDP

; a = segment index
; b = file handle
; hl <- bytes loaded
MappedReader_LoadSegment: PROC
	push bc
	call MappedReader_SelectSegment
	ld hl,MappedReader.BASE_ADDRESS
	call Memory_GetSlot
	ld b,a
	ld a,(Mapper_instance.primaryMapperSlot)
	cp b
	pop bc
	jr nz,NonPrimary
	ld de,MappedReader.BASE_ADDRESS
	ld hl,4000H
	ld c,_READ
	call BDOS
	cp .EOF
	call nz,Application_CheckDOSError
	ret
NonPrimary:  ; Can not load directly into nonprimary mapper slots
	push bc
	ld de,SCRATCH
	ld hl,2000H
	ld c,_READ
	call BDOS
	cp .EOF
	call nz,Application_CheckDOSError
	ld a,l
	or h
	jr z,SkipLDIR1
	push hl
	ld c,l
	ld b,h
	ld hl,SCRATCH
	ld de,MappedReader.BASE_ADDRESS
	call System_FastLDIR
	pop hl
SkipLDIR1:
	pop bc
	ld a,h
	cp 20H
	ret nz
	ld de,SCRATCH
	ld hl,2000H
	ld c,_READ
	call BDOS
	cp .EOF
	call nz,Application_CheckDOSError
	ld a,l
	or h
	jr z,SkipLDIR2
	push hl
	ld c,l
	ld b,h
	ld hl,SCRATCH
	ld de,MappedReader.BASE_ADDRESS + 2000H
	call System_FastLDIR
	pop hl
SkipLDIR2:
	ld de,2000H
	add hl,de
	ret
	ENDP

MappedReader_ThrowAddressOutOfBounds:
	ld hl,MappedReader_addressOutOfBoundsError
	call System_ThrowExceptionWithMessage
	ret

;
	SECTION RAM

MappedReader_instance: MappedReader

	ENDS

MappedReader_outOfMemoryError:
	db "Not enough memory.",13,10,0

MappedReader_addressOutOfBoundsError:
	db "Address out of bounds.",13,10,0
