

modemRead_main: {

	pha
	phx
	phy
	phb
	
	LoadPAL(bgVineP, 0, $0200, 0)
	LoadVRAM(bgVineM, $0000, $1000, 0)
	LoadVRAM(bgVineT, $2000, $8000, 0)
	LoadVRAM(bgVineTH, $A000, $1C00, 0)
	
	WaitNMI()
	
	lda.b #%00000011
	sta.w REG_BGMODE

	lda.b #%00000000
	sta.w REG_BG1SC
	lda.b #%00000001
	sta.w REG_BG12NBA

	lda.b #%00000001
	sta.w REG_TM

	stz.w REG_BG1HOFS
	stz.w REG_BG1HOFS
	stz.w REG_BG1VOFS
	stz.w REG_BG1VOFS

	lda.b #%00000001
	sta.w REG_TM 
	
	ldx.w #modemRead_waitForHandshake
	stx.w scenePtr
	
	FadeIN()
	
	plb
	ply
	plx
	pla
	
	rts

}

modemRead_mainUpdate: {

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

modemRead_waitForHandshake: {
	
	pha
	phx
	phy
	phb	
	
	sta.w $0100
	lda.w $2100
	
	plb
	ply
	plx
	pla

	rts

}