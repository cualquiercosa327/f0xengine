

modemRead_main: {

	pha
	phx
	phy
	phb
	
	lda.b #$80
	sta.w REG_INIDISP
	
	LoadPAL(debugFontP, $00, 4, 0)
	LoadLOVRAM(debugFont, $8000, $3F8, 0) //; load our debug font
	
	lda.b #%00001000
	sta.w REG_BGMODE

	lda.b #%1111111
	sta.w REG_BG1SC
	lda.b #%00000100
	sta.w REG_BG12NBA

	lda.b #%00000001
	sta.w REG_TM

	stz.w REG_BG1HOFS
	stz.w REG_BG1HOFS
	stz.w REG_BG1VOFS
	stz.w REG_BG1VOFS

	lda.b #%00000001
	sta.w REG_TM 
	
	lda.b #3
	sta.w $1FD0
	lda.b #2
	sta.w $1FD1
	ldx.w #waitTxt
	stx.w $1FD2
	ldx.w #$F800
	stx.w $1FD4
	lda.b #12
	sta.w $1FD6
	jsr f_print
	
	stz $60
	
	ldx.w #modemRead_waitForHandshake
	stx.w scenePtr
	
	lda.b #$80		//; SNES ready to receive
	sta.l $7F0000
	
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
	
	lda.l $7F0000
	cmp.b #$E0
	bne +
	
	stz.w REG_CGADD
	
	lda.b #$55
	sta.w REG_CGDATA
	sta.w REG_CGDATA
	
	+
	plb
	ply
	plx
	pla

	rts

}

player_dat:
db 11
db "TEST PLAYER"
db 16
db "UNKNOWN LOCATION"

modemRead_waitForHandshake: {
	
	pha
	phx
	phy
	phb	
	
	lda.b #$80
	sta.l $7F0000
	
	ldx.w #modemRead_mainUpdate
	stx.w scenePtr
	
	plb
	ply
	plx
	pla

	rts

}