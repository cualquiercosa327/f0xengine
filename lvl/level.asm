plotLevel: {
	
	lda.w currentLvl+2
	cmp #$00
	beq +
	
	lda [currentLvl] // Object count
	ldy.w #$0000
	
	- {
		iny
		pha
		lda [currentLvl],y
		sta.w stackActID
		iny
		lda [currentLvl],y
		sta.w stackActX
		iny
		lda [currentLvl],y
		sta.w stackActY
		pla
		pha
		phx
		phy
		jsr setActFromLvl
		ply
		plx
		pla
		clc
		dec
		cmp #$00
		bne -
	}
	
	+ {
		rts
	}
}

setActFromLvl: {
	
	lda.w stackActID
	asl
	rep #$30
	tax
	lda.l actorLUT,x
	sta.w sprCallback
	lda.w #$0000
	sep #$20
	FActor.createActor()
	rts