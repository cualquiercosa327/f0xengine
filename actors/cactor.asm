CActor:
	
	pha
	phy
	phx
	
	FActor.initActor()
	setSprite(actorIndex, stackActX, stackActY, 2, 0)
	setActorUpdate(CActor_Update)
	
	plx
	ply
	pla
	
	rts
	
CActor_Update:
	
	pha
	phy
	phx
	
	sty.w actorIndex
	
	FActor.incActorY(1)
	FActor.incActorX(1)
	
	ldy.w #$0001
	lda [actorRes],y
	cmp #$FF
	beq +
	
	plx
	ply
	pla
	
	rts
	
	+ {
		FActor.removeActor(actorIndex)
		plx
		ply
		pla
		rts
	}