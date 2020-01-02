
playSFX: {
	
	pha
	
	lda.b $80
	cmp $01,s
	beq +
	
	pla 
	
	sta.w $2141
	sta.b $80
	
	rts
	
	+
	
	eor.b #$C0
	sta.w $2141
	sta.b $80
	
	pla
	
	rts
}