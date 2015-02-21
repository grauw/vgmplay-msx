;
; VGM file data reader
;
DataReader: MACRO
	start:
		dw DATA
	end:
		dw DATA + 4000H
	current:
		dw DATA
	size:
	ENDM

; hl = data start
; bc = data size
; ix = this
; ix <- this
DataReader_Constructor:
	ld (ix + DataReader.start),l
	ld (ix + DataReader.start + 1),h
	ld (ix + DataReader.current),l
	ld (ix + DataReader.current + 1),h
	add hl,bc
	ld (ix + DataReader.end),l
	ld (ix + DataReader.end + 1),h
	ret

; ix = this
; a <- value
DataReader_ReadByte: PROC
	ld e,(ix + DataReader.current)
	ld d,(ix + DataReader.current + 1)
	ld l,(ix + DataReader.end)
	ld h,(ix + DataReader.end + 1)
	scf
	sbc hl,de
	jr c,EndOfData
	ld a,(de)
	inc de
	ld (ix + DataReader.current),e
	ld (ix + DataReader.current + 1),d
	ret
EndOfData:
	ld hl,DataReader_endOfDataError
	call VGMPlay_ThrowWithMessage
	ret
	ENDP

;
	SECTION RAM

DataReader_instance: DataReader

DataReader_endOfDataError:
	db "End of data.",13,10,0

	ENDS
