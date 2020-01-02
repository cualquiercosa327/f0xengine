rH1: {
	cmp #$00
	bne rH2
	lda.b #$01
	bra rDone
}
	
rH2: {
	cmp #$01
	bne rH3
	lda.b #$04
	bra rDone
}
	
rH3: {
	cmp #$02
	bne rH4
	lda.b #$10
	bra rDone
}
	
rH4: {
	lda.b #$40
}
	
rDone: {
	ora $0200,y
	sta $0200,y
	rts
}

calcHigh1: {
	cmp #$00
	bne calcHigh2
	lda.b #$01
	bra finishHigh
}
	
calcHigh2: {
	cmp #$01
	bne calcHigh3
	lda.b #$04
	bra finishHigh
}
	
calcHigh3: {
	cmp #$02
	bne calcHigh4
	lda.b #$10
	bra finishHigh
}
	
calcHigh4: {
	cmp #$02
	lda.b #64
	bra finishHigh
}
	
finishHigh: {
	eor #$FF
	and $0600,y
	sta $0600,y
	rts
}

calcHigh1B: {
	cmp #$00
	bne calcHigh2B
	lda.b #$01
	ldx.w #$02
	bra finishHighB
}
	
calcHigh2B: {
	cmp #$01
	bne calcHigh3B
	lda.b #$04
	ldx.w #$08
	bra finishHighB
}
	
calcHigh3B: {
	cmp #$02
	bne calcHigh4B
	lda.b #$10
	ldx.w #32
	bra finishHighB
}
	
calcHigh4B: {
	cmp #$02
	lda.b #64
	ldx.w #128
	bra finishHighB
}
	
finishHighB: {
	eor #$FF
	and $0600,y
	sta $0600,y
	txa
	ora $0600,y
	sta $0600,y
	rts
}


checkAnimID: {
	
	beq +
	
	sta (ADTI),y
	ldy.w #3
	lda #$00
	sta (ADTI),y
	
	rts
	
	+ {
		rts
	}
}


checkCommand: {
	
	jsr f_setADB
	cmp #$FE
	beq AnimEndCmd
	cmp #$FD
	beq AnimResetCmd
	cmp #$01
	beq AnimSndCmd
	
	lda.w animFrame
	inc
	ldy.w #3
	sta (ADTI),y
	
	rts
}

AnimEndCmd: {
	
	lda #$00
	ldy.w #3
	sta (ADTI),y
	
	rts
}

AnimResetCmd: {
	
	lda #$00
	ldy.w #3
	sta (ADTI),y
	
	rts
}

AnimSndCmd: {

	sty animSnd
	jsr f_resetADB
	GSS.playSound(5, animSnd, 127, 50)
	jsr f_setADB
	lda.w animFrame
	inc
	ldy.w #3
	sta (ADTI),y
	
	rts
	
}