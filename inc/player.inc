macro playerControl() {
	
	stz.w $2102
	stz.w $2103
	ldy.w #$0400
	sty.w $4300
	ldy.w #$0400
	sty.w $4302
	ldy.w #$0220
	sty.w $4305
	lda.b #$7E
	sta.w $4304
	lda.b #$01
	sta.w $420B
	
	lda.b sprX
	sta.w $0400
	lda.b sprY
	sta.w $0401
	lda.b marioX
	sta.w $0404
	lda.b marioY
	sta.w $0405
	lda.b marioFrame
	sta.w $0406
	
	ldx.w bgX
	inx
	stx.w bgX
	lda.w bgX
	sta.w REG_BG1HOFS
	lda.w bgX+1
	sta.w REG_BG1HOFS
	
	lda.b marioX
	adc #$01
	sta.w marioX

}