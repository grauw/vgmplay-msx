; f <- c: turbo R
Utils_IsTurboR:
	ld hl,IDBYT2
	call System_ReadBIOS
	add a,-3
	ret

; bc = offset
; ix = jump address base
Utils_JumpIXOffsetBC:
	JP_OFFSET ix,bc

; de = offset
; ix = jump address base
Utils_JumpIXOffsetDE:
	JP_OFFSET ix,de

; de = offset
; ix = this
; dehl <- value
; af <- d | e | h | l
Utils_GetDoubleWordIXOffset:
	push ix
	add ix,de
	ld l,(ix)
	ld h,(ix + 1)
	ld e,(ix + 2)
	ld d,(ix + 3)
	ld a,l
	or h
	or e
	or d
	pop ix
	ret

; de = offset
; iy = this
; dehl <- value
; af <- d | e | h | l
Utils_GetDoubleWordIYOffset:
	push iy
	add iy,de
	ld l,(iy)
	ld h,(iy + 1)
	ld e,(iy + 2)
	ld d,(iy + 3)
	ld a,l
	or h
	or e
	or d
	pop iy
	ret
