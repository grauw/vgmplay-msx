;
; GD3 tag processing
;

; dehl = GD3 offset
; ix = reader
GD3_ShowTagInfoEnglish:
	call Reader_SetPosition
	call GD3_CheckVersion
	ret nz
	ld hl,GD3_name
	call GD3_PrintTag
	call GD3_SkipTag
	ld hl,GD3_game
	call GD3_PrintTag
	call GD3_SkipTag
	ld hl,GD3_system
	call GD3_PrintTag
	call GD3_SkipTag
	ld hl,GD3_author
	call GD3_PrintTag
	call GD3_SkipTag
	ld hl,GD3_date
	call GD3_PrintTag
	ld hl,GD3_converter
	call GD3_PrintTag
	ld hl,GD3_notes
	call GD3_PrintTag
	ret

; ix = reader
; f <- z: tag recognised
GD3_CheckVersion:
	call Reader_ReadByte
	cp "G"
	ret nz
	call Reader_ReadByte
	cp "d"
	ret nz
	call Reader_ReadByte
	cp "3"
	ret nz
	call Reader_ReadByte
	cp " "
	ret nz
	call Reader_ReadByte
	cp 0
	ret nz
	call Reader_ReadByte
	cp 1
	ret nz
	call Reader_ReadByte
	cp 0
	ret nz
	call Reader_ReadByte
	cp 0
	call Reader_ReadByte
	call Reader_ReadByte
	call Reader_ReadByte
	call Reader_ReadByte
	xor a
	ret

; hl = field name
; ix = reader
; Modifies: af, de, hl
GD3_PrintTag: PROC
	push hl
	call Reader_ReadByte
	ld e,a
	call Reader_ReadByte
	ld d,a
	pop hl
	or e
	ret z
	call System_Print
	call SkipFirst
	call System_PrintCrLf
	ret
Loop:
	call Reader_ReadByte
	ld e,a
	call Reader_ReadByte
	ld d,a
	or e
	ret z
SkipFirst:
	ld a,d
	and a
	jr nz,Unknown
	ld a,e
	cp 10
	jr z,Newline
	call System_PrintChar
	jp Loop
Unknown:
	ld a,"?"
	call System_PrintChar
	jp Loop
Newline:
	call System_PrintCrLf
	jp Loop
	ENDP

; hl = field name
; ix = reader
; Modifies: af, de, hl
GD3_SkipTag:
	call Reader_ReadByte
	ld e,a
	call Reader_ReadByte
	or e
	jp nz,GD3_SkipTag
	ret

;
GD3_name:
	db "Name: ",0

GD3_game:
	db "Game: ",0

GD3_system:
	db "System: ",0

GD3_author:
	db "Author: ",0

GD3_date:
	db "Date: ",0

GD3_converter:
	db "Converter: ",0

GD3_notes:
	db "Notes: ",0
