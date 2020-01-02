constant OBJ_SMALL($00)
constant OBJ_LARGE($01)

constant SVT_LOC($7E6100)
constant MAX_SVT_ENTRIES(12)
constant SVT_ENTRY_SIZE(5)

constant ST_LOC($7E6200)
constant ST_ENTRY_SIZE(1)
constant MAX_ST_ENTRIES(128)

constant LAST_META_ENTRY(5)

constant OAMT_LOC($0400)
constant OAM_X(0)
constant OAM_Y(1)
constant OAM_TILE(2)
constant OAM_FLAGS(3)

constant OAM_LOW($0400)
constant OAM_HIGH($0600)

constant SVT_DUP_FOUND($00)
constant SVT_NO_DUP($01)

constant CMD_NULL($00)
constant CMD_SND($01)

constant FRAME_REPLAY($00)
constant FRAME_ONCE($80)

f_setSprite: {
	
	lda.b actorIndex
	pha
	phy
	ldy.w #0
	asl
	asl
	sta.w sprCallback
	rep #$30
	lda.w #$0400
	sep #$20
	adc sprCallback
	rep #$30
	sta.w sprCallback
	and.w #$00FF
	sep #$20
	lda.b stackActX
	sta [sprCallback],y
	lda.b stackActY
	iny
	sta [sprCallback],y
	txa //; tile
	iny
	sta [sprCallback],y
	tyx
	ply
	rep #$30
	tya //; flag
	sep #$20
	txy
	iny
	sta [sprCallback],y
	stz.w sprCallback
	stz.w sprCallback+1
	
	pla
	tax
	lsr
	lsr
	tay
	txa
	and #$03
	
	//;jsr calcHigh1
	
	rts
}

f_disableSprite: {

	lda.b actorIndex
	asl
	asl
	sta.w sprCallback
	rep #$30
	lda.w #$0400
	sep #$20
	adc sprCallback
	sta.w sprCallback
	lda.b #$01
	ldy.w #$0000
	sta [sprCallback],y
	iny
	sta [sprCallback],y
	iny
	sta [sprCallback],y
	iny
	sta [sprCallback],y
	stz.w sprCallback
	stz.w sprCallback+1
	
	lda.b actorIndex
	lsr
	lsr
	tay
	lda.b actorIndex
	and #$03
	
	//;jsr rH1
	
	rts
}

f_enableSprLarge: {
	
	lda.b actorIndex
	pha
	lsr
	lsr
	tay
	pla
	and #$03
	
	//;jsr calcHigh1B
	
	rts

}

initSVT:

	lda.b #PT_NULL
	pha
	sta.l SVT_LOC
	
	ldx.w #SVT_LOC
	ldy.w #SVT_LOC + 1
	lda.b #MAX_SVT_ENTRIES * SVT_ENTRY_SIZE - 2
	
	rep #$30
	pha
	
	mvn $7E=$7E
	
	pla
	plb
	
	sep #$20
	
	rts
	
allocateSVTEntry:

		phx
		phy
		pha
		
		lda.b #$7E
		pha
		plb
		
		ldx.w #0
		ldy.w #0
		
		phy
		ldy.w #SVT_LOC
		sty.w tempWord
		ply
		
		lda (ADTI),y
		pha
		
		-
			cpy.w #MAX_SVT_ENTRIES
			beq ++
			lda (tempWord)
			beq +
			
			jsr checkSVTDup
			beq endSVTDup
			
			iny
			inx #SVT_ENTRY_SIZE
			lda.b $04
			clc
			adc.b #5
			sta.b $04
			bra -
			
		+
			
			pla
			sta.l SVT_LOC,x
			phx
			txa
			adc.b #3
			tax
			inc SVT_LOC,x
			plx
			
			sep #$10
			
			phy
			phx
			tyx
			
			lda.l SVTCharTable,x
			ldy.b #actor.charAddr
			sta (ADTI),y
			
			plx
			
			rep #$20
			
			ply
			phx
			tya
			asl
			tax
			
			lda.l SVTSizeTable,x
			ldy.b #actor.vramAddr
			sta (ADTI),y
			
			plx
			pha
			
			inx
			sta.l SVT_LOC,x
			
			sep #$20
			rep #$10
			
			jsr f_resetADB
			
			lda.b #$80         
			//;sta.w REG_VMAIN
			sta.b dmaTemp+dmaMode
			
			rep #$20
			pla
			lsr
			tax
			xba
			sep #$20

			//;stx.w REG_VMADDL
			stx.b dmaTemp+dmaDest

			//;lda.b #$01
			//;sta.w REG_DMAP0
			//;lda.b #$18
			//;sta.w REG_BBAD0
			
			pla
			ply
			plx
			
			//;stx.w REG_A1T0L
			stx.b dmaTemp+dmaSrc
			//;sta.w REG_A1B0
			sta.b dmaTemp+dmaSrc+2
			
			//;sty.w REG_DAS0L
			sty.b dmaTemp+dmaSize

			//;lda.b #$01
			//;sta.w REG_MDMAEN

			jsr addDMAQueue
			
			rts
			
		+
			ply
			plx
			pla
			
			rts
			
	endSVTDup:
			
			pla
			pla
			ply
			plx
			
			rts
			
checkSVTDup:

	phx
	phy
	
	sep #$10
	
	ldy.b #0
	ldx.b #0
	lda $07,s		//; actor type
	
	-
	
	cpy.b #MAX_SVT_ENTRIES
	beq ++
	
	cmp SVT_LOC,x
	beq +
	iny
	inx
	inx
	inx
	inx
	inx
	bra -
	
	+
	
	rep #$10
	phx
	txa
	adc.b #2
	tax
	inc SVT_LOC,x
	plx
	
	sep #$10
	
	phy
	phx
	tyx
	
	lda.l SVTCharTable,x
	ldy.b #actor.charAddr
	sta (ADTI),y
	
	plx

	rep #$20
	
	ply
	phx
	tya
	asl
	tax
	
	lda.l SVTSizeTable,x
	ldy.b #actor.vramAddr
	sta (ADTI),y
	
	plx
	
	inx
	sta.l SVT_LOC,x
	
	sep #$20
	rep #$10

	ply
	plx
	
	lda.b #SVT_DUP_FOUND
	
	rts
	
	+
	
	rep #$10
	sep #$20
	
	ply
	plx
	
	lda.b #SVT_NO_DUP
	
	rts
	
renderOAM:

	pha
	plb
	
	sta.b tempByte
	stx.w tempWord
	lda (tempWord)
	pha 				//; S $01 = metasprite count
	inc tempWord		//; metasprite pointer++
	
	lda.b #$7E
	pha
	plb
	
	sep #$10
	
	ldx.b #0
	ldy.b #MAX_ST_ENTRIES
	
	findFreeSTSlot:
	
		cpy.b #0
		beq ++
		lda ST_LOC,x
		beq +
		inx
		dey
		bra findFreeSTSlot
		+
			pla
			dec
			tay
			phy
			sty.b trash
			phx
		-
			cpy.b #0
			beq allocateSTSlots
			inx
			lda ST_LOC,x
			bne moveToNextSlot
			dey
			bra -
			
		//; size does not match slot count
		moveToNextSlot:
		
			lda.b $02,s
			inc
			sta.b $02,s
			inx
			ldy.b trash
			bra findFreeSTSlot
			
		allocateSTSlots:
		
			plx		//; get starting allocation index
			stx.b sprCallback
			pla
			clc
			adc.b #1	//; get count + 1
			
			pha
			phx
			tay
			lda.b #0
			clc
			adc.b sprCallback
			tax
			lda.b #$FF
			-
				cpy.b #0
				beq +
				sta ST_LOC,x
				inx
				dey
				bra -
			+
			
			plx
			txa
			ldy.b #actor.oamIndex
			sta (ADTI),y
			pla
			
			iny
			sta (ADTI),y
			
			tay
			sty.b sprCallback+2
			
			ldy.b #actor.x
			lda (ADTI),y
			pha

			iny
			lda (ADTI),y
			sta.b stackActX			//; set upper 8-bits in stackActX
			
			ldy.b #actor.y
			lda (ADTI),y
			pha
			
			ldy.b #actor.SPTID
			lda (ADTI),y
			asl
			pha
			
			rep #$20
			
			ldy.b #actor.vramAddr
			lda (ADTI),y
			pha
			
			xba
			sep #$20
			
			ldy.b #actor.charAddr
			lda (ADTI),y
			pha
			
			lda.b tempByte
			pha
			plb
			
			ldy.b sprCallback+2
			
		parseSTDefinitions:
		
			cpy.b #0
			beq +
			jsr parseSTDef
			inc sprCallback
			bra parseSTDefinitions
			
		//; time to clean up our mess
		+
			rep #$20
			
			pla
			pla
			pla
			
			sep #$20
			rep #$10
			
			lda.b #0
			pha
			plb
			
			rts
			
parseSTDef:
	
	phb
	phy
	ldx.b #LAST_META_ENTRY
	txy
	dey
	-
		cpx.b #0
		beq plotOAMEntry
		lda (tempWord),y
		pha
		dex
		dey
		bra -
	
	plotOAMEntry:
		
		
		lda.b #MAX_ST_ENTRIES-1
		sbc.b sprCallback
		
		sta.b tempByte
		
		rep #$20
		asl
		asl
		clc
		adc.w #OAMT_LOC
		sta.w tempLong
		
		sep #$20

		lda.b #0
		tay
		pha
		plb
		xba
		
		pla		//; X position
		adc $0E,s
		sta [tempLong],y
		iny
		
		pla		//; Y position
		adc $0C,s
		sta [tempLong],y
		iny
		
		pla		//; size
		//;adc $0A,s ????
		sta sprCallback+2
		
		pla		//; char
		adc $06,s
		sta [tempLong],y
		iny
		
		pla		//; palette
		adc $08,s
		sta [tempLong],y
		
		lda.b tempByte
		tax
		lsr
		lsr
		tay
		txa
		
		and.b #3
		asl
		tax
		
		lda oamHighTable,x
		eor.b #$FF
		and OAM_HIGH,y
		
		phx
		
		ldx.b sprCallback+2
		beq +
		
		plx
		inx
		ora oamHighTable,x
		bra ++
		
		+
		
		plx
		
		+
		
		sta OAM_HIGH,y
		
		ply
		dey
		
		lda.b tempWord
		clc
		adc.b #5
		sta.b tempWord
		
		plb
		
		rts
		
checkOffscrn:

	pha
	lda.b stackActX
	beq +
	pla
	lda.b #0
	rts
	+
	pla
	rts

//; X = metasprite address
//; A = metasprite bank
updateMetaSprites:

	inx
	stx.w tempLong
	
	ldx.w #OAMT_LOC
	stx.w tempWord
	
	//; push metasprite bank
	pha
	
	sep #$10
	
	//; push MAX_ST_ENTRIES - actor.oamIndex
	ldy.b #actor.oamIndex
	lda.b #MAX_ST_ENTRIES-1
	sec
	sbc (ADTI),y
	
	pha
	iny
	
	//; get metasprite count and iterate through each one
	lda (ADTI),y
	tax
	
	-
		cpx.b #0
		bne +
		jmp endMetaCalc
		+
		//; push X
		ldy.b #actor.x
		lda (ADTI),y
		pha

		//; save X high bit
		iny
		lda (ADTI),y
		sta stackActX
		
		//; push Y
		ldy.b #actor.y
		lda (ADTI),y
		pha

		ldy.b #actor.charAddr
		lda (ADTI),y
		sta.b trash+1

		//; push sprite flag
		ldy.b #actor.tileFlags
		lda (ADTI),y
		pha

		//; push sprite frame
		ldy.b #6
		lda (ADTI),y
		sta.b trash

		ldy.b #actor.SPTID
		lda (ADTI),y
		asl
		sta.b tempByte			//; save palette
		
		phb
		
		//; bankswitch to metasprite bank
		lda $06,s
		pha
		plb
		
		//; store metasprite X
		ldy.b #0
		lda (tempLong),y
		sta.b sprCallback
		iny
		
		//; get metasprite Y
		lda (tempLong),y
		pha
		iny
		iny

		//; get metasprite frame
		lda (tempLong),y
		sta.b trash
		
		//; bankswitch back to actor space
		pla
		plb
		
		//; metasprite Y + actor Y
		clc
		adc $02,s
		sta $02,s
		
		//; metasprite X + actor X
		lda.b sprCallback
		adc $03,s
		sta $03,s

		//; handle offscreen areas
		jsr updateOffscrn
		
		//; get OAM address from slot index
		rep #$30
		lda $04,s
		and.w #$00FF
		asl
		asl
		tay
		sep #$20
		
		//; store calculated X and Y into OAMT
		lda $03,s
		sta [tempWord],y
		iny
		lda $02,s
		sta [tempWord],y
		iny
		
		//; store tile frame
		lda.b trash
		clc
		adc.b trash+1
		sta [tempWord],y
		
		//; store tile flag into OAMT
		iny
		lda $01,s
		ora.b tempByte
		sta [tempWord],y

		//; decrement slot index 
		dex
		clc
		lda $04,s
		dec
		sta $04,s
		
		//; increment metasprite address
		lda tempLong
		clc
		adc.b #5
		sta.b tempLong
		
		sep #$10
		
		//; clean our precious stack
		pla
		pla
		pla
		
		//; loop back until we've gotten every metasprite
		jmp -
		
	endMetaCalc:
	
	pla
	pla
	
	rep #$10
	
	rts

updateOffscrn:
	
	pha
	phx
	phy
	
	rep #$10
	lda.b #0
	xba
	lda $09,s		//; get oam index
	pha
	lsr
	lsr
	tay
	pla
	and.b #3
	asl
	tax

	lda.b stackActX
	beq +

	minusSFVD:
	
	stz.b sprCallback+1
	
	phx
	rep #$20
	ldx.b ADTI
	lda.w actor.x,x
	plx
	and.w #$01FF
	clc
	adc.b sprCallback
	bit.w #$0100
	beq +
	
	sep #$20
	lda oamHighTable,x
	ora OAM_HIGH,y
	sta OAM_HIGH,y
	bra ++

	+
	sep #$20
	lda oamHighTable,x
	eor.b #$FF
	and OAM_HIGH,y
	sta OAM_HIGH,y

	+
	sep #$10
	ply
	plx
	pla
	rts

macro defineMacroSprite(X, Y, SIZE, TILE, FLAG) {
	
		db {X}
		db {Y}
		
		if {SIZE} == OBJ_LARGE {
			db $01
		} else {
			db $00
		}
		
		db {TILE}
		db {FLAG}
}

macro defineFrame(DATA, COMMAND, DELAY) {
	
	db ({COMMAND} << 6) + {DELAY}
	dl {DATA}

}

macro defineFrameProp(CMD, LEN) {
	db {CMD} + {LEN}
	db 255				//; unused
	dw 65535			//; unused
}