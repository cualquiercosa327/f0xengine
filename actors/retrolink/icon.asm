iconActor_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$58
	jsr setActorType
	
	ldy.w #sprNews2C
	ldx.w #sprNews2C.size
	lda.b #sprNews2C >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprNews2P
	ldy.w #$0400
	lda.b #sprNews2P >> 16
	jsr allocateSVTEntry
	
	ldx.w #iconTbl
	lda.b #iconTbl >> 16
	jsr renderOAM

	lda.b #0
	jsr setActorAnim
	
	ldx.w #iconActor_Update
	lda.b #iconActor_Update >> 16
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

iconActor_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

    ldx.b ADTI
    lda.b #48
    sta.w actor.tileFlags,x

	ldx.w #iconTbl
	lda.b #iconTbl >> 16
	jsr updateMetaSprites

	ldx.w #iconAnimTable
	lda.b #iconAnimTable >> 16
	jsr processADMAA

	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}