constant mario.direction($07)
constant mario.methodIndex($08)
constant mario.seedTimer($09)

constant controller.sinIndex($09)
constant controller.anchorX($0A)
constant controller.anchorY($0B)

waterActor_Init:

    pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$5A
	jsr setActorType
	
	ldy.w #sprWaterPotSC
	ldx.w #sprWaterPotSC.size
	lda.b #sprWaterPotSC >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprWaterPotSP
	ldy.w #$0400
	lda.b #sprWaterPotSP >> 16
	jsr allocateSVTEntry
	
	ldx.w #waterTbl
	lda.b #waterTbl >> 16
	jsr renderOAM
	
	ldx.w #waterActor_Update
	lda.b #waterActor_Update >> 16
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
    lda.l waterActor_randYVelTbl,x
    ldx.b ADTI
    sta.w $0A,x

    tdc
    sep #$20
    jsr randAccum
    and.b #7
    asl
    tax
    rep #$20
    lda.l waterActor_randXVelTbl,x
    ldx.b ADTI
    sta.w $12,x
    sep #$20

    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue

waterActor_Update:

    pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

    ldx.w #waterTbl
	lda.b #waterTbl >> 16
	jsr updateMetaSprites

    ldx.b ADTI
	tdc

    lda.b #48
    sta.w actor.tileFlags,x

    jsr waterActor_handleX
    jsr waterActor_handleY

    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue

waterActor_handleX:

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

waterActor_handleY:

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

    cmp.b #$C0
    bcc +

    jsr destroyActor

    +
    rts

waterPotActor_Init:

    pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$5A
	jsr setActorType
	
	ldy.w #sprWaterPotSC
	ldx.w #sprWaterPotSC.size
	lda.b #sprWaterPotSC >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprWaterPotSP
	ldy.w #$0400
	lda.b #sprWaterPotSP >> 16
	jsr allocateSVTEntry
	
	ldx.w #smallTeapotTbl
	lda.b #smallTeapotTbl >> 16
	jsr renderOAM
	
	ldx.w #waterPotActor_Update
	lda.b #waterPotActor_Update >> 16
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue

waterPotActor_Update:

    pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

    ldx.w #smallTeapotTbl
	lda.b #smallTeapotTbl >> 16
	jsr updateMetaSprites

    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue

dirtActor_Init:

    pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$5A
	jsr setActorType
	
	ldy.w #sprWaterPotSC
	ldx.w #sprWaterPotSC.size
	lda.b #sprWaterPotSC >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprWaterPotSP
	ldy.w #$0400
	lda.b #sprWaterPotSP >> 16
	jsr allocateSVTEntry
	
	ldx.w #dirtTbl
	lda.b #dirtTbl >> 16
	jsr renderOAM
	
	ldx.w #dirtActor_Update
	lda.b #dirtActor_Update >> 16
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue

dirtActor_Update:

    pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

    ldx.w #dirtTbl
	lda.b #dirtTbl >> 16
	jsr updateMetaSprites

    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue

refillActor_Init:

    pha
	phy
	phx
	
	jsr f_initActorDP

    jsr f_setADB
    ldx.b ADTI
    lda.b #$50
    sta.w actor.y,x
    lda.b marioX
    sec
    sbc.b #22
    sta.w actor.x,x
    jsr f_resetADB
	
	lda.b #$5B
	jsr setActorType
	
	ldy.w #sprRefillC
	ldx.w #sprRefillC.size
	lda.b #sprRefillC >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprRefillP
	ldy.w #$0800
	lda.b #sprRefillP >> 16
	jsr allocateSVTEntry
	
	ldx.w #controllerTbl
	lda.b #controllerTbl >> 16
	jsr renderOAM
	
	ldx.w #refillActor_Update
	lda.b #refillActor_Update >> 16
	jsr f_setActorUpdate

    jsr f_resetADB
    lda.b #$0A
	sta.w $2143
	lda.b #$50
	sta.w $2141
	lda.b #$80
	sta.w $2142
	lda.b #$08
	sta.w $2140
    jsr f_setADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue

constant refill.blinkTimer($08)
constant refill.blinkIndex($09)
refillActor_Update:

    pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

    ldx.b ADTI
	lda.b marioX
    sec
    sbc.b #22
    sta.w actor.x,x
    lda.b #$50
    sta.w actor.y,x

    ldx.w #controllerTbl
	lda.b #controllerTbl >> 16
	jsr updateMetaSprites

    ldx.b ADTI
    lda.w refill.blinkTimer,x
    cmp.b #7
    bne +
    
    rep #$30
    lda.w refill.blinkIndex,x
    pha
    asl
    tax
    lda.l refill_colorTbl,x
    tay
    pla
    sep #$20
    eor.b #1
    ldx.b ADTI
    sta.w refill.blinkIndex,x
    stz.w refill.blinkTimer,x

    lda.w actor.SPTID+1,x
    inc
    sta.l REG_CGADD
    rep #$20
	tya
	sep #$20
	sta.l REG_CGDATA
	xba
	sta.l REG_CGDATA

    +
    inc.w refill.blinkTimer,x

    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue

doSeedActor_Init:

    pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$59
	jsr setActorType

    jsr f_setADB
    ldx.b ADTI
    lda.b #$50
    sta.w controller.anchorY,x
    sta.w actor.y,x
    lda.b #$78-22
    sta.w actor.x,x
    jsr f_resetADB
	
	ldy.w #sprDoSeedC
	ldx.w #sprDoSeedC.size
	lda.b #sprDoSeedC >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprDoSeedP
	ldy.w #$0800
	lda.b #sprDoSeedP >> 16
	jsr allocateSVTEntry
	
	ldx.w #controllerTbl
	lda.b #controllerTbl >> 16
	jsr renderOAM
	
	ldx.w #doSeedActor_Update
	lda.b #doSeedActor_Update >> 16
	jsr f_setActorUpdate

    lda.b #$1E
    sta.b $70
	
	plx
	ply
	pla
	
	jml actorHandle_continue

doSeedActor_Update:

    pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

    ldx.b ADTI
	lda.b marioX
    sec
    sbc.b #22
    sta.w actor.x,x
    lda.w controller.anchorY,x
	pha
	lda.w controller.sinIndex,x
	inc controller.sinIndex,x
	rep #$20
	and.w #$00FF
	tax
	sep #$20
	lda.l controllerMoveTbl,x
	ldx.b ADTI
	clc
	adc $01,s
	sta.w actor.y,x
	pla

    jsr ticActor_fadeColor

    ldx.w #controllerTbl
	lda.b #controllerTbl >> 16
	jsr updateMetaSprites

    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue

ticActor_fadeColor: {
	
	lda.b $76				//; timer
	cmp.b #3
	bne +
	
	lda.b #0
	xba
	
	jsr colorFade

	ldy.b $72
	ldx.b $70
	jsr RGBtoBGR
	
	ldy.w #actor.SPTID+1
	lda (ADTI),y
	inc
	sta.l REG_CGADD
	
	rep #$20
	txa
	sep #$20
	sta.l REG_CGDATA
	xba
	sta.l REG_CGDATA

	stz.b $76

	+
	inc $76
	rts

}

//; mario child actors:
//; 0 - water seed/refill
//; 1 - water pot
marioActor_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$58
	jsr setActorType

    jsr f_setADB
    ldx.w ADTI
    lda.b #$D0
    sta.w actor.x,x
    lda.b #$FF
    sta.w actor.x+1,x

    lda.b #$A7
    sta.w actor.y,x

    jsr f_resetADB
	
	ldy.w #sprMarioC
	ldx.w #sprMarioC.size
	lda.b #sprMarioC >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprMarioP
	ldy.w #$0400
	lda.b #sprMarioP >> 16
	jsr allocateSVTEntry
	
	ldx.w #marioTbl
	lda.b #marioTbl >> 16
	jsr renderOAM

    jsr f_setADB
    ldx.w #marioTbl
	lda.b #marioTbl >> 16
	jsr updateMetaSprites
    jsr f_resetADB

	lda.b #1
	jsr setActorAnim
	
	ldx.w #marioActor_Update
	lda.b #marioActor_Update >> 16
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

marioActor_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

    ldx.b ADTI
    lda.b #48
    sta.w actor.tileFlags,x

	ldx.w #marioTbl
	lda.b #marioTbl >> 16
	jsr updateMetaSprites

	ldx.w #marioAnimTable
	lda.b #marioAnimTable >> 16
	jsr processADMAA

    ldx.w ADTI
    rep #$30
    lda.w actor.x,x
    clc
    adc.w #$0001
    sta.w actor.x,x
    sep #$20

    lda.w actor.x,x
    cmp.b #$78
    bne +
    
    lda.b #0
	jsr setActorAnim
    ldx.w #mario_setAnim
	lda.b #mario_setAnim >> 16
	jsr f_setActorUpdate

	rep #$20
	lda.w #((CHILD_0 << 8) | (doSeedActor_Init >> 16))
	ldx.w #doSeedActor_Init
	ldy.w #$8575
	jsr createChild

	+
    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

mario_setAnim:

    pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP

    lda.w REG_JOY1H
	sta.b joy1Input
    
    jsr f_setADB

    ldx.b ADTI
    lda.w actor.x,x
    sta.b marioX

    sep #$10
	ldy.b #mario.direction
	lda (ADTI),y
	asl
	tax
	rep #$10
	jsr (marioActor_DirList,x)
	
	jsr updateMetaSprites
	
	ldx.w #marioAnimTable
	lda.b #marioAnimTable >> 16
	jsr processADMAA

	ldy.w #mario.methodIndex
	lda (ADTI),y
	asl
	sep #$10
	tax
	rep #$10
	jsr (marioActor_FuncList,x)

    jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue

marioActor_DirList:
dw marioActor_DirRight
dw marioActor_DirLeft

marioActor_FuncList:
dw marioActor_IdleInit      //; 0
dw marioActor_IdleUpdate    //; 1
dw marioActor_RunInit       //; 2
dw marioActor_RunUpdate     //; 3
dw marioActor_setSeedInit   //; 4
dw marioActor_setSeedUpdate //; 5
dw marioActor_waterInit     //; 6
dw marioActor_waterUpdate   //; 7

marioActor_DirRight:

	ldy.w #actor.tileFlags
	lda.b #$30
	sta (ADTI),y
	
	ldx.w #marioTbl
	lda.b #marioTbl >> 16

	rts

marioActor_DirLeft:

	ldy.w #actor.tileFlags
	lda.b #$70
	sta (ADTI),y
	
	ldx.w #marioTbl
	lda.b #marioTbl >> 16

	rts

marioActor_IdleInit:

	lda.b #0
	jsr setActorAnim

    ldx.b ADTI
    lda.b #$01
    sta.w actor.animDelay,x

	ldy.w #mario.methodIndex
	lda (ADTI),y
	inc
	sta (ADTI),y
	
	rts

marioActor_IdleUpdate:
	
	lda.b joy1Input
	bit.b #1
	beq +

	ldy.w #mario.direction
	lda.b #0
	sta (ADTI),y

	ldy.w #mario.methodIndex
	lda.b #2
	sta (ADTI),y

	rts

	+
	bit.b #2
	beq +

	ldy.w #mario.direction
	lda.b #1
	sta (ADTI),y
	
	ldy.w #mario.methodIndex
	lda.b #2
	sta (ADTI),y

	+
    bit.b #4
    beq +

    ldy.w #mario.methodIndex
	lda.b #4
	sta (ADTI),y

    +
    bit.b #$80
    beq +

    ldy.w #mario.methodIndex
	lda.b #6
	sta (ADTI),y

    +
	rts

marioActor_RunInit:

	lda.b #1
	jsr setActorAnim

    ldx.b ADTI
    lda.b #$03
    sta.w actor.animDelay,x


	ldy.w #mario.methodIndex
	lda.b #3
	sta (ADTI),y
	
	rts

marioActor_RunUpdate:

	lda.b joy1Input
	cmp.b #1
	bne +

	ldy.w #mario.direction
	lda.b #0
	sta (ADTI),y
	
	ldx.w ADTI
	rep #$20
	lda.w actor.x,x
	clc
	adc.w #1
	sta.w actor.x,x
	sep #$20

	rts

	+
	cmp.b #2
	bne +

	ldy.w #mario.direction
	lda.b #1
	sta (ADTI),y
	
	ldx.w ADTI
	rep #$20
	lda.w actor.x,x
	sec
	sbc.w #1
	sta.w actor.x,x
	sep #$20

	rts

	+
	ldy.w #mario.methodIndex
	lda.b #0
	sta (ADTI),y
	rts

marioActor_setSeedInit:

    lda.b #2
	jsr setActorAnim

    jsr f_resetADB
    lda.b #$0A
	sta.w $2143
	lda.b #$22
	sta.w $2141
	lda.b #$80
	sta.w $2142
	lda.b #$08
	sta.w $2140
    jsr f_setADB

	ldx.b ADTI
    inc.w mario.methodIndex,x
    stz.w mario.seedTimer,x

	lda.b #CHILD_0	//; plant seed icon
	jsr destroyChild

    ldx.b ADTI
	lda.b marioX
    xba
    lda.w actor.y,x
    adc.b #$10
    tay
    lda.b #dirtActor_Init >> 16
	ldx.w #dirtActor_Init
	jsr spawnActor

    rts

marioActor_setSeedUpdate:

    ldx.b ADTI
    lda.w mario.seedTimer,x
    bit.b #$20
    beq +
    ldx.b ADTI
    lda.b #0
    sta.w mario.methodIndex,x
    +
    inc.w mario.seedTimer,x
    rts

marioActor_waterInit:

    lda.b #3
	jsr setActorAnim

    jsr f_resetADB
    lda.b #$0A
	sta.w $2143
	lda.b #$08
	sta.w $2141
	lda.b #$80
	sta.w $2142
	lda.b #$08
	sta.w $2140
    jsr f_setADB

	
	ldx.b ADTI
    inc.w mario.methodIndex,x

    lda.b marioX
    adc.b #14
    xba
    lda.w actor.y,x
    adc.b #11
    tay
    rep #$20
	lda.w #((CHILD_0 << 8) | (waterPotActor_Init >> 16))
	ldx.w #waterPotActor_Init
	jsr createChild

    rts

marioActor_waterUpdate:

    jsr sceneMap512_DecreaseWater
    jsr marioActor_viewMeter
    jsr marioActor_checkMeter
    
    lda.b gameFrame
    bit.b #7
    beq +

	ldx.b ADTI
    lda.b marioX
    adc.b #24
    xba
    lda.w actor.y,x
    adc.b #10
    tay
    lda.b #waterActor_Init >> 16
	ldx.w #waterActor_Init
	jsr spawnActor

    +
    rts

marioActor_viewMeter:

    ldx.b $64
    cpx.w #-16
    bne +
    rts
    +
    dex
    stx.b $64
    rts

marioActor_checkMeter:

    lda.b $66
    beq +

    lda.b #CHILD_0		//; water pot
	jsr destroyChild
	
	lda.b #refillActor_Init >> 16
	ldx.w #refillActor_Init
    ldy.w #$FFFF
    jsr spawnActor

    inc.b $66

    ldx.b ADTI
    stz.w mario.methodIndex,x

    +
    rts

controllerMoveTbl:
db 0,0,0,0,0,1,1,2,3,3,4,5,6,7,8,8
db 9,10,11,11,12,12,13,13,13,13,13,13,13,13,12,12
db 11,11,10,9,8,8,7,6,5,4,3,3,2,1,1,0
db 0,0,0,0,0,0,0,0,1,1,2,3,3,4,5,6
db 7,8,8,9,10,11,11,12,12,13,13,13,13,13,13,13
db 13,12,12,11,11,10,9,8,8,7,6,5,4,3,3,2
db 1,1,0,0,0,0,0,0,0,0,0,1,1,2,3,3
db 4,5,6,7,8,8,9,10,11,11,12,12,13,13,13,13
db 13,13,13,13,12,12,11,11,10,9,8,8,7,6,5,4
db 3,3,2,1,1,0,0,0,0,0,0,0,0,0,1,1
db 2,3,3,4,5,6,7,8,8,9,10,11,11,12,12,13
db 13,13,13,13,13,13,13,12,12,11,11,10,9,8,8,7
db 6,5,4,3,3,2,1,1,0,0,0,0,0,0,0,0
db 0,1,1,2,3,3,4,5,6,7,8,8,9,10,11,11
db 12,12,13,13,13,13,13,13,13,13,12,12,11,11,10,9
db 8,8,7,6,5,4,3,3,2,1,1,0,0,0,0,0

waterActor_randXVelTbl:
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

waterActor_randYVelTbl:
dw $FFFF
dw $FFFF
dw $FFFF
dw $FFFF

refill_colorTbl:
dw $0000
dw $7FFF