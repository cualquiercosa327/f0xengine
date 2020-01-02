scope FActor {
	
	macro initActors() {
		
		phb
		
		lda.b #$10
		sta.w actorCount
		ldy.w #$0000
		
		- {
			cmp #$00
			beq +
			ldx.w #nullActor
			stx actorList,y
			iny
			iny
			dec
			bne -
		}
		
		+ {
			plb
		}
		
	}
	
	macro initActor() {
		
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
		
		plb
	
	}
	
	macro createActor() {
		
		phb
		
		lda.b #$00
		ldx.w #$0000
		ldy.w #$0000
		
		- {
			cmp #$10
			beq +
			ldx actorList,y
			cpx.w #nullActor
			beq ++
			iny
			iny
			clc
			adc #$01
			bne -
		}
		
		+ {
			pla
		}
		
		+ {
			ldx.w sprCallback
			stx actorList,y
			tya
			asl
			asl
			adc #$A0
			sta.w actorRes
			sep #$20
			ldy.w #$0001
			lda.w stackActX
			sta [actorRes],y
			iny
			lda.w stackActY
			sta [actorRes],y
			
			lda.b stackActID
			cmp #$00
			beq +
			iny
			sta [actorRes],y
		}
		
		+ {
			stz.w stackActID
			plb
		}
	}
	
	macro removeActor(INDEX) {
		
		rep #$30
		ldy.w {INDEX}
		tya
		asl
		tay
		ldx.w #nullActor
		stx actorList,y
		lda.w #$0000
		tya
		asl
		asl
		tay
		lda.w #$0000
		sta $00A0,y
		sep #$20
		
		removeSprite({INDEX})
	}
	
	macro updateActorProp() {
		
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
		sta.w sprCallback
		lda.w #$0000
		sep #$20
		
		ldy.w #$0001
		lda [actorRes],y
		dey
		sta [sprCallback],y
		
		ldy.w #$0002
		lda [actorRes],y
		dey
		sta [sprCallback],y
		
		plb
	}
	
	macro incActorX(AMOUNT) {
		
		pha
		phy
		
		ldy.w #$0001
		lda [actorRes],y
		adc.b #{AMOUNT}
		sta [actorRes],y
		
		lda [actorRes],y
		dey
		sta [sprCallback],y
		
		ply
		pla
	}
	
	macro decActorX(AMOUNT) {
		
		pha
		phy
		
		ldy.w #$0001
		lda [actorRes],y
		dec #{AMOUNT}
		sta [actorRes],y
		
		lda [actorRes],y
		dey
		sta [sprCallback],y
		
		ply
		pla
	}
	
	macro incActorY(AMOUNT) {
		
		pha
		phy
		
		lda.w actorIndex
		ldy.w #$0002
		asl
		asl
		adc #$A0
		sta.w actorRes
		lda [actorRes],y
		adc.b #{AMOUNT}
		sta [actorRes],y
		
		rep #$30
		ldy.w #$0002
		lda.w actorIndex
		asl
		asl
		adc #$0400
		sta.w sprCallback
		lda [actorRes],y
		dey
		sep #$20
		sta [sprCallback],y
		rep #$30
		lda.w #$0000
		sep #$20
		
		ply
		pla
	}
	
	scope Anim {
		
		macro processAnim(ANIM, ID) {
			
			phb
			
			lda.b #{ID}
			ldy.w #$0004
			cmp [actorRes],y
			jsr checkAnimID
			
			ldy.w #$0003
			lda [actorRes],y
			sta.w currAnim
			asl
			asl
			tax
			
			lda.l {ANIM},x //; Current frame index
			sta.b animFrame
			inx
			
			lda.l {ANIM},x //; Sprite character index number
			ldy.w #$0002
			sta [sprCallback],y
			inx
			
			lda.l {ANIM},x //; Command
			pha
			inx
			lda.l {ANIM},x //; Parameter
			tay
			pla
			
			jsr checkCommand
			
			plb
		}
		
	}

}

macro setActorUpdate(ROUTINE) {
	
	rep #$30
	lda.w actorIndex
	asl
	tay
	lda.w #{ROUTINE}
	sta actorList,y
	lda.w #$0000
	sep #$20
	
}

macro setCurrentLvl(LEVEL) {
	
	rep #$30
	ldx.w #{LEVEL}
	stx.w currentLvl
	lda.w #{LEVEL} >> 16
	sta.b currentLvl+2
	sep #$20
}