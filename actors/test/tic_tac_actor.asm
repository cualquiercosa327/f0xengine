constant icon.cosIndex($06)
constant icon.cosMax(131)
constant icon.sinIndex($07)
constant icon.anchorX($08)
constant icon.anchorY($09)

ticActor_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #ACT_TYPE_TIC
	jsr setActorType
	
	ldy.w #sprVSP
	ldx.w #sprVSP.size
	lda.b #sprVSP >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprVST
	ldy.w #$0800
	lda.b #sprVST >> 16
	jsr allocateSVTEntry
	
	ldx.w #circleSprTbl
	lda.b #circleSprTbl >> 16
	jsr renderOAM
	
	ldx.w #ticActor_Update
	lda.b #ticActor_Update >> 16
	jsr f_setActorUpdate

	jsr f_setADB

	ldx.b ADTI
	lda.b #$10
	sta.w icon.anchorX,x
	lda.b #$21
	sta.w icon.anchorY,x

	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

ticActor2_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #ACT_TYPE_TIC
	jsr setActorType
	
	ldy.w #sprVSP
	ldx.w #sprVSP.size
	lda.b #sprVSP >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprNewsT
	ldy.w #$0800
	lda.b #sprNewsT >> 16
	jsr allocateSVTEntry
	
	ldx.w #circleSprTbl
	lda.b #circleSprTbl >> 16
	jsr renderOAM
	
	ldx.w #ticActor_Update
	lda.b #ticActor_Update >> 16
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue


ticActor3_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #ACT_TYPE_TIC
	jsr setActorType
	
	ldy.w #sprVSP
	ldx.w #sprVSP.size
	lda.b #sprVSP >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprMailT
	ldy.w #$0800
	lda.b #sprMailT >> 16
	jsr allocateSVTEntry
	
	ldx.w #circleSprTbl
	lda.b #circleSprTbl >> 16
	jsr renderOAM
	
	ldx.w #ticActor_Update
	lda.b #ticActor_Update >> 16
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

ticActor4_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #ACT_TYPE_TIC
	jsr setActorType
	
	ldy.w #sprVSP
	ldx.w #sprVSP.size
	lda.b #sprVSP >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprExitT
	ldy.w #$0800
	lda.b #sprExitT >> 16
	jsr allocateSVTEntry
	
	ldx.w #circleSprTbl
	lda.b #circleSprTbl >> 16
	jsr renderOAM
	
	ldx.w #ticActor2_Update
	lda.b #ticActor2_Update >> 16
	jsr f_setActorUpdate

	jsr f_setADB

	ldx.b ADTI
	lda.b #$30
	sta.w actor.tileFlags,x

	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

ticActor5_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP

	jsr f_setADB

	ldx.b ADTI
	lda.b #$31
	sta.w actor.tileFlags,x

	jsr f_resetADB
	
	lda.b #ACT_TYPE_TIC
	jsr setActorType
	
	ldy.w #sprVSP
	ldx.w #sprVSP.size
	lda.b #sprVSP >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprFightT
	ldy.w #$0800
	lda.b #sprFightT >> 16
	jsr allocateSVTEntry
	
	ldx.w #circleSprTbl
	lda.b #circleSprTbl >> 16
	jsr renderOAM
	
	ldx.w #ticActor2_Update
	lda.b #ticActor2_Update >> 16
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

ticActor6_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP

	jsr f_setADB

	ldx.b ADTI
	lda.b #$31
	sta.w actor.tileFlags,x

	jsr f_resetADB
	
	lda.b #ACT_TYPE_TIC
	jsr setActorType
	
	ldy.w #sprVSP
	ldx.w #sprVSP.size
	lda.b #sprVSP >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprToolsT
	ldy.w #$0800
	lda.b #sprToolsT >> 16
	jsr allocateSVTEntry
	
	ldx.w #circleSprTbl
	lda.b #circleSprTbl >> 16
	jsr renderOAM
	
	ldx.w #ticActor2_Update
	lda.b #ticActor2_Update >> 16
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

ticActor_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
	
	jsr f_setADB

	ldx.b ADTI
	lda.b #$30
	sta.w actor.tileFlags,x

	lda.b #0
	xba
	lda.w icon.cosIndex,x
	cmp.b #39-1
	beq +
	
	lda.w icon.cosIndex,x
	inc icon.cosIndex,x
	tax
	lda.l datIconSine1,x
	ldx.w ADTI
	sta.w actor.y,x
	
	+
	ldx.w #circleSprTbl
	lda.b #circleSprTbl >> 16
	jsr updateMetaSprites

	jsr ticActor_handleChoice

	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

ticActor_handleChoice: {

	lda.b actorIndex
	inc
	cmp.b OSIconIndex
	bne +

	jsr ticActor_fadeColor
	jsr ticActor_choiceMove

	+
	rts
}

ticActor_choiceMove: {

	ldx.b ADTI
	lda.w icon.anchorY,x
	pha
	lda.w icon.sinIndex,x
	inc icon.sinIndex,x
	rep #$20
	and.w #$00FF
	tax
	sep #$20
	lda.l datIconChoseSine,x
	ldx.b ADTI
	clc
	adc $01,s
	sta.w actor.y,x
	pla
	
	rts

}

ticActor_fadeColor: {
	
	lda.b $76				//; timer
	cmp.b #3
	bne +
	
	lda.b #0
	xba
	
	jsr colorFade

	ldy.b $72
	ldx.b $70
	jsr RGBtoBGR
	
	ldy.w #actor.SPTID+1
	lda (ADTI),y
	inc
	sta.l REG_CGADD
	
	rep #$20
	txa
	sep #$20
	sta.l REG_CGDATA
	xba
	sta.l REG_CGDATA
	xba
	sta.l REG_CGDATA
	xba
	sta.l REG_CGDATA

	stz.b $76

	+
	inc $76
	rts

}

ticActor2_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
	
	jsr f_setADB

	ldx.b ADTI
	lda.b #0
	xba
	lda.w icon.cosIndex,x
	cmp.b #35-1
	beq +
	
	lda.w icon.cosIndex,x
	inc icon.cosIndex,x
	tax
	lda.l datIconSine2,x
	ldx.w ADTI
	sta.w actor.y,x
	
	+
	ldx.w #circleSprTbl
	lda.b #circleSprTbl >> 16
	jsr updateMetaSprites

	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

datIconSine1:
db 223,226,230,234,237,241,245,249,252,256,260,263,267,270,273,276
db 279,282,285,287,289,291,293,295,296,297,298,298,298,298,298,298
db 297,296,295,293,291,289,287

datIconSine2:
db 223,230,238,245,253,260,268,276,283,291,298,306,313,320,326,333
db 339,344,350,355,359,363,367,370,372,374,376,377,377,377,377,376
db 374,372,369

datIconChoseSine:
db 0,0,0,0,0,1,1,2,3,3,4,5,6,7,8,8
db 9,10,11,11,12,12,13,13,13,13,13,13,13,13,12,12
db 11,11,10,9,8,8,7,6,5,4,3,3,2,1,1,0
db 0,0,0,0,0,0,0,0,1,1,2,3,3,4,5,6
db 7,8,8,9,10,11,11,12,12,13,13,13,13,13,13,13
db 13,12,12,11,11,10,9,8,8,7,6,5,4,3,3,2
db 1,1,0,0,0,0,0,0,0,0,0,1,1,2,3,3
db 4,5,6,7,8,8,9,10,11,11,12,12,13,13,13,13
db 13,13,13,13,12,12,11,11,10,9,8,8,7,6,5,4
db 3,3,2,1,1,0,0,0,0,0,0,0,0,0,1,1
db 2,3,3,4,5,6,7,8,8,9,10,11,11,12,12,13
db 13,13,13,13,13,13,13,12,12,11,11,10,9,8,8,7
db 6,5,4,3,3,2,1,1,0,0,0,0,0,0,0,0
db 0,1,1,2,3,3,4,5,6,7,8,8,9,10,11,11
db 12,12,13,13,13,13,13,13,13,13,12,12,11,11,10,9
db 8,8,7,6,5,4,3,3,2,1,1,0,0,0,0,0