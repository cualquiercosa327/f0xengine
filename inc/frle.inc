scope FRLE {

	constant DEST($7F0000)
	
	macro decompress(SRC, SIZE) {
		
		phb
		phx
		pha
		ldx.w #$0000
		rep #$30
		lda.w #$0000
		sep #$20
		
		- {
			ldx.b frle_pos
			lda.l {SRC},x
			sta.b frle_len
			inc frle_pos
			ldx.w frle_pos
			lda.l {SRC},x
			jsr decompBlock
			lda.b #{SIZE}
			cmp frle_pos
			bne -
		}
		
		pla
		plx
		plb
		
	}
	
}