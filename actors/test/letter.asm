
constant ANIM_PUGGSY_WALK($01)

constant bun.direction($06)
constant bun.methodIndex($07)

letterActor_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #ACT_TYPE_LETTER
	jsr setActorType
	
	ldy.w #sprGarfC
	ldx.w #sprGarfC.size
	lda.b #sprGarfC >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprGarfP
	ldy.w #$0800
	lda.b #sprGarfP >> 16
	jsr allocateSVTEntry
	
	ldx.w #garfSprTbl
	lda.b #garfSprTbl >> 16
	jsr renderOAM

	lda.b #0
	jsr setActorAnim
	
	ldx.w #letterActor_Update
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

letterActor_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
	
	lda.w REG_JOY1H
	sta.b joy1Input
	
	jsr f_setADB
	
	sep #$10
	ldy.b #bun.direction
	lda (ADTI),y
	asl
	tax
	rep #$10
	jsr (bunActor_DirList,x)
	
	jsr updateMetaSprites
	
	ldx.w #kittyAnimTable
	lda.b #kittyAnimTable >> 16
	jsr processADMAA

	ldy.w #bun.methodIndex
	lda (ADTI),y
	asl
	sep #$10
	tax
	rep #$10
	jsr (bunActor_FuncList,x)
	
	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

bunActor_DirList:
dw bunActor_DirRight
dw bunActor_DirLeft

bunActor_FuncList:
dw bunActor_IdleInit
dw bunActor_IdleUpdate
dw bunActor_RunInit
dw bunActor_RunUpdate
dw bunActor_skidInit
dw bunActor_skidUpdate

bunActor_DirRight:

	ldy.w #actor.tileFlags
	lda.b #$30
	sta (ADTI),y
	
	ldx.w #garfSprTbl
	lda.b #garfSprTbl >> 16

	rts

bunActor_DirLeft:

	ldy.w #actor.tileFlags
	lda.b #$70
	sta (ADTI),y
	
	ldx.w #garfSprTblLeft
	lda.b #garfSprTblLeft >> 16

	rts

bunActor_IdleInit:

	lda.b #0
	jsr setActorAnim

	ldy.w #bun.methodIndex
	lda (ADTI),y
	inc
	sta (ADTI),y
	
	rts

bunActor_IdleUpdate:
	
	lda.b joy1Input
	bit.b #1
	beq +

	ldy.w #bun.direction
	lda.b #0
	sta (ADTI),y

	ldy.w #bun.methodIndex
	lda.b #2
	sta (ADTI),y

	rts

	+
	bit.b #2
	beq +

	ldy.w #bun.direction
	lda.b #1
	sta (ADTI),y
	
	ldy.w #bun.methodIndex
	lda.b #2
	sta (ADTI),y

	+
	rts

bunActor_RunInit:

	lda.b #1
	jsr setActorAnim

	ldy.w #bun.methodIndex
	lda.b #3
	sta (ADTI),y
	
	rts

bunActor_RunUpdate:

	lda.b joy1Input
	cmp.b #1
	bne +

	ldy.w #bun.direction
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

	ldy.w #bun.direction
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
	ldy.w #bun.methodIndex
	lda.b #4
	sta (ADTI),y
	rts

bunActor_skidInit:

	lda.b #2
	jsr setActorAnim

	ldy.w #bun.methodIndex
	lda.b #5
	sta (ADTI),y
	
	rts

bunActor_skidUpdate:

	ldx.w ADTI
	lda.w actor.animIndex,x
	cmp.b #$06
	bne +
	
	ldy.w #bun.methodIndex
	lda.b #0
	sta (ADTI),y

	+
	rts