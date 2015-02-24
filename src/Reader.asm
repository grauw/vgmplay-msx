;
; Buffers an entire file in memory.
;
Reader: MACRO
	BASE_ADDRESS: equ 8000H
	end:
		dd 0
	position:
		dd 0
	lastSegment:
		db 0
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
	ld (ix + Reader.position),l
	ld (ix + Reader.position + 1),h
	ld (ix + Reader.position + 2),e
	ret

; ix = this
; a <- value
; Modifies: af, bc, de, hl
Reader_ReadByte:
	ld l,(ix + Reader.position)
	ld h,(ix + Reader.position + 1)
	ld e,(ix + Reader.position + 2)
	call Reader_ReadByteAt
	ld bc,1
	add hl,bc
	ld (ix + Reader.position),l
	ld (ix + Reader.position + 1),h
	ret nc
	inc e
	ld (ix + Reader.position + 2),e
	ret

; ehl = address
; ix = this
; Modifies: af
Reader_ReadByteAt: PROC
	call Reader_IsValidAddress
	jr nc,AddressOutOfBounds
	call Reader_GetSegment
	call Mapper_instance.Read
	ret
AddressOutOfBounds:
	ld hl,Reader_addressOutOfBoundsError
	call System_ThrowExceptionWithMessage
	ret
	ENDP

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
	ret c
	ret

; ehl = address
; ix = this
; a <- segment
Reader_GetSegment:
	push de
	ld a,h
	rla
	rl e
	rla
	rl e
	ld d,0
	push ix
	add ix,de
	ld a,(ix + Reader.segments)
	pop ix
	pop de
	ret

; ix = this
; a <- segment number
Reader_AllocateSegment:
	ld a,0
	ld b,0
	call Mapper_instance.Allocate
	ld hl,Reader_outOfMemoryError
	call c,VGMPlay_TerminateWithError
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
Loop:
	push hl
	push bc
	call Reader_AllocateSegment
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

;
	SECTION RAM

Reader_instance: Reader

Reader_outOfMemoryError:
	db "Not enough memory.",13,10,0

Reader_addressOutOfBoundsError:
	db "Address out of bounds.",13,10,0

	ENDS
