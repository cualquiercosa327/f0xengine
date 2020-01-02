
constant ACTOR_LOC($5000)
constant ACTOR_SIZE(128)
constant ACTOR_MAX(64)
constant SPR_PALETTE_INDEX(60)

//; Common actor structure
constant actor.id($00)
constant actor.x($01)
constant actor.y($03)
constant actor.tileFlags($05)
constant actor.SPTID($2E)
constant actor.vramAddr($30)
constant actor.charAddr($32)
constant actor.oamIndex($34)
constant actor.metaCount($35)
constant actor.currAnim($36)
constant actor.animIndex($37)
constant actor.animDelay($38)
constant actor.index($5F)
constant actor.parent($60)
constant actor.child($62)

constant ACT_TYPE_YOSHI($90)
constant ACT_TYPE_LETTER($07)
constant ACT_TYPE_TIC($03)
constant ACT_TYPE_ARROW($04)
constant ACT_TYPE_NULL($FF)

constant CHILD_0($00)

constant NO_ARGS($00)

f_initActors: {

	ldx.w #0
	
	- {
		cpx.w #ACTOR_MAX*3
		beq +
		rep #$20
		lda.w #nullActor
		sta.w actorList,x
		lda.w #nullActor >> 16
		sep #$20
		sta.w actorList+2,x
		inx
		inx
		inx
		bra -
	}
	
	+ {
		rts
	}

}



f_initActor: {

	phb
		
	sty.w actorIndex
	tya
	asl
	asl
	asl
	clc
	adc #$A0
	sta.w actorRes
	
	lda.b #$00
	sta [actorRes]
	ldy.w #$0001
	lda [actorRes],y
	sta.w stackActX
	iny
	lda [actorRes],y
	sta.w stackActY
	
	rep #$30
	lda.w actorIndex
	asl
	asl
	adc.w #$0400
	sta.w sprResult
	and.w #$00FF
	sep #$20
		
	plb
	rts

}

//; A = type
setActorType: {

	jsr f_setADB
	
	ldy.w #0
	sta (ADTI),y
	
	jsr f_resetADB
	
	rts

}

f_initActorDP: {

	//; Setup direct-page for actor entry
	//; chunk starts at $7E:5000
	rep #$30
	sty.w actorIndex
	tya
	asl #7
	adc.w #$5000
	sta.w ADTI
	
	lda.w actorIndex
	asl
	asl
	adc.w #$0400
	sta.w sprResult
	
	and.w #$FF
	sep #$20
	
	rts

}

f_createActor: {

	phb
	
	lda.b #$00
	ldx.w #$0000
	ldy.w #$0000
	
	- {
		cmp #$10
		beq +			//; Too many actors. Bail
		ldx actorList,y
		cpx.w #nullActor
		beq ++			//; We have space for it
		iny
		iny
		clc
		adc #$01
		bne -			//; Occupied. Go to next pointer
	}
		
	+ {
		brk #0			//; Throw "Too many allocated actors!!" exception
						//; No return, reset required
	}
		
	+ {
		ldx.w sprCallback
		stx actorList,y		//; Store pointer in APT
		tya
		asl
		asl
		adc #$A0
		sta.w actorRes		//; Get actor index with ADT location
		
		sep #$20
		
		ldy.w #1			//\
		lda.w stackActX		//|
		sta [actorRes],y	//|
		iny					//|
		lda.w stackActY		//|; Store inital X and Y coords into ADT
		sta [actorRes],y	//|; Also checks if third arg is zero
							//|; if not, store into ADT
		lda.b stackActID	//|; else, ignore and move on
		cmp #$00			//|
		beq +				//|
		iny					//|
		sta [actorRes],y	///
	}
		
	+ {
		stz.w stackActID
		plb
		rts
	}
}

createActor: {

	phb
	
	stx.w tempLong
	sta.b tempLong+2
	
	lda.b #$00
	ldx.w #$0000
	ldy.w #$0000
	
	- {
		cmp #$10
		beq +			//; Too many actors. Bail
		ldx actorList,y
		cpx.w #nullActor
		beq ++			//; We have space for it
		iny
		iny
		clc
		adc #$01
		bne -			//; Occupied. Go to next pointer
	}
		
	+ {
		brk #0			//; Throw "Too many allocated actors!!" exception
						//; No return, reset required
	}
		
	+ {
		rep #$30
		
		lda [tempLong]
		sta actorList,y		//; Store pointer in APT
		
		inc tempLong; inc tempLong
		
		tya
		lsr
		asl #6
		adc.w #$5000
		sta.w ADTI		//; Get actor index with ADT location
		
		sep #$20
		
		lda.b #$7E
		pha
		plb
		
		ldy.w #1			//\
		lda [tempLong]		//|
		sta (ADTI),y		//|
		
		iny					//|
		inc tempLong 
		inc tempLong
		
		lda [tempLong]		//|; Store inital X and Y coords into ADT
		sta (ADTI),y		//|; Also checks if third arg is zero
							//|; if not, store into ADT
		inc tempLong		//|; else, ignore and move on
		inc tempLong
		
		lda [tempLong]
		beq +
		
		rts					//; future not yet implemented
		
	}
		
	+ {
		plb
		rts
	}
}

//; AX = bank | address of actor
//; Y = X and Y position
createActorDirect: {

	phb
	phy
	
	stx.w tempLong
	sta.b tempLong+2
	
	lda.b #$00
	ldx.w #$0000
	ldy.w #$0000
	
	- {
		cpx.w #ACTOR_MAX
		beq +			//; Too many actors. Bail
		rep #$30
		lda actorList,y
		cmp.w #nullActor
		beq ++			//; We have space for it
		-
		sep #$20
		iny
		iny
		iny
		inx
		bne --			//; Occupied. Go to next pointer
	}
		
	+ {
		brk #0			//; Throw "Too many allocated actors!!" exception
						//; No return, reset required
	}
		
	+ {
		sep #$20
		lda actorList+2,y
		bne -
		
		stx.b tempWord		//; save index

		tax
		rep #$20
		
		lda.b tempLong
		sta actorList,y		//; Store pointer in APT
		sep #$20
		txa
		sta actorList+2,y

		rep #$20
		
		lda.b tempWord
		asl #7
		adc.w #$5000
		sta.w ADTI		//; Get actor index with ADT location
		
		sep #$20
		
		lda.b #$7E
		pha
		plb
		
		//; A = X and Y position
		ply
		rep #$30
		tya
		sep #$20
		ldx.b ADTI

		sta.w actor.y,x		//; store positions to actor 
		xba
		sta.w actor.x,x

		tdc
		lda.b actorArgs
		beq ++

		tay
		pla
		sta.b tempByte //; save bank
		rep #$30
		pla			//; save RA
		sta.b tempWord
		-
		cpy.w #0
		beq +
		pla
		dey
		sta.w 8,x
		inx
		inx
		bra -

		+
		sep #$20

		lda.b tempByte
		pha
		plb				//; restore bank
		
		stz.b actorArgs
		ldx.b tempWord
		phx				//; restore RA
		rts

		+
		plb
		rts
	}
}

//; AX = bank | address of actor
//; Y = X and Y position
spawnActor: {

	phb
	phy
	
	stx.w tempLong
	sta.b tempLong+2
	
	lda.b #$00
	ldx.w #$0000
	ldy.w #$0000
	
	- {
		cpx.w #ACTOR_MAX
		beq +			//; Too many actors. Bail
		rep #$30
		lda actorList,y
		cmp.w #nullActor
		beq ++			//; We have space for it
		-
		sep #$20
		iny
		iny
		iny
		inx
		bne --			//; Occupied. Go to next pointer
	}
		
	+ {
		brk #0			//; Throw "Too many allocated actors!!" exception
						//; No return, reset required
	}
		
	+ {
		sep #$20
		lda actorList+2,y
		bne -
		
		stx.b tempWord		//; save index

		tax
		rep #$20
		
		lda.b tempLong
		sta actorList,y		//; Store pointer in APT
		sep #$20
		txa
		sta actorList+2,y

		rep #$20
		
		lda.b tempWord
		asl #7
		adc.w #$5000
		//;sta.w ADTI		Get actor index with ADT location
		sta.w tempLong
		
		sep #$20
		
		lda.b #$7E
		pha
		plb
		
		//; A = X and Y position
		ply
		rep #$30
		tya
		sep #$20
		ldx.b tempLong

		sta.w actor.y,x		//; store positions to actor 
		xba
		sta.w actor.x,x

		tdc
		lda.b actorArgs
		beq ++

		tay
		pla
		sta.b tempByte //; save bank
		rep #$30
		pla			//; save RA
		sta.b tempWord
		-
		cpy.w #0
		beq +
		pla
		dey
		sta.w 8,x
		inx
		inx
		bra -

		+
		sep #$20

		lda.b tempByte
		pha
		plb				//; restore bank
		
		stz.b actorArgs
		ldx.b tempWord
		phx				//; restore RA
		rts

		+
		plb
		rts
	}
}

//; A 16-bit
//; AX = child index | bank | address of actor
//; Y = X and Y position
createChild: {

	sep #$20
	
	phb
	phy
	
	stx.w tempLong
	sta.b tempLong+2
	xba
	sta.b trash
	stz.b trash+1
	
	lda.b #$00
	ldx.w #$0000
	ldy.w #$0000
	
	- {
		cpx.w #ACTOR_MAX
		beq +			//; Too many actors. Bail
		rep #$30
		lda actorList,y
		cmp.w #nullActor
		beq ++			//; We have space for it
		-
		sep #$20
		iny
		iny
		iny
		inx
		bne --			//; Occupied. Go to next pointer
	}
		
	+ {
		brk #0			//; Throw "Too many allocated actors!!" exception
						//; No return, reset required
	}
		
	+ {
		sep #$20
		lda actorList+2,y
		bne -
		
		stx.b tempWord		//; save index

		tax
		rep #$20
		
		lda.b tempLong
		sta actorList,y		//; Store pointer in APT
		sep #$20
		txa
		sta actorList+2,y

		rep #$20
		
		lda.b tempWord
		asl #7
		adc.w #$5000
		//;sta.w ADTI		Get actor index with ADT location
		sta.w tempLong
		
		//; calculate child index
		lda.b trash
		asl
		clc
		adc.b ADTI
		tax

		//; store child pointer in parent
		lda.b tempLong
		sta.w actor.child,x
		
		//; store parent pointer in child
		tax
		lda.b ADTI
		sta.w actor.parent,x

		//; store child APT index in child
		sep #$20
		lda.b tempWord
		sta.w actor.index,x
		
		lda.b #$7E
		pha
		plb
		
		//; A = X and Y position
		ply
		rep #$30
		tya
		sep #$20
		ldx.b tempLong

		sta.w actor.y,x		//; store positions to actor 
		xba
		sta.w actor.x,x

		tdc
		lda.b actorArgs
		beq ++

		tay
		pla
		sta.b tempByte //; save bank
		rep #$30
		pla			//; save RA
		sta.b tempWord
		-
		cpy.w #0
		beq +
		pla
		dey
		sta.w 8,x
		inx
		inx
		bra -

		+
		sep #$20

		lda.b tempByte
		pha
		plb				//; restore bank
		
		stz.b actorArgs
		ldx.b tempWord
		phx				//; restore RA
		rts

		+
		plb
		rts
	}
}

destroyActor: {
	
	//; clear out sprite table
	//; =====================
	rep #$30
	
	ldy.w #actor.oamIndex
	lda (ADTI),y
	sta.b tempWord		//; tempWord = index, tempWord+1 = size
	and.w #$00FF
	tax
	sep #$30

	lda.b #0
	ldy.b #0
	-
	sta.w ST_LOC,x
	inx
	iny
	cpy.b tempWord+1
	bne -
	//; =======================

	//; clear out SVT (please monitor CPU usage, like fuck)
	//; ========================
	ldy.b #actor.id
	lda (ADTI),y
	sta.b tempByte

	ldx.b #0
	
	-
	lda.w SVT_LOC,x
	inx #5		//; SVT entry size
	cmp.b tempByte
	bne -

	dex #2		//; SVT actor count
	lda.w SVT_LOC,x
	dec
	beq +		//; no duplicate entries
	
	sta.w SVT_LOC,x
	bra ++

	+

	stz SVT_LOC,x
	dex
	stz SVT_LOC,x
	dex
	stz SVT_LOC,x
	dex
	stz SVT_LOC,x

	+
	//;===============================

	//; clear SPT entry
	//; ==============================

	ldx.b #0
	-
	lda.w SPR_PT_OFFSET+8,x
	inx
	cmp.b tempByte
	bne -

	dex
	lda.w SPR_PT_OFFSET,x
	dec
	sta.w SPR_PT_OFFSET,x
	beq +				//; is more than one entry allocated?

	bra ++				//; if so then exit

	+
	//; otherwise clear type (count should already be cleared)
	stz.w SPR_PT_OFFSET+8,x

	+
	//;===============================

	//; remove OAMT entry
	rep #$10
	lda.b #0
	-
	pha
	lda.b #MAX_ST_ENTRIES-1
	sec
	sbc.b tempWord
	pha
	lsr
	lsr
	tay
	pla
	and.b #3
	asl
	tax

	lda oamHighTable,x
	ora OAM_HIGH,y
	sta OAM_HIGH,y

	pla
	inc tempWord
	inc
	cmp.b tempWord+1
	bne -

	//;==================================

	rep #$30
	lda.b APTI
	clc
	adc.w #$0100
	tax
	lda.w #nullActor
	sta.w $00,x
	tdc
	sep #$20
	sta.w $02,x
	

	ldx.w ADTI
	jsr memcpybDyn

	sep #$20
	rep #$10

	rts
}

//; A = child index
//; can only be called in parent
destroyChild: {
	
	//; store child ADTI pointer (clears it too) and its APT index into temp memory
	rep #$20
	and.w #$00FF
	asl
	clc
	adc.b ADTI
	tax
	lda.w actor.child,x
	sta.w tempLong
	stz.w actor.child,x
	tax
	sep #$20
	lda.w actor.index,x
	sta.b tempLong+2
	
	//; clear out sprite table
	//; =====================
	rep #$30
	
	ldy.w #actor.oamIndex
	lda (tempLong),y
	sta.b tempWord		//; tempWord = index, tempWord+1 = size
	and.w #$00FF
	tax
	sep #$30

	lda.b #0
	ldy.b #0
	-
	sta.w ST_LOC,x
	inx
	iny
	cpy.b tempWord+1
	bne -
	//; =======================

	//; clear out SVT (please monitor CPU usage, like fuck)
	//; ========================
	ldy.b #actor.id
	lda (tempLong),y
	sta.b tempByte

	ldx.b #0
	
	-
	lda.w SVT_LOC,x
	inx #5		//; SVT entry size
	cmp.b tempByte
	bne -

	dex #2		//; SVT actor count
	lda.w SVT_LOC,x
	dec
	beq +		//; no duplicate entries
	
	sta.w SVT_LOC,x
	bra ++

	+

	stz SVT_LOC,x
	dex
	stz SVT_LOC,x
	dex
	stz SVT_LOC,x
	dex
	stz SVT_LOC,x

	+
	//;===============================

	//; clear SPT entry
	//; ==============================

	ldx.b #0
	-
	lda.w SPR_PT_OFFSET+8,x
	inx
	cmp.b tempByte
	bne -

	dex
	lda.w SPR_PT_OFFSET,x
	dec
	sta.w SPR_PT_OFFSET,x
	beq +				//; is more than one entry allocated?

	bra ++				//; if so then exit

	+
	//; otherwise clear type (count should already be cleared)
	stz.w SPR_PT_OFFSET+8,x

	+
	//;===============================

	//; remove OAMT entry
	rep #$10
	lda.b #0
	-
	pha
	lda.b #MAX_ST_ENTRIES-1
	sec
	sbc.b tempWord
	pha
	lsr
	lsr
	tay
	pla
	and.b #3
	asl
	tax

	lda oamHighTable,x
	ora OAM_HIGH,y
	sta OAM_HIGH,y

	pla
	inc tempWord
	inc
	cmp.b tempWord+1
	bne -

	//;==================================

	jsr f_resetADB
	sep #$30
	lda.b tempLong+2
	ldx.b #3
	mulu(a,x,a)
	jsr f_setADB
	rep #$30
	clc
	adc.w #$0100
	tax
	lda.w #nullActor
	sta.w $00,x
	tdc
	sep #$20
	sta.w $02,x
	

	ldx.w tempLong
	jsr memcpybDyn

	sep #$20
	rep #$10

	rts
}

f_actProp: {
	
	phb
	
	lda.w actorIndex
	asl
	asl
	asl
	adc #$A0
	sta.w actorRes
	
	rep #$30
	lda.w actorIndex
	asl
	asl
	adc #$0400
	sta.w sprResult
	lda.w #$0000
	sep #$20
		
	ldy.w #$0001
	lda [actorRes],y
	dey
	sta [sprResult],y
		
	ldy.w #$0002
	lda [actorRes],y
	dey
	sta [sprResult],y
	
	plb
	rts
}

f_actPropDP: {

	stx.b APTI
	sty.b actorIndex
	
	rep #$30
	pha
	
	lda.w actorIndex
	asl #7
	adc #$5000
	sta.w ADTI
	
	pla
	sep #$20
	
	rts

}

f_actorResDB: {

	pha
	lda.b #0
	tcd
	pha
	plb
	pla
	rts

}

f_actorSetDB: {

	pha
	lda.b #$7E
	pha
	plb
	rep #$30
	lda.w ADTI
	tcd
	and.w #$FF
	sep #$20
	pla
	rts

}

setActorAnim:

	phb
	pha
	
	lda.b #$7E
	pha
	plb

	ldy.w #actor.currAnim
	pla
	sta (ADTI),y

	iny
	lda.b #0
	sta (ADTI),y
	iny
	sta (ADTI),y
	
	plb
	
	rts
processADMAA:
	
	phb
	
	stx.b tempLong
	
	a16
	pha
	
	ldy.w #actor.currAnim
	lda (ADTI),y
	and.w #$00FF
	asl #2
	clc
	adc.b tempLong
	sta.b tempLong
	
	pla
	a8
	
	sta.b tempLong+2
	
	ai16
	lda [tempLong]
	tax
		
	a8
		
	inc tempLong
	inc tempLong
	lda [tempLong]
	stx.b tempLong
	sta.b tempLong+2
	
	lda [tempLong]
	sta.b tempByte
	
	ldy.w #actor.animIndex
	lda (ADTI),y
	bne +
	
		inc
		sta (ADTI),y
		
		plb
		rts
	
	+
	
	asl #2		//; A = current frame * 4
	
	rep #$20
	and.w #$00FF
	clc
	adc.b tempLong
	sta.b tempLong
	
	sep #$20
	
	iny
	lda [tempLong]
	inc tempLong
	cmp (ADTI),y
	beq +
	
	clc
	lda (ADTI),y
	inc					//; where speed would go
	sta (ADTI),y
	
	plb
	
	rts
	
	+
	
	rep #$20
	
	ldy.w #actor.vramAddr
	lda (ADTI),y
	lsr
	tax
	
	lda [tempLong]
	tay
	
	sep #$20
	
	lda.b #0
	pha
	plb
	
	lda.b #$80         
	sta.w dmaTemp+dmaMode

	sty.b tempWord
	ldy.w #$0300
	sty.w dmaTemp+dmaSize

	inc tempLong
	inc tempLong
	lda [tempLong]
	sta.w dmaTemp+dmaSrc+2
	//;pha						push high src
	
	ldy.b tempWord
	//;phy						push low-mid src
	sty.w dmaTemp+dmaSrc
	
	stx.w dmaTemp+dmaDest
	//;phx						push dest

	jsr addDMAQueue

	//;lda.b #$01
	//;sta.w REG_DMAP1
	//;lda.b #$18
	//;sta.w REG_BBAD1

	//;lda.b #$02
	//;sta.w REG_MDMAEN
	
	plb
	
	ldy.w #actor.animIndex
	lda (ADTI),y
	cmp.b tempByte					//; frame limit
	bne +
	lda.b #$FF
	+
	inc
	sta (ADTI),y
	
	iny
	lda.b #0
	sta (ADTI),y
	
	rts

f_setADB: {
	
	pha
	lda.b #$7E
	pha
	plb
	pla
	rts
}

f_resetADB: {
	
	pha
	lda.b #0
	pha
	plb
	pla
	rts

}

//; AX = Update routine
f_setActorUpdate: {

	pha
	phx
	sep #$10
	lda.b actorIndex
	ldx.b #3
	mulu(a,x,a)
	rep #$30
	and.w #$FF
	tay
	pla
	sta actorList,y
	sep #$20
	pla
	sta actorList+2,y
	
	rts

}

macro defineActor(PTR, X, Y, ARGS) {

	dw {PTR}
	dw {X}
	dw {Y}
	db {ARGS}

}