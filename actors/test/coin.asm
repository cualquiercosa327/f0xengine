sparkleActor_Init: {

    pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$57
	jsr setActorType
	
	ldy.w #sprCoinC
	ldx.w #sprCoinC.size
	lda.b #sprCoinC >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprCoinP
	ldy.w #$0400
	lda.b #sprCoinP >> 16
	jsr allocateSVTEntry
	
	ldx.w #nSprTbl
	lda.b #nSprTbl >> 16
	jsr renderOAM
	
	ldx.w #sparkleActor_Update
	lda.b #sparkleActor_Update >> 16
	jsr f_setActorUpdate

    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

sparkleActor_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
    stx.w APTI
	jsr f_actPropDP
    
    jsr f_setADB

	ldx.w #nSprTbl
	lda.b #nSprTbl >> 16
	jsr updateMetaSprites

	ldx.b ADTI
	tdc

    lda.b #48
    sta.w actor.tileFlags,x

	lda.w 8,x
	cmp.b #15
	beq +

	tax
	lda.l sparkleActor_animTbl,x
	ldx.b ADTI
	sta.w 6,x
	inc 8,x
	bra ++
	+
	stz.w 8,x
    jsr destroyActor
	+

    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

coinActor_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$57
	jsr setActorType
	
	ldy.w #sprCoinC
	ldx.w #sprCoinC.size
	lda.b #sprCoinC >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprCoinP
	ldy.w #$0400
	lda.b #sprCoinP >> 16
	jsr allocateSVTEntry
	
	ldx.w #nSprTbl
	lda.b #nSprTbl >> 16
	jsr renderOAM
	
	ldx.w #coinActor_Update
	lda.b #coinActor_Update >> 16
	jsr f_setActorUpdate

    jsr f_setADB
    ldx.b ADTI
    lda.w actor.y,x
    sta.w $0E,x

    lda.w actor.x,x
    sta.w $14,x

    tdc
    sep #$20
    jsr randAccum
    and.b #3
    asl
    tax
    rep #$20
    lda.l coinActor_randYVelTbl,x
    ldx.b ADTI
    sta.w $0A,x

    tdc
    sep #$20
    jsr randAccum
    and.b #7
    asl
    tax
    rep #$20
    lda.l coinActor_randXVelTbl,x
    ldx.b ADTI
    sta.w $12,x
    sep #$20

    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

coinActor_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
    stx.w APTI
	jsr f_actPropDP
    
    jsr f_setADB

	ldx.w #nSprTbl
	lda.b #nSprTbl >> 16
	jsr updateMetaSprites

	ldx.b ADTI
	tdc

    lda.b #48
    sta.w actor.tileFlags,x

	lda.w 8,x
	cmp.b #20
	beq +

	tax
	lda.l coinActor_animTbl,x
	ldx.b ADTI
	sta.w 6,x
	inc 8,x
	bra ++
	+
	stz.w 8,x
	+

	jsr coinActor_handleFloor
    jsr coinActor_handleWall
    jsr coinActor_handleX
    jsr coinActor_handleY

    lda.w $16,x
    beq +

    lda.w actor.x,x
    cmp.b #$56
    bcs +
    
    ldx.b ADTI
    lda.w actor.x,x
    xba
    lda.w actor.y,x
    rep #$20
    tay
    sep #$20
    lda.b #sparkleActor_Init >> 16
    ldx.w #sparkleActor_Init
    jsr spawnActor

    jsr destroyActor

    +
    
    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

coinActor_handleFloor:

    ldx.b ADTI
    lda.w actor.y,x
    cmp.b #224 - 16
    bcc +
    rep #$30
    lda.w #$FDFF
    sta.w $0A,x
    sep #$20
    +
    rts

coinActor_handleWall:

    //; 16: direction
    
    ldx.b ADTI
    lda.w actor.x,x
    cmp.b #256 - 16
    bcc +
    lda.w $16,x
    eor.b #1
    sta.w $16,x
    +
    rts

coinActor_handleX:

    //; 10: velocity int
    //; 11: velocity frac
    //; 12: rand inc
    //; 13: rand inc
    //; 14: new X

     rep #$30
    ldx.b ADTI
    clc
    lda.w $16,x
    and.w #$000F
    bne +

    lda.w $10,x
    adc.w $12,x
    bra ++

    +
    lda.w $10,x
    sbc.w $12,x
    +
    sta.w $10,x     //; velocity.x += increment
    
    clc
    lda.w $10,x
    xba
    and.w #$00FF
    sta.b tempWord
    lda.w $14,x
    adc.b tempWord
    sta.w actor.x,x
    sep #$20

    rts

coinActor_handleY:

    //; 0A: intergral
    //; 0B: fractional
    //; 0C: velocity int
    //; 0D: velocity frac
    //; 0E: new Y

    rep #$30
    ldx.b ADTI
    clc
    lda.w $0C,x
    adc.w $0A,x
    sta.w $0C,x     //; velocity.y += increment
    
    lda.w $0A,x
    clc
    adc.w #$000A
    sta.w $0A,x     //; increment += 0.04
    
    clc
    lda.w $0C,x
    xba
    and.w #$00FF
    adc.w $0E,x
    sta.w actor.y,x
    sep #$20

    rts

sparkleActor_animTbl:
db 6
db 6
db 6
db 6
db 6
db 8
db 8
db 8
db 8
db 8
db 10
db 10
db 10
db 10
db 10

coinActor_randXVelTbl:
dw $00B3    //; 0.70
dw $0099    //; 0.60
dw $0080    //; 0.50
dw $0066    //; 0.40
dw $004C    //; 0.30
dw $0033    //; 0.20
dw $0055    //; 0.70
dw $00A0    //; 0.60
dw $0025    //; 0.50
dw $0089    //; 0.40
dw $0045    //; 0.30
dw $0050    //; 0.20

coinActor_randYVelTbl:
dw $FDFF
dw $FFFF
dw $FEFF
dw $FDEE

coinActor_animTbl:
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 2
db 2
db 2
db 2
db 2
db 2
db 2
db 2
db 4
db 4
db 4
db 4
db 2
db 4
db 4
db 4
db 4