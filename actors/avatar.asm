avatarActor:
	
	pha
	phy
	phx
	
	jsr f_initActor
	
	ldx.w #$0028
	ldy.w #$0010
	jsr f_setSprite
	jsr f_enableSprLarge
	
	ldx.w #avatarActor_Update
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	rts
	
avatarActor_Update:
	
	pha
	phy
	phx
	
	sty.w actorIndex
	
	plx
	ply
	pla
	
	rts