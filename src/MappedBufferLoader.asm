;
; Buffers an entire file in memory
;
MappedBufferLoader_BASE_ADDRESS: equ 8000H

MappedBufferLoader: MACRO
	buffer:
		dw MappedBuffer_instance
	size:
	ENDM

; hl = filename
; ix = this
; ix <- this
MappedBufferLoader_Construct:
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

; hl = filename
; ix = this
; ix <- this
MappedBufferLoader_LoadFile:
	ex de,hl
	ld a,00000001B  ; read-only
	ld c,_OPEN
	call BDOS
	call Application_CheckDOSError
	push bc
	call MappedBufferLoader_LoadAllData
	pop bc
	ld c,_CLOSE
	call BDOS
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
MappedBufferLoader_LoadSegment: PROC
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
	jr nz,NonPrimary
	ld de,MappedBufferLoader_BASE_ADDRESS
	ld hl,4000H
	ld c,_READ
	call BDOS
	cp .EOF
	call nz,Application_CheckDOSError
	ret
NonPrimary:  ; Can not load directly into nonprimary mapper slots
	push bc
	ld de,READBUFFER
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
	ld hl,READBUFFER
	ld de,MappedBufferLoader_BASE_ADDRESS
	call System_FastLDIR
	pop hl
SkipLDIR1:
	pop bc
	ld a,h
	cp 20H
	ret nz
	ld de,READBUFFER
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
	ld hl,READBUFFER
	ld de,MappedBufferLoader_BASE_ADDRESS + 2000H
	call System_FastLDIR
	pop hl
SkipLDIR2:
	ld de,2000H
	add hl,de
	ret
	ENDP
