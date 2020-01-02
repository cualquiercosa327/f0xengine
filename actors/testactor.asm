testActor:
	
	pha
	phy
	phx
	
	FActor.initActor()
	setSprite(actorIndex, stackActX, stackActY, 0, 0)
	setActorUpdate(testActor_Update)
	
	plx
	ply
	pla
	
	rts
	
testActor_Update:
	
	pha
	phy
	phx
	
	sty.w actorIndex
	FActor.updateActorProp()
	
	
	
	plx
	ply
	pla
	
	rts