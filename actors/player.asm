playerActor: {
	
	pha
	
	sty.w actorIndex
	tya
	asl
	clc
	adc #$A0
	sta.w actorRes
	lda [actorRes]
	cmp #$01
	bne +
	bra playerActor_Update
	
	+ {
		lda.b #$01
		sta [actorRes]
		// Init functions here
		rts
	}
}

playerActor_Update: {
	pla
}