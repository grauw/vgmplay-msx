;
; Buffers an entire file in memory.
;
Reader: MACRO
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
		inc hl
		ld (position),hl
		bit 6,h
		ret z
		push af
		ld a,h
		and 10111111B
		ld (position + 1),a
		push ix
		ld ix,this
		call Reader_SelectNextSegment
		pop ix
		pop af
		ret
	segments:
		ds 256
	size:
	ENDM

; hl = filename
; ix = this
; ix <- this
Reader_Constructor:
	call Reader_LoadFile
	ret

; ehl = address
; ix = this
Reader_SetPosition:
	call Reader_IsValidAddress
	jp nc,Reader_ThrowAddressOutOfBounds
	ld a,h
	and 3FH
	or 80H
	ld (ix + Reader.position),l
	ld (ix + Reader.position + 1),a
	ld a,h
	rla
	rl e
	rla
	rl e
	ld (ix + Reader.positionSegmentIndex),e
	ld a,e
	call Reader_SelectSegment
	ret

; ix = this
; dehl <- address
Reader_GetPosition:
	ld l,(ix + Reader.position)
	ld h,(ix + Reader.position + 1)
	ld a,(ix + Reader.positionSegmentIndex)
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
Reader_Skip:
	ld a,d
	and a
	jp nz,Reader_ThrowAddressOutOfBounds
	push de
	push hl
	call Reader_GetPosition
	pop bc
	add hl,bc
	pop bc
	ex de,hl
	adc hl,bc
	ex de,hl
	jp c,Reader_ThrowAddressOutOfBounds
	call Reader_SetPosition
	ret

; Reads a byte from the current position.
; No bounds checks are performed.
;
; ix = this
; a <- value
; Modifies: af, hl
Reader_ReadByte:
	ld l,(ix + Reader.position)
	ld h,(ix + Reader.position + 1)
	ld a,(hl)
	inc hl
	ld (ix + Reader.position),l
	ld (ix + Reader.position + 1),h
	bit 6,h
	ret z
	res 6,h
	ld (ix + Reader.position + 1),h
	push af
	ld a,(ix + Reader.positionSegmentIndex)
	inc a
	ld (ix + Reader.positionSegmentIndex),a
	call Reader_SelectSegment
	pop af
	ret

; de = destination address
; bc = bytes count
; ix = this
Reader_ReadBlock: PROC
Loop:
	push bc
	push de
	call Reader_ReadByte
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

; ehl = address
; ix = this
; f <- nc: address points past the end
; Modifies: af
Reader_IsValidAddress:
	ld a,e
	cp (ix + Reader.end + 2)
	ret c
	ld a,h
	cp (ix + Reader.end + 1)
	ret c
	ld a,l
	cp (ix + Reader.end)
	ret

; a = segment index
; ix = this
; a <- segment
; Modifies: af
Reader_SelectSegment:
	push de
	push ix
	ld e,a
	ld d,0
	add ix,de
	ld a,(ix + Reader.segments)
	call Mapper_instance.PutP2
	pop ix
	pop de
	ret

; ix = this
Reader_SelectNextSegment:
	ld a,(ix + Reader.positionSegmentIndex)
	inc a
	ld (ix + Reader.positionSegmentIndex),a
	call Reader_SelectSegment
	ret

; ix = this
; a <- segment number
Reader_AllocateSegment:
	ld a,0
	ld b,0
	call Mapper_instance.Allocate
	ld hl,Reader_outOfMemoryError
	call c,VGMPlay_TerminateWithError
	ret

; ix = this
; a = segment number
; a <- segment number
Reader_AddSegment:
	ld e,(ix + Reader.lastSegment)
	ld d,0
	push ix
	add ix,de
	ld (ix + Reader.segments),a
	pop ix
	inc de
	ld (ix + Reader.lastSegment),e
	bit 0,d
	ld hl,Reader_outOfMemoryError
	call nz,VGMPlay_TerminateWithError
	ret

; hl = filename
; ix = this
; ix <- this
Reader_LoadFile:
	call Mapper_instance.GetP2
	push af
	ex de,hl
	ld a,00000001B  ; read-only
	ld c,_OPEN
	call BDOS
	call VGMPlay_CheckDOSError
	push bc
	call Reader_ReadAllData
	pop bc
	ld c,_CLOSE
	call BDOS
	call VGMPlay_CheckDOSError
	pop af
	call Mapper_instance.PutP2
	ret

; b = file handle
; ix = this
Reader_ReadAllData: PROC
	ld c,0
	ld hl,0
	push hl
	push bc
	call Mapper_instance.GetP2
	jp FirstSegment
Loop:
	push hl
	push bc
	call Reader_AllocateSegment
FirstSegment:
	call Reader_AddSegment
	call Mapper_instance.PutP2
	pop bc
	push bc
	ld de,Reader.BASE_ADDRESS
	ld hl,4000H
	ld c,_READ
	call BDOS
	cp .EOF
	call nz,VGMPlay_CheckDOSError
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
	ld (ix + Reader.end),l
	ld (ix + Reader.end + 1),h
	ld (ix + Reader.end + 2),c
	ret
	ENDP

Reader_ThrowAddressOutOfBounds:
	ld hl,Reader_addressOutOfBoundsError
	call System_ThrowExceptionWithMessage
	ret

;
	SECTION RAM

Reader_instance: Reader

Reader_outOfMemoryError:
	db "Not enough memory.",13,10,0

Reader_addressOutOfBoundsError:
	db "Address out of bounds.",13,10,0

	ENDS
