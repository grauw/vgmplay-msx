;
; Buffers an entire file in memory
;
MappedBufferLoader_BASE_ADDRESS: equ 8000H
MappedBufferLoader_PAGE_SIZE: equ 4000H

MappedBufferLoader: MACRO
	buffer:
		dw 0
	size:
	ENDM

; de = file path
; hl = mapped buffer
; ix = this
; ix <- this
MappedBufferLoader_Construct:
	ld (ix + MappedBufferLoader.buffer),l
	ld (ix + MappedBufferLoader.buffer + 1),h
	call MappedBufferLoader_LoadFile
	ret

; ix = this
; de <- buffer
; ix <- buffer
MappedBufferLoader_GetBuffer:
	ld e,(ix + MappedBufferLoader.buffer)
	ld d,(ix + MappedBufferLoader.buffer + 1)
	ld ixl,e
	ld ixh,d
	ret

; de = file path
; ix = this
; ix <- this
MappedBufferLoader_LoadFile:
	ld a,00000001B  ; read-only
	call DOS_OpenFileHandle
	call Application_CheckDOSError
	push bc
	call MappedBufferLoader_LoadAllData
	pop bc
	call DOS_CloseFileHandle
	call Application_CheckDOSError
	ret

; b = file handle
; ix = this
MappedBufferLoader_LoadAllData: PROC
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
	push ix
	call MappedBufferLoader_GetBuffer
	call MappedBuffer_AllocateSegment
	pop ix
FirstSegment:
	push ix
	call MappedBufferLoader_GetBuffer
	call MappedBuffer_AddSegment
	pop ix
	pop bc
	push bc
	call MappedBufferLoader_LoadSegment
	push hl
	call DOS_ConsoleStatus  ; allow ctrl-c
	pop de
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
	push ix
	call MappedBufferLoader_GetBuffer
	ld e,c
	call MappedBuffer_SetSize
	pop ix
	ret
	ENDP

; a = segment index
; b = file handle
; hl <- bytes loaded
MappedBufferLoader_LoadSegment:
	push bc
	push ix
	call MappedBufferLoader_GetBuffer
	ld h,MappedBufferLoader_BASE_ADDRESS >> 8
	call MappedBuffer_SelectSegment
	pop ix
	ld hl,MappedBufferLoader_BASE_ADDRESS
	call Memory_GetSlot
	ld b,a
	ld a,(Mapper_instance.primaryMapperSlot)
	cp b
	pop bc
	jr nz,MappedBufferLoader_LoadViaBuffer
	ld de,MappedBufferLoader_BASE_ADDRESS
	ld hl,4000H
	call DOS_ReadFromFileHandle
	cp .EOF
	call nz,Application_CheckDOSError
	ret

; Load data to BASE_ADDRESS via a buffer in the primary mapper.
; Because DOS2 can not load directly into nonprimary mapper slots.
; b = file handle
; hl <- bytes loaded
MappedBufferLoader_LoadViaBuffer: PROC
	ld hl,MappedBufferLoader_PAGE_SIZE
	ld de,MappedBufferLoader_BASE_ADDRESS
Loop:
	push bc
	push hl
	push de
	ld de,READBUFFER_SIZE
	and a
	sbc hl,de
	jr c,LessThanBufferSize
	ex de,hl
	jp Continue
LessThanBufferSize:
	add hl,de
Continue:
	ld de,READBUFFER
	call DOS_ReadFromFileHandle
	ld c,l
	ld b,h
	pop de
	pop hl
	cp .EOF
	jr z,EndOfFile
	call nz,Application_CheckDOSError
	push bc
	push hl
	ld hl,READBUFFER
	call System_FastLDIR
	pop hl
	pop bc
	and a
	sbc hl,bc
	call c,System_ThrowException
	pop bc
	jp nz,Loop
Done:
	ex de,hl
	ld de,MappedBufferLoader_BASE_ADDRESS
	and a
	sbc hl,de
	ret
EndOfFile:
	pop bc
	jp Done
	ENDP
