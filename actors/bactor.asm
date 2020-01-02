BActor:
	pha
	phy
	phx
	
	FActor.initActor()
	setSprite(actorIndex, stackActX, stackActY, 1, 0)
	setActorUpdate(BActor_Update)
	
	plx
	ply
	pla
	
	rts
	
BActor_Update:
	pha
	phy
	phx
	
	sty.w actorIndex
	FActor.incActorY(1)
	
	ldy.w #$0002
	lda [actorRes],y
	cmp #$F0
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