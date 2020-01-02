

macro updateOAM() {

	stz.w REG_OAMADDL //; OAM low address
	stz.w REG_OAMADDH //; OAM high address
	ldy.w #$0400 //; DMAP0 = default, DMA I/O Address (BBAD0) = OAM
	sty.w $4300
	ldy.w #$0400 //; DMA low address, DMA high address
	sty.w $4302
	ldy.w #$0220 //; DMA byte counter/Amount of bytes (554 bytes)
	sty.w $4305
	lda.b #$7E //;  DMA bank (Bank 0)
	sta.w $4304
	lda.b #$01
	sta.w $420B //; Enable and start DMA (channel 0)

}


macro setSprite(INDEX, pX, pY, TILE, FLAGS) {
	
	pha
	phy
	
	lda.b {INDEX}
	ldy.w #$0000
	asl
	asl
	sta.w sprCallback
	rep #$30
	lda.w #$0400
	sep #$20
	adc sprCallback
	rep #$30
	sta.w sprCallback
	sep #$20
	lda.b {pX}
	sta [sprCallback],y
	lda.b {pY}
	iny
	sta [sprCallback],y
	lda.b #{TILE}
	iny
	sta [sprCallback],y
	lda.b #{FLAGS}
	iny
	sta [sprCallback],y
	stz.w sprCallback
	stz.w sprCallback+1
	
	setSpriteHigh({INDEX})
	
	ply
	pla
}

macro setSpriteBig(INDEX, pX, pY, TILE, FLAGS) {
	
	phy
	pha
	lda.b {INDEX}
	asl
	asl
	sta.w sprCallback
	rep #$30
	lda.w #$0400
	adc.w sprCallback
	sta.w sprCallback
	sep #$20
	lda.b #{pX}
	sta [sprCallback],y
	lda.b #{pY}
	iny
	sta [sprCallback],y
	lda.b #{TILE}
	iny
	sta [sprCallback],y
	lda.b #{FLAGS}
	iny
	sta [sprCallback],y
	stz.w sprCallback
	stz.w sprCallback+1
	
	setSpriteHighBig({INDEX})
	
	ply
	pla
}

macro removeSprite(INDEX) {
	
	lda.b {INDEX}
	asl
	asl
	sta.w sprCallback
	rep #$30
	lda.w #$0400
	sep #$20
	adc sprCallback
	sta.w sprCallback
	lda.b #$01
	ldy.w #$0000
	sta [sprCallback],y
	iny
	sta [sprCallback],y
	iny
	sta [sprCallback],y
	iny
	sta [sprCallback],y
	stz.w sprCallback
	stz.w sprCallback+1
	
	lda.b {INDEX}
	lsr
	lsr
	tay
	lda.b {INDEX}
	and #$03
	
	jsr rH1
	
}

macro moveSprite(OAM, X, Y) {
	pha
	rep #$30
	lda.w {OAM}
	adc #{X}
	sta.w {OAM}
	lda.w {OAM}+1
	adc #{Y}
	sta.w {OAM}+1
	sep #$20
	pla
}

macro setSpriteHigh(INDEX) {
	
	lda.b {INDEX}
	lsr
	lsr
	tay
	lda.b {INDEX}
	and #$03
	
	jsr calcHigh1
}

macro setSpriteHighBig(INDEX) {
	
	lda.b {INDEX}
	lsr
	lsr
	tay
	lda.b {INDEX}
	and #$03
	
	jsr calcHigh1B
}