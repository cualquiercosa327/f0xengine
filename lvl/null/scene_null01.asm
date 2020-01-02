sceneNull01_Init: {
	
	lda.b #$80
	sta.w REG_INIDISP
	
	initOAM()
	
	jsr f_initActors
	
	LoadPAL(bgScrollP, 0, 52, 0)
	LoadPAL(sprTSTAvaP, 128, $17, 0)
	LoadPAL(sprNFontP, 144, $000A, 0)
	
	LoadVRAM(sprNFontT, $0000, $0690, 0)
	LoadVRAM(bgScrollT, $4000, bgScrollT.size, 0)
	LoadVRAM(bgScrollM, $2000, bgScrollM.size, 1)
	
	LoadVRAM(sprTSTAvaT, $0500, sprTSTAvaT.size, 0)
	
	lda.b #%00001011
	sta.w REG_BGMODE

	lda.b #%00010001  // AAAAAASS: S = BG Map Size, A = BG Map Address
	sta.w REG_BG1SC   // $2108: BG1 32x32, BG1 Map Address = $3F (VRAM Address / $400)
	lda.b #%00000010  // BBBBAAAA: A = BG1 Tile Address, B = BG2 Tile Address
	sta.w REG_BG12NBA // $210B: BG1 Tile Address = $0 (VRAM Address / $1000)

	lda.b #%00010001
	sta.w REG_TM 

	stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos Low Byte
	stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos High Byte
	stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Scroll Pos Low Byte
	stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Pos High Byte

	lda.b #%00000000 // 8x8 -> 16x16
	sta.w REG_OBSEL
	
	//; Initalize actors
	jsr f_initActors
	
	ldx.w #sceneNull01_Update
	stx.w scenePtr
	
	ldx.w #numFontActor
	ldy.w #$0034
	sty.w stackActX
	ldy.w #$00F0
	sty.w stackActY
	stx.w sprCallback
	lda.b #$02
	sta.w stackActID
	FActor.createActor()
	
	ldx.w #numFontActor
	ldy.w #$0046
	sty.w stackActX
	ldy.w #$00F0
	sty.w stackActY
	stx.w sprCallback
	lda.b #$01
	sta.w stackActID
	FActor.createActor()
	
	ldx.w #avatarActor
	ldy.w #$0020
	sty.w stackActX
	ldy.w #$00C9
	sty.w stackActY
	stx.w sprCallback
	stz.w stackActID
	FActor.createActor()
	
	lda.b #$F1
	sta.w $60
	sta.w REG_MOSAIC
	stz.w $61
	
	FadeIN()
	
	rts

}


sceneNull01_Update: {

	
	jsr mosaicIntro
	jsr sceneNull01_UpdateBG

	rts

}

sceneNull01_UpdateBG: {

	lda.b $50
	sta.w REG_BG1HOFS
	lda.b $51
	sta.w REG_BG1HOFS
	
	lda.b $53
	cmp #$07
	beq +
	phb
	rep #$30
	lda.w $0050
	and.w #$0007
	sep #$20
	sta.b $53
	plb
	
	jsr sceneNull01_checkVRAMInc
	
	+
	rts

}

sceneNull01_checkVRAMInc: {

	lda.b $53
	cmp #$07
	beq +
	rts
	+
	rts
}

mosaicIntro: {
	
	lda.b $60
	cmp #$01
	beq ++
	
	lda.w $61
	cmp #$03
	bmi +
	
	lda.w $60
	and #$F0
	lsr #$04
	dec
	asl #$04
	ora #$01
	sta.w REG_MOSAIC
	sta.w $60
	stz.w $61
	rts
	
	+
	inc $61
	rts
	
	+
	rts

}