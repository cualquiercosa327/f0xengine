debugMenu_Init: {

	lda.b #$80
	sta.w REG_INIDISP
	
	initOAM()
	jsr f_initActors
	
	LoadPAL(debugFontP, $00, 4, 0) // Load BG Palette Data
	LoadLOVRAM(debugFont, $8000, $3F8, 0) // Load 1BPP Tiles To VRAM Lo Bytes (Converts To 2BPP Tiles)
	LoadPAL(sprCursorP, 128, 8, 0)
	LoadVRAM(sprCursorT, $0000, sprCursorT.size, 0)
	
	// Setup Video
	lda.b #%00001000 // DCBAPMMM: M = Mode, P = Priority, ABCD = BG1,2,3,4 Tile Size
	sta.w REG_BGMODE // $2105: BG Mode 0, Priority 1, BG1 8x8 Tiles

	// Setup BG1 256 Color Background
	lda.b #%11111110  // AAAAAASS: S = BG Map Size, A = BG Map Address
	sta.w REG_BG1SC   // $2108: BG1 32x32, BG1 Map Address = $3F (VRAM Address / $400)
	lda.b #%00000100  // BBBBAAAA: A = BG1 Tile Address, B = BG2 Tile Address
	sta.w REG_BG12NBA // $210B: BG1 Tile Address = $0 (VRAM Address / $1000)

	lda.b #%00000001 // Enable BG1
	sta.w REG_TM // $212C: BG1 To Main Screen Designation

	stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos Low Byte
	stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos High Byte
	stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Scroll Pos Low Byte
	stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Pos High Byte

	lda.b #%00010001
	sta.w REG_TM 

	lda.b #%00000000 // 8x8 -> 16x16
	sta.w REG_OBSEL
	
	//; Initalize actors
	jsr f_initActors
	
	ldx.w #debugMenu_Update
	stx.w scenePtr
	
	//lda.b #3
	//sta.w $1FD0
	//lda.b #2
	//sta.w $1FD1
	//ldx.w #f0xengine_credits
	//stx.w $1FD2
	//ldx.w #$F800
	//stx.w $1FD4
	//lda.b #26
	//sta.w $1FD6
	//jsr f_print
	
	PrintText(7, 4, sceneSelTxt, $F800, 16)
	PrintText(12, 8, tst00txt, $F800, 5)
	PrintText(12, 9, tst01txt, $F800, 5)
	PrintText(12, 10, titletxt, $F800, 5)
	PrintText(12, 11, tst02txt, $F800, 13)
	PrintText(12, 12, tst03txt, $F800, 9)
	
	ldx.w #dbgCursorActor
	ldy.w #$00EF
	sty.w stackActX
	ldy.w #$00EF
	sty.w stackActY
	stx.w sprCallback
	FActor.createActor()
	
	lda.b #$00
	sta.w sprCallback
	
    //setHDMAMultiColor(textColor, colorTable, 3, 0)
	ldx.w #$71C6
	stx.w $0067 //; choice palette color
	
	ldx.w #290
	stx.w tempByte
	BGScroll16(tempByte, REG_BG1VOFS, in)
	
	ClearLOVRAM(noTxt, $022a, $0002, 6)
	ClearLOVRAM(noTxt, $026c, $0002, 6)
	ClearLOVRAM(noTxt, $02E8, $0002, 6)
	ClearLOVRAM(noTxt, $0680, $0200, 6)
	
	lda.b #$00
	sta.w $0060 //; Set current menu choice to zero
	ldx.w #selListMain
	stx.w $006E
	
	//; Fade screen (In)
	FadeIN()
	
	rts

}

debugMenu_Update: {

	pha
	phx
	phy
	phb
	
	jsr checkBGIntroScroll
	jsr processChoice
	jsr updateChoiceColor
	
	plb
	ply
	plx
	pla
	
	rts

}

mainMenu_Show: {

	PrintText(3, 2, f0xengine_credits, $F800, 26)
	PrintText(7, 4, sceneSelTxt, $F800, 16)
	PrintText(12, 8, tst00txt, $F800, 5)
	PrintText(12, 9, tst01txt, $F800, 5)
	PrintText(12, 10, titletxt, $F800, 5)
	PrintText(12, 11, tst02txt, $F800, 13)
	PrintText(12, 12, tst03txt, $F800, 9)
	ldx.w #debugMenu_Update
	stx.w scenePtr
	
	rts
}

sceneMenu_Show: {
	
	PrintText(12, 8, scn00, $F800, 6)
	PrintText(12, 9, scn01, $F800, 6)
	ldx.w #debugMenu_Update
	stx.w scenePtr
	rts

}

audioMenu_Show: {
	
	PrintText(12, 8, mus00, $F800, 4)
	PrintText(12, 9, mus01, $F800, 6)
	PrintText(12, 10, mus02, $F800, 4)
	ldx.w #debugMenu_Update
	stx.w scenePtr
	rts

}

happyMenu_Show: {
	
	PrintText(12, 8, hpy00, $F800, 10)
	PrintText(12, 9, hpy01, $F800, 6)
	ldx.w #debugMenu_Update
	stx.w scenePtr
	rts

}

snesMenu_Show: {
	
	PrintText(12, 8, snes00, $F800, 11)
	PrintText(12, 9, snes01, $F800, 8)
	ldx.w #debugMenu_Update
	stx.w scenePtr
	rts

}

checkBGIntroScroll: {

	
	rep #$30
	lda.w tempByte
	cmp.w #$0200
	sep #$20
	bpl +
	
	lda.b tempByte
	sta.w REG_BG1VOFS
	lda.b tempByte+1
	sta.w REG_BG1VOFS
	
	rep #$30
	lda.w tempByte
	adc.w #$0002
	sta.w tempByte
	lda.w #$0000
	sep #$20
	
	+ {
		rep #$30
		lda.w #0
		sep #$20
		rts
	}

}

processChoice: {
	
	lda.b $0060 //; menu choice
	asl
	asl
	tay
	lda [$6E],y //; x
	pha
	iny
	lda [$6E],y //; y
	pha
	iny
	lda [$6E],y //; size
	sta.b $0063
	pla
	sta.b $0062
	pla
	sta.b $0061
	
	lda.b $0060
	asl
	asl
	tay
	iny #03
	lda [$6E],y //; index
	sta.b $006C
	
	phb
  
	lda.w $0062
	rep #$30
	asl #$06
	sta.w sprCallback
	lda.w #0
	sep #$20
	lda.w $0061
	asl
	rep #$30
	adc.w sprCallback
	adc.w #$F800
	lsr
	tax
  
	lda.w #$0000
	sep #$20
  
	lda.b #$80
	sta.w REG_VMAIN 
	stx.w REG_VMADDL

	ldx.w #0
	
	- {
		
		lda.b #$04
		sta.w REG_VMDATAH
		inx 
		cpx.w $0063
		
		bne -
	}
	
	plb
	
	rts
	
}

updateChoiceColor: {

	LoadPAL($0067, 5, 2, 0)
	ldx.w $0067
	dex
	stx.w $0067
	
	rts

}

debugMenu_resetPrevious: {

	lda.b $0070
	beq +
	
	lda.w $0071
	rep #$30
	asl #$06
	sta.w sprCallback
	lda.w #0
	sep #$20
	lda.w $0070
	asl
	rep #$30
	adc.w sprCallback
	adc.w #$F800
	lsr
	tax
  
	lda.w #$0000
	sep #$20
  
	lda.b #$80
	sta.w REG_VMAIN 
	stx.w REG_VMADDL

	ldx.w #0
	
	- {
		
		lda.b #$00
		sta.w REG_VMDATAH
		inx 
		cpx.w $0063
		
		bne -
	}
	
	+ {
		rts
	}

}

debugMenu_setPrevious: {

	pha
	lda.w $0061
	sta.w $0070
	lda.w $0062
	sta.w $0071
	lda.w $0063
	sta.w $0072
	pla
	rtl

}

debugMenu_clearPage: {

	ClearVRAM(noTxt, $Fa10, $0200, 0)
	lda.b $006C
	asl
	tay
	rep #$30
	lda menuPtrs,y
	sta.w $006E
	lda menuExePtrs,y
	sta.w $007E
	lda.w #0
	sep #$20
	ldx.w $007E
	stx.w scenePtr
	//jsr debugMenu_loadPage
	rts

}

debugMenu_returnPage: {

	ClearVRAM(noTxt, $Fa10, $0200, 0)
	ldy.w #0
	rep #$30
	lda menuPtrs,y
	sta.w $006E
	lda menuExePtrs,y
	sta.w $007E
	lda.w #0
	sep #$20
	ldx.w $007E
	stx.w scenePtr
	rts

}

jumpToTst00: {

	ldx.w #sceneNull01_Init
	stx.w scenePtr
	
	jsr debugMenu_clearVals 
	initOAM()
	jsr f_initActors
	FadeOUT()
	
	rts

}

jumpToTst02: {

	ldx.w #sceneNull02_Init
	stx.w scenePtr
	
	jsr debugMenu_clearVals 
	initOAM()
	jsr f_initActors
	FadeOUT()
	
	rts

}

debugMenu_clearVals:

	ldx.w #0
	ldy.w #$001E
	lda.b #0
	
	-
		sta $62,x
		inx
		dey
		cpy #0
		bne -

	rts

debugFontP:
  dw $0000, $7FFF
  
sceneSelTxt:
	db "-- DEBUG MENU --"
tst00txt:
	db "SCENE"
tst01txt:
	db "AUDIO"
titletxt:
	db "CRASH"
tst02txt:
	db "HAPPY FUNTIME"
tst03txt:
	db "DAMN 5A22"

scn00:
	db "TEST00"
scn01:
	db "TEST01"
	
mus00:
	db "MONO"
mus01:
	db "STEREO"
mus02:
	db "NONE"
	
hpy00:
	db "MIKE SUCKS"
hpy01:
	db "ZENDEN"
	
snes00:
	db "2.58 MHz of"
snes01:
	db "slowness"
	

selListMain:
	db 12; db 8; db 5; db 1
	db 12; db 9; db 5; db 2
	db 12; db 10; db 5; db 3
	db 12; db 11; db 13; db 4
	db 12; db 12; db 9; db 5
sceneSelMain:
	db 12; db 8; db 6; db 6
	db 12; db 9; db 6; db 7
musSelMain:
	db 12; db 8; db 4; db $FF
	db 12; db 9; db 6; db $FF
	db 12; db 10; db 4; db $FF
hypSelMain:
	db 12; db 8; db 10; db $FF
	db 12; db 9; db 6; db $FF
snesSelMain:
	db 12; db 8; db 11; db $FF
	db 12; db 9; db 8; db $FF
	
menuPtrs:
	dw selListMain
	dw sceneSelMain
	dw musSelMain
	dw 0			//; in dedication to Mr. Rean
	dw hypSelMain
	dw snesSelMain
menuExePtrs:
	dw mainMenu_Show
	dw sceneMenu_Show
	dw audioMenu_Show
	dw 0
	dw happyMenu_Show
	dw snesMenu_Show
	dw jumpToTst00
	dw jumpToTst02
noTxt:
	dw 0