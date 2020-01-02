
constant ARROW_ID_IDLE($00)


dbgCursorActor:
	
	pha
	phy
	phx
	
	jsr f_initActor
	
	ldx.w #0
	ldy.w #0
	jsr f_setSprite
	jsr f_enableSprLarge
	
	ldx.w #dbgCursorActor_Update
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	rts
	
dbgCursorActor_Update:
	
	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actProp
	
	lda.b #1
	ldx.w #anim_arrow
	ldy.w #ARROW_ID_IDLE
	jsr f_processAnim
	
	jsr checkIntroY
	jsr checkIntroX
	
	plx
	ply
	pla
	
	rts
	
dbgCursorActorChoose_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
	FActor.updateActorProp()
	
	FActor.Anim.processAnim(anim_arrow, ARROW_ID_IDLE)
	jsr cursor_InputHandle
	jsr cursor_selectHandle
	
	plx
	ply
	pla
	
	rts

}

checkIntroY: {

	ldy.w #$0002
	lda [actorRes],y
	cmp #$3A
	beq +
	php
	sep #$10 //; X-Y: 8-bit mode
	ldy.b #$05
	lda [actorRes],y
	tax
	lda.l arrowYTable,x
	dey #$03
	sta [actorRes],y
	inx
	txa
	iny #$03
	sta [actorRes],y
	plp
	
	rts
	
	+ {
		
		ldy.w #$0005
		lda.b #$00
		sta [actorRes],y
		iny
		sta [actorRes],y
		setActorUpdate(dbgCursorActorChoose_Update)
		rts
		
	}

}

checkIntroX: {

	ldy.w #$0001
	lda [actorRes],y
	cmp #$3E
	beq +
	php
	sep #$10 //; X-Y: 8-bit mode
	ldy.b #$06
	lda [actorRes],y
	tax
	lda.l arrowXTable,x
	dey #$05
	sta [actorRes],y
	inx
	txa
	iny #$05
	sta [actorRes],y
	plp
	
	rts
	
	+ {
		
		rts
		
	}

//; $0069 = input
//; $006A = input timer
cursor_InputHandle: {

	jsr cursor_IHT
	
	lda.l REG_JOY1H
	sta.w $0069 //; input
	
	lda.w $0069
	cmp #$00
	bne +
	lda.b #$00
	sta.w $006A
	rts
	
	+ {
		inc $006A
		rts
	}
}

//; Input Handle Timer
cursor_IHT: {

	lda.w $006A
	cmp #$A0
	beq +
	rts
	+
	lda.b #$9F
	sta.w $006A
	rts

}

cursor_selectHandle: {

	lda.w $0069
	jsr cBtnDown
	rts
}

cBtnDown: {
	
	pha
	lda.w $006A
	cmp #$01
	bne +
	pla
	cmp #$08
	beq _cbup
	cmp #$04
	beq _cbdown
	cmp #$10
	beq _cbstart
	cmp #$80
	beq _cbB
	-
	rts
	
	_cbdown:
	
	ldy.w #$0002
	lda [actorRes],y
	clc
	adc #$09
	inc $0060
	sta [actorRes],y
	jsl debugMenu_setPrevious
	jsr debugMenu_resetPrevious
	bra -
	
	_cbup:
	
	ldy.w #$0002
	lda [actorRes],y
	clc
	sbc #$08
	dec $0060
	sta [actorRes],y
	jsl debugMenu_setPrevious
	jsr debugMenu_resetPrevious
	bra -
	
	_cbstart:
	
	jsr debugMenu_clearPage
	ldy.w #$0002
	lda.b #$3A
	sta [actorRes],y
	stz.w $0060
	bra -
	
	_cbB:
	
	jsr debugMenu_returnPage
	ldy.w #$0002
	lda.b #$3A
	sta [actorRes],y
	stz.w $0060
	stz.w $006C
	bra -
	
	+
	pla
	rts
	

}