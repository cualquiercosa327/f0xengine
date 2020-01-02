sceneNull_Init: {
	
	pha
	phx
	phy
	phb
	
	lda.b #$80
	sta.w REG_INIDISP
	
	LoadPAL(sprFontP, 128, $000A, 0)
	LoadPAL(sprNFontP, 144, $000A, 0)
	LoadVRAM(sprFontT, $0000, sprFontT.size, 0)
	LoadVRAM(sprNFontT,$0080, sprNFontT.size, 0)

	LoadPAL(bgNullP, 0, $0004, 0)
	LoadVRAM(bgNullM, $2000, bgNullM.size, 0)
	LoadVRAM(bgNullT, $4000, bgNullT.size, 0)

	lda.b #%00001011
	sta.w REG_BGMODE

	lda.b #%00010000  // AAAAAASS: S = BG Map Size, A = BG Map Address
	sta.w REG_BG1SC   // $2108: BG1 32x32, BG1 Map Address = $3F (VRAM Address / $400)
	lda.b #%00000010  // BBBBAAAA: A = BG1 Tile Address, B = BG2 Tile Address
	sta.w REG_BG12NBA // $210B: BG1 Tile Address = $0 (VRAM Address / $1000)

	lda.b #%00000001 // Enable BG1
	sta.w REG_TM // $212C: BG1 To Main Screen Designation

	lda.b #%00010001
	sta.w REG_TM 

	lda.b #%00000000 // 8x8 -> 16x16
	sta.w REG_OBSEL
	
	//; Decompress test map into second WRAM bank ($7F0000)
	//FRLE.decompress(nullCol00, nullCol00.size)

	//; Initalize actors
	FActor.initActors()

	//; Set current level pointer
	setCurrentLvl(nullLvl00)

	//; Instantiate all actors from level data 
	jsr plotLevel
	
	
	ldx.w #numFontActor
	ldy.w #$0004
	sty.w stackActY
	stx.w sprCallback
	FActor.createActor()
	
	ldx.w #numFontActor
	ldy.w #$0034
	sty.w stackActX
	ldy.w #$0004
	sty.w stackActY
	stx.w sprCallback
	FActor.createActor()

	//setHDMAColor(colorTable, 3, 0, 4)
	
	ldx.w #sceneNull_Update
	stx.w scenePtr
	
	FadeIN()
	
	plb
	ply
	plx
	pla
	
	rts

}

sceneNull_Update: {

	pha
	phx
	phy
	phb
	
	plb
	ply
	plx
	pla

	rts

}