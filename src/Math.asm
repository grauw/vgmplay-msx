; Binary logarithm
; b = antilogarithm exponent
; hl = antilogarithm significand (precision: 11 bits)
; b <- logarithm characteristic
; hl <- logarithm mantissa (precision: 16 bits)
Math_Log2: PROC
	and a
	adc hl,hl
	jr c,Lookup
	jr z,NegativeInfinity
LeadingZerosLoop:
	dec b
	add hl,hl
	jr nc,LeadingZerosLoop
Lookup:
	ld a,l
	srl h
	rra
	sla h
	ld l,h
	ld h,Math_log2Table >> 8
	ld e,(hl)
	inc l
	ld d,(hl)
	inc l
	ld c,(hl)
	inc l
	ld h,(hl)
	ld l,c
	sbc hl,de
	ex de,hl
Interpolate:
	srl d
	rr e
	add a,a
	jr nc,NoAddHalf
	add hl,de
NoAddHalf:
	srl d
	rr e
	add a,a
	jr nc,NoAddQuarter
	add hl,de
NoAddQuarter:
	add a,a
	ret nc
	srl d
	rr e
	add hl,de
	ret
NegativeInfinity:
	ld b,-16
	ret
	ENDP

; hl = multiplicand
; bc = multiplier
; dehl <- product
; Modifies: af
Math_Multiply16x16: PROC
	ex de,hl
	ld hl,0
	ld a,16
Loop:
	add hl,hl
	rl e
	rl d
	jr nc,NoAdd
	add hl,bc
	jp nc,NoAdd
	inc de
NoAdd:
	dec a
	jr nz,Loop
	ret
	ENDP

; Log mantissa table in 128 steps
; JS: Array.from({length: 129}, (v, i) => Math.round(65536 * Math.log((i / 128) + 1) / Math.log(2)))
	ALIGN 100H
Math_log2Table:
	dw     0,   736,  1466,  2190,  2909,  3623,  4331,  5034
	dw  5732,  6425,  7112,  7795,  8473,  9146,  9814, 10477
	dw 11136, 11791, 12440, 13086, 13727, 14363, 14996, 15624
	dw 16248, 16868, 17484, 18096, 18704, 19308, 19909, 20505
	dw 21098, 21687, 22272, 22854, 23433, 24007, 24579, 25146
	dw 25711, 26272, 26830, 27384, 27936, 28484, 29029, 29571
	dw 30109, 30645, 31178, 31707, 32234, 32758, 33279, 33797
	dw 34312, 34825, 35334, 35841, 36346, 36847, 37346, 37842
	dw 38336, 38827, 39316, 39802, 40286, 40767, 41246, 41722
	dw 42196, 42667, 43137, 43603, 44068, 44530, 44990, 45448
	dw 45904, 46357, 46809, 47258, 47705, 48150, 48593, 49034
	dw 49472, 49909, 50344, 50776, 51207, 51636, 52063, 52488
	dw 52911, 53332, 53751, 54169, 54584, 54998, 55410, 55820
	dw 56229, 56635, 57040, 57443, 57845, 58245, 58643, 59039
	dw 59434, 59827, 60219, 60609, 60997, 61384, 61769, 62152
	dw 62534, 62915, 63294, 63671, 64047, 64421, 64794, 65166
