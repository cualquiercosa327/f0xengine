

scene_boot00_Init: {
	
	pha
	phx
	phy
	phb
	
	LoadPAL(sprBootTxtP, 128, $0020, 0)
	LoadVRAM(sprBootTxtT, $0000, $07F0, 0)
	
	LoadPAL(bgNBootP, 0, $0020, 0)
	LoadVRAM(bgNBootT, $4000, bgNBootT.size, 0)
	LoadVRAM(bgNBootM, $2000, bgNBootM.size, 0)
	

	lda.b #%00000001
	sta.w REG_BGMODE

	lda.b #%00010000  // AAAAAASS: S = BG Map Size, A = BG Map Address
	sta.w REG_BG1SC   // $2108: BG1 32x32, BG1 Map Address = $3F (VRAM Address / $400)
	lda.b #%00000010  // BBBBAAAA: A = BG1 Tile Address, B = BG2 Tile Address
	sta.w REG_BG12NBA // $210B: BG1 Tile Address = $0 (VRAM Address / $1000)

	lda.b #%00010001
	sta.w REG_TM 

	lda.b #%00000000 // 8x8 -> 16x16
	sta.w REG_OBSEL

	//; Initalize actors
	FActor.initActors()
	
	rep #$30
	lda.w #OBJ_OUTSIDE_BG2_INSIDE
	ldx.w #128
	ldy.w #128
	jsr f_setWH01Window
	
	lda.b #128
	sta.b $60
	sta.b $62
	
	ldx.w #bootTextActor_Init
	ldy.w #$0070
	sty.w stackActX
	ldy.w #$0050
	sty.w stackActY
	stx.w sprCallback
	lda.b #$01
	sta.w stackActID
	jsr f_createActorDP
	
	ldx.w #bootTextActor_Init
	ldy.w #$0070
	sty.w stackActX
	ldy.w #$0050
	sty.w stackActY
	stx.w sprCallback
	lda.b #$02
	sta.w stackActID
	jsr f_createActorDP
	
	ldx.w #bootTextActor_Init
	ldy.w #$0070
	sty.w stackActX
	ldy.w #$0050
	sty.w stackActY
	stx.w sprCallback
	lda.b #$03
	sta.w stackActID
	jsr f_createActorDP
	
	ldx.w #bootTextActor_Init
	ldy.w #$0070
	sty.w stackActX
	ldy.w #$0050
	sty.w stackActY
	stx.w sprCallback
	lda.b #$04
	sta.w stackActID
	jsr f_createActorDP
	
	ldx.w #bootTextActor_Init
	ldy.w #$0070
	sty.w stackActX
	ldy.w #$0050
	sty.w stackActY
	stx.w sprCallback
	lda.b #$05
	sta.w stackActID
	jsr f_createActorDP
	
	ldx.w #bootTextActor_Init
	ldy.w #$0070
	sty.w stackActX
	ldy.w #$0050
	sty.w stackActY
	stx.w sprCallback
	lda.b #$06
	sta.w stackActID
	jsr f_createActorDP
	
	ldx.w #bootTextActor_Init
	ldy.w #$0070
	sty.w stackActX
	ldy.w #$0050
	sty.w stackActY
	stx.w sprCallback
	lda.b #$07
	sta.w stackActID
	jsr f_createActorDP
	
	ldx.w #bootTextActor_Init
	ldy.w #$0070
	sty.w stackActX
	ldy.w #$0050
	sty.w stackActY
	stx.w sprCallback
	lda.b #$08
	sta.w stackActID
	jsr f_createActorDP
	
	ldx.w #bootTextActor_Init
	ldy.w #$0070
	sty.w stackActX
	ldy.w #$0050
	sty.w stackActY
	stx.w sprCallback
	lda.b #$09
	sta.w stackActID
	jsr f_createActorDP
	
	ldx.w #scene_boot00_Update
	stx.w scenePtr
	
	lda.b #$14
	sta.w REG_BG1HOFS
	stz.w REG_BG1HOFS
	lda.b #$F4
	sta.w REG_BG1VOFS
	stz.w REG_BG1VOFS

	
	FadeIN()
	
	plb
	ply
	plx
	pla
	
	rts

}

scene_boot00_Update: {

	pha
	phx
	phy
	phb
	
	rep #$30
	lda.w #OBJ_OUTSIDE_BG2_INSIDE
	ldx.w $60
	ldy.w $62
	jsr f_setWH01Window
	
	jsr scene_boot00_Window
	jsr scene_boot00_counter
	jsr scene_boot00_fade
	
	plb
	ply
	plx
	pla

	rts

}


scene_boot00_Window: {

	lda.b $60
	cmp.b #1
	bmi +
	dec $60
	+
	lda.b $62
	cmp.b #250
	bpl +
	inc $62
	+
	rts

}

scene_boot00_counter: {

	rep #$30
	lda.b $64
	adc.w #1
	sta.b $64
	sep #$20
	rts

}


scene_boot00_fade: {

	ldx.w $64
	cpx.w #618
	bcc +
	FadeOUT()
	
	ldx.w #0
-
	lda.b #0
	sta $60,x
	inx
	cpx #8
	bne -
	
	ldx.w #debugMenu_Init
	stx.w scenePtr
	+
	rts

}