//; NUMERICAL FONT ACTOR
//; $62 = Command
//; $63 = Player ID

constant NGRAV_FORCE($01)
constant NVELO_INC_WAIT($05)
constant NVELO_MAX($10)
constant NJUMP_HEIGHT($02)

numFontActor:
	
	pha
	phy
	phx
	
	jsr f_initActor
	
	ldx.w #0
	ldy.w #50
	jsr f_setSprite
	jsr f_enableSprLarge
	
	ldx.w #numFontActor_Delay
	jsr f_setActorUpdate
	
	ldy.w #6 //; jump height
	lda.b #$FF
	sta [actorRes],y
	iny
	lda.b #$04
	sta [actorRes],y //; bounce index - 5 bounces
	
	plx
	ply
	pla
	
	rts
	
numFontActor_Update:
	
	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actProp
	
	jsr numFontActor_checkCMD
	
	plx
	ply
	pla
	
	rts
	
numFontActor_checkCMD:
	
	pha
	phy
	phx
	
	lda.b $62
	cmp #$00
	beq +
	pha
	and #$0F
	sta.b $63
	pla
	and #$F0
	lsr #$04
	
	jsr numFontActor_CMDLUT
	
	+
	
	plx
	ply
	pla
	
	rts
	
numFontActor_CMDLUT:
	
	ldy.w #3
	pha
	lda [actorRes],y
	cmp $63
	bne +
	pla
	tay
	ldx numFontCMDLUT,y
	stx.w sprResult
	ldx.w #0
	jsr (sprResult,x)
	pha
	+
	pla
	rts

numFontActor_clearCMD:

	stz.b $62
	stz.b $63
	rts


numFontActor_inc:

	ldy.w #2
	lda [sprCallback],y
	clc
	adc #$02
	sta [sprCallback],y
	ldy.w #6 //; jump height
	lda.b #$00
	sta [actorRes],y
	iny
	lda.b #$03
	sta [actorRes],y //; bounce index - 5 bounces
	ldy.w #2
	lda [actorRes],y
	clc
	sbc #$01
	sta [actorRes],y
	
	ldx.w #numFontActor_IntroUpdate
	jsr f_setActorUpdate
	
	jsr numFontActor_clearCMD
	rts
	
numFontActor_IntroUpdate:

	pha
	phy
	phx

	sty.w actorIndex
	jsr f_actProp
	
	jsr numFontActor_gravity

	plx
	ply
	pla
	
	rts
	
numFontActor_Delay: 

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actProp
	
	jsr numFontActor_checkDelay
	
	plx
	ply
	pla

	rts
	
numFontActor_checkDelay:

	ldy.w #3
	lda [actorRes],y
	tax
	
	iny
	lda [actorRes],y
	cmp delayTable,x
	beq +
	adc #$01
	sta [actorRes],y
	rts

	+
	ldy.w #4
	lda.b #$00
	sta [actorRes],y
	
	ldx.w #numFontActor_IntroUpdate
	jsr f_setActorUpdate
	rts
	
numFontActor_gravity:
	
	ldy.w #5
	lda [actorRes],y
	clc
	adc #$01
	sta [actorRes],y
	
	jsr numFontActor_veloDelay
	
	//; Y = Y + velocity 
	ldy.w #$0002
	lda [actorRes],y
	iny #$02
	adc [actorRes],y
	dey #$02
	sta [actorRes],y
	
	//; Y = Y - jump height
	lda [actorRes],y
	ldy.w #6
	sbc [actorRes],y
	ldy.w #2
	sta [actorRes],y
	
	jsr numFontActor_checkBounce

	rts
	
numFontActor_veloDelay:

	ldy.w #5
	lda [actorRes],y
	cmp.b #NVELO_INC_WAIT
	bpl +
	
	dey
	lda [actorRes],y
	cmp.b #NVELO_MAX
	bpl ++
	
	rts
	
	+ {
		lda.b #0
		ldy.w #5
		sta [actorRes],y
		dey
		lda [actorRes],y
		clc
		adc.b #NGRAV_FORCE
		sta [actorRes],y
	}
	
	rts
	
	+ {
		ldy.w #4
		lda.b #NVELO_MAX
		sta [actorRes],y
	}
	
	rts
	
numFontActor_checkBounce:

	ldy.w #2
	lda [actorRes],y
	cmp #$C9
	bpl +
	rts
	
	+ 
	and #$F0
	lsr #$04
	cmp #$0F
	beq getOut
	cmp #$0E
	beq getOut
	cmp #$0D
	beq getOut
	cmp #$0C
	beq +
	rts
	
	+
	ldy.w #7
	lda [actorRes],y
	cmp #$FF
	beq stopNumBounce
	bne +
	
	+
	ldy.w #7
	lda [actorRes],y
	tax
	ldy.w #$0002
	lda [actorRes],y
	dec #01
	sta [actorRes],y
	ldy.w #4
	lda.b #0
	sta [actorRes],y
	iny
	sta [actorRes],y
	lda bounceTable,x
	ldy.w #6
	sta [actorRes],y
	
	ldy.w #7
	lda [actorRes],y
	dec
	sta [actorRes],y
	
	getOut:
	
	rts
	
	stopNumBounce:
	ldx.w #numFontActor_Update
	jsr f_setActorUpdate
	rts
	

	
delayTable:
	db 0
	db 10
	db 25
	db 255
	
bounceTable:
	db 0
	db 1
	db 2
	db 3
	db 4
	
numFontCMDLUT:
	dw numFontActor_inc