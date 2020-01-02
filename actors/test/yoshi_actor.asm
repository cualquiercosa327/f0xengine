
constant YANIM_IDLE($00)
constant YANIM_WALK($01)

constant Y_WALK_SPEED(45)
constant Y_WALK_ACCEL(4)
constant Y_WALK_DECEL(8)

constant Y_FALL_SPEED(30)
constant Y_FALL_ACCEL(2)
constant Y_JUMP_HEIGHT(256-2)

constant yoshi.id($00)
constant yoshi.x($01)
constant yoshi.y($02)
constant yoshi.velocity.x($05)
constant yoshi.velocity.y($06)
constant yoshi.isAirborne($07)
constant yoshi.col.x($08)
constant yoshi.col.y($09)
constant yoshi.col($0A)

yoshiActor_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #ACT_TYPE_YOSHI
	jsr setActorType
	
	ldy.w #sprYoshiP
	ldx.w #sprYoshiP.size
	lda.b #3
	jsr allocateSPTEntry
	
	ldx.w #sprYoshiT
	ldy.w #sprYoshiT.size
	lda.b #3
	jsr allocateSVTEntry
	
	ldx.w #yoshiSprTable
	lda.b #3
	jsr renderOAM
	
	ldx.w #yoshiActor_Update
	jsr f_setActorUpdate
	
	phb
	lda.b #$7E
	pha
	plb
	
	ldy.w #1
	lda (ADTI),y
	sta.b $70
	
	ldy.w #2
	lda (ADTI),y
	sta.b $72
	
	plb
	
	plx
	ply
	pla
	
	rts
}

yoshiActor_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
	
	//jsr yoshi_inputHandle
	
	jsr f_setADB
	
	
	ldy.w #actor.x
	lda.b $71
	tax
	lda yoshiSineX,x
	clc
	adc.b $70
	sta (ADTI),y
	
	ldy.w #actor.y
	lda.b $71
	tax
	lda yoshiSineY,x
	clc
	adc.b $72
	sta (ADTI),y
	
	inc $71
	
	ldx.w #yoshiSprTable
	lda.b #3
	jsr updateMetaSprites
	
	//jsr yoshi_jumpHandle
	
	jsr f_resetADB
	
	plx
	ply
	pla
	
	rts
}

yoshi_inputHandle: {
	
	phb
	
	ReadJOY({JOY_RIGHT})
	bne ++
	ReadJOY({JOY_LEFT})
	bne ++
	ReadJOY({JOY_A})
	bne +
	+
	
	ldy.w #yoshi.velocity.y
	lda.b #0
	sta (ADTI),y
	
	lda.b #1
	ldx.w #anim_yoshi_idle
	ldy.w #YANIM_IDLE
	//jsr f_processAnimDP
	
	+
	jsr yoshi_moveControl
	
	plb
	rts

}

yoshi_moveControl: {

	jsr f_resetADB
	ReadJOY({JOY_RIGHT})
	beq yoshi_notRight
	
	ldy.w #3
	lda (sprResult),y
	and #$02
	sta (sprResult),y
	
	jsr f_setADB
	
	lda.b #1
	ldx.w #anim_yoshi_walk
	ldy.w #YANIM_WALK
	jsr f_processAnimDP
	
	ldy.w #yoshi.velocity.x
	lda (ADTI),y
	bmi yoshi_notRight
	
	jsr f_resetADB
	
	jsr f_setADB
	
	ldy.w #yoshi.velocity.x
	lda (ADTI),y
	clc
	adc.b #Y_WALK_ACCEL
	cmp.b #Y_WALK_SPEED
	bcc +
	
	lda.b #Y_WALK_SPEED
	
	+
	
	sta (ADTI),y
	
	jsr f_resetADB
	
	jmp yoshi_doneRight
	
	yoshi_notRight:
	
		jsr f_setADB
		ldy.w #yoshi.velocity.x
		lda (ADTI),y
		bmi yoshi_doneRight
		cmp.b #Y_WALK_DECEL
		bcs yoshi_notRightStop
		lda.b #Y_WALK_DECEL+1
		
	yoshi_notRightStop:
	
		sbc.b #Y_WALK_DECEL
		sta (ADTI),y
		
	yoshi_doneRight:
		
		jsr f_resetADB
		ReadJOY({JOY_LEFT})
		beq yoshi_notLeft
		jsr f_setADB
		
		ldy.w #3
		lda (sprResult),y
		ora #$40
		sta (sprResult),y
		
		ldy.w #yoshi.velocity.x
		lda (ADTI),y
		beq yoshi_isLeft
		bpl yoshi_notLeft
		
	yoshi_isLeft:
	
		sec
		sbc.b #Y_WALK_ACCEL
		cmp.b #256-Y_WALK_SPEED
		bcs +
		lda.b #256-Y_WALK_SPEED
		+
		sta (ADTI),y
		
		lda.b #1
		ldx.w #anim_yoshi_walk
		ldy.w #YANIM_WALK
		jsr f_processAnimDP
		
		jmp yoshi_doneLeft
		
	yoshi_notLeft:
	
		jsr f_setADB
		
		ldy.w #yoshi.velocity.x
		lda (ADTI),y
		bpl yoshi_doneLeft
		cmp.b #256-Y_WALK_DECEL
		bcc yoshi_notLeftStop
		lda.b #256-Y_WALK_DECEL
		
  yoshi_notLeftStop:
		
		adc.b #8-1
		sta (ADTI),y
  
  yoshi_doneLeft:
	
		ldy.w #yoshi.velocity.x
		lda (ADTI),y
		bpl yoshi_velo_pos
		
		eor.b #$FF
		lsr #4
		sta.b tempByte
		ldy.w #1
		lda (ADTI),y
		sec
		sbc.b tempByte
		sta (ADTI),y
		rts
		
		
  yoshi_velo_pos:
	
		
		ldy.w #5
		lsr #4
		clc
		ldy.w #1
		adc (ADTI),y
		sta (ADTI),y
		rts
}

yoshi_jumpHandle: {

	sep #$10
	
	ldy.b #yoshi.isAirborne
	lda (ADTI),y
	beq yoshi_doGravity
	
	rep #$10
	rts
	
	yoshi_doGravity:
	
		ldy.b #yoshi.velocity.y
		lda (ADTI),y
		bmi yoshi_isJumping		//; is velocity negative?
		
	yoshi_isFalling:
	
		clc
		adc.b #Y_FALL_ACCEL
		cmp.b #Y_FALL_SPEED
		bcc +
			lda.b #Y_FALL_SPEED
		+
		sta (ADTI),y
		ldy.b #yoshi.y
		lsr #3
		adc (ADTI),y
		sta (ADTI),y
		rep #$10
		rts
		
	yoshi_isJumping:
		
		rep #$10
		rts

}

yoshi_checkFloor: {
	
	sep #$10
	
	//; Load actor X position and divide by 8, then add 32 (Sprite size)
	ldy.b #yoshi.x
	lda (ADTI),y
	adc.b #32
	lsr
	lsr
	lsr
	ldy.b #yoshi.col.x
	phy
	sta (ADTI),y //; Store result into actor collision X
	
	//; Load actor Y position and divide by 8, multiplied by 32
	ldy.b #yoshi.y
	lda (ADTI),y
	adc.b #32
	rep #$30
	and.w #$FFF8
	asl
	asl
	ldy.b #yoshi.col.y
	sta (ADTI),y //; Store result into temp actor collision Y
	
	//; Add both temporary collision values to get correct collision map index
	ply
	adc (ADTI),y
	
	//; Transfer collision index into X
	rep #$10
	tax
	and.w #255
	sep #$20
	
	ldy.w #yoshi.col
	//; Load floor collision value from map
	lda.l nullCol00,x
	sta (ADTI),y
	
	//; Calculate floor slope height from look-up table
	//; NOT IMPLEMENTED FUCKER
	//;jsr calcSlope
	
	//; Load actor Y position & by 7 (8x8 tiles) - actor Y - slope height result
	ldy.w #yoshi.y
	lda (ADTI),y
	and.b #$1F
	sta.b tempWord
	lda (ADTI),y
	sbc.b tempWord
	//sbc slopeH
	sta (ADTI),y
	
	rts
}