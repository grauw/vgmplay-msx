;
; Buffers an entire file in memory.
;
DataReader: MACRO
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
DataReader_Constructor:
	call DataReader_LoadFile
	ret

; ehl = address
; ix = this
DataReader_SetPosition:
	ld (ix + DataReader.position),l
	ld (ix + DataReader.position + 1),h
	ld (ix + DataReader.position + 2),e
	ret

; ix = this
; a <- value
; Modifies: af, bc, de, hl
DataReader_ReadByte:
	ld l,(ix + DataReader.position)
	ld h,(ix + DataReader.position + 1)
	ld e,(ix + DataReader.position + 2)
	call DataReader_ReadByteAt
	ld bc,1
	add hl,bc
	ld (ix + DataReader.position),l
	ld (ix + DataReader.position + 1),h
	ret nc
	inc e
	ld (ix + DataReader.position + 2),e
	ret

; ehl = address
; ix = this
; Modifies: af
DataReader_ReadByteAt: PROC
	call DataReader_IsValidAddress
	jr nc,AddressOutOfBounds
	call DataReader_GetSegment
	call Mapper_instance.Read
	ret
AddressOutOfBounds:
	ld hl,DataReader_addressOutOfBoundsError
	call System_ThrowExceptionWithMessage
	ret
	ENDP

; de = destination address
; bc = bytes count
; ix = this
DataReader_ReadBlock: PROC
Loop:
	push bc
	push de
	call DataReader_ReadByte
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
DataReader_IsValidAddress:
	ld a,e
	cp (ix + DataReader.end + 2)
	ret c
	ld a,h
	cp (ix + DataReader.end + 1)
	ret c
	ld a,l
	cp (ix + DataReader.end)
	ret c
	ret

; ehl = address
; ix = this
; a <- segment
DataReader_GetSegment:
	push de
	ld a,h
	rla
	rl e
	rla
	rl e
	ld d,0
	push ix
	add ix,de
	ld a,(ix + DataReader.segments)
	pop ix
	pop de
	ret

; ix = this
; a <- segment number
DataReader_AllocateSegment:
	ld a,0
	ld b,0
	call Mapper_instance.Allocate
	ld hl,DataReader_outOfMemoryError
	call c,VGMPlay_TerminateWithError
	ld e,(ix + DataReader.lastSegment)
	ld d,0
	push ix
	add ix,de
	ld (ix + DataReader.segments),a
	pop ix
	inc de
	ld (ix + DataReader.lastSegment),e
	bit 0,d
	ld hl,DataReader_outOfMemoryError
	call nz,VGMPlay_TerminateWithError
	ret

; hl = filename
; ix = this
; ix <- this
DataReader_LoadFile:
	call Mapper_instance.GetP2
	push af
	ex de,hl
	ld a,00000001B  ; read-only
	ld c,_OPEN
	call BDOS
	call VGMPlay_CheckDOSError
	push bc
	call DataReader_ReadAllData
	pop bc
	ld c,_CLOSE
	call BDOS
	call VGMPlay_CheckDOSError
	pop af
	call Mapper_instance.PutP2
	ret

; b = file handle
; ix = this
DataReader_ReadAllData: PROC
	ld c,0
	ld hl,0
Loop:
	push hl
	push bc
	call DataReader_AllocateSegment
	call Mapper_instance.PutP2
	pop bc
	push bc
	ld de,DataReader.BASE_ADDRESS
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
	ld (ix + DataReader.end),l
	ld (ix + DataReader.end + 1),h
	ld (ix + DataReader.end + 2),c
	ret
	ENDP

;
	SECTION RAM

DataReader_instance: DataReader

DataReader_outOfMemoryError:
	db "Not enough memory.",13,10,0

DataReader_addressOutOfBoundsError:
	db "Address out of bounds.",13,10,0

	ENDS
