
//; RNC decompression
//; based on Robert Trevellyan's source

constant RNC_IN($70)
constant RNC_OUT($74)
constant RNC_SPOS($76)
constant RNC_SLEN($79)

constant RNC_OUT_BUFFER($7F0000)

macro reload() {

	lda [RNC_IN],y
	iny
	rol
}

macro getBit() {

	asl
}

macro getRaw() {
	
	lda [RNC_IN],y
	sta (RNC_OUT)
	iny
	inc $74
	bne {#}noRNC_INc
	inc RNC_OUT+1

	{#}noRNC_INc:

}

//; MUST BE ON STACK:
//; low 16-bit address of compressed data
//; high 16-bit address of compressed data
//; low 16-bit address of RNC_OUTput
//; high 16-bit address of RNC_OUTput

//; $70 -> 24-bit address to compressed data
//; $74 -> 16-bit address to RNC_OUTput
//; 
rncDecompress:

	rep #$30
	and.w #$00FF
	
	phx
	pha
	pea RNC_OUT_BUFFER & $FFFF
	pea RNC_OUT_BUFFER >> 16
	
	jsl rncUnpack
	
	pla
	pla
	pla
	pla
	
	sep #$20
	
	rtl

rncUnpack:
	
	lda $06,s			//; read low word of RNC_OUTput address
    sta.b RNC_OUT
	
    lda $08,s			//; read high word of packed file
    sta.b RNC_IN+2
	
	lda $0A,s 			//; read low word of packed file
    sta.b RNC_IN
	
	sep #$21			//; 8-bit accumulator, set carry flag
	lda $04,s			//; read high word of RNC_OUTput address
	
	phb                 //; save current data bank
	pha
	plb                 //; make RNC_OUTput buffer default data bank
	
	stz.b RNC_SPOS+2
	stz.b RNC_SLEN+1
	
	ldx.w #0
	ldy.w #18			//; skip 18 byte pack header
	
	reload()
	getBit()
	
	jmp xLoop
	
fetch_0:

	reload()
	bra back_0

rraw:
	
	ldx.w #4
	
x4Bits:
	
	getBit()
	beq fetch_0
	
back_0:

	rol RNC_SPOS+1
	dex
	bne x4Bits
	ldx.w RNC_SPOS+1
	inx
	inx
	inx
	pha
	rep #$20				//; 16-bit accumulator
	tya
	adc RNC_IN
	sta RNC_IN
	ldy.w #0

rawlP:

	lda [RNC_IN],y
	sta (RNC_OUT),y
	iny
	iny
	lda [RNC_IN],y
	sta (RNC_OUT),y
	iny
	iny
	dex
	bne rawlP
	tya
	adc RNC_OUT
	sta RNC_OUT
	sep #$20				//; 8-bit accumulator
	pla
	jmp xLoop
	
fetch_1:
	reload()
	bra back_1
fetch_2:
	reload()
	bra back_2
fetch_3:
	reload()
	bra back_3
fetch_4:
	reload()
	bra back_4
fetch_5:
	reload()
	bra back_5
fetch_6:
	reload()
	bra back_6
fetch_7:
	reload()
	bra back_7

getLen:
	reload()
	beq fetch_1
	
back_1:
	rol RNC_SLEN
	getBit()
	beq fetch_2
back_2:
	bcc copy
	getBit()
	beq fetch_3
back_3:
	dec RNC_SLEN
	rol RNC_SLEN
	ldx.b RNC_SLEN
	cpx.w #9
	beq +
	bra ++
	
	+
	jmp rraw
	
	+
	ldx.w #0
	
	
copy:
	getBit()
	beq fetch_4
back_4:
	bcc byteDisp
	getBit()
	beq fetch_5
back_5:
	rol RNC_SPOS+1
	getBit()
	beq fetch_6
back_6:
	bcc skip
	jmp bigDisp
skip:
	cpx.b RNC_SPOS+1
	bne byteDisp
	inc RNC_SPOS+1
another:
	getBit()
	beq fetch_7
back_7:
	rol RNC_SPOS+1
byteDisp:
	pha
	lda [RNC_IN],y
	sta RNC_SPOS
	iny
	phy
	rep #$21             //; 16-bit accumulator, clear carry
	lda RNC_SPOS
	pha
	lda RNC_OUT
	sbc RNC_SPOS
	sta RNC_SPOS
	ldy.w #0
	lsr $79
	ldx.b RNC_SLEN
	pla
	bne byteDisp3
	sep #$20             //; 8-bit accumulator
	lda (RNC_SPOS),y
	xba
	lda (RNC_SPOS),y
	rep #$20             //; 16-bit accumulator
byteDisp2:
	sta (RNC_OUT),y
	iny
	iny
	dex
	bne byteDisp2
	bra byteDisp4
byteDisp3:
	lda (RNC_SPOS),y
	sta (RNC_OUT),y
	iny
	iny
	dex
	bne byteDisp3
byteDisp4:
	sep #$20             //; 8-bit accumulator
	bcc byteDisp5
	lda (RNC_SPOS),y
	sta (RNC_OUT),y
byteDisp5:
	tya
	adc RNC_OUT
	sta RNC_OUT
	bcc skip2
	inc RNC_OUT+1
skip2:
	ply
	pla
	bra xLoop
	
getBits:
	reload()
	bcs rncString
xByte:
	xba
	getRaw()
	xba
xLoop:
	getBit()
	bcs checkZ
	xba
	getRaw()
	xba
	getBit()
	bcc xByte
checkZ:
	beq getBits
	
rncString:
	stz $77
	stz $79
	inc $79
	inc $79
	getBit()
	beq fetch_8
back_8:
	bcs smallS
	jmp getLen
smallS:
	getBit()
	beq fetch_9
back_9:
	bcs skip3
	jmp byteDisp
skip3:
	inc $79
	getBit()
	beq fetch_10
back_10:
	bcs skip4
	jmp copy
skip4:
	xba
	lda [RNC_IN],y
	sta RNC_SLEN
	xba
	iny
	cpx RNC_SLEN
	beq overNout
	xba
	lda RNC_SLEN
	clc
	adc.b #8
	sta RNC_SLEN
	xba
	jmp copy
bigDisp:
	getBit()
	beq fetch_11
back_11:
	xba
	lda RNC_SPOS+1
	rol
	ora.b #4
	sta RNC_SPOS+1
	xba
	getBit()
	beq fetch_12
back_12:
	bcc skip5
	jmp byteDisp
skip5:
	jmp another
fetch_8:
	reload()
	bra back_8
fetch_9:
	reload()
	bra back_9
fetch_10:
	reload()
	bra back_10
fetch_11:
	reload()
	bra back_11
fetch_12:
	reload()
	bra back_12
overNout:
	getBit()
	bne check4End
	reload()
check4End:
	bcc skip6
	jmp xLoop
skip6:
	plb                 //; restore old data bank
	rep #$30             //; 16-bit AXY
	rtl