
//; Sprite Palette Table format - starting location: $7E:5400 (end of ADT)
//; each entry consists of two bytes in the table, eight bytes apart
//; 16 bytes total (eight entries, since SNES supports up to eight sprite palettes)
//; this is what the table should look like, in bytes: CC CC CC CC CC CC CC CC || II II II II II II II II
//; CC = total count of allocated entries for the actor, II = actor type/ID
//; in actor initialization, you need to call allocateSPTEntry and pass the size and 24-bit location of the palette

constant MAX_SPR_PALETTE(8)
constant SPR_PT_OFFSET($7E6000)
constant PT_NULL($00)

constant ACTOR_SPT_ID($50)

constant SPT_DUP_FOUND($00)
constant SPT_NO_DUP($01)
	
	//; this should clear the entirety of all SPT entries
	initSPT:
	
		lda.b #PT_NULL
		pha
		sta.l SPR_PT_OFFSET
		
		ldx.w #SPR_PT_OFFSET
		ldy.w #SPR_PT_OFFSET + 1
		lda.b #MAX_SPR_PALETTE * 2 - 2
		
		rep #$30
		pha
		
		mvn $7E=$7E
		
		pla
		plb
		
		sep #$20
		
		rts
		
	allocateSPTEntry:
	
		pha
		phx
		phy
		
		//; switch to actor bank
		lda.b #$7E
		pha
		plb
		
		ldx.w #0
		ldy.w #0
		
		//; store SPT offset into a temporary address
		phy
		ldy.w #SPR_PT_OFFSET
		sty.w tempWord
		ply
		
		//; we're going to keep looping through entries for free space 
		//; if the entry is empty, it's ready for allocation!
		//; otherwise, we check if this entry is already allocated
		//; SPT_DUP_FOUND (zero) is returned and the SPT entry count is incremented if so, SPT_NO_DUP (one) is returned if not
		-
			cpx.w #MAX_SPR_PALETTE
			beq ++
			lda (tempWord),y
			beq +
			
			jsr checkSPTDup
			beq ++
			
			inx
			iny
			bra -
			
		+	
			inc SPR_PT_OFFSET,x
			ldy.w #actor.SPTID		//; actor's SPT ID
			txa
			sta (ADTI),y
			asl #4				//; index * 16
			adc.b #128
			iny
			sta (ADTI),y		//; CGRAM index location
			
			pha
			
			ldy.w #0
			lda (ADTI),y
			pha
			txa
			adc.b #8
			tay
			pla
			sta SPR_PT_OFFSET,y
			
			pla
			
			//; SPT -> DMA -> CGRAM
			
			jsr f_resetADB
			
			sta.w REG_CGADD 	//; SPT -> CGRAM address

			stz.w REG_DMAP1
			lda.b #$22           //; CGRAM write
			sta.w REG_BBAD1 	 //; I/O (CGRAM)
			ply
			sty.w REG_A1T1L 	 //; DMA src (palette data)
			plx
			stx.w REG_DAS1L 	 //; DMA size 
			pla
			sta.w REG_A1B1 		 //; DMA bank

			lda.b #2
			sta.w REG_MDMAEN
			
			rts
			
		+
			ply
			plx
			pla
			
			rts
			
checkSPTDup:

	phx
	phy
	
	sep #$10
	
	ldy.b #actor.id
	ldx.b #0
	lda (ADTI),y
	pha
	
	-
	lda SPR_PT_OFFSET+8,y
	cmp $01,s
	beq +
	inx
	iny
	cpx.b #MAX_SPR_PALETTE
	bne -
	
	rep #$10
	
	pla
	ply
	plx
	
	lda.b #SPT_NO_DUP
	
	rts
	
	+
	
	ldy.b #0
	inc SPR_PT_OFFSET,x
	
	ldy.b #actor.SPTID		//; actor's SPT ID
	txa
	sta (ADTI),y
	asl #4					//; index * 16
	adc.b #128
	iny
	sta (ADTI),y			//; CGRAM index location
	
	rep #$10
	
	pla
	ply
	plx
	
	lda.b #SPT_DUP_FOUND
	
	rts

//; X = BGR15 value
//; returns: 0BGR in XY
BGRToRGB:

	rep #$20
	txa
	txy 				//; transfer BGR to Y for backup
	and.w #$001F		//; grab R
	pha					//; save R to stack
	tya
	and.w #$03E0
	asl #3
	pha					//; grab G and save to stack
	tya
	and.w #$7C00
	xba
	lsr #2
	tax					//; X now contains 0B
	pla
	ora $01,s			//; pull G from stack and OR it with R
	tay					//; XY now contains 0BGR

	pla
	sep #$20			//; fix our stack and restore status

	rts

//; XY = 0BGR
//; returns: BGR15 in X
RGBtoBGR:

	rep #$20
	tya						//; A contains GR
	and.w #$00FF			//;
	pha						//; grab R and push to stack
	tya
	and.w #$FF00
	lsr #3
	ora $01,s				//; grab G, shift into place and OR it with R
	pha						//; push GR to the stack
	txa						//; A has 0B
	xba
	asl #2
	ora $01,s				//; grab 0B, shift, and OR with GR
	tax						//; X now has BGR15

	pla
	pla

	sep #$20

	rts

colorFade:

	jsr fadeRG
	jsr fadeGB
	jsr fadeRB

	rts

fadeRG:

	lda.b $72			//; load R
	cmp.b #1
	bcs +
	rts

	+
	lda.b $70			//; load B
	beq +
	rts

	+
	dec $72				//; R--
	inc $73				//; G++
	
	rts

fadeGB:

	lda.b $73			//; load G
	cmp.b #1
	bcs +
	rts

	+
	lda.b $72			//; load R
	beq +
	rts

	+
	dec $73				//; G--
	inc $70				//; B++
	rts

fadeRB:

	lda.b $70			//; load B
	cmp.b #1
	bcs +
	rts

	+
	lda.b $73			//; load G
	beq +
	rts

	+
	inc $72				//; R++
	dec $70				//; B--
	rts