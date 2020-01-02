rooActor: {

	pha
	phy
	phx
	
	FActor.initActor()
	
	setSprite(actorIndex, stackActX, stackActY, 0, 0)
	setSpriteHighBig(actorIndex)
	setActorUpdate(rooActor_Update)
	
	plx
	ply
	pla
	
	rts

}


rooActor_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
	FActor.updateActorProp()
	
	jsr roo_checkBG
	
	plx
	ply
	pla
	
	rts

}

roo_checkBG: {
	
	ldy.w #1
	lda [actorRes],y
	cmp #$58
	bpl +
	
	clc
	adc #$01
	sta [actorRes],y
	
	rts
	
	+
	
	lda.b $53
	cmp #$07
	beq +
	ldx.w $0050
	inx
	stx.w $0050
	
	+
	
	rts

}