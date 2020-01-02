decompBlock: {

	phx
	
	ldx.w frle_dest_pos
	ldy.w frle_len
	sta.b frle_byte
	lda.b frle_len
	sta.b frle_dest_i
	inc frle_pos
	
	- {
		ldx.w frle_dest_pos
		lda.b frle_byte
		sta.l FRLE.DEST,x
		inc frle_dest_pos
		dec frle_dest_i
		lda.b frle_dest_i
		cmp.b #$00
		bne -
	}
	
	plx
	rts
}