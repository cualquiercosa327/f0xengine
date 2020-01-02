
garfActor_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$55
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
	
	ldx.w #garfActor_Update
	lda.b #garfActor_Update >> 16
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

garfActor_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

	ldx.w #garfSprTbl
	lda.b #garfSprTbl >> 16
	jsr updateMetaSprites

    ldx.w ADTI
    lda.b #$30
    sta.w actor.tileFlags,x

	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

emptyActor_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$FF
	jsr setActorType
	
	ldy.w #$0001
	jsr allocateSVTEntry
	
	ldx.w #emptyActor_Update
	lda.b #emptyActor_Update >> 16
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

emptyActor_Update:

    pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue