
bootTextActor_Init:
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	ldx.w #0
	ldy.w #0
	jsr f_setSprite
	jsr f_enableSprLarge
	
	//sta.w $0100
	
	lda.b #$7E
	ldx.w ADTI
	pha
	plb
	phx
	phx
	pld
	
	sta.w $0100
	ldy.w #3
	lda ($01,s),y
	tax
	lda.l textTable,x
	dey
	jsr bootTextActor_resDB
	sta (sprResult),y
	jsr bootTextActor_setDB
	iny
	lda.l moveTable,x
	sta ($01,s),y
	
	ldx.w #bootTextActor_Update
	jsr f_setActorUpdate
	
	lda.b #0
	ldx.w #0
	txa
	tcd
	pha
	plb
	
	plx
	plx
	ply
	pla
	
	rts
	
bootTextActor_Update:
	
	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
	
	ldx.w ADTI
	lda.b #$7E
	phx
	pld
	phx
	pha
	plb
	
	ldy.w #3
	lda ($01,s),y
	tax
	dec
	sta ($01,s),y
	iny
	lda.l bootTxt_sine_x,x
	adc #$40
	adc ($01,s),y
	ldy.w #1
	sta ($01,s),y
	
	ldy.w #5
	lda.l bootTxt_sine_y,x
	adc #$20
	adc ($01,s),y
	ldy.w #2
	sta ($01,s),y
	
	jsr bootTextActor_timer
	jsr bootTextActor_checkKill
	
	lda.b #0
	pha
	plb
	tcd
	
	plx
	plx
	ply
	pla
	
	rts

bootTextActor_timer: {

	ldy.w #6
	lda ($03,s),y
	cmp.b #255
	bcs +
	inc
	sta ($03,s),y
	rts
	+
	ldy.w #4
	lda ($03,s),y
	adc.b #$01
	sta ($03,s),y
	rts

}

bootTextActor_checkKill: {

	ldy.w #1
	lda ($03,s),y
	cmp.b #253
	bcs +
	rts
	+
	jsr bootTextActor_resDB
	jsr f_destroyActor
	rts
}

bootTextActor_resDB: {

	
	pha
	lda.b #0
	tcd
	pha
	plb
	pla
	rts

}

bootTextActor_setDB: {

	
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

moveTable:

db $FF	//; null
db 10	//; F
db 30	//; 0
db 50	//; X
db 90	//; E
db 110	//; N
db 130	//; G
db 150	//; I
db 170	//; N
db 190	//; E

textTable:

db $FF	//; null
db $00
db $02
db $04
db $06
db $08
db $0A
db $0C
db $0E
db $20