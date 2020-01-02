
constant YANIM_ID_IDLE($00)
constant YANIM_ID_WALK($01)

constant YGRAV_FORCE($01)
constant YVELO_INC_WAIT($05)
constant YVELO_MAX($10)
constant YJUMP_HEIGHT($02)

yoshiActor:
	
	pha
	phy
	phx
	
	FActor.initActor()
	
	lda.b #$FF
	sta.b yoshiJmpVal
	
	setSprite(actorIndex, stackActX, stackActY, 0, 0)
	//setSpriteHighBig(actorIndex)
	setActorUpdate(yoshiActor_Update)
	
	plx
	ply
	pla
	
	rts
	
yoshiActor_Update:
	
	//; Reserve all our main registers to the stack, to avoid tom-fuckery
	pha
	phy
	phx
	
	//; Updates actor and stores the current actor index
	//; These two instructions must be executed for every actor
	sty.w actorIndex
	FActor.updateActorProp()
	//; ----------
	
	//; Main Yoshi actor code
	jsr yoshi_input
	jsr yoshi_checkFloor
	jsr yoshi_stateMachine
	jsr yoshi_checkJump
	
	//; Pull our values from the stack and return
	plx
	ply
	pla
	
	rts
	//;----------
	
yoshi_stateMachine: {

	phb
	
	jsr yoshiGravity
	
	lda [actorRes]
	cmp #$00
	beq yoshi_statusIdle
	cmp #$01
	beq yoshi_statusMove
	
	plb
	rts
}

yoshi_statusIdle: {

	//; Execute Yoshi's idle animation script 
	//FActor.Anim.processAnim(anim_yoshi_idle, YANIM_ID_IDLE)
	plb
	rts
}

yoshi_statusMove: {

	//; Execute Yoshi's walk animation script
	//FActor.Anim.processAnim(anim_yoshi_walk, YANIM_ID_WALK)
	plb
	rts
}

yoshi_input: {
	
	phb
	
	ReadJOY({JOY_RIGHT})
	bne yoshi_moveRight
	ReadJOY({JOY_LEFT})
	bne yoshi_moveLeft
	
	lda #$00
	sta [actorRes]
	
	plb
	rts
}

yoshi_moveRight: {

	FActor.incActorX(1)
	lda #$01
	sta [actorRes]
	ldy.w #$0003
	lda [sprCallback],y
	and #$02
	sta [sprCallback],y
	plb
	rts
}

yoshi_moveLeft: {
	
	FActor.decActorX(1)
	lda #$01
	sta [actorRes]
	ldy.w #$0003
	lda [sprCallback],y
	ora #$40
	sta [sprCallback],y
	plb
	rts

}

yoshi_checkJump: {
	
	//; annonymous + branch when A is pressed
	ReadJOY({JOY_A})
	bne +
	rts
	
	+ {
		
		//; Decrement actor Y and sprite Y by one
		ldy.w #$0002
		lda [actorRes],y
		dec #01
		sta [actorRes],y
		
		lda [actorRes],y
		dey
		sta [sprCallback],y
		//; ---------------
		
		//; Reset jump values (velocity, velocity timer, jump height, gravity bool)
		stz yoshiVeloY
		stz yoshiVeloY+1
		lda.b #YJUMP_HEIGHT
		sta.b yoshiJmpVal
		lda.b #00
		sta.b yoshiGravity
	}
	
	rts
}

yoshiGravity: {
	
	lda.b yVal
	cmp #$01
	beq +
	
	lda.b yoshiVeloY+1
	clc
	adc #$01
	sta.w yoshiVeloY+1
	jsr y_veloTimerCheck
	
	ldy.w #$0002
	lda [actorRes],y
	adc yoshiVeloY
	sta [actorRes],y
	
	lda [actorRes],y
	sbc yoshiJmpVal
	sta [actorRes],y
	
	rts
	
	+ {
		stz yoshiVeloY
		stz yoshiVeloY+1
		rts
	}
}

y_veloTimerCheck: {

	lda.b yoshiVeloY+1
	cmp.b #YVELO_INC_WAIT
	bpl +
	
	lda.b yoshiVeloY
	cmp.b #YVELO_MAX
	bpl ++
	
	rts
	
	+ {
		stz.b yoshiVeloY+1
		lda.b yoshiVeloY
		clc
		adc.b #YGRAV_FORCE
		sta yoshiVeloY
	}
	
	rts
	
	+ {
		lda.b #YVELO_MAX
		sta.b yoshiVeloY
	}
	
	rts
}

yoshi_checkFloor: {
	
	//; Load actor X position and divide by 8, then add 8 (Sprite size)
	ldy.w #$0001
	lda [actorRes],y
	adc #$08
	lsr
	lsr
	lsr
	sta.b yColX //; Store result into temp actor collision X
	
	//; Load actor Y position and divide by 8, multiplied by 32
	ldy.w #$0002
	lda [actorRes],y
	adc #$08
	rep #$30
	and.w #$FFF8
	asl
	asl
	sta.w yColY //; Store result into temp actor collision Y
	
	//; Add both temporary collision values to get correct collision map index
	lda.w yColX
	adc.w yColY
	
	//; Transfer collision index into X
	tax
	lda.w #$0000
	sep #$20
	
	//; Load floor collision value from map
	lda.l nullCol00,x
	sta.b yVal
	
	//; Check wall collision value
	rep #$30
	txa
	sbc.w #$0020 //; Subtract $20 and increment by one to get correct wall index 
	tax
	lda.w #$0000
	sep #$20
	inx
	//; Check wall
	lda.l nullCol00,x
	jsr yoshi_checkWall
	
	
	//; I don't know what the fuck I was doing here
	//; These two checks will soon be relocated 
	lda.b yVal
	cmp #$01
	beq +
	
	lda.b yoshiGravity
	cmp #$01
	beq ++
	
	rts
	
	+ {
		//; Calculate floor slope height from look-up table
		jsr calcSlope
		//; Load actor Y position & by 7 (8x8 tiles) - actor Y - slope height result
		ldy.w #$0002
		lda [actorRes],y
		and #$07
		sta.b sprResult
		lda [actorRes],y
		sbc sprResult
		sbc slopeH
		sta [actorRes],y
		//; ---------------
		
		//; Nullify actor's gravity functionality
		lda.b #01
		sta.b yoshiGravity
		stz yoshiVeloY
		stz yoshiVeloY+1
		lda.b #$FF
		sta.b yoshiJmpVal
		lda.b #00
		sta.b yoshiGravity
	}
	
	rts
	
	+ {
		lda.b yVal
		cmp #$00
		bne +
		stz yoshiVeloY
		stz yoshiVeloY+1
		lda.b #$FF
		sta.b yoshiJmpVal
		lda.b #00
		sta.b yoshiGravity
	}
	rts
}

yoshi_checkWall: {

	cmp #$01
	beq +
	rts
	
	+ {
		//; Decrement actor X when stuck in right wall
		ldy.w #$0001
		lda [actorRes],y
		dec
		sta [actorRes],y
		rts
	}

}

//; Note for F0x: FINISH THIS YOU FUCK
calcSlope: {

	rts

}